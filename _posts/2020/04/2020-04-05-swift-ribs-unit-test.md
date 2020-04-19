---
layout: post
title: "[Swift5][RIBs] Uber의 RIBs 프로젝트에서 얻은 경험 (4) - Unit Test 작성하기"
description: ""
category: "programming"
tags: [iOS, Swift, Uber, RIBs, Unit]
---
{% include JB/setup %}

## 들어가기 전

이전 RIBs 관련 글에서 RIBs 아키텍처가 프로토콜 지향 프로그래밍을 강제한다는 것을 말했습니다. 그래서 적절한 Mock 객체를 주입을 하면 테스트가 가능합니다. 

간단한 유닛 테스트 예를 살펴봅시다.

```swift
protocol Servicable {
  func requestPageNumber() -> Int
}

class ServiceMock: Servicable {
  let value: Int

  init(value: Int) {
    self.value = value
  }

  func requestPageNumber() -> Int { value }
}

class Interactor {
  private let service: Servicable

  init(service: Servicable) {
    self.service = service
  }

  func pageNumber() -> Int { 
    service.requestPageNumber
  }
}

func test_pageNumber() {
  let mock = ServiceMock(value: 1)
  let interactor = Interactor(service: mock)
  XCTAssertEqual(interactor.pageNumber(), mock.value)
}
```

위와 같이 Interactor는 Servicable이라는 프로토콜 타입을 가지며, Mock 객체인 ServiceMock을 만들어 주입할 수 있습니다. 그리고 Interactor가 pageNumber를 호출할 때, ServiceMock의 value와 비교하여 올바르게 값을 반환하는지 확인할 수 있습니다.

이는 구현체 타입이 아닌 프로토콜 타입을 가지기 때문에 가능합니다.

이제 RIB의 테스트 코드를 한번 작성해봅시다.

## Interactor 유닛 테스트 하기

RIBs 프로젝트의 Tutorial 2 프로젝트를 열어보면 TicTacToeTests 폴더 아래에 `TicTacToeMocks.swift`라는 파일이 있습니다. 여기에는 Root, LoggedIn, LoggedOut의 Buildable, Interactable, Routing Mock 소스가 있습니다.

하지만 Interactor와 Router 구현체에 Mock 객체를 주입하면 별다른 작업을 하지 않아도, 실제 비지니스 로직을 테스트 할 수 있습니다. 따라서 Router에서 다른 Buildable을 가지고 Router를 만들 것이므로, Buildable을 따르는 Mock들만 만들면 됩니다.

LoggedOut RIB으로 유닛 테스트 작성해봅시다.

먼저 LoggedOut Interactor는 로그인하는 로직이 없다보니 로그인을 요청하는 Service를 추가하고 Interactor에 Service를 주입하는 코드를 만들어봅시다.

```swift
protocol LoggedOutServicable {
  func requestLogin(withPlayer1Name player1Name: String, player2Name: String) -> Bool
}

protocol LoggedOutRouting: ViewableRouting {
  func routeToFailAlert()
}

protocol LoggedOutPresentable: Presentable {
  var listener: LoggedOutPresentableListener? { get set }
    
  func failedLogin()
}

protocol LoggedOutListener: class {
  func didLogin(withPlayer1Name player1Name: String, player2Name: String)
}

final class LoggedOutInteractor: PresentableInteractor<LoggedOutPresentable>, LoggedOutInteractable, LoggedOutPresentableListener {

    weak var router: LoggedOutRouting?
    weak var listener: LoggedOutListener?

    private let service: LoggedOutServicable

    init(presenter: LoggedOutPresentable, service: LoggedOutServicable) {
      self.service = service
      super.init(presenter: presenter)

      presenter.listener = self
    }

    override func didBecomeActive() {
      super.didBecomeActive()
    }

    override func willResignActive() {
      super.willResignActive()
    }

    // MARK: - LoggedOutPresentableListener
    func login(withPlayer1Name player1Name: String?, player2Name: String?) {
      let player1Name = playerName(player1Name, withDefaultName: "Player 1")
      let player2Name = playerName(player2Name, withDefaultName: "Player 2")

      if service.requestLogin(withPlayer1Name: player1Name, player2Name: player2Name) {
        listener?.didLogin(withPlayer1Name: player1Name, player2Name: player2Name)
      } else {
        presenter.failedLogin()
        router?.routeToFailAlert()
      }
    }

    private func playerName(_ name: String?, withDefaultName defaultName: String) -> String {
      if let name = name {
        return name.isEmpty ? defaultName : name
      } else {
        return defaultName
      }
    }
}
```

다음으로는 Interactor에서 호출할 Router와 Presenter 그리고 Listener의 Mock을 추가해봅시다.

```swift
// FileName: Mock.swift

// MARK: - LoggedOutRoutingMock class

/// A LoggedOutRoutingMock class used for testing.
class LoggedOutRoutingMock: LoggedOutRouting {
  // Variables
  var viewControllable: ViewControllable
  var interactable: Interactable { didSet { interactableSetCallCount += 1 } }
  var interactableSetCallCount = 0
  var children: [Routing] = [Routing]() { didSet { childrenSetCallCount += 1 } }
  var childrenSetCallCount = 0
  var lifecycleSubject: PublishSubject<RouterLifecycle> = PublishSubject<RouterLifecycle>() { didSet { lifecycleSubjectSetCallCount += 1 } }
  var lifecycleSubjectSetCallCount = 0
  var lifecycle: Observable<RouterLifecycle> { return lifecycleSubject }
  
  // Function Handlers
  var loadHandler: (() -> ())?
  var loadCallCount: Int = 0
  var attachChildHandler: ((_ child: Routing) -> ())?
  var attachChildCallCount: Int = 0
  var detachChildHandler: ((_ child: Routing) -> ())?
  var detachChildCallCount: Int = 0
  
  var routeToFailAlertHandler: (() -> ())?
  var routeToFailAlertCallCount: Int = 0
  
  init(interactable: Interactable, viewControllable: ViewControllable) {
    self.interactable = interactable
    self.viewControllable = viewControllable
  }
  
  func load() {
    loadCallCount += 1
    loadHandler?()
  }
  
  func routeToFailAlert() {
    routeToFailAlertCallCount += 1
    routeToFailAlertHandler?()
  }
  
  func attachChild(_ child: Routing) {
    attachChildCallCount += 1
    attachChildHandler?(child)
  }
  
  func detachChild(_ child: Routing) {
    detachChildCallCount += 1
    detachChildHandler?(child)
  }
}

// MARK: - LoggedOutViewControllableMock class

/// A LoggedOutViewControllableMock class used for testing.
class LoggedOutViewControllableMock: LoggedOutViewControllable, LoggedOutPresentable {
  // Variables
  var uiviewController: UIViewController = UIViewController() { didSet { uiviewControllerSetCallCount += 1 } }
  var uiviewControllerSetCallCount = 0

  var listener: LoggedOutPresentableListener?
  
  // Function Handlers
  var failedLoginHandler: (() -> ())?
  var failedLoginCount: Int = 0
  
  init() {
  }

  func failedLogin() {
    failedLoginCount += 1
    failedLoginHandler?()
  }
}

// MARK: - LoggedOutLoggedOutListenerMock class

/// A LoggedOutLoggedOutListenerMock class used for testing.
class LoggedOutLoggedOutListenerMock: LoggedOutListener {

  // Function Handlers
  var didLoginWithPlayer1NameAndPlayer2NameHandler: ((String, String) -> ())?
  var didLoginWithPlayer1NameAndPlayer2NameCount: Int = 0

  func didLogin(withPlayer1Name player1Name: String, player2Name: String) {
    didLoginWithPlayer1NameAndPlayer2NameCount += 1
    didLoginWithPlayer1NameAndPlayer2NameHandler?(player1Name, player2Name)
  }
}

// MARK: - LoggedOutServiceMock class

/// A LoggedOutServiceMock class used for testing.
class LoggedOutServiceMock: LoggedOutServicable {
  var requestLoginWithPlayer1NameAndPlayer2NameHandler: ((String, String) -> Bool)?
  var requestLoginWithPlayer1NameAndPlayer2NameCount: Int = 0

  func requestLogin(withPlayer1Name player1Name: String, player2Name: String) -> Bool {
    requestLoginWithPlayer1NameAndPlayer2NameCount += 1
    return requestLoginWithPlayer1NameAndPlayer2NameHandler?(player1Name, player2Name) ?? true
  }
}
```

이제 우리는 Interactor를 테스트할 수 있습니다. 우선 테스트 클래스부터 만들어봅시다.

```swift
// FileName: LoggedOutTest.swift

import XCTest
@testable import TicTacToe

class LoggedOutInteractorTests: XCTestCase {
    
  var interactor: LoggedOutInteractor!
  var service: LoggedOutServiceMock!
  var listener: LoggedOutLoggedOutListenerMock!
  var viewController: LoggedOutViewControllableMock!
  var router: LoggedOutRoutingMock!

  override func setUp() {
    super.setUp()

    viewController = LoggedOutViewControllableMock()
    service = LoggedOutServiceMock()
    listener = LoggedOutLoggedOutListenerMock()
    interactor = LoggedOutInteractor(presenter: viewController, service: service)
    interactor.listener = listener
    viewController.listener = interactor

    router = LoggedOutRoutingMock(interactable: interactor, viewControllable: viewController)
    interactor.router = router

    router.load()
    router.interactable.activate()
  }
} 
```

Interactor를 제외한 나머지 요소들은 Mock으로 구성하여, 테스트 한 뒤 검증할 수 있도록 합니다.

이제 테스트 코드를 작성해봅시다.

먼저 Presenter로부터 플레이어 이름을 입력받아 정상적으로 로그인을 하고, 로그인이 되었다고 listener에 호출 하는지 검증하는 코드를 작성해봅시다.

```swift
class LoggedOutInteractorTests: XCTestCase {

  ...

  func test_login_success() {
    // Given
    service.requestLoginWithPlayer1NameAndPlayer2NameHandler = { (_, _) in true }

    // When
    viewController.listener?.login(withPlayer1Name: "Player1", player2Name: "Player2")

    // Then
    XCTAssertEqual(service.requestLoginWithPlayer1NameAndPlayer2NameCount, 1)
    XCTAssertEqual(listener.didLoginWithPlayer1NameAndPlayer2NameCount, 1)
  }
}
```

두번째로 Presenter로부터 플레이어 이름을 입력받았지만, 로그인 실패하는 경우 Presenter에 failedLogin() 함수를 호출하고, Router에 routeToFailAlert() 함수를 호출 하는지 검증하는 코드를 작성해봅시다.

```swift
class LoggedOutInteractorTests: XCTestCase {

  ...

  func test_login_failure() {
    // Given
    service.requestLoginWithPlayer1NameAndPlayer2NameHandler = { (_, _) in false }

    // When
    viewController.listener?.login(withPlayer1Name: "Player1", player2Name: "Player2")

    // Then
    XCTAssertEqual(viewController.failedLoginCount, 1)
    XCTAssertEqual(router.routeToFailAlertCallCount, 1)
  }
}
```

이렇게 Interactor의 테스트 코드를 쉽게 작성할 수 있습니다. 

다음으로 Router의 테스트 코드를 작성해봅시다.

## Router 유닛 테스트 하기

Router도 Interactor와 마찬가지로 테스트 코드를 작성할 수 있습니다. 하지만 일부 다른 점은, 다음 RIB과 연결해야 하므로, Builder를 Mock으로 만들어 넣어줘야 합니다. 

RootRouter는 LoggedIn과 LoggedOut RIB을 가지고 있는 Router로 해당 Router를 분석해봅시다.

```swift
@testable import TicTacToe

import XCTest

class RootRouterTests: XCTestCase {

  private var loggedInBuilder: LoggedInBuildableMock!
  private var rootInteractor: RootInteractableMock!
  private var rootRouter: RootRouter!

  override func setUp() {
    super.setUp()

    loggedInBuilder = LoggedInBuildableMock()
    rootInteractor = RootInteractableMock()
    rootRouter = RootRouter(interactor: rootInteractor,
               viewController: RootViewControllableMock(),
               loggedOutBuilder: LoggedOutBuildableMock(),
               loggedInBuilder: loggedInBuilder)
  }

  func test_routeToLoggedIn_verifyInvokeBuilderAttachReturnedRouter() {
    let loggedInRouter = LoggedInRoutingMock(interactable: LoggedInInteractableMock())
    var assignedListener: LoggedInListener? = nil
    loggedInBuilder.buildHandler = { (_ listener: LoggedInListener) -> (LoggedInRouting) in
      assignedListener = listener
      return loggedInRouter
    }

    XCTAssertNil(assignedListener)
    XCTAssertEqual(loggedInBuilder.buildCallCount, 0)
    XCTAssertEqual(loggedInRouter.loadCallCount, 0)

    rootRouter.routeToLoggedIn(withPlayer1Name: "1", player2Name: "2")

    XCTAssertTrue(assignedListener === rootInteractor)
    XCTAssertEqual(loggedInBuilder.buildCallCount, 1)
    XCTAssertEqual(loggedInRouter.loadCallCount, 1)
  }
}
```

setUp 함수를 먼저 살펴봅시다.

rootRouter는 Interactor, viewController, loggedOutBuilder, loggedInBuilder를 Mock으로 가집니다. Mock으로 가지므로, 테스트 코드 작성시 의도한 대로 호출되었는지 확인이 가능합니다.

```swift
override func setUp() {
  super.setUp()

  loggedInBuilder = LoggedInBuildableMock()
  rootInteractor = RootInteractableMock()
  rootRouter = RootRouter(interactor: rootInteractor,
             viewController: RootViewControllableMock(),
             loggedOutBuilder: LoggedOutBuildableMock(),
             loggedInBuilder: loggedInBuilder)
}
```

다음으로 test_routeToLoggedIn_verifyInvokeBuilderAttachReturnedRouter 함수를 살펴봅시다.

loggedInBuilder Mock은 build 함수가 구현되지 않았으므로, buildHandler에 Closure를 주입하여 LoggedInRouting Mock을 반환할 수 있도록 합니다.

```swift
let loggedInRouter = LoggedInRoutingMock(interactable: LoggedInInteractableMock())
var assignedListener: LoggedInListener? = nil
loggedInBuilder.buildHandler = { (_ listener: LoggedInListener) -> (LoggedInRouting) in
  assignedListener = listener
  return loggedInRouter
}
```

그리고 rootRouter의 routeToLoggedIn 함수를 호출하여 loggedInBuilder가 정상적으로 호출되었는지 build와 load 함수가 호출 Count 체크합니다.

```swift
rootRouter.routeToLoggedIn(withPlayer1Name: "1", player2Name: "2")

XCTAssertTrue(assignedListener === rootInteractor)
XCTAssertEqual(loggedInBuilder.buildCallCount, 1)
XCTAssertEqual(loggedInRouter.loadCallCount, 1)
```

Router의 테스트 코드는 자식 RIB의 buildHandler를 만들어 주입하는 것이 가장 귀찮은 작업입니다. 그래서 자식 RIB을 먼저 테스트 코드를 만든다면 자식 RIB의 Mock을 재사용하여 테스트 코드 작성하는데 금방 작성할 수 있습니다.

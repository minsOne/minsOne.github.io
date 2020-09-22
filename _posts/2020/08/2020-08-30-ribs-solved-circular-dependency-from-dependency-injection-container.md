---
layout: post
title: "[Swift][RIBs] RIBs에 Dependency Injection Container를 적용하여 의존성 관계 해결하기"
description: ""
category: "programming"
tags: [Swift, DI, Dependency Injection, IoC, Container, Circular Dependency, Protocol, RIBs, RIB, Builder, Adapter]
---
{% include JB/setup %}

이전에 작성한 글에서 DI Container를 이용하여 모듈간의 관계를 푸는 방법을 설명하였습니다. 이를 RIBs에 적용해보려 합니다.

LoggedIn RIB을 새로 만드는데, 이를 별도의 모듈로 만들려고 합니다. 그리고 LoggedIn RIB은 Verify RIB을 필요로 합니다. 그런데, Verify RIB은 어플리케이션 프로젝트에 위치해 있습니다.

<p style="text-align:center;">
    <img src="{{ site.production_url }}/image/2020/08/20200830_01.png" style="width: 600px"/>
</p><br/>

LoggedIn RIB은 Verify RIB을 알지 못하므로, 다음과 같은 일반적인 Builder 코드를 작성할 수 없습니다.


```
// MARK: - LoggedIn Module
/// File : LoggedInBuilder.swift

...

final class LoggedInBuilder: Builder<LoggedInDependency>, LoggedInBuildable {
  func build(withListener listener: LoggedInListener, name: String) -> LoggedInRouting {
    let component = LoggedInComponent(dependency: dependency, name: name)
    let viewController = LoggedInViewController()
    let interactor = LoggedInInteractor(presenter: viewController, name: component.name)
    interactor.listener = listener
    let verifyBuilder = VerifyBuilder(dependency: component)
    return LoggedInRouter(interactor: interactor, viewController: viewController, verifyBuilder: verifyBuilder)
  }
}
```

이전에 설명했던 DI Container와 RIB을 엮어 이를 해결해봅시다.


## 1. RIB 관리할 Container 만들기

우리가 만들 DI Container에서 Builder를 꺼낼때 Builder 객체가 아닌 타입을 꺼내야합니다. 꺼낸 Builder의 Dependency를 Component에 구현해줄 수 있기 때문입니다. 따라서 DI Container를 만들때 RIB의 Builder 타입을 저장하고 꺼내도록 만듭니다.

다음은 Builder 타입을 저장 및 관리하는 DI Container를 구현하였습니다.

```
// MARK: - DependencyContainer Module
/// File : BuilderContainer.swift

public protocol BuilderContainable {
  static func regist<T: Buildable>(builder: T.Type, with id: String)
  static func resolve(for id: String) -> Buildable.Type
}

public class BuilderContainer: BuilderContainable {
  public static let shared: BuilderContainer = BuilderContainer()
  private var container: [String: Buildable.Type] = [:]
  
  public static func regist<T: Buildable>(builder: T.Type, with id: String) {
    shared.container[id] = builder
  }
  
  public static func resolve(for id: String) -> Buildable.Type {
    guard let item = shared.container[id] else {
      assert(true, "등록되지 않은 아이디입니다.")
      return Void() as! Buildable.Type
    }
    return item
  }
}
```

BuilderContainer는 별도의 모듈에서 관리하도록 DependencyContainer 프로젝트를 만들어 그곳에서 구현하여 어플리케이션 또는 다른 모듈에서 꺼내어 쓸 수 있도록 합니다.

<p style="text-align:center;">
    <img src="{{ site.production_url }}/image/2020/08/20200830_02.png" style="width: 600px"/>
</p><br/>

## 2. 모듈간의 연결 - Protocol 만들기

먼저 LoggedIn RIB에서 사용할 Verify RIB을 만들어봅시다.

```
// MARK: - Application Module
/// File: VerifyBuilder.swift

import RIBs

protocol VerifyDependency: Dependency {
  var password: String { get }
}

final class VerifyComponent: Component<VerifyDependency> {
  fileprivate var password: String {
    return dependency.password
  }
}

// MARK: - Builder

protocol VerifyBuildable: Buildable {
  func build(withListener listener: VerifyListener) -> VerifyRouting
}

final class VerifyBuilder: Builder<VerifyDependency>, VerifyBuildable {
  override init(dependency: VerifyDependency) {
    super.init(dependency: dependency)
  }
  
  func build(withListener listener: VerifyListener) -> VerifyRouting {
    let component = VerifyComponent(dependency: dependency)
    let interactor = VerifyInteractor(password: component.password)
    interactor.listener = listener
    return VerifyRouter(interactor: interactor)
  }
}


/// File: VerifyInteractor.swift

import RIBs
import RxSwift

protocol VerifyRouting: Routing {
  func cleanupViews()
}

enum VerifyResult {
  case success, failed
}

protocol VerifyListener: class {
  func verify(result: VerifyResult)
}

final class VerifyInteractor: Interactor, VerifyInteractable {
  
  weak var router: VerifyRouting?
  weak var listener: VerifyListener?
  
  private let password: String
  
  init(password: String) {
    self.password = password
  }

  
  override func didBecomeActive() {
    super.didBecomeActive()
  }
  
  override func willResignActive() {
    super.willResignActive()
    
    router?.cleanupViews()
  }
}


/// File: VerifyRouter.swift

import RIBs

protocol VerifyInteractable: Interactable {
  var router: VerifyRouting? { get set }
  var listener: VerifyListener? { get set }
}

final class VerifyRouter: Router<VerifyInteractable>, VerifyRouting {
  func cleanupViews() {}

  override init(interactor: VerifyInteractable) {
    super.init(interactor: interactor)
    interactor.router = self
  }
}

```


어플리케이션 프로젝트에 있는 Verify RIB을, Feature 라는 모듈에서 Verify RIB을 사용해야 한다면 방법이 없습니다.

하지만 DependencyContainer 모듈에서 Protocol을 만들면 어플리케이션, Feature에서도 Protocol을 알 수 있습니다. Verify RIB이 이 Protocol을 따르도록 하고, 구현한 뒤, BuilderContainer에 등록한다면 Feature 모듈에서 BuilderContainer에서 Verify Builder를 꺼내어 사용할 수 있습니다.

그러면 필요한 Protocol은 어떤 것이 있을까요? Buildable, Dependency, Listener, Routing(옵션), ViewControllable(옵션)이 필요합니다. Router는 Routing, ViewableRouting인 RIBs의 기본 Protocol만 다루면 됩니다. 그리고 View에 기능이 추가 기능이 필요하다면 새로운 ViewControllable를 따르는 Protocol을 만들어 Dependency에 추가합니다.

```
// MARK: - DependencyContainer Module
/// File: DIVerifyRIBProtocol.swift

public let DIVerifyBuildId: String = "DIVerifyBuildId"

public enum DIVerifyResult {
  case success, failed
}

public protocol DIVerifyListener: class {
  func verify(result: DIVerifyResult)
}

public protocol DIVerifyDependency: Dependency {
  var password: String { get }
}

public protocol DIVerifyBuildable: Buildable {
  init(dependency: DIVerifyDependency)
  func build(withListener listener: DIVerifyListener) -> Routing
}

// MARK: - Optional
public protocol DIVerifyRouting: Routing {}
public protocol DIVerifyViewControllable: ViewControllable {}
```

이제 Verify RIB을 감싸는 Adapter RIB을 만든 뒤, DIVerify Protocol을 따르도록 합니다.

```
// MARK: - Application Module
/// File : DIVerifyBuilderAdapter.swift

final class DIVerifyBuilderAdapter: Builder<DIVerifyDependency>, DIVerifyBuildable, VerifyListener {
  private final class Component: RIBs.Component<DIVerifyDependency>, VerifyDependency {
    var password: String { dependency.password }
  }

  private weak var listener: DIVerifyListener?
  
  public required override init(dependency: DIVerifyDependency) {
    super.init(dependency: dependency)
  }

  public func build(withListener listener: DIVerifyListener) -> Routing {
    let component = Component(dependency: dependency)
    self.listener = listener
    
    let builder = VerifyBuilder(dependency: component)
    return builder.build(withListener: self)
  }

  public func verify(result: VerifyResult) {
    switch result {
    case .success:
      listener?.verify(result: .success)
    case .failed:
      listener?.verify(result: .failed)
    }
  }
}
```
DIVerifyBuilderAdapter는 VerifyListener를 따르도록 하여, Verify Interactor에서 받은 결과를 가공해서 다시 전달하도록 합니다. 이렇게 하면 사용하는 곳에서는 Verify를 몰라도, DIVerify Protocol은 알고 있기 때문입니다.

그러면 이제 `DIVerifyBuilderAdapter`를 `BuilderContainer`에 등록합시다.

```
// MARK: - Application Module
/// File: AppDelegate.swift

import DependencyContainer

class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    ...

    BuilderContainer.regist(builder: DIVerifyBuilderAdapter.self, with: DIVerifyBuildId)

    ...

    return true
  }
}
```

## 3. LoggedIn 모듈에서 Verify RIB 사용하기

이제 LoggedIn RIB에서 Verify RIB을 사용해봅시다.

첫번째 방법은 LoggedInDependency에서 VerifyBuilder를 요구하는 방법입니다.

```
// MARK: - LoggedIn Module
/// File : LoggedInBuilder.swift

import DependencyContainer
import RIBs

protocol LoggedInDependency: Dependency {
  var verifyBuilder: DIVerifyBuildable { get }
}

final class LoggedInComponent: Component<LoggedInDependency> {
  fileprivate var verifyBuilder: String {
    return dependency.verifyBuilder
  }
  fileprivate let name: String

  init(dependency: LoggedInDependency, name: String) {
    self.name = name
    super.init(dependency: dependency)
  }
}

final class LoggedInBuilder: Builder<LoggedInDependency>, LoggedInBuildable {
  func build(withListener listener: LoggedInListener, name: String) -> LoggedInRouting {
    let component = LoggedInComponent(dependency: dependency, name: name)
    let viewController = LoggedInViewController()
    let interactor = LoggedInInteractor(presenter: viewController, name: component.name)
    interactor.listener = listener
    let verifyBuilder = component.verifyBuilder
    return LoggedInRouter(interactor: interactor, viewController: viewController, verifyBuilder: verifyBuilder)
  }
}
```

두번째 방법은 LoggedInBuilder에서 BuilderContainer에서 꺼내어 사용하는 방법입니다.

```
// MARK: - LoggedIn Module
/// File : LoggedInBuilder.swift

import DependencyContainer
import RIBs

protocol LoggedInDependency: Dependency {}

final class LoggedInComponent: Component<LoggedInDependency>, DIVerifyDependency {
  fileprivate let name: String

  var password: String = ""

  init(dependency: LoggedInDependency, name: String) {
    self.name = name
    super.init(dependency: dependency)
  }
}

final class LoggedInBuilder: Builder<LoggedInDependency>, LoggedInBuildable {
  func build(withListener listener: LoggedInListener, name: String) -> LoggedInRouting {
    let component = LoggedInComponent(dependency: dependency, name: name)
    let viewController = LoggedInViewController()
    let interactor = LoggedInInteractor(presenter: viewController, name: component.name)
    interactor.listener = listener

    guard 
      let verifyBuilderType = BuilderContainer.resolve(for: DIVerifyBuildId) as? DIVerifyBuildable.Type 
      else {
        assert(true, "VerifyBuilder가 등록되어 있지 않습니다.")
        return Void() as! LoggedInRouting
    }

    let verifyBuilder = verifyBuilderType.init(dependency: component)

    return LoggedInRouter(interactor: interactor, viewController: viewController, verifyBuilder: verifyBuilder)
  }
}
```

이렇게 DependencyContainer를 이용하여 서로 다른 모듈에 있더라도 의존성을 해결할 수 있습니다.


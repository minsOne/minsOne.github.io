---
layout: post
title: "[iOS][Swift] 모듈간의 관계를 Dependency Injection Container으로 풀어보자 - Interface"
description: ""
category: "programming"
tags: []
---
{% include JB/setup %}

## 모듈화 진행 과정 중 어려운 점

프로젝트가 커지면 전체적인 생산성이 감소합니다. 감소하는 이유로는 빠른 개발로 프로젝트 정리의 미진함, 레거시 코드의 발목 잡기, 방대한 양의 코드로 빌드 시간 증가, 테스트 코드 작성 시간 증가 등등이 있습니다.

이런 문제는 모듈화 작업으로 레거시 코드 정리 작업, 도메인별 코드 분리, 도메인별 테스트 코드 분리, 레거시 코드 정리을 할 수 있어 낮은 생산성을 끌어올릴 수 있습니다. 

하지만 운영중인 서비스에서는 이 작업이 쉽지는 않습니다. 그리고 기존 프로젝트는 분리하기 어렵지만 새로운 기능, 도메인에서는 모듈화를 하고 싶기도 합니다.

다양한 요구사항을 만족시킬 수 있는 방법은 있을까요?

사실 쉽지 않습니다. 

첫번째 예로, 카카오뱅크의 세이프박스라는 서비스를 만든다고 가정해봅시다. 세이프박스는 1천만원까지 금액을 별도의 계좌에 보관하고, 매일 이자가 붙는 상품입니다. 세이프박스에서 **금액을 입력**하고, **인증 비밀번호를 입력**하여 거래가 완료이 됩니다.

<p style="text-align:center;">
  <img src="{{ site.development_url }}/image/2020/06/18_6.png" style="width: 300px"/>
  <img src="{{ site.development_url }}/image/2020/06/18_7.png" style="width: 300px"/>
</p><br/>

이 서비스에서 금액 입력 등의 기본적인 기능까지는 새로운 모듈에서 작업을 하였습니다. 그러나 마지막 인증 비밀번호를 입력하는 기능은 아직 모듈화가 되지 않았습니다. 가장 핵심이 되는 기능을 붙이지 못해 서비스가 만들어지지 못합니다.

이런 경우는 어떻게 해야 할까요? 메인 프로젝트에서 세이프박스를 호출하니, 인증 기능을 Closure로 받아서 저장 후, 세이브 박스가 인증 Closure를 계속 가져다니다가 마지막에 처리하는 방식이 있습니다. 또는, 세이프박스가 Delegate 방식을 이용해서 인증 기능을 세이프박스 호출한 객체에서 인증 기능을 구현하여 해결할 수 있습니다.

여러모로 인증이라는 기능이 모듈로 분리되지 않아, 작업이 어렵습니다.

두번째 예로, 카카오뱅크의 카드 서비스에서는 **카드 관리**라는 화면이 있습니다. 여기에는 연결된 **입출금 통장의 관리 화면**으로 진입을 할 수 있습니다. 그리고 입출금 통장 관리에서는 **연결된 카드의 관리 화면**으로 진입할 수 있습니다.

<p style="text-align:center;">
  <img src="{{ site.development_url }}/image/2020/06/18_8.png" style="width: 300px"/>
  <img src="{{ site.development_url }}/image/2020/06/18_9.png" style="width: 300px"/>
</p><br/>

즉, **카드 관리 -> 입출금 통장 관리 -> 카드 관리 -> 입출금 통장 관리 -> 카드 관리 -> ...** 와 같은 과정이 생깁니다. 각 서비스들을 아직 모듈로 분리하지 않았다면 이런 과정이 가능합니다. 하지만, 카드 관리와 입출금 통장 관리 서비스가 모듈화로 분리되면 어떨까요?

<p style="text-align:center;">
    <img src="{{ site.development_url }}/image/2020/06/18_10.png" style="width: 400px"/>
</p><br/>

위와 같은 다이어그램이 그려집니다. 이는 카드 관리와 입출금 통장 관리간의 **순환 종속성 관계(Circular Dependency)**를 가지며 컴파일 에러가 발생합니다. 적절한 모듈화도 좋지만, 순환 종속성이 생기면 모듈화를 섯불리 하기도 어렵습니다.

이런 문제는 어떻게 해결해야 할까요?

## IOC Container와 Dependency Injection

이미 이러한 문제들은 다른 분야(특히 서버)에서 해결책을 많이 내놓았습니다. 마틴 파울러가 [**Inversion of Control Containers and the Dependency Injection pattern**](https://www.martinfowler.com/articles/injection.html)로 우리가 고민하고 있는 것을 잘 정리해놓았습니다.

Dependency Injection 패턴 중 Interface Injection 방식으로 첫번째 경우를 풀어보려고 합니다.

### Interface Injection: 세이프박스 → 인증비밀번호

먼저 의존성을 담당할 별도의 프레임워크 - DependencyContainer 를 만듭니다.

<p style="text-align:center;">
    <img src="{{ site.development_url }}/image/2020/06/18_11.png" style="width: 400px"/>
</p><br/>

그리고 DependencyContainer 프로젝트에서 의존성 주입할 프로토콜을 만듭니다.

```
/// Module: DependencyContainer
/// File: SigningInject.swift

public static let signingInjectId = "SigningInjectId"

public protocol SigningInject {
  func request(withSign parameter: [String:String], completion: (([String:String]) -> Void), failure: ((Error) -> Void))
}
```

인증 비밀번호를 사용하고자 하는 클래스들은 `SigningInject` 프로토콜을 구현하기만 하면 됩니다. 첫번째 경우에서 인증 비밀번호가 모듈로 분리되어 있지 않아, 메인 프로젝트에서 구현해야 합니다.

```
/// Module: Application
/// File: SigningImplement.swift

import DependencyContainer

public class SigningImplement: SigningInject {
  func request(withSign parameter: [String:String], completion: (([String:String]) -> Void), failure: ((Error) -> Void)) {
    completion(parameter)
  }  
}
```

DependencyContainer 프로젝트에 Container를 만들어 의존성 주입 프로토콜을 구현한 구현체를 등록할 준비를 합니다. 

첫번째로, Injectable 프로토콜을 만들고 이 프로토콜을 등록시킬 Container를 만듭니다.

```
/// Module: DependencyContainer
/// File: Injectable.swift

public protocol Injectable {
  init()
  var id: String { get }
  func resolve() -> AnyObject
}


/// File: Container

public protocol ContainerAPI {
  func regist(injectType: Injectable.Type)
  func load(for injectId: String) -> Injectable?
}

public class Container: ContainerAPI {
  private var injections: [String: Injectable] = [:]
  public static let shared: Container = Container()

  public func regist(injectType: Injectable.Type) {
    let injection = injectType.init()
    injections[injection.id] = injection
  }

  public func load(for injectId: String) -> Injectable? {
    return injections[injectId]
  }
}
```

두번째로, 메인 프로젝트에서는 인증 비밀번호 Inject 아이템을 만들고, 구현체를 세이프박스에서 사용하도록 Container에 등록합니다.

```
/// Module: Application
/// File: SigningImplement.swift

import DependencyContainer

class SigningInjectItem: Injectable {
  init() {}
  var id: String = signingInjectId
  func resolve() -> AnyObject {
    SigningImplement()
  }
}

public class SigningImplement: SigningInject {
  func request(withSign parameter: [String:String], completion: (([String:String]) -> Void), failure: ((Error) -> Void)) {
    completion(parameter)
  }  
}


/// File: AppDelegate

import DependencyContainer

class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    ...

    Container.shared.regist(injectType: SigningInjectItem.self)

    ...

    return true
  }
}
```

인증기능이 Container에 등록되어, 이제 세이프박스에서 인증 기능을 꺼내어 사용할 수 있습니다.

먼저 세이프박스에서 DependencyContainer를 연결합니다.

<p style="text-align:center;">
    <img src="{{ site.development_url }}/image/2020/06/18_12.png" style="width: 400px"/>
</p><br/>

이제 세이프박스에서 인증이 필요한 곳에서 Container에 등록된 SigningInjectItem을 꺼내어 resolve를 호출하여 인증 인터페이스인 SigningInject 타입 객체를 얻어 사용할 수 있습니다.

```
/// Module: SafeBox

import DependencyContainer

class SafeBoxVerifyService {
  ...

  func signing(parameter: [String:String], completion: (([String:String]) -> Void), failure: ((Error) -> Void)) {
    guard let service = Container.shared.load(for: signingInjectId)?.resolve() as? SigningInject else {
      failure(NSError(domain: "com.kakaobank.example", code: -1, userInfo: nil))
      return
    }
    service.request(withSign: parameter, completion: completion, failure: failure)
  }
}
```

<br/>

### 순환 종속성 관계(Circular Dependency): 카드 관리 ⇄ 입출금통장 관리

순환 종속성 관계도 마찬가지로 Dependency Injection Container를 이용하여 풀 수 있습니다. DependencyContainer에서 카드 관리, 입출금통장 관리의  의존성 주입 프로토콜을 정의하고, 각 모듈에서는 구현하고, 메인 프로젝트는 카드 관리, 입출금통장 관리 모듈을 알고 있으므로, 인증 기능을 Container에 등록하듯 카드 관리와 입출금통장 관리도 Container에 등록이 가능합니다.

즉, 카드 관리와 입출금통장 관리가 서로 종속성을 가지는 것이 아니라, DependencyContainer에 종속성을 가지도록 변경됩니다.

<p style="text-align:center;">
    <img src="{{ site.development_url }}/image/2020/06/18_13.png" style="width: 400px"/>
</p><br/>

그러면 카드 관리와 입출금통장 관리가 서로 종속성을 가지지 않도록 만들어봅시다.

첫번째로 DependencyContainer 프로젝트에 카드 관리 의존성 프로토콜과 입출금통장 관리 의존성 프로토콜을 선언합니다.

```
/// Module: DependencyContainer
/// File: ManagementCardInject.swift

public static let managementCardInjectId = "ManagementCardInjectId"

public protocol ManagementCardInject {
  func viewController(with cardNumber: String) -> UIViewController
}

/// File: ManagementDemandDepositInject.swift

public static let managementDemandDepositInjectId = "ManagementDemandDepositInject"

public protocol ManagementDemandDepositInject {
  func viewController(with accountNumber: String) -> UIViewController
}
```

두번째로 카드 관리와 입출금통장 관리 모듈에서 Inject 프로토콜을 구현합니다.

```
/// Module: Card
/// File: ManagementCardInjectImplement.swift

import DependencyContainer

public class ManagementCardInjectImplement: ManagementCardInject {
  public func viewController(with cardNumber: String) -> UIViewController {
    ...
    let vc = ManagementCardViewController(cardNumber: cardNumber) 
    return vc
  }
}


/// Module: DemandDeposit
/// File: ManagementDemandDepositInjectImplement.swift

public class ManagementDemandDepositInjectImplement: ManagementDemandDepositInject {
  public func viewController(with accountNumber: String) -> UIViewController {
    ...
    let vc = ManagementDemandDepositViewController(accountNumber: accountNumber)
    return vc
  }
}
```

세번째로 메인 프로젝트에서 카드 관리 Inject 아이템, 입출금통장 관리 Inject 아이템을 만들고, 구현체를 카드 관리, 입출금통장 관리에서 사용하도록 Container에 등록합니다.

```
/// Module: Application
/// File: ManagementCardInjectItem.swift

import DependencyContainer
import Card

class ManagementCardInjectItem: Injectable {
  init() {}
  var id: String = managementCardInjectId
  func resolve() -> AnyObject {
    ManagementCardInjectImplement()
  }
}


/// File: ManagementDemandDepositInjectItem.swift

import DependencyContainer
import DemandDeposit

class ManagementDemandDepositInjectItem: Injectable {
  init() {}
  var id: String = managementDemandDepositInjectId
  func resolve() -> AnyObject {
    ManagementDemandDepositInjectImplement()
  }
}


/// File: AppDelegate

import DependencyContainer

class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    ...

    Container.shared.regist(injectType: SigningInjectItem.self)
    Container.shared.regist(injectType: ManagementCardInjectItem.self)
    Container.shared.regist(injectType: ManagementDemandDepositInjectItem.self)

    ...

    return true
  }
}
```

마지막으로 카드 관리, 입출금통장 관리에서 DependencyContainer의 Container에 등록되어 있는 ManagementCardInject, ManagementDemandDepositInject 프로토콜을 구현한 구현체를 꺼내어 각 화면으로 이동할 수 있습니다.



## 정리

Dependency Injection Container를 이용하여 모듈간의 종속 관계를 끊을 수 있습니다.

ps. ~~첫번째 예제도 사실상 순환 종속성 관계로, 인증 기능때문에 메인 프로젝트와 세이프박스 서로 종속성을 가짐.~~















<div class="alert warning"><strong>경고</strong>:본 내용은 이해하면서 작성하는 글이기 때문에 잘못된 내용이 포함될 수 있습니다. 따라서 언제든지 내용이 수정되거나 삭제될 수 있습니다.</div>

이 편에서는 코드를 분석 및 이해하고 다음 편에서 개념을 제대로 다룰 예정입니다.

# Plugin Pattern

어플리케이션의 크기가 커지면, 기능 개발하기에는 빌드 속도가 느려지고, 각 기능간의 커플링 등이 일어날 수 있어 각 기능을 집중해서 개발하도록 모듈로 분리를 합니다.

<p style="text-align:center;"><img src="{{ site.production_url }}/image/2020/06/18_1.png" style="width: 500px"/></p><br/>

위 이미지에서는 각 기능 간의 연결이 없습니다. 하지만 요구사항이 그렇게 만만하지 않습니다. Feature A에서 Feature B를 필요로 할 때도 있고, Feature B에서 Feature A를 필요로 할 때도 있습니다.

<p style="text-align:center;"><img src="{{ site.production_url }}/image/2020/06/18_2.png" style="width: 500px"/></p><br/>

이런 경우는 Feature A와 Feature B가 서로 요구를 하기 때문에, Circular Dependency - 순환 종속성 관계로, 컴파일이 되지 않습니다.

Feature A, B는 App에다 요청을 하여 위임하는 방법이 있습니다. 

<!-- App 에다 위임하는 그림 -->

하지만 깊이가 깊어진다면 요청하기도 쉽지가 않아집니다.

<!-- 뎁스가 깊은 그림 -->

그러면 어떻게 해야할까요?

플러그인 패턴을 이용하여 기능의 확장 및 유연성을 보장받을 수 있습니다. 플러그인 패턴은 다음 편에서 상세하게 설명할 예정입니다.

<p style="text-align:center;"><img src="{{ site.production_url }}/image/2020/06/18_5.png"/></p><br/>

Plugin 모듈의 Container에 각 Feature에 필요한 Interface를 정의하고, 각 모듈에서 Plugin에서 필요한 Interface를 따라 구현한 후, Container에 등록합니다.

그러면 Feature A와 Feature B 모듈은 서로 알 필요 없이, Plugin 모듈에 등록되어 있는 Feature A, B를 가져다 사용하면 됩니다.

위 그림을 코드로 봅시다.

먼저 각 Plugin Interface를 담당할 Plugable 프로토콜을 만듭니다.

```
// MARK: - PlugIn Module

public protocol Plugable {
  init()
  var pluginId: String { get }
  func plug() -> AnyObject?
}
```

그리고 Plugin을 관리할 PluginManager를 만듭니다.

```
// MARK: - PlugIn Module

public protocol PluginAPI {
  func regist(pluginTypes: [Plugable.Type])
  func plugin<T: Plugable>(for pluginId: String) -> T?
}

public class PluginManager: PluginAPI {
  static public let shared: PluginManager = PluginManager()
  private var plugins: [String: Plugable] = [:]

  public func regist(pluginTypes: [Plugable.Type]) {
    pluginTypes.forEach { pluginType in
      let plugin = pluginType.init()
      plugins[plugin.pluginId] = plugin
    }
  }

  public func plugin<T: Plugable>(for pluginId: String) -> T? {
    return plugins[pluginId] as? T
  }
}
```

PluginManager를 접근하여 Plugin을 꺼낼 수 있습니다.

그러면 모듈에서 PluginManager에 등록할 구현체를 만들어봅시다.

첫번째로, Plugin 모듈에 FeatureA Plugin의 Interface를 정의합니다.

```
// MARK: - Plugin Module

public let FeatureA_PluginId = "FeatureA_Plugin"

public protocol FeatureAPluginAPI {
  func viewController(uuid: String) -> UIViewController
}
```

두번째로, FeatureA 모듈에서 Plugin으로 등록할 기능을 만듭니다.

```
// MARK: - FeatureA

class FeatureAViewController: UIViewController {
	init(uuid: String) {
		...
	}

	...
}

class FeatureAPluginAPIInternal: FeatureAPluginAPI {
  func viewController(uuid: String) -> UIViewController {
    FeatureAViewController(uuid: String)
  }
}

class FeatureAPlugin: Plugable {
  public required init() {}

  public var pluginId: String {
    return TopStoriesUIPluginId
  }

  public func plug() -> AnyObject? {
    return FeatureAPluginAPIInternal()
  }
}
```




# 참고자료 

* https://github.com/Vinodh-G/NewsApp 
* https://blog.usejournal.com/extending-your-modules-using-a-plugin-architecture-c1972735d728 
* https://gist.github.com/dehrom/ac1a50cfbee3b573fd590150e652f914 
* https://kdata.or.kr/info/info_04_view.html?field=&keyword=&type=techreport&page=223&dbnum=127607&mode=detail&type=techreport 
* https://en.wikipedia.org/wiki/Plug-in_(computing)
* https://javacan.tistory.com/entry/120
* https://gunju-ko.github.io/toby-spring/2019/03/25/IoC-%EC%BB%A8%ED%85%8C%EC%9D%B4%EB%84%88%EC%99%80-DI.html
* https://develogs.tistory.com/7
* https://ilya.puchka.me/ioc-container-in-swift/
* https://basememara.com/swift-dependency-injection-via-property-wrapper/
* https://theswiftdev.com/swift-dependency-injection-design-pattern/
* https://spring.io/blog/2010/06/01/what-s-a-plugin-oriented-architecture
* https://www.youtube.com/watch?v=lOcJ2z-tgu0
* Swinject to handle dependency injection, Felipe Garcia (English) https://www.youtube.com/watch?v=8a_oL8-ioqA
* https://github.com/ivlevAstef/DITranquillity
* https://github.com/Angel-Cortez/example-buck-ribs-needle

마틴파울러 - Inversion of control Containers and the Dependency pattern 관련 글

* https://greatshin.tistory.com/8
* https://javacan.tistory.com/entry/120
* https://martinfowler.com/eaaCatalog/plugin.html

* [디자인패턴] IoC, DI, DIP 용어 정리  https://black-jin0427.tistory.com/194

http://www.masterqna.com/android/88455/%EC%9D%B8%EC%95%B1-%EB%8D%B0%EC%9D%B4%ED%84%B0%ED%8C%A9-%ED%94%8C%EB%9F%AC%EA%B7%B8%EC%9D%B8-%EC%95%84%ED%82%A4%ED%85%8D%EC%B2%98-%ED%8C%A8%ED%84%B4-%EB%AA%A8%EB%93%88-dynamic-delivery

<!--
//
//  Copyright (c) 2017. Uber Technologies
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import RIBs
import RxSwift
import UIKit

/// Game app delegate.
@UIApplicationMain
public class AppDelegate: UIResponder, UIApplicationDelegate {

    /// The window.
    public var window: UIWindow?

    /// Tells the delegate that the launch process is almost done and the app is almost ready to run.
    ///
    /// - parameter application: Your singleton app object.
    /// - parameter launchOptions: A dictionary indicating the reason the app was launched (if any). The contents of
    ///   this dictionary may be empty in    situations where the user launched the app directly. For information about
    ///   the possible keys in this dictionary and how to handle them, see Launch Options Keys.
    /// - returns: false if the app cannot handle the URL resource or continue a user activity, otherwise return true.
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)

        PluginManager.shared.load(pluginTypes: [LoggedInPlugin.self])

        self.window = window

        let launchRouter = RootBuilder(dependency: AppComponent()).build()
        self.launchRouter = launchRouter
        launchRouter.launch(from: window)

        return true
    }

    // MARK: - Private

    private var launchRouter: LaunchRouting?
}


// MARK: - Plugin Module
public protocol Plugable {
    init()
    var pluginId: String { get }
    func plug() -> AnyObject?
}

public protocol PluginAPI {
    func load(pluginTypes: [Plugable.Type])
    func plugin(for pluginId: String) -> Plugable?
}

public class PluginManager: PluginAPI {

    static public let shared: PluginManager = PluginManager()
    private var plugins: [String: Plugable] = [:]

    public func load(pluginTypes: [Plugable.Type]) {

        pluginTypes.forEach { (pluginType) in
            let plugin = pluginType.init()
            plugins[plugin.pluginId] = plugin
        }
    }

    public func plugin(for pluginId: String) -> Plugable? {
        return plugins[pluginId]
    }
}

public let LoggedInPluginBuildId: String = "LoggedInPluginBuildId"

public protocol LoggedInPluginListener: class {}

public protocol LoggedInPluginDependency: Dependency {
    var viewController: ViewControllable { get }
    var player1Name: String { get }
    var player2Name: String { get }
}

public protocol LoggedInPluginBuildable: Buildable {
    init(dependency: LoggedInPluginDependency)
    func build(withListener listener: LoggedInPluginListener) -> Routing
}





// MARK: - LoggedIn Module
class LoggedInPluginAdapter: LoggedInPluginBuildable, LoggedInListener {
    private class Component: LoggedInDependency {
        private class ViewControllerWrapper: LoggedInViewControllable {
            func present(viewController: ViewControllable) {
                uiviewController.present(viewController.uiviewController, animated: true, completion: nil)
            }

            func dismiss(viewController: ViewControllable) {
                viewController.uiviewController.dismiss(animated: true, completion: nil)
            }

            var uiviewController: UIViewController
            init(viewControllable: ViewControllable) {
                self.uiviewController = viewControllable.uiviewController
            }
        }
        var loggedInViewController: LoggedInViewControllable

        init(viewControllable: ViewControllable) {
            self.loggedInViewController = ViewControllerWrapper(viewControllable: viewControllable)
        }
    }

    private weak var listener: LoggedInPluginListener?

    func build(withListener listener: LoggedInPluginListener, player1Name: String, player2Name: String, viewController: ViewControllable) -> Routing {
        self.listener = listener
        let component = Component(viewControllable: viewController)
        let builder = LoggedInBuilder(dependency: component)
        let router = builder.build(withListener: self, player1Name: player1Name, player2Name: player1Name)
        return router
    }
}

public class LoggedInPlugin: Plugable {
    public required init() {}

    public var pluginId: String {
        LoggedInPluginBuildId
    }

    public func plug() -> AnyObject.Type? {
        LoggedInPluginAdapter.self
    }
}


import RIBs

protocol RootDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class RootComponent: Component<RootDependency> {

    let rootViewController: RootViewController

    init(dependency: RootDependency,
         rootViewController: RootViewController) {
        self.rootViewController = rootViewController
        super.init(dependency: dependency)
    }
}

// MARK: - Builder

protocol RootBuildable: Buildable {
    func build() -> LaunchRouting
}

final class RootBuilder: Builder<RootDependency>, RootBuildable {

    override init(dependency: RootDependency) {
        super.init(dependency: dependency)
    }

    func build() -> LaunchRouting {
        let viewController = RootViewController()
        let component = RootComponent(dependency: dependency,
                                      rootViewController: viewController)
        let interactor = RootInteractor(presenter: viewController)

        let loggedOutBuilder = LoggedOutBuilder(dependency: component)
//        let loggedInBuilder = LoggedInBuilder(dependency: component)
        let loggedInBuilder = PluginManager.shared.plugin(for: LoggedInPluginBuildId)?.plug() as? LoggedInPluginBuildable


        return RootRouter(interactor: interactor,
                          viewController: viewController,
                          loggedOutBuilder: loggedOutBuilder,
                          loggedInBuilder: loggedInBuilder)
    }
}







import RIBs

protocol RootInteractable: Interactable, LoggedOutListener, LoggedInPluginListener {
    var router: RootRouting? { get set }
    var listener: RootListener? { get set }
}

protocol RootViewControllable: ViewControllable {
    func present(viewController: ViewControllable)
    func dismiss(viewController: ViewControllable)
}

final class RootRouter: LaunchRouter<RootInteractable, RootViewControllable>, RootRouting {

    init(interactor: RootInteractable,
         viewController: RootViewControllable,
         loggedOutBuilder: LoggedOutBuildable,
         loggedInBuilder: LoggedInPluginBuildable?) {
        self.loggedOutBuilder = loggedOutBuilder
        self.loggedInBuilder = loggedInBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    override func didLoad() {
        super.didLoad()

        routeToLoggedOut()
    }

    func routeToLoggedIn(withPlayer1Name player1Name: String, player2Name: String) {
        // Detach logged out.
        if let loggedOut = self.loggedOut {
            detachChild(loggedOut)
            viewController.dismiss(viewController: loggedOut.viewControllable)
            self.loggedOut = nil
        }

        if let loggedIn = loggedInBuilder?.build(withListener: interactor, player1Name: player1Name, player2Name: player2Name) {
            attachChild(loggedIn)
        }
    }

    // MARK: - Private

    private let loggedOutBuilder: LoggedOutBuildable
    private let loggedInBuilder: LoggedInPluginBuildable?

    private var loggedOut: ViewableRouting?

    private func routeToLoggedOut() {
        let loggedOut = loggedOutBuilder.build(withListener: interactor)
        self.loggedOut = loggedOut
        attachChild(loggedOut)
        viewController.present(viewController: loggedOut.viewControllable)
    }
}

-->

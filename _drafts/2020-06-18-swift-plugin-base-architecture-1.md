---
layout: post
title: "[iOS][Swift] 플러그인 패턴(1) - 소스위주의 분석"
description: ""
category: "programming"
tags: []
---
{% include JB/setup %}

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

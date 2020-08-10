---
layout: post
title: "[Swift][RIBs] RIBs + Dependency Injection Container"
description: ""
category: ""
tags: []
---
{% include JB/setup %}



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
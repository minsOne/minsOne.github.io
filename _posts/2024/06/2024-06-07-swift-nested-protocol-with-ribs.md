---
layout: post
title: "[Swift 5.10] Nested Protocol With RIBs"
tags: [Swift, Protocol, RIBs]
---
{% include JB/setup %}

Swift에서는 Protocol을 제외한 대부분의 타입은 타입 내부에서 다른 타입을 정의할 수 있었습니다.

```swift
struct Parent {
    class ChildClass {} // ✅
    struct ChildStruct {} // ✅
    enum ChildEnum {} // ✅
    protocol ChildProtocol {} // ❌
}
```

이로 인해 Protocol 이름은 길어질 수밖에 없었습니다.

```swift
protocol ParentChildProtocol {}
```

이는 Swift 5.10 이전까지 Protocol을 사용하던 방식이었습니다. 그러나 Swift 5.10부터는 중첩 프로토콜을 사용할 수 있게 되었습니다. [SE-0404 Allow Protocols to be Nested in Non-Generic Contexts](https://github.com/apple/swift-evolution/blob/main/proposals/0404-nested-protocols.md) 덕분입니다.

이제 Struct, Class, Enum과 같이 Protocol도 타입 내부에서 정의할 수 있게 되었습니다. 중첩 프로토콜을 사용하면 타입의 구조를 더욱 조직화하고 캡슐화할 수 있습니다.

```swift
// FileName : RootInterface.swift
enum Root {}

extension Root {
    protocol Serviceable {
        func doSomething()
    }

    protocol Interactable {
        var service: Serviceable { get }
        func doSomething()
    }
}

// FileName : RootImplement.swift
extension Root {
    struct Service: Serviceable {
        func doSomething() {
            print("Service did something")
        }
    }

    struct Interactor: Interactable {
        let service: any Serviceable
        init(service: some Serviceable) {
            self.service = service
        }

        func doSomething() {
            service.doSomething()
        }
    }
}

// 중첩 프로토콜과 구현 타입을 사용하는 예시
let service = Root.Service()
let interactor = Root.Interactor(service: service)
interactor.doSomething() // "Service did something" 출력
```

## RIBs

RIBs 아키텍처는 Router, Interactor, Builder, Presenter 등으로 구성됩니다. 각 구성 요소는 Protocol로 추상화합니다.

```swift
/// FileName : LoggedInBuilder.swift
protocol LoggedInDependency: Dependency {}
protocol LoggedInBuildable: Buildable {
    func build(withListener listener: LoggedInListener) -> LoggedInRouting
}

/// FileName : LoggedInteractor.swift
protocol LoggedInRouting: ViewableRouting {}
protocol LoggedInPresentable: Presentable {
    var listener: LoggedInPresentableListener? { get set }
}
protocol LoggedInListener: AnyObject {}

/// FileName : LoggedRouter.swift
protocol LoggedInInteractable: Interactable {
    var router: LoggedInRouting? { get set }
    var listener: LoggedInListener? { get set }
}
protocol LoggedInViewControllable: ViewControllable {}

/// FileName : LoggedViewController.swift
protocol LoggedInPresentableListener {}
```

중첩 프로토콜이 도입되기 전에는 위와 같이 Protocol 이름이 길어질 수밖에 없었습니다. 하지만, 중첩 프로토콜을 사용한다면 네임스페이스 역할을 해주는 타입 아래에 코드를 조직화할 수 있게 되었습니다.

다음은 LoggedInRIB에 중첩 프로토콜을 적용한 코드입니다.

```swift
/// FileName: LoggedIn.swift
enum LoggedIn {}

/// FileName: LoggedIn+Builder.swift
extension LoggedIn {
    protocol Dependency: RIBs.Dependency {}

    protocol Buildable: RIBs.Buildable {
        func build(withListener listener: Listener) -> RIBs.Routing
    }
}

extension LoggedIn {
    final class Component: RIBs.Component<Dependency> {}

    final class Builder: RIBs.Builder<Dependency>, Buildable {
        override init(dependency: Dependency) {
            super.init(dependency: dependency)
        }

        func build(withListener listener: Listener) -> RIBs.Routing {
            let component = Component(dependency: dependency)
            let viewController = ViewController()
            let interactor = Interactor(presenter: viewController)
            interactor.listener = listener
            return Router(interactor: interactor, viewController: viewController)
        }
    }
}

/// FileName: LoggedIn+Interactor.swift
extension LoggedIn {
    protocol Routing: RIBs.ViewableRouting {}
    protocol Presentable: RIBs.Presentable {
        var listener: PresentableListener? { get set }
    }

    protocol Listener: AnyObject {}
}

extension LoggedIn {
    final class Interactor: PresentableInteractor<Presentable>, Interactable, PresentableListener {
        weak var router: Routing?
        weak var listener: Listener?
        // TODO: Add additional dependencies to constructor. Do not perform any logic
        // in constructor.
        override init(presenter: Presentable) {
            super.init(presenter: presenter)
            presenter.listener = self
        }

        override func didBecomeActive() {
            super.didBecomeActive()
            // TODO: Implement business logic here.
        }

        override func willResignActive() {
            super.willResignActive()
            // TODO: Pause any business logic.
        }
    }
}

/// FileName : LoggedIn+Router.swift
extension LoggedIn {
    protocol Interactable: RIBs.Interactable {
        var router: Routing? { get set }
        var listener: Listener? { get set }
    }

    protocol ViewControllable: RIBs.ViewControllable {}
}

extension LoggedIn {
    final class Router: ViewableRouter<Interactable, ViewControllable>, Routing {
        // TODO: Constructor inject child builder protocols to allow building children.
        override init(interactor: Interactable, viewController: ViewControllable) {
            super.init(interactor: interactor, viewController: viewController)
            interactor.router = self
        }
    }
}

/// FileName : LoggedIn+ViewController.swift
extension LoggedIn {
    protocol PresentableListener: AnyObject {}
}

extension LoggedIn {
    final class ViewController: UIViewController, Presentable, ViewControllable {
        weak var listener: PresentableListener?
    }
}
```

## 정리

* Swift 5.10 이전에는 프로토콜은 네임스페이스 기능을 제공하지 못했으나, Swift 5.10 이후부터는 중첩 프로토콜을 지원하여 코드를 더욱 구조화 및 캡슐화할 수 있게 되었습니다.

## 참고자료

* Apple
  * [SE-0404: Nested Protocols](https://github.com/apple/swift-evolution/blob/main/proposals/0404-nested-protocols.md)
  * [Swift Forum - Pitch: Allow Protocols to be Nested in Non-Generic Contexts](https://forums.swift.org/t/pitch-allow-protocols-to-be-nested-in-non-generic-contexts/65285)
* [[iOS - swift] nested protocol 개념 (#Swift 5.10)](https://ios-development.tistory.com/1623)

---
layout: post
title: "[Swift 5.7+] Dependency Injection (1) - PropertyWrapper를 이용한 Service Locator 구현하기"
tags: [Swift, Dependency Injection, PropertyWrapper, Service Locator, Container, resultBuilder, DI, IoC, Circular Dependency, Protocol, Generics]
---
{% include JB/setup %}

서비스 로케이터는 객체를 로케이터에 등록하고, 해당 객체가 필요한 곳에서는 로케이터에 접근하여 객체를 제공받는 방식입니다.

서비스 로케이터는 객체를 컨테이너에 저장하고, 필요한 시점에 컨테이너에서 해당 객체를 꺼내어 사용하는 방식입니다. 이를 위해, 이전에는 직접 컨테이너에서 객체를 꺼내는 코드를 작성하거나, 이를 위한 클래스를 만들어 사용했었습니다.

Swift 5.1에서 도입된 PropertyWrapper를 사용하면, 직접 코드를 작성하지 않고도 컨테이너에서 객체를 꺼내와 사용할 수 있습니다. 이를 이용하여, 스프링이나 안드로이드의 Koin, Hilt와 비슷한 방식으로 코드를 작성하고 동작시킬 수 있습니다.

Swift 5.1에서 도입된 [PropertyWrapper](https://github.com/apple/swift-evolution/blob/main/proposals/0258-property-wrappers.md)를 사용하면,직접 코드를 작성하지 않고도 컨테이너에서 객체를 꺼내와 사용할 수 있습니다.

 이를 이용하여, 스프링이나 안드로이드의 Koin, Hilt와 비슷한 방식으로 코드를 작성하고 동작시킬 수 있습니다.

## 특정 프로토콜만 등록할 수 있는 서비스 로케이터

먼저, Injectable 프로토콜을 따르는 타입의 객체만 서비스 로케이터에 등록할 수 있다고 가정해봅시다.

```swift
/// Module : Container
/// FileName : Module.swift
public protocol Injectable {}

public struct Module {
    let name: String
    let resolve: () -> Injectable

    public init(_ name: Any.Type, _ resolve: @escaping () -> Injectable) {
        self.name = String(describing: name)
        self.resolve = resolve
    }
}
```

이전에 만든 모듈을 관리하는 컨테이너를 만들어봅시다.

```swift
/// Module : Container
/// FileName : Container.swift

/// A dependency collection that provides resolutions for object instances.
public class Container {
    /// Composition root container.
    static var root = Container()

    /// Stored object instance factories.
    private var modules: [String: Module] = [:]
    
    public init() {}
    deinit { modules.removeAll() }
}

extension Container {
    /// Registers a specific type and its instantiating factory.
    func add(module: Module) {
        modules[module.name] = module
    }
}

public extension Container {
    /// Resolves through inference and returns an instance of the given type from the current default container.
    ///
    /// If the dependency is not found, an exception will occur.
    static func resolve<T>(for name: String? = nil) -> T {
        let name = name ?? String(describing: T.self)
        
        guard let component: T = root.modules[name]?.resolve() as? T else {
            fatalError("Container '\(T.self)' not resolved!")
        }
        
        return component
    }
    
    /// Construct dependency resolutions.
    convenience init(@ModuleBuilder _ modules: () -> [Module]) {
        self.init()
        modules().forEach { add(module: $0) }
    }
    
    /// Construct dependency resolution.
    convenience init(@ModuleBuilder _ module: () -> Module) {
        self.init()
        add(module: module())
    }
    
    /// Assigns the current container to the composition root.
    func build() {
        // Used later in property wrapper
        Self.root = self
    }
    
    /// DSL for declaring modules within the container dependency initializer.
    @resultBuilder  struct ModuleBuilder {
        public static func buildBlock(_ modules: Module...) -> [Module] { modules }
        public static func buildBlock(_ module: Module) -> Module { module }
        public static func buildEither(first component: Module) -> Module { component }
    }
}
```

위 컨테이너를 사용하면, 쉽게 객체를 등록할 수 있습니다.

```swift
protocol Service {
    func doSomething()
}

struct ServiceImpl: Service, Injectable {
    func doSomething() {
        print("Doing something...")
    }
}

let container = Container {
    Module(Service.self) { ServiceImpl() }
}
container.build()

let service: Service = Container.resolve()
service.doSomething()
// Output: Doing something...
```

여기에 PropertyWrapper를 활용하면, `Container.resolve()`를 직접 호출하지 않아도 객체를 얻을 수 있습니다.

```swift
/// Module : Container
/// FileName : Inject.swift

@propertyWrapper
public class Inject<Value> {
    private var storage: Value?

    public var wrappedValue: Value {
        storage ?? {
            let value: Value = Container.resolve()
            storage = value // Reuse instance for later
            return value
        }()
    }

    public init() {}
}
```

`Inject`라는 PropertyWrapper를 사용하면, 객체를 얻을 수 있습니다.

```swift
@Inject 
var service: Service
service.doSomething()
// Output: Doing something...
```

하지만 `Inject`는 제약이 없기 때문에 어떤 타입이라도 사용할 수 있습니다. 따라서 컨테이너에 등록되어 있지 않은 타입을 `Inject`하면 에러가 발생합니다.

```swift
protocol AAAA {
    func doSomething()
}

@Inject 
var service: AAAA
service.doSomething()
// Error : Fatal error: Container 'AAAA' not resolved!
```

`Inject`를 사용할 때는 제약을 주어 의도한 대로 동작하도록 만들 수 있습니다. `Inject`의 제네릭 타입 `Value`에 `Injectable` 프로토콜을 준수하도록 제한하면, `Injectable`을 준수하지 않는 타입은 사용할 수 없습니다.

```swift
/// Module : Container
/// FileName : Inject.swift

@propertyWrapper
public class Inject<Value: Injectable> {
    private var storage: Value?

    public var wrappedValue: Value {
        storage ?? {
            let value: Value = Container.resolve()
            storage = value // Reuse instance for later
            return value
        }()
    }

    public init() {}
}
```

하지만 `Injectable`을 준수하는 구현 타입이 필요하기 때문에, 추상화를 할 수는 없습니다.

```swift
@Inject 
var service: Service
service.doSomething()
// Error : Type 'any Service' cannot conform to 'Injectable'
```

따라서 `Service` 대신 `ServiceImpl`을 사용해야 합니다.

```swift
let container = Container {
    Module(ServiceImpl.self) { ServiceImpl() }
}
container.build()

@Inject 
var service: ServiceImpl
service.doSomething()
// Output: Doing something...
```

혹은 Adapter를 만들어 사용할 수 있습니다.

```swift
struct ServiceAdapter: Injectable {
    let service: Service
    init(service: Service) {
        self.service = service
    }
    func doSomething() {
        service.doSomething()
    }
}

let container = Container {
    Module(ServiceAdapter.self) { ServiceAdapter(service: ServiceImpl()) }
}
container.build()

@Inject 
var service: ServiceAdapter
service.doSomething()
// Output: Doing something...
```

## 프로토콜, 키를 한 쌍으로 사용하는 서비스 로케이터

앞에서는 컨테이너에 등록된 객체를 얻어오는 방법을 설명했습니다. 하지만, 제약을 두면 구현 타입을 사용할 수밖에 없는 한계가 있습니다. 이를 해결하는 방법에 대해서 설명하려고 합니다.

```swift
/// Module : Container
/// FileName : InjectionKey.swift

public protocol InjectionKey {
    associatedtype Value
    static var currentValue: Self.Value { get }
}
```

키에 사용할 프로토콜을 정의했습니다. `InjectionKey`에서 정의된 `associatedtype`은 키에 사용할 타입을 정의합니다. 그리고 `currentValue`는 자기 자신을 키로 컨테이너에서 객체를 꺼내도록 할 것입니다.

그리고 Module 코드는 `InjectionKey`를 이름으로 하는 코드로 변경됩니다.

```swift
/// Module : Container
/// FileName : Module.swift
public protocol Injectable {}

public struct Module {
    let name: String
    let resolve: () -> Injectable

    public init<T: InjectionKey>(_ name: T.Type, _ resolve: @escaping () -> Injectable) {
        self.name = String(describing: name)
        self.resolve = resolve
    }
}
```

다음으로, Property Wrapper인 Inject는 initialize에서 키를 인자로 받도록 합니다.

다음으로, Property Wrapper인 `Inject`는 `initialize`에서 키를 인자로 받도록 합니다.

```swift
@propertyWrapper
public class Inject<Value> {
    private let lazyValue: (() -> Value)
    private var storage: Value?

    public var wrappedValue: Value {
        storage ?? {
            let value: Value = lazyValue()
            storage = value // Reuse instance for later
            return value
        }()
    }

    public init<K>(_ key: K.Type) where K : InjectionKey, Value == K.Value {
        lazyValue = {
            key.currentValue
        }
    }
}
```

`Inject`를 사용할 때는, 해당 프로퍼티 래퍼를 선언하는 타입이 `InjectionKey` 프로토콜을 준수하는 타입으로 지정되어야 하며, 해당 키 타입에 정의된 `Value`와 동일한 타입을 지정해야 합니다. 앞에서 정의한 `Service`에서 `ServiceKey`를 추가하고, 해당 키 타입에서 `Value` 프로퍼티에 해당하는 값이 해당 타입과 일치하도록 합니다.

```swift
struct ServiceKey: InjectionKey {
    typealias Value = Service
    static var currentValue: Value { Container.resolve(for: Self.self) }
}

protocol Service {
    func doSomething()
}

struct ServiceImpl: Service, Injectable {
    func doSomething() {
        print("Doing something...")
    }
}
```

이제 `ServiceKey`와 `ServiceImpl`을 컨테이너에 등록하고, 사용하는 것을 확인해봅시다.

```swift
let container = Container {
    Module(ServiceKey.self) { ServiceImpl() }
}
container.build()

@Inject(ServiceKey.self)
var service: Service
service.doSomething()
// Output: Doing something...
```

만약 `ServiceKey`에서 정의된 타입과 다른 타입을 사용하면 에러가 발생합니다.

```swift
@Inject(ServiceKey.self) // Error : Type of expression is ambiguous without more context
var service: AAAA
service.doSomething()
```

따라서 `Inject`를 사용할 때에는 키와 프로토콜은 쌍으로 사용하여, 실수할 가능성이 줄어들게 됩니다.

또한, `InjectionKey` 프로토콜에서 정의된 `currentValue`의 코드를 계속 구현하려면 꽤 많은 코드를 작성해야 합니다. 그러나 extension을 활용하여 `currentValue`를 구현하면 코드의 양을 줄일 수 있습니다.

```swift
public extension InjectionKey {
    static var currentValue: Value {
        return Container.resolve(for: Self.self)
    }
}

struct ServiceKey: InjectionKey {
    typealias Value = Service
}
```

## 정리

`PropertyWrapper`를 활용하면 컨테이너에서 객체를 쉽게 가져와 사용할 수 있습니다.

다음은 전체코드입니다.<br/><br/>

```swift
/// Module : DIContainer
/// FileName : Module.swift
public protocol Injectable {}

public protocol InjectionKey {
    associatedtype Value
    static var currentValue: Self.Value { get }
}

public extension InjectionKey {
    static var currentValue: Value {
        return Container.resolve(for: Self.self)
    }
}

/// A type that contributes to the object graph.
public struct Module {
    let name: String
    let resolve: () -> Injectable

    public init<T: InjectionKey>(_ name: T.Type, _ resolve: @escaping () -> Injectable) {
        self.name = String(describing: name)
        self.resolve = resolve
    }
}
```

```swift
/// Module : DIContainer
/// FileName : Container.swift

/// A dependency collection that provides resolutions for object instances.
public class Container {
    /// Composition root container.
    static var root = Container()

    /// Stored object instance factories.
    private var modules: [String: Module] = [:]
    
    public init() {}
    deinit { modules.removeAll() }
}

extension Container {
    /// Registers a specific type and its instantiating factory.
    func add(module: Module) {
        modules[module.name] = module
    }

    /// Resolves through inference and returns an instance of the given type from the current default container.
    ///
    /// If the dependency is not found, an exception will occur.
    static func resolve<T>(for type: Any.Type?) -> T {
        let name = type.map { String(describing: $0) } ?? String(describing: T.self)
        
        guard let component: T = root.modules[name]?.resolve() as? T else {
            fatalError("Dependency '\(T.self)' not resolved!")
        }
        
        return component
    }
}

public extension Container {
    /// Construct dependency resolutions.
    convenience init(@ModuleBuilder _ modules: () -> [Module]) {
        self.init()
        modules().forEach { add(module: $0) }
    }
    
    /// Construct dependency resolution.
    convenience init(@ModuleBuilder _ module: () -> Module) {
        self.init()
        add(module: module())
    }
    
    /// Assigns the current container to the composition root.
    func build() {
        // Used later in property wrapper
        Self.root = self
    }
    
    /// DSL for declaring modules within the container dependency initializer.
    @resultBuilder  struct ModuleBuilder {
        public static func buildBlock(_ modules: Module...) -> [Module] { modules }
        public static func buildBlock(_ module: Module) -> Module { module }
        public static func buildEither(first component: Module) -> Module { component }
    }
}
```

```swift
/// Module : DIContainer
/// FileName : Inject.swift
@propertyWrapper
public class Inject<Value> {
    private let lazyValue: (() -> Value)
    private var storage: Value?

    public var wrappedValue: Value {
        storage ?? {
            let value: Value = lazyValue()
            storage = value // Reuse instance for later
            return value
        }()
    }

    public init<K>(_ key: K.Type) where K : InjectionKey, Value == K.Value {
        lazyValue = {
            key.currentValue
        }
    }
}
```

```swift
/// Module : Application
/// FileName : Service.swift

import DIContainer

struct ServiceKey: InjectionKey {
    typealias Value = Service
}

protocol Service {
    func doSomething()
}

struct ServiceImpl: Service, Injectable {
    func doSomething() {
        print("Doing something...")
    }
}
```

```swift
/// Module : Application
/// FileName : Application.swift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        ...

        let container = Container {
            Component(ServiceKey.self) { ServiceImpl() }
        }
        container.build()

        ...

        @Inject(ServiceKey.self)
        var service: Service
        
        service.doSomething()
    }
}
```

## 참고자료

* [Dependency Injection in Swift using latest Swift features](https://www.avanderlee.com/swift/dependency-injection/)
* [iOS Dependency Injection Using Swinject](https://ali-akhtar.medium.com/ios-dependency-injection-using-swinject-9c4ceff99e41)
* [Dependency Injection via Property Wrappers](https://www.kiloloco.com/articles/004-dependency-injection-via-property-wrappers/)
* [DI 라이브러리 “Koin” 은 DI가 맞을까?](https://dev-kimji1.medium.com/di-%EB%9D%BC%EC%9D%B4%EB%B8%8C%EB%9F%AC%EB%A6%AC-koin-%EC%9D%80-di%EA%B0%80-%EB%A7%9E%EC%9D%84%EA%B9%8C-66f974fead4f)
* [SwiftLee 방식의 DI를 하는 것으로 TCA의 Environment 버킷 릴레이를 그만두고 싶은 이야기](https://zenn.dev/yimajo/articles/e9f72549270873)
* [Swift Dependency Injection via Property Wrapper](https://zamzam.io/swift-dependency-injection-via-property-wrapper/)
* [뱅크샐러드 안드로이드 앱에서 Koin 걷어내고 Hilt로 마이그레이션하기](https://blog.banksalad.com/tech/migrate-from-koin-to-hilt/)
* [마틴 파울러 - Inversion of Control Containers and the Dependency Injection pattern](https://martinfowler.com/articles/injection.html)
  * [번역글](https://edykim.com/ko/post/the-service-locator-is-an-antipattern/)

## 다음 편

다음 편에서는 서비스 로케이터를 사용했을 때 로케이터에 등록되어 있는지 어떻게 보장할 것인지 알아보도록 하겠습니다.
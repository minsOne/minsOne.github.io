---
layout: post
title: "[Swift 5.7+] Dependency Injection (2) - 컨테이너 무결성 보장해 보기"
tags: [Swift, Dependency Injection, PropertyWrapper, Service Locator, Container, resultBuilder, DI, IoC, Circular Dependency, Protocol, Generics, nm, mangle, demangle]
---
{% include JB/setup %}

이전 글에서 컨테이너에 객체를 저장하고, 사용할 때 저장했던 객체를 꺼내어 사용하는 방법을 기술하였습니다.

이번 글에서 컨테이너에 저장했던 객체가 잘 있는지 무결성을 어떻게 보장해 볼 수 있을지 고민하는 글입니다.

관련 소스는 [여기](https://github.com/minsOne/Experiment-Repo/tree/master/20220806-DemoAppSample)에서 확인할 수 있습니다.

## 프로젝트 구조

이 프로젝트는 다음과 같은 의존성 그래프를 가질 것입니다.

<div class="mermaid" style="display:flex;justify-content:center;"> 
graph TD;
    id1[Application]-->id2([Features]);
    id2-->id3[FeatureDeposit];
    id4[FeatureAuth]-->id5[FeatureAuthInterface];
    id2-->id4;
    id3-->id5;
    id3-->id6[DIContainer];
    id5-->id6;

    style id1 fill:#03bfff
    style id2 fill:#ffba0c
    style id3 fill:#ff7357
    style id4 fill:#ff7357
    style id5 fill:#ff7357
    style id6 fill:#ff7357
</div>

`FeatureAuthInterface` 모듈은 `AuthServiceKey`와 `AuthServiceInterface`를 가집니다.

```swift
/// ModuleName : FeatureAuthInterface
/// FileName : AuthServiceInterface.swift
import Foundation

public struct AuthResult {
    public let value: Int

    public init(value: Int) {
        self.value = value
    }
}

public protocol AuthServiceInterface {
    func auth() -> AuthResult
}

/// ModuleName : FeatureAuthInterface
/// FileName : AuthServiceKey.swift
import Foundation
import DIContainer

public struct AuthServiceKey: InjectionKey {
    public typealias Value = AuthServiceInterface
}
```

그리고 `FeatureAuth` 모듈은 `AuthServiceInterface` 프로토콜을 구현한 `AuthService`를 가집니다.

```swift
/// ModuleName : FeatureAuth
/// FileName : AuthServiceKey.swift
import FeatureAuthInterface
import DIContainer

public struct AuthService: AuthServiceInterface, Injectable {
    public init() {}

    public func auth() -> AuthResult {
        return AuthResult(value: 10)
    }
}
```

`FeatureDeposit` 모듈은 `FeatureAuthInterface` 모듈을 의존하여, `AuthServiceInterface`를 의존성 주입받아 auth를 호출하는 `DepositService`를 가집니다.

```swift
/// ModuleName : FeatureDeposit
/// FileName : DepositService.swift
import FeatureAuthInterface

public protocol DepositServiceProtocol {
    func run()
}

public struct DepositService: DepositServiceProtocol {
    let authService: AuthServiceInterface

    public init(authService: AuthServiceInterface) {
        self.authService = authService
    }

    public func run() {
        let result = authService.auth()
        print("Auth Result : \(result.value)")
    }
}

/// ModuleName : FeatureDeposit
/// FileName : DepositBuilder.swift
import Foundation
import FeatureAuthInterface
import DIContainer

public protocol DepositBuildable {
    func build() -> DepositServiceProtocol
}

public struct DepositBuilder: DepositBuildable {
    @Inject(AuthServiceKey.self)
    var authService: AuthServiceInterface
    
    public init() {}

    public func build() -> DepositServiceProtocol {
        DepositService(authService: authService)
    }
}
```

이제 `Application` 프로젝트의 `AppDelegate`에서 컨테이너에 `AuthServiceKey`를 키로 하여 `AuthService` 객체를 생성하는 클로저를 주입합니다.

```swift
/// ModuleName : Application
/// FileName : AppDelegate.swift

...
func register() {
    let container = Container {
        Component(AuthServiceKey.self) { AuthService() }
    }
    container.build()
}
```

이 프로젝트를 빌드하여 결과물을 확인합니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2022/08/20220806_01.png" style="width: 800px"/>
</p><br/>

## 바이너리 심볼 분석하기

Swift를 사용하는 소스에서는 정상적인 방법으로는 현재 의존하는 모듈의 목록 및 모듈 분석하는 것이 불가능합니다. 그래서 애플리케이션으로 빌드 한 결과물에서 실행 바이너리, 프레임워크의 바이너리의 심볼을 읽어 분석할 수 있지 않을까 합니다.

`nm`을 사용하여 라이브러리의 심볼 테이블을 확인합니다.

```bash
$ nm Frameworks/Features.framework/Features

0000000000007344 S _$s11DIContainer10InjectableMp
0000000000007ab4 s _$s11DIContainer10Injectable_pMF
000000000000c268 d _$s11DIContainer10Injectable_pSgMD
0000000000007370 S _$s11DIContainer12InjectionKeyMp
0000000000004208 T _$s11DIContainer12InjectionKeyPAAE12currentValue0E0QzvgZ
0000000000007380 S _$s11DIContainer12InjectionKeyTL
0000000000007ac4 s _$s11DIContainer12InjectionKey_pMF
00000000000038e8 T _$s11DIContainer6InjectC12wrappedValuexvg
0000000000007328 S _$s11DIContainer6InjectC12wrappedValuexvgTq
0000000000003ae4 t _$s11DIContainer6InjectC12wrappedValuexvgxyKXEfu_xyXEfU_
0000000000007298 S _$s11DIContainer6InjectC12wrappedValuexvpMV
0000000000003864 T _$s11DIContainer6InjectC7storage33_010E4EA1AD04315E8A85F0D18585835FLLxSgvM
00000000000038ac t _$s11DIContainer6InjectC7storage33_010E4EA1AD04315E8A85F0D18585835FLLxSgvM.resu
...
```

심볼은 우리가 알아보기 어렵기 때문에, `demangle` 하여 알아볼 수 있도록 해야 합니다.

```bash
$ nm Frameworks/Features.framework/Features \
| awk '{print $3}' \
| xcrun swift-demangle

protocol descriptor for DIContainer.Injectable
reflection metadata field descriptor DIContainer.Injectable
demangling cache variable for type metadata for DIContainer.Injectable?
protocol descriptor for DIContainer.InjectionKey
static (extension in DIContainer):DIContainer.InjectionKey.currentValue.getter : A.Value
protocol requirements base descriptor for DIContainer.InjectionKey
reflection metadata field descriptor DIContainer.InjectionKey
DIContainer.Inject.wrappedValue.getter : A
method descriptor for DIContainer.Inject.wrappedValue.getter : A
closure #1 () -> A in implicit closure #1 () throws -> A in DIContainer.Inject.wrappedValue.getter : A
property descriptor for DIContainer.Inject.wrappedValue : A
DIContainer.Inject.(storage in _010E4EA1AD04315E8A85F0D18585835F).modify : A?
DIContainer.Inject.(storage in _010E4EA1AD04315E8A85F0D18585835F).modify : A? with unmangled suffix ".resume.0"
method descriptor for DIContainer.Inject.(storage in _010E4EA1AD04315E8A85F0D18585835F).modify : A?
...
```

이제는 어느 정도 알아볼 수 있는 코드로 변경되었습니다. `DIContainer` 모듈의 `InjectionKey` 프로토콜을 준수하는 타입을 찾을 수 있습니다. 

심볼 테이블에서 `DIContainer.InjectionKey`를 찾아봅니다.

```bash
$ nm Frameworks/Features.framework/Features \
| awk '{print $3}' \
| xcrun swift-demangle \
| grep 'DIContainer.InjectionKey'

protocol descriptor for DIContainer.InjectionKey
static (extension in DIContainer):DIContainer.InjectionKey.currentValue.getter : A.Value
protocol requirements base descriptor for DIContainer.InjectionKey
reflection metadata field descriptor DIContainer.InjectionKey
DIContainer.Inject.__allocating_init<A where A == A1.Value, A1: DIContainer.InjectionKey>(A1.Type) -> DIContainer.Inject<A>
method descriptor for DIContainer.Inject.__allocating_init<A where A == A1.Value, A1: DIContainer.InjectionKey>(A1.Type) -> DIContainer.Inject<A>
DIContainer.Inject.init<A where A == A1.Value, A1: DIContainer.InjectionKey>(A1.Type) -> DIContainer.Inject<A>
closure #1 () -> A in DIContainer.Inject.init<A where A == A1.Value, A1: DIContainer.InjectionKey>(A1.Type) -> DIContainer.Inject<A>
partial apply forwarder for closure #1 () -> A in DIContainer.Inject.init<A where A == A1.Value, A1: DIContainer.InjectionKey>(A1.Type) -> DIContainer.Inject<A>
DIContainer.Component.init<A where A: DIContainer.InjectionKey>(A.Type, () -> DIContainer.Injectable) -> DIContainer.Component
reflection metadata associated type descriptor FeatureAuthInterface.AuthServiceKey : DIContainer.InjectionKey in FeatureAuthInterface
protocol conformance descriptor for FeatureAuthInterface.AuthServiceKey : DIContainer.InjectionKey in FeatureAuthInterface
protocol witness table for FeatureAuthInterface.AuthServiceKey : DIContainer.InjectionKey in FeatureAuthInterface
protocol witness for static DIContainer.InjectionKey.currentValue.getter : A.Value in conformance FeatureAuthInterface.AuthServiceKey : DIContainer.InjectionKey in FeatureAuthInterface
associated type descriptor for DIContainer.InjectionKey.Value
```

`protocol conformance descriptor for FeatureAuthInterface.AuthServiceKey : DIContainer.InjectionKey in FeatureAuthInterface`에서 `FeatureAuthInterface` 모듈 내에서 `FeatureAuthInterface.AuthServiceKey`이 `DIContainer.InjectionKey` 프로토콜을 준수한다는 것을 확인할 수 있습니다.

즉, `FeatureAuthInterface` 모듈에서 컨테이너에 사용할 키를 얻을 수 있음을 의미합니다.

쉘 스크립트 코드를 좀 더 정리해서 키 목록만 뽑아봅시다.

```bash
$ nm Frameworks/Features.framework/Features \
| awk '{print $3}' \
| xcrun swift-demangle \
| grep 'DIContainer.InjectionKey' \
| grep "protocol conformance descriptor for " \
| sed -E "s/protocol conformance descriptor for (.*) : (.*) in .*/\1/g"

FeatureAuthInterface.AuthServiceKey
```

## 테스트 코드 작성

앞에서 `DIContainer` 모듈의 `InjectionKey` 프로토콜을 준수하는 키 목록을 추출할 수 있었습니다. 그러면 추출한 키 목록을 토대로 테스트 코드를 작성해 봅시다.

```swift
@testable import DIContainer
import XCTest
import FeatureAuthInterface

final class FeaturesTests: XCTestCase {
    func test_has_registered_container() {
        XCTAssertNotNil(AuthServiceKey.module?.resolve() as? AuthServiceKey.Value)
    }
}

extension InjectionKey {
    static var module: Component? {
        return Container.root.modules[String(describing: Self.self)]
    }
}
```

`AppDelegate`에서 `didFinishLaunchingWithOptions` 함수가 호출된 뒤 테스트 코드가 동작합니다. 따라서 컨테이너에 키가 등록되어 있음을 가정하고 테스트를 할 수 있습니다. 

이렇게 테스트 코드를 작성하는 스크립트를 만든다면, 매번 또는 주기적으로 테스트 코드를 이용하여 컨테이너에 등록되어 있는지 검증할 수 있습니다. 키를 사용할 때, 잘 등록되어 있는지를 테스트 코드로 보장이 되므로 안심하고 사용할 수 있습니다.

## 컨테이너 등록 코드 작성

테스트 코드 자동화로는 사실 부족합니다. 컨테이너에 등록하는 코드를 작성하는 자동화까지 필요합니다. 그래야 안심하고 사용을 할 수 있을 것이라고 생각됩니다.

앞에서 `DIContainer` 모듈의 `InjectionKey` 프로토콜을 준수하는 키 `FeatureAuthInterface` 모듈의 `AuthServiceKey`를 추출할 수 있었습니다. `AuthServiceKey`에서 `associatedtype`으로 가지는 타입을 찾아야 합니다.

타입을 찾는 방법은 여러 가지가 있지만, 심볼 테이블을 분석해 봅시다.

```bash
$ nm Frameworks/Features.framework/Features \
| awk '{print $3}' \
| xcrun swift-demangle \
| grep "FeatureAuthInterface.AuthServiceKey"

reflection metadata associated type descriptor FeatureAuthInterface.AuthServiceKey : DIContainer.InjectionKey in FeatureAuthInterface
protocol conformance descriptor for FeatureAuthInterface.AuthServiceKey : DIContainer.InjectionKey in FeatureAuthInterface
protocol witness table for FeatureAuthInterface.AuthServiceKey : DIContainer.InjectionKey in FeatureAuthInterface
protocol witness for static DIContainer.InjectionKey.currentValue.getter : A.Value in conformance FeatureAuthInterface.AuthServiceKey : DIContainer.InjectionKey in FeatureAuthInterface
FeatureAuthInterface.AuthServiceKey.init() -> FeatureAuthInterface.AuthServiceKey
reflection metadata field descriptor FeatureAuthInterface.AuthServiceKey
type metadata accessor for FeatureAuthInterface.AuthServiceKey
full type metadata for FeatureAuthInterface.AuthServiceKey
nominal type descriptor for FeatureAuthInterface.AuthServiceKey
type metadata for FeatureAuthInterface.AuthServiceKey
```

`AuthServiceKey`의 `associatedtype`으로 가지는 타입을 유추할 수 있는 코드를 찾지 못하였습니다. 우리는 코드를 확인하면 바로 `AuthServiceKey`의 `associatedtype`은 `AuthServiceInterface`라는 것을 확인할 수 있지만, 심볼 테이블에서는 찾지 못했습니다. 심볼 테이블에서 `AuthServiceInterface`를 찾을 수 있는 방법으로 코드를 수정해 봅시다.

```swift
/// Module : DIContainer
/// FileName : Module.swift

// MARK: - Before
public protocol InjectionKey {
    associatedtype Value
    static var currentValue: Self.Value { get }
}

// MARK: - After
public protocol InjectionKey {
    associatedtype Value
    var type: Value? { get }
    static var currentValue: Self.Value { get }
}
```

InjetionKey 프로토콜에 Value 타입을 가지는 `type` 변수를 정의합니다. 그러면 AuthServiceKey 코드는 다음과 같이 수정해야 합니다.

```swift
/// ModuleName : FeatureAuthInterface
/// FileName : AuthServiceKey.swift

// MARK: - Before
public struct AuthServiceKey: InjectionKey {
    public typealias Value = AuthServiceInterface
}

// MARK: - After
public struct AuthServiceKey: InjectionKey {
    public var type: AuthServiceInterface?
}
```

코드 수정 후, 다시 애플리케이션을 빌드하고, Features 라이브러리의 심볼 테이블을 확인해 봅시다.

```bash
$ nm Frameworks/Features.framework/Features \
| awk '{print $3}' \
| xcrun swift-demangle \
| grep "FeatureAuthInterface.AuthServiceKey"

reflection metadata associated type descriptor FeatureAuthInterface.AuthServiceKey : DIContainer.InjectionKey in FeatureAuthInterface
protocol conformance descriptor for FeatureAuthInterface.AuthServiceKey : DIContainer.InjectionKey in FeatureAuthInterface
protocol witness table for FeatureAuthInterface.AuthServiceKey : DIContainer.InjectionKey in FeatureAuthInterface
protocol witness for static DIContainer.InjectionKey.currentValue.getter : A.Value in conformance FeatureAuthInterface.AuthServiceKey : DIContainer.InjectionKey in FeatureAuthInterface
protocol witness for DIContainer.InjectionKey.type.getter : A.Value? in conformance FeatureAuthInterface.AuthServiceKey : DIContainer.InjectionKey in FeatureAuthInterface
FeatureAuthInterface.AuthServiceKey.type.modify : FeatureAuthInterface.AuthServiceInterface?
FeatureAuthInterface.AuthServiceKey.type.modify : FeatureAuthInterface.AuthServiceInterface? with unmangled suffix ".resume.0"
FeatureAuthInterface.AuthServiceKey.type.getter : FeatureAuthInterface.AuthServiceInterface?
property descriptor for FeatureAuthInterface.AuthServiceKey.type : FeatureAuthInterface.AuthServiceInterface?
variable initialization expression of FeatureAuthInterface.AuthServiceKey.type : FeatureAuthInterface.AuthServiceInterface?
FeatureAuthInterface.AuthServiceKey.type.setter : FeatureAuthInterface.AuthServiceInterface?
FeatureAuthInterface.AuthServiceKey.init(type: FeatureAuthInterface.AuthServiceInterface?) -> FeatureAuthInterface.AuthServiceKey
FeatureAuthInterface.AuthServiceKey.init() -> FeatureAuthInterface.AuthServiceKey
reflection metadata field descriptor FeatureAuthInterface.AuthServiceKey
type metadata accessor for FeatureAuthInterface.AuthServiceKey
full type metadata for FeatureAuthInterface.AuthServiceKey
nominal type descriptor for FeatureAuthInterface.AuthServiceKey
type metadata for FeatureAuthInterface.AuthServiceKey
value witness table for FeatureAuthInterface.AuthServiceKey
initializeBufferWithCopyOfBuffer value witness for FeatureAuthInterface.AuthServiceKey
assignWithCopy value witness for FeatureAuthInterface.AuthServiceKey
initializeWithCopy value witness for FeatureAuthInterface.AuthServiceKey
getEnumTagSinglePayload value witness for FeatureAuthInterface.AuthServiceKey
storeEnumTagSinglePayload value witness for FeatureAuthInterface.AuthServiceKey
assignWithTake value witness for FeatureAuthInterface.AuthServiceKey
destroy value witness for FeatureAuthInterface.AuthServiceKey
```

아까는 보지 못했던 `FeatureAuthInterface` 모듈의 `AuthServiceKey` 타입에 `type` 속성 정보가 생겼습니다.

```
FeatureAuthInterface.AuthServiceKey.type.modify : FeatureAuthInterface.AuthServiceInterface?
FeatureAuthInterface.AuthServiceKey.type.modify : FeatureAuthInterface.AuthServiceInterface? with unmangled suffix ".resume.0"
FeatureAuthInterface.AuthServiceKey.type.getter : FeatureAuthInterface.AuthServiceInterface?
property descriptor for FeatureAuthInterface.AuthServiceKey.type : FeatureAuthInterface.AuthServiceInterface?
variable initialization expression of FeatureAuthInterface.AuthServiceKey.type : FeatureAuthInterface.AuthServiceInterface?
FeatureAuthInterface.AuthServiceKey.type.setter : FeatureAuthInterface.AuthServiceInterface?
```

우리는 `AuthServiceKey` 타입도 알고 있고, `type`이라는 속성도 알고 있기 때문에, `type`이 어떤 타입인지를 확인할 수 있고, 해당 타입을 추출할 수 있습니다.

```bash
$ nm Frameworks/Features.framework/Features \
| awk '{print $3}' \
| xcrun swift-demangle \
| grep "property descriptor for FeatureAuthInterface.AuthServiceKey.type" \
| sed -E "s/.*: (.*)\?/\1/g"

FeatureAuthInterface.AuthServiceInterface
```

`FeatureAuthInterface` 모듈의 `AuthServiceInterface` 타입을 찾았으니, 심볼 테이블에서 `FeatureAuthInterface.AuthServiceInterface`를 찾아봅시다.

```bash
$ nm Frameworks/Features.framework/Features \
| awk '{print $3}' \
| xcrun swift-demangle \
| grep "FeatureAuthInterface.AuthServiceInterface"

demangling cache variable for type metadata for DIContainer.Inject<FeatureAuthInterface.AuthServiceInterface>
protocol conformance descriptor for FeatureAuth.AuthService : FeatureAuthInterface.AuthServiceInterface in FeatureAuth
protocol witness table for FeatureAuth.AuthService : FeatureAuthInterface.AuthServiceInterface in FeatureAuth
protocol witness for FeatureAuthInterface.AuthServiceInterface.auth() -> FeatureAuthInterface.AuthResult in conformance FeatureAuth.AuthService : FeatureAuthInterface.AuthServiceInterface in FeatureAuth
FeatureDeposit.DepositBuilder.authService.getter : FeatureAuthInterface.AuthServiceInterface
property descriptor for FeatureDeposit.DepositBuilder.authService : FeatureAuthInterface.AuthServiceInterface
variable initialization expression of FeatureDeposit.DepositBuilder.(_authService in _F8D93451287FA1752E417A8D41ADF4BF) : DIContainer.Inject<FeatureAuthInterface.AuthServiceInterface>
FeatureDeposit.DepositService.authService.getter : FeatureAuthInterface.AuthServiceInterface
property descriptor for FeatureDeposit.DepositService.authService : FeatureAuthInterface.AuthServiceInterface
FeatureDeposit.DepositService.init(authService: FeatureAuthInterface.AuthServiceInterface) -> FeatureDeposit.DepositService
FeatureAuthInterface.AuthServiceKey.type.modify : FeatureAuthInterface.AuthServiceInterface?
FeatureAuthInterface.AuthServiceKey.type.modify : FeatureAuthInterface.AuthServiceInterface? with unmangled suffix ".resume.0"
FeatureAuthInterface.AuthServiceKey.type.getter : FeatureAuthInterface.AuthServiceInterface?
property descriptor for FeatureAuthInterface.AuthServiceKey.type : FeatureAuthInterface.AuthServiceInterface?
variable initialization expression of FeatureAuthInterface.AuthServiceKey.type : FeatureAuthInterface.AuthServiceInterface?
FeatureAuthInterface.AuthServiceKey.type.setter : FeatureAuthInterface.AuthServiceInterface?
FeatureAuthInterface.AuthServiceKey.init(type: FeatureAuthInterface.AuthServiceInterface?) -> FeatureAuthInterface.AuthServiceKey
protocol descriptor for FeatureAuthInterface.AuthServiceInterface
protocol requirements base descriptor for FeatureAuthInterface.AuthServiceInterface
reflection metadata field descriptor FeatureAuthInterface.AuthServiceInterface
outlined init with take of FeatureAuthInterface.AuthServiceInterface?
outlined init with copy of FeatureAuthInterface.AuthServiceInterface?
outlined assign with take of FeatureAuthInterface.AuthServiceInterface?
outlined destroy of FeatureAuthInterface.AuthServiceInterface?
outlined init with take of FeatureAuthInterface.AuthServiceInterface
outlined init with copy of FeatureAuthInterface.AuthServiceInterface
```

위 결과 중에서 프로토콜을 준수함을 의미하는 `protocol conformance descriptor` 문자열이 있는지 찾아봅시다.

```bash
$ nm Frameworks/Features.framework/Features \
| awk '{print $3}' \
| xcrun swift-demangle \
| grep "FeatureAuthInterface.AuthServiceInterface" \
| grep "protocol conformance descriptor for " \
| sed -E "s/protocol conformance descriptor for (.*) : (.*) in .*/\1/g"

FeatureAuth.AuthService
```

`FeatureAuthInterface` 모듈의 `AuthServiceInterface` 프로토콜을 준수하는 `FeatureAuth` 모듈의 `AuthService`을 찾았습니다.

`FeatureAuthInterface` 모듈의 `AuthServiceKey` 타입과 `FeatureAuth` 모듈의 `AuthService` 타입을 가지고 컨테이너에 등록하는 코드를 작성할 수 있습니다.

```swift
/// ModuleName : Application
/// FileName : RegisterContainerService.swift

import DIContainer
import FeatureAuthInterface
import FeatureAuth

struct ContainerRegisterService {
    func register() {
        let container = Container {
            Component(FeatureAuthInterface.AuthServiceKey.self) { FeatureAuth.AuthService() }
        }
        container.build()
    }
}

/// Module : Application
/// FileName : Application.swift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        ContainerRegisterService()
          .register()

        ...
    }
}
```

지금은 프레임워크 하나만 찾아서 하였지만, find 명령어를 활용하여 모든 라이브러리를 찾아 심볼 테이블을 분석할 수 있습니다.

```bash
$ find . -type f -exec file {} \; \
| grep -e "Mach-O 64-bit dynamically linked shared library arm64" -e "Mach-O 64-bit executable arm64" \
| awk '{print $1}' \
| tr -d ":" \
| xargs nm \
| awk '{print $3}' \
| xcrun swift-demangle 
| ~~~~
```

Xcode에서 사용하는 여러 환경 변수\(ex, CODESIGNING_FOLDER_PATH\)를 이용해서 애플리케이션, 프레임워크 또는 라이브러리 경로를 얻어와 작업도 가능합니다. [Xcode Build Settings](https://xcodebuildsettings.com/)

## 정리

* 빌드 된 결과물은 모든 코드가 모여진 결과물
* 심볼 테이블을 demangle하여 알아볼 수 있는 코드 및 문자열로 변경하고, 해당 코드 및 문자열을 분석하여 원하는 코드를 추출 및 생성할 수 있음

## 참고자료

* [Nest.js는 실제로 어떻게 의존성을 주입해줄까?](https://velog.io/@coalery/nest-injection-how)
* [mikeash.com - Friday Q&A 2014-08-08: Swift Name Mangling](https://mikeash.com/pyblog/friday-qa-2014-08-15-swift-name-mangling.html)
* [Wikipedia - Name mangling](https://en.wikipedia.org/wiki/Name_mangling#Swift)
* [Github - DerekSelander/dsdump](https://github.com/DerekSelander/dsdump)
* [Building a class-dump in 2020](https://derekselander.github.io/dsdump/)

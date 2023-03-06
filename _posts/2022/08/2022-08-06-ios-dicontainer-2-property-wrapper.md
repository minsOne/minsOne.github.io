---
layout: post
title: "[Swift 5.7+] Dependency Injection (2) - 컨테이너 무결성 보장해 보기"
tags: [Swift, Dependency Injection, PropertyWrapper, Service Locator, Container, resultBuilder, DI, IoC, Circular Dependency, Protocol, Generics, nm, mangle, demangle]
---
{% include JB/setup %}

이전 글에서 객체를 저장하고 사용하는 방법을 설명하였습니다. 이번 글에서는 이전에 저장했던 객체의 무결성을 보장하기 위해 어떤 방법을 고려할 수 있는지에 대해 고민해보고자 합니다

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

Swift를 사용하는 소스에서는 현재 의존하는 모듈의 목록과 해당 모듈을 분석하는 것이 일반적으로 불가능합니다. 대신 실행 가능한 바이너리 및 프레임워크에서 심볼을 읽어서 분석하면 어떨까 생각해봅니다.

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

심볼은 우리가 알아보기 어렵기 때문에, `demangle` 하여 알아볼 수 있도록 바꿀 수 있습니다.

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

`AppDelegate`에서 `didFinishLaunchingWithOptions` 함수가 호출된 후 테스트 코드가 실행합니다. 따라서 컨테이너에 키가 등록되어 있음을 가정하고 테스트를 시작할 수 있습니다.

이렇게 테스트 코드를 작성하는 스크립트를 만든다면, 매번 또는 주기적으로 테스트 코드를 이용하여 컨테이너에 등록되어 있는지 검증할 수 있습니다. 키를 사용할 때, 잘 등록되어 있는지를 테스트 코드로 보장이 되므로 안심하고 사용할 수 있습니다.

테스트 코드를 작성해주는 스크립트를 만든다면, 테스트 코드를 이용하여 주기적으로 컨테이너에 등록된 키가 잘 등록되어 있는지 확인할 수 있어, 코드의 안정성과 신뢰성이 높아집니다.

## 컨테이너 등록 코드 작성

테스트 코드 자동화는 코드 안정성을 높이지만, 컨테이너에 등록하는 코드를 작성하는 자동화를 추가한다면 더욱 효과적일 것입니다. 이러한 자동화를 통해 시간과 노력을 절약하면서, 코드의 안정성과 신뢰성을 높일 수 있습니다.

이전에 `DIContainer` 모듈의 `InjectionKey` 프로토콜을 준수하는 키 중에서 `FeatureAuthInterface` 모듈의 `AuthServiceKey`를 추출하였습니다. 이제 `AuthServiceKey`에서 가지고 있는 `associatedtype`으로 필요한 타입을 찾아내어야 합니다.

타입을 찾는 방법은 다양하지만 그 중에 심볼 테이블을 분석해보겠습니다.

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

`AuthServiceKey`의 `associatedtype`에서 어떤 타입을 사용해야 할 지 코드에서 확인할 수 없었습니다. 코드를 살펴보면 `AuthServiceKey`의 `associatedtype`은 `AuthServiceInterface`이어야 한다는 것을 알 수 있습니다. 그러나 이를 심볼 테이블에서 찾을 수 없었습니다. 이를 해결하기 위해 코드를 수정하여 심볼 테이블에서 `AuthServiceInterface`를 찾을 수 있도록 해봅시다.

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

`InjectionKey` 프로토콜에서 `Value` 타입을 가지는 `type` 변수를 정의합니다. 이에 따라, `AuthServiceKey` 코드를 다음과 같이 수정해야합니다.

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

코드를 수정한 후, 애플리케이션을 다시 빌드하고 `Features` 라이브러리의 심볼 테이블을 다시 확인해봅시다.

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

이전에 보지 못했던 `FeatureAuthInterface` 모듈의 `AuthServiceKey` 타입에서 `type` 속성 정보를 확인할 수 있습니다.

```
FeatureAuthInterface.AuthServiceKey.type.modify : FeatureAuthInterface.AuthServiceInterface?
FeatureAuthInterface.AuthServiceKey.type.modify : FeatureAuthInterface.AuthServiceInterface? with unmangled suffix ".resume.0"
FeatureAuthInterface.AuthServiceKey.type.getter : FeatureAuthInterface.AuthServiceInterface?
property descriptor for FeatureAuthInterface.AuthServiceKey.type : FeatureAuthInterface.AuthServiceInterface?
variable initialization expression of FeatureAuthInterface.AuthServiceKey.type : FeatureAuthInterface.AuthServiceInterface?
FeatureAuthInterface.AuthServiceKey.type.setter : FeatureAuthInterface.AuthServiceInterface?
```

`AuthServiceKey` 타입과 `type` 속성 모두 알고 있기 때문에, `type`의 타입을 확인하고 해당 타입을 추출할 수 있습니다.

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

위 결과 중에서 프로토콜을 채택함을 의미하는 `protocol conformance descriptor` 문자열이 있는지 찾아봅시다.

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

`FeatureAuthInterface` 모듈의 `AuthServiceKey` 타입과 `FeatureAuth` 모듈의 `AuthService` 타입을 이용하여 컨테이너에 등록하는 코드를 작성할 수 있습니다.

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

현재는 하나의 프레임워크에서만 찾아냈지만, find 명령어를 사용하여 모든 라이브러리를 검색하고 심볼 테이블을 분석하는 것도 가능합니다.

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

Xcode에서는 `CODESIGNING_FOLDER_PATH`와 같은 여러 환경 변수를 이용하여, 애플리케이션이나 프레임워크, 라이브러리의 경로를 가져올 수 있습니다. 이를 이용하여 작업하는 것도 가능합니다. [Xcode Build Settings](https://xcodebuildsettings.com/)

## 정리

* 빌드 결과물은 모든 코드가 모인 결과물
* 심볼 테이블을 demangle하여 알아볼 수 있는 코드나 문자열로 변환한 뒤, 해당 코드나 문자열을 분석하여 필요한 코드를 추출하거나 생성할 수 있음

## 참고자료

* [Nest.js는 실제로 어떻게 의존성을 주입해줄까?](https://velog.io/@coalery/nest-injection-how)
* [mikeash.com - Friday Q&A 2014-08-08: Swift Name Mangling](https://mikeash.com/pyblog/friday-qa-2014-08-15-swift-name-mangling.html)
* [Wikipedia - Name mangling](https://en.wikipedia.org/wiki/Name_mangling#Swift)
* [Github - DerekSelander/dsdump](https://github.com/DerekSelander/dsdump)
* [Building a class-dump in 2020](https://derekselander.github.io/dsdump/)

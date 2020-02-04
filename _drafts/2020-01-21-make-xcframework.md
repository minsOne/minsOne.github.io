---
layout: post
title: "[WWDC][2019] Binary Frameworks in Swift 살짝 정리"
description: ""
category: ""
tags: [Xcode, Framework, XCFramework, inlinable, usableFromInline, frozen, Build Libraries for Distribution, swiftmodule, swiftinterface]
---
{% include JB/setup %}

# 들어가기 전

[WWDC 2019 - Binary Frameworks in Swift](https://developer.apple.com/videos/play/wwdc2019/416/) 세션의 발표를 번역 및 일부 요약하였습니다. XCFramework를 만드는 방법 및 프레임워크를 다룰 때 어떻게 해야하는지, 호환성은 어떻게 지켜야 하는지 등에 대하 많이 배울 수 있었던 세션이었습니다.

## Introducing XCFrameworks

XCFramework는 Xcode11부터 제공하는 새로운 포맷으로 여러 Framework 변형을 묶어 배포할 수 있습니다.

<p style="text-align:center;"><img src="{{ site.development_url }}/image/2020/1.jpg" style="width: 600px"/></p><br/>

Xcode가 지원하는 모든 플랫폼을 지원하며, AppKit을 사용하는 Mac App, UIKit을 사용하는 MacApp도 지원합니다.

<p style="text-align:center;"><img src="{{ site.development_url }}/image/2020/2.jpg" style="width: 600px"/></p><br/>

Static 프레임워크와 해당 헤더도 묶을 수 있으며, Swift와 C 기반 코드의 바이너리 배포를 지원합니다.

<p style="text-align:center;"><img src="{{ site.development_url }}/image/2020/3.jpg" style="width: 600px"/></p><br/>

Xcode 11에서는 `Build Libraries for Distribution` 라는 빌드 설정이 추가되었습니다. 

<p style="text-align:center;"><img src="{{ site.development_url }}/image/2020/5.jpg" style="width: 600px"/></p><br/>

Swift 기반 바이너리 프레임워크를 클라이언트에게 전달했을 때, 프레임워크가 만들어진 Swift 버전과 클라이언트의 Swift 버전이 다르면 `Compiled module was created by a newer version of the compiler`라는 에러를 볼 수 있습니다. 

<p style="text-align:center;"><img src="{{ site.development_url }}/image/2020/6.jpg" style="width: 600px"/></p><br/>

이 에러는 Swift 컴파일러가 모듈을 import 하면서 `Compiled Module`이라 불리는 `.swiftmodule` 파일을 프레임워크 내에서 찾아, Public API의 manifest를 읽고 클라이언트의 코드가 호출하면 이를 사용할 수 있습니다. 

<p style="text-align:center;"><img src="{{ site.development_url }}/image/2020/7.jpg" style="width: 600px"/></p><br/>

`Compiled Module Format`는 바이너르 포맷으로 Internal Compiler Data Structure를 기본으로 포함하며, 이 Structure는 Swift 컴파일러 버전에 따라 변경할 수 있습니다. 그래서 특정 Swift 버전으로 만들어진 모듈을 import하려고 한다면, 컴파일러는 해당 모듈을 이해할 수 없어 사용이 불가능합니다.

<p style="text-align:center;"><img src="{{ site.development_url }}/image/2020/8.jpg" style="width: 600px"/></p><br/>

이를 해결하기 위해 Xcode 11버전에서는 Swift Module을 위한 `Swift Module Interfaces` 이라는 새로운 포맷을 만들었습니다. 그리고 `Compiled Module Format`과 마찬가지로 Public API를 나열되어 있지만, 소스코드에 가까운 텍스트 형식입니다. `Build Libraries for Distribution` 빌드 설정을 활성화하면 컴파일러는 프레임워크를 빌드할 때마다 `Swift Module Interfaces` 포맷의 파일인 `.swiftinterface`파일을 생성합니다.

<p style="text-align:center;"><img src="{{ site.development_url }}/image/2020/4.jpg" style="width: 600px"/></p><br/>

실제 코드와 swiftinterface에 생성된 코드를 비교 살펴봅시다.

```
/**
 파일명 : FlightKit.swift
 */

import UIKit

public class Spaceship { 
    public let name: String
    private var currentLocation: Location
    
    public init(name: String) {
        self.name = name
        currentLocation = Location(coordinates: "낙성대")
    }
    
    public func fly(
        to destination: Location,
        speed: Speed) {
        currentLocation = destination
    }
}

public enum Speed {
    case leisurely
    case fast
}

public struct Location {
    public var coordinates: String
}


//------------------------------------------------------------------------

/**
 파일명 : FlightKit.xcarchive/Products/Library/Frameworks/FlightKit.framework/Modules/FlightKit.swiftmodule/arm64.swiftinterface
 */

// swift-interface-format-version: 1.0
// swift-compiler-version: Apple Swift version 5.1.2 (swiftlang-1100.0.278 clang-1100.0.33.9)
// swift-module-flags: -target x86_64-apple-ios13.1-macabi -enable-objc-interop -enable-library-evolution -swift-version 5 -enforce-exclusivity=checked -O -module-name FlightKit
import Swift
import UIKit
@_exported import FlightKit
public class Spaceship {
  final public let name: Swift.String
  public init(name: Swift.String)
  public func fly(to destination: FlightKit.Location, speed: FlightKit.Speed)
  @objc deinit
}
public enum Speed {
  case leisurely
  case fast
  public static func == (a: FlightKit.Speed, b: FlightKit.Speed) -> Swift.Bool
  public var hashValue: Swift.Int {
    get
  }
  public func hash(into hasher: inout Swift.Hasher)
}
public struct Location {
  public var coordinates: Swift.String
}
extension FlightKit.Speed : Swift.Equatable {}
extension FlightKit.Speed : Swift.Hashable {}
```

swiftinterface 파일을 분석해봅시다.

Meta Data 섹션은 인터페이스를 생성한 컴파일러 버전이 포함되지만, Swift 컴파일러가 해당 모듈을 가져오는데 필요한 Command Line Flag의 명령들도 포함되어 있습니다.

다음으로 Spaceship Class의 Public API를 살펴봅시다. public인 name은 인터페이스에 포함되어 있지만, private인 currentLocation은 포함되지 않았습니다. 이는 Public API의 일부가 아니기 때문입니다. Public인 생성자와 fly 함수는 인터페이스에 포함되어 있으나, 본문은 포함되지 않았습니다. 이 역시 Public API의 일부가 아니기 때문입니다. 
Swift에서는 클래스를 작성할 때 명시적인 초기화 해제 - deinit을 작성하지 않으면, 컴파일러가 deinit을 생성합니다.
이러한 형식이 모든 컴파일러 버전에서 안정적일려면, 컴파일러는 소스 코드에 어떤 가정도 하지 않아야합니다. 그래서 Module Interface에 포함됩니다.

다음으로 Speed Enum을 살펴봅시다. 두 가지 case가 인터페이스에 포함되어 있는데, 이는 Public API의 일부입니다. 그리고 인터페이스에는 Speed가 명확하게 Hashable을 준수하고 있습니다. Hashable과 Equatable을 준수하기 위해 Method를 나열하고 있습니다.
Swift는 associted value가 없는 Enum을 만들면, 컴파일러는 암묵적으로 Equatable과 Hashable을 준수하도록 하며 필요한 메소드를 자동으로 도출합니다. 명확하고 가정하지 않도록 Module Interface에 포함되어 있습니다.

마지막으로 Location Struct는 Public인 coordinates만 있고, 어떠한 적합성(conformances)가 선언되지 않았기 때문에 Module Interface에 그대로 포함됩니다.


## Building an XCFramework

다음으로 배포 가능한 바이너리 XCFramework를 빌드하는 방법을 이야기 해봅시다.

프레임워크를 만드는 첫 단계는 Archiving 하는 것입니다. Archive에는 프레임워크의 해당 빌드에 해당하는 디버그 정보도 포함되어 있으며, 클라이언트는 프레임워크에서 발생하는 충돌이나 불완전성이 있으면 해당 정보를 사용하여 Symbol을 보고 디버깅을 할 수 있습니다.

`xcodebuild archive` 를 이용하여 프레임워크를 만들어봅시다.

```
$ xcodebuild archive -scheme [Scheme 명] -archivePath [Archive 출력 결과 경로] -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# ex) iOS, iOS Simulator, macOS
$ xcodebuild archive -scheme FlightKit -archivePath "./build/ios.xcarchive" -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
$ xcodebuild archive -scheme FlightKit -archivePath "./build/ios_sim.xcarchive" -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
$ xcodebuild archive -scheme FlightKit -archivePath "./build/mac.xcarchive" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
```

여러 환경에 맞는 프레임워크 변형을 만들었습니다.

<p style="text-align:center;"><img src="{{ site.development_url }}/image/2020/9.jpg" style="width: 600px"/></p><br/>


그리고 Xcode에서 지원하는 다양한 SDK 목록은 `-showsdks` 옵션을 이용하여 얻을 수 있습니다.

```
$ xcodebuild -showsdks
iOS SDKs:
	iOS 13.2                      	-sdk iphoneos13.2

iOS Simulator SDKs:
	Simulator - iOS 13.2          	-sdk iphonesimulator13.2

macOS SDKs:
	DriverKit 19.0                	-sdk driverkit.macosx19.0
	macOS 10.15                   	-sdk macosx10.15

tvOS SDKs:
	tvOS 13.2                     	-sdk appletvos13.2

tvOS Simulator SDKs:
	Simulator - tvOS 13.2         	-sdk appletvsimulator13.2

watchOS SDKs:
	watchOS 6.1                   	-sdk watchos6.1

watchOS Simulator SDKs:
	Simulator - watchOS 6.1       	-sdk watchsimulator6.1
```

이제 프레임워크를 만들었으므로, `xcodebuild -create-xcframework` 명령을 이용하여 `XCFramework` 파일을 만들어봅시다.

```
xcodebuild -create-xcframework \
    -framework "./build/ios.xcarchive/Products/Library/Frameworks/FlightKit.framework" \
    -framework "./build/ios_sim.xcarchive/Products/Library/Frameworks/FlightKit.framework" \
    -framework "./build/macos.xcarchive/Products/Library/Frameworks/FlightKit.framework" \
    -output "./build/FlightKit.xcframework"
```

<p style="text-align:center;"><img src="{{ site.development_url }}/image/2020/10.jpg" style="width: 600px"/></p><br/>

요약하면, `Build Libraries for Distribution`를 활성화하고, 프레임워크를 만든 후, `xcodebuild -create-xcframework`를 실행하여 패키지로 만드는 것입니다.

## Framework Author Considerations

프레임워크는 배포할 때마다 발전을 합니다. 발전을 한다는 의미는 새로운 버전의 프레임워크가 출시될 때마다 새로운 기능, 새로운 API, 버그 수정입니다. 그리고 소스 또는 바이너리 호환성이 손상되지 않기 바랍니다. 바이너리 호환성이 손상된다면 클라이언트의 코드가 수정 및 다시 컴파일이 되어야 한다는 의미입니다. 

<p style="text-align:center;"><img src="{{ site.development_url }}/image/2020/11.jpg" style="width: 600px"/></p><br/>

프레임워크 버전은 중요하며, 이를 프레임워크에 게시해야 하며, 프레임워크의 Info.plist의 Bundle version에 설정해야 합니다. 사람이 읽을 수 있는 버전 번호로 클라이언트에게 마지막 릴리즈 이후로 변경사항을 알려줍니다.

<p style="text-align:center;"><img src="{{ site.development_url }}/image/2020/12.jpg" style="width: 600px"/></p><br/>

그리고 버전은 [Semantic Versioning](https://semver.org) 사용을 권장합니다. 

<p style="text-align:center;"><img src="{{ site.development_url }}/image/2020/13.jpg" style="width: 600px"/></p><br/>

X.Y.Z 형식으로 X는 주 버전이며, Y는 부 버전, Z는 수 버전입니다.(해당 용어는 https://semver.org/lang/ko/ 에 기술된 번역을 따랐습니다.)

수 버전은 버그 수정 또는 클라이언트에게 영향이 미치지 않는 프레임워크의 구현 변경을 나타냅니다. 부 버전은 이전 버전과 호환되는 버전으로 새로운 API 또는 새로운 기능을 나타냅니다. 그리고 주 버전은 소스 변경, 바이너리 변경, Semantic 변경이든 호환성이 유지되지 않아 클라이언트는 다시 컴파일을 하고 코드 일부를 다시 수정하고 실행해야하는 버전입니다.

이전 FlightKit 코드를 변경하여 프레임워크 버전에 어떻게 영향을 미치는지 살펴봅시다.

```
/**
 파일명 : FlightKit.swift
 버전 : 1.0.1
 */

import UIKit

public class Spaceship { 
    public let name: String
    private static var defaultLocation: Location?
    private var currentLocation: Location
    
    public init(name: String) {
        self.name = name
        currentLocation = Self.defaultLocation ?? Location(coordinates: "낙성대")
    }
    
    public func fly(
        to destination: Location,
        speed: Speed) {
        currentLocation = destination
    }
}

public enum Speed {
    case leisurely
    case fast
}

public struct Location {
    public var coordinates: String
}

```

Spaceship에 새로운 private인 `defaultLocation`을 추가하였고, Spaceship 생성자 내에서 사용하지만, Module Interface에 나타나지 않습니다. 프레임워크의 Public API의 일부가 아니기 때문입니다. 따라서 이런 종류의 변경사항은 부 버전 또는 수 버전만 업데이트 하면 됩니다. 하지만 이전 버전의 생성자 동작이 *문서화* 된 경우, 의미론적으로는 변경되었으므로 클라이언트이 업데이트를 고려하도록 주 버전을 변경해야 합니다. 

```
/**
 파일명 : FlightKit.swift
 버전 : 1.1.0
 */

public class Spaceship { 
    ...
    public func doABarrelRoll() {
        /// ...
    }
    ...
}
...
```

다음 변경사항으로 Spaceship에 새로운 public 메소드인 `doABarrelRoll`를 추가하고, 이는 클라이언트가 사용할 수 있습니다. 따라서 부 버전 번호를 증가시키고, 수 버전 번호는 0으로 초기화합니다. 


```
/**
 파일명 : FlightKit.swift
 버전 : 2.0.0
 */

public class Spaceship { 
    ...
    public func fly(
        to destination: Location,
        speed: Speed,
        stealthily: Bool = false) {
        currentLocation = destination
    }
    ...
}

...

public struct Location {
    public var coordinates: String
    public var label: String
}
```

마지막으로 fly 메소드에 새 매개변수를 추가하였습니다. fly 메소드를 사용하는 경우 대부분의 경우에 변경할 필요가 없도록 기본 값을 지정하였습니다. 그러나 Swift에서는 함수는 이름과 매개변수가 Label과 Type 모두 다 고유하게 식별되므로, 소스와 바이너리 호환성을 손상시켰습니다. 따라서 주 버전 번호를 증가시키고, 클라이언트에게 다시 컴파일 하도록 요청해야 합니다.

```
/**
 파일명 : FlightKit.swift
 버전 : 2.1.0
 */

...
public enum Speed {
    case leisurely
    case fast
    case ludicrous
}

public struct Location: Hashable {
    public var coordinates: String
    public var label: String
}
```

Speed Enum에 새로운 Case를, Location에 Hashable을 추가했습니다. 소스나 바이너리 호환성을 손상시키지 않았고, 변경사항이 이전 버전과 호환되므로 부 버전 번호만 올리면 됩니다.

클라이언트가 필요한 기능이 있으면 새로운 기능을 쉽게 추가할 수 있지만, 어떤 기능을 제거하려면 클라이언트의 소스 또는 바이너리 호환성이 손상될 수 있기 때문에 어렵습니다. 타입과 같이 변경할 수 없는 사항에 대해서는 이름을 신중하게 고려해야 합니다. 그리고 확장성을 너무 일찍 고려하지 않아야 합니다. Class를 개방하거나 임의의 Callback을 제공할 필요가 없습니다. 클라이언트 무엇을 하고 있는지 고려하면서 한다면 프레임워크의 동작을 추론하기 어려워집니다. Class를 개방하는 것은 언제든지 할 수 있습니다. Callback 추가는 항상 할 수 있지만, 기본적으로 제공하는 유연성은 제거할 수 없습니다.

<p style="text-align:center;"><img src="{{ site.development_url }}/image/2020/14.jpg" style="width: 600px"/></p><br/>

<p style="text-align:center;"><img src="{{ site.development_url }}/image/2020/15.jpg" style="width: 600px"/></p><br/>

클라이언트의 코드에서 FlightKit의 fly 메소드를 사용합니다. 런타임에서 클라이언트는 fly 메소드가 어떤 건지 프레임워크에 물어보고, 프레임워크는 두 번째 메소드라고 응답합니다. 이는 클래스에 새로운 메소드가 추가될 때에도 바이너리 호환성이 보장되는 방법입니다. Objective-C에서도 라이브러리 간의 호출시 Message Dispatch라는 같은 방법을 사용하고 있지만, Swift는 프레임워크를 넘을 때 사용합니다.

<p style="text-align:center;"><img src="{{ site.development_url }}/image/2020/16.jpg" style="width: 600px"/></p><br/>

Enum 타입은 바이너리 호환성을 유지하면서 새로운 Case를 추가할 수 있습니다. 즉, Enum 타입이 메모리가 얼마나 큰지 알 수 없으므로, 프레임워크에 물어보고, 프레임워크는 1 byte라고 응답합니다.
클라이언트는 프레임워크에 Enum 값을 정리할 것을 요청하고, 프레임워크는 이를 수행합니다. 프레임워크와 클라이언트 간의 추가 커뮤니케이션을 이야기 하고 있습니다. 이는 성능에 민감한 프레임워크가 있기 때문입니다. (역자 주. 이 부분은 해석이 좀 어렵네요.  *원문*. And so the client will also ask the framework to cleanup the enum value when it's done with it, and the framework will do so. Now, a couple of you in the audience at this point are probably getting a little antsy because we're talking about all this extra communication between the client and the framework, and that's because you have performance sensitive frameworks.)



## Trading Flexibility for Optimizability

우리는 프레임워크 작성자로 소스 또는 바이너리 호환성을 유지하면서 기능을 변경하고, 추가하고 개선할 수 있는 유연성을 필요로 합니다. 그러나 컴파일러가 클라이언트 코드를 가능한 빨리 만들려면 프레임워크에 무엇이 있는지 가정해야 합니다. Swift는 유연성, 최적화 양쪽을 모두 처리할 수 있어야 합니다. 이를 위해 `Build Libraries for Distribution` 빌드 설정을 활성화하여 Module Interface 파일을 만들어, 유연성 측면을 기본으로 합니다. 

<p style="text-align:center;"><img src="{{ site.development_url }}/image/2020/21.jpg" style="width: 600px"/></p><br/>

그리고 최적화 관련된 세 가지 방법인 **@inlinable functions**, **@frozen enum**, **@frozen struct**이 있습니다.

<p style="text-align:center;"><img src="{{ site.development_url }}/image/2020/18.jpg" style="width: 600px"/></p><br/>

Swift 4.2에서 도입된 **inlinable functions**은 메소드 뿐만 아니라 본문도 프레임워크의 Public API 일부로 만들어, Module Interface 파일에 본문이 복사됩니다. 본문을 볼 수 있기 때문에, 어떤 내부 속성을 참조하는지도 알 수 있습니다. 이때 사용하는 내부 속성은 **@usableFromInline**으로 마크하여야 가능하며, 해당 속성이 Public API 일부로도 가능하지만, inlinable 코드에서만 사용이 가능합니다. 하지만 외부로 보인다고 하지만 internal 이므로 외부 클라이언트가 임의로 읽거나 쓰는 것이 방지됩니다.<br/><br/>

<p style="text-align:center;"><img src="{{ site.development_url }}/image/2020/19.jpg" style="width: 600px"/></p><br/>

CargoShip 코드를 한번 살펴봅시다. currentCargo 속성은 interal 이므로 Module Interface에 포함되지 않습니다. 그리고 @inlinable로 마크한 canCarry 메소드의 본문이 Module Interface에 있습니다. 클라이언트가 해당 인터페이스에 대해 컴파일을 할 때, canCarry 메소드 본문이 클라이언트 코드에 복사되며, 최적화 할 수 있습니다. 

<p style="text-align:center;"><img src="{{ site.development_url }}/image/2020/22.jpg" style="width: 600px"/></p><br/>

그러나 프레임워크의 canCarry 메소드의 본문이 변경되고 클라이언트가 다시 컴파일을 하지 않으면 변경된 메소드의 본문이 클라이언트 코드로 복사되지 않습니다. 여기에서 프로그램의 심각한 논리 오류가 발생할 수 있습니다. 더 나은 알고리즘 등의 동일한 결과라면 괜찮지만 그렇지 않다면 @inlinable 메소드의 본문은 변경하지 않아야 합니다. 만약 이 작업을 해야한다면 모든 클라이언트가 다시 컴파일 해야합니다.

Enum은 소스나 바이너리 호환성을 유지하면서 새로운 case를 enum에 추가할 수 있습니다. 단, 클라이언트가 default case를 항상 적어야 합니다. Swift 4.2에서는 @unknown default 구문이 추가되었습니다. 이는 모든 case를 다뤘지만, 미래에 추가되는 case를 처리하겠다는 의미입니다.<br/>

<p style="text-align:center;"><img src="{{ site.development_url }}/image/2020/23.jpg" style="width: 600px"/></p><br/>

하지만 @frozen을 Enum에 표시하면 프레임워크는 향후 릴리즈에 새로운 case가 추가되지 않을 것임을 약속합니다. 이로 인해 클라이언트는 더이상 default case를 작성할 필요가 없으며, 컴파일러는 더 효율적으로 컴파일을 할 수 있습니다. <br/>

<p style="text-align:center;"><img src="{{ site.development_url }}/image/2020/24.jpg" style="width: 600px"/></p><br/>

하지만 클라이언트 코드에는 default case가 없으므로, 프레임워크에서 새로운 case를 추가한다면 주 버전을 증가시키고 모든 클라이언트에게 다시 컴파일 하도록 해야합니다.

<p style="text-align:center;"><img src="{{ site.development_url }}/image/2020/25.jpg" style="width: 600px"/></p><br/>

Struct는 새로운 stored 속성을 추가하거나 기존 속성을 재정렬하는데 문제는 없지만, 클라이언트와 프레임워크 간 Handshake와 같은 종류의 추가 커뮤니케이션이 발생합니다. 이를 방지하기 위해, Struct에 @frozen을 표시하여 stored 속성이 추가, 변경, 순서 변경 또는 제거가 되지 않을 것을 약속할 수 있습니다.

또한, 컴파일러가 클라이언트에 매우 효율적인 코드를 생성하도록 @inlinable을 생성자에 표기합니다. 이때 모든 stored 속성을 설정할 것을 요구합니다. 그래서 모든 stored 속성을 Public으로 접근 수준 제어하거나 또는 @usableFromInline을 표기해야 합니다.<br/>

<p style="text-align:center;"><img src="{{ site.development_url }}/image/2020/26.jpg" style="width: 600px"/></p><br/>

프레임워크 변경사항은 클라이언트 또는 해당 프레임워크를 사용하는 다른 바이너리 프레임워크에 호환성 등의 문제가 발생할 수 있습니다. 따라서 @frozen 또는 @inlinable을 이용하기 전에 외부에서 프레임워크의 동작을 프로파일링 하고, 추가 성능이 필요한지를 입증해야 하며, 그렇지 않다면 **유연성 - Flexibility**를 유지해야 합니다.<br/><br/>

## Helping Your Clients

<p style="text-align:center;"><img src="{{ site.development_url }}/image/2020/27.jpg" style="width: 600px"/></p><br/>

프레임워크가 성공적으로 채택되기 위해서는 어떤 일을 하는지 알 수 있도록 문서화가 필요합니다. 또한, 권한 요청을 최소화하며, 이는 더 많은 Context에 적용할 수 있습니다. 그리고 프레임워크와 어플리케이션은 유저에게 권한을 요청할 수 있지만, 궁극적으로 권한 부여 여부는 고객 선택입니다. 따라서 특정 권한이 거부되면 프레임워크가 이를 정상적으로 처리해야 하며, 어플리케이션이 크래시나거나 작동이 멈추면 안됩니다. 

따라서 프레임워크가 의존성을 최소화하여 어플리케이션에 적게 요구하고, 따라서 신뢰 확장(Extending Trust)와 의존성이 차지하는 코드 사이즈와 같은 문제가 적습니다.(Less in extending trust, and even practical matters like the code size taken up by your Dependencies.)
마지막으로 Build Libraries for Distribution 빌드 설정을 설정하여 바이너리 호환성을 보장해야 하며, 이는 Package에 의존할 수 없다는 의미입니다.<br/>

<p style="text-align:center;"><img src="{{ site.development_url }}/image/2020/27.jpg" style="width: 600px"/></p><br/><br/>

Xcode 기본 템플릿에는 Objective-C Umbrella Header와 Swift의 Objective-C 일부를 포함하는 Header를 만들어주는 설정이 활성화되어 있습니다. 프레임워크가 Objective-C API를 제공하지 않으면 Objective-C 헤더를 생성할 필요가 없으므로, `Swift Compiler - Genenal의 Install Objective-C Compatibility Header` 빌드 설정을 비활성화 합니다. 

<p style="text-align:center;"><img src="{{ site.development_url }}/image/2020/28.jpg" style="width: 600px"/></p><br/>

그리고 Objective-C의 Import 구문을 지원할 필요가 없기 때문에 `Packaging - Defines Module` 빌드 설정을 비활성화 합니다. 그러면 Objective-C에 유효한 코드가 아니므로, Xcode가 생성하는 Umbrella Header도 제거됩니다.

<p style="text-align:center;"><img src="{{ site.development_url }}/image/2020/29.jpg" style="width: 600px"/></p><br/>

## Summary
XCFramework는 사용자에게 여러 프레임워크 변형을 배포하기 위한 새로운 Bundle Format입니다. `Build Libraries for Distribution` 빌드 설정을 활성화 해야 바이너리 프레임워크의 호환성을 얻을 수 있으며 XCFrameworks를 만들 수 있습니다.


## 참고자료
https://habr.com/ru/company/true_engineering/blog/475816/
https://medium.com/trueengineering/xcode-and-xcframeworks-new-format-of-packing-frameworks-ca15db2381d3

https://appspector.com/blog/xcframeworks
https://stackoverflow.com/questions/47103464/archive-in-xcode-appears-under-other-items
https://instabug.com/blog/ios-binary-framework/
https://instabug.com/blog/swift-5-module-stability-workaround-for-binary-frameworks/

https://medium.com/@dcortes22/how-to-create-a-xcframework-2a166445a898

https://pspdfkit.com/guides/ios/current/troubleshooting/removing-architectures/
https://pspdfkit.com/guides/ios/current/getting-started/integrating-pspdfkit/
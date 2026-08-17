---
layout: post
title: "[Swift] SPM 외부 의존성을 하나의 XCFramework로 미리 빌드하기"
tags: [Swift, SPM, XCFramework, Modularization, Tuist]
---
{% include JB/setup %}

프로젝트를 여러 모듈로 나누면 각 모듈이 사용하는 외부 패키지도 반복해서 빌드하게 됩니다. RxSwift, RxCocoa, Alamofire처럼 코드가 크고 자주 변경되지 않는 패키지는 이 비용이 더 크게 느껴집니다.

외부 패키지의 버전을 일정 기간 고정해서 사용한다면 소스 대신 미리 빌드한 바이너리를 배포할 수 있습니다. 이번에는 여러 SPM 패키지의 구현을 하나의 Dynamic Framework로 묶고, 다음과 같은 기존 import를 유지하는 XCFramework를 만들었습니다.

```swift
import Alamofire
import RxCocoa
import RxSwift
```

이 글에서는 XCFramework를 만드는 과정뿐만 아니라 App, Dynamic Framework, Static Library에서 사용하고 Archive까지 확인한 내용을 정리합니다.

## 하나의 Dynamic Framework로 묶기

먼저 외부 패키지를 의존하는 Dynamic Library를 SPM으로 정의합니다.

```swift
let package = Package(
  name: "ExternalDependenciesSDK",
  platforms: [
    .iOS(.v15),
  ],
  products: [
    .library(
      name: "ExternalDependencies",
      type: .dynamic,
      targets: ["ExternalDependencies"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/ReactiveX/RxSwift.git",
      exact: "6.9.1"
    ),
    .package(
      url: "https://github.com/Alamofire/Alamofire.git",
      exact: "5.12.0"
    ),
  ],
  targets: [
    .target(
      name: "ExternalDependencies",
      dependencies: [
        .product(name: "RxSwift", package: "RxSwift"),
        .product(name: "RxCocoa", package: "RxSwift"),
        .product(name: "Alamofire", package: "Alamofire"),
      ]
    ),
  ]
)
```

이 타깃을 빌드하면 외부 패키지의 구현 심볼은 `ExternalDependencies.framework` 바이너리에 포함됩니다. 하지만 바이너리만 전달해서는 사용하는 쪽에서 `import RxSwift`를 할 수 없습니다. 컴파일러가 `RxSwift`라는 모듈의 공개 API를 알 수 있는 정보도 필요하기 때문입니다.

## 바이너리와 모듈 인터페이스 나누기

Swift 모듈을 import할 때는 구현 바이너리와 모듈 정보가 함께 필요합니다.

- `ExternalDependencies`: 실제 구현 심볼이 들어 있는 바이너리
- `.swiftinterface`: 각 Swift 모듈의 공개 인터페이스
- `module.modulemap`과 헤더: Objective-C 기반 Clang 모듈 정보

`BUILD_LIBRARY_FOR_DISTRIBUTION=YES`로 빌드하면 배포용 `.swiftinterface`가 생성됩니다. 같은 빌드에서 만들어진 바이너리 `.swiftmodule` 대신 텍스트 형식의 `.swiftinterface`를 SDK에 포함했습니다.

```text
ExternalDependencies.framework
└── Modules
    ├── Alamofire.swiftmodule
    │   └── arm64-apple-ios.swiftinterface
    ├── RxCocoa.swiftmodule
    │   └── arm64-apple-ios.swiftinterface
    ├── RxRelay.swiftmodule
    │   └── arm64-apple-ios.swiftinterface
    └── RxSwift.swiftmodule
        └── arm64-apple-ios.swiftinterface
```

소비자 코드는 각 `.swiftinterface`를 보고 컴파일하지만, 링크할 때는 하나의 `ExternalDependencies.framework`에서 구현을 찾습니다. 따라서 기존 모듈 이름을 유지하면서 실제 Dynamic Framework는 하나만 앱에 포함할 수 있습니다.

## RxCocoa가 요구하는 Clang Module

RxCocoa의 `.swiftinterface`에는 `RxCocoaRuntime`에 대한 의존성이 있습니다. `RxCocoaRuntime`은 Objective-C 헤더로 구성된 Clang Module이므로 Swift interface만 복사해서는 RxCocoa를 import할 수 없습니다.

```text
Modules
└── RxCocoaRuntime
    ├── module.modulemap
    ├── RxCocoaRuntime.h
    └── *.h
```

```text
module RxCocoaRuntime {
  umbrella header "RxCocoaRuntime.h"
  export *
}
```

Swift 모듈의 `.swiftinterface`가 다시 의존하는 Swift 또는 Clang Module까지 함께 제공해야 모듈 그래프가 완성됩니다.

## SDK 레이아웃

최종 결과물은 XCFramework와 빌드 메타데이터를 포함하는 SDK 디렉터리로 구성했습니다.

```text
ExternalDependenciesSDK
├── ExternalDependencies.xcframework
│   ├── ios-arm64
│   │   └── ExternalDependencies.framework
│   │       └── Modules
│   └── ios-arm64_x86_64-simulator
│       └── ExternalDependencies.framework
│           └── Modules
└── Metadata
    └── Package.resolved
```

`Package.resolved`는 XCFramework를 사용하는 데 필요한 파일이 아닙니다. 어떤 버전의 패키지로 바이너리를 만들었는지 확인하기 위한 정보이므로 XCFramework 내부가 아닌 SDK의 `Metadata`에 둡니다.

각 Framework slice의 `Modules`에는 해당 플랫폼과 아키텍처에 맞는 interface를 넣습니다. Simulator slice에는 arm64와 x86_64 interface가 모두 필요합니다.

## XCFramework 빌드 스크립트

SDK 생성 과정은 `build-sdk.sh`로 정리했습니다. 먼저 디바이스와 Simulator용 framework를 각각 빌드합니다.

```shell
#!/bin/bash

set -euo pipefail

project_dir="$(cd "$(dirname "$0")/.." && pwd)"
build_dir="$project_dir/.build"
simulator_derived_data="$build_dir/DerivedData-simulator"
device_derived_data="$build_dir/DerivedData-device"

simulator_products="$simulator_derived_data/Build/Products/Release-iphonesimulator"
device_products="$device_derived_data/Build/Products/Release-iphoneos"

build() {
  local destination="$1"
  local derived_data="$2"

  xcodebuild \
    -scheme ExternalDependenciesSDK \
    -configuration Release \
    -destination "$destination" \
    -derivedDataPath "$derived_data" \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SKIP_INSTALL=NO \
    CODE_SIGNING_ALLOWED=NO \
    build
}

build "generic/platform=iOS Simulator" "$simulator_derived_data"
build "generic/platform=iOS" "$device_derived_data"
```

두 framework를 `xcodebuild -create-xcframework`로 묶습니다.

```shell
sdk_dir="$build_dir/ExternalDependenciesSDK"
output_dir="$sdk_dir/ExternalDependencies.xcframework"

rm -rf "$sdk_dir"
mkdir -p "$sdk_dir"

xcodebuild -create-xcframework \
  -framework \
    "$simulator_products/PackageFrameworks/ExternalDependencies.framework" \
  -framework \
    "$device_products/PackageFrameworks/ExternalDependencies.framework" \
  -output "$output_dir"
```

마지막으로 외부 모듈의 interface와 RxCocoaRuntime의 Module Map을 각 slice에 넣습니다.

```shell
checkout_dir="$simulator_derived_data/SourcePackages/checkouts/RxSwift"

install_modules() {
  local products_dir="$1"
  local framework_dir="$2"

  for module in Alamofire RxSwift RxRelay RxCocoa; do
    mkdir -p "$framework_dir/Modules/$module.swiftmodule"
    cp "$products_dir/$module.swiftmodule/"*.swiftinterface \
      "$framework_dir/Modules/$module.swiftmodule/"
  done

  mkdir -p "$framework_dir/Modules/RxCocoaRuntime"
  cp "$checkout_dir/Sources/RxCocoaRuntime/include/"*.h \
    "$framework_dir/Modules/RxCocoaRuntime/"
  cp "$project_dir/Config/RxCocoaRuntime.modulemap" \
    "$framework_dir/Modules/RxCocoaRuntime/module.modulemap"
}

install_modules \
  "$simulator_products" \
  "$output_dir/ios-arm64_x86_64-simulator/ExternalDependencies.framework"

install_modules \
  "$device_products" \
  "$output_dir/ios-arm64/ExternalDependencies.framework"

mkdir -p "$sdk_dir/Metadata"
cp "$project_dir/Package.resolved" "$sdk_dir/Metadata/Package.resolved"
```

이 스크립트는 XCFramework를 만든 뒤 내부 파일을 추가합니다. 배포본에 서명한다면 모듈 구성을 모두 마친 후 XCFramework에 서명해야 합니다.

## Tuist 프로젝트에서 사용하기

동작을 확인하기 위해 다음 구조의 데모 프로젝트를 Tuist로 만들었습니다.

```text
DemoApp
├── DemoFramework                 Dynamic Framework
│   └── DemoStaticLibrary         Static Library
└── ExternalDependencies.xcframework
```

각 타깃은 실제로 사용하는 모듈을 import합니다.

- `DemoStaticLibrary`: `import Alamofire`
- `DemoFramework`: `import RxSwift`, `import RxCocoa`
- `DemoApp`: `DemoFramework`가 제공하는 화면 사용

XCFramework 의존성은 각 타깃에 명시합니다.

```swift
let externalDependency: TargetDependency = .xcframework(
  path: "../.build/ExternalDependenciesSDK/ExternalDependencies.xcframework"
)
```

의존성 선언은 바이너리를 링크하기 위한 용도만 있는 것이 아닙니다. Xcode가 현재 빌드 플랫폼에 맞는 slice를 선택하고 컴파일 전에 빌드 디렉터리에 준비하도록 합니다.

외부 모듈의 검색 경로는 다음과 같이 설정했습니다.

```swift
let externalModuleSettings: Settings = .settings(
  base: [
    "SWIFT_INCLUDE_PATHS":
      "$(inherited) $(BUILT_PRODUCTS_DIR)/ExternalDependencies.framework/Modules",
    "HEADER_SEARCH_PATHS":
      "$(inherited) $(BUILT_PRODUCTS_DIR)/ExternalDependencies.framework/Modules/RxCocoaRuntime",
  ]
)
```

각 프로젝트에서 XCFramework까지의 상대 경로를 계산하는 대신, Xcode가 선택한 framework가 놓이는 빌드 디렉터리를 기준으로 모듈을 찾습니다. 여러 프로젝트에서 같은 설정을 사용할 수 있고 디바이스와 Simulator slice도 따로 계산하지 않아도 됩니다.

XCFramework 파일의 위치는 Tuist의 `ProjectDescriptionHelpers`에서 한 번만 정의하고 각 프로젝트에서 재사용할 수 있습니다. SDK를 저장하는 위치도 저장소 루트의 `Vendor`처럼 하나로 고정하는 편이 관리하기 쉽습니다.

```swift
public enum ExternalDependencies {
  public static let dependency: TargetDependency = .xcframework(
    path: .relativeToRoot(
      "Vendor/ExternalDependenciesSDK/ExternalDependencies.xcframework"
    )
  )

  public static let settings: Settings = externalModuleSettings
}
```

각 `Project.swift`는 프로젝트 위치에 따라 `../`를 계산하지 않고 같은 dependency와 settings를 사용합니다.

## Build와 Archive의 경로가 달랐던 문제

처음에는 모듈 검색 경로로 `$(TARGET_BUILD_DIR)`를 사용했습니다.

```text
$(TARGET_BUILD_DIR)/ExternalDependencies.framework/Modules
```

일반 Build와 디바이스 링크는 성공했지만 Archive에서 Static Library를 컴파일할 때 모듈을 찾지 못했습니다. Archive 과정에서 해당 타깃의 `TARGET_BUILD_DIR`가 `UninstalledProducts/iphoneos`로 바뀌었기 때문입니다. 반면 Xcode가 XCFramework에서 선택한 framework는 `BUILT_PRODUCTS_DIR`에 있었습니다.

검색 경로를 `$(BUILT_PRODUCTS_DIR)` 기준으로 변경한 후 일반 Build와 Archive가 모두 성공했습니다.

```text
$(BUILT_PRODUCTS_DIR)/ExternalDependencies.framework/Modules
```

빌드 설정의 경로는 Debug 빌드만 확인해서는 부족합니다. App뿐만 아니라 Framework와 Static Library를 포함한 구조에서 디바이스 Archive까지 확인해야 합니다.

## 소비자와 Archive 검증하기

Tuist 프로젝트에 연결하기 전에 `swiftc`로 SDK만 사용하는 소비자를 컴파일했습니다. 이 검증은 원본 SPM 패키지 없이 interface를 읽고 통합 바이너리에 링크할 수 있는지 확인합니다.

```shell
framework_dir=".build/ExternalDependenciesSDK/ExternalDependencies.xcframework/ios-arm64"
mkdir -p .build/Consumer-device

xcrun --sdk iphoneos swiftc \
  -target arm64-apple-ios15.0 \
  -sdk "$(xcrun --sdk iphoneos --show-sdk-path)" \
  -I "$framework_dir/ExternalDependencies.framework/Modules" \
  -I "$framework_dir/ExternalDependencies.framework/Modules/RxCocoaRuntime" \
  -F "$framework_dir" \
  -framework ExternalDependencies \
  Consumer/main.swift \
  -o .build/Consumer-device/Consumer
```

그다음 Tuist workspace를 생성하고 Simulator Build와 디바이스 Archive를 실행합니다.

```shell
cd Demo
mise exec -- tuist generate --no-open

xcodebuild \
  -workspace ExternalDependenciesDemo.xcworkspace \
  -scheme DemoApp \
  -destination "generic/platform=iOS Simulator" \
  build

xcodebuild \
  -workspace ExternalDependenciesDemo.xcworkspace \
  -scheme DemoApp \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath .build/ExternalDependenciesDemo \
  archive
```

직접 컴파일은 SDK의 모듈 구성과 링크를 확인하고, Tuist 프로젝트 빌드는 Xcode의 slice 선택과 타깃 간 의존성을 확인합니다. Archive는 일반 Build와 다른 제품 경로와 embed 결과를 확인하기 위해 별도로 실행합니다.

## Modules가 앱에 포함되는지 확인하기

`.swiftinterface`와 Module Map은 컴파일할 때 필요하지만 런타임에는 필요하지 않습니다. Framework의 `Modules`에 파일을 추가하면 Archive 용량도 늘어나는지 확인할 필요가 있습니다.

실제 Archive 결과에서 앱에 포함된 framework를 확인했습니다.

```text
DemoApp.app
└── Frameworks
    └── ExternalDependencies.framework
        ├── ExternalDependencies
        └── Info.plist
```

Xcode는 framework를 앱에 embed할 때 `Modules`를 제거했습니다. SDK 배포본의 크기는 interface만큼 늘어나지만 최종 앱에 포함되는 framework에는 남지 않았습니다.

반면 `ClangModules`처럼 임의로 만든 디렉터리는 framework와 함께 앱에 복사되었습니다. Clang Module의 헤더와 Module Map도 별도 디렉터리를 만들지 않고 표준 `Modules` 아래에 둔 이유입니다.

이번 예제에서 확인한 크기는 다음과 같습니다.

```text
ExternalDependenciesSDK                         22 MB
device Framework의 Modules                     1.2 MB
simulator Framework의 Modules                  2.3 MB
Archive 앱의 ExternalDependencies.framework    6.0 MB
```

Archive 앱의 framework에는 `Modules`와 `Metadata`가 남지 않았습니다. dSYM에는 디버깅을 위해 일부 interface가 기록될 수 있지만 배포되는 앱 바이너리에는 포함되지 않습니다.

## 표준 XCFramework와 다른 점

Apple이 설명하는 XCFramework는 하나의 모듈을 여러 플랫폼과 아키텍처에 배포하기 위한 형식입니다. 여러 Swift 모듈의 interface를 하나의 framework에 넣는 기능을 제공하는 것은 아닙니다.

이번 구조는 다음 규칙을 직접 관리하는 커스텀 SDK에 가깝습니다.

- 여러 모듈의 구현은 하나의 Dynamic Framework에 포함한다.
- 각 모듈의 interface는 Framework의 `Modules`에서 제공한다.
- 사용하는 쪽은 원본 SPM 패키지를 함께 링크하지 않는다.
- 외부 패키지 버전이 바뀌면 SDK 전체를 다시 만든다.
- XCFramework에 서명한다면 모든 파일을 구성한 후 마지막에 서명한다.

원본 SPM 의존성과 이 SDK를 동시에 연결하면 같은 구현이 중복될 수 있습니다. 또한 의존성이 런타임 리소스를 사용한다면 바이너리뿐 아니라 리소스 배포 방식도 별도로 설계해야 합니다.

따라서 범용 XCFramework 기능으로 보기보다, 외부 의존성을 한곳에서 빌드하고 배포하기 위해 팀이 관리하는 SDK 레이아웃으로 보는 것이 적절합니다.

## 검증한 범위

이번 예제에서는 다음 항목을 확인했습니다.

- iOS 디바이스와 Simulator용 XCFramework 생성
- 원본 SPM 패키지 없이 `import RxSwift`, `import RxCocoa`, `import Alamofire` 컴파일
- RxCocoa가 요구하는 Clang Module 로딩
- App, Dynamic Framework, Static Library로 구성된 Tuist 프로젝트 빌드
- Simulator에서 Dynamic Framework 로딩 및 실행
- 디바이스 Release Archive
- 외부 의존성용 Dynamic Framework가 `ExternalDependencies.framework` 하나만 포함되는지 확인
- Archive 앱의 framework에서 컴파일용 `Modules`가 제거되는지 확인

## 정리

변경이 적고 빌드 비용이 큰 외부 의존성은 미리 빌드한 SDK로 관리할 수 있습니다. 구현을 하나의 Dynamic Framework에 묶고 각 라이브러리의 모듈 인터페이스를 함께 제공하면 기존 import도 유지할 수 있습니다.

중요한 것은 XCFramework를 만드는 명령 자체보다 바이너리, Swift interface, Clang Module 사이의 관계를 맞추는 일입니다. 그리고 일반 Build에서 끝내지 않고 여러 타깃 구조와 Archive에서 같은 방식으로 동작하는지 확인해야 합니다.

## 참고

- [Creating a multiplatform binary framework bundle](https://developer.apple.com/documentation/xcode/creating-a-multi-platform-binary-framework-bundle)
- [Distribute binary frameworks as Swift packages](https://developer.apple.com/videos/play/wwdc2020/10147/)
- [Tuist Settings](https://docs.tuist.dev/en/references/project-description/structs/settings)

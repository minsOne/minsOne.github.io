---
layout: post
title: "[Swift 5.9+][SE-0386] 새로운 Access Modifier인 Package를 Xcode Project에서 사용하기"
tags: [access modifier, package, xcode, swift]
---
{% include JB/setup %}

Swift 5.9에서 Swift Package에 새로운 접근 제어자 `Package`가 추가됐습니다. [SE-0386](https://github.com/apple/swift-evolution/blob/main/proposals/0386-package-access-modifier.md)

`Package` 접근 제어자는 특정 도메인이나 역할을 가진 모듈만 접근할 수 있게 해, 유용할 것입니다.

그러나 Swift Package가 아닌 Xcode Project로 구축된 프로젝트라면, 구축된 프로젝트는 새 접근 제어자 `Package`를 사용할 수 없어 아쉽습니다.

Xcode Project로 구축된 프로젝트에서도 `Package` 접근 제어자를 사용할 수 있다면 어떨까요?

## SE-0386

[SE-0386](https://github.com/apple/swift-evolution/blob/main/proposals/0386-package-access-modifier.md) 제안서는 패키지 경계를 정의해 빌드 시스템이 `-package-name` 플래그로 패키지명을 받도록 합니다.

즉, Swift Package는 이 옵션을 빌드 시스템에 전달해 `Package` 접근 제어자 사용을 가능하게 합니다.

간단한 Swift Package를 만들어 Package.swift에 `packageAccess` 옵션을 추가하고, 빌드해 `-package-name` 플래그를 전달하는지 확인해봅시다.

```swift
// Package.swift
import PackageDescription

let package = Package(
    name: "MyLibrary",
    products: [
        .library(
            name: "MyLibrary",
            targets: ["MyLibrary"]),
    ],
    targets: [
        .target(
            name: "MyLibrary",
            packageAccess: true),
    ]
)
```

```
$ swift build --verbose
Planning build
Building for debugging...
Write auxiliary file /MyLibrary/.build/arm64-apple-macosx/debug/swift-version-4987FB7F52197B0.txt
/Applications/Xcode-15.3.0-Beta.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc -module-name MyLibrary -emit-dependencies -emit-module -emit-module-path /MyLibrary/.build/arm64-apple-macosx/debug/MyLibrary.swiftmodule -output-file-map /MyLibrary/.build/arm64-apple-macosx/debug/MyLibrary.build/output-file-map.json -parse-as-library -incremental -c @/MyLibrary/.build/arm64-apple-macosx/debug/MyLibrary.build/sources -I /MyLibrary/.build/arm64-apple-macosx/debug -target arm64-apple-macosx10.13 -swift-version 5 -v -enable-batch-mode -index-store-path /MyLibrary/.build/arm64-apple-macosx/debug/index/store -Onone -enable-testing -j8 -DSWIFT_PACKAGE -DDEBUG -module-cache-path /MyLibrary/.build/arm64-apple-macosx/debug/ModuleCache -parseable-output -parse-as-library -emit-objc-header -emit-objc-header-path /MyLibrary/.build/arm64-apple-macosx/debug/MyLibrary.build/MyLibrary-Swift.h -color-diagnostics -sdk /Applications/Xcode-15.3.0-Beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX14.4.sdk -F /Applications/Xcode-15.3.0-Beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks -I /Applications/Xcode-15.3.0-Beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/usr/lib -L /Applications/Xcode-15.3.0-Beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/usr/lib -g -Xcc -isysroot -Xcc /Applications/Xcode-15.3.0-Beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX14.4.sdk -Xcc -F -Xcc /Applications/Xcode-15.3.0-Beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks -Xcc -fPIC -Xcc -g -package-name mylibrary
Apple Swift version 5.10 (swiftlang-5.10.0.10.5 clang-1500.3.7.4)
Target: arm64-apple-macosx10.13
Build complete! (0.20s)
```

로그를 확인해보니, `-package-name mylibrary` 옵션을 전달한 것을 알 수 있었습니다.

그렇다면, Xcode Project에서 `-package-name` 옵션을 추가하면 `Package` 접근 제어자를 사용할 수 있을까요?

## Xcode Project

다음 의존관계를 가진 프로젝트를 구축합니다.

<div class="mermaid" style="display:flex;justify-content:center;"> 
graph LR;
    Application-->FeatureA-->FeatureB;
</div><br/>

<p style="text-align:center;"><img src="{{ site.prod_url }}/image/2024/02/01.png"/></p><br/>

FeatureA의 Package Name을 Alpha로, FeatureB의 Package Name을 Beta로 설정할 것입니다.

각 모듈의 Package Name을 설정하려면 Build Settings의 `OTHER_SWIFT_FLAGS`에 `-package-name` 옵션을 추가합니다.

<p style="text-align:center;"><img src="{{ site.prod_url }}/image/2024/02/02.png"/></p><br/>

```
// Module: FeatureA
OTHER_SWIFT_FLAGS = $(inherited) -package-name Alpha

// Module: FeatureB
OTHER_SWIFT_FLAGS = $(inherited) -package-name Beta
```

FeatureA에는 SampleAlpha 클래스, FeatureB에는 SampleBeta 클래스가 있으며, 두 클래스 모두에 `package` 접근 제어자를 적용합니다.

```swift
// Module: FeatureA
// FileName: SampleAlpha.swift

import Foundation

package class SampleAlpha {
    package init() {
        print("init \(Self.self)")
    }

    package func sampleFunc() {
        print("call \(#function)")
    }
}


// Module: FeatureB
// FileName: SampleBeta.swift

import Foundation

package class SampleBeta {
    package init() {
        print("init \(Self.self)")
    }

    package func sampleFunc() {
        print("call \(#function)")
    }
}
```

Application이 Package Name을 아직 설정하지 않았으므로, `SampleAlpha`와 `SampleBeta` 클래스에 접근할 수 없습니다.

<p style="text-align:center;"><img src="{{ site.prod_url }}/image/2024/02/03.png"/></p><br/>

Application의 Package Name을 `Beta`로 설정하기 위해 Build Settings의 `OTHER_SWIFT_FLAGS`에 `-package-name Beta` 옵션을 추가합니다.

```
// Application
OTHER_SWIFT_FLAGS = $(inherited) -package-name Beta
```

<p style="text-align:center;"><img src="{{ site.prod_url }}/image/2024/02/04.png"/></p><br/>

이렇게 하면 Application에서 FeatureB의 `SampleBeta` 클래스에는 접근할 수 있으나, FeatureA의 `SampleAlpha` 클래스에는 접근할 수 없습니다.

<p style="text-align:center;"><img src="{{ site.prod_url }}/image/2024/02/05.png"/></p><br/>

Application의 Package Name을 `Alpha`로 설정하면, `SampleAlpha` 클래스에는 접근할 수 있으나, `SampleBeta` 클래스에는 접근할 수 없습니다.

<p style="text-align:center;"><img src="{{ site.prod_url }}/image/2024/02/06.png"/></p><br/>

Xcode Project의 `OTHER_SWIFT_FLAGS`에 `-package-name` 옵션을 추가해 Swift Package에서 Package 접근 제어자 사용을 가능하게 했습니다.

---

위 코드의 샘플은 [여기](https://github.com/minsOne/Experiment-Repo/tree/master/20240207)에서 확인하실 수 있습니다.

## 정리

* `Package` 접근 제어자를 이용하면 동일한 도메인이나 역할을 가진 모듈만 접근 가능합니다.
* OTHER_SWIFT_FLAGS에 `-package-name` 옵션을 추가해 Package Name을 설정할 수 있습니다.

## 참고자료

* [Swift Evolution - SE-0386](https://github.com/apple/swift-evolution/blob/main/proposals/0386-package-access-modifier.md)
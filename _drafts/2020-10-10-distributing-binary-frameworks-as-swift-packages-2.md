---
layout: post
title: "[Swift 5.3+][SwiftPM] Binary Framework(XCFramework)를 Swift Package로 배포하기(2) - App에서 Binary Framework 사용하기"
description: ""
category: "programming"
tags: [Swift, SwiftPM, SPM, Package, XCFramework, Binary Framework, xcodebuild, archive]
---
{% include JB/setup %}

이전 글에서 XCFramework를 만드는 법, 그리고 Swift Package 에서 Binary Framework를 연결하는 방법을 설명하였습니다. 

이번 글에서는 Swift Package에 연결된 Binary Framework를 App에 연결하는 방법을 설명해보려고 합니다.

그리고 Binary Framework는 Static Library, Dynamic Library로 배포할 수 있어, 이 타입이 앱이 만들어질 때 어떤 영향이 있는지 여러 경우를 나눠서 분석하려고 합니다.

## Binary Target을 의존하는 Library를 사용하는 경우

SamplePackage를 다시 한번 살펴봅시다.

<p style="text-align:center;">
<img src="{{ site.development_url }}/image/2020/10/20201015_01.png" style="width: 600px"/>
</p><br/>

Binary Target을 의존하는 Library라는 말은 `SamplePackage`를 의미하며, SamplePackage는 `sample.xcframework`를 의존하고 있습니다. 

다음으로 XCFramework는 아키텍처에 따라 나눠서 Framework를 구분, 관리합니다. 아키텍처에 따라 나뉜다고 하더라도 Mach-O 타입까지 구분된 것은 아닙니다. 

그렇기 때문에 Static, Dynamic이 어떻게 영향을 미치는지 분석합니다.

### XCFramework가 Static Library인 경우

XCFramework를 Static Library로 만들고, 기존 sample.xcframework를 새로 만든 XCFramework로 교체합니다.

```
# Archive 하기
$ xcodebuild archive -scheme sample -archivePath "./build/ios.xcarchive" -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES MACH_O_TYPE=staticlib
xcodebuild archive -scheme sample -archivePath "./build/ios_sim.xcarchive" -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES MACH_O_TYPE=staticlib
xcodebuild archive -scheme sample -archivePath "./build/mac.xcarchive" -sdk macosx10.15 SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES MACH_O_TYPE=staticlib

# XCFramework 생성
$ xcodebuild -create-xcframework \
-framework "./build/ios.xcarchive/Products/Library/Frameworks/sample.framework" \
-framework "./build/ios_sim.xcarchive/Products/Library/Frameworks/sample.framework" \
-framework "./build/mac.xcarchive/Products/Library/Frameworks/sample.framework" \
-output "./build/sample.xcframework"
```

다음으로 App 프로젝트를 만들고, SamplePackage 폴더를 드래그 해서 추가합니다.

<p style="text-align:center;">
<img src="{{ site.development_url }}/image/2020/10/20201015_02.png" style="width: 600px"/>
</p><br/>

앱 타겟에서 SamplePackage 라이브러리를 추가합니다.

<p style="text-align:center;">
<img src="{{ site.development_url }}/image/2020/10/20201015_03.png" style="width: 600px"/>
</p><br/>

다음으로 AppDelegate에서 SamplePackage의 helloworld 함수의 결과를 출력하는 코드를 추가합니다.

```
/// FileName: AppDelegate.swift
import UIKit
import SamplePackage

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    print(SamplePackage.helloworld())
    return true
  }
}
```

빌드하여 정상적으로 출력되는지 확인합니다. 아마 시뮬레이터로는 빌드가 잘 되지만, 기기로 빌드하는 경우는 안될 수 있습니다.

다음으로, 테스트 코드에서도 helloworld 함수의 결과가 제대로 나오는지 확인합니다.

```
/// FileName: SampleAppTests.swift
import XCTest
import SamplePackage
@testable import SampleApp

class SampleAppTests: XCTestCase {
  func test_helloworld() throws {
    XCTAssertEqual(SamplePackage.helloworld(), "Hello World on Sample Framework")
  }
}
```

여기까지 잘 진행되었다면, Archive를 하여 App의 구조를 분석해봅시다.

### XCFramework가 Dynamic Library인 경우

## Binary Target을 직접 사용하는 경우
<!--

Swift 5.3에서 여러 개의 XCFramework를 포함하는 Swift Package를 만들어서 배포할 수 있게 되었습니다. 즉, 소스가 공개되지 않은 3rd Party 라이브러리를 어떻게 잘 해서 Swift Package로 배포할 수 있다는 이야기입니다.

XCFramework 관련해서 [이전 글]({{  site.production_url }}/ios/mac/ios-wwdc-2019-binary-frameworks-in-swift-little-summary-and-translate)에서 참고하시면 좋습니다.

대부분의 3rd Party 라이브러리는 Static Library, 또는 Dynamic Library로 배포합니다. 만약에 Mach-O 타입인 Static, Dynamic을 모른다면 먼저 공부하고 이 글을 보시는 것을 추천드립니다.

이 글은 XCFramework를 만들어서 Swift Package로 만들어 사용하는 방법, App에서 사용하는 경우, 프레임워크에서 사용하는 경우 등 여러 경우를 나눠서 분석하려고 합니다. 

그 중 첫번째로 XCFramework를 만들어서 Swift Package로 만드는 방법을 설명하려고 합니다.

## Swift Package에서 XCFramework 사용하기

### XCFramework 만들기

첫번째로, Framework 프로젝트를 생성합니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2020/10/20201010_01.png" style="width: 600px"/>
</p><br/>

그리고 문자열 `"Hello World on Sample Framework"`를 반환하는 함수를 만들고, 추가로 a1 부터 a100 이름을 가진 Dummy 함수를 만듭니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2020/10/20201010_02.png" style="width: 600px"/>
</p><br/>

다음으로, 해당 프로젝트의 경로로 터미널을 열어 iPhoneOS, iPhoneSimulator SDK으로 각각 아카이브 파일을 만들고 XCFramework를 생성합니다.

```
# Archive 하기
$ xcodebuild archive -scheme sample -archivePath "./build/ios.xcarchive" -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
xcodebuild archive -scheme sample -archivePath "./build/ios_sim.xcarchive" -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
xcodebuild archive -scheme sample -archivePath "./build/mac.xcarchive" -sdk macosx10.15 SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# XCFramework 생성
$ xcodebuild -create-xcframework \
-framework "./build/ios.xcarchive/Products/Library/Frameworks/sample.framework" \
-framework "./build/ios_sim.xcarchive/Products/Library/Frameworks/sample.framework" \
-framework "./build/mac.xcarchive/Products/Library/Frameworks/sample.framework" \
-output "./build/sample.xcframework"
```

다음과 같이 XCFramework가 만들어졌습니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2020/10/20201010_03.png" style="width: 600px"/>
</p><br/>

### Swift Package에서 XCFramework 사용하기

명령어로 Swift Package를 만들어봅시다.

```
$ mkdir SamplePackage
$ mkdir -p SamplePackage/BinaryFramework
$ cp -r build/sample.xcframework SamplePackage/BinaryFramework
$ cd SamplePackage
$ swift package init --type library
```

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2020/10/20201010_04.png" style="width: 600px"/>
</p><br/>

다음으로 위에서 만들었던 `sample.xcframework`를 SamplePackage에서 binaryTarget으로 추가할 수 있습니다. 이 기능은 Swift 5.3부터 Binary Framework인 XCFramework를 묶을 수 있습니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2020/10/20201010_05.png" style="width: 600px"/>
</p><br/>

다음으로, `SamplePackage.swift` 로 이동하여 sample 프레임워크의 helloworld 함수의 결과를 반환하는 코드를 작성합니다. 그리고 b1 ~ b100 이름을 가진 Dummy 함수를 작성합니다.

```
import sample

public func helloworld() -> String {
  sample.helloworld()
}

public func b1() {}
public func b2() {}
...
public func b100() {}
```

다음으로 `SamplePackageTests.swift`으로 이동하여 SamplePackage의 helloworld 함수가 반환하는 문자열이 sample 프레임워크에서 반환하는 문자열과 일치하는지 확인합니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2020/10/20201010_06.png" style="width: 600px"/>
</p><br/>

테스트 코드가 성공하였으므로 Swift Package에서 XCFramework 연결하는 것이 가능함을 확인하였습니다.

이어서 다양한 경우를 설명하도록 하겠습니다.

## 참고자료

* Apple Document
  * [Distributing Binary Frameworks as Swift Packages](https://developer.apple.com/documentation/swift_packages/distributing_binary_frameworks_as_swift_packages)

-->
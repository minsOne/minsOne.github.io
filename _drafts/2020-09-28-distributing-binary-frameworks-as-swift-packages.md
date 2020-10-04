---
layout: post
title: "Distributing Binary Frameworks as Swift Packages"
description: ""
category: ""
tags: []
---
{% include JB/setup %}

Swift 5.3에서 여러 개의 XCFramework를 포함하는 Swift Package를 만들어서 배포할 수 있게 되었습니다. 즉, 소스가 공개되지 않은 3rd Party 라이브러리를 어떻게 잘 해서 Swift Package로 배포할 수 있다는 이야기입니다.

XCFramework 관련해서 [이전 글]({{site.production_url/ios/mac/ios-wwdc-2019-binary-frameworks-in-swift-little-summary-and-translate}})에서 참고하시면 좋습니다.

대부분의 3rd Party 라이브러리는 Static 라이브러리, 일부만 Dynamic Framework로 배포합니다. 만약에 Mach-O 타입인 Static, Dynamic을 모른다면 먼저 공부하고 이 글을 보시는 것을 추천드립니다.

## Swift Package에서 XCFramework 사용하기

### XCFramework 만들기

첫번째로, Framework 프로젝트를 생성합니다.

<p style="text-align:center;">
<img src="{{ site.development_url }}/image/2020/10/20201004_01.png" style="width: 600px"/>
</p><br/>

그리고 함수 하나를 만듭니다.

<p style="text-align:center;">
<img src="{{ site.development_url }}/image/2020/10/20201004_02.png" style="width: 600px"/>
</p><br/>

다음으로, 해당 프로젝트의 경로로 터미널을 열어 iPhoneOS, iPhoneSimulator SDK으로 각각 아카이브 파일을 만들고 XCFramework를 생성합니다.

```
# Archive 하기
$ xcodebuild archive -scheme sample -archivePath "./build/ios.xcarchive" -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
$ xcodebuild archive -scheme sample -archivePath "./build/ios_sim.xcarchive" -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# XCFramework 생성
$ xcodebuild -create-xcframework \
-framework "./build/ios.xcarchive/Products/Library/Frameworks/sample.framework" \
-framework "./build/ios_sim.xcarchive/Products/Library/Frameworks/sample.framework" \
-output "./build/sample.xcframework"
```

다음과 같이 XCFramework가 만들어졌습니다.

<p style="text-align:center;">
<img src="{{ site.development_url }}/image/2020/10/20201004_03.png" style="width: 600px"/>
</p><br/>

### Swift Package에서 XCFramework 사용하기

명령어로 Swift Package를 만들어봅시다.

```
$ mkdir SamplePackage
$ cd SamplePackage
$ swift package init --type library
```

<p style="text-align:center;">
<img src="{{ site.development_url }}/image/2020/10/20201004_04.png" style="width: 600px"/>
</p><br/>



---
layout: post
title: "[iOS][Xcode] Framework Part 1 : Static Framework와 Dynamic Framework"
description: ""
category: "iOS/Mac"
tags: [Xcode, static, dynamic, framework, lipo, nm, file, strings]
---
{% include JB/setup %}

# 서론

Xcode에서는 Framework 라는 것을 통해 모듈화 단위의 코드 및 리소스를 사용할 수 있습니다. 그리고 외부 소스를 가져다 사용할 때 Cocoapods, Carthage 같은 도구를 사용하거나 혹은 직접 git submodule을 이용하기도 합니다.

하지만 소스를 쉽게 사용하는 것 이상으로 많이 살펴보질 않았습니다. 어떻게 Framework가 구성이 되어 있고, 어떻게 동작을 하고, Static Framework와 Dynamic Framework가 어떤 차이인질 말이죠. 그리고 전체적인 개발 방식도 바꿀 수 있는 것도 알진 못했습니다.

특히나, 대규모 프로젝트를 경험하고 그것에 발표하는 자료가 조금씩 많이 나오고 있는데, 그 중에는 디테일 같은 것이 아닌 어떻게 큰 그림을 그려 프로젝트를 꾸려 나가고 있는지를 이야기 하는 것이 종종 있습니다. 

예를 들어, SwiftUI 처럼 UI를 가져다 사용할 수 있게 하여 빠르게 개발하고 디자인의 통일을 한다던지, Build 시스템을 어떻게 개선하고 있고 어떤 것을 사용해서 기존보다 빠른 CI/CD 주기를 만들 수 있었는가, 또는 아키텍처에 대한 고민을 엿볼 수 있는 것들이죠.

저는 최근 NSSpain 2019의 [Journey to Buck build system at Booking.com](https://vimeo.com/362205579)에서 발표를 관심있게 살펴보았습니다. 여기에서 흥미롭게 살펴본 점은 Buck 이 아니라 32분쯤에 나오는 local build의 부분이었습니다. Incremental Build 부분이 몇 초로 끝난다는 부분인 것입니다. 현재 개발중인 프로젝트에서는 Incremental Build가 몇초로 끝나지 않고 몇분으로 하기 때문에 아주 개발이 힘듭니다. 몇초니깐 max 10초로 잡고, 보통 신형 아이맥 최고 사양으로 해서 3분 정도 끝나니깐 180초, 그러므로 18배나 빠른 개발 효율을 보여줍니다. 한번 정도이므로 매번 수정사항을 살피고 맞는지 검토하고 테스트 코드 돌리고 하는 것 까지 생각해보면 그 차이는 어마어마하게 발생하고 여러번 한다면 시간 차이는 벌어집니다.

그래서 해당 영상을 좀 더 살펴보았습니다. 31분 쯤에 나오는 모듈의 수를 본 것이죠. 과거에는 15개의 Module 에서 130+개의 모듈이 만들어진 것을 확인할 수 있습니다. 저는 이 부분이 몇 초만에 Incremental Build가 되는 핵심이라고 생각하게 되었습니다. 하지만 130+개 모듈을 Framework로 어떻게 관리해야 할까 고민이 됩니다. 이 부분에 있어 Static Framework와 Dynamic Framework의 적절한 조합을 이용할 수 있다고 결론을 내렸습니다. 그렇다면 Static Framework와 Dynamic Framework을 알기 위해선 Framework를 먼저 알아봅시다.

# Framework

Framework는 Dynamic shared Library, Nib 파일, 이미지 파일, 다국어 문자, 헤더 파일, 레퍼런스 문서과 같이 공유 리소스를 패키지로 캡슐화 하는 계층 구조 파일 디렉토리를 말합니다. 그리고 Framework도 Bundle이며 NSBundle로 접근이 가능합니다. 또한 리소스 사본은 프로세스 수에 상관없이 항상 물리적으로 메모리에 상주하며 리소스 공유로 풋 프린트를 줄이고 성능을 향상 시킵니다.

Framework는 다음과 같은 기본 구조를 가집니다.

```
# /Library/Frameworks/iTunesLibrary.framework 예시
.
├── Resources -> Versions/Current/Resources
├── Versions
│   ├── A
│   │   ├── Resources
│   │   │   ├── BridgeSupport
│   │   │   │   └── iTunesLibrary.bridgesupport
│   │   │   ├── Info.plist
│   │   │   ├── framework.sb
│   │   │   └── version.plist
│   │   ├── _CodeSignature
│   │   │   └── CodeResources
│   │   └── iTunesLibrary
│   └── Current -> A
└── iTunesLibrary -> Versions/Current/iTunesLibrary
```

# Dynamic Framework

<p style="text-align:center;"><img src="/../../../../image/2019/10/1.png" style="width: 600px"/></p><br/>

Xcode에서 Framework를 만들면 기본적으로 Dynamic Framework으로 만들어집니다. Dynamic Framework는 동시에 여러 프레임워크 또는 프로그램에서 동일한 코드 사본을 공유하고 사용을 하므로, 메모리를 효율적으로 사용합니다. 동적으로 연결되어 있으므로, 전체 빌드를 다시 하지 않아도 새로운 프레임워크 사용이 가능합니다. 

Static Linker를 통해 `Dynamic Library Reference`가 어플리케이션 코드에 들어가고 모듈 호출시 Stack에 있는 Library에 접근하여 사용합니다.

또한, 여러 버전의 library가 존재할 수 있기 때문에 다음과 같이 symbolic links를 구성하기도 합니다.

<p style="text-align:center;"><img src="/../../../../image/2019/10/3.png" style="width: 300px"/></p><br/>

# Static Framework

<p style="text-align:center;"><img src="/../../../../image/2019/10/2.png" style="width: 600px"/></p><br/>

Static Framework는 Static Linker를 통해 Static Library 코드가 어플리케이션 코드 내로 들어가 Heap 메모리에 상주합니다. 따라서 Static Library가 복사되므로, Static Framework를 여러 Framework에서 사용하게 되면 코드 중복이 발생하게 됩니다.

Library는 Framework가 아니라 Static Library가 복사된 곳 위치하므로, Bundle의 위치는 Static Framework가 아닌 Static Library가 위치해 있는 곳이 됩니다. 때문에 번들을 접근할 때는 스스로가 접근하는 것 보단 외부에서 **Bundle의 위치를 주입**받는 것이 좋습니다.

# 어떤 Mach-O 타입을 선택해야 할까?

**일반적으로** 리소스를 스스로 가지고 있거나 전체 소스를 제공하는 경우 Dynamic Framework를, 그렇지 않고 SDK 형태로 배포하는 경우는 Static Framework를 선택합니다.

# Framework 관련 명령어

* file : file 명령어를 이용하여 Dynamic Framework 또는 Static Framework인지 구분이 가능합니다.

```
# Dynamic Framework
$ file RxSwift.framework/RxSwift

RxSwift.framework/RxSwift: Mach-O universal binary with 4 architectures: [i386:Mach-O dynamically linked shared library i386] [x86_64] [arm_v7] [arm64]
RxSwift.framework/RxSwift (for architecture i386):	Mach-O dynamically linked shared library i386
RxSwift.framework/RxSwift (for architecture x86_64):	Mach-O 64-bit dynamically linked shared library x86_64
RxSwift.framework/RxSwift (for architecture armv7):	Mach-O dynamically linked shared library arm_v7
RxSwift.framework/RxSwift (for architecture arm64):	Mach-O 64-bit dynamically linked shared library arm64

# Static Framework
$ file Firebase.framework/Firebase
Firebase.framework/Firebase: Mach-O universal binary with 4 architectures: [i386:Mach-O object i386] [x86_64:Mach-O 64-bit object x86_64] [arm_v7:Mach-O object arm_v7] [arm64:Mach-O 64-bit object arm64]
Firebase.framework/Firebase (for architecture i386):	Mach-O object i386
Firebase.framework/Firebase (for architecture x86_64):	Mach-O 64-bit object x86_64
Firebase.framework/Firebase (for architecture armv7):	Mach-O object arm_v7
Firebase.framework/Firebase (for architecture arm64):	Mach-O 64-bit object arm64
```

* dwarfdump : dwarfdump 명령어를 이용하여 Dynamic Framework이면 uuid를 얻을 수 있습니다.

```
# Dynamic Framework
$ dwarfdump --uuid RxSwift.framework/RxSwift
UUID: 3510A8FF-F219-31D8-B602-A2C13F9BB820 (i386) RxSwift.framework/RxSwift
UUID: 255E3296-E02A-30F1-B175-CC5EADD87A50 (x86_64) RxSwift.framework/RxSwift
UUID: A9EAFFC9-EDC7-3D4D-9067-E46EE4CA632F (armv7) RxSwift.framework/RxSwift
UUID: 02E2617C-E350-391F-A346-2F0E824C70D9 (arm64) RxSwift.framework/RxSwift

# Static Framework
$ dwarfdump --uuid Firebase.framework/Firebase
# 출력결과 없음
```

* strings : strings 명령어를 이용하여 문자열 추출이 가능합니다. 해당 프레임워크의 코드가 어떤 것이 들어가있는지 일부 추론이 가능합니다.

```
$ strings RxSwift.framework/RxSwift
init
lock
unlock
isMainThread
dealloc
currentThread
threadDictionary
setObject:forKeyedSubscript:
hash
copyWithZone:
.cxx_destruct

...

```

* nm : 오브젝트 파일에 포함된 Symbol 목록을 출력할 수 있습니다.

```
$ nm RxSwift.framework/RxSwift
00000000000c06dc S _$s10DisposeKey7RxSwift27SynchronizedUnsubscribeTypePTl
                 U _$s10Foundation4DateV13distantFutureACvgZ
                 U _$s10Foundation4DateV17timeIntervalSinceySdACF
                 U _$s10Foundation4DateV18addingTimeIntervalyACSdF
                 U _$s10Foundation4DateV19_bridgeToObjectiveCSo6NSDateCyF
0000000000047740 T _$s10Foundation4DateV7RxSwiftE22addingDispatchIntervalyAC0F00f4TimeG0OF
                 U _$s10Foundation4DateV7compareySo18NSComparisonResultVACF
000000000000abc0 t _$s10Foundation4DateV9eventTime_7RxSwift5EventOy7ElementAE12ObserverTypePQzG0C0tAeIRzlWOh
000000000000aef0 t _$s10Foundation4DateV9eventTime_7RxSwift5EventOy7ElementAE12ObserverTypePQzG0C0tSgAeIRzlWOh
                 U _$s10Foundation4DateVACycfC
                 U _$s10Foundation4DateVMa
000000000009d680 t _$s10Foundation4DateVSgWOb
000000000000af70 t _$s10Foundation4DateVSgWOc
000000000009d5b0 t _$s10Foundation4DateVSgWOd
000000000000aff0 t _$s10Foundation4DateVSgWOh
00000000000b7228 S _$s12ReactiveBase7RxSwift0A10CompatiblePTl
00000000000b9920 S _$s15VirtualTimeUnit7RxSwift0aB13ConverterTypePTl
                 U _$s18IntegerLiteralTypes013ExpressibleByaB0PTl
00000000000b9928 S _$s23VirtualTimeIntervalUnit7RxSwift0aB13ConverterTypePTl

...

```

* lipo : 유니버셜 프레임워크로 만들어주는 명령어로, 특정 아키텍처를 제거 또는 통합 등의 작업을 할 수 있습니다.


# 참조
* [Apple Document - Framework Programming Guide / What is Frameworks?](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFrameworks/Concepts/WhatAreFrameworks.html#//apple_ref/doc/uid/20002303-BBCEIJFI)
* [Apple Document - Framework Programming Guide
/ Guidelines for Creating Frameworks](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFrameworks/Concepts/CreationGuidelines.html#//apple_ref/doc/uid/20002254-BAJHGGGA)
* [Apple Document - Framework Programming Guide / Frameworks and Binding](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFrameworks/Concepts/FrameworkBinding.html)
* [Apple Document - Mach-O Programming Topics / Building Mach-O Files](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/MachOTopics/1-Articles/building_files.html)
* [Apple Document - Dynamic Library Programming Topics / Overview of Dynamic Libraries](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/DynamicLibraries/100-Articles/OverviewOfDynamicLibraries.html)
* [Google - iOS Static Framework](https://code.google.com/archive/p/ios-static-framework/)
* [ModularFlowArchitecture](https://github.com/markjarecki/ModularFlowArchitecture)
* [Building a dynamic modular iOS architecture](https://medium.com/fluxom/building-a-dynamic-modular-ios-architecture-1b87dc31278b)
* [iOS Frameworks Part 1: A Treacherous Voyage Through Murky Waters](https://wundermanthompsonmobile.com/2016/05/ios-frameworks-part-1/)
* [Optimize your iOS projects creating binaries Frameworks](https://medium.com/@cristianarielbarril/optimize-your-ios-projects-creating-binaries-frameworks-f83cb848f59f)
* [Big Nerd Ranch - It Looks Like You Are Trying to Use a Framework](https://www.bignerdranch.com/blog/it-looks-like-you-are-trying-to-use-a-framework/)
* [iOS, iOS에서 프레임워크와 라이브러리의 차이점을 알아보자!](https://devmjun.github.io/archive/FrameworkVsLibrary)
* [Creating and Distributing an iOS Binary Framework](https://instabug.com/blog/ios-binary-framework/)
* [Resource Bundles & Static Library in iOS](https://medium.com/@09mejohn/resource-bundles-in-ios-static-library-beba3070fafd)
* [Deep dive into Swift frameworks](https://theswiftdev.com/2018/01/25/deep-dive-into-swift-frameworks/)

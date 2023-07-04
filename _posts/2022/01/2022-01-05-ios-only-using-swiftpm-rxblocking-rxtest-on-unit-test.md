---
layout: post
title: "[iOS][SwiftPM][Xcode 13.2.1+] SwiftPM로 RxSwift 사용할 때 RxBlocking, RxTest를 유닛테스트에서 사용하기 - 해결편(SwiftPM)"
description: ""
category: "iOS/Mac"
tags: [Swift, SwiftPM, SPM, Package, Framework, Library, Dynamic Framework, Static Library]
---
{% include JB/setup %}

[이전 글](../ios-swiftpm-rxblocking-rxtest-on-unit-test)에서는 모듈 중복 적재되는 문제를 코드 복사로 해결했습니다. 그러나 현재 Xcode 13.2.1 버전에서는 SwiftPM을 이용해 모듈 중복 적재 문제를 해결할 수 있게 되었습니다.

Xcode 13.0 버전을 사용해서 아래에 제시된 방법을 사용하는 것도 가능하지만, 조금 애매한 부분도 있어서 Xcode 13.2.1 이상 버전에서 작업하는 것을 추천드립니다

## SwiftPM을 이용하여 RxBlocking, RxTest를 유닛 테스트에서 사용하기

우선 이전 글에서 테스트 타겟이 RxBlocking, RxTest를 의존성 가지도록 작업하였을 때, 모듈이 중복해서 적재되어 경고가 발생하는 문제가 있었습니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/12/20211213_02.png"/></p>

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/12/20211213_04.png"/></p>

위에서 말한 모듈 중복 경고는 RxBlocking, RxTest가 RxSwift를 의존성으로 가지기 때문입니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/12/20211213_05.png"/></p>

유닛 테스트 모듈이 RxSwift를 의존성으로 가진다면 다음과 같은 구조가 됩니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2022/01/20220103_01.png"/></p>

유닛 테스트 모듈은 RxSwift, RxCocoa, RxRelay를 SwiftPM을 통해 직접 의존성으로 추가하였습니다.

아래 그림은 유닛 테스트 타겟의 Build Phase에서 SwiftPM으로 직접 추가된 RxSwift, RxCocoa, RxRelay, RxBlocking, RxTest, Nimble, RxNimble, Quick을 볼 수 있습니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2022/01/20220103_02.png"/></p>

또한, 테스트 소스 파일에서는 ThirdPartyLibraryManager와 함께 RxSwift, RxCocoa, RxRelay, RxBlocking, RxTest, Nimble, RxNimble, Quick을 import 해야 합니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2022/01/20220103_03.png"/></p>

테스트를 실행했을 때, RxSwift 모듈이 중복으로 적재되는 경고가 발생하지 않았음을 확인하였습니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2022/01/20220103_04.png"/></p>

## 그 이유는?

해당 문제가 이슈화된지는 오래되었습니다. 버그 리포트 [https://bugs.swift.org/browse/SR-12303](https://bugs.swift.org/browse/SR-12303)에도 이 문제에 대한 이슈가 올라왔으며, RxSwift 저장소의 오래된 [이슈](https://github.com/ReactiveX/RxSwift/issues/2127)이기도 했습니다. 또한, 트위터에서도 이 문제를 해결하기 위한 [대화](https://twitter.com/freak4pc/status/1233465169189228544?s=20)가 이루어졌습니다.

[Xcode 12.5 Release Note](https://developer.apple.com/documentation/xcode-release-notes/xcode-12_5-release-notes#Swift-Packages)에서는 Swift Package에 대한 업데이트가 포함되어 있습니다.

```
The Swift Package Manager now builds package products and targets as dynamic frameworks automatically, if doing so avoids duplication of library code at runtime. (59931771) (FB7608638)
```

`Dynamic Framework`를 사용해 라이브러리 중복 문제를 해결했다는 점을 언급합니다. 일반적으로 앱 타겟으로 빌드할 때는 중복된 라이브러리가 발생할 가능성이 적지만, 유닛테스트 타겟으로 빌드할 때는 RxSwift와 같은 라이브러리가 중복될 가능성이 있습니다.

이 문제를 어떻게 해결했는지 확인하기 위해 테스트를 빌드한 결과물을 확인해봅시다.

Xcode의 `Product > Show Build Folder in Finder` 를 실행하여 빌드 결과물을 확인합니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2022/01/20220103_05.png"/></p>

SampleApp 패키지의 PlugIns 폴더에는 `SampleAppTests.xctest` 라는 테스트 번들 파일이 존재합니다. 

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2022/01/20220103_06.png"/></p>

패키지의 내용을 확인하면 실행 바이너리와 프레임워크를 확인할 수 있습니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2022/01/20220103_07.png"/></p>

프레임워크 폴더에 `RxSwift.framework`, `RxRelay.framework`, `RxCocoa_38E61CAF42DDE0B6_PackageProduct.framework`가 있습니다. 일반적으로 SwiftPM으로 서드파티 라이브러리를 추가하면 Static Library로 추가되어 프레임워크를 만들 수 없지만, 이번에는 프레임워크가 만들어졌습니다.

SampleAppTests 바이너리에서 RxSwift, RxRelay, RxCocoa 프레임워크를 링킹하고 있는지 확인해봅시다.

```
# otool -L /Users/minsone/Library/Developer/Xcode/DerivedData/SampleApp-ffjppqknwwtddmbtzuojardnnpgy/Build/Products/Debug-iphonesimulator/SampleApp.app/PlugIns/SampleAppTests.xctest/SampleAppTests
/Users/minsone/Library/Developer/Xcode/DerivedData/SampleApp-ffjppqknwwtddmbtzuojardnnpgy/Build/Products/Debug-iphonesimulator/SampleApp.app/PlugIns/SampleAppTests.xctest/SampleAppTests:
	@rpath/XCTest.framework/XCTest (compatibility version 1.0.0, current version 19566.0.0)
	@rpath/RxSwift.framework/RxSwift (compatibility version 0.0.0, current version 0.0.0)
	@rpath/RxRelay.framework/RxRelay (compatibility version 0.0.0, current version 0.0.0)
	@rpath/RxCocoa_38E61CAF42DDE0B6_PackageProduct.framework/RxCocoa_38E61CAF42DDE0B6_PackageProduct (compatibility version 0.0.0, current version 0.0.0)
	@rpath/ThirdPartyLibraryManager.framework/ThirdPartyLibraryManager (compatibility version 1.0.0, current version 1.0.0)
	/System/Library/Frameworks/Foundation.framework/Foundation (compatibility version 300.0.0, current version 1856.105.0)
	/usr/lib/libobjc.A.dylib (compatibility version 1.0.0, current version 228.0.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1311.0.0)
	/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation (compatibility version 150.0.0, current version 1856.105.0)
	/usr/lib/swift/libswiftCore.dylib (compatibility version 1.0.0, current version 1300.0.46)
	/usr/lib/swift/libswiftCoreFoundation.dylib (compatibility version 1.0.0, current version 14.0.0, weak)
	/usr/lib/swift/libswiftCoreGraphics.dylib (compatibility version 1.0.0, current version 3.0.0, weak)
	/usr/lib/swift/libswiftCoreImage.dylib (compatibility version 1.0.0, current version 2.0.0, weak)
	/usr/lib/swift/libswiftDarwin.dylib (compatibility version 1.0.0, current version 0.0.0, weak)
	/usr/lib/swift/libswiftDataDetection.dylib (compatibility version 1.0.0, current version 697.1.0, weak)
	/usr/lib/swift/libswiftDispatch.dylib (compatibility version 1.0.0, current version 11.0.0)
	/usr/lib/swift/libswiftFileProvider.dylib (compatibility version 1.0.0, current version 378.62.1, weak)
	/usr/lib/swift/libswiftFoundation.dylib (compatibility version 1.0.0, current version 70.101.0)
	/usr/lib/swift/libswiftMetal.dylib (compatibility version 1.0.0, current version 258.14.0, weak)
	/usr/lib/swift/libswiftObjectiveC.dylib (compatibility version 1.0.0, current version 2.0.0)
	/usr/lib/swift/libswiftQuartzCore.dylib (compatibility version 1.0.0, current version 3.0.0, weak)
	/usr/lib/swift/libswiftUIKit.dylib (compatibility version 1.0.0, current version 5100.0.0, weak)
	/usr/lib/swift/libswiftWebKit.dylib (compatibility version 1.0.0, current version 612.3.6, weak)
	@rpath/libXCTestSwiftSupport.dylib (compatibility version 1.0.0, current version 1.0.0)
```

RxSwift, RxRelay, RxCocoa 프레임워크를 의존하고 있음을 확인할 수 있습니다. 

그럼 다시 생각해봅시다. ThirdPartyLibraryManager에서도 RxSwift, RxRelay, RxCocoa 라이브러리를 의존하고 있는데, 어떻게 모듈이 중복된다는 경고가 노출되지 않을까요?

SampleApp의 프레임워크 폴더에 있는 생성된 `ThirdPartyLibraryManager.framework` 를 확인해봅시다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2022/01/20220103_08.png"/></p>

ThirdPartyLibraryManager 프레임워크 내에 Frameworks 폴더가 생성되어 있고, RxSwift, RxRelay, RxCocoa 프레임워크가 포함되어 있음을 알 수 있습니다.

ThirdPartyLibraryManager 라이브러리가 RxSwift, RxRelay, RxCocoa 프레임워크를 링킹하고 있는지 확인해봅시다.

```
# otool -L /Users/minsone/Library/Developer/Xcode/DerivedData/SampleApp-ffjppqknwwtddmbtzuojardnnpgy/Build/Products/Debug-iphonesimulator/SampleApp.app/Frameworks/ThirdPartyLibraryManager.framework/ThirdPartyLibraryManager
/Users/minsone/Library/Developer/Xcode/DerivedData/SampleApp-ffjppqknwwtddmbtzuojardnnpgy/Build/Products/Debug-iphonesimulator/SampleApp.app/Frameworks/ThirdPartyLibraryManager.framework/ThirdPartyLibraryManager:
	@rpath/ThirdPartyLibraryManager.framework/ThirdPartyLibraryManager (compatibility version 1.0.0, current version 1.0.0)
	@rpath/RxSwift.framework/RxSwift (compatibility version 0.0.0, current version 0.0.0)
	@rpath/RxRelay.framework/RxRelay (compatibility version 0.0.0, current version 0.0.0)
	@rpath/RxCocoa_38E61CAF42DDE0B6_PackageProduct.framework/RxCocoa_38E61CAF42DDE0B6_PackageProduct (compatibility version 0.0.0, current version 0.0.0)
	/System/Library/Frameworks/Foundation.framework/Foundation (compatibility version 300.0.0, current version 1856.105.0)
	/usr/lib/libobjc.A.dylib (compatibility version 1.0.0, current version 228.0.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1311.0.0)
	/usr/lib/swift/libswiftCore.dylib (compatibility version 1.0.0, current version 1300.0.46)
	/usr/lib/swift/libswiftCoreFoundation.dylib (compatibility version 1.0.0, current version 14.0.0, weak)
	/usr/lib/swift/libswiftCoreGraphics.dylib (compatibility version 1.0.0, current version 3.0.0, weak)
	/usr/lib/swift/libswiftCoreImage.dylib (compatibility version 1.0.0, current version 2.0.0, weak)
	/usr/lib/swift/libswiftDarwin.dylib (compatibility version 1.0.0, current version 0.0.0, weak)
	/usr/lib/swift/libswiftDataDetection.dylib (compatibility version 1.0.0, current version 697.1.0, weak)
	/usr/lib/swift/libswiftDispatch.dylib (compatibility version 1.0.0, current version 11.0.0, weak)
	/usr/lib/swift/libswiftFileProvider.dylib (compatibility version 1.0.0, current version 378.62.1, weak)
	/usr/lib/swift/libswiftFoundation.dylib (compatibility version 1.0.0, current version 70.101.0, weak)
	/usr/lib/swift/libswiftMetal.dylib (compatibility version 1.0.0, current version 258.14.0, weak)
	/usr/lib/swift/libswiftObjectiveC.dylib (compatibility version 1.0.0, current version 2.0.0, weak)
	/usr/lib/swift/libswiftQuartzCore.dylib (compatibility version 1.0.0, current version 3.0.0, weak)
	/usr/lib/swift/libswiftUIKit.dylib (compatibility version 1.0.0, current version 5100.0.0, weak)
	/usr/lib/swift/libswiftWebKit.dylib (compatibility version 1.0.0, current version 612.3.6, weak)
```

마찬가지로 ThirdPartyLibraryManager 라이브러리는 RxSwift, RxRelay, RxCocoa 프레임워크를 링킹하고 있습니다.

그러면 테스트 번들에 있는 Rx 프레임워크 또는 ThirdPartyLibraryManager 프레임워크에 있는 Rx 프레임워크 중 어떤 프레임워크를 로드할까요?

그것을 확인하기 위해 Run일때 환경 변수 `DYLD_PRINT_LIBRARIES` 를 추가하여 테스트 번들을 실행시 어떤 프레임워크를 로드하는지 확인해보려고 합니다.(DYLD_PRINT_LIBRARIES 환경 변수 설명은 [Apple 문서](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/DynamicLibraries/100-Articles/LoggingDynamicLoaderEvents.html)에서 자세히 확인할 수 있음)

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2022/01/20220103_09.png"/></p>

테스트 코드를 실행하면 다음과 같이 로그가 출력됩니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2022/01/20220103_10.png"/></p>

출력된 로그 중 RxSwift, RxRelay, RxCocoa 프레임워크가 로드된 부분을 확인할 수 있습니다.

```
...

dyld[41367]: <ADD16376-712F-37D1-94E7-9330D03E461E> /Users/minsone/Library/Developer/Xcode/DerivedData/SampleApp-ffjppqknwwtddmbtzuojardnnpgy/Build/Products/Debug-iphonesimulator/PackageFrameworks/RxSwift.framework/RxSwift
dyld[41367]: <77F7D06F-9C71-3670-85C2-70732D79A429> /Users/minsone/Library/Developer/Xcode/DerivedData/SampleApp-ffjppqknwwtddmbtzuojardnnpgy/Build/Products/Debug-iphonesimulator/PackageFrameworks/RxRelay.framework/RxRelay
dyld[41367]: <83881B35-1FF3-30F5-89C8-F62881D34202> /Users/minsone/Library/Developer/Xcode/DerivedData/SampleApp-ffjppqknwwtddmbtzuojardnnpgy/Build/Products/Debug-iphonesimulator/PackageFrameworks/RxCocoa_38E61CAF42DDE0B6_PackageProduct.framework/RxCocoa_38E61CAF42DDE0B6_PackageProduct

...
```

우리가 생각했던 프레임워크 경로가 아닌 `Build/Products/Debug-iphonesimulator/PackageFrameworks`에 있는 Rx 프레임워크를 로드하는 것을 볼 수 있습니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2022/01/20220103_11.png"/></p>

이렇게 프레임워크를 로드하여 문제를 해결한 것으로 보입니다. 

**왜 이렇게 해결했는지는 레퍼런스를 찾지 못하였습니다. 추후 찾으면 업데이트 하겠습니다.**

<br/>

그리고 테스트 빌드시 Rx 프레임워크가 생성되었지만, 앱 타겟으로 빌드한다면 유닛 테스트 타겟과 라이브러리가 중복되지 않기 때문에 Static Library로 만들어 ThirdPartyLibraryManager 라이브러리에 복사되어 Rx 프레임워크가 생성되지 않습니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2022/01/20220103_12.png"/></p><br/>

위에서 해결했던 방법은 [Github 저장소](https://github.com/minsOne/Experiment-Repo/tree/master/20220103-SampleApp)에서 확인하실 수 있습니다.

## 정리

* 테스트 타겟에 SwiftPM으로 RxBlocking, RxTest를 추가할 때 RxSwift, RxRelay를 같이 추가하면 라이브러리 중복 로드 경고가 발생하지 않는다.

ps. 해결 방안을 알려주신 회사 동료인 이기대님께 감사드립니다.

## 참고

* [Xcode 12.5 Release Note](https://developer.apple.com/documentation/xcode-release-notes/xcode-12_5-release-notes)
* [Apple Document - Dynamic Library Programming Topics](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/DynamicLibraries/000-Introduction/Introduction.html#//apple_ref/doc/uid/TP40001908-SW1)
* [SR-SR-12303](https://bugs.swift.org/browse/SR-12303)

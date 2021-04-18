---
layout: post
title: "[iOS][Xcode] 3rd party 라이브러리 관리하기 - Static/Dynamic"
description: ""
category: ""
tags: []
---
{% include JB/setup %}

앱 개발하면서 많은 서드파티 라이브러리를 사용합니다. 오픈소스 기반 라이브러리도 있고, 업체에서 제공해주는 라이브러리도 있습니다. 이들 라이브러리는 Mach-O 타입이 Static Library 또는 Dynamic Library으로 되어 있습니다.

이 글에서 서드파티 라이브러리가 Static Library 일때, Dynamic Library 일때 어떻게 관리하면 좋을지를 설명하려고 합니다.

## 서드파티 라이브러리 관리 - Static Library

Static Library인 대표적인 서드파티 라이브러리는 Firebase Analytics가 있습니다. [Firebase SDK](https://github.com/firebase/firebase-ios-sdk)에서 Carthage.md 파일을 보시면 Carthage로 라이브러리를 내려받음을 알 수 있습니다. [FirebaseAnalyticsBinary.json](https://dl.google.com/dl/firebase/ios/carthage/FirebaseAnalyticsBinary.json)를 내려받으면 버전별로 FirebaseAnalytics Zip 파일 목록이 있는 것을 확인할 수 있습니다.

```
$ curl https://dl.google.com/dl/firebase/ios/carthage/FirebaseAnalyticsBinary.json
{
  "4.11.0": "https://dl.google.com/dl/firebase/ios/carthage/4.11.0/Analytics-2468c231ebeb7922.zip",
  "4.12.0": "https://dl.google.com/dl/firebase/ios/carthage/4.12.0/Analytics-bc8101d420b896c5.zip",
  "4.9.0": "https://dl.google.com/dl/firebase/ios/carthage/4.9.0/Analytics-d2b6a6b0242db786.zip",
  "5.0.0": "https://dl.google.com/dl/firebase/ios/carthage/5.0.0/Analytics-a72e54e6ee35a1da.zip",
  "5.0.1": "https://dl.google.com/dl/firebase/ios/carthage/5.0.1/Analytics-6f41f8b6a4a602b9.zip",
  "5.1.0": "https://dl.google.com/dl/firebase/ios/carthage/5.1.0/Analytics-52948f6ㅋ6a286d179.zip",

...

  "7.1.0": "https://dl.google.com/dl/firebase/ios/carthage/7.1.0/FirebaseAnalytics-6ff5be548eef1a14.zip",
  "7.3.0": "https://dl.google.com/dl/firebase/ios/carthage/7.3.0/FirebaseAnalytics-08224b8e737b268b.zip",
  "7.4.0": "https://dl.google.com/dl/firebase/ios/carthage/7.4.0/FirebaseAnalytics-b707977c5254fb87.zip"
}
```

zip 파일을 내려받고 압축을 풀면 FirebaseAnalytics 관련된 프레임워크를 얻을 수 있습니다. 이 프레임워크의 라이브러리 파일의 Mach-O를 확인하면 Static Library 임을 알 수 있습니다.

```
$ file FirebaseAnalytics/Firebase.framework/Firebase
FirebaseAnalytics/Firebase.framework/Firebase: Mach-O universal binary with 4 architectures: [i386:Mach-O object i386] [x86_64:Mach-O 64-bit object x86_64] [arm_v7:Mach-O object arm_v7] [arm64:Mach-O 64-bit object arm64]
FirebaseAnalytics/Firebase.framework/Firebase (for architecture i386):	Mach-O object i386
FirebaseAnalytics/Firebase.framework/Firebase (for architecture x86_64):	Mach-O 64-bit object x86_64
FirebaseAnalytics/Firebase.framework/Firebase (for architecture armv7):	Mach-O object arm_v7
FirebaseAnalytics/Firebase.framework/Firebase (for architecture arm64):	Mach-O 64-bit object arm64
```

Static Library는 Static Linker를 통해 코드가 복사됩니다.

<p style="text-align:center;"><img src="{{ site.production_url }}/image/2019/10/2.png" style="width: 600px"/></p>

이미지 출처 - [Apple Document](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/DynamicLibraries/100-Articles/OverviewOfDynamicLibraries.html)

그러면 이를 살짝 틀어보면 서드파티 라이브러리만을 담당하는 Dynamic Library를 만들면 되지 않을까요? Dynamic Library에 서드파티 라이브러리 코드가 모두 복사되었기 때문에, 우리가 사용하기 쉽게 레이어를 하나 두고 감싼다면 직접 접근하지 않아도 서드파티 라이브러리 기능들을 모두 사용할 수 있기 때문입니다.

이 방식은 이전에 설명한 [Swift Package Manager를 이용하여 패키지를 통합 관리하기]({{site.production_url}}/ios/mac/swift-package-manager-proxy-modular) 라는 글에서도 설명하였던 방식입니다.

따라서 `ManageVenderStaticLibrary` 라이브러리는 Firebase Library를 다 품는 다이어그램 형태가 됩니다.

{% mermaid %}
graph TD;
	subgraph FirebaseSDK
	PromisesObjC
	GoogleUtilities
	nanopb
	GoogleDataTransport
	GoogleAppMeasurement
	FirebaseCoreDiagnostics
	FirebaseInstallations
	FirebaseAnalytics
	FirebaseCore
	Firebase
	FIRAnalyticsConnector
	end
	Application-->ManageVenderStaticLibrary;
    ManageVenderStaticLibrary-->PromisesObjC;
    ManageVenderStaticLibrary-->GoogleUtilities;
    ManageVenderStaticLibrary-->nanopb;
    ManageVenderStaticLibrary-->GoogleDataTransport;
    ManageVenderStaticLibrary-->GoogleAppMeasurement;
    ManageVenderStaticLibrary-->FirebaseCoreDiagnostics;
    ManageVenderStaticLibrary-->FirebaseInstallations;
    ManageVenderStaticLibrary-->FirebaseAnalytics;
    ManageVenderStaticLibrary-->FirebaseCore;
    ManageVenderStaticLibrary-->Firebase;
    ManageVenderStaticLibrary-->FIRAnalyticsConnector;
{% endmermaid %}

위 다이어그램을 토대로 한번 적용해봅시다.

1.`ManageVenderStaticLibrary` 라는 Dynamic Framework를 만듭니다. 

<!-- 그림 1 -->

2.이 프로젝트 경로에 Firebase 프레임워크를 복사해옵니다.

<!-- 그림 2 -->

3.프레임워크에 Firebase 프레임워크를 모두 연결 시킵니다.

<!-- 그림 3 -->

4.Build Settings에서 Framework Search Paths에 Firebase 프레임워크가 복사된 경로가 있는지 확인합니다. 그리고 Bitcode는 No로 설정합니다.

<!-- 그림 4 -->

5.Firebase 관련 코드를 만들어 Firebase 코드를 작성가능한지 확인합니다.

<!-- 그림 5 -->

이제 모든 과정이 끝났습니다. 이렇게 서드파티 라이브러리가 Static Library인 경우 하나로 합쳐 관리하면 관리이슈가 줄어듭니다.

## 서드파티 라이브러리 관리 - Dynamic Library

예제로 사용할 Dynamic Library는 Facebook SDK입니다. [Facebook SDK iOS 저장소](https://github.com/facebook/facebook-ios-sdk)의 배포된 버전을 살펴보면 FacebookSDK_Dynamic.framework.zip이 있습니다. 이를 내려받으면 프레임워크가 있습니다.

```
FBSDKLoginKit.framework
FBSDKShareKit.framework
FBSDKGamingServicesKit.framework
FBSDKCoreKit.framework
```

FBSDKLoginKit.framework의 Mach-O를 확인하면 Dynamic Library임을 확인할 수 있습니다.

```
$ file FBSDKLoginKit.framework/FBSDKLoginKit
FBSDKLoginKit.framework/FBSDKLoginKit: Mach-O universal binary with 3 architectures: [arm_v7:Mach-O dynamically linked shared library arm_v7] [x86_64] [arm64]
FBSDKLoginKit.framework/FBSDKLoginKit (for architecture armv7):	Mach-O dynamically linked shared library arm_v7
FBSDKLoginKit.framework/FBSDKLoginKit (for architecture x86_64):	Mach-O 64-bit dynamically linked shared library x86_64
FBSDKLoginKit.framework/FBSDKLoginKit (for architecture arm64):	Mach-O 64-bit dynamically linked shared library arm64

$ otool -L FBSDKLoginKit.framework/FBSDKLoginKit
FBSDKLoginKit.framework/FBSDKLoginKit:
	@rpath/FBSDKLoginKit.framework/FBSDKLoginKit (compatibility version 0.0.0, current version 0.0.0)
	@rpath/FBSDKCoreKit.framework/FBSDKCoreKit (compatibility version 0.0.0, current version 0.0.0)
	/System/Library/Frameworks/UIKit.framework/UIKit (compatibility version 1.0.0, current version 4006.0.0)
	...
```


Dynamic Library는 Static Library와는 다르게 코드가 복사되지 않고, 연결만 합니다. 따라서 배포되는 애플리케이션에 Dynamic Library가 포함되어야 합니다. 

따라서 Dynamic Library의 코드에서 우리가 사용할 수 있도록 인터페이스를 정의한 모듈 AbstractionVenderLibrary를 만들고, 애플리케이션에서 Dynamic Library로 부터 AbstractionVenderLibrary의 인터페이스로 코드를 만든 후, AbstractionVenderLibrary 모듈에 코드를 주입합니다.

{% mermaid %}
graph TD;
	subgraph FBSDK
	FBSDKLoginKit
	FBSDKCoreKit
	end
	Application-- Embed -->FBSDKLoginKit & FBSDKCoreKit;
	Application-- Link -->ModuleA;
	ModuleA-- Link -->AbstractionVenderLibrary;
	Application-. Code Injection .->AbstractionVenderLibrary;
{% endmermaid %}

## 서드파티 라이브러리 관리 - 종합

Dynamic Library, Static Library를 관리하는 방법을 다루었습니다. 여기에서 조금 더 나아가서 두 가지를 합쳐보면 어떨까요?

Static Library는 코드가 복사가 되지만 Dynamic은 애플리케이션에 임베드를 하고 모듈에 코드 주입합니다. 그러면 한 모듈에서 통합해서 해도 되지 않을까요?

{% mermaid %}
graph TD;
	subgraph FBSDK
	FBSDKLoginKit
	FBSDKCoreKit
	end

	subgraph FirebaseSDK
	PromisesObjC
	GoogleUtilities
	nanopb
	GoogleDataTransport
	GoogleAppMeasurement
	FirebaseCoreDiagnostics
	FirebaseInstallations
	FirebaseAnalytics
	FirebaseCore
	Firebase
	FIRAnalyticsConnector
	end

	Application-- Embed -->FBSDKLoginKit & FBSDKCoreKit;
	Application-. Embed .->AbstractionVenderLibrary;
	Application-- Link -->ModuleA;
	ModuleA-- Link -->AbstractionVenderLibrary;
	Application-. FBSDK Code Injection .->AbstractionVenderLibrary;

	AbstractionVenderLibrary-->PromisesObjC;
	AbstractionVenderLibrary-->GoogleUtilities;
	AbstractionVenderLibrary-->nanopb;
	AbstractionVenderLibrary-->GoogleDataTransport;
	AbstractionVenderLibrary-->GoogleAppMeasurement;
	AbstractionVenderLibrary-->FirebaseCoreDiagnostics;
	AbstractionVenderLibrary-->FirebaseInstallations;
	AbstractionVenderLibrary-->FirebaseAnalytics;
	AbstractionVenderLibrary-->FirebaseCore;
	AbstractionVenderLibrary-->Firebase;
	AbstractionVenderLibrary-->FIRAnalyticsConnector;
{% endmermaid %}


<!-- 
mermaid  
	https://github.com/svrooij/svrooij.github.io/commit/1deca4ed49674592256e61b480f8e3b2e794dd66
	https://mermaid-js.github.io/mermaid-live-editor/
	https://mermaid-js.github.io/mermaid/#/
-->
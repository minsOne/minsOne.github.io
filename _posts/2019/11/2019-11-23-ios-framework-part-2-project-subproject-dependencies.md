---
layout: post
title: "[iOS][Xcode] Framework Part 2 : 프로젝트, 서브 프로젝트, Dependencies, 그리고 Static, Dynamic Framework"
description: ""
category: "iOS/Mac"
tags: [Xcode, Project, Framework, Static Framework, Dynamic Framework, Dependencies]
---
{% include JB/setup %}

# 서론

프로젝트를 만들면 해당 프로젝트 내에 서브 프로젝트를 만드는 것에 이야기를 들어본적이 없었습니다. 프로젝트 하나에 모든 코드와 리소스가 다 들어가도록 개발을 했기 때문입니다.

하지만 프로젝트 내에 서브 프로젝트를 만들어 소스 코드를 추가하고 오직 상위 프로젝트에서만 서브 프로젝트의 코드를 알도록 `Build Phases -> Dependencies`를 이용할 수 있습니다.

그러면 서브 프로젝트, Dependencies, Static Framework를 이용하여 프로젝트를 좀 더 관리할 수 있도록 풀어보도록 하겠습니다.

# 프로젝트, 서브 프로젝트

프로젝트내에 서브 프로젝트를 만들어서 관리할 수 있습니다. 이는 해당 프로젝트의 코드가 많아지면 서브 프로젝트를 만들어 관리하도록 하는 것입니다.

다음 단계를 통해 서브 프로젝트를 만들어봅시다.

1.File -> New -> Project
<p style="text-align:center;"><img src="{{ site.production_url }}/image/2019/11/1.png" style="width: 600px"/></p><br/>
2.Framework를 선택
<p style="text-align:center;"><img src="{{ site.production_url }}/image/2019/11/2.png" style="width: 600px"/></p><br/>
3.Product Name을 지정
<p style="text-align:center;"><img src="{{ site.production_url }}/image/2019/11/3.png" style="width: 600px"/></p><br/>
4.서브 프로젝트가 만들어 지는 경로를 지정
<p style="text-align:center;"><img src="{{ site.production_url }}/image/2019/11/4.png" style="width: 600px"/></p><br/>
5.서브 프로젝트 추가 완료.
<p style="text-align:center;"><img src="{{ site.production_url }}/image/2019/11/5.png" style="width: 600px"/></p><br/>
6.General -> Frameworks, Libraries, and Embedded Content 에 Service.framework 추가
<p style="text-align:center;"><img src="{{ site.production_url }}/image/2019/11/6.png" style="width: 600px"/></p><br/>

# Dependencies, 그리고 Static, Dynamic Framework

Framework를 만들면 Dynamic Framework로 기본 지정되어 만들어집니다. 즉, 위와 같은 방법으로 서브 프로젝트를 많이 만들게되면 앱 프로젝트에 많은 Dynamic Framework를 임베딩 하고 있어야 합니다.

하지만 과연 그것이 맞는 방법일까요? Dynamic Framework 프로젝트를 만들고, 해당 서브 프로젝트로 Static Framework를 만들면 어떻게 될까요?

Dynamic Library에 Static Library가 코드가 복사되기 때문에, 서브 프로젝트는 많아질 수 있어도, Dynamic Framework는 적은 숫자로 유지가 됩니다.

다음 단계를 통해 프로젝트를 만들어봅시다.

1.위의 1~2단계 동일

2.Product Name을 지정
<p style="text-align:center;"><img src="{{ site.production_url }}/image/2019/11/7.png" style="width: 600px"/></p><br/>
3.서브 프로젝트가 만들어 지는 경로를 지정
<p style="text-align:center;"><img src="{{ site.production_url }}/image/2019/11/8.png" style="width: 600px"/></p><br/>
4.서브 프로젝트 추가 완료.
<p style="text-align:center;"><img src="{{ site.production_url }}/image/2019/11/9.png" style="width: 600px"/></p><br/>
5.`Build Settings -> Linking -> Mach-O Type` 에서 Static Library로 변경
<p style="text-align:center;"><img src="{{ site.production_url }}/image/2019/11/10.png" style="width: 600px"/></p><br/>
6.Service 프로젝트의 `Build Phases -> Dependencies` 에서 AppLogService 추가
<p style="text-align:center;"><img src="{{ site.production_url }}/image/2019/11/11.png" style="width: 600px"/></p><br/>

Service 프로젝트는 Dynamic Framework이며, AppLogService 프로젝트는 Static Framework이므로 Service 프로젝트가 빌드되면서 Service Dynamic Library에 AppLogService Static Library가 복사될 것 입니다.

코드를 한번 추가해봅시다.

AppLogService 프로젝트는 다음과 같이 코드를 추가합니다.

```
/// Service.swift

public class Service {
    public init() {}
    
    public func logging(txt: String) {
        print("Send Log : \(txt)")
    }
}
```

Service 프로젝트는 다음과 같이 코드를 추가합니다.

```
/// Service.swift

import AppLogService

public class Service {
    let appLogService: AppLogService.Service
    public init() {
        self.appLogService = AppLogService.Service()
    }
}
```

그리고 SampleApp의 AppDelegate에는 다음과 같은 코드를 추가합니다.

```
/// AppDelegate.swift
import UIKit
import Service

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Service().start()
        return true
    }
}
```

이제 빌드 후 실행하면 콘솔에 다음과 같이 출력됩니다.

```
Send Log : Start
```

이제 생성된 Service 프레임워크의 Dynamic Library를 다음 단계를 통해 살펴봅시다.

1.Service.project의 Product -> Service.framework 파일 선택 후, 오른쪽에서 Pull Path를 얻음.
<p style="text-align:center;"><img src="{{ site.production_url }}/image/2019/11/12.png" style="width: 600px"/></p><br/>
2.터미널을 열고 다음과 같이 명령을 실행.

```
$ nm /Users/minsone/Library/Developer/Xcode/DerivedData/SampleApp-atsergzbigkpwdailnubkfjtygsm/Build/Products/Debug-iphonesimulator/SampleApp.app/Frameworks/Service.framework/Service
00000000000019e0 T _$s13AppLogService0C0C7logging3txtySS_tF
0000000000001f20 S _$s13AppLogService0C0C7logging3txtySS_tFTq
0000000000001920 T _$s13AppLogService0C0CACycfC
0000000000001f18 S _$s13AppLogService0C0CACycfCTq
00000000000019c0 T _$s13AppLogService0C0CACycfc
0000000000001f74 s _$s13AppLogService0C0CMF
0000000000003300 b _$s13AppLogService0C0CML
0000000000001970 T _$s13AppLogService0C0CMa
0000000000003288 d _$s13AppLogService0C0CMf
0000000000003260 D _$s13AppLogService0C0CMm
0000000000001ee4 S _$s13AppLogService0C0CMn
0000000000003298 D _$s13AppLogService0C0CN
0000000000001c80 T _$s13AppLogService0C0CfD
0000000000001c60 T _$s13AppLogService0C0Cfd
0000000000001ed0 s _$s13AppLogServiceMXM
0000000000001720 T _$s7ServiceAAC06appLogA003AppcA0AACvg
0000000000001e20 S _$s7ServiceAAC06appLogA003AppcA0AACvpMV
0000000000001e28 S _$s7ServiceAAC06appLogA003AppcA0AACvpWvd
0000000000001840 T _$s7ServiceAAC5startyyF
0000000000001e80 S _$s7ServiceAAC5startyyFTq
0000000000001750 T _$s7ServiceAACABycfC
0000000000001e78 S _$s7ServiceAACABycfCTq
00000000000017f0 T _$s7ServiceAACABycfc
0000000000001f58 s _$s7ServiceAACMF
00000000000032f8 b _$s7ServiceAACML
00000000000017a0 T _$s7ServiceAACMa
00000000000031e8 d _$s7ServiceAACMf
00000000000031c0 D _$s7ServiceAACMm
0000000000001e44 S _$s7ServiceAACMn
00000000000031f8 D _$s7ServiceAACN
00000000000018e0 T _$s7ServiceAACfD
00000000000018b0 T _$s7ServiceAACfd
0000000000001e38 s _$s7ServiceMXM
...
```

Service 라이브러리의 Symbol 목록을 확인하다 보면 AppLogService의 코드가 있는 것을 확인할 수 있습니다. 이는 Static Linker가 AppLogService Static Library를 Service Dynamic Library에 복사됨을 확인할 수 있습니다.

```
00000000000019e0 T _$s13AppLogService0C0C7logging3txtySS_tF
0000000000001f20 S _$s13AppLogService0C0C7logging3txtySS_tFTq
0000000000001920 T _$s13AppLogService0C0CACycfC
0000000000001f18 S _$s13AppLogService0C0CACycfCTq
00000000000019c0 T _$s13AppLogService0C0CACycfc
0000000000001f74 s _$s13AppLogService0C0CMF
0000000000003300 b _$s13AppLogService0C0CML
0000000000001970 T _$s13AppLogService0C0CMa
0000000000003288 d _$s13AppLogService0C0CMf
0000000000003260 D _$s13AppLogService0C0CMm
0000000000001ee4 S _$s13AppLogService0C0CMn
0000000000003298 D _$s13AppLogService0C0CN
0000000000001c80 T _$s13AppLogService0C0CfD
0000000000001c60 T _$s13AppLogService0C0Cfd
0000000000001ed0 s _$s13AppLogServiceMXM
```

# 실험

## 실험 1. Service 프로젝트는 서브 프로젝트를 관리만 하는 프로젝트인 경우
만약 Service 프로젝트는 서브 프로젝트를 관리만 하는 프로젝트이고, 사용할때는 AppLogService 프로젝트의 Service를 호출하여 사용한다면 어떻게 될까요? 즉, Service 프로젝트에서 AppLogService 프로젝트를 호출하는 코드가 하나도 없고 SampleApp 프로젝트에서만 호출한다고 가정하면요.

1.Service 프로젝트의 Service 코드를 제거.

2.SampleApp의 AppDelegate에서 다음과 같이 코드 작성.

```
import UIKit
import AppLogService
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppLogService.Service().logging(txt: "Start")
        return true
    }
}
```

3.SampleApp의 Product -> SampleApp.app 파일 선택 후, 오른쪽에서 Pull Path를 얻음.
<p style="text-align:center;"><img src="{{ site.production_url }}/image/2019/11/13.png" style="width: 600px"/></p><br/>
4.터미널을 열고 다음과 같이 명령을 실행.

```
$ nm /Users/minsone/Library/Developer/Xcode/DerivedData/SampleApp-atsergzbigkpwdailnubkfjtygsm/Build/Products/Debug-iphonesimulator/SampleApp.app/SampleApp
                 U _$s10ObjectiveC22_convertBoolToObjCBoolyAA0eF0VSbF
0000000100002900 T _$s13AppLogService0C0C7logging3txtySS_tF
0000000100004bf0 S _$s13AppLogService0C0C7logging3txtySS_tFTq
0000000100002840 T _$s13AppLogService0C0CACycfC
0000000100004be8 S _$s13AppLogService0C0CACycfCTq
00000001000028e0 T _$s13AppLogService0C0CACycfc
0000000100004d10 s _$s13AppLogService0C0CMF
0000000100007f38 b _$s13AppLogService0C0CML
0000000100002890 T _$s13AppLogService0C0CMa
0000000100007ba0 d _$s13AppLogService0C0CMf
0000000100007b78 D _$s13AppLogService0C0CMm
0000000100004bb4 S _$s13AppLogService0C0CMn
0000000100007bb0 D _$s13AppLogService0C0CN
0000000100002ba0 T _$s13AppLogService0C0CfD
0000000100002b80 T _$s13AppLogService0C0Cfd
0000000100004ba0 s _$s13AppLogServiceMXM
                 U _$s15_ObjectiveCTypes01_A11CBridgeablePTl
00000001000049cc s _$s5UIKitMXM
                 U _$s8RawValueSYTl
0000000100001880 T _$s9SampleApp0B8DelegateC11application_29didFinishLaunchingWithOptionsSbSo13UIApplicationC_SDySo0j6LaunchI3KeyaypGSgtF
0000000100001920 t _$s9SampleApp0B8DelegateC11application_29didFinishLaunchingWithOptionsSbSo13UIApplicationC_SDySo0j6LaunchI3KeyaypGSgtFTo
0000000100004958 S _$s9SampleApp0B8DelegateC11application_29didFinishLaunchingWithOptionsSbSo13UIApplicationC_SDySo0j6LaunchI3KeyaypGSgtFTq
0000000100001b30 T _$s9SampleApp0B8DelegateCACycfC
0000000100001b50 T _$s9SampleApp0B8DelegateCACycfc
...

$ nm /Users/minsone/Library/Developer/Xcode/DerivedData/SampleApp-atsergzbigkpwdailnubkfjtygsm/Build/Products/Debug-iphonesimulator/SampleApp.app/Frameworks/Service.framework/Service
0000000000000ff8 S _ServiceVersionNumber
0000000000000fd0 S _ServiceVersionString
0000000000000fc0 s ___swift_reflection_version
                 U dyld_stub_binder
```

SampleApp의 바이너리의 Symbol 목록에서 AppLogService Static Library 코드가 복사된 것을 확인할 수 있습니다. 따라서 Static Linker가 Static Library를 사용하는 곳에 코드를 복사함을 알 수 있습니다.

이 이야기를 확장해보면 AppLogService의 Service 클래스의 Bundle 위치는 Service 프레임워크가 아니라 SampleApp이 됩니다. 만약에 해당 클래스가 Storyboard나 Nib을 사용하는 ViewController인 경우 코드가 있는 Bundle 위치와 Storyboard나 Nib이 있는 Bundle의 위치가 달라집니다. 개발자가 예상하지 못한 곳에 코드가 있으면 되지 않기 때문에 Static Library를 강제로 우리가 원하는 곳에 복사되도록 합니다.

즉, 상위 Dynamic Framework에서 더미로 코드를 사용해줘야 됩니다.

```
/// Service 프로젝트의 Service.swift

import AppLogService

func linking_static_library() {
	/// 단순히 Linking 하기 위한 코드
    print(AppLogService.Service.self)
}
```

이제 nm 명령어를 이용하여 살펴보면 SampleApp의 Symbol 목록에는 AppLogService가 없고, Service Dynamic Library에 있습니다.

```
$ nm /Users/minsone/Library/Developer/Xcode/DerivedData/SampleApp-atsergzbigkpwdailnubkfjtygsm/Build/Products/Debug-iphonesimulator/SampleApp.app/SampleApp
                 U _$s10ObjectiveC22_convertBoolToObjCBoolyAA0eF0VSbF
                 U _$s13AppLogService0C0CACycfC
                 U _$s13AppLogService0C0CMa
                 U _$s15_ObjectiveCTypes01_A11CBridgeablePTl
0000000100004a5c s _$s5UIKitMXM
                 U _$s8RawValueSYTl
0000000100001d30 T _$s9SampleApp0B8DelegateC11application_29didFinishLaunchingWithOptionsSbSo13UIApplicationC_SDySo0j6LaunchI3KeyaypGSgtF
0000000100001dd0 t _$s9SampleApp0B8DelegateC11application_29didFinishLaunchingWithOptionsSbSo13UIApplicationC_SDySo0j6LaunchI3KeyaypGSgtFTo
00000001000049e8 S _$s9SampleApp0B8DelegateC11application_29didFinishLaunchingWithOptionsSbSo13UIApplicationC_SDySo0j6LaunchI3KeyaypGSgtFTq
0000000100001fe0 T _$s9SampleApp0B8DelegateCACycfC
0000000100002000 T _$s9SampleApp0B8DelegateCACycfc
...

$ nm /Users/minsone/Library/Developer/Xcode/DerivedData/SampleApp-atsergzbigkpwdailnubkfjtygsm/Build/Products/Debug-iphonesimulator/SampleApp.app/Frameworks/Service.framework/Service
0000000000000b30 T _$s13AppLogService0C0C7logging3txtySS_tF
0000000000000f40 S _$s13AppLogService0C0C7logging3txtySS_tFTq
0000000000000a70 T _$s13AppLogService0C0CACycfC
0000000000000f38 S _$s13AppLogService0C0CACycfCTq
0000000000000b10 T _$s13AppLogService0C0CACycfc
0000000000000f88 s _$s13AppLogService0C0CMF
00000000000021a0 b _$s13AppLogService0C0CML
0000000000000ac0 T _$s13AppLogService0C0CMa
0000000000002130 d _$s13AppLogService0C0CMf
0000000000002108 D _$s13AppLogService0C0CMm
0000000000000f04 S _$s13AppLogService0C0CMn
0000000000002140 D _$s13AppLogService0C0CN
0000000000000d90 T _$s13AppLogService0C0CfD
0000000000000d70 T _$s13AppLogService0C0Cfd
0000000000002100 d _$s13AppLogService0C0CmML
00000000000009e0 t _$s13AppLogService0C0CmMa
0000000000000ef0 s _$s13AppLogServiceMXM
0000000000000930 T _$s7Service22linking_static_libraryyyF
                 U _$sBoWV
```

<div class="alert warning"><strong>경고</strong>: 더미 코드를 사용하는 부분은 정확한 동작을 방법을 모르기 때문에 임시방편으로 처리한 부분입니다.</div><br/>

## 실험 2. AppLogService를 SampleApp에서 import시 Service.AppLogService로 사용할 수 없을까?

SampleApp에서 AppLogService를 `import Service.AppLogService` 와 같은 방법으로 AppLogService 프레임워크를 호출하고 싶을 수도 있습니다. 왜냐하면 AppLogService 프로젝트는 AppLog 로 바꾸어서 Service 프로젝트의 AppLog를 담당하는 서비스라고 생각하고 작업할 수 있습니다.

SampleApp에서 `import Service.AppLogService` 로 import 하면 `No such module 'Service.AppLogService'` 에러를 노출합니다. 하지만 UIKit의 UIViewController는 `import UIKit.UIViewController`와 같이 사용이 가능합니다.

modulemap을 이용하여 우리가 원하는 기능을 구현해보도록 합시다.

1.Service 프로젝트 내 빈 `module.modulemap` 파일을 생성.
<p style="text-align:center;"><img src="{{ site.production_url }}/image/2019/11/14.png" style="width: 600px"/></p><br/>
2.`module.modulemap` 파일 내에 다음과 같이 코드를 추가.

```
framework module Service {
  umbrella header "Service.h"

  export *
  module * { export * }
}
```

3.Service 프로젝트의 Build Settings -> Packaging -> Module Map File 항목에 다음과 같이 코드를 추가.

<p style="text-align:center;"><img src="{{ site.production_url }}/image/2019/11/15.png" style="width: 600px"/></p><br/>
4.Service 프로젝트의 Service.swift 파일에 `@_exported import AppLogService`를 다음과 같이 코드를 추가.

```
import Foundation
import AppLogService

@_exported import AppLogService

func linking_static_library() {
    print(AppLogService.AppLog.self)
}
```

5.`module.modulemap` 파일에 다음과 같이 코드를 수정.

```
framework module Service {
  umbrella header "Service.h"

  explicit module AppLogService { export * }
  module * { export * }
}
```

6.SampleApp의 AppDelegate에 다음과 같이 코드를 작성.

```
import UIKit
import Service.AppLogService

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppLogService.Service().logging(txt: "Start")
        return true
    }
}
```

7.SampleApp 빌드 후, 정상적으로 되는지 확인.

<div class="alert warning"><strong>경고</strong>: 실험 2는 아직 이해가 부족하여 맞는지 확인이 필요합니다.</div><br/>

# 정리

* 프로젝트 내 서브 프로젝트를 적절히 이용.
* 서브 프로젝트는 Dependencies, ModuleMap 을 이용.
* Dynamic Framework와 Static Framework를 적절히 잘 이용.

# 참조

* [Clang 10 Documentation - Modules](https://clang.llvm.org/docs/Modules.html)
* [Modular framework, creating and using them](http://nsomar.com/modular-framework-creating-and-using-them/)
* [Injecting and Mocking static frameworks in Swift](https://medium.com/openclassrooms-product-design-and-engineering/injecting-and-mocking-static-frameworks-in-swift-b4fc410ab3ae)
* [Stackoverflow - iOS merge several framework into one](https://stackoverflow.com/questions/38843617/ios-merge-several-framework-into-one)
* [How we cut our iOS app’s launch time in half (with this one cool trick)](https://blog.automatic.com/how-we-cut-our-ios-apps-launch-time-in-half-with-this-one-cool-trick-7aca2011e2ea)
* [WWDC 2016 - Optimizing App Startup Time](https://developer.apple.com/videos/play/wwdc2016/406/)
* [Grab - Cocoapods Pod Merge](https://github.com/grab/cocoapods-pod-merge)
* [iOSアプリの起動速度を2倍にするために、複数のDynamic FrameworkをStaticにして、ひとつのDynamic Frameworkを作る with Swift](https://medium.com/eureka-engineering/create-merged-framework-to-cut-appstartuptime-72ee67b2bbab)
* [Understanding Objective-C Modules](https://samsymons.com/blog/understanding-objective-c-modules/)
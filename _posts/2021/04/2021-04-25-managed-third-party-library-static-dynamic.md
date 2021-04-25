---
layout: post
title: "[iOS][Xcode] 서드파티 라이브러리 잘 관리하기 - Static Library와 Dynamic Library의 관점 분리"
description: ""
category: "Mac/iOS"
tags: [Xcode, Static, Dynamic, Library, Framework, Dependency, Injection, Dependency Injection, DI, Protocol, Adapter]
---
{% include JB/setup %}

앱 개발하면서 많은 서드파티 라이브러리를 사용합니다. 오픈소스 기반 라이브러리도 있고, 업체에서 제공해주는 라이브러리도 있습니다. 이들 라이브러리는 Mach-O 타입이 Static Library 또는 Dynamic Library으로 되어 있습니다.

이 글에서 서드파티 라이브러리가 Static Library 일때, Dynamic Library 일때 어떻게 관리하면 좋을지를 설명하려고 합니다.

## 서드파티 라이브러리 관리 - Static Library

Static Library인 대표적인 서드파티 라이브러리는 Firebase Analytics가 있습니다. [Firebase SDK](https://github.com/firebase/firebase-ios-sdk)에서 [Carthage.md](https://github.com/firebase/firebase-ios-sdk/blob/master/Carthage.md) 파일을 보시면 Carthage로 라이브러리를 내려받음을 알 수 있습니다. [FirebaseAnalyticsBinary.json](https://dl.google.com/dl/firebase/ios/carthage/FirebaseAnalyticsBinary.json)를 내려받으면 버전별로 FirebaseAnalytics Zip 파일 목록이 있는 것을 확인할 수 있습니다.

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

사용할 FirebaseAnalytics 버전의 zip 내려받고, 압축을 풀면 FirebaseAnalytics 관련된 프레임워크를 얻을 수 있습니다. 프레임워크의 바이너리 파일의 Mach-O를 확인하면 모두 Static Library 임을 알 수 있습니다.

```
$ ls -1
FIRAnalyticsConnector.framework
Firebase.framework
FirebaseAnalytics.framework
FirebaseCore.framework
FirebaseCoreDiagnostics.framework
FirebaseInstallations.framework
GoogleAppMeasurement.framework
GoogleDataTransport.framework
GoogleUtilities.framework
PromisesObjC.framework
nanopb.framework

$ file Firebase.framework/Firebase
Firebase.framework/Firebase: Mach-O universal binary with 4 architectures: [i386:Mach-O object i386] [x86_64:Mach-O 64-bit object x86_64] [arm_v7:Mach-O object arm_v7] [arm64:Mach-O 64-bit object arm64]
Firebase.framework/Firebase (for architecture i386):	Mach-O object i386
Firebase.framework/Firebase (for architecture x86_64):	Mach-O 64-bit object x86_64
Firebase.framework/Firebase (for architecture armv7):	Mach-O object arm_v7
Firebase.framework/Firebase (for architecture arm64):	Mach-O 64-bit object arm64
```

Static Library는 Static Linker를 통해 코드가 복사됩니다.

<p style="text-align:center;"><img src="{{ site.production_url }}/image/2019/10/2.png" style="width: 600px"/></p>

이미지 출처 - [Apple Document](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/DynamicLibraries/100-Articles/OverviewOfDynamicLibraries.html)

그러면 이를 살짝 틀어보면 서드파티 라이브러리만을 담당하는 Dynamic Library를 만들면 되지 않을까요? Dynamic Library에 서드파티 라이브러리 코드가 모두 복사되었기 때문에, 우리가 사용하기 쉽게 레이어를 하나 두고 감싼다면 직접 접근하지 않아도 서드파티 라이브러리 기능들을 모두 사용할 수 있기 때문입니다.

이 방식은 이전에 설명한 [Swift Package Manager를 이용하여 패키지를 통합 관리하기]({{site.production_url}}/ios/mac/swift-package-manager-proxy-modular) 라는 글에서도 설명하였던 방식입니다.

따라서 `ExternalLibrary` 라이브러리는 Firebase Library에 의존성을 가지는 다이어그램이 됩니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/04/20210423_01.png" style="width: 400px"/>
</p><br/>


위 다이어그램을 토대로 한번 적용해봅시다.

1.`ExternalLibrary` 라는 Dynamic Framework를 만듭니다. 

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/04/20210423_04.png" style="width: 800px"/>
</p><br/>

2.이 프로젝트 경로에 FirebaseSDK 프레임워크를 복사해옵니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/04/20210423_05.png" style="width: 800px"/>
</p><br/>

3.프레임워크에 FirebaseSDK 프레임워크를 모두 연결 시킵니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/04/20210423_06.png" style="width: 800px"/>
</p><br/>

4.Build Settings에서 Framework Search Paths에 FirebaseSDK 프레임워크가 복사된 경로가 있는지 확인합니다. 그리고 `Bitcode`는 `No`로 값을 설정, `Other Linker Flags(OTHER_LDFLAGS)`에 `-ObjC` linker flag를 추가합니다.(Bitcode가 No로 설정하므로, 모든 프로젝트는 Bitcode를 No로 설정해야합니다.)

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/04/20210423_07.png" style="width: 800px"/>
</p><br/>

5.FirebaseSDK 관련 코드를 만들어 Firebase 코드를 작성가능한지 확인합니다.

```
/// FileName : AppLogService.swift
/// Module : ExternalLibrary

import Foundation

public class AppLogService {}


/// FileName : Firebase.swift
/// Module : ExternalLibrary
import Foundation
import Firebase

protocol FirebaseLogEventServicable {
  func configure()
  func logEvent()
}

final class FirebaseLogEventService: FirebaseLogEventServicable {
  func configure() {
    guard
      let filePath = Bundle(for: Self.self).path(forResource: "GoogleService-Info", ofType: "plist"),
      let fileopts = FirebaseOptions(contentsOfFile: filePath)
      else { return }
    FirebaseApp.configure(options: fileopts)
  }
  
  func logEvent() {
    Analytics.logEvent(AnalyticsEventSelectContent, parameters: nil)
  }
}

public extension AppLogService {
  class Firebase {
    static var service: FirebaseLogEventServicable = FirebaseLogEventService()

    public static func configure() {
      service.configure()
    }
    public static func logEvent() {
      service.logEvent()
    }
  }
}
```

이제 모든 과정이 끝났습니다. App에서 AppDelegate의 didFinishLaunching 함수에서 `AppLogService.Firebase.configure()` 를 호출하여 설정이 완료되면, 모든 곳에서 `AppLogService.Firebase.logEvent()` 를 호출할 수 있습니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/04/20210423_08.png" style="width: 800px"/>
</p><br/>


이렇게 서드파티 라이브러리가 Static Library인 경우 Dynamic Framework인 `ExternalLibrary`에서 관리하여 유지보수하는 지점이 줄어들게 됩니다.

위에서 작업한 코드는 [여기](https://github.com/minsOne/ManagedExternalLibrary/tree/main/StaticExternalLibraryExample)에서 확인할 수 있습니다.
<br/>

## 서드파티 라이브러리 관리 - Dynamic Library

예제로 사용할 Dynamic Library인 서드파티 라이브러리는 Facebook SDK입니다. [Facebook SDK iOS 저장소](https://github.com/facebook/facebook-ios-sdk)의 배포된 버전(Tags)을 살펴보면 FacebookSDK_Dynamic.framework.zip이 있습니다. 내려받으면 프레임워크 파일이 있습니다.

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


Dynamic Library는 Static Library와는 다르게 코드가 복사되지 않고, 연결만 합니다. 따라서 배포되는 애플리케이션에 Dynamic Library인 서드파티 라이브러리가 포함되어야 합니다. 

단순히 애플리케이션에 넣고 사용하는 것이 아니라, 서드파티 라이브러리에서 사용할 코드의 인터페이스를 ExternalLibrary 모듈에서 정의하고, 애플리케이션에서는 ExternalLibrary 모듈에서 정의한 인터페이스를 토대로 서드파티 라이브러리 코드를 감싼뒤 ExternalLibrary 모듈에 주입합니다.

다음과 같은 구조로 다이어그램이 만들어집니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/04/20210423_02.png" style="width: 800px"/>
</p><br/>


위 다이어그램을 토대로 한번 적용해봅시다.

1.앞에서 만들었던 구조와 같이 App 프로젝트, Feature 모듈(Static), ExternalLibrary 모듈(Static)을 만듭니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/04/20210423_09.png" style="width: 800px"/>
</p><br/>

2.이 프로젝트 경로에 FacebookSDK를 복사 후, 애플리케이션에 FacebookSDK 프레임워크를 Link/Embed 합니다. 그리고 Build Settings에서 Framework Search Paths에 FacebookSDK 프레임워크가 복사된 경로가 있는지 확인합니다. 또한, `Building for iOS Simulator, but the linked and embedded framework '*.framework' was built for iOS + iOS Simulator.` 같은 에러가 발생할 수 있으므로, `Validate Workspace`(VALIDATE_WORKSPACE) 값을 `true` 로 변경합니다.(이는 FacebookSDK 프레임워크가 i386 아키텍처를 지원하지 않아서 그렇습니다.)

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/04/20210423_10.png" style="width: 800px"/><br/>
<img src="{{ site.production_url }}/image/2021/04/20210423_11.png" style="width: 800px"/><br/>
<img src="{{ site.production_url }}/image/2021/04/20210423_12.png" style="width: 800px"/><br/>
</p>

3.FacebookSDK의 FBSDKShareKit을 이용하여 공유하는 코드를 본따 ExternalLibrary 모듈에 인터페이스를 정의합니다.

3.1 FacebookSDK에서 Link를 공유하는 코드는 다음과 같습니다.
```
import FBSDKShareKit

let shareContent = ShareLinkContent()
shareContent.contentURL = URL(string: "https://developers.facebook.com")!
ShareDialog(fromViewController: UIViewController(), content: shareContent, delegate: SharingDelegate).show()

extension SomeObject: SharingDelegate {
  func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {}

  func sharer(_ sharer: Sharing, didFailWithError error: Error) {}

  func sharerDidCancel(_ sharer: Sharing) {}
}
```

3.2 ExternalLibrary에서는 비슷하게 인터페이스를 정의할 수 있습니다.

```
/// FileName : FacebookAdapter.swift
/// Module : ExternalLibrary
import Foundation
import UIKit

public struct FBShareLinkContent {
  public let contentURL: URL
  public init(contentURL: URL) {
    self.contentURL = contentURL
  }
}

public protocol FBSharingDelegate: class {
  func sharerDidCompleteWithResults(results: [String : Any])
  func sharerDidFailWithError(error: Error)
  func sharerDidCancel()
}

public protocol FBShareDialogInterface {
  init(fromViewController: UIViewController, link: FBShareLinkContent, delegate: FBSharingDelegate)
  func show() -> Bool
}
```

처음부터 인터페이스를 완벽히 동일하게 맞출 필요가 없습니다. 필요에 따라 확장하거나 재정의하는 것이 좋습니다.<br/>

4.애플리케이션에서 ExternalLibrary 모듈에 정의된 인터페이스를 토대로 Facebook SDK 코드를 감싼 Adapter 타입을 정의합니다.

```
/// FileName: FBShareDialogAdapter.swift
/// Module: App
import UIKit
import ExternalLibrary
import FBSDKShareKit

final class FBShareDialogAdapter: NSObject, FBShareDialogInterface, SharingDelegate {
  var dialog: ShareDialog?
  weak var delegate: FBSharingDelegate?
  
  required init(fromViewController: UIViewController, link: FBShareLinkContent, delegate: FBSharingDelegate) {
    super.init()

    let shareContent = ShareLinkContent()
    link.contentURL.map { shareContent.contentURL = $0 }
    self.delegate = delegate
    self.dialog = ShareDialog(fromViewController: fromViewController, content: shareContent, delegate: self)
  }
  
  func show() -> Bool {
    return dialog?.show() ?? false
  }
  
  func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
    delegate?.sharerDidCompleteWithResults(results: results)
  }
  func sharer(_ sharer: Sharing, didFailWithError error: Error) {
    delegate?.sharerDidFailWithError(error: error)
  }
  func sharerDidCancel(_ sharer: Sharing) {
    delegate?.sharerDidCancel()
  }
}
```

5.애플리케이션은 아까 정의한 Adapter를 App의 AppDelegate에서 ExternalLibrary 모듈에 주입합니다.

```
/// FileName : AdapterContainer.swift
/// Module : ExternalLibrary

public class ExternalLibraryAdapter {
  public static var fbShareDialog: FBShareDialogInterface.Type?
}

/// FileName : AppDelegate.swift
/// Module: App
import UIKit
import ExternalLibrary

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    ...
    ExternalLibraryAdapter.fbShareDialog = FBShareDialogAdapter.self
    ...

    return true
  }
}
```

6.피처 모듈에서는 ExternalLibrary 모듈에 주입된 Adapter 객체를 이용하여 FacebookSDK 코드를 실행합니다.

```
/// FileName: ViewController.swift
/// Module: Feature

import Foundation
import UIKit
import ExternalLibrary

public class ViewController: UIViewController, FBSharingDelegate {
  private var dialog: FBShareDialogInterface?

  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .blue
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    var shareContent = FBShareLinkContent()
    shareContent.contentURL = URL(string: "https://developers.facebook.com")
    let dialog = ExternalLibraryAdapter.fbShareDialog?.init(fromViewController: self, link: shareContent, delegate: self)
    self.dialog = dialog
    _ = dialog?.show()
  }
  
  public func sharerDidCompleteWithResults(results: [String : Any]) {
    print(#function)
  }
  
  public func sharerDidFailWithError(error: Error) {
    print(#function)
  }
  
  public func sharerDidCancel() {
    print(#function)
  }
}
```

<p style="text-align:center;">
	<br/><video src="{{ site.production_url }}/image/2021/04/20210423_13.mov" width="800px" controls autoplay loop></video>
</p><br/>

피처 모듈은 직접적으로 서드파티 라이브러리인 FacebookSDK를 알지는 못하지만, 추상화시킨 Adapter를 통해 사용할 수 있게 됩니다. 즉, 피처를 개발함에 있어서 서드파티 라이브러리를 직접적으로 의존할 필요가 없어집니다.

위에서 작업한 코드는 [여기](https://github.com/minsOne/ManagedExternalLibrary/tree/main/DynamicExternalLibraryExample)에서 확인할 수 있습니다.

<br/>

## 서드파티 라이브러리 관리 - 종합

Dynamic/Static 서드파티 라이브러리를 관리하는 방법을 다루었습니다. 여기에서 조금 더 나아가서 두 가지를 합쳐보면 어떨까요?

Static Library는 코드가 복사가 되지만 Dynamic은 Library는 애플리케이션에 임베드를 하고 ExternalLibrary 모듈에 우리가 별도로 정의한 인터페이스를 구현한 코드 주입합니다. 그러면 한 모듈에서 서드파티 라이브러리를 모두 관리해도 되지 않을까요?

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/04/20210423_03.png" style="width: 800px"/>
</p><br/>

위 다이어그램으로 구성한 코드는 [여기](https://github.com/minsOne/ManagedExternalLibrary/tree/main/UniversalExternalLibraryExample)에서 확인할 수 있습니다.

<br/>

# 참고

* [모듈간의 관계를 Dependency Injection Container으로 풀어보자]({{site.production_url}}/programming/swift-solved-circular-dependency-from-dependency-injection-container)
* [Swift Package Manager를 이용하여 패키지를 통합 관리하기 - Proxy Module]({{site.production_url}}/ios/mac/swift-package-manager-proxy-modular)
* [Framework Part 1 : Static Framework와 Dynamic Framework]({{site.production_url}}/ios/mac/ios-framework-part-1-static-framework-dynamic-framework)
<!-- 
mermaid  
	https://github.com/svrooij/svrooij.github.io/commit/1deca4ed49674592256e61b480f8e3b2e794dd66
	https://mermaid-js.github.io/mermaid-live-editor/
	https://mermaid-js.github.io/mermaid/#/
-->
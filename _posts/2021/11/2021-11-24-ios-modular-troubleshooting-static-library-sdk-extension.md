---
layout: post
title: "[iOS][Swift][Modular Architecture] Troubleshooting - Static Library를 모듈로 작업 후, Extension으로 코드 확장시 멤버를 찾을 수 없는 문제와 해결방법"
description: ""
category: "Mac/iOS"
tags: [Swift, Xcode, Static Library, Dynamic Framework, Linker, OTHER_LDFLAGS, Extension, Library, Framework, all_load, force_load]
---
{% include JB/setup %}

## 서론

모듈화를 할때 모듈을 어떻게 다룰 것인지 정의가 필요합니다. 모듈을 Dynamic Framework로 관리할 것인지, 아니면 Static Library로 관리할 것인지 입니다.

모듈을 Dynamic Framework로 관리한다면 쉽게 사용할 수 있습니다. 하지만, 모듈을 만들기 쉽다는 이야기는 많은 모듈을 만들 수 있기 때문에 Dynamic Framework 개수가 빠르게 늘어단다는 의미입니다. 따라서 유저가 애플리케이션을 실행할 때 최초 실행(Cold Start)라면 기기 상태에 따라 실행되는 시간이 달라집니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/11/20211124_01.png"/></p>

출처 : [Github - grab/cocoapods-pod-merge](https://github.com/grab/cocoapods-pod-merge)

따라서 저는 모듈화 하는 경우 Static Library를 만드는 것을 추천합니다. 

## Static Library와 Extension

Objc에서 Category, Swift에서 Extension 이라는 기능을 제공합니다. 이 기능을 이용하면 별도의 클래스, 구조체, 함수 등을 만들지 않고도 쉽게 해당 타입의 확장이 가능합니다.

```swift
// Module : FoundationExtension
// FileName : Int+Extension.swift
import Foundation

public extension Int {
    var toDouble: Double { Double(self) }
}
```

하지만 Extension을 활용한 코드를 Static Library에 추가하여 사용하다보면 가끔씩 해당 코드를 작성 후 빌드하면 심볼을 찾을 수 없다는 에러가 발생합니다. 

<div class="mermaid" style="display:flex;justify-content:center;"> 
graph LR;
    id1[App]-->id2[(ModuleKit)]-->id3([FoundationExtension]);
    style id1 fill:#03bfff
    style id2 fill:#ffba0c
    style id3 fill:#ff7357
</div><br/>

**ModuleKit**은 `Dynamic Framework`, **FoundationExtension**는 `Static Library` 형태로, 위와 같은 의존성 관계를 구성합니다. 그러면 **FoundationExtension** 라이브러리는 **ModuleKit** 프레임워크의 바이너리에 **코드가 적재**됩니다. 

그러면 **FoundationExtension** 라이브러리가 **ModuleKit**에 적재되었으니 **App**은 **ModuleKit**을 의존성을 가지므로 **FoundationExtension**을 `import`로 선언하고 `toDouble` 속성을 사용할 수 있습니다. 이론적으로 가능합니다.

그러나 컴파일 과정은 우리가 예상한대로 동작하지 않습니다. 

한번 살펴봅시다.

FoundationExtension에서 Int+Extension 파일을 두개 만듭니다.

```swift
// Module : FoundationExtension
// FileName : Int+Extension1.swift
import Foundation

public extension Int {
    var toDouble: Double { Double(self) }
}

// Module : FoundationExtension
// FileName : Int+Extension2.swift
import Foundation

public extension Int {
    var toFloat: Float { Float(self) }
}
```

그리고 ModuleKit에서는 위 코드를 이용하는 코드를 만듭니다.

```swift
// Module : ModuleKit
// FileName : ModuleKit.swift
import Foundation
import FoundationExtension

func convertIntToDouble(int value: Int) -> Double {
    value.toDouble
}
```

다음으로 App에서는 AppDelegate에서 FoundationExtension 모듈의 코드를 이용하는 코드를 만듭니다.

```swift
// Module : App
// FileName : AppDelegate.swift
import UIKit
import FoundationExtension

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        print(10.toDouble)
        print(20.toFloat)

        return true
    }
}
```

AppDelegate에서 toDouble, toFloat를 사용하는데 문제가 없어 보입니다. 하지만, 심볼을 찾을 수 없다는 에러인 Undefined symbol을 출력합니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/11/20211124_02.png"/></p>

ModuleKit에 Int의 Extension 코드가 **적재되지 않았고**, 따라서 AppDelegate에서 작성한 코드는 **정의되지 않은 코드**를 사용한 것입니다.

## 문제 해결 

**ModuleKit 프레임워크**에서 의존성 가지는 `모든 정적 라이브러리(FoundationExtension 라이브러리 포함)`에 작성된 `모든 멤버`를 `적재`하도록 `링커`에 `all_load` 옵션을 전달합니다. **ModuleKit 프로젝트 설정**의 `Build Settings`에서 `Linking`의 `Other Link Flag(OTHER_LDFLAGS)`에 `all_load`를 기입합니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/11/20211124_03.png"/></p>

이제 링커에게 라이브러리에 작성된 모든 멤버를 적재하도록 전달했으므로, 다시 빌드하면 성공합니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/11/20211124_04.png"/></p><br/>

또는 `force_load`를 이용하여 `지정된 라이브러리`에 작성된 모든 멤버를 적재하도록 할 수 있습니다. **ModuleKit 프레임워크**에서 **FoundationExtension 라이브러리**를 `force_load`로 지정하면 위와 같이 빌드가 성공합니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/11/20211124_05.png"/></p><br/>

ps1. 위에서 작업한 코드는 [여기](https://github.com/minsOne/Experiment-Repo/tree/master/20211124-research-modular-static-library-foundation-extension)에서 확인하실 수 있습니다.<br/>
ps2. 서드파티 라이브러리를 제공하는 업체인 경우, Category, Extension 기능을 가급적 자제하여 공급업체의 프로젝트 설정을 위와 같이 설정을 강제하지 않도록 하는 것이 좋습니다.

## 참고

* [Apple Document - Technical Q&A QA1490 Building Objective-C static libraries with categories](https://developer.apple.com/library/archive/qa/qa1490/_index.html)
* [Stack Overflow - What does the -all_load linker flag do?](https://stackoverflow.com/a/2906210)
* [Stack Overflow - Xcode -- get force_load to work with relative paths](https://stackoverflow.com/a/5095793)
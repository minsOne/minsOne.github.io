---
layout: post
title: "[iOS][Xcode 13.3.1][Tuist 3.3] 프로젝트 생성/관리 도구 Tuist(7) - DemoApp과 Inject의 Hot Reload를 이용해서 빠른 개발하기"
tags: [iOS, Hot Reload, Preview, Inject, Tuist, InjectionIII]
---
{% include JB/setup %}

<!-- Tuist로 쉽게 프로젝트를 생성 및 의존성을 추가할 수 있습니다. 이 말은 역할에 맞는 라이브러리, 프레임워크로 세분화해서 만들 수 있다는 의미입니다.  -->

iOS 13부터 Preview 기능이 들어가면서, 이 기능을 어떻게 잘 써볼 수 있을지 많은 시도들이 있었습니다. 하지만 대규모 프로젝트로 진행될수록 Preview 활용도가 많이 떨어집니다. 

그 이유는 정확한 이유를 알 수 없는 에러, Preview를 위한 빌드, 빌드시간이 오래 걸리면 Preview 실패, Static Library에서는 사용 불가, Static Library를 사용할 때 간헐적인 실패 등이 발생합니다. 

UI 기능을 담당하는 모듈만 의존하는 DemoApp을 통해서 빠른 빌드 및 실행으로 작성한 UI를 확인할 수 있습니다. 

아래와 같이 의존 관계가 형성됩니다.

<div class="mermaid" style="display:flex;justify-content:center;"> 
graph TD;
    App-->Feature
    Feature-->예금
    Feature-->적금
    subgraph 예금상품
    예금-->예금UI
    예금DemoApp-->예금
    예금UIDemoApp-->예금UI
    end
    subgraph 적금상품
    적금-->적금UI
    적금DemoApp-->적금
    적금UIDemoApp-->적금UI
    end
    예금UI-->Resource
    적금UI-->Resource
</div>

UI는 사실 시행착오를 겪으면서 작업해야하는 기능입니다. 따라서 UIDemoApp을 만들고, 작업하는 편이 추후 유지보수를 생각했을 때 좋습니다. 

하지만, UI는 모듈로 해당 소스를 수정하고 다시 DemoApp을 빌드, 실행하여 수정한 코드가 잘 반영되었는지 확인하는데 있어서 컨텍스트 스위칭 비용이 생깁니다. 

여기에서 Preview 기능까지는 아니지만, DemoApp에서 Hot Reload를 할 수 있도록 해주는 툴인 InjectionIII - [MacApp](https://apps.apple.com/us/app/injectioniii/id1380446739?mt=12), [Github](https://github.com/johnno1962/InjectionIII)과 [Inject 라이브러리](https://github.com/krzysztofzablocki/Inject)를 이용하여 개발할 수 있습니다.

위의 구조를 축약하여 `Application --> Features --> FeatureDeposit --> FeatureDepositUI` 구조를 가지는 프로젝트를 만들어봅시다.

<div class="mermaid" style="display:flex;justify-content:center;"> 
graph TD;
    Application-->Features
    Features-->FeatureDeposit
    subgraph FeatureDepositGroup
    FeatureDeposit-->FeatureDepositUI
    FeatureDepositDemoApp-->FeatureDeposit
    FeatureDepositUIPreviewApp-->FeatureDepositUI
    end
</div>

그럼 UI의 DemoApp을 가지는 구조로 Tuist 코드를 작성해봅시다.

```swift
/// FileName: Projects/Application/Project.swift

import ProjectDescription
import ProjectDescriptionHelpers

let targets: [Target] = [
    .init(name: "Application",
          platform: .iOS,
          product: .app,
          bundleId: "kr.minsone.app",
          deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
          sources: ["App/Sources/**"],
          resources: ["App/Resources/**"],
          dependencies: [
            .project(target: "Features", path: "../Features")
          ]
         )
]

let project = Project.init(name: "Application",
                           organizationName: "minsone",
                           targets: targets)

/// -----------------------------------------------------------------------------

/// FileName : Projects/Feature/Features/Project.swift
import ProjectDescription
import ProjectDescriptionHelpers

let targets: [Target] = [
    .init(name: "Features",
          platform: .iOS,
          product: .framework,
          bundleId: "kr.minsone.features",
          deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
          sources: ["Source/Feature/**"],
          dependencies: [
            .project(target: "FeatureDeposit", path: "../FeatureDeposit")
          ]
         ),
    .init(name: "FeaturesDemoApp",
          platform: .iOS,
          product: .app,
          bundleId: "kr.minsone.features.demoApp",
          deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
          sources: ["App/DemoApp/**"],
          resources: ["App/DemoApp/Resources/**"],
          dependencies: [
            .target(name: "Features")
          ]
         )
]

let project: Project =
    .init(name: "Features",
          organizationName: "minsone",
          targets: targets)


/// -----------------------------------------------------------------------------

/// FileName : Projects/Feature/FeatureDeposit/Project.swift
import ProjectDescription
import ProjectDescriptionHelpers

let targets: [Target] = [
    .init(name: "FeatureDepositUI",
          platform: .iOS,
          product: .staticLibrary,
          bundleId: "kr.minsone.feature.deposit.ui",
          deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
          sources: ["Source/UI/**"]
         ),
    .init(name: "FeatureDepositUIPreviewApp",
          platform: .iOS,
          product: .app,
          bundleId: "kr.minsone.feature.deposit.uipreviewApp",
          deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
          sources: ["App/UIPreviewApp/Sources/**"],
          resources: ["App/UIPreviewApp/Resources/**"],
          dependencies: [
            .target(name: "FeatureDepositUI"),
            .package(product: "Inject"),
          ],
          settings: .settings(base: ["OTHER_LDFLAGS": "$(inherited) -Xlinker -interposable"])
         ),
    .init(name: "FeatureDeposit",
          platform: .iOS,
          product: .staticLibrary,
          bundleId: "kr.minsone.feature.deposit",
          deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
          sources: ["Source/Feature/**"],
          dependencies: [
            .target(name: "FeatureDepositUI")
          ]
         ),
    .init(name: "FeatureDepositDemoApp",
          platform: .iOS,
          product: .app,
          bundleId: "kr.minsone.feature.deposit.demoApp",
          deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
          sources: ["App/DemoApp/Sources/**"],
          resources: ["App/DemoApp/Resources/**"],
          dependencies: [
            .target(name: "FeatureDeposit"),
            .package(product: "Inject"),
          ]
         )
]

let project: Project =
    .init(name: "FeatureDeposit",
          organizationName: "minsone",
          packages: [.remote(url: "https://github.com/krzysztofzablocki/Inject.git", requirement: .revision("0844cfbd6af3d30314adb49c8edf22168d254467"))],
          targets: targets)
```

위의 Project manifest를 기반으로 `tuist generate`를 실행하여 프로젝트를 생성합니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2022/04/20220430_01.png"/></p>

그리고 FeatureDepositUI 모듈에 ViewController.swift 파일을 생성하고 FeatureDepositUIPreviewApp에서 해당 ViewController를 사용하도록 합니다.

```swift
/// FileName : Projects/Feature/FeatureDeposit/Source/UI/ViewController.swift

import UIKit

public class ViewController: UIViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let label = UILabel()
        label.text = "Hello UIKit"
        label.font = .boldSystemFont(ofSize: 50)
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}

/// -----------------------------------------------------------------------------

/// FileName : Projects/Feature/FeatureDeposit/App/UIPreviewApp/Sources/AppDelegate.swift

import UIKit
import FeatureDepositUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        let vc = ViewController()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        self.window = window

        return true
    }
}
```

이제 FeatureDepositUIPreviewApp을 실행하면 FeatureDepositUI의 ViewController가 노출됩니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2022/04/20220430_02.png"/></p>

다음으로, InjectionIII와 Inject 라이브러리를 이용하여 Hot Reload를 이용하여 개발해보도록 합니다. FeatureDepositUIPreviewApp 타겟을 기반으로 프로젝트를 생성하도록 `tuist generate`를 사용합니다.

```
$ tuist generate FeatureDepositUIPreviewApp
```

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2022/04/20220430_03.png"/></p>

FeatureDepositUIPreviewApp의 AppDelegate에 Inject를 이용한 코드를 추가합시다.

```swift
import UIKit
import FeatureDepositUI
import Inject

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        let vc = Inject.ViewControllerHost(ViewController())
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        self.window = window

        return true
    }
}
```

그리고 빌드, 실행해봅시다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2022/04/20220430_04.png"/></p>

콘솔창에서 `InjectionIII.app` 이 실행되지 않았다고 출력되었습니다. `InjectionIII.app` 를 실행하고 다시 빌드, 실행을 해봅시다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2022/04/20220430_05.png"/></p>

시뮬레이터에서 FeatureDepositUIPreviewApp앱은 실행되고, 프로젝트 디렉토리를 선택하라는 팝업이 뜹니다. 이때, Tuist로 생성한 워크스페이스가 있는 폴더를 선택합니다.

그러면 콘솔창에 InjectionIII와 연결되었다고 출력됩니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2022/04/20220430_06.png"/></p>

이제 FeatureDepositUI의 ViewController 코드를 수정하면 바로 시뮬레이터의 FeatureDepositUIPreviewApp에 반영되는 것을 확인할 수 있습니다.

<p style="text-align:center;">
	<br/><video src="{{ site.production_url }}/image/2022/04/20220430_07.mov" width="800px" controls autoplay loop></video>
</p><br/>

## 참고자료

* Github
  * [johnno1962/InjectionIII](https://github.com/johnno1962/InjectionIII)
  * [krzysztofzablocki/Inject](https://github.com/krzysztofzablocki/Inject)
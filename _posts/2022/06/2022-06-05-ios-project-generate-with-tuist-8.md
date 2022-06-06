---
layout: post
title: "[iOS][Xcode 13.3.1][Tuist 3.3.0] 프로젝트 생성/관리 도구 Tuist(8) - 모듈의 데모앱의 지속가능하게 유지보수되도록 검증하기 with Tuist"
tags: [Swift, Xcode, Tuist, Demo, UnitTest, Target, TestPlan, TEST_HOST, BUNDLE_LOADER]
---
{% include JB/setup %}

모듈 단위로 개발하다보면, 모듈의 데모앱을 만들고, 작성한 모듈을 실행해보면서 잘 동작되고 있는지 확인합니다.

아래와 같이 모듈이 상세하게 나눠진다면 모듈마다 데모앱이 많아지게 생깁니다.

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

상품, 기능이 많아지면 모듈도 많아지고, 그러면 인원수 대비 관리해야할 데모앱이 많아지는데, 이 모든 데모앱을 챙기기는 쉽지 않아집니다. 특정 모듈을 리팩토링 했는데, 해당 모듈을 사용하는 데모앱에 반영을 해줘야하는데, 반영을 하기 어렵고, 그러면 방치되는 데모앱이 많아지게 됩니다.

그러면 이런 데모앱들을 어떻게 지속적인 관리를 할 수 있을까요?

다음 단계를 통해서 지속적인 관리를 하는 방법을 살펴봅시다.

먼저, 모듈을 테스트하기 위한 테스트 타겟을 만듭니다.

```swift
/// FeatureDeposit 모듈
let targets: [Target] = [
    ...

    .init(name: "FeatureDepositUIUnitTests",
          platform: .iOS,
          product: .unitTests,
          bundleId: "kr.minsone.feature.deposit.uiunitTests",
          deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
          sources: ["Tests/UIUnitTests/**"],
          dependencies: [.target(name: "FeatureDepositUI"),
                         .target(name: "FeatureDepositUIPreviewApp")]
         )
]
```
UnitTests 타겟은 `FeatureDepositUI` 모듈의 테스트를 위해 만들었습니다. `FeatureDepositUIPreviewApp` 앱은 `FeatureDepositUI` 모듈의 데모앱으로, 의존성을 추가하였습니다. 이는 UnitTests 타겟이 `FeatureDepositUIPreviewApp` 앱 타겟을 빌드하도록 하기 위함입니다.

위와 같이 타겟을 만들고 `tuist generate` 를 이용하여 프로젝트 생성하면, HOST Application 항목에 `FeatureDepositUIPreviewApp` 앱 타겟이 추가되어 있는 것을 확인할 수 있습니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2022/06/20220605_01.png"/>
</p><br/>

그리고 Build Phases의 Dependencies에 `FeatureDepositUIPreviewApp` 앱 타겟이 추가되어 있는 것을 확인할 수 있습니다. 이는 UnitTest 타겟이 빌드될때 `FeatureDepositUIPreviewApp` 앱 타겟도 빌드함을 의미합니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2022/06/20220605_04.png"/>
</p><br/>

HOST Application에 추가되어 있으면 테스트시 `FeatureDepositUIPreviewApp` 앱이 기동하므로, 단순 빌드 및 검증만 하기 위해서는 HOST Application에서 제거를 해야합니다.

HOST Application 항목을 제거하기 위해선 TEST_HOST의 값을 제거해야합니다. TEST_HOST의 값은 제거하면, BUNDLE_LOADER는 TEST_HOST 값을 사용하는데, 없어지므로, 기존 TEST_HOST의 값을 사용해서 넣어줘야 합니다. 

```swift
/// FeatureDeposit 모듈
let targets: [Target] = [
    ...

    .init(name: "FeatureDepositUIUnitTests",
          platform: .iOS,
          product: .unitTests,
          bundleId: "kr.minsone.feature.deposit.uiunitTests",
          deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
          sources: ["Tests/UIUnitTests/**"],
          dependencies: [.target(name: "FeatureDepositUI"),
                         .target(name: "FeatureDepositUIPreviewApp")],
          settings: .settings(base: ["TEST_HOST": "",
                                     "BUNDLE_LOADER": "$(BUILT_PRODUCTS_DIR)/$(TEST_TARGET_NAME).app/$(TEST_TARGET_NAME)"])
         )
]
```

TEST_TARGET_NAME은 Tuist에서 만들어주는 값으로, 이것을 활용하여 BUNDLE_LOADER 값을 넣어줄 수 있습니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2022/06/20220605_02.png"/>
</p><br/>

위와 같이 HOST Application이 Custom으로 변경됩니다.

그리고 FeatureDepositUI 타겟으로 테스트를 실행하면 다음과 같이 UIPreview 데모앱도 빌드 되는 것을 확인할 수 있습니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2022/06/20220605_03.png"/>
</p><br/>

CI가 구축되어 있다면, CI가 돌면서 모듈을 테스트할 때 테스트 타겟을 빌드하고 테스트하게 되는데, 데모앱이 HOST Application으로 등록되어 있지 않으니 기동되지 않습니다. 빌드만 수행하므로 모듈을 리팩토링 하더라도 데모앱을 수정하지 않으면 테스트 타겟을 빌드하다가 에러가 발생하게 됩니다. 그러므로 데모앱을 지속적으로 관리할 수 있습니다.

[여기](https://github.com/minsOne/Experiment-Repo/tree/master/20220605-DemoAppSample)에서 위의 작업한 내역을 확인하실 수 있습니다.
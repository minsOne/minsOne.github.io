---
layout: post
title: "[iOS][Tuist 2.7.2] 프로젝트 생성/관리 도구 Tuist(6) - ProcessInfo Environment 기반 프로젝트 생성"
description: ""
category: ""
tags: [Swift, Xcode, Tuist, Environment, ProcessInfo]
---
{% include JB/setup %}

Tuist는 쉘에서 실행할 때, 환경변수를 읽어들여 개발자가 Project.swift 파일에서 사용할 수 있도록 지원합니다. [Guide - Generation-time configuration](https://docs.tuist.io/guides/environment/)

따라서 환경변수를 이용하여 프로젝트 생성할때 어떤 값을 넣었는지에 따라 제어가 가능함을 의미합니다.

예를 들어, `tuist generate` 명령어를 이용해서 App, DevApp 애플리케이션 타겟이 생성했다고 가정해봅시다.

```swift
// FileName: Project.swift
import Foundation
import ProjectDescription

let project = Project(
    name: "App",
    organizationName: "KakaoBank",
    targets: [
        Target(
            name: "App",
            platform: .iOS,
            product: .app,
            bundleId: "com.kakaobank.app",
            infoPlist: .default,
            sources: ["App/Sources/**"]),
         Target(
            name: "DevApp",
            platform: .iOS,
            product: .app,
            bundleId: "com.kakaobank.devApp",
            infoPlist: .default,
            sources: ["App/Sources/**",
                      "DevApp/Sources/**"]),
    ]
)
```

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2022/04/20220413_01.png"/></p>

만약 프로젝트에 추가된 파일 개수가 백개, 천개, 만개가 된다면, App, DevApp 타겟의 Build Phases의 Compile Sources는 최소한 동일한 파일을 프로젝트 파일에 추가되어 있다는 의미이며, 프로젝트 파일에는 의도치 않은 중복된 설정이 포함된다는 의미입니다. 

개발 중에는 App 타겟을 기반으로 작업보다는, DevApp 타겟을 기반으로 작업을 할 가능성이 많습니다.

그렇다면, `tuist generate` 할 때 환경변수를 넣어 프로젝트 생성시 원하는 애플리케이션 타겟만 노출되도록 하면 좀 더 경량화된 프로젝트 파일이 생성되므로, Xcode에서 프로젝트 로드 및 인덱싱 등이 빨라질 것입니다. 또한, 타겟이 하나만 노출되므로 파일 추가시 어떤 타겟에 파일을 추가해야 하는지 선택하는 것도 쉬워집니다.

Tuist에서 환경변수를 사용하기 위해서는 `TUIST_` 가 접두어로 붙습니다. 저는 `TUIST_DEPLOY` 라는 환경변수 이름을 사용할 것입니다.

ProcessInfo에서 환경변수를 가져와, 일반적인 로직을 작성하듯, 환경변수 기반으로 분기처리하는 코드를 작성합니다.

```swift
// FileName: Project.swift
import Foundation
import ProjectDescription

let tuistDeploy = ProcessInfo.processInfo.environment["TUIST_DEPLOY"]
let isDeploy = (tuistDeploy == "App")

let project = Project(
    name: "App",
    organizationName: "minsone",
    targets: [
        isDeploy
        ? Target(name: "App",
                 platform: .iOS,
                 product: .app,
                 bundleId: "kr.minsone.app",
                 infoPlist: .default,
                 sources: ["App/Sources/**"])
        : Target(name: "DevApp",
                 platform: .iOS,
                 product: .app,
                 bundleId: "kr.minsone.devApp",
                 infoPlist: .default,
                 sources: ["App/Sources/**",
                           "DevApp/Sources/**"])
    ])
```

```
$ TUIST_DEPLOY=App tuist generate
```

위와 같이 실행하면 App 애플리케이션 타겟만 있는 프로젝트가 생성됩니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2022/04/20220413_02.png"/></p>

환경변수를 넣지 않고 `tuist generate`를 실행하면 DevApp 애플리케이션 타겟만 있는 프로젝트가 생성됩니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2022/04/20220413_03.png"/></p>

## 정리

환경변수를 통해서 Tuist의 프로젝트 생성 제어가 가능하므로, 개발 환경을 좀 더 원할하게 만들 수 있습니다.

## 참고자료

* [Tuist/Tuist - Environment.swift](https://github.com/tuist/tuist/blob/main/Sources/ProjectDescription/Environment.swift#L17)
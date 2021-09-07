---
layout: post
title: "[iOS] 준 Clean Architecture With RIBs, ReactorKit 그리고 Tuist를 이용한 프로젝트 모듈화 설계(2) - Tuist"
description: ""
category: "Mac/iOS"
tags: [Swift, Xcode, Clean Architecture, RIBs, ReactorKit, Tuist]
published: false
---
{% include JB/setup %}

## 들어가기 전

Tuist를 이용하여 프로젝트를 구성할 것이므로, 어떻게 구조를 잡을 것인지 염두하고 작업해야 합니다. 그래야 모듈을 쉽게 추가할 수 있어, 확장이 가능합니다.

이 글은 Tuist 1.48.1 이상 버전이 설치되어 있음을 가정하고 작성되었습니다.

## 설정

**1.** `tuist init` 명령으로 Tuist 초기설정합니다.

```
$ tuist init
$ tree .
.
├── Project.swift
├── Targets
└── Tuist
    ├── Config.swift
    └── ProjectDescriptionHelpers
        └── Project+Templates.swift
```

Targets 폴더와 Project.swift 파일은 삭제합니다.

**2.**  클린 아키텍처에서 따르는 프로젝트 구조를 만족하기 위해 Projects라는 폴더를 만든 후, 다음 구조로 모듈을 구성할 것입니다.
```
$ tree Projects
Projects
├── Application
├── Features
│   ├── Features
│   ├── BaseDependency
│   │   ├── DataRepository
│   │   ├── Domain
│   │   └── UserInterface
│   ├── FeatureLoan
│   │   ├── DataRepository
│   │   ├── Domain
│   │   ├── Package
│   │   └── UserInterface
│   ├── FeatureMain
│   │   ├── DataRepository
│   │   ├── Domain
│   │   ├── Package
│   │   └── UserInterface
│   └── FeatureSettings
│       ├── DataRepository
│       ├── Domain
│       ├── Package
│       └── UserInterface
├── Modules
│   ├── AnalyticsKit
│   ├── CoreKit
│   ├── ThirdPartyLibraryManager
│   └── UtilityKit
├── Network
│   ├── NetworkAPIKit
│   ├── NetworkAPICommon
│   ├── NetworkAPIHome
│   ├── NetworkAPILogin
│   ├── NetworkAPIs
│   └── NetworkStub
└── UserInterface
    ├── DesignSystem
    ├── ResourcePackage
    └── UserInterfaceLibraryManager
```

각 폴더의 역할을 설명합니다.

* Application - 제품으로 나가는 애플리케이션을 관리하는 프로젝트로, AppDelegate, SceneDelegate, Push Notification, Widget 등을 다루고, 앱 시작시 어떤 기능으로 시작할지, 그리고 값 초기화, 설정 초기화 등을 처리하는 `프로젝트`입니다.
* Features - 화면 또는 비지니스로직 등 기능을 담당하는 준 클린 아키텍처 모듈을 모아두도록 하는 `폴더`입니다.
  * Features - 기능를 담당하는 준 클린 아키텍처 모듈의 집합인 Package 들을 의존성을 가지도록 하여 준 클린 아키텍처 모듈 전체를 관리하는 `프로젝트` 입니다.
  * FeatureMain - Main 기능을 담당하는 준 클린 아키텍처 모듈이 있는 `폴더`입니다.
    * DataRepository - Main 기능을 담당하는 준 클린 아키텍처에서 DataRepository를 담당하는 `프로젝트` 입니다.
    * Domain - Main 기능을 담당하는 준 클린 아키텍처에서 Domain을 담당하는 `프로젝트` 입니다.
    * UserInterface - Main 기능을 담당하는 준 클린 아키텍처에서 UserInterface을 담당하는 `프로젝트` 입니다.
    * Package - `DataRepository`, `Domain`, `UserInterface` 모듈을 묶어 관리하는 `프로젝트` 입니다.
  * FeatureLoan - 위와 상동
  * FeatureSettings - 위와 상동
* Modules - 각종 기능 모듈을 모아둔 `폴더`입니다.
  * AnalyticsKit - 앱로그를 담당하는 `프로젝트` 입니다.
  * CoreKit - AnalyticsKit, UtilityKit, ThirdPartyLibraryManager 등 모듈을 의존성 가지는 `프로젝트` 입니다. CoreKit을 의존성 가지면 하위 기능들을 다 사용할 수 있습니다.
  * ThirdPartyLibraryManager - 서드파티 라이브러리를 묶어 관리하는 `프로젝트` 입니다.
  * UtilityKit - 유틸리티 기능들을 담당하는 `프로젝트` 입니다.
* Network - 네트워크 모듈을 모아두는 `폴더`입니다.
  * NetworkAPIKit - 네트워크 기능의 기반으로 각종 API들이 만들어지도록 하는 `프로젝트` 입니다.
  * NetworkAPICommon - NetworkAPIKit 기반으로 Common API를 정의한 `프로젝트` 입니다.
  * NetworkAPIHome - NetworkAPIKit 기반으로 Home API를 정의한 `프로젝트` 입니다.
  * NetworkAPILogin - NetworkAPIKit 기반으로 Login API를 정의한 `프로젝트` 입니다.
  * NetworkAPIs - 각종 도메인 API 모듈을 모아서 관리하는 `프로젝트` 입니다.
  * NetworkStub - 빠른 개발을 위해 API의 Mock Response를 모아서 Stub 역할을 하는 `프로젝트` 입니다.
* UserInferface - 사용자 인터페이스 모듈을 모아두는 `폴더`입니다.
  * DesignSystem - 라이브러리를 이용하여 Design System을 정의 및 관리하는 `프로젝트` 입니다.
  * ResourcePackage - 앱에서 사용하는 리소스를 통합 관리하는 `프로젝트` 입니다.
  * UserInterfaceLibraryManager - UserInferface에서 사용할 라이브러리를 관리하는 `프로젝트` 입니다.

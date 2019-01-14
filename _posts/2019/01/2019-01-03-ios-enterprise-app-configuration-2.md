---
layout: post
title: "[iOS] Enterprise 규모 앱 환경 구성 - 3"
description: ""
category: "iOS/Mac"
tags: [iOS, XCode, Project, CocoaPods, Carthage, Layer, Library, Framework]
---
{% include JB/setup %}

이번 글에서는 신규 프로젝트에서 Layer들을 어떤 순서로 나눠야 하는지 기술해보려고 합니다.

### 1. 라이브러리 모듈

일반적으로 프로젝트는 CocoaPods, Carthage 또는 Git Submodule로 외부 라이브러리를 가져다 사용하고, 라이브러리를 사용하는 곳에서 `import 라이브러리`를 합니다. 

여기에서 우리는 프로젝트와 라이브러리 간의 커플링이 생겼고, 점점 많은 곳에서 해당 라이브러리를 직접 사용하므로, 프로젝트 전체를 타이트하게 만듭니다. 

그러다 라이브러리가 문제가 생기거나 라이브러리를 잘못 사용하거나 혹은 라이브러리를 교체할 때, 프로젝트 전체를 다 고쳐야합니다.

그러므로 라이브러리를 Framework로 가지는 프로젝트를 만드는 것이 좋습니다.

[의존성 주입하기](../ios-dependency-injection) 글의 방법을 이용하여 라이브러리와 본 프로젝트 간의 코드 커플링을 끊을 수 있고, 프로젝트 설정은 [Splitting A Workspace into Modules](https://edit.theappbusiness.com/modular-ios-splitting-a-workspace-into-modules-331293f1090)글과 같이 설정하거나 상황에 맞게 해야합니다.

하지만 `RxSwift` 같은 라이브러리는 의존성 끊기가 어렵기 때문에 그냥 사용하는 것이 더 나을 수 있습니다. 일반적인 유틸성 라이브러리는 가져다 사용하지만, RxSwift와 같은 라이브러리는 라이브러리 위에서 개발하기 때문입니다.

또한, 각 모듈간의 중복코드가 일부 있어도 문제가 되지 않는다고 생각합니다. 대부분 생성되는 중복코드는 좀 더 쉽게 사용하도록 하는 코드이기 때문입니다. 물론 모듈로 나눴기 때문에 테스트 코드를 작성해야 하지 않을까 싶습니다.

### 2. 라이브러리 모듈 패키지

다른 라이브러리와 결합을 하여 기능을 확장된 기능을 가집니다. 예를 들면, 이미지 다운로드 모듈의 이미지 다운로드 비동기 요청을 RxSwift로 감싸 Observable을 반환하는 함수를 만든다던지, RxSwift의 doOnNext에 앱로그 요청을 결합한 새로운 RxSwift의 오퍼레이터를 만들수도 있습니다.

### 3. 서비스 모듈화 - Domain Layer

각 서비스는 UI 레이어, 비즈니스 레이어 그리고 리소스 레이어를 가집니다. 

UI 레이어는 View, ViewController, ViewModel 등 View에 관련된 것들을 가집니다.

<p style="text-align:center;"><img src="/../../../../image/2019/01/enterprise_ui_layer.png" alt="UI Layer" style="width: 300px"/></p><br/>

리소스 레이어는 네트워크 요청, DB 조회 등의 서비스를 가지며, 비즈니스 레이어에서는 비즈니스 로직를 가지고, 리소스 레이어를 통해 데이터를 조회하거나 요청합니다.

<p style="text-align:center;"><img src="/../../../../image/2019/01/enterprise_business_resource_layer.png" alt="Business Resource Layer" style="width: 300px"/></p><br/>

그리고 UI 레이어는 비즈니스 레이어를 가지고 있어, UI 이벤트를 비즈니스 레이어에서 처리하고 응답받은 결과를 받아 처리하도록 합니다.

<p style="text-align:center;"><img src="/../../../../image/2019/01/enterprise_ui_business_resource_layer.png" alt="UI Business Resource Layer" style="width: 300px"/></p><br/>

이와 같은 레이어들을 묶은 것을 도메인 레이어라고 하고, 개발 환경, 조직에 따라 `UI, Business, Resource` 를 한 세트로 묶거나 Layer 단위로 `UI Layer`만 묶고, `Business Layer`만 묶고, `Resource Layer`만 묶을 수도 있습니다.

**UI, Business, Resource Layer 그룹**
<p style="text-align:center;"><img src="/../../../../image/2019/01/enterprise_domain_layer_group_1.png" alt="Domain Layer 1" style="width: 500px"/></p><br/>

**각각의 UI Layer, Business Layer, Resource Layer 그룹**
<p style="text-align:center;"><img src="/../../../../image/2019/01/enterprise_domain_layer_group_2.png" alt="Domain Layer 1" style="width: 500px"/></p><br/>

### 4. 메인 서비스, 어플리케이션

Application은 앱 구동시 처리하는 Layer로 가장 최상위 Layer로서 모든 레이어를 가집니다.

그리고 Application은 어떤 메인 서비스를 호출할 것인지를 정합니다. 예를 들어, 로그인 기능을 가진 앱인 경우, AuthToken을 기준으로 AuthToken이 발급되기 전, 후 서비스로 나눕니다. 

즉, 어떤 메인 서비스를 호출할지를 특정 조건에 따라 결정되므로, 트리 구조로 서비스들이 구성됩니다.

<p style="text-align:center;"><img src="/../../../../image/2019/01/enterprise_application_main_layer.png" alt="Domain Layer 1" style="width: 500px"/></p><br/>

## 정리 & 사족

* 어플리케이션부터 시작하여, 트리구조로 각 서비스들이 추가가 됩니다.
* 어떻게 묶어야 할지 파트에서 의견을 잘 정리하여 방향을 잘 설정해야합니다.
* UI, Business, Resource를 각각으로 묶을 것인지 한 세트로 묶어서 할 것인지 둘다 장단점이 있어서 고민됩니다.

## 참고자료

* [A Framework for iOS Application Development](https://pdfs.semanticscholar.org/5cf0/4ee81dac8e09580d5eac312428d07f2abcc6.pdf)
* [Coupang Android Architecture — Part 3 리패키징을 통한 의존성 제거(Reducing dependencies through repackaging)](https://medium.com/coupang-tech/coupang-android-architecture-part-3-ac336f435a17)
* [Coupang Android Architecture — Part 2 안드로이드 애플리케이션 모듈화 (Modularizing Android Applications)](https://medium.com/coupang-tech/coupang-android-architecture-part-2-3448d8f1099b)
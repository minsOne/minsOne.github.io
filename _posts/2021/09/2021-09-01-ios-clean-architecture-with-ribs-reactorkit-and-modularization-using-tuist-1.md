---
layout: post
title: "[iOS] 준 Clean Architecture With RIBs, ReactorKit 그리고 Tuist를 이용한 프로젝트 모듈화 설계(1) - 설계편"
description: ""
category: "Mac/iOS"
tags: [Swift, Xcode, Clean Architecture, RIBs, ReactorKit, Tuist]
---
{% include JB/setup %}

* [1편 - 설계편]({{BASE_PATH}}/mac/ios/ios-clean-architecture-with-ribs-reactorkit-and-modularization-using-tuist-1)
* [2편 - Tuist]({{BASE_PATH}}/mac/ios/ios-clean-architecture-with-ribs-reactorkit-and-modularization-using-tuist-2)
* [3편 - UserInterface]({{BASE_PATH}}/mac/ios/ios-clean-architecture-with-ribs-reactorkit-and-modularization-using-tuist-3)
* [4편 - Presentation, Domain]({{BASE_PATH}}/mac/ios/ios-clean-architecture-with-ribs-reactorkit-and-modularization-using-tuist-4)
* [5편 - Repository, Data, DI Container]({{BASE_PATH}}/mac/ios/ios-clean-architecture-with-ribs-reactorkit-and-modularization-using-tuist-5)

# 들어가기 전

여기에서 사용하는 클린 아키텍처는 Android에서 설계된 구조를 많이 참고하였습니다.

<p style="text-align:center;"><img src="{{ site.production_url }}/image/2021/09/20210901_01.png" /></p>

출처 : [Github - bufferapp/clean-architecture-components-boilerplate](https://github.com/bufferapp/clean-architecture-components-boilerplate)

클린 아키텍처를 iOS 형태에 맞춰 구현한 프로젝트들은 존재를 하지만, 실제 해당 프로젝트들은 한 프로젝트에서 작업한 방식들이 대부분입니다. 따라서 이 부분을 프레임워크 기반으로 각각을 모듈로 나누고, 개발하는 방식을 이야기 하려고 합니다.

<br/><br/>

# 설계도

다음은 전체적인 설계 구조입니다.

<p style="text-align:center;"><img src="{{ site.production_url }}/image/2021/09/20210901_02.png" /></p>

**User Interface**, **Presentation-Domain**, **Data-Remote**, **RepositoryInjectManager**, **ThirdPartyLibrary**, **Application** 으로 구성되어 있습니다. 

해당 모듈을 하나씩 풀어서 설명하려고 합니다.

## User Interface

User Inteface는 다음과 같은 구조를 가지고 있습니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/09/20210901_03.png" style="width: 200px"/></p>

### Resource

애플리케이션에서 공통으로 사용해야할 모듈 중 하나는 리소스입니다. 리소스는 애플리케이션의 모든 부분에서 사용되는 Image, Color, WebP, Lottie, Storyboard, Xib 등이 있습니다. 각 기능 단위로 모듈을 만들어 리소스를 관리하게 되면 필요한 리소스만 관리한다고 생각할 순 있지만, 각 모듈의 리소스 간에 중복된 리소스가 생기게 되며 이를 관리하기 어려워지게 됩니다. 이를 해결하기 위해서는 리소스를 관리하는 모듈을 만들어야 합니다.

또한, 리소스를 관리해야하기 때문에 이 모듈은 Mach-O가 `Dynamic Library` 이거나, `Swift Package`로 관리해야 합니다. Dynamic Library로 관리하면 프레임워크 내에 리소스가 위치하여 관리할 수 있습니다. 또한, Swift Package로 관리하면, 앱 타겟 빌드시 메인 번들에 리소스 번들을 만들어 복사하는 방식으로 관리할 수 있습니다.

### Design System

디자인 시스템 모듈은 리소스를 의존성을 가지며, 또한, SwiftUI, [FlexLayout](https://github.com/layoutBox/FlexLayout), [Yoga](https://github.com/facebook/yoga), [SnapKit](https://github.com/SnapKit/SnapKit), [Texture](https://github.com/TextureGroup/Texture), [Render](https://github.com/alexdrone/Render) 등을 사용하여 애플리케이션의 디자인을 구현하기 위해 기반을 마련하도록 만드는 모듈입니다. 기본적인 컴포넌트를 제공하여 디자인 시스템 모듈을 가져다 기능 화면들을 구성할 수 있도록 제공합니다.

### Feature UserInterface, Action, State

디자인 시스템 모듈에 의존성을 가져 기능별 View, ViewController을 빠르게 구성합니다. 그리고 어떤 상태를 받을지, 어떤 액션을 넘겨줄지 정의합니다. 이는 화면 개발시 의존성을 최대한 끊고, 상태만 받아 업데이트를 하고, 액션을 listener에 전달하기만 하면 됩니다. 기능에 의존성이 없어지기 때문에 화면을 빠르게 확인하고 개발이 가능합니다.

### Feature UserInterface DemoApp

UserInterface 모듈을 의존성을 가져 기능별 View, ViewController를 빠르게 확인하고 기능을 테스트합니다. 화면만 보여주는 테스트용 앱을 만들기 때문에, 원하는 상태만 만들어 View, ViewController를 업데이트 하면 되기 때문입니다.

-----

위에서 Resource, Design System, Feature UserInterface를 설명하였습니다. UserInterface는 View와 관련된 의존성만 가지도록 하여 빌드시 시간을 줄여, 빠른 빌드를 확보할 수 있습니다.

## Presentation과 Domain

Uber의 [RIBs](https://github.com/uber/RIBs) 아키텍처를 도입하여, Presentation 영역에서 사용하려고 합니다. 그리고 Presentation과 Domain은 모듈 하나로 작업하는 형태로 설계하였습니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/09/20210901_04.png"/></p>

### Presentation - State, Action, Mapper, Presentation

UserInterface의 State, Action과 동일한 구조를 가집니다. 이는 Presentation 모듈이 UserInterface 모듈과 강결합을 하지 않기 위함입니다. Interactor, Router를 테스트하기 위해 UserInterface에 정의된 타입을 가져다 사용하게 되면 강결합이 발생하는데, Presentation 모듈에 중복된 코드가 있다면 모듈간의 결합도를 줄여지게 됩니다.

UserInterface 모듈에서 전달한 Action을 Presentation 모듈에 정의된 Action으로 변환해서 Interactor에 전달합니다. 그리고 Interactor에서 처리된 State를 UserInterface 모듈에 전달하기 위해 UserInterface 모듈에 정의된 State로 변환해야합니다. 이를 Mapper에서 처리하도록 합니다.

Presentation는 UserInterface의 ViewController를 가져 Interactor에 Action을 전달하거나, State를 전달받고, Router를 통해 UserInterface 모듈의 UIViewController를 업데이트하는 등의 역할을 합니다.

### Presentation - Interactor, Router, Builder

Interactor는 비지니스로직을 처리를 담당하며, Router는 라우팅을 담당합니다. 그리고 Builder는 Presentation, Interactor, Router, UseCase 등을 묶어 하나의 단위로 묶어줍니다 Uber의 RIBs 역할을 그대로 수행합니다.

### Domain

UseCase 인터페이스를 정의하면 Presentation에 Interactor가 UseCase를 가져다 호출하도록 합니다. Repository는 인터페이스를 정의하도록만 합니다. 이는 Repository는 API, Security 등의 모듈들이 필요하기 때문에, 이를 가져다 사용하게 되면, 해당 의존성이 추가됩니다. 그러면 도메인 모듈을 빌드하기 위해 API, Security 등의 모듈을 빌드하므로 빌드시간이 늘어납니다. 따라서 생산성이 떨어지고, 코드가 복잡해지는 것을 방지하기 위해 도메인 모듈만을 빌드 하도록 합니다.

하지만 Repository 구현체를 사용해야하는데, 이는 DIContainer를 이용하여 Repository 구현체를 사용할 수 있도록 [Swinject](https://github.com/Swinject/Swinject)를 이용합니다. 이는 의존성을 추가하지 않고, 코드를 짧게 하고, 생산성을 높여줍니다.

-----

저는 Presentation, Domain 모듈을 하나의 모듈로 합쳐서 Domain으로 구현하는 것을 추천합니다. Presentation과 Domain이 결합도가 높지만, Domain에서 Repository 모듈간의 의존성을 없앴기 때문에 Presentation과 Domain을 같이 개발하는 것이 큰 문제가 없다고 생각합니다. 

하지만 Presentation과 Domain이 점점 커지게 되면 각 모듈로 분리하는 것을 추천합니다. (모듈 분리는 기존에 한땀한땀 프로젝트 만들고 의존성을 엮는것이 어려웠지만, Tuist를 이용하면 간단하게 프로젝트를 만들어 모듈 분리할 수 있습니다.)

## Data와 Remote(고민중)

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/09/20210901_05.png"/></p>

### Data와 Remote

Domain 모듈을 의존성 가지며, Repository Interface를 구현합니다. Repository는 API, Cache, Database 등의 모듈에 있는 기능을 가져다 사용합니다. 지금 구조로 구현하면 Data 모듈은 의존성을 모두 가져오기 때문에, 이 부분은 Data에서 Remote의 의존성을 없애고 Repository Interface를 Data 모듈에서 구현하는 방식과 같이 설계 할 것인지 고민중입니다. 

## ThirdPartyLibrary

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/09/20210901_06.png" style="width: 400px"/></p>

ThirdPartyLibrary는 Third-Party 라이브러리를 관리하는 모듈로, ThirdPartyLibrary에 Swinject의 Container를 만들어 ThirdPartyLibrary 모듈을 의존성을 가지는 모든 모듈이 동일한 Swinject Container를 사용할 수 있도록 합니다.

## RepositoryInjectManager

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/09/20210901_07.png"/></p>

RepositoryInjectManager 모듈은 Domain 모듈에 있는 Repository Interface(Protocol)와 Data 모듈에 있는 Repository Implementation(Class)를 ThirdPartyLibrary 모듈에 있는 Swinject Container에 등록하도록 합니다. 

각각 Swinject Container에 등록하는 것이 아닌 RepositoryInjectManager가 등록하여, 애플리케이션에서 등록되는 Repository Implementation는 언제든지 접근하더라도 동일한 구현 클래스임을 만들어 줍니다.

## Application

애플리케이션은 시작할 때, ThirdPartyLibrary의 Swinject의 Container를 생성하도록 요청하고, RepositoryInjectManager 모듈을 통해 사용할 Repository를 등록시키고, Presentation에 있는 RIB을 접근하여 RIB이 시작될 수 있도록 합니다.

즉, 모든 시작점의 위치가 애플리케이션입니다.

---

<br/><br/><br/>

## 참고자료

* [Bruno Rocha: Preparing for Growth: Architecting Giant Apps for Scalability and Build Speed](https://www.youtube.com/watch?v=sZuI6z8qSmc)
* [\[iOS, Swift\] Clean Architecture With MVVM on iOS(using SwiftUI, Combine, SPM)](https://tigi44.github.io/ios/iOS,-Swift-Clean-Architecture-with-MVVM-DesignPattern-on-iOS/)
* [\[iOS - swift\] clean architecture를 적용한 MVVM 코드 맛보기](https://ios-development.tistory.com/559)
* [Clean Architecture and MVVM on iOS](https://tech.olx.com/clean-architecture-and-mvvm-on-ios-c9d167d9f5b3)
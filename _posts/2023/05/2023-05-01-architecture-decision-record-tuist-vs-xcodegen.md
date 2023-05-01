---
layout: post
title: "[ADR][가상] 아키텍처 의사 결정 기록: Xcode 프로젝트 생성 도구 선택하기 Tuist vs XcodeGen"
tags: [ADR, Tuist, XcodeGen, Xcode]
---
{% include JB/setup %}

Contents:

* [상태](#status)
* [Context](#context)
* [결정](#decisions)
  * [이유](#rationale)
* [결과](#consequences)
* [결론](#conclusion)
* [노트](#note)

## Xcode 프로젝트 생성 도구 선택하기 - Tuist vs XcodeGen

작성일 : 2022-05-01  
작성자 : 안정민

<h2 id="status">상태</h2>

수락됨

* 프로젝트 생성을 잘 관리할 수 있는 새로운 도구를 사용할 수 있게 된다면 다시 논의합니다.

<h2 id="context">Context</h2>

프로젝트가 커짐에 따라 프로젝트 파일 충돌, 결합도 증가, 빌드 시간 증가, 작성한 코드의 결과 확인의 어려움 등이 있습니다. 별도의 프로젝트, 라이브러리로 코드를 분리하여 프로젝트의 운영, 유지보수성과 확장성을 높이려고 합니다. 그러나 이런 작업은 반복적이고 복잡한 작업일 수 있으며, 실수할 가능성이 있습니다.

* 자동화된 프로젝트 생성 도구를 사용하여 안정적으로 모듈을 만들 수 있는 환경을 구축하길 원합니다.
* 모듈, 데모앱, 테스트 등을 지원해줄 수 있는 구조를 고려하고 싶습니다.

<h2 id="decisions">결정</h2>

요구 사항을 신중하게 고려하고 평가한 후 프로젝트 생성을 위해 선호하는 도구로 Tuist를 선택하기로 결정했습니다.

<h4 id="rationale">이유</h4>

Tuist와 XcodeGen 모두 Xcode 프로젝트를 생성하는데 널리 사용되는 도구이며, 둘 다 장단점이 있습니다. 프로젝트 요구 사항과 팀 전문성을 신중하게 고려한 후 다음과 같은 이유로 Tuist를 사용하기로 결정했습니다.

* 사용 용이성 : Tuist는 Swift 언어로 Manifest를 작성할 수 있어, 해당 파일을 읽고 이해하기 쉬우므로 개발자가 Tuist에 심층적인 지식 없이도 프로젝트를 생성할 수 있습니다. 또한, Mach-O에 따라 프레임워크, 라이브러리의 Embed 설정 및 의존성 관리를 Tuist는 쉽게 관리해줄 수 해줍니다.
* 확장성 : Tuist는 최소한의 구성으로 복잡한 프로젝트 구조를 쉽게 관리할 수 있으므로 여러 대상과 종속성이 있는 대규모 프로젝트에 적합합니다.
* 가시화 : Tuist에서 모듈 간의 의존성 그래프를 다양한 포맷으로 지원하여 분석하여 모듈 간의 의존성 정리하는데 적합합니다.

XcodeGen도 자체적인 이점이 있는 훌륭한 도구이지만 Tuist가 우리 프로젝트의 특정 요구 사항에 더 적합하다고 생각합니다.

<h2 id="consequences">결과 및 영향</h2>

Tuist를 개발 프로세스에 통합하려면 몇 가지 추가 설정 및 구성이 필요합니다.

* Tuist 구성 파일 생성 및 유지 관리, 개발자가 도구에 익숙해지도록 시간 필요
* 새 도구를 수용하기 위해 기존 작업 흐름을 수정하는 작업
* Tuist 기반 코드 이전 비용 검토

<h2 id="conclusion">결론</h2>

우리는 Tuist 사용의 이점이 이러한 초기 비용을 능가하고 궁극적으로 보다 확장 가능하고 유지 가능한 프로젝트 구조로 이어질 것이라고 판단됩니다.

<h2 id="notes">노트</h2>

당근마켓  
[Tuist 를 활용해 확장 가능한 모듈 구조 만들기](https://medium.com/daangn/tuist-%EB%A5%BC-%ED%99%9C%EC%9A%A9%ED%95%B4-%EB%AA%A8%EB%93%88-%EA%B5%AC%EC%A1%B0-%EC%9E%90%EB%8F%99%ED%99%94%ED%95%98%EA%B8%B0-f200992d4bf2)

29CM  
[iOS Modular Architecture 를 향한 여정 Part 1 — XcodeGen 도입과 모듈화의 시작](https://medium.com/29cm/modular-architecture-%EB%A5%BC-%ED%96%A5%ED%95%9C-%EC%97%AC%EC%A0%95-part-1-xcodegen-%EB%8F%84%EC%9E%85%EA%B3%BC-%EB%AA%A8%EB%93%88%ED%99%94%EC%9D%98-%EC%8B%9C%EC%9E%91-19a7f7b6401a)  
[iOS Modular Architecture 를 향한 여정 Part 2 — 프로젝트 모듈화, 레거시와 공존하기](https://medium.com/29cm/ios-modular-architecture-%EB%A5%BC-%ED%96%A5%ED%95%9C-%EC%97%AC%EC%A0%95-part-2-%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8-%EB%AA%A8%EB%93%88%ED%99%94-%EB%A0%88%EA%B1%B0%EC%8B%9C%EC%99%80-%EA%B3%B5%EC%A1%B4%ED%95%98%EA%B8%B0-d63f5e454573) 

[모듈식 iOS 가이드](https://anuragajwani.medium.com/modular-ios-guide-60810f5a7f97)  

[Xcode Previews를 사용하여 UIKit 기반 프로젝트 개발 효율성](https://engineering.mercari.com/blog/entry/2019-12-13-155700/)  

에어비앤비  
[대규모 iOS 앱 개발 생산성을 위해 바꾼 것들](https://yozm.wishket.com/magazine/detail/1330/)  

MIXI  
[iOS 앱 설계에 Clean Architecture를 채용하여 약 3년 운용해 온 지견](https://mixi-developers.mixi.co.jp/mitene-ios-clean-architecture-11d23325553d)  

mitene  
[미테네에서의 iOS 앱 개발의 현재 상황과 과제에 대한 대처](https://team-blog.mitene.us/ios-development-2022-2d60d16e7135)  

[인프라 지속성 계층 디자인](https://docs.microsoft.com/ko-kr/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/infrastructure-persistence-layer-design)  

Slack  
[Slack의 모바일앱 리팩토링 모듈화](https://medium.com/mobile-app-development-publication/mobile-app-refactoring-initiative-by-slack-fedc4c4a6026)  

Trendyol  
[트렌디올의 iOS 앱 개편: 모듈화 성공 사례](https://medium.com/trendyol-tech/revamping-trendyols-ios-app-a-modularization-success-story-a6c1d2c4188b)  


쿡패드  
[iOSDC Japan 2021 - 대규모 앱의 멀티모듈 구성 실습](https://www.youtube.com/watch?v=LCOU2ZlGKi4)  
[코드 생성을 이용한 iOS 앱 멀티 모듈화를 위한 종속 솔루션](https://techlife.cookpad.com/entry/2021/06/16/110000)  
[쿡 패드 iOS 앱의 파괴와 창조, 그리고 미래](https://techconf.cookpad.com/2019/kohki_miki.html)

Just Eat  
[Modular iOS Architecture](https://tech.just-eat.com/2019/12/18/modular-ios-architecture-just-eat/)  

Depop  
[Scaling up an iOS app using modules](https://engineering.depop.com/scaling-up-an-ios-app-with-modularisation-8cd280d6b2b8)  

iOS Architecture Patterns for Large-Scale Development  
[part 1: Modular architecture](https://blog.griddynamics.com/modular-architecture-in-ios/)  
[part 2: Dependency management](https://blog.griddynamics.com/dependency-management/)  
[part 3: UI architecture approach](https://blog.griddynamics.com/ui-architecture-approach/)  

The Washington Post  
[Scaling iOS Architecture](https://github.com/ArtSabintsev/iOSDevCampDC-2018/blob/master/Scaling-iOS-Architecture.md)

Badoo  
[iOS 앱 모듈화: Badoo 앱을 모듈로 세분화한 이유와 방](https://medium.com/bumble-tech/modularising-an-ios-app-3ea131a5c809)  
[Badoo iOS 앱 모듈화: 노크온 효과 처리하기](https://medium.com/bumble-tech/modularising-the-badoo-ios-app-ce75d5a7aba7)  

Spotify
[성장을 위한 준비: 확장성 및 빌드 속도를 위한 대규모 앱 아키텍처 설계하기](https://www.youtube.com/watch?v=sZuI6z8qSmc)  

[\[Swift\] Bastard Injection의 문제점, 혹은 의존성 반전의 원리에 대해서 또는 needle이라는 DI 컨테이너 소개](https://qiita.com/YusukeHosonuma/items/77bbb962e8ec4d36cbea)  

Wayfair  
[앱 모듈화: 코드와 Android 및 iOS 팀을 대규모로 확장한 방법](https://www.aboutwayfair.com/tech-blog/app-modularization-at-wayfair-how-we-unlocked-our-code-and-android-and-ios-teams-at-scale)  

Capital One
[플러그인 기반 아키텍처 및 확장형 iOS 개발](https://medium.com/capital-one-tech/plugin-based-architecture-and-scaling-ios-development-at-capital-one-fb67561c7df6)


---
layout: post
title: "[ADR][가상] 아키텍처 의사 결정 기록: Feature 모듈에서 UI 모듈 분리 결정"
tags: [ADR, Module, UI, Feature, Preview]
---
{% include JB/setup %}

Contents:

* [상태](#status)
* [배경](#context)
* [결정](#decisions)
  * [이유](#rationale)
* [결과](#consequences)
* [결론](#conclusion)

## Feature 모듈과 UI 모듈 분리 결정

작성일 : 2023-05-07  
작성자 : 안정민

<h2 id="status">상태</h2>

* 수락됨(Accepted)
  
<h2 id="context">배경</h2>

* 프로젝트의 규모가 커지고, 다양한 기능 및 UI 컴포넌트가 추가되어 코드의 복잡성이 증가함
* 각 Feature 모듈 내에서 UI와 로직 코드가 섞여있어 가독성과 유지보수성이 떨어짐
* 각 Feature별 UI를 별도의 모듈로 분리하여 사용하려 함

<h2 id="decisions">결정</h2>

Feature 모듈에서 UI를 별도의 모듈로 분리하여 사용하기로 결정

<h4 id="rationale">이유</h4>

* 모듈화를 통해 코드의 가독성과 유지보수성을 향상시킬 수 있음
* UI와 비즈니스 로직을 분리함으로써 각 부분에 대한 책임이 명확해짐
* 독립된 UI 모듈을 통해 테스트가 용이해짐

<h2 id="consequences">결과 및 영향</h2>

Feature 모듈에서 UI를 별도의 모듈로 분리하면 다음과 같은 결과를 기대할 수 있습니다.

* UI와 비즈니스 로직을 명확하게 분리되어 개별적으로 관리할 수 있어 코드의 가독성이 증가하고, 유지보수가 용이해짐.
* 모듈 간의 책임이 명확해짐.
* 독립된 독립된 UI 모듈은 필요한 의존성만 가져 빌드 시간 감소를 통해 Preview 기능을 활용할 수 있음. 이를 통해 다양한 상태를 테스트하는 것이 용이해짐
* 비즈니스 로직의 테스트 코드 작성이 용이해짐

다음과 같은 사항에 대해 보완해야합니다.

* UI를 별도로 분리한 예제 코드 작성
* Tuist 템플릿 작성
* 원활한 Preview 환경 구축

<h2 id="conclusion">결론</h2>

* 프로젝트의 규모가 커지고, Feature별로 코드가 복잡해질 경우, UI를 별도의 모듈로 분리하여 사용하는 것이 가독성, 유지보수성, 개발 시간 단축에 긍정적인 영향을 미칠 것으로 판단됨
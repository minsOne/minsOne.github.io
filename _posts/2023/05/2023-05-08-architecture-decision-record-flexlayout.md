---
layout: post
title: "[ADR][가상] 아키텍처 의사 결정 기록: FlexLayout 기반 UI 작성 결정"
tags: [ADR]
---
{% include JB/setup %}

Contents:

* [상태](#status)
* [배경](#context)
* [결정](#decisions)
  * [이유](#rationale)
* [결과](#consequences)
* [결론](#conclusion)
* [노트](#note)

## FlexLayout 기반 UI 작성 결정

작성일 : 2022-05-08  
작성자 : 안정민

<h2 id="status">상태</h2>

* 수락됨(Accepted)
  
<h2 id="context">배경</h2>

* 프로젝트에서 UI를 효율적이고 유연하게 작성하고 관리할 필요가 있음
* Auto Layout을 사용하여 UI를 작성하는 것이 복잡하거나 제한적일 수 있음
* 더 나은 대안이 있는지 검토하고자 함

<h2 id="decisions">결정</h2>

* FlexLayout 라이브러리를 사용하여 UI를 작성하기로 결정

<h4 id="rationale">이유</h4>

* FlexLayout을 사용하면 UI 요소 간의 상대적인 크기와 위치를 쉽게 조절할 수 있어, 다양한 화면 크기에 대응하는 UI를 효율적으로 작성할 수 있음
* Auto Layout보다 코드가 간결하고 이해하기 쉬워, 개발 속도를 높이고 유지보수를 용이하게 할 수 있음
* 추후 SwiftUI 기반으로 UI를 작성할 때 리팩토링이 기존 Auto Layout 기반보다 용이할 것으로 추정됨

<h2 id="consequences">결과 및 영향</h2>

UI를 FlexLayout을 이용하여 UI를 작성한다면 다음과 같은 결과를 기대할 수 있습니다.

* 코드가 간결하고 이해하기 쉬워지므로 개발자들의 생산성이 향상됨
* 유지보수성이 개선되어 코드의 변경이나 수정이 쉬워짐

다음과 같은 사항에 대해 보완해야합니다.

* 특정 경우에 UI 요소의 크기와 위치의 계산이 무한 루프가 도는 경우가 있음
* 일관성있게 UI를 작성하도록 템플릿 및 예제가 필요함.

<h2 id="conclusion">결론</h2>

* FlexLayout을 사용하여 UI를 작성하는 것이 Auto Layout보다 유연하고 효율적인 방법임이 확인되었으므로, 이를 적용하여 프로젝트의 UI를 개발하기로 결정
* FlexLayout을 사용하여 프로젝트의 개발 속도, 유지보수성, 코드 재사용성 등의 측면에서 이점을 얻을 것으로 기대됨

<h2 id="notes">노트</h2>

* [layoutBox/FlexLayout](https://github.com/layoutBox/FlexLayout)
* [minsOne/FlexUI](https://github.com/minsOne/FlexUI)
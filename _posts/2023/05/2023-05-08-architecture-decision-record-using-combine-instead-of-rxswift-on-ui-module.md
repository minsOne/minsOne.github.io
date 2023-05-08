---
layout: post
title: "[ADR][가상] 아키텍처 의사 결정 기록: UI 모듈에서 Combine 사용"
tags: [ADR, Combine]
published: false
---
{% include JB/setup %}

Contents:

* [상태](#status)
* [배경](#context)
* [결정](#decisions)
  * [이유](#rationale)
* [결과](#consequences)
* [결론](#conclusion)

## UI 모듈에서 Combine 사용

작성일 : 2022-05-08  
작성자 : 안정민

<h2 id="status">상태</h2>

* 제안됨(Proposed)
  
<h2 id="context">배경</h2>

* RIBs 아키텍처 기반으로 인해 UI 모듈에서 RxSwift, RxCocoa를 사용하고 있음
* UI 모듈은 최소한의 외부 의존성을 가지도록 하기 위해 애플의 Combine 프레임워크를 사용하는 것을 제안함
* 추후 SwiftUI로 화면을 작성할 때 Combine, Concurrency를 사용해야하므로 나중에 리팩토링하는 비용을 줄이고자 함

<h2 id="decisions">결정</h2>

* UI 모듈에서 RxSwift 대신 Combine을 사용하기로 함

<h4 id="rationale">이유</h4>

* Combine은 애플에서 제공하는 프레임워크로, Swift 및 애플 플랫폼과의 호환성이 뛰어남
* 프로젝트의 유지 보수성을 고려하면, Combine을 사용하는 것이 더 나은 선택일 수 있음
* UI 모듈에서는 복잡한 연산자가 필요없어, RxSwift, RxCocoa, RxRelay를 모두 다 사용할 필요가 없음

<h2 id="consequences">결과 및 영향</h2>

* RxSwift에서 Combine으로 전환하는 작업에 시간이 소요될 것임
* 기존에 RxSwift를 사용한 코드는 전환 과정에서 수정이 필요함
* 팀원들이 Combine에 대한 학습이 필요할 수 있음
* 프로젝트의 성능 향상 및 유지 보수성을 기대할 수 있음

<h2 id="conclusion">결론</h2>

* UI 모듈에서 Combine을 사용하는 것이 프로젝트의 성능 향상 및 유지 보수성을 위한 좋은 선택임이 확인되었음
* 프로젝트 팀은 이 결정에 따라 전환 작업을 진행하고, 팀원들은 Combine에 대한 학습을 통해 프로젝트에 기여할 것으로 기대됨
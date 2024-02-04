---
layout: post
title: "[ADR][가상] 아키텍처 의사 결정 기록: 수많은 모듈의 Unit Test의 Host Application을 None으로 설정 결정"
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

## 수많은 모듈의 Unit Test의 Host Application을 None으로 설정 결정

작성일 : 2024-02-05
작성자 : 안정민

<h2 id="status">상태</h2>

* 수락됨(Accepted)
  
<h2 id="context">배경</h2>

* 모듈 기반으로 개발함에 따라 수많은 데모앱을 만들어 왔음
* 모듈마다 Unit Test 타겟을 만들고, Host Application에 모듈의 데모앱을 설정하는 방식으로 개발함
* XCTestPlan을 이용해 모든 모듈의 테스트를 수행함에 따라, 모든 데모앱이 빌드가 되어, Derived Data의 용량이 엄청 늘어나는 문제가 발생함

<h2 id="decisions">결정</h2>

* Unit Test에서 Host Application를 `None`으로 설정하며, 필요한 경우에만 설정하도록 함

<h4 id="rationale">이유</h4>

* CI 환경의 부하를 경감하기 위해 Unit Test에서 Host Application를 `None`으로 설정

<h2 id="consequences">결과 및 영향</h2>

* 모듈의 Unit Test의 Host Application을 `None`으로 설정함으로써, CI의 용량 문제가 줄어들었음
* 기존 Unit Test의 Host Application이 데모앱으로 설정되어 있을 때는, Unit Test가 빌드될 때, 데모앱도 빌드가 되어, 지속적인 관리를 할 수 있었지만, Host Application을 `None`으로 설정함으로써 데모앱의 관리는 각 조직에서 관리하는 방식으로 변경되어야 함

<h2 id="conclusion">결론</h2>

* 모듈의 Unit Test의 Host Application을 `None`으로 설정함으로써, 데모앱의 유지보수는 각 조직에서 하도록 하지만, CI 환경의 부하를 경감하기 위한 선택으로, 이점이 데모앱의 관리 비용보다 크다고 생각합니다.
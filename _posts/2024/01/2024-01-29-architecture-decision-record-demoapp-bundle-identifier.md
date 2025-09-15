---
layout: post
title: "[ADR][가상] 아키텍처 의사 결정 기록: 수많은 데모앱의 Bundle Identifier 관리 결정"
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

## 수많은 데모앱의 Bundle Identifier 관리 결정

작성일 : 2024-01-29

작성자 : 안정민

<h2 id="status">상태</h2>

* 수락됨(Accepted)
  
<h2 id="context">배경</h2>

* 모듈 기반으로 개발함에 따라 수많은 데모앱을 만들어 왔음
* Xcode를 사용하는 과정에서 자동으로 많은 Provisioning Profile이 생성되어 관리가 복잡해짐
* 새로운 테스트 폰을 추가할 때, 이러한 Provisioning Profile을 갱신하는 데에 많은 시간이 소요되는 문제가 발생함
* Provisioning Profile 생성 및 갱신을 최소화할 방안이 필요함

<h2 id="decisions">결정</h2>

* 데모앱의 Bundle Identifier를 하나로 통합 관리하며, 새로운 Bundle Identifier는 필요한 경우에만 생성

<h4 id="rationale">이유</h4>

* 대부분의 데모앱은 작업을 빠르게 확인을 위해 사용되고 있어, Provisioning Profile을 불필요하게 늘리지 않아도 됨
* 새로운 테스트 폰을 추가할 때, Provisioning Profile을 갱신할 필요가 없어짐
* 이로 인해 Provisioning Profile의 수가 현저히 줄어들어 관리가 용이해짐

<h2 id="consequences">결과 및 영향</h2>

* Provisioning Profile의 증가 속도가 크게 줄어들었음
* 새로운 테스트 폰을 연결할 때 필요한 Provisioning Profile 갱신 시간도 현저히 단축됨
* 개발자들은 Bundle Identifier의 중요성을 인식하게 됨

<h2 id="conclusion">결론</h2>

* 데모앱의 Bundle Identifier를 단일화함으로써, Provisioning Profile의 생성 및 갱신을 최소화할 수 있었습니다. 이는 프로젝트 관리의 효율성을 높이는 중요한 결정으로, 관리해야 할 요소들이 줄어들 것으로 예상됩니다.
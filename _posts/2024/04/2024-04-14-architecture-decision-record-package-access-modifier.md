---
layout: post
title: "[ADR][가상] 아키텍처 의사 결정 기록: Package 접근제어자 사용"
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
* [관련 문서 링크](#reference)
* [대안 고려](#considered_alternatives)
* [예상되는 리스크 및 대응책](#risks_and_mitigation)
* [구현 계획](#Implementation_Plan)
* [비용 및 이점](#Costs_and_Benefits)
* [결정 후 모니터링](#Monitoring_after_Decision)

## Package 접근제어자 사용

작성일 : 2024-04-14
작성자 : 안정민

<h2 id="status">상태</h2>

* 수락됨(Accepted)
  
<h2 id="context">배경</h2>

* [SE-0386](https://github.com/apple/swift-evolution/blob/main/proposals/0386-package-access-modifier.md) 제안서가 Swift 5.9에 추가됨
* 현재 수백 개의 모듈을 사용 중
* 기존의 Public, Open 접근 제어자만 사용하여 의도하지 않은 인터페이스 공개로 인한 문제 발생
* 동일 도메인 내에서만 공유하는 인터페이스를 외부에서 접근하지 못하도록 제한이 필요함

<h2 id="decisions">결정</h2>

* Package 접근제어자 사용

<h4 id="rationale">이유</h4>

* 동일 도메인 내에서만 공유하는 인터페이스는 외부에서 접근하지 못하도록 제한 필요
* Package 접근제어자를 사용하여 필요한 인터페이스만 Public, Open으로 공개, 다른 모듈의 접근을 차단
* 이로써 모듈 간 불필요한 의존성 감소

<h2 id="consequences">결과 및 영향</h2>

*  개발자들은 Package 접근제어자를 통해 의도하지 않은 인터페이스 공개로 인한 문제 방지

<h2 id="conclusion">결론</h2>

* 동일 도메인의 모듈 간의 인터페이스는 사용 가능하나, 외부 도메인의 모듈은 접근 불가로 제한
* 이는 프로젝트 관리의 효율성 향상에 중요한 역할을 할 것으로 예상됨

<h2 id="reference">관련 문서 링크</h2>

* [SE-0386](https://github.com/apple/swift-evolution/blob/main/proposals/0386-package-access-modifier.md): Swift 5.9에 추가된 Package 접근제어자 제안서

<h2 id="considered_alternatives">대안 고려</h2>

* 다른 대안을 고려하지 않았음. Package 접근제어자가 현재 요구사항을 가장 잘 충족시키는 것으로 판단됨.

<h2 id="risks_and_mitigation">예상되는 리스크 및 대응책</h2>

* 예상되는 리스크: 기존 코드에 대한 변경 및 적용 시간이 필요할 수 있음
* 대응책: 변경 및 적용 시간을 충분히 확보하고, 변화에 대한 문서화 및 교육을 실시

<h2 id="Implementation_Plan">구현 계획</h2>

* Package 접근제어자를 적용하기 위한 구체적인 계획을 수립할 예정

<h2 id="Costs_and_Benefits">비용 및 이점</h2>

* 비용: 초기 적용 및 변경에 따른 비용 발생
* 이점: 의도치 않은 인터페이스 공개로 인한 문제를 방지하고, 모듈 간 의존성을 감소시킬 것으로 예상됨

<h2 id="Monitoring_after_Decision">결정 후 모니터링</h2>

* 결정을 구현하고 나서 해당 결정이 예상대로 작동하는지를 모니터링할 계획

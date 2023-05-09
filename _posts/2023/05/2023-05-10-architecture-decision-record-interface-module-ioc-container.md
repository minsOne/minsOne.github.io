---
layout: post
title: "[ADR][가상] 아키텍처 의사 결정 기록: 인터페이스 모듈 생성 및 IoC 컨테이너를 통한 의존성 순환 문제 해결"
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

## 인터페이스 모듈 생성 및 IoC 컨테이너를 통한 의존성 순환 문제 해결

작성일 : 2023-05-10  
작성자 : 안정민

<h2 id="status">상태</h2>

* 수락됨(Accepted)
  
<h2 id="context">배경</h2>

* 프로젝트에서 모듈 간의 의존성 순환이 발생하고 있음
* 의존성 순환으로 인해 코드의 유지 보수와 확장성이 어려워짐
* 의존성 관리와 모듈 간의 결합도를 줄이는 방안이 필요함

<h2 id="decisions">결정</h2>

* 인터페이스 모듈을 생성하고 IoC(Inversion of Control) 컨테이너를 사용하여 의존성 순환 문제를 해결하기로 함

<h4 id="rationale">이유</h4>

* 인터페이스 모듈을 통해 모듈 간의 결합도를 낮추고, 구현체를 교체하기 쉬운 구조를 만듦
* IoC 컨테이너를 사용하여 런타임에 의존성 주입을 수행하고, 의존성 관리가 쉬워짐
* 의존성 순환 문제 해결을 통해 프로젝트의 유지 보수성과 확장성이 향상됨

<h2 id="consequences">결과 및 영향</h2>

* 인터페이스 모듈 생성과 IoC 컨테이너 도입에 시간과 노력이 필요함
* 기존 코드를 새로운 인터페이스 모듈 및 IoC 컨테이너 구조에 맞게 리팩토링해야 함
* 코드의 유지 보수성, 확장성, 테스트 용이성이 향상될 것으로 예상됨
* 팀원들이 인터페이스 모듈과 IoC 컨테이너 사용 방법을 익혀야 함

<h2 id="conclusion">결론</h2>

* 인터페이스 모듈 생성 및 IoC 컨테이너 도입은 의존성 순환 문제 해결과 프로젝트 구조 개선에 도움이 될 것으로 판단됨

<h2 id="notes">노트</h2>

* GitHub
  * [minsone/DIContainer](https://github.com/minsone/DIContainer)

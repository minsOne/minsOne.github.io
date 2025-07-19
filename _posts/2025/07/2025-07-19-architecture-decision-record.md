---
layout: post
title: "[ADR][가상] 아키텍처 의사 결정 기록: Tuist 템플릿 - 1 Project, N Target"
tags: [ADR, Tuist, Xcode, Project, Target]
---
{% include JB/setup %}

## Tuist 템플릿 - 1 Project, N Target

작성일 : 2025-07-19
작성자 : 안정민

<h2 id="status">상태</h2>

* 제안됨(Proposed)

<h2 id="context">배경</h2>

현재 Tuist를 사용하여 iOS 프로젝트를 관리하고 있습니다. 보통 하나의 Project에 구현 코드가 있는 Target, 그리고 그 Target의 코드를 실행, 테스트 등을 위한 Target이 존재합니다. 이를 통해 작성한 코드의 빠른 검증과 테스트가 가능하다는 장점을 가지고 있습니다.

하지만, 현재 프로젝트 구조에서 다음과 같은 문제점들을 발견했습니다.

* **프로젝트 세분화**: 각 코드들은 다른 기능을 담당하고 있어, 별도의 모듈로 분리하여 관리하는 것이 바람직합니다. 그렇기에 별도의 프로젝트로 관리를 하여, 각 기능별로 독립적인 개발 및 테스트가 가능해집니다. 하지만, 하나의 프로젝트에 하나의 기능만 담고 있어, 기능별로 프로젝트를 세분화 할 수록 많은 프로젝트가 생기면서 유사한 성격 또는 같은 도메인을 가진 코드들이 프로젝트 단위로 흩어지게 됩니다. 그래서 코드의 유사성을 찾기 어려워지며, 코드 관리, 재사용성, 응집도 감소 등의 문제가 발생합니다.

이러한 문제는 유지보수 포인트가 증가로 이어지고 있습니다.

<h2 id="decisions">결정</h2>

하나의 프로젝트에서 각 기능별로 Target을 만들어 유사한 성격 및 동일한 도메인을 가지는 코드를 하나의 프로젝트에서 관리하는 **'1 Project, N Target' 구조**를 제안합니다.

```
Project
ㄴ DemoApp
  ㄴ App1
  ㄴ App2
  ...
ㄴ Sources
  ㄴ Feature1
    ㄴ File1.swift
    ㄴ File2.swift
    ㄴ File3.swift
  ㄴ Feature2
  ㄴ Feature3
  ...
ㄴ Tests
  ㄴ UnitTest
    ㄴ Test1.swift
    ㄴ Test2.swift
  ㄴ UITest
ㄴ Project.swift
ㄴ README.md
```

<h4 id="rationale">이유</h4>

이 제안의 핵심은 유사한 성격을 가진 코드들을 한 곳에서 관리하고, 해당 프로젝트 내의 모듈간의 의존성을 자율성을 보장하도록 하는 것입니다. 

<h2 id="consequences">결과 및 영향</h2>

`Tuist 템플릿 - 1 Project, N Target` 도입 시 다음과 같은 사항들을 신중히 고려하고, 필요시 이에 대한 대비책을 마련해야 합니다.

* **모듈 간의 의존성 순환 가능성**: 하나의 Project에 많은 Target을 만들 수 있고, 의존 관계에 유연성을 확대시킨 템플릿입니다. 따라서, 개발자의 이해도, 숙련도에 많은 영향을 받을 수 있습니다. 이는 모듈 설계시 잘못했을 때, 의존성 순환 가능성이 존재할 수 있음을 의미하기도 합니다. 따라서 충분한 검토가 필요합니다.

다음과 같은 긍정적 및 잠재적 부정적 영향이 있을 수 있습니다.

* **긍정적 영향**:
    * 프로젝트 개수의 증가 폭이 감소합니다.
    * 유사한 성격을 가진 코드가 한 프로젝트에서 같이 관리되어 해당 코드들의 거리가 가까워져 코드의 가시성이 증가합니다.

* **잠재적 부정적 영향**:
    * 모듈 생성과 관리에 자율성을 부여하여 설계에 대한 높은 이해가 필요할 수 있습니다.

<h2 id="conclusion">결론</h2>

**프로젝트 생성 증가 폭 감소**와 **개발 자율성 향상**이라는 목표를 달성하기 위해 `Tuist 템플릿 - 1 Project, N Target` 도입을 제안합니다. 이 방식은 코드의 응집도 및 가시성을 기존보다 증가시키는 이점을 제공할 것으로 기대됩니다.

그러나, **모듈 의존성 순환 가능성 증가**인 잠재적인 위험과 **개발자의 충분한 숙련 및 이해도 필요**에 대해서 충분히 인지하고, 이를 관리하기 위한 방안을 함께 마련해야 합니다.

<h2 id="notes">노트</h2>

* **템플릿 파일**: [Tuist - Multiple Target Template](https://github.com/minsOne/iOSApplicationTemplate/blob/main/Tuist/ProjectDescriptionHelpers/Template/MultipleTarget/MultipleTargetTemplateGenerator.swift)
* **PoC 진행 예정**: 신규 Tuist 템플릿을 적용하는 PoC(Proof of Concept)를 진행하여 실제 적용 가능성과 영향도를 검증할 예정입니다.
---
layout: post
title: "[iOS] 도메인 별로 파일을 모으기"
description: ""
category: "programming"
tags: [Xcode, iOS]
---
{% include JB/setup %}

많은 아키텍처들의 예제들을 살펴보면 대다수가 각각의 기능(View, Present, Router, Worker 등)으로 폴더를 나눈 후, 그 밑에 파일들이 모여져있습니다.

다음과 같은 파일 트리를 가지고 있죠.

```
* Router
  - RouterA.swift
  - RouterB.swift
  - RouterC.swift
* Present
  - PresentA.swift
  - PresentB.swift
  - PresentC.swift
* Worker
  - WorkerA.swift
  - WorkerB.swift
  - WorkerC.swift
...
```

아키텍처를 설명하는 저장소에는 이렇게 폴더를 나누고 파일들을 모으는게 맞습니다. 하지만 일반적인 제품의 화면, 기능 개수와 예제에 있는 화면, 기능의 개수와는 많이 차이가 납니다.

만약에 위와 같은 구조를 일반적인 제품에 적용하면 대부분 이렇게 파일 트리가 구성될 것 입니다.

```
* Router
  * DomainA
    - DomainA_RouterA.swift
    - DomainA_RouterB.swift
    - DomainA_RouterC.swift
  * DomainB
    - DomainB_RouterA.swift
    - DomainB_RouterB.swift
    - DomainB_RouterC.swift
* Present
  * DomainA
    - DomainA_PresentA.swift
    - DomainA_PresentB.swift
    - DomainA_PresentC.swift
  * DomainB
    - DomainB_PresentA.swift
    - DomainB_PresentB.swift
    - DomainB_PresentC.swift 
...
```

처음에는 괜찮습니다. 하지만 점점 도메인이 늘어나고, 파일 개수가 많아지면, Present, Router, Worker 등 관련 파일을 동시에 살펴봐야 하는 경우 파일을 찾기가 점점 어려워집니다.

현재 이런 문제를 겪어, 연관되는 파일들을 모으는 방식으로 변경하고 있습니다.

```
* DomainA
  * SceneA
    - SceneAViewController.swift
    - SceneAStoryboard.storyboard
    - SceneARouter.swift
    - SceneAPresent.swift
    - SceneAWorker.swift
  * SceneB
    - SceneBViewController.swift
    - SceneBStoryboard.storyboard
    - SceneBRouter.swift
    - SceneBPresent.swift
    - SceneBWorker.swift
* DomainB
  * SceneC
    - SceneCViewController.swift
    - SceneCStoryboard.storyboard
    - SceneCRouter.swift
    - SceneCPresent.swift
    - SceneCWorker.swift
  * SceneD
    - SceneDViewController.swift
    - SceneDStoryboard.storyboard
    - SceneDRouter.swift
    - SceneDPresent.swift
    - SceneDWorker.swift
...
```

위와 같이 파일 트리를 구성하는 경우, 재사용, 상속 등의 이야기가 나올 수 있습니다.

만약 상속을 한다고 하더라도, DomainA에서 사용하고 있는 클래스를 DomainB에서 사용하면 안됩니다. DomainA 내에 공통 클래스를 만든 후, DomainA 내에서 상속을 받고 사용해야합니다.

또는 모듈을 만든 후, 모듈을 import 하여 사용해야합니다.

이와 같은 문제는 저만 겪는 것이 아니고, 다른 곳에서도 비슷한 문제를 겪고 위와 같은 방식으로 해결을 하고 있습니다. - [링크](https://medium.com/night-shift/i-let-my-ios-project-turn-into-chaos-fe52c8a73e14)


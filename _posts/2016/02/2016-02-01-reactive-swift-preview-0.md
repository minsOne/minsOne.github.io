---
layout: post
title: "[ReactiveX][RxSwift]들어가기 전"
description: ""
category: "programming"
tags: [swift, ReactiveX, RxSwift, ReactiveCocoa, Reactive, RxJava, RxJS, ui]
---
{% include JB/setup %}

UI와 관련된 프로그래밍을 주로 하다 보니 항상 UI와 데이터 간의 바인딩 문제, 구조적 설계에 미숙하여 나중에 고칠 때 다시 찾는 데 어려움을 겪은 적이 많았습니다. 그러면 이를 어떻게 하면 좀 더 깔끔하게, 빠르게 찾아 수정할 수 있을까 하는 생각을 하여 디자인 패턴, 아키텍처 패턴을 살펴보기도 하였지만 미숙하여 잘하지 못하였습니다.

그러다 Raywenderlich에서 올라온 [ReactiveCocoa 튜토리얼](http://www.raywenderlich.com/62699/reactivecocoa-tutorial-pt1)을 뒤늦게서야 보고 나서 이런 방식으로 하면 괜찮겠는데? 라고 생각했습니다. 그러나 Objective-C의 문법에 reactive 개념까지 포함되어버리니 이건 지금 손댈 것이 아니라고 좌절하고 덮어두었습니다. 

그러다 최근에 [RxSwift](https://github.com/ReactiveX/RxSwift) 프로젝트가 있다는 것을 알게 되었고, 예전의 `ReactiveCocoa`보다 훨씬 더 간결하고 알아볼 수 있게 되어, 해볼 만 하다라는 판단을 내렸습니다. 그리고 현재 관리하는 프로젝트에는 적용하기엔 무리하는 것으로 보였습니다. 

어떤 프로젝트에다 적용해볼까 고르고 있는 상황에서 사내에 카페가 생겼고, 웹사이트에서 주문할 수 있어 안드로이드 개발자분이 앱으로 만든다고 하셔서 여기에 적용해보자고 해서 시작해보았습니다.

다음은 Reactive 관련된 한글 자료입니다.

* [RxJava with Android](http://gaemi.github.io/android/2015/05/20/RxJava%20with%20Android%20-%201%20-%20RxJava%20사용해보기.html)
* [RxJava와 Android로 시작하기](https://www.evernote.com/shard/s655/sh/ca763c7a-17a9-4b85-ba8d-8eec979d2442/ab38e452d455f654)
* [RxAndroid로 리액티브 앱 만들기](https://realm.io/kr/news/rxandroid/)
* [Reactive Programming 배우는 방법](http://mobicon.tistory.com/467)

RxSwift로 작업하면서 Reactive 개념은 Java, Javascript에서 작성된 코드로도 쉽게 이해할 수 있었습니다(<del>진짜?</del>).

그래서 Reactive 개념을 RxSwift로 여러 가지 상황을 풀어보려고 합니다. 부족했던 부분을 다시 짚고 넘어가려고 하며, 잘못된 지식이 있을 수 있음에 유의해 주시기 바랍니다.

ps. 생각외로 해보면 재미있는데, 자료가 많지 않다 보니 이 방식이 맞는 것인지 간혹 헷갈릴 때가 있습니다.. OTZ

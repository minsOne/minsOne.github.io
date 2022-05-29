---
layout: post
title: "[iOS][Swift]solved Circular dependency using Pure Dependency Injection"
description: ""
tags: []
published: false
---
{% include JB/setup %}

프로토콜이 정의만 된 모듈,
App 모듈에서 의존성을 구현하여 di 하도록 함.


Ref :
Mobile Act ONLINE #6 | uber/needleを用いたモジュール間の画面遷移とDI
- https://www.youtube.com/watch?v=6vUpxUW_PGI
- https://scrapbox.io/ikesyo/Mobile_Act_ONLINE_%236_%7C_uber%2Fneedle%E3%82%92%E7%94%A8%E3%81%84%E3%81%9F%E3%83%A2%E3%82%B8%E3%83%A5%E3%83%BC%E3%83%AB%E9%96%93%E3%81%AE%E7%94%BB%E9%9D%A2%E9%81%B7%E7%A7%BB%E3%81%A8DI

<div class="alert warning"><strong>경고</strong>:본 내용은 이해하면서 작성하는 글이기 때문에 잘못된 내용이 포함될 수 있습니다. 따라서 언제든지 내용이 수정되거나 삭제될 수 있습니다. 잘못된 내용이 있는 부분이 있어 의견 주시면 공부하여 올바른 내용으로 반영하도록 하겠습니다.</div><br/>

모듈 간의 의존관계가 형성되었을 때, Container를 이용한 Service Locator 패턴을 이용하여 해결할 수 있습니다. 하지만 이 방법은 Container에 구현 타입이나 객체를 등록해야 하며, 실수로 등록하지 않으면 런타임 에러 - 크래시가 발생할 여지가 있습니다. 에러가 발생하면 특정 기능이 실행되지 않거나, 앱이 죽어버리기도 합니다.

유저에게 좋지 않은 경험을 선사하기 때문에 해당 문제를 잘 해결해야 합니다.

[예전 글]({{ site.production_url/programming/swift-solved-circular-dependency-from-dependency-injection-container }})에서 Container를 이용하여 모듈의 순환관계를 푸는 글을 올렸었습니다.

이번에는 Pure DI 관점으로 푼다면 정적 언어의 특성을 이용하기 때문에 안정적으로 순환관계를 풀 수 있지 않을까 싶습니다.




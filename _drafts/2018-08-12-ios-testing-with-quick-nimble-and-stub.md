---
layout: post
title: "[iOS][Swift] testing with quick nimble and stub"
description: ""
category: ""
tags: []
---
{% include JB/setup %}

iOS를 일정 기간 이상 개발하다보면 `이렇게 복잡하게 되어 있는 것을 어떻게 테스트 해야하는걸까?` , `UI도 테스트 해야하는 것일까`, `네트워크 테스트는 어떻게 해야하나` 등을 고민하게 됩니다.

현재 UI 테스트는 아직 자신이 없으니 Unit 테스트부터 먼저 해보려고 합니다.

Unit 테스트를 하기 위해서는 애플에서 기본적으로 제공하는 XCTest 프레임워크를 사용하거나, [Quick](https://github.com/Quick/Quick)과 [Nimble](https://github.com/Quick/Nimble)을 사용합니다.

XCTest는 자료가 많으니 Quick과 Nimble을 이용해서 Unit 테스트를 해보려고 합니다.(XCTest는 까는 자료들은 많으나 좋다는 자료는 찾기가 어려운 것도 한 몫을...)

## 참고자료

https://github.com/Quick/Quick/blob/master/Documentation/ko-kr/QuickExamplesAndGroups.md
https://medium.com/inloopx/tdd-using-quick-nimble-244b14b09e3d
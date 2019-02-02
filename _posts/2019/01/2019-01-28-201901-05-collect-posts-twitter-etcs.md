---
layout: post
title: "2019년 1월 5주 개발 자료 모음집 - iOS"
description: ""
category: "programming"
tags: [Swift, iOS, TestFlight, SFUIRounded, LayoutInspector, Inspector]
---
{% include JB/setup %}

<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

※ 본 글에 링크된 글들은 꼭 최신 자료이지 않을 수 있습니다.

※ 본 글은 해당 주간동안 계속 업데이트되며, 자료 제보도 받습니다.

## iOS

* iOS 12.2에서 추가된 새로운 폰트 **SFUIRounded**

<blockquote class="twitter-tweet" data-lang="ko" style="margin-bottom: 20px;"><p lang="en" dir="ltr">New font on iOS 12.2: SFUIRounded <a href="https://t.co/chCQassrL5">pic.twitter.com/chCQassrL5</a></p>&mdash; Guilherme Rambo (@_inside) <a href="https://twitter.com/_inside/status/1088924107469701120?ref_src=twsrc%5Etfw">2019년 1월 25일</a></blockquote><p style="margin-bottom: 20px;"></p>

* **[Unified lldb Print Command](https://kastiglione.github.io/lldb/2019/01/26/unified-lldb-print-command.html)**
  - Xcode 10.2에서 기존의 p, po 대신 v를 사용하기

* 깔려진 앱이 **TestFlight**인지 구분하기
  - Bundle.main의 `appStoreReceiptURL`이 있는지, 그리고 그 URL에 `sandboxReceipt`가 있는지 확인.

<blockquote class="twitter-tweet" style="margin-bottom: 20px;"><p lang="en" dir="ltr">Handy little snippet to know if installed via TestFlight<a href="https://t.co/SyH8L8knel">pic.twitter.com/SyH8L8knel</a></p>&mdash; Ben Kraus (@kraustifer) <a href="https://twitter.com/kraustifer/status/1090773523860058112?ref_src=twsrc%5Etfw">January 31, 2019</a></blockquote><p style="margin-bottom: 20px;"></p>

* [**UnitTest**를 좀 더 빠르게 돌리는 방법](https://useyourloaf.com/blog/faster-app-setup-for-unit-tests)
  - Launch 시 UnitTest 옵션을 넣고, AppDelegate에서 분기 처리를 하기.
  - 개인적으로는 이렇게 유닛 테스트를 하는 것 자체가 잘못되었다고 생각하며, 각각 Framework으로 나누고, 그 Framework의 유닛테스트를 작성하면, 저렇게 옵션을 추가해야할 일이 사라짐.

* **[LayoutInspector](https://github.com/isavynskyi/LayoutInspector)**
  - 스크린샷 찍으면 각 뷰를 3D로 살펴볼 수 있도록 제공해주는 디버깅 툴


## 일반

* **Dependency Injection** - [YouTube](https://www.youtube.com/watch?v=IKD2-MAkXyQ) 

* **[타다 시스템 아키텍처](http://engineering.vcnc.co.kr/2019/01/tada-system-architecture/)** - VCNC
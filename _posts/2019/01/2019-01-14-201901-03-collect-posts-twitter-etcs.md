---
layout: post
title: "2019년 1월 3주 개발 자료 모음집 - iOS, Swift, UI, UnitTest"
description: ""
category: "programming"
tags: [Swift, iOS]
---
{% include JB/setup %}

※ 본 글에 링크된 글들은 꼭 최신 자료이지 않을 수 있습니다.

※ 본 글은 해당 주간동안 계속 업데이트됩니다.

## Swift

* **[High Performance Numeric Programming with Swift: Explorations and Reflections](https://www.fast.ai/2019/01/10/swift-numerics/)**
  - Chris Lattner가 이런 글이 있다고 소개하며 일부 단점들을 해결하기 위해 많은 노력을 기울여 해결할 수 있다고 이야기 했습니다. 한번쯤 읽어볼만한 글.

* **[DynamicJSON](https://github.com/saoudrizwan/DynamicJSON)**
  - Swift 4.2에 추가된 dynamicMemberLookup를 이용하여 JSON을 파싱합니다. [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)과 사용법이 매우 유사함.

* **[Money](https://github.com/Flight-School/Money)**
  - 통화 관련 라이브러리
  - [ISO 4217](https://en.wikipedia.org/wiki/ISO_4217) 규격을 따라 3자리의 통화 코드, 통화 이름, 소수점 자리수를 잘 지키고 있음.

* **[Swift GYB](https://nshipster.co.kr/swift-gyb/)**, [원문](https://nshipster.com/swift-gyb/)
  - Python의 [gyb.py](https://github.com/apple/swift/blob/master/utils/gyb.py)를 이용하여 템플릿 셋을 통해 Swift 코드를 생성하는 GYB를 설명하는 글.

* **SE-0240: Ordered Collection Diffing** [포럼](https://forums.swift.org/t/se-0240-ordered-collection-diffing/), [Proposal](https://github.com/apple/swift-evolution/blob/master/proposals/0240-ordered-collection-diffing.md)
  - Diff 관련 제안서
  - iOS 개발자들이 고대하던 기능.

## iOS

* **[Bagel](https://github.com/yagiz/Bagel)**
  - 네트워크 디버깅관련 라이브러리
  - Bounjour protocol를 이용하여 데스크탑 앱과 통신하여 네트워크 정보를 디버깅 할 수 있도록 해줌.

* **[A Framework for iOS Application Development](https://pdfs.semanticscholar.org/5cf0/4ee81dac8e09580d5eac312428d07f2abcc6.pdf)**
  - Framework 기반 iOS 앱 개발 방법
  - iOS 앱이 커지면 어떤 것을 Framework으로 나눌지 작성됨.
  - 현재 Swift 기반 프로젝트이고, 다수가 개발을 하다보니 컴파일 시간이 많이 걸리는 문제가 있어 Framework으로 분리하는 것이 대안으로 생각됨.

* **[Swift with a hundred engineers](https://medium.com/@ririsid/swift-with-a-hundred-engineers-2f74ddde529a)**, **[원문](https://www.skilled.io/u/swiftsummit/swift-with-a-hundred-engineers)**
  - 신뢰도 높은 아키텍쳐 설계 RIB
  - 대규모 프로젝트에서 얻은 교훈 - 심각한 컴파일 시간, 무한 인덱싱, 도구 등의 해결
    - 컴파일 시간은 많은 프레임워크로 쪼갬, 파일을 하나로 합침, 컴파일 옵션 수정, Buck 사용
    - 많은 프레임워크의 로드로 시작속도 저하는 모든 심볼을 가져와 스태틱 바이너리에 연결하는 방법으로 해결

* **[Scaling iOS at Uber](https://atscaleconference.com/videos/blazing-fast-scaling-ios-at-uber/)**
  - Uber 앱을 어떻게 관리하는지 등의 노하우가 담겨져있음. 해당 세션에서 발표된 내용이 정리된 [Uber의 글](https://eng.uber.com/ios-monorepo/)
  - **[Buck](https://buckbuild.com/)** - Build 툴로, 기존 Xcode로 빌드하는 것보다 속도가 훨씬 빠르다고 함.

* **[Building iOS Apps at Scale](https://academy.realm.io/posts/yusei-nishiyama-mobilization-2017-building-ios-apps-at-scale/)**
  - Cookpad에서 앱을 어떻게 관리하는지 등의 노하우가 담겨져있음.

* iOSConfSG 발표자료
  - **[Behind the Scenes with Auto Layout or How to Solve Constraints with the Cassowary Algorithm](https://speakerdeck.com/vasarhelyia/behind-the-scenes-with-auto-layout-or-how-to-solve-constraints-with-the-cassowary-algorithm-iosconfsg?slide=9)**

* Print나 NSLog 대신 **os_log**를 써보는 것은 어떨까?
  - **[Clear and searchable logging in Swift with OSLog](https://www.lordcodes.com/posts/clear-and-searchable-logging-in-swift-with-oslog)**
  - **[Logging - Apple Document](https://developer.apple.com/documentation/os/logging)**
  - **[os_log - Apple Document](https://developer.apple.com/documentation/os/os_log)**

## UI
* **[UI 엔지니어링의 요소들](https://overreacted.io/ko/the-elements-of-ui-engineering/)**, **[원문](https://overreacted.io/the-elements-of-ui-engineering/)**

## 개발
* **[UnitTest - Martin Fowler](http://blog.weirdx.io/post/57004)**, **[원문](https://martinfowler.com/bliki/UnitTest.html)**
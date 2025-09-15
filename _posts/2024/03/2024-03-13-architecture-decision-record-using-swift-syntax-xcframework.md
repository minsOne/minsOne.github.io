---
layout: post
title: "[ADR][가상] 아키텍처 의사 결정 기록: Swift Macro 사용시 Prebuild된 SwiftSyntax.xcframework 사용 결정"
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
* [참고자료](#reference)

## Swift Macro 사용시 Prebuild된 SwiftSyntax.xcframework 사용 결정

작성일 : 2024-03-13

작성자 : 안정민

<h2 id="status">상태</h2>

* 수락됨(Accepted)
  
<h2 id="context">배경</h2>

* Xcode 15부터 Swift Macro를 사용할 수 있어짐
* Swift Macro는 [Swift-Syntax](https://github.com/apple/swift-syntax)를 의존하여 코드를 작성하는 방식으로 개발이 진행됨
* Swift Macro를 빌드하려면 SwiftSyntax를 빌드를 해야하며, 기존 빌드 시간보다 20초 이상 늘어나는 문제가 발생함

<h2 id="decisions">결정</h2>

* SwiftSyntax.xcframework를 만들어, Macro에서 Binary Target으로 사용하도록 함

<h4 id="rationale">이유</h4>

* CI 환경의 부하를 경감하기 위해 Prebuild된 SwiftSyntax.xcframework를 만들어야 할 필요가 있었음

<h2 id="consequences">결과 및 영향</h2>

* Swift Macro에서 SwiftSyntax.xcframework를 사용하여, CI 및 로컬 환경의 Macro 빌드 시간이 줄어들었음

<h2 id="conclusion">결론</h2>

* Apple에서 해당 문제를 해결하기 전까지는 SwiftSyntax.xcframework를 사용하는 방식을 유지

<h2 id="reference">참고자료</h2>

* Swift Forums
  * [How to import macros using methods other than SwiftPM](https://forums.swift.org/t/how-to-import-macros-using-methods-other-than-swiftpm)
  * [Macros and XCFrameworks](https://forums.swift.org/t/macros-and-xcframeworks)
  * [Macro Adoption Concerns around SwiftSyntax](https://forums.swift.org/t/macro-adoption-concerns-around-swiftsyntax/66588)
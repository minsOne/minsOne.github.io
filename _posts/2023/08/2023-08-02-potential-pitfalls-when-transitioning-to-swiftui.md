---
layout: post
title: "[SwiftUI] SwiftUI 도입시 주의해야할 사항(SwiftUI 1.0 ~ )"
tags: []
published: false
---
{% include JB/setup %}

##### iOS 13 주의사항
* LazyVStack, LazyHStack, Namespace은 iOS 14부터 사용 가능
* GeometryReader - 레이아웃 문제
  * iOS 13에서 GeometryReader에 View를 붙이면 가운데 위치
  * iOS 14 이상에서는 왼쪽 상단 모서리에 위치
  * 출처
    * https://protocorn93.github.io/2020/07/26/GeometryReader-in-SwiftUI/
    * [Xcode 12 release note](https://developer.apple.com/documentation/xcode-release-notes/xcode-12-release-notes)
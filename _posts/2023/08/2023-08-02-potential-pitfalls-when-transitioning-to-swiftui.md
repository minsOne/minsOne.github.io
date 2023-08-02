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
* TextField
  * TextField에서 포커스가 되어 키보드가 위로 올라올 때, SafeArea가 변경됨
  * iOS 14에서는 `.ignoresSafeArea(.keyboard, edges: .bottom)`를 제공하여 iOS 13에서 별도의 대응 필요
* List, ScrollView
  * ScrollView 내의 버튼이 오동작하는 것으로 추정됨. iOS 13.5.1 이상에서 해결된 것으로 추정
    출처 : https://techlife.cookpad.com/entry/2021/01/18/kaimono-swift-ui#fn-d9b05647
* NavigationLink
  * 자잘한 버그가 많음
* Sheet, Alert
  * 여러번 수행시 동작이 안되는 경우가 존재함
* UIViewRepresentable를 사용하여 기존 UIKit 코드를 감싸 호출하는 것을 추천

##### iOS 17 주의사항

* SwiftUI의 기본 애니메이션은 Spring으로 변경됨

## 참고자료
* [Fucking SwiftUI](https://fuckingswiftui.com/)

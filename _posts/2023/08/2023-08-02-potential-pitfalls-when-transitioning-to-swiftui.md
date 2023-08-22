---
layout: post
title: "[SwiftUI] SwiftUI 도입시 주의해야할 사항 SwiftUI 1.0~ (수정중)"
tags: [SwiftUI, UIKit]
---
{% include JB/setup %}

UIKit 기반 프로젝트를 SwiftUI로 전환하기 위해 고려해야할 사항을 모아 확인하기 위한 글입니다.

### iOS 13 주의사항

* LazyVStack, LazyHStack, Namespace은 iOS 14부터 사용 가능
* GeometryReader
  * 레이아웃 문제
    * iOS 13에서 GeometryReader에 View를 붙이면 가운데 위치
    * iOS 14 이상에서는 왼쪽 상단 모서리에 위치
    * 출처
      * https://protocorn93.github.io/2020/07/26/GeometryReader-in-SwiftUI/
      * [Xcode 12 release note](https://developer.apple.com/documentation/xcode-release-notes/xcode-12-release-notes)
* TextField
  * TextField에서 포커스가 되어 키보드가 위로 올라올 때, SafeArea가 변경됨
  * iOS 14에서는 `.ignoresSafeArea(.keyboard, edges: .bottom)`를 제공하여 iOS 13에서 별도의 대응 필요
  * 참고자료
    * https://www.fivestars.blog/articles/swiftui-keyboard/
* List, ScrollView
  * Button 이슈
    * ScrollView 내의 버튼이 오동작하는 것으로 추정됨. iOS 13.5.1 이상에서 해결된 것으로 추정
    * Tap Gesture로 대응
    * 출처 : https://techlife.cookpad.com/entry/2021/01/18/kaimono-swift-ui#fn-d9b05647
    * https://stackoverflow.com/questions/56561064/swiftui-multiple-buttons-in-a-list-row
  * List의 Separator를 수정하는 건 iOS 15부터 가능
  * ScrollView의 scollTo(id) 관련 이슈 - https://blog.timing.is/swiftui-production-experience-problems-solutions-performance-tips/
* NavigationLink
  * 자잘한 버그가 많음
* Sheet, Alert
  * 여러번 수행시 동작이 안되는 경우가 존재함
* Text
  * 개행문제
    * iOS 13.0에서 문자열 개행이 안된다고 추정, iOS 13.1에서는 개행이 정상 동작된다고 함
    * 출처 : https://speakerdeck.com/kuritatu18/uikit-besunoda-gui-mo-napuroziekutoheno-swiftui-dao-ru
* View
  * onDisappear 호출 문제
    * iOS 13.0에서 onDisappear가 호출되지 않는다고 추정, iOS 13.1에서는 호출된다고 함.
* ToolBar
  * 문제가 있다고 하는데 명확한 지점을 못찾음
* Task
  * iOS 15 이상부터 지원 - [Document](https://developer.apple.com/documentation/swiftui/view/task(priority:_:))

---

### iOS 14

#### 기대되는 점

* LazyVStack, LazyHStack, LazyVGrid, LazyHGrid, Namespace 사용 가능

#### 주의사항

* StateObject
  * 할당 해제가 되지 않는 문제 - https://swiftunwrap.com/article/swiftui-bugs

---

### iOS 15

#### 기대되는 점

* Task 사용 가능

#### 주의사항

* didSet이 여러번 호출됨 - https://swiftunwrap.com/article/swiftui-bugs/
* ScrollViewReader의 scrollTo가 이상하게 동작함 - https://developer.apple.com/forums/thread/688230, https://www.hackingwithswift.com/forums/swiftui/scrollviewproxy-scrollto-seems-to-be-broken-on-ios-16/16318
  * iOS 14에서는 문제가 발생하지 않음

---

### iOS 16

#### 기대되는 점

* Grid 사용 가능
* NavigationStack이 추가됨
* Layout 프로토콜 추가

#### 주의사항

* NavigationLink가 Deprecated됨
* NavigationStack도 마이너 버전에 따라 Large Title 관련 버그가 있음

---

### iOS 17

#### 기대되는 점

#### 주의사항

* SwiftUI의 기본 애니메이션은 Spring으로 변경됨

---

## 참고자료

* [Fucking SwiftUI](https://fuckingswiftui.com/)
* [UIKit 기반의 대규모 프로젝트에 SwiftUI 도입](https://speakerdeck.com/kuritatu18/uikit-besunoda-gui-mo-napuroziekutoheno-swiftui-dao-ru)
* GitHub
  * [ryangittings/swiftui-bugs](https://github.com/ryangittings/swiftui-bugs)
* [SwiftUI bugs and defects](https://swiftunwrap.com/article/swiftui-bugs/)
* [A review of SwiftUI problems](https://www.loopwerk.io/articles/2020/swiftui-review/)
* [10 More Deadly SwiftUI Mistakes and How to Avoid Them](https://blog.devgenius.io/10-more-deadly-swiftui-mistakes-and-how-to-avoid-them-de0952f1766c)
* [The SwiftUI Lab - Bug Watch](https://swiftui-lab.com/bug-watch/)
* [Holy Swift - SwiftUI의 중첩된 Observables 문제](https://holyswift.app/how-to-solve-observable-object-problem/)
* [30,000줄의 SwiftUI 생산한 후기](https://blog.timing.is/swiftui-production-experience-problems-solutions-performance-tips/)
* [SwiftUI performance tips](https://martinmitrevski.com/2022/04/14/swiftui-performance-tips/)
* [Using complex gestures in a SwiftUI ScrollView](https://danielsaidi.com/blog/2022/11/16/using-complex-gestures-in-a-scroll-view)
* [iOS13 SwiftUI 버그 모음](https://qiita.com/trickart4121/items/efc0d8db54f0617d4698)

* [Backport SwiftUI safe area insets to iOS 13 and 14](https://www.fivestars.blog/articles/safe-area-insets-2/)

---

## SwiftUI 개발시 참고자료

* [Holy Swift](https://holyswift.app/swiftui/)
* [Five Stars](https://www.fivestars.blog/)
* [SwiftUI Weekly By Majid Jabrayilov](https://weekly.swiftwithmajid.com/)
* [Design+Code](https://designcode.io/)
* [The SwiftUI Lab](https://swiftui-lab.com/)

* YouTube
  * [Swiftful Thinking](https://www.youtube.com/@SwiftfulThinking)
  * [DesignCode](https://www.youtube.com/@DesignCodeTeam)
  * [Kavsoft](https://www.youtube.com/@Kavsoft)
  * [Stewart Lynch](https://www.youtube.com/@StewartLynch)
---
layout: post
title: "[SwiftUI] View와 Interactor 간의 통신 - Delegate"
description: ""
category: "SwiftUI"
tags: [SwiftUI, View, Protocol, Delegate, ObservedObject, ObservableObject, Published]
---
{% include JB/setup %}

SwiftUI의 View는 struct이기 때문에, View를 소유하고 있는 곳(예, UIHostingController)에서 View에 일어난 행동(예, onAppear)를 어떻게 처리해야할지 고민을 했습니다.

View에는 Model을 Binding하여 View를 다시 그리게 하는 `@ObservedObject`를 이용하는 것입니다.

기본적인 View와 ViewState를 만듭니다.

```
class ViewState: ObservableObject {
  @Published var text: String = "Hello world"
}

struct MainView {
  @ObservedObject var state: ViewState
  var body: some View {
  	Text(state.text)
  }
}
```

<br/>View가 나타날때 호출할 onAppear를 추가하여 ViewState가 이를 받도록 합니다.

```
class ViewState: ObservableObject {
  @Published var text: String = "Hello world"
  func onAppear() {
  }
}

struct MainView {
  @ObservedObject var state: ViewState
  var body: some View {
  	Text(state.text)
  	  .onAppear(perform: state.onAppear)
  }
}
```

<br/>이제 ViewState를 발행하는 Interactor에서 onAppear를 처리하도록 protocol을 정의합니다.

```
protocol ViewStateListener: class {
  func onAppear()
}

class ViewState: ObservableObject {
  @Published var text: String = "Hello world"
  weak var listener: ViewStateListener?
  func onAppear() {
  	listener.onAppear()
  }
}

class Interactor: ViewStateListener {
  @ObservedObject private var state: ViewState

  init() {
    self._state = ViewState()
    super.init()
    _state.listener = self
  }

  func onAppear() {
  	print(#file, #function)
  }
}
```

이제 View에서 onAppear가 호출되었을 때, Interactor에서 특정 행동을 할 수 있게 되었습니다.<br/><br/>

## 참고자료

* [How to reload data without using onAppear in SwiftUI in watchOS](https://onmyway133.github.io/blog/How-to-reload-data-without-using-onAppear-in-SwiftUI-in-watchOS/)
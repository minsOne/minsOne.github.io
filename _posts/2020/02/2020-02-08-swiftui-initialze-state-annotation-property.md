---
layout: post
title: "[SwiftUI] View 생성시 @State 속성 값 주입하기"
description: ""
category: "SwiftUI"
tags: [SwiftUI, View, State, initialize]
---
{% include JB/setup %}

SwiftUI로 화면을 구성할 때, `@State`를 가진 속성을 외부에서 값을 가져와 생성시 주입할 경우가 있습니다. 하지만 일반적인 방법으로는 컴파일 오류가 발생합니다.

```
struct SampleView {
  @State var text: String
  init(text: String) {
    self.text = text // Error: Cannot assign value of type 'String' to type 'State<String>'  
  }
}
```

State 타입으로 값을 주입해야 합니다.

```
struct SampleView {
  @State var text: String
  init(text: String) {
    self._text = State<String>(initialValue: text)
    // 또는 타입을 생략하고 사용할 수 있음.
    // self._text = .init(initialValue: current)
  }
}
```


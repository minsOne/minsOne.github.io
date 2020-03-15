---
layout: post
title: "[SwiftUI] Binding Proxy"
description: ""
category: "SwiftUI"
tags: [SwiftUI, Binding, State]
---
{% include JB/setup %}

Slider 또는 TextField 등에서 값이 바꾸거나 바뀐 값을 참조할 때 `@Binding`을 사용합니다.

```
@Binding var text: String
TextField("Title", text: $text)

@Binding var value: CGFloat
Slider(value: $value)
```

하지만 View에는 String, CGFloat 등 특정 타입만을 받도록 고정되어 있으며, 우리가 사용하는 Model에는 View에서 받는 타입과 같지 않을 수 있습니다.

그러면 어떻게 해야할까요?

View에 맞는 Binding 변수를 만들어 주입하면 되지 않을까요? 

예를 들어, Slider는 CGFloat Binding 변수를 받습니다. 하지만 Model은 Double을 가집니다. Model과 Slider에서 필요한 타입은 변하지 않으니, 중간에 변환 역할을 해 줄 구현이 필요합니다. 

그래서 Custom Binding 변수를 만들어봅시다.

```
struct ContentView: View {
  @State private var value: Double = 0

  var body: some View {

    let valueProxy = Binding<CGFloat>(
      get: { CGFloat(self.value) },
      set: { self.value = Double($0) }
    )

    return Slider(value: valueProxy, in: -100...100, step: 10)
  }
}
```

valueProxy로 만든 Binding 변수는 Model 역할을 하는 value와 Slider 사이의 데이터 변환으로 쉽게 사용이 가능합니다.
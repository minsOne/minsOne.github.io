---
layout: post
title: "[SwiftUI] Binding 변수 주입하기 - Initialization"
description: ""
category: "SwiftUI"
tags: [SwiftUI, Binding, initialization, initializer, init]
---
{% include JB/setup %}

View에서 Binding 변수를 가질때, 외부에서 Binding 변수를 주입해줘야 합니다. 그때 다음과 같이 코드를 사용하여 값을 주입할 수 있습니다.

```
struct ContentView: View {
  @Binding var amount: CGFloat

  init(amount: Binding<CGFloat>) {
    self._amount = amount
  }
}

ContentView(amount: .constant(1))
```
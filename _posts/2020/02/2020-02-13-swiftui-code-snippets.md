---
layout: post
title: "[SwiftUI] 유용한 Extension 및 예제 코드 모음집"
description: ""
category: "SwiftUI"
tags: [SwiftUI, View]
---
{% include JB/setup %}

이 글은 유용하다고 생각하는 Extension 및 예제 코드의 모음집으로 계속 업데이트 될 예정입니다.

# Table

- View Extension
  * [If](#view_if)
  * [maskContent](#view_maskContent)


# View Extension

## If <a id="view_if"></a>

조건에 따라 transform을 호출하여 View에 반영할지 사용할때 유용한 코드.

```
public extension View {
  func `if`<T: View>(_ conditional: Bool, transform: (Self) -> T) -> some View {
    Group {
      if conditional { transform(self) }
      else { self }
    }
  }

  func `if`<T: View>(_ condition: Bool, true trueTransform: (Self) -> T, false falseTransform: (Self) -> T) -> some View {
	Group {
	  if condition { trueTransform(self) } 
	  else { falseTransform(self) }
    }
  }
}
```

위 코드는 다음과 같이 사용할 수 있습니다.

```
struct ContentView: View {
  @State var colorize: Bool = true
  var body: some View {
  	Text("Hello")
      .if(colorize) { $0.background(Color.red) }
  }
}
```

**출처** : [dotSwift 2020 - Tobias Due Munk - Prototyping Custom UI in SwiftUI](https://www.youtube.com/watch?v=1BHHybRnHFE)

## maskContent <a id="view_maskContent"></a>

mask를 역으로 사용할때 유용한 코드.(예, 텍스트 색상을 그라데이션으로 설정함.)

```
public extension View {
  func maskContent<T: View>(using: T) -> some View {
    using.mask(self)
  }
}
```

위 코드는 다음과 같이 사용할 수 있습니다.

```
struct ContentView: View {
  var body: some View {
    Text("Hello world")
      .maskContent(using: LinearGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple]),
                                         startPoint: .leading,
                                         endPoint: .trailing))
  }
}
```

**출처** : [dotSwift 2020 - Tobias Due Munk - Prototyping Custom UI in SwiftUI](https://www.youtube.com/watch?v=1BHHybRnHFE)
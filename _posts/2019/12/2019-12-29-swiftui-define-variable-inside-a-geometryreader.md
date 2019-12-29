---
layout: post
title: "[SwiftUI] GeometryReader 내부에 변수 선언하기"
description: ""
category: "SwiftUI"
tags: [SwiftUI, GeometryReader, GeometryProxy]
---
{% include JB/setup %}

SwiftUI에서 `GeometryReader` 사용시 내부에 변수를 만들어 사용하려고 하면 컴파일 에러 `Unable to infer complex closure return type; add explicit type to disambiguate`가 발생합니다.

```
var body: some View {
  return VStack() {
    GeometryReader { geometry in
      let size = geometry.size // 문제지점
      return Text("Hello world")
        .frame(width: size.width, height: size.height, alignment: .top)
    }
  }
}
```

하지만 size를 이용한 계산이 필요한 경우가 많다보니 컴파일 에러를 피하고자 중복되는 코드를 넣을 수는 없습니다. 

이를 해결하기 위해서는 GeometryProxy를 가지는 함수를 만들어 사용하도록 합니다.

```
var body: some View {
  return VStack() {
    GeometryReader { geometry in
      self.geometryProxy(geometry)
    }
  }
}

func geometryProxy(_ geometry: GeometryProxy) -> some View {
  let size = geometry.size
  return Text("Hello world")
    .frame(width: size.width, height: size.height, alignment: .top)	
}
```

이제 컴파일 에러를 피하면서 View 코드를 작성할 수 있게 되었습니다.

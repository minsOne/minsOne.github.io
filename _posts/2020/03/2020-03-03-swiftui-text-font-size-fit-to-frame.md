---
layout: post
title: "[SwiftUI] Text의 Font Size를 Frame에 Fit하게 맞추기 - minimumScaleFactor"
description: ""
category: "SwiftUI"
tags: [SwiftUI, Text, font, minimumScaleFactor]
---
{% include JB/setup %}

SwiftUI에서 Text를 사용하다보면 특정 Frame의 Size에 맞추어 Font Size를 조절해야 하는 경우가 있습니다. 그렇다고 애매한 폰트 사이즈를 넣기에는 확실치도 않고, 애매모호합니다. Frame이 늘어나는 만큼의 배수로 Font Size를 늘리는게 맞는가 싶기도 하고요.

애매한 문제를 한번 확인해보겠습니다.

```
struct ContentView: View {
  var body: some View {
    return Text("Hello world")
      .font(.system(size: 50, weight: .bold))
      .foregroundColor(Color.blue)
  }
}
```

위의 코드를 실행하면 다음과 같이 화면이 출력됩니다.

<p style="text-align:center;"><img src="{{ site.production_url }}/image/2020/03/1.png" style="width: 300px"/></p><br/>

하지만 여기에서 Frame의 Size를 작게 하면 어떻게 될까요?

```
struct ContentView: View {
  var body: some View {
    return Text("Hello world")
      .font(.system(size: 50, weight: .bold))
      .foregroundColor(Color.blue)
      .frame(width: 100, height: 100)
      .background(Color.green)
  }
}
```

Frame의 Size를 width는 100, height는 100으로 주었을 때 실행하면 다음과 같이 출력됩니다.

<p style="text-align:center;"><img src="{{ site.production_url }}/image/2020/03/2.png" style="width: 300px"/></p><br/>

이와 같이 표시되면 안되므로, `minimumScaleFactor` 함수를 이용하여 Scale Factor 값을 정하도록 합니다. 이 속성은 기존 UIKit에서도 있는 속성으로, 글자 크기를 최소한의 Scale Factor만큼 줄여줍니다.

`minimumScaleFactor`의 Factor 값을 0.5로 설정하여 다시 실행해 봅시다.

```
struct ContentView: View {
  var body: some View {
    return Text("Hello world")
      .font(.system(size: 50, weight: .bold))
      .minimumScaleFactor(0.5)
      .foregroundColor(Color.blue)
      .frame(width: 100, height: 100)
      .background(Color.green)
  }
}
```

<p style="text-align:center;"><img src="{{ site.production_url }}/image/2020/03/3.png" style="width: 300px"/></p><br/>

Frame에 맞추어 Text의 Font Size가 줄어든 것을 확인할 수 있습니다. 

이를 조금 더 극단적으로 이용하면, Frame에 맞춘 Text를 얻을 수 있습니다.

```
struct FittingFontSizeModifier: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(.system(size: 100))
      .minimumScaleFactor(0.001)
  }
}

struct ContentView: View {
  var body: some View {
    return Text("Hello world")
      .modifier(FittingFontSizeModifier())
      .foregroundColor(Color.blue)
      .frame(width: 200, height: 200) 
      // 또는 
      // .frame(width: 50, height: 50) 
      .background(Color.green)
  }
}
```

위의 코드를 실행하면 Frame에 맞춘 Text가 그려지는 것을 확인할 수 있습니다.

<p style="text-align:center;">
  <img src="{{ site.production_url }}/image/2020/03/4.png" style="width: 300px"/>
  <img src="{{ site.production_url }}/image/2020/03/5.png" style="width: 300px"/>
</p><br/>

## 정리

* Text를 Frame의 Size에 맞추어 그릴 때 minimumScaleFactor 함수를 이용하면 쉽게 할 수 있음.

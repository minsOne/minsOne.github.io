---
layout: post
title: "[SwiftUI] 가독성 측면에서 View를 어떻게 만들어야 할까? - Extension 활용"
description: ""
category: "SwiftUI"
tags: [SwiftUI, View, State, Protocol, Extension]
---
{% include JB/setup %}

SwiftUI를 이용하여 View를 만들다보면 View에서 상태값을 점점 많이 가지거나 또는 View의 Model을 만들어 가지게 됩니다.

```
struct HelloWorldView: View {
    @State var helloworld1: String = "Hello world1"
    @State var helloworld2: String = "Hello world2"
    @State var helloworld3: String = "Hello world3"

    var body: some View {
        VStack {
            Text(helloworld1)
            Text(helloworld2)
            Text(helloworld3)
        }
    }
}
```

한 곳으로 코드가 몰려지고, 코드 읽기가 어려워집니다. 그러면 어떻게 하는 것이 좋을까요?

Swift Heroes 2019에서 발표된 [Bringing Swift UI to your App](https://www.youtube.com/watch?v=Dxkr-bq1L28)에서 View 코드는 Extension으로 분리하는 다음과 같은 방식을 이야기 했습니다. 

```
struct HelloWorldView {
    @State var helloworld1: String = "Hello world1"
    @State var helloworld2: String = "Hello world2"
    @State var helloworld3: String = "Hello world3"	
}

extension HelloWorldView: View {
    var body: some View {
        VStack {
            Text(helloworld1)
            Text(helloworld2)
            Text(helloworld3)
        }
    }
}
```

View의 상태를 먼저 정의하고, View는 상태를 기반으로 화면에 보여줄 UI를 작성합니다. 상태와 View의 코드가 분리가 되어 있기 때문에 온전히 한 곳의 영역에만 집중해서 작업이 가능하다는 장점이 있습니다. 또한 Protocol로 상태를 정의하고, extension으로 view를 가지도록 할 수도 있습니다. 

```
protocol HelloProtocol {
    var helloworld1: String { get set }
    var helloworld2: String { get set }
    var helloworld3: String { get set }
}

extension HelloProtocol where Self: View {
    var body: some View {
        VStack {
            Text(helloworld1)
            Text(helloworld2)
            Text(helloworld3)
        }
    }
}

struct HelloView: View, HelloProtocol {
    @State var helloworld1: String = "Hello world1"
    @State var helloworld2: String = "Hello world2"
    @State var helloworld3: String = "Hello world3"
}
```

따라서 SwiftUI의 View 코드 작성시 상태와 View 코드를 분리하는 것이 좀 더 좋지 않을까 싶습니다.

# 참고자료
* [Swift Heroes 2019 - Bringing Swift UI to your App](https://www.youtube.com/watch?v=Dxkr-bq1L28)
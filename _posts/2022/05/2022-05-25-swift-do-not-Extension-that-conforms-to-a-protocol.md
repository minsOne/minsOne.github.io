---
layout: post
title: "[Swift] Protocol를 준수하는 Extension 코드를 주의하여 작성하기"
description: ""
category: "programming"
tags: [swift, protocol, extension, objc, category]
---
{% include JB/setup %}

Objective-C의 Category, Swift의 Extension은 유용하게 사용하고 있습니다. 기존 타입을 확장시키는데 있어서 유용합니다. 

```swift
protocol SomeProtocol {
    func something()
}

extension UIView : SomeProtocol {
    func something() {
        // some code
    }
}
```

위와 같이 UIView의 extension에 SomeProtocol을 준수하도록 하면 됩니다. 하지만, UIView는 SomeProtocol과 강결합 관계가 형성됩니다.

SomeProtocol 타입의 값을 받아 UIView로 캐스팅 할 수 있습니다. 

```swift
let view = UIView()
let some: SomeProtocol = view
let view2: UIView? = some as? UIView
```

위와 같은 코드가 존재를 하게 되면, SomeProtocol 코드는 UIView로부터 분리하는 것이 어려워지며, 그대로 남게 됩니다.

그러면 어떻게 해결해야 할까요?

SomeProtocol을 따르는 타입을 만들고, 해당 타입을 구현체에서 변수로 가지도록 해야합니다.

```swift
struct ConstructThings: SomeProtocol {
    let view: UIView
    init(view: UIView) { self.view = view }
    func something() {
        // some code
    }
}

class SomeViewController: UIViewController {
    let someView = UIView()
    let things: SomeProtocol
    init() {
        self.things = ConstructThings(view: someView)
    }
    ...

    func anything() {
        things.something()
    }
}
```

위와 같이 SomeProtocol을 따르는 `ConstructThings` 타입을 만들고, `SomeProtocol` 타입을 변수로 가지고 사용합니다. 그러면 UIView와 SomeProtocol 간 결합이 생기지 않기 때문에 SomeProtocol을 모듈로 옮기거나 제거하거나 등 리팩토링 하기에 쉬워집니다.

---

예제를 하나 더 살펴봅시다.

```swift
protocol SomeData {}

extension Int: SomeData {}
extension String: SomeData {}
```

위의 코드도 흔히 볼 수 있는 형태입니다. 이렇게 작성하면 변환하는 곳에서 캐스팅을 하면 되기 때문에 참 쉽게 사용할 수 있는 코드가 됩니다.

하지만 이전에 작성했던 코드와 마찬가지로, SomeData와 Int, SomeData와 String 간의 강결합이 발생하는 코드입니다.

```swift
let intValue = 2022
let data: SomeData = intValue
let value1: Int? = data as? Int
let value2: String? = data as? String
```

위에서 data는 Int인지 String인지 구분이 가지 않기 때문에 타입 캐스팅을 해야합니다. 타입을 확인하고 값이 있는지 확인하기 전까지 어떤 데이터인지 모르기 때문에 Swift의 강타입 언어 특성을 활용할 수 없습니다.

따라서 SomeData를 따르는 구현체를 만들고, `init`에서 `Int`, `init`에서 `String` 값을 받도록 해야합니다.

```swift
struct ConstructData: SomeData {
    enum Value {
        case int(Int), string(String)
    }

    let value: Value

    init(value: Int) {
        self.value = Value.int(value)
    }
    init(value: String) {
        self.value = Value.string(value)
    }
}

let something1: SomeData = ConstructData(value: 2022)
let something2: SomeData = ConstructData(value: "2022")
```

즉, Extension에 Protocol을 준수하도록 하는 코드는 가급적이면 지양하고, 해당 Protocol을 준수하는 타입을 사용하여 Protocol과 기존 타입간의 `강결합`이 생기지 않도록 해야합니다.


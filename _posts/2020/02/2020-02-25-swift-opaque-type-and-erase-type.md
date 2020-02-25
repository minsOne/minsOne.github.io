---
layout: post
title: "[Swift 5.1] Opaque Type과 Type Erasure"
description: ""
category: "programming"
tags: [Swift, some, Opaque Type, any, Generic, Protocol]
---
{% include JB/setup %}

## Opaque Type과 Type Erasure

Swift 5.1에서는 Opaque Type이 추가되었습니다. 기존 Swift 버전에서는 프로토콜을 반환할 때, 프로토콜이 아닌 해당 프로토콜을 따르는 타입을 반환하면 에러가 발생하였습니다.

```swift
/// 에러 - Protocol 'Comparable' can only be used as a generic constraint because it has Self or associated type requirements
func get_comparable_value() -> Comparable {
  return 1
}
```

해당 에러를 피하기 위해서는 Comparable을 따르는 타입을 사용한다고 Generic을 사용해야 합니다.

```swift
func get_comparable_value<T: Comparable>() -> T
  ...
}
```

이렇게 사용하게 되면 외부에서 타입을 명시해야 한다는 문제가 있습니다. 그래서 Swift 5.1에서는 Opaque Type이라는 것을 이용하여 Generic을 사용하지 않고도 가능합니다.

```swift
func get_comparable_value() -> some Comparable {
  return 1
}
```

위와 같이 `some`이라는 키워드를 이용하여 Opaque Type을 사용할 수 있고, Swift 5.1 이전에서 발생하던 에러는 이제 발생하지 않습니다.



하지만 위의 코드에서 `Comparable` 프로토콜을 따르는 다른 타입을 if 문을 이용하여 분기 처리하면 어떻게 될까요?

```swift
/// 에러 - Function declares an opaque return type, but the return statements in its body do not have matching underlying types
func get_comparable_value() -> some Comparable {
  if true { return 1 }
  else { return "a" }
}
```

return 문에 있는 타입이 Int, String 둘 다 있기 때문에 컴파일 에러가 발생합니다.

이런 문제를 해결하기 위해서 SwiftUI에서 `AnyView`, `AnyPublisher`, `eraseToAnyPublisher()` 와 같은 방식으로 타입을 지우는 방식을 이용하였습니다. 이러한 방법은 Generic을 지원하는 언어라면 비슷한 방식으로 사용하고 있습니다.

이제 위의 문제를 한번 해결해봅시다.

먼저 어떤 타입을 가질지 모르니 Any 타입을 가지는 프로토콜을 만듭니다.

```swift
private protocol TypeErasedBox {
  var value: Any { get }
}
```

다음 `ComparableTypeErasing` 프로토콜을 따르는 타입을 만듭니다.

```swift
private struct ComparableTypeErased<T: Comparable>: TypeErasedBox {
  let origin: T
  var value: Any { self.origin }
}
```

그러면 모든 타입을 포괄하는 AnyCompare 타입을 만들고, Comparable을 따르게 합니다.

```swift
struct AnyCompare: Comparable {
  private var eraser: TypeErasedBox

  public init<T>(_ value: T) where T : Comparable {
    eraser = ComparableTypeErased(origin: value)
  }

  static func < (lhs: AnyCompare, rhs: AnyCompare) -> Bool {
    return false
  }
  static func == (lhs: AnyCompare, rhs: AnyCompare) -> Bool {
    return false
  }
}
```

이제 `AnyCompare` 라는 타입을 이용하여 Compare 프로토콜을 따르는 타입을 숨길 수 있습니다. 그러면 위에서 에러가 발생했던 코드를 AnyCompare을 이용하여 수정하도록 합니다.

```swift
func get_comparable_value() -> some Comparable {
  if true { return AnyCompare(1) }
  else { return AnyCompare("a") }
}
```

## 출처

* [Swift Forum - Type-Erasing in Swift | AnyView behind the scenes](https://forums.swift.org/t/type-erasing-in-swift-anyview-behind-the-scenes/27952/2)
* Apple SwiftUI - AnyView 주석

---
layout: post
title: "[Swift 5.9+] Generic과 Noncopyable을 활용하여 보다 안전한 상태머신을 만들기"
tags: [Swift, Generic, Noncopyable]
---
{% include JB/setup %}
유한 상태 머신(Finite State Machine, FSM)은 소프트웨어 개발에서 자주 사용하는 패턴 중 하나입니다. 특정 사건(Event)에 의해 한 상태에서 다른 상태로 변할 수 있으며, 이를 전이(Transition)라고 합니다. 다양한 시스템의 동작을 모델링하는 데 유용합니다.

FSM을 작성하다 보면 다양한 상태와 이벤트 등을 다루게 되는데, 코드가 복잡해지는 경우가 있습니다.

예를 들어, 간단한 턴스타일(Turnstile)의 FSM을 생각해봅시다.

```swift
struct Turnstile {
  enum State {
    case locked, unlocked
  }

  enum Event {
    case insertCoin, push
  }

  private(set) var state: State = .locked

  mutating func handleEvent(_ event: Event) {
    switch (state, event) {
    case (.locked, .insertCoin):
      state = .unlocked
      print("Turnstile is now unlocked")
    case (.locked, .push):
      print("❌ Turnstile is locked. Please insert a coin.")
    case (.unlocked, .insertCoin):
      print("❌ Turnstile is already unlocked. You can push.")
    case (.unlocked, .push):
      state = .locked
      print("Turnstile is now locked")
    }
  }
}

var turnstile = Turnstile()
turnstile.handleEvent(.insertCoin) // Output: "Turnstile is now unlocked"
turnstile.handleEvent(.insertCoin) // Output: "❌ Turnstile is already unlocked. You can push."
turnstile.handleEvent(.push) // Output: "Turnstile is now locked"
turnstile.handleEvent(.push) // Output: "❌ Turnstile is locked. Please insert a coin."
```

위 코드에서는 상태와 이벤트를 Enum으로 정의하고, 상태 전이를 조건문(Switch-Case)으로 작성하였습니다. 이 방법에는 다음과 같은 문제점이 있습니다.

* 확장성 부족: 새로운 상태나 이벤트를 추가할 때마다 조건문을 수정해야 합니다.
* 유지보수 어려움: 상태 전이 로직이 분산되어 있으면 코드의 가독성과 유지보수가 어려워집니다.
* 안전성 부족: 상태 전이가 잘못 정의되거나 빠질 경우, 예기치 않은 동작이 발생할 수 있습니다.

## 제네릭을 활용한 상태 전이 정의


상태 enum의 각 case를 가지지 않는 `Locked`와 `Unlocked` Enum 타입으로 정의하고, Turnstile은 내부에서 가지고 있던 상태를 제네릭으로 받아 상태를 런타임에서 컴파일 타임 유형으로 정의할 수 있습니다.

```swift
enum Locked {}
enum Unlocked {}

struct Turnstile<State> {}

let locked = Turnstile<Locked>()
let unlocked = Turnstile<Unlocked>()
```

다음으로 각 상태에서 수행할 수 있는 이벤트를 Enum이 아닌, 함수를 호출하도록 하며, 각 이벤트는 해당 상태에서만 사용할 수 있게 제한을 둡니다.

```swift
extension Turnstile where State == Locked {
  func insertCoin() -> Turnstile<Unlocked> {
    print("Turnstile is now unlocked")
    return .init()
  }
}

extension Turnstile where State == Unlocked {
  func push() -> Turnstile<Locked> {
    print("Turnstile is now locked")
    return .init()
  }
}

let locked = Turnstile<Locked>()
let unlocked = locked.insertCoin()

locked.push() // ❌ Referencing instance method 'push()' on 'Turnstile' requires the types 'Locked' and 'Unlocked' be equivalent

unlocked.push() // Output: "Turnstile is now locked"
unlocked.insertCoin() // ❌ Referencing instance method 'insertCoin()' on 'Turnstile' requires the types 'Unlocked' and 'Locked' be equivalent
```

각 함수에서는 변경된 상태를 타입인 Turnstile을 반환하도록 하여, 각 이벤트는 해당 상태에서만 사용할 수 있게 제약을 두어 다른 이벤트를 사용할 수 없도록 만들었습니다.

하지만 `locked`와 `unlocked`는 함수 호출 뒤에도 사용할 수 있는 문제가 있습니다. 상태의 수명을 제한하고, 임의의 재사용을 지양해야 문제를 방지할 수 있습니다.

Swift 5.9의 [SE-0377 - borrowing and consuming parameter ownership modifiers](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0377-parameter-ownership-modifiers.md) 및 [SE-0390 - Noncopyable structs and enums](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0390-noncopyable-structs-and-enums.md)의 consuming을 이용하여 사용한 상태를 해제하는 방식을 활용할 수 있습니다.

## Noncopyable를 활용한 상태 재사용 제한

Noncopyable 타입은 Struct, Enum에 추가할 수 있습니다. Noncopyable을 추가하여 자신을 복사 불가능하도록 선언하여 상태의 수명을 제한합니다.

```swift
struct Turnstile<State>: ~Copyable {}

extension Turnstile where State == Locked {
  consuming func insertCoin() -> Turnstile<Unlocked> {
    print("Turnstile is now unlocked")
    return .init()
  }
}

extension Turnstile where State == Unlocked {
  consuming func push() -> Turnstile<Locked> {
    print("Turnstile is now locked")
    return .init()
  }
}

let locked = Turnstile<Locked>() 
let unlocked = locked.insertCoin()

_ = unlocked.push()
_ = unlocked.push() // ❌ 'unlocked' consumed more than once
_ = locked.insertCoin() // ❌ 'locked' consumed more than once
```

`consume`을 사용하여 변수의 수명이 종료되어 재사용이 불가능해졌습니다. 위 코드와 같이 변수를 재사용하려고 하면 컴파일러가 에러를 발생시켜 안전한 코드를 작성할 수 있게 됩니다.

또한, `var`로 작성 시 기존 변수에 새로운 값을 다시 할당하는 것은 가능하지만, 기존 변수를 재사용하는 것은 여전히 불가능합니다.

```swift
var locked = Turnstile<Locked>()
var unlocked = locked.insertCoin()

locked = unlocked.push()
unlocked = locked.insertCoin()
locked = unlocked.push()
unlocked = locked.insertCoin()

unlocked = locked.insertCoin() // ❌ 'locked' consumed more than once
locked = unlocked.push() // ❌ 'locked' consumed more than once
```

Noncopyable을 활용하여 FSM의 안전성을 더욱 강화할 수 있습니다.

## 정리

Swift의 제네릭을 활용하여 FSM을 구현하는 것은 코드의 확장성과 안전성을 높이고 버그를 줄이는 데 도움이 됩니다. Noncopyable을 통해 값의 수명을 제한하여 재사용을 막음으로써 상태의 안전성을 보장할 수 있습니다. 코드의 확장성과 안전성을 높이는 데 타입 시스템을 활용하는 것은 안정성과 확장성 있는 애플리케이션을 개발하는 데 중요한 요소입니다.

## 참고자료

* Swift Evolution
  * [SE-0377 - borrowing and consuming parameter ownership modifiers](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0377-parameter-ownership-modifiers.md)
  * [SE-0390 - Noncopyable structs and enums](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0390-noncopyable-structs-and-enums.md)

* GitHub
  * [Orion98MC/FSM.swift](https://github.com/Orion98MC/FSM.swift)

* [Wikipedia - 유한 상태 기계](https://ko.wikipedia.org/wiki/%EC%9C%A0%ED%95%9C_%EC%83%81%ED%83%9C_%EA%B8%B0%EA%B3%84)
* [Typestate the new Design Pattern in Swift 5.9](https://swiftology.io/articles/typestate/)
* [[iOS - swift] 1. noncopyable, ~Copyable - 개념 (Swift 5.9+, owner, ownership, 최적화)](https://ios-development.tistory.com/1683)
* [[iOS - swift] 2. noncopyable, ~Copyable - 연산자 (borrowing, inout, consuming)](https://ios-development.tistory.com/1684)
---
layout: post
title: "[Swift] Optional 값을 꺼내고 비우는 take 함수"
tags: [Swift, Optional, Extension, take]
---
{% include JB/setup %}

Swift에서 Optional 값을 다룰 때는 보통 `if let`, `guard let`, `map`, `flatMap` 같은 방법을 사용합니다.

그런데 가끔은 Optional에 들어 있는 값을 꺼내서 사용한 뒤, 기존 저장값은 바로 `nil`로 비워야 하는 경우가 있습니다.

예를 들어 한 번만 실행되어야 하는 Closure를 Optional로 들고 있는 경우를 생각해볼 수 있습니다.

```swift
final class Loader {
  private var completion: ((Result<Data, Error>) -> Void)?

  func load(completion: @escaping (Result<Data, Error>) -> Void) {
    self.completion = completion
  }

  func finish(_ result: Result<Data, Error>) {
    completion?(result)
    completion = nil
  }
}
```

위 코드는 크게 문제 없어 보입니다. 하지만 `completion`을 호출한 뒤에 `nil`을 넣는 코드는 매번 같이 따라다녀야 합니다.

```swift
completion?(result)
completion = nil
```

만약 성공, 실패, 취소 같은 분기가 여러 곳에 있다면 이 패턴이 반복될 수 있습니다. 그리고 어떤 분기에서 `completion = nil`을 빼먹으면 같은 Closure가 다시 호출될 여지가 생깁니다.

이럴 때 Optional 값을 꺼내면서 동시에 원본을 비우는 `take` 함수를 사용할 수 있습니다.

## take

`take` 함수의 역할은 단순합니다.

* Optional에 값이 있으면 그 값을 반환합니다.
* 원래 Optional 값은 `nil`로 바꿉니다.
* 값이 없으면 `nil`을 반환합니다.

Swift 표준 라이브러리에 `take` 함수가 구현되어 있습니다. 현재 구현은 Swift 리포지토리의 `stdlib/public/core/Optional.swift` 파일에서 확인할 수 있습니다.

```swift
extension Optional where Wrapped: ~Copyable & ~Escapable {
  @_alwaysEmitIntoClient
  @lifetime(copy self)
  public mutating func take() -> Self {
    let result = consume self
    self = nil
    return result
  }
}
```

핵심 동작만 단순하게 표현하면 다음 코드와 같습니다.

```swift
extension Optional {
  mutating func take() -> Wrapped? {
    let value = self
    self = nil
    return value
  }
}
```

`Optional`은 enum이지만 `var`로 선언된 값이라면 `mutating` 함수를 통해 자기 자신을 변경할 수 있습니다. 여기서는 현재 값을 `value`에 담아두고, `self`를 `nil`로 비운 뒤, 이전 값을 반환합니다.

표준 라이브러리 구현은 이보다 조금 더 복잡합니다. `Wrapped: ~Copyable & ~Escapable` 조건과 `consume self`가 들어가는데, 이는 Swift의 ownership 모델을 반영한 구현입니다. 단순히 값을 복사해두는 것이 아니라, 현재 Optional 값을 소비하면서 꺼내고, 원본 자리에는 `nil`을 다시 넣습니다.

반환 타입도 `Wrapped?`가 아니라 `Self`입니다. `Optional` 안에서 `Self`는 현재 Optional 타입 자체를 의미하므로, `String?`에서 호출하면 반환 타입은 `String?`가 됩니다.

간단한 예제로 보면 동작이 더 명확합니다.

```swift
var name: String? = "Swift"

let value = name.take()

print(value) // Optional("Swift")
print(name)  // nil
```

값을 한 번 꺼낸 뒤 원래 Optional은 비워졌습니다.

## Closure에 적용하기

처음 예제를 `take`로 바꾸면 다음과 같습니다.

```swift
final class Loader {
  private var completion: ((Result<Data, Error>) -> Void)?

  func load(completion: @escaping (Result<Data, Error>) -> Void) {
    self.completion = completion
  }

  func finish(_ result: Result<Data, Error>) {
    completion.take()?(result)
  }
}
```

`completion.take()`는 현재 Closure를 반환하고, `completion` 프로퍼티는 바로 `nil`이 됩니다. 이후 반환된 Closure에 `?(result)`를 호출합니다.

즉 아래 두 줄을 하나의 의도로 묶을 수 있습니다.

```swift
let completion = self.completion
self.completion = nil
completion?(result)
```

`take`를 사용하면 "값을 사용한다"와 "저장된 값을 비운다"는 동작이 분리되지 않습니다. 이 점이 가장 큰 장점입니다.

## 왜 호출 전에 비우는 것이 좋은가

Closure를 호출한 뒤에 `nil`로 비우는 방식은 대부분의 경우 문제가 없습니다.

하지만 Closure 내부에서 다시 같은 객체를 건드리거나, 동기적으로 다른 흐름을 실행하는 경우를 생각하면 호출 전에 저장값을 비워두는 편이 더 안전할 때가 있습니다.

```swift
func finish(_ result: Result<Data, Error>) {
  completion?(result)
  completion = nil
}
```

위 방식에서는 `completion`이 실행되는 동안 아직 프로퍼티에 Closure가 남아 있습니다.

반면 `take`를 사용하면 Closure 실행 전에 프로퍼티가 먼저 비워집니다.

```swift
func finish(_ result: Result<Data, Error>) {
  completion.take()?(result)
}
```

한 번만 실행되어야 하는 콜백이라면 이 순서가 더 의도를 잘 드러냅니다. "꺼내는 순간 소유권을 넘기고, 저장소는 비운다"는 흐름에 가깝습니다.

## willSet과 didSet으로 변경 순서 확인하기

`take`가 실제로 언제 Optional 값을 비우는지 `willSet`과 `didSet`을 이용해 확인할 수 있습니다.

```swift
final class Loader {
  private var completion: (() -> Void)? {
    willSet {
      print("willSet: newValue is nil =", newValue == nil)
      print("willSet: current is nil =", completion == nil)
    }

    didSet {
      print("didSet: completion is nil =", completion == nil)
    }
  }

  func prepare() {
    completion = {
      print("completion 실행")
    }
  }

  func finish() {
    print("finish 시작")
    completion.take()?()
    print("finish 종료")
  }
}

let loader = Loader()
loader.prepare()
loader.finish()
```

출력 순서는 다음과 같습니다.

```text
willSet: newValue is nil = false
willSet: current is nil = true
didSet: completion is nil = false
finish 시작
willSet: newValue is nil = true
willSet: current is nil = false
didSet: completion is nil = true
completion 실행
finish 종료
```

`prepare()`에서 Closure를 저장할 때는 `newValue`가 `nil`이 아니고, 기존 `completion`은 `nil`입니다. 반대로 `take()`가 호출될 때는 `newValue`가 `nil`이고, 기존 `completion`에는 아직 Closure가 들어 있습니다.

여기서 중요한 부분은 `completion 실행`보다 `willSet: newValue is nil = true`와 `didSet: completion is nil = true`가 먼저 출력된다는 점입니다.

즉 `completion.take()?()`는 Closure를 실행한 뒤에 Optional을 비우는 것이 아닙니다. 먼저 Optional에 들어 있던 Closure를 꺼내고, 원본 프로퍼티를 `nil`로 변경한 다음, 꺼낸 Closure를 실행합니다.

이를 풀어서 쓰면 다음 순서와 같습니다.

```swift
let current = completion.take()
current?()
```

따라서 `willSet`과 `didSet` 기준으로 보면 `completion.take()`가 호출되는 시점에 이미 프로퍼티 변경이 끝납니다. 이 특성 때문에 한 번만 실행되어야 하는 Closure를 다룰 때 `take`가 의도를 잘 드러냅니다.

## 다른 값에도 사용할 수 있다

`take`는 Closure 전용 함수는 아닙니다. Optional에 들어 있는 값을 한 번 소비하고 상태를 비우고 싶을 때 사용할 수 있습니다.

예를 들어 지연 실행할 작업을 Optional로 들고 있다가, 실행 시점에 꺼내서 비우는 방식으로 사용할 수 있습니다.

```swift
struct PendingAction {
  private var action: (() -> Void)?

  mutating func set(_ action: @escaping () -> Void) {
    self.action = action
  }

  mutating func run() {
    action.take()?()
  }
}
```

`run()`을 여러 번 호출하더라도 저장된 action은 한 번만 실행됩니다.

```swift
var pendingAction = PendingAction()

pendingAction.set {
  print("run")
}

pendingAction.run() // run
pendingAction.run() // nothing
```

이런 코드는 플래그를 따로 두는 방식보다 상태가 단순합니다. 값이 있으면 아직 실행되지 않은 것이고, 값이 없으면 이미 실행되었거나 등록되지 않은 상태입니다.

## 사용할 때 주의할 점

`take`는 Optional 값을 변경하는 함수입니다. 따라서 `let`으로 선언된 Optional에는 사용할 수 없습니다.

```swift
let name: String? = "minsone"
name.take() // Compile Error
```

`take`를 사용하려면 값이 변경 가능해야 합니다.

```swift
var name: String? = "Swift"
let value = name.take()
```

또 하나 주의할 점은 `take`가 값을 꺼내면서 원본 Optional을 변경한다는 점입니다. 표준 라이브러리 구현에서는 `consume self`를 사용해 현재 Optional을 소비하고, 그 자리에 `nil`을 다시 넣습니다.

대부분의 경우 `take`는 큰 모델 객체보다 Closure, Task, Timer, Token 처럼 "등록된 작업이나 핸들"을 한 번 꺼내고 비우는 용도에 더 잘 맞습니다.

## 정리

Optional의 `take` 함수는 값을 꺼내는 동작과 원본을 `nil`로 비우는 동작을 하나로 묶는 작은 유틸리티입니다.

```swift
extension Optional where Wrapped: ~Copyable & ~Escapable {
  public mutating func take() -> Self {
    let result = consume self
    self = nil
    return result
  }
}
```

특히 한 번만 실행되어야 하는 Closure나 지연 작업을 Optional로 들고 있을 때 유용합니다. 호출한 뒤에 직접 `nil`을 넣는 패턴이 반복된다면, `take`를 통해 의도를 더 명확하게 표현할 수 있습니다.

## 참고자료

* [Swift Standard Library - Optional.swift](https://github.com/swiftlang/swift/blob/main/stdlib/public/core/Optional.swift)

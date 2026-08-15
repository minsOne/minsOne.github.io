---
layout: post
title: "[Swift] Protocol Extension으로 공통 인터페이스를 도메인에 맞게 처리하기"
tags: [Swift, Protocol, Extension]
---
{% include JB/setup %}

여러 상품에서 공통 모듈을 사용하다 보면, 공통 모듈의 인터페이스가 각 상품에서 필요한 것보다 구체적인 경우가 있습니다.

예를 들어 계좌 개설 모듈이 취소 사유를 다음과 같이 전달한다고 가정해봅시다.

```swift
enum AccountOpenCancelReason {
  case cancel
  case failed
  case notAccessible
}

protocol AccountOpenCancelRequestHandler {
  func accountOpenCancel(reason: AccountOpenCancelReason)
}
```

취소 사유마다 다른 동작이 필요하다면 구현체에서 각 case를 처리하면 됩니다. 하지만 일부 상품에서는 모든 취소 사유를 계좌 개설 종료라는 하나의 동작으로 처리하기도 합니다.

## 구현체에서 직접 처리하는 경우

펀드와 연금 상품이 모든 취소 사유를 동일하게 처리한다면 다음과 같은 코드가 반복될 수 있습니다.

```swift
final class FundAccountOpenHandler: AccountOpenCancelRequestHandler {
  func accountOpenCancel(reason: AccountOpenCancelReason) {
    switch reason {
    case .cancel, .failed, .notAccessible:
      closeAccountOpen()
    }
  }

  private func closeAccountOpen() {
    // 펀드 계좌 개설 종료
  }
}
```

```swift
final class PensionAccountOpenHandler: AccountOpenCancelRequestHandler {
  func accountOpenCancel(reason: AccountOpenCancelReason) {
    switch reason {
    case .cancel, .failed, .notAccessible:
      closeAccountOpen()
    }
  }

  private func closeAccountOpen() {
    // 연금 계좌 개설 종료
  }
}
```

두 타입이 수행하는 실제 동작은 다르지만, 공통 인터페이스를 해석하는 방식은 같습니다. 상품이 늘어나면 같은 `switch`도 각 구현체에 반복됩니다.

## 도메인 동작 정의하기

해당 상품군에서 필요한 동작을 별도 프로토콜로 정의할 수 있습니다.

```swift
protocol InvestmentAccountOpenCancelRequestHandler:
  AccountOpenCancelRequestHandler {
  func closeAccountOpen()
}
```

그리고 공통 인터페이스에서 전달된 취소 사유를 protocol extension에서 처리합니다.

```swift
extension InvestmentAccountOpenCancelRequestHandler {
  func accountOpenCancel(reason: AccountOpenCancelReason) {
    switch reason {
    case .cancel, .failed, .notAccessible:
      closeAccountOpen()
    }
  }
}
```

각 상품은 취소 사유를 직접 해석하지 않고, 자신에게 필요한 동작만 구현합니다.

```swift
final class FundAccountOpenHandler:
  InvestmentAccountOpenCancelRequestHandler {
  func closeAccountOpen() {
    // 펀드 계좌 개설 종료
  }
}

final class PensionAccountOpenHandler:
  InvestmentAccountOpenCancelRequestHandler {
  func closeAccountOpen() {
    // 연금 계좌 개설 종료
  }
}
```

`AccountOpenCancelRequestHandler`는 취소 사유를 전달하는 공통 인터페이스를 유지합니다. protocol extension은 이 인터페이스를 투자 상품에서 필요한 `closeAccountOpen()` 동작으로 연결합니다. 역할만 놓고 보면, 공통 모듈의 언어를 해당 도메인의 언어로 바꾸는 작은 번역 계층에 가깝습니다.

구현체는 공통 모듈의 세부적인 취소 사유보다 해당 상품에서 수행해야 하는 동작에 집중할 수 있습니다.

## switch를 남겨두는 이유

모든 사유를 동일하게 처리한다면 `reason`을 사용하지 않고 바로 `closeAccountOpen()`을 호출할 수도 있습니다.

```swift
func accountOpenCancel(reason: AccountOpenCancelReason) {
  closeAccountOpen()
}
```

하지만 이 경우 새로운 case가 추가되어도 기존 코드에서는 컴파일 오류가 발생하지 않습니다.

반면 `switch`를 유지하면 새로운 case가 추가되었을 때 protocol extension에서 컴파일 오류가 발생합니다. 새로운 취소 사유도 투자 상품에서 동일하게 처리할 것인지 한 곳에서 다시 확인할 수 있습니다.

따라서 `switch`를 제거하기보다 도메인 정책을 결정하는 위치로 모으는 것이 좋습니다.

## 여러 함수를 하나의 도메인 동작으로 연결하기

이 방식은 enum 처리에만 한정되지 않습니다. 상위 프로토콜에 여러 함수가 있는 경우에도 하나의 도메인 동작으로 연결할 수 있습니다.

```swift
protocol AccountOpenRequestHandler {
  func accountOpenDidCancel()
  func accountOpenDidFail()
}

protocol InvestmentAccountOpenRequestHandler:
  AccountOpenRequestHandler {
  func closeAccountOpen()
}

extension InvestmentAccountOpenRequestHandler {
  func accountOpenDidCancel() {
    closeAccountOpen()
  }

  func accountOpenDidFail() {
    closeAccountOpen()
  }
}
```

## 정리

중요한 것은 여러 case나 함수를 하나로 줄이는 데 있지 않습니다. 공통 인터페이스의 세부사항을 도메인 경계에서 처리하고, 구체 타입은 자신이 수행해야 하는 동작만 구현하도록 만드는 데 있습니다.

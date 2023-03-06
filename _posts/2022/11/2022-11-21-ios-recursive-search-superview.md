---
layout: post
title: "[iOS][Swift] Sequence를 활용하여 UIView의 특정 superview를 찾기"
tags: [iOS, Swift, UIView, superview, sequence, Sequence, sequencetype, iterator]
---
{% include JB/setup %}

Swift에서 특정 superview를 찾기 위해선 여러 가지 방법이 있습니다. superview의 타입이 원하는 타입인지 일치할 때까지, 재귀함수를 이용하여 호출하는 방법 등이 있습니다.

그런 경우, 조건이 들어가면서 함수 자체가 복잡해지고, 이해하기 살짝 쉽지 않습니다.

```swift
func recursive(from view: UIView) -> UIView? {
  guard let superview = view.superview else { return nil }

  if type(of: superview) == UIWindow.self { return superview }
  else { return recursive(from: superview) }
}
```

물론, view는 superview를 알고 있기 때문에, superview를 찾기 위해선 sequence를 이용할 수 있습니다. 여러 view가 존재하는 경우, 알맞은 조건문과 타입 캐스팅을 사용하여 원하는 superview를 찾을 수 있습니다. 이를 통해 함수를 더욱 간단하고 명확하게 작성할 수 있습니다.

```swift
func recursive(from view: UIView) -> UIView? {
  for view in sequence(first: self, next: \.superview) {
    if type(of: $0) == UIWindow.self { return view }
  }
  return nil
}

func recursive(from view: UIView) -> UIView? {
  for view in sequence(first: view, next: \.superview) where type(of: view) == UIWindow.self {
    return view
  }
  return nil
}

func recursive(from view: UIView) -> UIView? {
   sequence(first: view, next: \.superview).first(where: { type(of: $0) == UIWindow.self })
}

func recursive(from view: UIView) -> UIView? {
   sequence(first: view, next: \.superview).lazy.compactMap { $0 as? UIWindow }.first
}
```

## 참고자료

* Apple Document 
  * [sequence](https://developer.apple.com/documentation/swift/sequence)
  * [sequence(first:next:)](https://developer.apple.com/documentation/swift/sequence(first:next:))

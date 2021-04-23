---
layout: post
title: "[Swift] 간결한 if let 문은 Optional의 map 그리고 Nil-Coalescing(??)으로 대체하기"
description: ""
category: "programming"
tags: [Swift, Optional, map, flatMap]
---
{% include JB/setup %}

Swift에서 nil 값을 풀어서 사용할 때 `if let` 문을 이용하여 처리를 많이 합니다. 

```
let a: Int? = 10

if let a = a { 
  print(a)
} else {
  print("nil")
}
```

사실 else를 사용하지 않을 때는 `if let` 문이 귀찮을때도 있기도 합니다. 

Optional 타입에도 map을 이용할 수 있다는 것을 아시나요? enum 타입인 Optional은 ExpressibleByNilLiteral 프로토콜을 따르고 있기도 하고, map, flatMap이 구현되어 있습니다.

```
@frozen public enum Optional<Wrapped> : ExpressibleByNilLiteral {
...
    @inlinable public func map<U>(_ transform: (Wrapped) throws -> U) rethrows -> U?

    @inlinable public func flatMap<U>(_ transform: (Wrapped) throws -> U?) rethrows -> U?
...
```

Optional에 `map`과 `flatMap` 함수를 이용하여 간결한 `if let` 문을 대체할 수 있습니다.

```
let a: Int? = 10
let b: Int? = nil

a.map { print("Result : \($0)") }
  ?? print("map Error")

b.flatMap { print("flatMap Error") }
  ?? print("Result : nil")

/** 
-- output --
Result : 10
Result : nil
*/
```

이러한 코드는 `if let` 문이 간결한 조건일때 은근히 유용하게 사용되며, 복잡한 `if` 문에서 사용은 지양하는 것이 좋을 것 같습니다. 

또한, map과 flatMap은 적절하게 필요한 상황에 따라 사용하면 됩니다.
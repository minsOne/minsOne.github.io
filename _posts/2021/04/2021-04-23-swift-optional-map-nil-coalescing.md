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

만약 map이나 flatMap에서 받은 결과를 변수에 저장해야 한다면, 해당 타입은 어떻게 될까요?

```
let a: String? = "10"
let b: String? = nil

let c: Int?? = a.map { Int($0) } 
let d: Int? = b.flatMap { Int($0) }
```

a 값을 map으로 변환할 떄, `Int.init()` 에서 값이 옵셔널로 반환되기 때문에 (Int?)? 형태가 됩니다. 그래서 변수 c의 타입이 `Int??`로 정의됩니다. 

b 값을 flatMap으로 변환할 때 `Int.init()` 에서 값이 옵셔널이 반환되더라도 flatMap은 Int를 반환하므로 (Int)? 형태를 취합니다.. 그래서 변수 d의 타입은 `Int?`로 정의됩니다.

따라서 체이닝이 연속될때는 flatMap을 쓰며, map은 return이 Void 인 경우 사용하면 좋습니다.

```
let a: String? = "5"
let b: String? = nil

a.map { Int($0) }.map { String($0) } // Compile Error
a.flatMap { Int($0) }.map { String($0) } // Ok

func returnVoid() {
  a.flatMap { Int($0) }.flatMap { String($0)}.map { print($0) } // Ok
}
```

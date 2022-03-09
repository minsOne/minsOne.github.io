---
layout: post
title: "[Swift] 순방향 파이프 연산자 - |> "
description: ""
category: ""
tags: ["Swift", "Operator", "Pipe", "ForwardPipe", "infix", "precedencegroup"]
---
{% include JB/setup %}

[실용주의 프로그래머](http://www.yes24.com/Product/Goods/107077663) 책의 Topic 30 변환 프로그래밍에서 단계별로 변환하는 것을 순방향 파이프 연산자를 사용하여 데이터를 변환하는 것을 보여줍니다.

파이프 연산자는 단순히 왼쪽에 있는 값을 오른쪽에 있는 함수의 인자에 넣는 것입니다. 

```swift
precedencegroup ForwardPipe {
    associativity: left
}

infix operator |> : ForwardPipe

public func |> <T, U>(value: T, function: ((T) -> U)) -> U {
    return function(value)
}

func add(lhs: Int, rhs: Int) -> Int {
    return lhs + rhs
}

func double(value: Int) -> Int {
    return value * 2
}

/// Before
let value1 = double(value: add(lhs: 123, rhs: 456)) // Output : 1158

/// After
let value2 = (123, 456) |> add |> double // Output : 1158
let value3 = (123, 456) 
|> add
|> double
// Output : 1158
```

파이프 연산자를 이용하면 데이터가 한 변환에서 다음 변환으로 흘러가는 데이터 변환의 관점을 생각하게 됩니다. 

사실 Swift, Objective-C에서 Extension, Category를 통해서 Chaining으로 데이터 변환을 할 수도 있습니다. 하지만 코드가 Extension에 추가되기 때문에 스코프에서 벗어나서 작성됩니다.

```swift
class A {
    func add(lhs: Int, rhs: Int) -> Int {
        return lhs + rhs
    }
    
    func getValue() -> Int {
        return add(lhs: 123, rhs: 456)
        // or
        return 123.add(rhs: 456)
    }
}

extension Int {
    func add(rhs: Int) -> Int {
        return self + rhs
    }
}
```

그리고 Optional은 map, flatMap을 이용하여 데이터 변환을 할 수도 있습니다. [관련 글](https://minsone.github.io/programming/swift-optional-map-nil-coalescing)

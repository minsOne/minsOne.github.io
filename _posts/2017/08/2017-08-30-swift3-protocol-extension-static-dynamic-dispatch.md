---
layout: post
title: "[Swift3]Protocol Extension(2) - Dynamic Dispatch과 Static Dispatch"
description: ""
category: "Programming"
tags: [Swift, Protocol, Extension, Protocol Extension, Dispatch]
---
{% include JB/setup %}

앞의 글에서 그러한 현상이 어떻게 되는지 추론 및 Dispatch에 대해 알아보려고 합니다.

Protocol 타입인 변수에 Extension에 구현된 메소드를 접근시 구조체나 클래스에 이름이 동일한 메소드가 호출되지 않고 Extension에 구현된 메소드가 호출됩니다.

```
protocol A {
	func foo() -> String
}

extension A {
	func foo() -> String {
		return "foo"
	}
	func bar() -> String {
		return "bar"
	}
}

class B: A {
	func foo() -> String {
		return "Foo"
	}
	func bar() -> String {
		return "Bar"
	}
}

let b: A = B()
print(b.bar()) // bar
```

컴파일러는 변수 b가 B 클래스라는 것을 알 수 없으며, 따라서 런타임시에 프로토콜 A에 정의된 bar 함수를 호출합니다. 이 부분에 있어 Dynamic Dispatch와 관련됩니다.

bar 함수 호출 대신 foo 함수를 호출했다면, 컴파일러는 foo 함수가 구현되어 있음을 알고, 각 객체들의 foo 함수를 호출합니다. 이부분에는 Static Dispatch와 관련됩니다.

### Static Dispatch

프로토콜 A에서 정의가 되었으므로 컴파일 타임에 예측 가능하므로 어떤 메소드로 호출할지 결정되며, 이를 정적 디스패치라고 합니다.

### Dynamic Dispatch 

컴파일 타임에 어떤 메소드로 호출될 것인지를 모르기 때문에, 런타임시 변수 b 타입인 프로토콜 A의 Extension에 구현된 bar 함수를 호출합니다. 이를 동적 디스패치라고 합니다. 

만약 Extension에 bar가 구현되어 있지 않다면, 컴파일러는 변수 b의 bar 함수를 알 수 없으므로 컴파일 에러가 발생합니다.

### 정리

Protocol Extension을 어떻게 쓰느냐에 따라 의도한 코드가 호출되거나, 의도하지 않은 결과가 호출될 수 있습니다.

### 참고자료

* [[swift-evolution] Proposal: Universal dynamic dispatch for method calls](https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20151207/001922.html)
* [[swift-evolution] Proposal: Universal dynamic dispatch for method calls](https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20151207/001948.html)
* [Does Swift have dynamic dispatch and virtual methods?](https://stackoverflow.com/questions/24014045/does-swift-have-dynamic-dispatch-and-virtual-methods)
* [[swift-evolution] Require use of override keyword to override dynamically dispatched methods defined in a protocol with a default implementation](https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20160104/005380.html)
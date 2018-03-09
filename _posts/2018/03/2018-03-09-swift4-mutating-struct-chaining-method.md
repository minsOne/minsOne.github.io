---
layout: post
title: "[Swift4] Struct를 체이닝 메소드로 값을 계속 변경하기"
description: ""
category: "Programming"
tags: [Swift, Struct, mutating]
---
{% include JB/setup %}

Swift의 Struct는 `mutating` 이라는 것을 통해 내부 속성 값 변경이 가능합니다.

```
struct A {
	var b: Int

	mutating func set(b: Int) {
		self.b = b
	}
}

var a = A(b: 10)
a.set(b: 5) // b is 5
```

<br/>하지만 `mutating`을 쓰게 되면 `return`을 할 수 없습니다. 

```
struct A {
	...
	mutating func set(b: Int) -> A {
		self.b = b
		return self
	}	
}
```

<br/>하지만 `mutating`을 쓰지 않으면 내부 값이 바꿀 수 없습니다. 

그렇다면 **새로운 값을 만들어 반환**하는 방식으로 하면 체이닝 메소드를 사용하여 값을 계속 설정하는 것이 가능해집니다.

```
struct A {
	var a: Int = 0
	var b: Int = 0

	func set(a: Int) -> A {
		var _a = A(a: a, b: self.b)
		return _a
	}

	func set(b: Int) -> A {
		var _a = A(a: self.a, b: b)
		return _a
	}
}

A().set(a: 5).set(b: 10) // a is 5, b is 10
```

값을 계속 생성하는 것이 아쉽긴 하지만 체이닝 메소드를 사용한 값 변경이 클래스에서만이 아닌 구조체에서도 사용이 가능합니다.

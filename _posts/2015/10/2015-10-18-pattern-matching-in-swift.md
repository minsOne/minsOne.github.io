---
layout: post
title: "[Swift]Switch문 Trick"
description: ""
category: "programming"
tags: [swift, if case, if, case, function, generic]
---
{% include JB/setup %}

### IF Case 문

Swift 2에서는 Switch문이 아닌 if문에서도 case를 사용할 수 있습니다.

	enum Direction {
		case Right, Down, Left, Up
	}

	let r = Direction.Right
	let l = Direction.Left

	if case Direction.Right = r {
		print("Right")
	}

	// Or

	if case .Right = r {
		print("Right")
	}

	if case Direction.Right = r where l == Direction.Left {
		print("Right and Left")
	}

### Case에 함수 사용하기

기본적으로 Swift에서는 Case에 함수를 사용할 수 없습니다. 다음과 같이 코드를 작성하면 에러가 발생합니다.

	var x = 0
	func isEven(n: Int) -> Bool {
		return n % 2 == 0 ? true : false
	}

	func isOdd(n: Int) -> Bool {
		return n % 2 != 0 ? true : false
	}

	switch x {
	case isEven: print("Even")
	case isOdd: print("Odd")
	default: print("Odd")
	}

	error: binary operator '~=' cannot be applied to operands of type '(Int) -> Bool' and 'Int'
	case isEven: print("Even")
		 ^~~~~~

위와 같은 에러가 발생을 하여 Case에 함수를 사용할 수 없습니다. 하지만 에러를 살펴보면 `(Int) -> Bool` 타입의 변수와, `Int` 타입의 변수가 들어감을 알 수 있으므로, 다음과 같이 `~=` 연산자를 선언할 수 있습니다.

	func ~=(f: Int -> Bool, value: Int) -> Bool {
		return f(value)
	}

제네릭을 사용하여 다른 타입도 사용할 수 있도록 작성합니다.

	func ~=<T>(f: T -> Bool, value: T) -> Bool {
		return f(value)
	}

그리고 Case에 함수를 사용하게 되면 Switch문은 모든 경우를 판단할 수 없기 때문에 반드시 default를 사용해야 합니다.

### 참고자료

* [Pattern Matching in Swift](http://oleb.net/blog/2015/09/swift-pattern-matching/)

<!--
http://oleb.net/blog/2015/09/swift-ranges-and-intervals/
http://oleb.net/blog/2015/09/more-pattern-matching-examples/
http://natashatherobot.com/swift-2-pattern-matching-with-if-case/
http://ericasadun.com/2015/05/27/swift-the-good-switch-of-the-east/
-->
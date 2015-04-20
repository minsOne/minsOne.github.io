---
layout: post
title: "커링(Currying) in Swift"
description: ""
category: "programming"
tags: [functional programming, FP, swift, refactoring, type, lamda, currying, uncurrying, haskell, closure, lazy]
---
{% include JB/setup %}

## 커링(Currying)

수학과 컴퓨터 과학에서 커링은 다중 인수를 갖는 함수를 단일 인수로 갖는 함수들의 함수열로 바꾸는 것입니다.[[1]][Wiki_Currying]

언커링(UnCurrying)은 커링의 듀얼 변형으로 f(x) 함수를 취하면 그 결과로 g(y)라는 다른 함수를 반환하고, 새로운 함수 f(x, y)를 가져옵니다.[[2]][Wiki_Currying]

커링(Currying)이라는 이름은 [하스켈 커리(Haskell Curry)][Haskell_Curry]에서 이름을 가져온 것입니다.


### 동기(Motivation)

커링은 주어진 다중 값을 함수로 계산하는 과정과 유사합니다.

예를 들어 `f(x, y) = y / x` 라는 함수가 주어졌다면 `h(x) = y -> f(x, y)`로 정의할 수 있습니다. f(2, 3)을 계산하기 위해서 x의 값에 2를 대입합니다. 

그 후에 y 함수의 결과로 새로운 함수 `g(y) = h(2) = y -> f(2, y) = y / 2` 로 정의할 수 있습니다

다음으로 y 값에 3을 대입하여 `g(3) = f(2, 3) = 3 / 2` 라는 과정을 도출하게 됩니다.

### 커링 정의

f:(X x Y) -> Z 타입의 함수 f는 curry(f): X->(Y->Z)로 만들 수 있습니다. curry(f)는 타입 X의 인자를 가지고 Y->Z 타입 함수를 반환합니다. 언커링은 역 변형입니다.

커링 함수 X->(Y->Z)는 X->Y->Z로 작성되기도 합니다.


### 코드로 보는 커링

두 개의 인자를 가지는 함수를 통해 점점 발전시켜 봅시다.

	func add1(x: Int, y: Int) -> Int {
		return x + y
	}

위의 함수는 두 개의 인자를 가지고 합계를 반환합니다. 클로저를 이용하여 다른 방식으로 작성할 수 있습니다.

	func add2(x : Int) -> (Int -> Int) {
		return { y in return x + y }
	}

위의 함수는 인자 하나만 가지고 두번째 인자 y로 예상하는 클로저를 반환합니다.

두 함수는 각각 다르게 작성됩니다.

	add1(1, 2)
	add2(1)(2)

<br/>첫번째 함수 add1는 클로저 대신 커링된 버전으로 정의할 수 있습니다.

	func add3(x: Int)(y: Int) -> Int {
		return x + y
	}

대신 두번째 인자는 인자 명을 명시해주어야 합니다.

	add3(2)(y: 1)

<br/>다시 돌아가서 앞에서 `f(X x Y) -> Z` 타입의 함수를 커링된 제네릭 함수로 정의할 수 있습니다.

	func curry<X, Y, Z>(f: (X, Y) -> Z) -> X -> Y -> Z {
		return { x in
			{ y in f(x, y) }
		}
	}

	func curry<A, B, C, D>(f: (A, B, C) -> D) -> A -> B -> C -> D {
		return { a in { b in { c in f(a, b, c) } } }
	}	

<br>또한, 여러 인자를 함수로 받아 커링된 버전으로 함수를 정의할 수 있습니다.

	func curry1<X, Y, Z>(f: X -> Y, g: Y -> Z) -> X -> Z {
		return { x in g(f(x)) }
	}

	infix operator >>> { associativity left }
	func >>> <A, B, C>(f: A -> B, g: B -> C) -> A -> C {
		return { x in g(f(x)) }
	}

	var f: Int -> Int = { $0 + 2 }
	var g: Int -> Int = { $0 * 3 }

	var myf1 = f >>> g
	myf1(2)	// 12

	var myf2 = curry1(f, g)
	myf2(2)	// 12

### 정리

다중 인자를 갖는 함수를 단일 인자로 갖는 여러 함수로 변형시키는 것을 커링(Currying)이라고 부릅니다.

함수형 프로그래밍을 통해 로직이 견고하게 작성되도록 만들어 집니다.

### 참고 자료

* [위키피디아 커링][Wiki_Currying]
* [위키피디아 언커링][Wiki_UnCurrying]
* [Functional Programming in Swift][Functional Programming in Swift]
* [Scala Document][Scala_Document]


[Wiki_Currying]: http://ko.wikipedia.org/wiki/커링
[Wiki_UnCurrying]: http://en.wikipedia.org/wiki/Currying
[Haskell_Curry]: http://en.wikipedia.org/wiki/Haskell_Curry
[Functional Programming in Swift]: http://www.objc.io/books/
[Scala_Document]: http://docs.scala-lang.org/ko/tutorials/tour/currying.html
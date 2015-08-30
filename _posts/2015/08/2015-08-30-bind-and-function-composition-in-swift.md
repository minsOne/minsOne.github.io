---
layout: post
title: "[Swift]함수 묶기(Binding)"
description: ""
category: "programming"
tags: [swift, function, closure, bind, fp, functional programming, currying]
---
{% include JB/setup %}

### 함수 묶기(Binding)

중첩된 조건문이 많아지면 조건문들을 이해해야 되고, 점점 코드의 복잡도는 증가됩니다. 이러한 조건문들을 함수 단위로 잘게 나누고 묶어 사용할 수 있습니다.

	func bind<A, B>(a: A?, f: A -> B?) -> B?
	{
	    if let x = a {
	        return f(x)
	    } else {
	        return .None
	    }
	}

	func >>=<A, B>(a: A?, f: A -> B?) -> B?
	{
	    return bind(a, f)
	}

`bind` 함수는 a가 nil이 아닐 경우에 함수 f를 호출하는데, 함수 호출 진행 여부를 판단할 수 있습니다.

`>>=` 는 함수와 변수를 묶어 bind 함수에서 함수를 호출하도록 만듭니다.

다음 예제는 위의 bind 함수와 >>= 함수를 이용하여 문자열에 추가 문자열을 붙이도록 합니다.

	let f1: (String) -> (String?) = {
	    str in str + " bind f1"
	}

	let f2: (String) -> (String?) = {
	    str in str + " bind f2"
	}

	let f3: (String) -> (String?) = {
	    str in count(str) > 15 ? str + " bind f3" : nil
	}

	((("String" >>= f1) >>= f2 ) >>= f1) >>= f2	// "String bind f1 bind f2 bind f1 bind f2"
	(("String" >>= f1) >>= f2) >>= f3	// "String bind f1 bind f2 bind f3"

	("String" >>= f1) >>= f3			// nil
	(("String" >>= f1) >>= f3) >>= f2	// nil
	((("String" >>= f1) >>= f3) >>= f2) >>= f1	// nil


### Currying과 Binding

두 숫자를 더하는 함수는 다음과 같이 작성됩니다.

	func add(x: Int, y: Int) -> Int {
		return x + y
	}

이 함수를 `Currying` 형태로 바꾸면 다음과 같이 작성할 수 있습니다.

	func add(x: Int) -> Int -> Int {
	    return {
	        y in x + y
	    }
	}

그리고 `bind`를 같이 사용하면 다음과 같이 사용할 수 있습니다.

	func bind<A, B>(a: A, f: A -> B) -> B {
	    return f(a)
	}

	func >>=<A, B>(a: A, f: A -> B) -> B {
	    return bind(a, f)
	}

	1 >>= 2 >>= add 	// 3

### 결론

하나의 함수는 하나의 기능을 해야한다는 기본 명제에 충실하다면, 함수들을 묶어 좀 더 간결하게 코드를 표현할 수 있습니다.

### 참고 자료

* [Realm - Object-Oriented Functional Programming: 
The Best of Both Worlds!](https://realm.io/news/altconf-saul-mora-object-orientated-functional-programming/)
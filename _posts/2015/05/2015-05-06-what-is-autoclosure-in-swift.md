---
layout: post
title: "[Swift]Autoclosure란?"
description: ""
category: "Mac/iOS"
tags: [swift, autoclosure, function]
---
{% include JB/setup %}

### Auto-Closures

Swift 오픈 소스 라이브러리들을 살펴보면 가끔 `@autoclosure`라는 키워드가 보입니다. 

Swift에서 closure를 사용할 때는 다음과 같이 함수 형태로 인자를 넘겨주도록 합니다.

	func f( pred: () -> Bool ) {
	  if pred() {
	    println("It`s true")
	  }
	}

	f({ 2 > 1 } )
	//or
	f{ 2 > 1 }

<br/>하지만 @autoclosure를 사용하면 함수 사용할 때 `{}`를 사용하지 않고 `()`를 사용합니다.

	func g(@autoclosure pred: () -> Bool ) {
	  if pred() {
	    println("It`s true")
	  }
	}

	g( 3 > 1 )
	//or
	g( { 3 > 1 }() )

함수에 인자를 넣어 사용하는 것과 비슷한 형태로 사용할 수 있습니다.

<div class="alert-info">`()`가 아닌 `(Int)` 등 인자를 받고자 하려고 한다면 컴파일러가 `Autoclosure argument type must be '()'`로 에러를 보여줍니다. 따라서 인자를 추가할 수 없습니다.</div>

또한, `assert` 함수도 @autoclosure 형태로 구현되어 있음을 확인할 수 있습니다.

	func assert(condition: @autoclosure () -> Bool, 
		_ message: @autoclosure () -> String = default, 
		file: StaticString = default, 
		line: UWord = default)

#### 참고 자료

* [Stackoverflow][Stackoverflow]
* [Apple Blog][Apple_Blog]

<br/>

[Stackoverflow]: http://stackoverflow.com/questions/24102617/how-to-use-swift-autoclosure/24103289?stw=2#24103289
[Apple_Blog]: https://developer.apple.com/swift/blog/
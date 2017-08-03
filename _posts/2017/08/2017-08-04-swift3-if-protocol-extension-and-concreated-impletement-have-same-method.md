---
layout: post
title: "[Swift3]Protocol Extension(1) - 클래스 또는 구조체가 Protocol Extension에 같은 이름을 갖는 메소드나 계산 속성을 가질 때 어떻게 될까?"
description: ""
category: "Programming"
tags: [Swift, Protocol, Extension, Protocol Extension, Class, Struct]
---
{% include JB/setup %}

Swift로 코드를 작성하다보면 Protocol Extension에 구현된 메소드 또는 계산 속성과 클래스 또는 구조체에 구현된 메소드와 계산 속성 이름이 같으면 어떻게 동작하지 라는 고민을 하게 됩니다.

A라는 프로토콜에 foo라는 함수를 명시한 뒤, Extension에 foo 함수를 구현합니다.

```
protocol A {
	func foo() -> String
}

extension A {
	func foo() -> String {
		return "foo"
	}
}

class B: A {}
```

클래스 B는 프로토콜 A를 따르기 때문에, 프로토콜 A의 foo 함수를 B에서 사용할 수 있습니다.

```
print(B().foo()) // foo
```

그러면 클래스 B에다 foo 함수를 작성하면 어떻게 될까요?

```
class B: A {
	func foo() -> String {
		return "Foo"
	}
}

let b: A = B()
print(b.foo()) // Foo
```

컴파일 에러가 발생하지 않으며, B에서 작성된 foo 함수의 결과값이 반환됩니다. 클래스 B의 foo 함수를 찾아서 호출되기 때문입니다.

그렇다면 프로토콜 A에 정의되지 않은 함수를 Extension에 구현하고, 클래스 B에 extension에 구현된 함수의 이름과 같게 구현하면 어떻게 될까요?

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
```

이제 클래스 B의 bar 함수를 호출해봅시다.

```
let b: A = B()
print(b.bar()) // bar
```

앞에서 foo 함수 호출과는 다르게 bar 함수 호출시 `bar`로 출력이 되었습니다. 그러면 변수 b의 타입을 클래스 B로 변경하여 다시 호출봅시다.

```
let b: B = B()
print(b.bar()) // Bar
```

변수 b의 타입이 달리지니 결과도 달라졌습니다. 클래스 또는 구조체 타입이냐 프로토콜 타입이냐에 따라 프로토콜에 정의되지 않은 함수를 호출시 결과가 달라집니다.

다음 포스팅에서 왜 출력값이 달라지는지 알아보도록 하겠습니다.

<br/>

### 다음 포스팅 참고 자료

* [objc_msgSend() Tour](http://www.friday.com/bbum/2009/12/18/objc_msgsend-part-1-the-road-map/)
* [Method Dispatch in Swift](https://www.raizlabs.com/dev/2016/12/swift-method-dispatch/)
* [Swift - ABI](https://github.com/apple/swift/blob/master/docs/ABI/TypeMetadata.rst#protocol-metadata)
* [The Ghost of Swift Bugs Future](https://nomothetis.svbtle.com/the-ghost-of-swift-bugs-future)
* [Wikipedia - Dynamic dispatch](https://en.wikipedia.org/wiki/Dynamic_dispatch)
* [Wikipedia - 가상 메소드 테이블](https://ko.wikipedia.org/wiki/%EA%B0%80%EC%83%81_%EB%A9%94%EC%86%8C%EB%93%9C_%ED%85%8C%EC%9D%B4%EB%B8%94)
* [[iOS] dynamic dispatch로 메서드(Method)가 호출되는 과정 (objc_msgSend)](http://blog.naver.com/PostView.nhn?blogId=horajjan&logNo=220956348099)
* [Increasing Performance by Reducing Dynamic Dispatch](https://developer.apple.com/swift/blog/?id=27)
* [Swift 성능 이해하기: Value 타입, Protocol과 스위프트의 성능 최적화](https://news.realm.io/kr/news/letswift-swift-performance/)
* [Friday Q&A 2014-07-18: Exploring Swift Memory Layout](https://mikeash.com/pyblog/friday-qa-2014-07-18-exploring-swift-memory-layout.html)
* [Overriding Swift Protocol Extension Default Implementations](https://team.goodeggs.com/overriding-swift-protocol-extension-default-implementations-d005a4428bda)
* [Understanding Swift Performance - WWDC 2016](https://developer.apple.com/videos/play/wwdc2016/416/)
* [Optimizing Swift Performance - WWDC 2015](https://developer.apple.com/videos/play/wwdc2015/409/)
* [Building Better Apps with Value Types in Swift - WWDC 2015](https://developer.apple.com/videos/play/wwdc2015/414/)
* [Reddit](https://www.reddit.com/r/iOSProgramming/comments/3atu5w/does_swift_use_dynamic_method_dispatch_or_a/)
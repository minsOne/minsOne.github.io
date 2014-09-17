---
layout: post
title: "Swift - Extensions 정리"
description: ""
category: "mac/ios"
tags: [swift, extension, initializer, category, method, subscript, property]
---
{% include JB/setup %}

## 확장(Extensions)

확장은 기존 클래스, 구조체 또는 열거형 타입에 새로운 기능을 추가한다. 기존 소스 코드에서 접근하지 못하는 타입들을 확장하는 능력이다(소급 적용 모델링). 확장은 Objective-C의 카테고리와 유사하다(Swift 확장은 이름을 가지지 않는다는 점에서 Objective-C 카테고리와는 다르다.).

Swift에서 확장은 다음 기능을 할 수 있다:

* 계산 속성과 계산 정적 속성 추가
* 인스턴스 메소드와 타입 메소드 정의
* 새로운 이니셜라이저 제공
* 서브스크립트 정의
* 새로운 중첩 타입 정의와 사용
* 기존 타입에 프로토콜 적용하기

<div class="alert-info">
	확장은 타입에 새로운 기능을 추가할 수 있지만 기존 기능을 오버라이드 할 수 없다.
</div>

### 확장 문법(Extension Syntax)

`extension` 키워드로 확장을 선언한다.

	extension SomeType {
	    // new functionality to add to SomeType goes here
	}

확장은 하나 이상의 프로토콜을 만들어 기존 타입에 적용시켜 확장한다. 

	extension SomeType: SomeProtocol, AnotherProtocol {
	    // implementation of protocol requirements goes here
	}

<div class="alert-info">
	기존 타입에 새로운 기능을 추가하기 위해 확장을 정의한다면, 새로운 기능은 기존 타입의 인스턴스에서 가능하다. 심지어 확장이 정의되기 전에 만들어진다.
</div>

### 계산 속성(Computed Properties)

확장은 기존 타입에 계산 인스턴스 속성과 계산 타입 속성을 추가할 수 있다. 다음은 다섯개의 계산 인스턴스 속성을 Swift에 탑재된 Double 타입에 추가하는 예제이다.

	extension Double {
	    var km: Double { return self * 1_000.0 }
	    var m: Double { return self }
	    var cm: Double { return self / 100.0 }
	    var mm: Double { return self / 1_000.0 }
	    var ft: Double { return self / 3.28084 }
	}
	let oneInch = 25.4.mm
	println("One inch is \(oneInch) meters")
	// prints "One inch is 0.0254 meters"
	let threeFeet = 3.ft
	println("Three feet is \(threeFeet) meters")
	// prints "Three feet is 0.914399970739201 meters"

이들 계 속성은 Double 값이 특정 길이의 단위로 간주됨을 나타낸다. 계산 속성들로 구현되었지만 부동소수점 리터럴 값에 점 문법으로 속성의 이름을 덧붙여 리터럴 값을 거리값으로 변환할 수 있다.

1.0의 Double value는 일 미터로 표현하는 예제로, `m` 계산 속성은 `self`를 반환한다. 1.m 표현은 1.0의 Double 값으로 계산하여 간주된다.

다른 단위들은 미터 측정값으로 표현되기 위한 변환이 필요하다. 1킬로미터는 1,000 미터와 같고, 그래서 `km` 계산 속성은 1_000.00을 값에 곱하여 표현한다. 유사하게 1미터는 3.28024 피트이고 `ft`는 3.28024를 Double 값으로 나누어 피트를 미터로 변경한다.

이들 속성은 읽기 전용 계산 속성으로, `get` 키워드 없이 짧게 표현된다. Double 타입의 반환 값은 산술 계산을 사용하여 Double에 어디에나 적용된다.

	let aMarathon = 42.km + 195.m
	println("A marathon is \(aMarathon) meters long")
	// prints "A marathon is 42195.0 meters long"

<div class="alert-info">
	확장은 새로운 계산 속성을 추가할 수 있지만, 저장 속성이나 기존 속성에 속성 감시자를 추가할 수 없다.
</div>

### 이니셜라이저(Initializers)

확장은 기존 타입에 새로운 이니셜라이저를 추가할 수 있다. 이는 다른 타입이 사용자 타입의 이니셜라이저 인자로 받거나 타입의 기본 구현의 부분에 포함되지 않는 추가적인 초기화 옵션을 제공하도록 확장이 가능하다.

확장은 클래스에 새로운 편의 이니셜라이저를 추가할 수 있으나, 새로운 지정 이니셜라이저나 디이니셜라이저를 클래스에 추가할 수 없다. 지정 이니셜라이저와 디이니셜라이저는 항상 기존 클래스 구현이 되어 있어야 한다.

<div class="alert-info">
	모든 저장 속성에 기본 값을 주고 사용자 이니셜라이저를 정의하지 않는 값 타입에 이니셜라이저를 추가하기 위해 확장을 사용한다면, 확장 이니셜라이저 안으로부터 값 타입을 위한 기본 이니셜라이저와 멤버 이니셜라이저를 호출한다.
</div>

다음은 모든 속성에 기본 값이 주어지는 구조체 예제이다.

	struct Size {
	    var width = 0.0, height = 0.0
	}
	struct Point {
	    var x = 0.0, y = 0.0
	}
	struct Rect {
	    var origin = Point()
	    var size = Size()
	}

기본적인 이니셜라이저를 통해 Rect 인스턴스를 만들 수 있다.

	let defaultRect = Rect()
	let memberwiseRect = Rect(origin: Point(x: 2.0, y: 2.0),
	    size: Size(width: 5.0, height: 5.0))

Rect 구조체를 확장하여 특정 중앙 좌표와 크기를 갖는 이니셜라이저를 추가할 수 있다.

	extension Rect {
	    init(center: Point, size: Size) {
	        let originX = center.x - (size.width / 2)
	        let originY = center.y - (size.height / 2)
	        self.init(origin: Point(x: originX, y: originY), size: size)
	    }
	}

새로운 이니셜라이저는 center 좌표와 size 크기를 통해 기존 좌표를 계산하여 적합한 위치로 멤버 이니셜라이저를 호출하여 초기화한다.

	let centerRect = Rect(center: Point(x: 4.0, y: 4.0),
	    size: Size(width: 3.0, height: 3.0))
	// centerRect's origin is (2.5, 2.5) and its size is (3.0, 3.0)

<div class="alert-info">
	확장을 이용한 새로운 이니셜라이저를 제공한다면, 이니셜라이저가 완료되었을 때 각 인스턴스가 완전히 초기화되었는지 확인하는 책임이 있다.
</div>

### 메소드(Methods)

확장은 새로운 인스턴스 메소드와 타입 메소드를 기존 타입에 추가할 수 있다. 다음은 Int 타입에 인스턴스 메소드를 추가하는 예제이다.

	extension Int {
	    func repetitions(task: () -> ()) {
	        for i in 0..<self {
	            task()
	        }
	    }
	}

repetitions 메소드는 타입 `() -> ()` 단일 인자를 가지며, 이 함수는 인자와 반환 값을 가지지 않는다.

확장이 정의된 뒤에, 호출할 만큼의 정수에서 repetitions 메소드를 호출할 수 있다.

	3.repetitions({
	    println("Hello!")
	})
	// Hello!
	// Hello!
	// Hello!

클로저 문법으로 더 간결하게 호출하여 사용한다.

	3.repetitions {
	    println("Goodbye!")
	}
	// Goodbye!
	// Goodbye!
	// Goodbye!

### 서브스크립트(Subscripts)

확장은 기존 타입에 새로운 서브스크립트를 추가할 수 있다. 다음은 Swift에 내재된 Int 타입에 정수 서브스크립트를 추가하는 예제이다. 서브스크립트 `[n]`는 n번째 숫자를 반환한다.

	extension Int {
	    subscript(var digitIndex: Int) -> Int {
	        var decimalBase = 1
	            while digitIndex > 0 {
	                decimalBase *= 10
	                --digitIndex
	            }
	            return (self / decimalBase) % 10
	    }
	}
	746381295[0]
	// returns 5
	746381295[1]
	// returns 9
	746381295[2]
	// returns 2
	746381295[8]
	// returns 7


### 중첩 타입(Nested Types)

확장은 기존 클래스, 구조체 그리고 열거형에 새로운 중첩 타입을 추가할 수 있다.

	extension Int {
	    enum Kind {
	        case Negative, Zero, Positive
	    }
	    var kind: Kind {
	        switch self {
	        case 0:
	            return .Zero
	        case let x where x > 0:
	            return .Positive
	        default:
	            return .Negative
	            }
	    }
	}

위 예제는 Int 타입에 새로운 중첩 열거형을 추가하였다. Kind 라는 열거형은 정수 종류를 zero, positive, negative라고 표현한다.

다음은 Int에 계산 인스턴스 속성을 추가하는 예제로 적합한 기호를 반환해준다.

	func printIntegerKinds(numbers: [Int]) {
	    for number in numbers {
	        switch number.kind {
	        case .Negative:
	            print("- ")
	        case .Zero:
	            print("0 ")
	        case .Positive:
	            print("+ ")
	        }
	    }
	    print("\n")
	}
	printIntegerKinds([3, 19, -27, 0, -6, 0, 7])
	// prints "+ + - 0 - 0 +"

<div class="alert-info">
	<code>number.kind</code>는 <code>Int.Kind</code> 타입으로 이미 알려져 있다. <code>Int.Kind</code> 모든 멤버 값은 Switch 문에서 축약하여 작성되기 때문에 <code>Int.Kind.negative</code> 보단 <code>.Negative</code>를 사용한다.
</code>
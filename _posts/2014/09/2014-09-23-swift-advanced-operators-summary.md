---
layout: post
title: "[Swift]Advanced Operators 정리"
description: ""
category: "mac/ios"
tags: [swift, operator, bit, infix, prefix, postfix, overflow, underflow, equivalence, associativity, precedence, left, right, none]
---
{% include JB/setup %}

## 고급 연산자(Advanced Operators)

Swift는 더 복잡한 값 조작을 동작하는 몇가지 고급 연산자를 제공한다. 비트 관련 연산자는 C와 Objective-C와 유사하다.

Swift에 산술 연산자는 기본적으로 오버플로우를 제공하지 않는다. 오버플로우 행동은 에러가 발생한다. 오버플로우 행동은 옵션으로 할 수 있는데 오버플로우 덧셈 연산자(`&+`)로 사용하여 오버플로우가 가능핟. 오버플로우 연산자는 `&`기호로 시작한다.

Swift는 사용자 중위, 전위, 후위, 할당 연산자를 자유롭게 정의할 수 있다. 또한 기존 타입을 확장할 수 있다.

### 비트 연산자(Bitwise Operators)

비트 연산자는 데이터 구조 내에 각각의 원시 데이타 비트를 조작하는 것이 가능하다. 그래픽 프로그래밍과 디바이스 드라이버 생성과 같은 저급 프로그래밍을 사용하는데 유용하다. 또한, 사용자 프로토콜로 커뮤니케이션을 위한 인코딩, 디코딩 데이터처럼 외부 소스로부터 원시 데이터를 작업할 때 유용하다.

#### 비트 NOT 연산자(Bitwise NOT Operator)

비트 NOT 연산자(`~`)는 모든 비트 수를 거꾸로 한다.

<img src="/../../../../image/2014/09/bitwiseNOT_2x.png" alt="bitwiseNOT" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

비트 NOT 연산자는 전위 연산자이다.

	let initialBits: UInt8 = 0b00001111
	let invertedBits = ~initialBits  // equals 11110000

#### 비트 AND 연산자(Bitwise AND Operator)

비트 AND 연산자(`&`)는 두 수의 비트를 AND 연산으로 결합한다.

<img src="/../../../../image/2014/09/bitwiseAND_2x.png" alt="bitwiseAND" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

비트 AND 연산자는 중위 연산자이다.

	let firstSixBits: UInt8 = 0b11111100
	let lastSixBits: UInt8  = 0b00111111
	let middleFourBits = firstSixBits & lastSixBits  // equals 00111100

#### 비트 OR 연산자(Bitwise OR Operator)

비트 OR 연산자(`|`)는 두 수의 비트를 OR 연산한다.

<img src="/../../../../image/2014/09/bitwiseOR_2x.png" alt="bitwiseOR" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

비트 OR 연산자는 중위 연산자이다.

	let someBits: UInt8 = 0b10110010
	let moreBits: UInt8 = 0b01011110
	let combinedbits = someBits | moreBits  // equals 11111110

#### 비트 XOR 연산자(Bitwise XOR Operator)

비트 XOR 연산자는 배타적인 OR 연산자(`^`)로, 두 값을 XOR 연산한다.

<img src="/../../../../image/2014/09/bitwiseXOR_2x.png" alt="bitwiseXOR" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

비트 XOR 연산자는 중위 연산자이다.

	let firstBits: UInt8 = 0b00010100
	let otherBits: UInt8 = 0b00000101
	let outputBits = firstBits ^ otherBits  // equals 00010001

#### 비트 왼쪽과 오른쪽 이동 연산자(Bitwise Left and Right Shift Operators)

비트 왼쪽 이동 연산자(`<<`)와 비트 오른쪽 이동 연산자(`>>`)는 모든 비트를 왼쪽 또는 오른쪽으로 특정 수만큼 이동시킨다.

##### Unsigned 정수를 위한 이동 동작(Shifting Behavior for Unsigned Intergers)

비트 이동 동작은 다음을 따른다.

1. 기존 비트는 요청된 수만큼 왼쪽이나 오른쪽으로 이동한다.
2. 모든 비트는 정수의 저장공간 범위를 벗어나면 버려진다.
3. 왼쪽이나 오른쪽으로 비트가 이동하면 그 공간에 0이 삽입된다.

<img src="/../../../../image/2014/09/bitshiftUnsigned_2x.png" alt="bitshiftUnsigned" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

	let shiftBits: UInt8 = 4   // 00000100 in binary
	shiftBits << 1             // 00001000
	shiftBits << 2             // 00010000
	shiftBits << 5             // 10000000
	shiftBits << 6             // 00000000
	shiftBits >> 2             // 00000001

다른 데이타 타입 내에서 값을 인코딩 및 디코딩을 하기 위해 비트 이동을 사용할 수 있다.

	let pink: UInt32 = 0xCC6699
	let redComponent = (pink & 0xFF0000) >> 16    // redComponent is 0xCC, or 204
	let greenComponent = (pink & 0x00FF00) >> 8   // greenComponent is 0x66, or 102
	let blueComponent = pink & 0x0000FF           // blueComponent is 0x99, or 153

##### Signed 정수를 위한 이동 동작(Shifting Behavior for Signed Integers)

Unsigned 정수보다 signed 정수가 좀 더 복잡하다. 이는 가장 마지막 비트가 부호를 표현하는 비트이기 때문이다.

부호 비트가 0이면 양수, 1이면 음수를 의미한다.

양수 4는 다음과 같이 표시된다.

<img src="/../../../../image/2014/09/bitshiftSignedFour_2x.png" alt="bitshiftSignedFour" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

음수 -4는 다음과 같이 표시된다.

<img src="/../../../../image/2014/09/bitshiftSignedMinusFour_2x.png" alt="bitshiftSignedMinusFour" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

음수 -4는 128 - 4인 값 124의 바이너리 값으로 가진다.

<img src="/../../../../image/2014/09/bitshiftSignedMinusFourValue_2x.png" alt="bitshiftSignedMinusFourValue" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

다음은 signed 정수를 오른쪽으로 이동할 때, 빈 공간이 어떻게 채워지는지 나타내는 그림이다. 

<img src="/../../../../image/2014/09/bitshiftSigned_2x.png" alt="bitshiftSigned" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

오른쪽으로 비트를 이동할 때, 부호 비트 값으로 빈 공간을 채운다.

### 오버플로우 연산자(Overflow Operators)

Swift는 오버플로우를 지원하지 않는다. 만약 오버플로우가 발생할 경우 유효하지 않은 값을 할당하는 것 보다 에러를 발생시킨다. 이러한 행동은 너무 큰 수나 너무 작은 수를 작업할 때 추가적으로 안전하다.

하지만 때로는, 에러를 발생시키는 것 보다 오버플로우를 발생하는 것이 나을 때도 있다. 산술 오버플로우 연산자는 기존 연산자에 `&`를 앞에 붙인다.

* 오버플로우 덧셈연산자(`&+`)
* 오버플로우 뺄셈연산자(`&-`)
* 오버플로우 곱셈연산자(`&*`)
* 오버플로우 나눗셈연산자(`&/`)
* 오버플로우 나머지연산자(`&%`)

#### 값 오버플로우(Value Overflow)

다음은 Unsigned 값에 오버플로우 덧셈 연산하는 예제이다.

	var willOverflow = UInt8.max
	// willOverflow equals 255, which is the largest value a UInt8 can hold
	willOverflow = willOverflow &+ 1
	// willOverflow is now equal to 0

<img src="/../../../../image/2014/09/overflowAddition_2x.png" alt="overflowAddition" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

#### 값 언더플로우(Value Underflow)

가장 작은 값의 범위를 벗어나도록 연산하는 예제이다.

	var willUnderflow = UInt8.min
	// willUnderflow equals 0, which is the smallest value a UInt8 can hold
	willUnderflow = willUnderflow &- 1
	// willUnderflow is now equal to 255

<img src="/../../../../image/2014/09/overflowUnsignedSubtraction_2x.png" alt="overflowUnsignedSubtraction" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

#### 0으로 나누기(Division by Zero)

값을 0으로 나누거나 0의 나머지를 계산하려고 하면 에러가 발생한다.

	let x = 1
	let y = x / 0

그러나 오버플로우 버전의 연산자로 계산할 경우 0의 값을 반환한다.

	let x = 1
	let y = x &/ 0
	// y is equal to 0

### 우선순위와 연관성(Precedence and Associativity)

연산자 우선순위는 C나 Objective-C의 우선순위와 동일하다.

### 연산자 함수(Operator Functions)

클래스와 구조체는 자신만의 기존 연산자 구현을 제공할 수 있다. 이것은 기존 연산자 오버로딩으로 알려져있다.

	struct Vector2D {
	    var x = 0.0, y = 0.0
	}
	func + (left: Vector2D, right: Vector2D) -> Vector2D {
	    return Vector2D(x: left.x + right.x, y: left.y + right.y)
	}

연산자 함수가 전역으로 선언되면, 해당 클래스와 구조체의 메소드 대신하여 연산자를 사용할 수 있다.

	let vector = Vector2D(x: 3.0, y: 1.0)
	let anotherVector = Vector2D(x: 2.0, y: 4.0)
	let combinedVector = vector + anotherVector
	// combinedVector is a Vector2D instance with values of (5.0, 5.0)

#### 전위 연산자와 후위 연산자(Prefix and Postfix Operators)

클래스와 구조체는 표준 단항 연산자의 구현을 제공할 수 있다. 단항 연산자는 단일 타켓에 동작한다.

연산자 함수를 선언할 때 전위 또는 후위 단항 연산자는 `prefix` 또는 `postfix` 수식어를 `func` 키워드 앞에 작성하여 구현한다.

	prefix func - (vector: Vector2D) -> Vector2D {
	    return Vector2D(x: -vector.x, y: -vector.y)
	}

	let positive = Vector2D(x: 3.0, y: 4.0)
	let negative = -positive
	// negative is a Vector2D instance with values of (-3.0, -4.0)
	let alsoPositive = -negative
	// alsoPositive is a Vector2D instance with values of (3.0, 4.0)

#### 복합 할당 연산자(Compound Assignment Operators)

복합 할당 연산자는 할당 연산자(`=`)와 다른 연산자가 결합한다. 복합 할당 연산자의 왼쪽 입력 인자는 `inout`으로 표시하는데, 인자의 값이 연산자 함수 내에서 직접적으로 수정된다.

	func += (inout left: Vector2D, right: Vector2D) {
	    left = left + right
	}

	var original = Vector2D(x: 1.0, y: 2.0)
	let vectorToAdd = Vector2D(x: 3.0, y: 4.0)
	original += vectorToAdd
	// original now has values of (4.0, 6.0)

전위 또는 후위 수식어으로 증감 연산자를 구현할 수 있다.

	prefix func ++ (inout vector: Vector2D) -> Vector2D {
	    vector += Vector2D(x: 1.0, y: 1.0)
	    return vector
	}

	var toIncrement = Vector2D(x: 3.0, y: 4.0)
	let afterIncrement = ++toIncrement
	// toIncrement now has values of (4.0, 5.0)
	// afterIncrement also has values of (4.0, 5.0)

<div class="alert-info">
	기본 할당 연산자(<code>=</code>)는 오버로드를 할 수 없다. 오로지 복합 할당 연산자만 오버로드가 가능하다. 유사하게 삼항 조건 연산자(<code>a ? b : c</code>)도 오버로드 될 수 없다.
</div>

### 항등 연산자(Equivalence Operators)

사용자 클래스와 구조체는 기본적으로 기본적인 항등 연산자의 구현으로 받을 수 없다. Swift는 사용자 타입에 대해서는 같다라는 것을 추측하지 못한다. 때문에 사용자 타입의 항등을 검사할 수 있는 항등 연산자를 구현하여 사용할 수 있다.

항등 연산자는 중위 연산자이다.

	func == (left: Vector2D, right: Vector2D) -> Bool {
	    return (left.x == right.x) && (left.y == right.y)
	}
	func != (left: Vector2D, right: Vector2D) -> Bool {
	    return !(left == right)
	}

	let twoThree = Vector2D(x: 2.0, y: 3.0)
	let anotherTwoThree = Vector2D(x: 2.0, y: 3.0)
	if twoThree == anotherTwoThree {
	    println("These two vectors are equivalent.")
	}
	// prints "These two vectors are equivalent."

### 사용자 연산자(Custom Operators)

새로운 연산자는 `operator` 키워드를 사용하여 전역 수준으로 정의되며 `prefix`, `infix` 또는 `postfix` 수식으로 표시된다.

	prefix operator +++ {}

다음은 새로운 `+++` 전위 연산자를 정의하는 예제이다.

	prefix func +++ (inout vector: Vector2D) -> Vector2D {
	    vector += vector
	    return vector
	}

`+++` 연산자는 단항 연산을 하기 때문에 인자에 `inout` 가 앞에 붙는다.

	var toBeDoubled = Vector2D(x: 1.0, y: 4.0)
	let afterDoubling = +++toBeDoubled
	// toBeDoubled now has values of (2.0, 8.0)
	// afterDoubling also has values of (2.0, 8.0)


#### 사용자 중위 연산자를 위한 우선순위와 연관성(Precedence and Associativity for Custom Infix Operators)

사용자 중위 연산자는 우선순위와 연관성을 지정할 수 있다. `associativity`는 `left`, `right` 그리고 `none`이다. 왼쪽 결합 연산자는 같은 우선순위라면 왼쪽부터 수행된다. 오른쪽 결합 연산자라면 오른쪽부터 수행된다.

`associativity`의 기본 값은 `none`이며, `precedence`의 기본 값은 100이다.

다음은 새로운 사용자 중위 연산자 +-로 왼쪽 결합과 140의 우순순위를 가지는 예제이다.

	infix operator +- { associativity left precedence 140 }
	func +- (left: Vector2D, right: Vector2D) -> Vector2D {
	    return Vector2D(x: left.x + right.x, y: left.y - right.y)
	}
	let firstVector = Vector2D(x: 1.0, y: 2.0)
	let secondVector = Vector2D(x: 3.0, y: 4.0)
	let plusMinusVector = firstVector +- secondVector

<div class="alert-info">
	전위 또는 후위 연산자를 정의할 때 우선순위를 지정하지 않는다. 같은 피연산자에 전위와 후위 연산자를 모두 적용할 경우, 후위 연산자가 먼저 적용된다.
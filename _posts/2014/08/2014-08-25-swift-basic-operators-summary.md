---
layout: post
title: "Swift - Basic Operators 정리"
description: ""
category: "mac/ios"
tags: [swift, operator]
---
{% include JB/setup %}

Swift는 대부분의 표준 C 연산자를 지원하고 흔하게 발생하는 코딩 에러를 제거하는 몇가지 기능을 향상시킴.

할당 연산자(=)는 항등 연산자(==)를 사용할 때 실수로 사용하는 것을 방지하도록, 값을 반환하지 않음.

산술 연산자(+, -, *, /, % 등)은 오버플로우를 감지하고 예상치 못한 결과가 발생하는 것을 방지.

C와는 다르게 나머지 연산자(%)를 부동 소수점 수에 수행 가능.

C에는 없는 2개의 범위 연산자(a..<b와 a...b)는 값의 범위를 표현.


### 용어(Terminology)

연산자에는 단항, 아헝, 삼항이 있음.

* 단항 연산자는 단일 대상에 동작(ex. -a), 단항 전위 연산자는 대상 앞에 나타내고(ex. !b), 단항 후위 연산자는 대상 뒤에 나타남(ex. i++).
* 이항 연산자는 두 개의 대상에 동작하며(ex. 2 + 3), 두 개의 대상 사이에 나타나기 때문에 중위 연산자
* 삼항 연산자는 C와 비슷하게 삼항 조건 연산자만을 가짐(ex. a ? b : c)


### 할당 연산자(Assignment Operator)

할당 연산자는 값을 초기화 하거나 변경함.(ex. a = b)

	let b = 10
	var a = 5
	a = b
	// a is now equal to 10
	
	let (x, y) = (1, 2)
	// x is equal to 1, and y is equal to 2

C와 Objective-C의 할당 연산자와는 다르게 할당 연산자는 값을 반환하지 않음.

다음은 유효하지 않은 코드임. 항등 연산자(==)가 실수로 대입 연산자(=)로 사용하는 것을 방지하기 위함.

	if x = y {
	    // this is not valid, because x = y does not return a value
	}


### 산술 연산자(Arithmetic Operators)

Swift는 4가지 표준 산술 연산자를 모든 숫자 타입에 지원.

* 덧셈(+)
* 뺄셈(-)
* 곱셈(*)
* 나눗셈(/)

C와 Objective-C의 산술 연산자와는 다르게 Swift 산술 연산자는 오버플로우를 지원하지 않음. Swift 오버플로우 연산자(a &+ b)를 사용하여 오버플로우 행동을 선택할 수 있음.

덧셈 연산자는 String 연결도 지원.

	"hello, " + "world"	// equals "hello, world"

두 개의 Chraracter 값이거나 각각의 Chraracter 값과 String 값을 더하여 새로운 String 값을 만들 수 있음.

	let dog: Character = "🐶"
	let cow: Character = "🐮"
	let dogCow = dog + cow
	// dogCow is equal to "🐶🐮"


### 나머지 연산자(Remainder Operator)

나머지 연산자(a % b)는 b를 몇 배 곱하여 a에 맞춘 다음 남는 값을 반환.

다음은 9 % 4를 계산하여 어떻게 값을 얻는지 알 수 있음.

<img src="/../../../../image/2014/08/remainderInteger_2x.png" alt="remainderInteger" style="width: 500px;"/><br/>

a % b에 % 연산자는 다음 방정식을 계산하고 나머지(remainder)를 반환.

a = (b x 배수) + 나머지

a값이 음수라도 같은 방법으로 값을 얻을 수 있음.

	-9 % 4   // equals -1


### 부동 소수점 나머지 연산(Floating-Point Remainder Calculations)

C와 Objective-C의 나머지 연산자과는 다르게 Swift의 나머지 연산자는 부동 소수점 수 연산을 할 수 있음.

	8 % 2.5   // equals 0.5

8을 2.5로 나누면 3과 같고 나머지는 0.5이며 나머지 연산자는 Double 타입의 0.5 값을 반환함.

<img src="/../../../../image/2014/08/remainderfloat_2x.png" alt="remainderfloat" style="width: 500px;"/><br/>


### 증감 연산자(Increment and Decrement Operators)

C와 같이 Swift는 증가 연산자(++)와 감소 연산자(--)를 제공.

### 단항 음수 연산자(Unary Minus Operator)

단항 음수 연산자 -를 수 앞에 사용하여 부호를 전환.

	let three = 3
	let minusThree = -three       // minusThree equals -3
	let plusThree = -minusThree   // plusThree equals 3, or "minus minus three"

### 단항 양수 연산자(Unary Plus Operator)

단항 양수 연산자 +를 수 앞에 사용하지만 아무런 변화 없음.

	let minusSix = -6
	let alsoMinusSix = +minusSix  // alsoMinusSix equals -6

### 복합 할당 연산자(Compound Assignment Operators)

C와 같이 Swift는 복합 할당 연산자를 제공함.

	var a = 1
	a += 2
	// a is now equal to 3

### 비교 연산자(Comparison Operators)

Swift는 C의 표준 비교 연산자를 지원.

* 같음 (a == b)
* 같지 않음 (a != b)
* 보다 큰 (a > b)
* 보다 작은 (a < b)
* 보다 크거나 같음 (a >= b)
* 보다 작거나 같음 (a <= b)

비교 연산자는 각 문장이 참인지 나타내는 Bool 값을 반환.

	1 == 1   // true, because 1 is equal to 1
	2 != 1   // true, because 2 is not equal to 1
	2 > 1    // true, because 2 is greater than 1
	1 < 2    // true, because 1 is less than 2
	1 >= 1   // true, because 1 is greater than or equal to 1
	2 <= 1   // false, because 2 is not less than or equal to 1

비교 연산자는 if문 같은 조건문에 종종 사용됨.

	let name = "world"
	if name == "world" {
	    println("hello, world")
	} else {
	    println("I'm sorry \(name), but I don't recognize you")
	}
	// prints "hello, world", because name is indeed equal to "world"

### 삼항 연산자(Ternary Conditional Operator)

삼항 조건 연산자는 세 부분과 특별한 연산자이며 `question ? answer1 : answer2` 식으로 사용. `question`이 true인지 false 인지에 따라 값을 반환하는 것이 다름. true이면 answer1을, false이면 answer2를 반환함.

삼항 조건 연산자는 다음 코드를 축약함.

	if question {
	    answer1
	} else {
	    answer2
	}

### Nil 결합 연산자(Nil Coalescing Operator)

Nil 결합 연산자(a ?? b)는 옵셔널 a를 풀어 nil인지 확안하여 nil이면 b값을, nil이 아니면 a값을 반환함.

항상 a는 옵셔널 타입이어야 하며 b는 a와 타입이 일치해야 함.

	let defaultColorName = "red"
	var userDefinedColorName: String?   // defaults to nil
	 
	var colorNameToUse = userDefinedColorName ?? defaultColorName
	// userDefinedColorName is nil, so colorNameToUse is set to the default of "red"

userDefinedColorName가 nil이므로 colorNameToUse는 defaultColorName 값을 가짐.

	userDefinedColorName = "green"
	colorNameToUse = userDefinedColorName ?? defaultColorName
	// userDefinedColorName is not nil, so colorNameToUse is set to "green"

userDefinedColorName 값이 nil이 아니므로 colorNameToUse는 userDefinedColorName 값을 가짐.


### 범위 연산자(Range Operators)

### 닫힌 범위 연산자(Closed Range Operator)

닫힌 범위 연산자(a...b)는 a에서 b까지 수행되는 범위로, a와 b 값을 포함함. a는 b보다 크면 안됨.

닫힌 범위 연산자는 `for-in` 반복문과 같이 값 범위에서 반복해서 사용할 때 유용함.

	for index in 1...5 {
	    println("\(index) times 5 is \(index * 5)")
	}
	// 1 times 5 is 5
	// 2 times 5 is 10
	// 3 times 5 is 15
	// 4 times 5 is 20
	// 5 times 5 is 25

### 반 열림 범위 연산자(Half-Open Range Operator)

반 열림 범위 연산자(a..<b)는 a에서 b까지 수행되는 범위이지만 b는 포함되지 않음. 처음 값은 포함하지만 마지막 값은 포함하지 않음.

닫힌 범위 연산자와 같이 a는 b보다 크면 안됨.

반 열림 범위는 0을 기반으로 한 배열을 작업할 때 유용.

	let names = ["Anna", "Alex", "Brian", "Jack"]
	let count = names.count
	for i in 0..<count {
	    println("Person \(i + 1) is called \(names[i])")
	}
	// Person 1 is called Anna
	// Person 2 is called Alex
	// Person 3 is called Brian
	// Person 4 is called Jack

### 논리 연산자(Logical Operator)

논리 연산자는 불리언 논리 값 true와 false를 수정하거나 결합함. Swift는 C 기반 언어에 3가지 표준 논리 연산자를 지원함.

* NOT(!a)
* AND(a && b)
* OR(a || b)

### 논리 NOT 연산자(Logical NOT Operator)

논리 NOT 연산자(!a)는 true 값을 false로, false 값을 true로 반전함.

논리 NOT 연산자는 전위 연산자로 값 앞에 공백없이 표시. `not a`로 읽음.

	let allowedEntry = false
	if !allowedEntry {
	    println("ACCESS DENIED")
	}

### 논리 AND 연산자(Logical AND Operator)

논리 AND 연산자(a && b)는 두개의 값이 true여야 true가 되는 논리 표현식을 생성.

두 값이 false라면 false, 첫번째 값이 false라면 두 번째 값은 평가하지 않고 true.

	let enteredDoorCode = true
	let passedRetinaScan = false
	if enteredDoorCode && passedRetinaScan {
	    println("Welcome!")
	} else {
	    println("ACCESS DENIED")
	}
	// prints "ACCESS DENIED"

### 논리 OR 연산자(Logical OR Operator)

논리 OR 연산자(a || b)는 중위 연산자로 두 개의 인접한 파이프 문자로 만들어짐. 두 값 중 하나만 true가 되면 전체 표현식에서 true.

첫번째 값이 true라면 두 번째 값은 평가하지 않고 true.

	let hasDoorKey = false
	let knowsOverridePassword = true
	if hasDoorKey || knowsOverridePassword {
	    println("Welcome!")
	} else {
	    println("ACCESS DENIED")
	}
	// prints "Welcome!"

### 복합 논리 연산자(Combining Logical Operators)

여러 논리 연산자를 결합하여 긴 복합 표현식을 만듬.

	if enteredDoorCode && passedRetinaScan || hasDoorKey || knowsOverridePassword {
	    println("Welcome!")
	} else {
	    println("ACCESS DENIED")
	}
	// prints "Welcome!"

### 괄호 명시(Explicit Parentheses)

괄호를 사용하게 되면 복잡한 표현식의 가독성이 증가.

	if (enteredDoorCode && passedRetinaScan) || hasDoorKey || knowsOverridePassword {
	    println("Welcome!")
	} else {
	    println("ACCESS DENIED")
	}
	// prints "Welcome!"
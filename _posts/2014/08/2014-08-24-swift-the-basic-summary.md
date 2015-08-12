---
layout: post
title: "[Swift]The Basic 정리"
description: ""
category: "mac/ios"
tags: [swift, optional, let, var, constants, optional binding, safe]
---
{% include JB/setup %}

### Swift 타입

* 정수형 - Int
* 부동소숫점 - Double, Float
* 논리자료형 - Boolean
* 문자열 - String
* 컬렉션 - Array, Dictionary
* 값의 묶음 타입 - Tuple
* 선택형 타입


### 상수와 변수(Constants and Variables)

상수 값은 한번 설정된 후로는 변경할 수 없으나, 변수는 이후에도 변경될 수 있음.

상수의 keyword - let<br/>
변수의 keyword - var

	let maximumNumberOfLoginAttempts = 10
	var currentLoginAttempt = 0


### 타입 명시(Type Annotations)

Swift는 기본적으로 타입을 명시하지 않지만 명확하게 하기 위해 타입 명시를 할 수 있음.
상수 또는 변수 뒤에 콜론을 쓰고 한칸 띄우고 타입을 씀.

	var welcomMessage: String
	welcomMessage = "Hello"


### 상수와 변수 출력(Printing Constants and Variables)

println 함수를 사용하여 값을 출력.

	println(friendlyWelcome)
	// prints "Bonjour!"

	println("This is a string")
	// prints "This is a string"

	println("The current value of friendlyWelcome is \(friendlyWelcome)")
	// prints "The current value of friendlyWelcome is Bonjour!"


### 정수(Integers)

최대값과 최소값은 각 정수 타입의 min과 max 속성에 접근하여 얻음.

	let minValue = UInt8.min  // minValue is equal to 0, and is of type UInt8
	let maxValue = UInt8.max  // maxValue is equal to 255, and is of type UInt8


### Int

* 32-bit 플랫폼 - Int는 Int32와 같은 크기
* 64-bit 플랫폼 - Int는 Int64와 같은 크기


### UInt

* 32-bit 플랫폼 - UInt는 UInt32와 같은 크기
* 64-bit 플랫폼 - UInt는 UInt64와 같은 크기


### 부동 소수점

* Double은 64-bit 부동 소수점
* Float은 32-bit 부동 소수점


### 타입 세이프와 타입 추정(Type safety and Type Inference)

Swift는 형 안전 언어(타입 세이프 언어).<br/>
값들의 타입을 명확하게 하도록 함. String타입으로 예상되는 부분이라면 Int 값을 전달하는건 불가능.

컴파일 시 일치하지 않으면 에러로 표수하며 개발시 가능한 일찍 오류를 고칠 수 있도록 함.

타입 추정은 상수나 변수의 초기 값을 같이 선언할 때 유용함. 이는 초기 값을 설정해놓으면 해당 값의 타입으로 가진다고 추정함.

	let meaningOfLife = 42
	// meaningOfLife is inferred to be of type Int

	let pi = 3.14159
	// pi is inferred to be of type Double

	let anotherPi = 3 + 0.14159
	// anotherPi is also inferred to be of type Double

Swift는 타입 추정시 Float보다 Double을 선택함.


### 숫자의 문자 표현(Numeric Literals)

정수 문자 표현

* 10진수 - 접두사 x
* 2진수 - 접두사 0b
* 8진수 - 접두사 0o
* 16진수 - 접두사 0x

<br/>

	let decimalInteger = 17
	let binaryInteger = 0b10001       // 17 in binary notation
	let octalInteger = 0o21           // 17 in octal notation
	let hexadecimalInteger = 0x11     // 17 in hexadecimal notation

exp를 통한 10진수

	1.25e2 means 1.25 × 102, or 125.0.
	1.25e-2 means 1.25 × 10-2, or 0.0125.

exp를 통한 16진수
	
	0xFp2 means 15 × 22, or 60.0.
	0xFp-2 means 15 × 2-2, or 3.75.

부동 소수점 문자 표현

	let decimalDouble = 12.1875
	let exponentDouble = 1.21875e1
	let hexadecimalDouble = 0xC.3p0

밑줄(_)를 넣어 읽기 쉽게 문자 표현

	let paddedDouble = 000123.456
	let oneMillion = 1_000_000
	let justOverOneMillion = 1_000_000.000_000_1


### 형 별칭(Type Aliases)

형의 이름을 대체하여 다른 이름으로 정의. `typealias`

	typealias AudioSample = UInt16

	var maxAmplitudeFound = AudioSample.min
	// maxAmplitudeFound is now 0


### 논리 값(Booleans)

Boolean은 true, false 두가지 상수 값

	let orangesAreOrange = true
	let turnipsAreDelicious = false


### 튜플(Tuples)

여러 값들을 하나의 통합적인 값으로 묶음. 튜플에 있는 값들은 어떤 타입이라도 가능.

	let http404Error = (404, "Not Found")
	// http404Error is of type (Int, String), and equals (404, "Not Found")

(404, "Not Found")는 Int 값, String 값을 서로 묶은 것.

튜플의 각 값은 상수나 변수로 분해하여 사용이 가능.

	let (statusCode, statusMessage) = http404Error

	println("The status code is \(statusCode)")
	// prints "The status code is 404"

	println("The status message is \(statusMessage)")
	// prints "The status message is Not Found"


튜플 값 중에 몇 개만 필요하다면 무시할 부분에 밑줄(_)을 사용하면 됨.

	let (justTheStatusCode, _) = http404Error

	println("The status code is \(justTheStatusCode)")
	// prints "The status code is 404"


0번 부터 시작하는 index 번호를 통해 각각의 튜플 요소를 접근 가능.

	println("The status code is \(http404Error.0)")
	// prints "The status code is 404"

	println("The status message is \(http404Error.1)")
	// prints "The status message is Not Found"

튜플에 각 요소들에 명명할 수 있음.

	let http200Status = (statusCode: 200, description: "OK")

	println("The status code is \(http200Status.statusCode)")
	// prints "The status code is 200"

	println("The status message is \(http200Status.description)")
	// prints "The status message is OK"


* 튜플은 연관성 있는 값들을 묶는데 유용, 하지만 복잡한 자료구조에는 맞지 않음.


### 옵셔널(Optionals)

옵셔널은 값이 없을 수도 있는 상황에 사용됨.

* 값이 있거나 값이 아예 없는 상황

값이 있다면 상관없지만 값이 없다면 nil을 가짐.

	let str = "Hello, playground"
	let convertedStr = str.toInt()
	println("\(convertedStr)")
	// toInt는 Int? 타입의 영향을 주기 때문에 convertedStr는 옵셔널 타입을 가지게 됨, 
	// prints "nil"

	let possibleNumber = "123"
	let convertedNumber = possibleNumber.toInt()
	prints "123"


또한, 옵셔널 타입인 경우 nil값을 할당하여 사용할 수 있음.

	var serverResponseCode: Int? = 404
	// serverResponseCode contains an actual Int value of 404

	serverResponseCode = nil
	// serverResponseCode now contains no value


변수 선언시 옵셔널 타입이지만 값을 할당하지 않은 경우 nil값을 자동으로 설정.

	var surveyAnswer: String?
	// surveyAnswer is automatically set to nil


### If 조건문과 언래핑(If Statements and Forced Unwrapping)

if 조건문에서 옵셔널이 값을 가지고 있는지 판단하기 위해 nil과 비교할 수 있음.

옵셔널이 값을 가지고 있다면 nil과 같지 않음.

	if convertedNumber != nil {
	    println("convertedNumber contains some integer value.")
	}
	// prints "convertedNumber contains some integer value."


옵셔널이 반드시 값을 가지고 있다고 확신하면 느낌표(!)를 옵셔널 이름 끝에 추가함. 즉, 느낌표(!)는 옵셔널에 값이 반드시 있고, 없으면 Error가 발생함.

	var cabBeNil: Int?
	println(cabBeNil)
	// Compile is OK

	println(cabBeNil!)
	// Error, canBeNil is no value


### 옵셔널 바인딩(Optional Binding)

옵셔널 바인딩은 값이 가지고 있는지를 찾고 임시 상수나 변수에 담아 사용할 수 있도록 함. 

if와 while문에서 옵셔널 값이 있는지를 확인. 

상수나 변수로부터 값을 가져와 if와 while문에 한번 사용하기 위함.

옵셔널 바인딩은 다음과 같은 형태

	if let constantName = someOptional {
		statements
	}

다음은 옵셔널 바인딩 예제.

	if let actualNumber = possibleNumber.toInt() {
	    println("\(possibleNumber) has an integer value of \(actualNumber)")
	} else {
	    println("\(possibleNumber) could not be converted to an integer")
	}


### 절대적인 언래핑된 옵셔널(Implicitly Unwrapped Optionals)

옵셔널은 상수나 변수가 값을 가지고 있지 않음을 허용하는 것이고 if문을 통해 값이 있는지 옵셔널 바인딩을 통해 접근.

옵셔널에서 항상 값을 가지고 있도록 하는 것을 절대적인 언래핑된 옵셔널(Implicitly Unwrapped Optionals)라고 함.

이 옵셔널은 접근할 때 마다 항상 값이 있는지 확인할 필요가 없음.

기존 옵셔널에 물음표(?) 대신하여 느낌표(!)를 사용.

또한, 변수 또는 상수 뒤에 느낌표(!)를 사용하여 절대적인 언래핑된 옵셔널을 사용한다는 것을 나타냄.

우선 다음 값들을 초기 설정함.

	let possibleString: String? = "An optional string."
	let forcedString: String = possibleString! // requires an exclamation mark
	 
	let assumedString: String! = "An implicitly unwrapped optional string."
	let implicitString: String = assumedString // no need for an exclamation mark


다음은 절대적인 언래핑된 옵셔널과 일반적인 옵셔널 조건문

	if possibleString != nil {} // It`s OK.
	if possibleString {} // Error, possibleString is normal Optional

	if assumedString {}	// It`s OK, assumedString is Implicitly Unwrapped Optional

또한, 일반적인 옵셔널에서 초기 값을 설정하지 않은 상태에서 출력하고자 할때 절대적인 언래핑된 옵셔널을 이용하여 Error를 확인 가능.

	let printStr: String?
	println(printStr!)	// Error

	var printStr1: String?
	printStr1 = "1111"
	println(printStr1!)	// It`s OK.


### Assertions

디버깅 환경에서 Assertion이 발생한다면 어디에서 올바르지 않은 상태를 확인할 수 있으며, 앱 상태를 확인 할 수 있음.

assert함수를 통해 true와 false를 확인하여 false일 때 출력할 메시지를 보여줄 수 있음.

	let age = -3
	assert(age >= 0, "A person's age cannot be less than zero")
	// this causes the assertion to trigger, because age is not >= 0

	assert(age >= 0)

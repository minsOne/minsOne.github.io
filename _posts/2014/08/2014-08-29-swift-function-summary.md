---
layout: post
title: "Swift - Function 정리"
description: ""
category: "mac/ios"
tags: [swift, function, nested function, inout, func, return, tuple, optional, type, external parameter name, parameter, defalut, hash simbol, variadic parameter, function type]
---
{% include JB/setup %}

## 함수(Functions)

함수는 특정 작업을 수행하기 위한 독립적인 코드 집합임. 함수에 식별할 수 있도록 명명하며, 작업이 필요할 때 함수의 이름을 호출하여 사용함. 

Swift의 함수 문법은 인자가 없는 C 언어 스타일의 함수부터 지역, 전역 인자 이름을 가지는 복잡한 Objective-C 스타일 메소드까지 모두 표현할 수 있음. 인자는 기본 값을 가지며 간단한 함수를 호출하는데 인자를 넘기거나 받을 수 있음. 이 인자들은 함수에 실행이 끝난 다음 변경되어 넘겨짐.

Swift의 모든 함수는 타입을 가지며 함수의 인자 타입과 반환 타입을 고려해야 함. Swift에 다른 타입과 마찬가지로 함수에서 다른 함수로 인자를 넘기고 함수에서 함수로 인자를 반환받는 것이 쉬움. 함수는 캡슐화를 위해 중첩된 함수 범위 내에서 작성할 수 있음.

### 함수 정의와 호출(Defining and Calling Functions)

함수를 정의할 때, 함수에 입력되는 인자 값에 이름을 정할 수 있으며, 출력 시 값의 타입 정함.

모든 함수는 함수 이름을 가지며, 이는 어떤 작업을 하는지에 대한 설명임. 함수를 사용하기 위해 이름과 함수 인자의 타입과 일치하는 값을 넘기도록 호출함. 함수의 입력값은 함수의 인자 목록에 순서와 항상 일치함.

다음은 sayHello라고 호출되는 함수의 예제임. 사람의 이름을 입력받고 인사말을 반환하는 함수. 이를 달성하기 위해 한 개의 입력 인자(personName 변수의 문자열 값)과 문자열 반환 타입를 정의함.

	func sayHello(personName: String) -> String {
	    let greeting = "Hello, " + personName + "!"
	    return greeting
	}

`func`키워드를 앞에 사용하며, 함수의 반환 타입과 반환 방향 ->를 나타내고 그 뒤에 반환 타입의 이름을 사용함.

함수 정의는 함수가 어떤 작업을 하는지, 인자의 값을 예상하고, 완료되면 무엇을 반환하는지 설명함.
함수 정의는 함수가 코드 안에서 호출되면 명확하고 명백한 방법으로 사용하게 함.

	println(sayHello("Anna"))
	// prints "Hello, Anna!"
	println(sayHello("Brian"))
	// prints "Hello, Brian!"

sayHello 함수를 String 인자 값을 넘기면서 호출함. sayHello("Anna")와 같이 호출. 이는 함수가 문자열 값을 반환하며 sayHello는 println 함수 호출 안에 감싸져있으며 반환된 값은 출력됨.

sayHello 함수는 시작하면 새로운 문자열 상수를 greeting로 정의하며 personName에 간단한 인사 메시지를 설정함. 이 인사말은 `return` 키워드를 사용하여 함수 밖으로 넘겨지게 됨.  `return greeting`이 곧 호출되면 함수는 실행 종료하고 현재 greeting 값이 반환됨.

sayHello 함수는 여러번 다양한 입력 값으로 호출됨.

	func sayHelloAgain(personName: String) -> String {
	    return "Hello again, " + personName + "!"
	}
	println(sayHelloAgain("Anna"))
	// prints "Hello again, Anna!"

### 함수 인자와 반환 값(Function Parameters and Return Values)

Swift에서 함수 인자와 반환 값은 극도로 유연함. 이름없는 한개 인자를 사용하는 단순한 기능성 함수에서 명시적 인자와 다른 인자 옵션을 가지는 복잡한 함수까지 정의할 수 있음.

#### 복수 입력 인자(Multiple Input Parameters)

함수는 복수 입력 인자를 가질 수 있으며, 함수의 괄호 안에서 콤마로 분리하여 사용됨.

다음은 처음과 마지막 index의 범위를 구하는 함수 예제.

	func halfOpenRangeLength(start: Int, end: Int) -> Int {
	    return end - start
	}
	println(halfOpenRangeLength(1, 10))
	// prints "9"

#### 인자 없는 함수(Functions Without Parameters)

함수는 입력 인자를 정의할 필요는 없음. 다음은 항상 같은 문자열 메시지를 반환하는 인자 없는 함수 예제.	

	func sayHelloWorld() -> String {
	    return "hello, world"
	}
	println(sayHelloWorld())
	// prints "hello, world"

입력 인자가 없더라도 괄호()를 꼭 써야함.

#### 값을 반환하지 않는 함수(Functions Without Return Values)

함수는 반환 타입을 정의할 필요는 없음. 다음은 반환 값 없는 함수 예제.

	func sayGoodbye(personName: String) {
	    println("Goodbye, \(personName)!")
	}
	sayGoodbye("Dave")
	// prints "Goodbye, Dave!"

반환 값이 없기 때문에 `->`를 사용할 필요가 없고 타입도 쓸 필요도 없음.

<div class="alert-info">
엄밀히 말하면, 값을 반환하지 않는 함수는 값을 반환함. 이는 <code>Void</code>타입의 특수 값을 반환하는데 이 값은 빈 튜플이며 원소가 없으며 <code>()</code>로 작성됨.
</div>

#### 다중 값을 반환하는 함수(Functions with Multiple Return Values)

함수에 반환 타입을 튜플 값을 사용할 수 있으며 하나의 집합으로 된 다중 값을 반환함.

minMax라고 호출되는 함수는 최소 값과 최대 값을 Int 값을 가지는 배열에서 찾는 예제.

	func minMax(array: [Int]) -> (min: Int, max: Int) {
	    var currentMin = array[0]
	    var currentMax = array[0]
	    for value in array[1..<array.count] {
	        if value < currentMin {
	            currentMin = value
	        } else if value > currentMax {
	            currentMax = value
	        }
	    }
	    return (currentMin, currentMax)
	}

minMax 함수는 두 Int 값을 가지는 튜플을 반환. 이들 값은 min과 max로 명명되고 해당 이름으로 접근하여 사용함.

	let bounds = minMax([8, -6, 2, 109, 3, 71])
	println("min is \(bounds.min) and max is \(bounds.max)")
	// prints "min is -6 and max is 109"

#### 옵셔널 튜플 반환 타입(Optional Tuple Return Types)

함수에서 반환되는 튜플 타입은 값이 없는 가능성이 있음. 옵셔널 튜플 반환 타입은 튜플이 nil일 수도 있다는 사실을 반영함. 옵셔널 튜플 반환 타입은 닫는 괄호 다음에 물음표(?)를 사용하여 사용함. (Int, Int)? 나 (String, Int, Bool)?.

<div class="alert-info">
옵셔널 튜플 타입<code>(Int, Int)?</code>는 옵셔널 타입을 가지는 튜플<code>(Int?, Int?)</code>와는 다름.
</div>

다음은 minMax 함수에 옵셔널 튜플 반환 타입과 빈 배열일 때 nil 값을 반환하는 예제.

	func minMax(array: [Int]) -> (min: Int, max: Int)? {
	    if array.isEmpty { return nil }
	    var currentMin = array[0]
	    var currentMax = array[0]
	    for value in array[1..<array.count] {
	        if value < currentMin {
	            currentMin = value
	        } else if value > currentMax {
	            currentMax = value
	        }
	    }
	    return (currentMin, currentMax)
	}

	if let bounds = minMax([8, -6, 2, 109, 3, 71]) {
	    println("min is \(bounds.min) and max is \(bounds.max)")
	}
	// prints "min is -6 and max is 109"

### 함수 인자 이름(Function Parameter Names)

함수의 인자에 이름을 지음.

	func someFunction(parameterName: Int) {
	    // function body goes here, and can use parameterName
	    // to refer to the argument value for that parameter
	}

이들 인자 이름은 함수 안에서만 사용 가능하며 함수 호출할 때에는 사용할 수 없음. 이러한 종류의 인자 이름은 지역 인자 이름으로 불리는데 함수 내에서만 오직 사용 가능하기 때문임.

#### 외부 인자 이름(External Parameter Names)

때론 함수를 호출할 때 각각의 인자에 이름을 붙이는게 유용할 때가 있는데 함수로 던져진 각 인자의 목적을 가르키기 위함.

함수 사용자에게 함수를 호출 할 때 인자에 이름을 지어주길 원하면 각 인자에게 외부 인자 이름을 지역 인자 이름에 붙이도록 정의함. 

지역 인자 이름 앞에 한칸 띄우고 외부 인자 이름을 작성함.

	func someFunction(externalParameterName localParameterName: Int) {
	    // function body goes here, and can use localParameterName
	    // to refer to the argument value for that parameter
	}

다음은 문자열을 합치는 함수 예제.

	func join(s1: String, s2: String, joiner: String) -> String {
	    return s1 + joiner + s2
	}

위 함수를 호출 할 때 세 개의 문자열 인자의 목적이 뚜렷하지 않음.

	join("hello", "world", ", ")
	// returns "hello, world"

따라서 이들 문자열 값의 목적을 뚜렷하게 하기 위해 외부 인자 이름을 각 함수 인자에 정의함.

	func join(string s1: String, toString s2: String, withJoiner joiner: String)
	    -> String {
	        return s1 + joiner + s2
	}

외부 인자 이름을 정의함에 따라 각 인자들의 목적이 뚜렷하게 나타남.

	join(string: "hello", toString: "world", withJoiner: ", ")
	// returns "hello, world"

<div class="alert-info">
만약 각 인자들의 이름에 목적이 뚜렷하게 나타난다면, 외부 인자 이름을 사용할 필요가 없음.
</div>

#### 축약 외부 인자 이름(Shorthand External Parameter Names)

외부 인자 이름을 함수 인자에 쓰길 원하는데 지역 인자 이름은 이미 적절한 이름을 사용하고 있다면 같은 이름을 두번이나 사용할 필요가 없음. 대신 해쉬 기호(`#`)를 이름 앞에 한번 붙임. 그러면 Swift에 지역 인자 이름과 외부 인자 이름 둘다 사용한다고 통보함.

다음은 지역 인자 이름과 외부 인자 이름 둘다 사용하는 함수 예제.

	func containsCharacter(#string: String, #characterToFind: Character) -> Bool {
	    for character in string {
	        if character == characterToFind {
	            return true
	        }
	    }
	    return false
	}

이 함수의 인자 이름 선택은 명확하고, 가독성있고, 함수 호출 시 모호함이 없게 만듬.

	let containsAVee = containsCharacter(string: "aardvark", characterToFind: "v")
	// containsAVee equals true, because "aardvark" contains a "v"

#### 인자 기본 값(Default Parameter Values)

함수의 정의에 부분으로 인자에 기본값을 정의할 수 있음. 기본 값은 정의되면 함수 호출될 때 인자를 생략할 수 있음.

<div class="alert-info">
기본 값을 가지는 인자는 함수 인자 목록의 마지막에 위치함. 이는 기본 값을 가지지 않는 인자가 같은 순서를 사용함을 보장하며 매 경우 같은 함수가 호출되도록 명확하게 함.
</div>

joiner 인자가 기본 값을 가지도록 하는 join 함수의 예제.

	func join(string s1: String, toString s2: String,
	    withJoiner joiner: String = " ") -> String {
	        return s1 + joiner + s2
	}

joiner에 값이 있는 경우에 다음과 같이 함수를 호출함.

	join(string: "hello", toString: "world", withJoiner: "-")
	// returns "hello-world"

만약 joiner에 값이 없는 경우 기본 값이 대신 사용하도록 다음과 같이 함수를 호출함.

	join(string: "hello", toString: "world")
	// returns "hello world"

#### 기본값을 가지는 외부 인자 이름(External Names for Parameters with Default Values)

대부분의 경우에 인자에 기본값과 외부 이름을 사용하는 것은 유용함. 함수가 호출될 때 인자에 값이 전달되어 그 목적이 명확해짐.

이 과정을 쉽게 하기 위해 Swift는 외부 이름이 부여되지 않은 인자에 대해 자동으로 외부 이름을 기본값으로 하도록 함.

자동 외부 이름은 지역 이름과 같으며 지역 이름 앞에 해쉬 기호(`#`)를 씀.

join함수에 다른 인자에는 외부 이름을 사용하지 않지만 joiner 인자에는 기본 값을 사용함.

	func join(s1: String, s2: String, joiner: String = " ") -> String {
	    return s1 + joiner + s2
	}

이 경우에 Swift는 자동적으로 외부 인자 이름을 joiner에 부여 함. 외부 이름은 함수 호출될 때 부여되므로 인자의 목적이 명확하고 분명하도록 만듬.

	join("hello", "world", joiner: "-")
	// returns "hello-world"

<div class="alert-info">
선택사항으로 인자를 정의할 때 명시적인 외부 이름 대신 밑줄(_)을 사용하여 행동을 무시하도록 선택할 수 있으나 외부 이름을 기본값을 가진 인자에 사용하는 것이 적절함.</div>

#### 가변 인자(Variadic Parameters)

가변 인자는 특정 타입의 0 이상의 값을 받아 들임. 가변 갯수 파라메터를 사용함으로써 함수 호출시 입력 값들이 임의의 갯수가 될수 있다고 정할 수 있음. 
 
가변 인자 타입 이름 뒤에 마침표 세개(`...`)를 추가하여 가변 인자를 작성함.

가변 인자에 넘긴 값은 적절한 타입의 배열로 만들어짐. Double... 타입인 numbers이름 가변 인자는 함수 내에서 [Double]타입의 numbers로 불리는 상수 배열로 만들어짐.

다음은 평균이라고 불리는 산술 계산 예제 코드.

	func arithmeticMean(numbers: Double...) -> Double {
	    var total: Double = 0
	    for number in numbers {
	        total += number
	    }
	    return total / Double(numbers.count)
	}
	arithmeticMean(1, 2, 3, 4, 5)
	// returns 3.0, which is the arithmetic mean of these five numbers
	arithmeticMean(3, 8.25, 18.75)
	// returns 10.0, which is the arithmetic mean of these three numbers

<div class="alert-info">
함수는 대부분 한 개의 가변 인자를 가지며 이는 인자 목록에 마지막에 항상 위치를 하고, 함수 호출 시 여러 인자들과의 모호성을 피하기 위함.

하나 이상의 기본 값을 가지는 인자와 가변 인자를 가지고 있다면, 기본 값을 가지는 인자 뒤에 가변 인자 순으로 위치해야 함.
</div>

#### 상수 인자와 변수 인자(Constant and Variable Parameters)

함수 인자는 기본적으로 상수. 함수 내에에서 함수 인자 값을 변경하려고 한다면 컴파일 타임 에러가 발생. 이 의미는 실수로 인자의 값을 변경할 수 없음.

때로는 작업 중에 인자의 값을 변수에 복사하여 사용하기에 유용함. 하나 이상의 변수 인자를 함수에 사용하여 새로운 변수를 정의하는 것을 피할 수 있음.  변수 인자는 상수보다는 변수로 하는 것이 더 나으며, 함수는 인자의 변경 가능한 사본을 주어 작업하도록 할 수 있음.

인자 앞에 `var` 키워드를 붙여 변수 인자를 정의함.

	func alignRight(var string: String, count: Int, pad: Character) -> String {
	    let amountToPad = count - countElements(string)
	    if amountToPad < 1 {
	        return string
	    }
	    let padString = String(pad)
	    for _ in 1...amountToPad {
	        string = padString + string
	    }
	    return string
	}
	let originalString = "hello"
	let paddedString = alignRight(originalString, 10, "-")
	// paddedString is equal to "-----hello"
	// originalString is still equal to "hello"

이 예제에서 alignRight 함수에 string은 변수 인자로 정의되며 함수 내부에서 변경됨.

<div class="alert-info">
변수 인자에 변화는 함수 가 호출된 후에는 남지 않으며 함수 밖에서는 보이지 않음. 변수 인자의 생명주기는 함수가 호출되는 동안에만 존재를 함.
</div>

#### 입출력 인자(In-Out Parameters)

앞에서 설명한 가변 인자는 함수 내에서만 변경 가능함. 만약 인자 값이 변경된 후에도 값이 유지되길 원한다면 인자를 입출력 인자로 정의해야 함.

입출력 인자는 `inout` 키워드가 인자 앞에 위치하도록 정의함. 입출력 인자는 함수로 넘겨진 값을 가지며, 함수에 의해 수정되고 원래 값을 대체하여 밖으로 넘겨짐.

입출력 인자에 변수만 넘길 수 있으며, 상수나 값 리터럴 값은 넘길 수 없는데 이는 값을 변경할 수 없기 때문임. 입출력 인자를 넘길 때 앤드 기호(&)를 변수 앞에 붙여서 함수에 의해 수정될 수 있음을 나타냄.

입출력 인자는 기본 값을 가질 수 없으며, 가변 인자도 inout으로 표시할 수 없고 var 이나 let도 표시할 수 없음.

다음은 입출력 인자를 가지는 함수 예제.

	func swapTwoInts(inout a: Int, inout b: Int) {
	    let temporaryA = a
	    a = b
	    b = temporaryA
	}

swapTwoInts 함수는 a와 b의 값을 바꿈. 바꾸는 작업은 a 값을 임시 상수 temporaryA에 저장하고, b 값을 a에 할당, temporaryA 값을 b에 할당함.

swapTwoInts함수는 앤드 기호(&)를 붙여 다음과 같이 호출함.

	var someInt = 3
	var anotherInt = 107
	swapTwoInts(&someInt, &anotherInt)
	println("someInt is now \(someInt), and anotherInt is now \(anotherInt)")
	// prints "someInt is now 107, and anotherInt is now 3"

위 예제는 someInt와 anotherInt의 원래 값이 swapTwoInts에 의해 변경되었음을 보여줌.

<div class="alert-info">
입출력 인자는 함수에서 값을 반환하는 것이 아니고 someInt 값과 anotherInt 값을 변경하여 범위 밖에서도 영향을 끼치는 방법임.
</div>

### 함수 타입(Function Types)

모든 함수는 특정 함수 타입을 가지며, 함수 타입은 인자 타입과 반환 타입으로 만들어짐.

	func addTwoInts(a: Int, b: Int) -> Int {
	    return a + b
	}
	func multiplyTwoInts(a: Int, b: Int) -> Int {
	    return a * b
	}

위 예제는 두 개의 산수하는 함수이며 addTwoInts와 multiplyTwoInts 함수로 호출됨. 이들 함수는 각각 두 개의 Int 값을 취하고 Int 값을 적절히 연산하여 결과로 반환함.

이들 함수의 타입은 `(Int, Int) -> Int`이며 다음과 같이 읽음 : 

함수 타입은 두 개의 Int 타입 인자를 가지며 Int 타입의 값을 반환함.

다음은 인자도 반환 값도 없는 함수의 예제.

	func printHelloWorld() {
	    println("hello, world")
	}

이 함수의 타입은 `() -> ()` 또는 함수에 인자는 없고 `Void`를 반환함. 함수는 특별하지 않으면 `Void`를 항상 반환하며, 이는 Swift에서 빈 튜플 `()`과 같은 의미임.

#### 함수 타입 사용(Using Function Types)

함수 타입은 Swift에 다른 타입들 처럼 사용함. 예를 들어 함수 타입을 변수나 상수에 할당할 수 있음.

	var mathFunction: (Int, Int) -> Int = addTwoInts

위는 두 개의 Int 값을 취하고 Int 값을 반환하는 함수 타입을 가진 mathFunction 변수를 정의. addTwoInts 함수가 참조하는 새로운 변수로 설정.

addTwoInts 함수는 mathFunction 변수와 같은 타입이며, Swift에 타입 확인로 할당이 허용됨.

다음은 mathFunction 이름으로 할당된 함수를 호출하는 예제.

	println("Result: \(mathFunction(2, 3))")
	// prints "Result: 5"

타입은 같지만 다른 동작을 하는 함수는 타입이 같은 변수에 할당할 수 있으며, 다음은 해당 예제.

	mathFunction = multiplyTwoInts
	println("Result: \(mathFunction(2, 3))")
	// prints "Result: 6"

Swift에선 상수나 변수에 함수를 할당할 때 함수 타입을 추론하도록 내버려둠.

	let anotherMathFunction = addTwoInts
	// anotherMathFunction is inferred to be of type (Int, Int) -> Int

#### 인자 타입으로서 함수 타입(Function Types as Parameter Types)

`(Int, Int) -> Int` 같은 함수 타입은 다른 함수에 인자 타입으로 사용할 수 있음. 

다음은 함수 타입을 인자 타입으로 가지는 함수 예제.

	func printMathResult(mathFunction: (Int, Int) -> Int, a: Int, b: Int) {
	    println("Result: \(mathFunction(a, b))")
	}
	printMathResult(addTwoInts, 3, 5)
	// prints "Result: 8"

printMathResult 함수는 세 개의 인자로 정의되며, 첫번째 인자는 mathFunction로 불리며 `(Int, Int) -> Int` 타입임. 

printMathResult가 호출되면 addTwoInts 함수, 정수 3과 5가 넘어오고 addTwoInts 함수에 정수 3과 5를 넘겨 8의 값을 얻음. 넘어온 함수가 어떤 행동을 하는지는 중요한 것이 아니고 어떤 타입이냐가 중요함.(type-safe)

#### 반환 타입으로서 함수 타입(Function Type as Return Types)

다른 함수에서 반환 타입을 함수 타입으로 사용할 수 있음. 반환하는 함수의 반환 화살표(`->`) 뒤에 완전한 함수 타입을 붙여 작성함.

다음 예제는 값을 증가 또는 감소시키는 함수 예제.

	func stepForward(input: Int) -> Int {
	    return input + 1
	}
	func stepBackward(input: Int) -> Int {
	    return input - 1
	}

이 함수의 반환 타입은 (Int) -> Int를 반환하는 함수. chooseStepFunction은 backwards 논리값 인자에 따라 stepForward함수와 stepBackward함수중 하나를 반환.

	func chooseStepFunction(backwards: Bool) -> (Int) -> Int {
	    return backwards ? stepBackward : stepForward
	}

	var currentValue = 3
	let moveNearerToZero = chooseStepFunction(currentValue > 0)
	// moveNearerToZero now refers to the stepBackward() function

이제 moveNearerToZero 상수는 stepBackward 함수를 참조하도록 할당됨.

다음은 moveNearerToZero 상수에 stepBackward 함수를 참조하는지 확인하는 예제.

	println("Counting to zero:")
	// Counting to zero:
	while currentValue != 0 {
	    println("\(currentValue)... ")
	    currentValue = moveNearerToZero(currentValue)
	}
	println("zero!")
	// 3...
	// 2...
	// 1...
	// zero!

### 중첩 함수(Nested Functions)

함수 내부에서 또다른 함수를 정의할 수 있으며 이를 중첩 함수라고 함.

중첩 함수는 기본적으로 밖에서는 숨겨져 있으며 중첩 함수 중 하나를 반환하여 다른 범위에서 함수가 사용할 수 있게 함.

다음은 chooseStepFunction에 중첩 함수로 작성된 예제.

	func chooseStepFunction(backwards: Bool) -> (Int) -> Int {
	    func stepForward(input: Int) -> Int { return input + 1 }
	    func stepBackward(input: Int) -> Int { return input - 1 }
	    return backwards ? stepBackward : stepForward
	}
	var currentValue = -4
	let moveNearerToZero = chooseStepFunction(currentValue > 0)
	// moveNearerToZero now refers to the nested stepForward() function
	while currentValue != 0 {
	    println("\(currentValue)... ")
	    currentValue = moveNearerToZero(currentValue)
	}
	println("zero!")
	// -4...
	// -3...
	// -2...
	// -1...
	// zero!
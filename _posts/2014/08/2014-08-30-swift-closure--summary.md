---
layout: post
title: "Swift - Closure 정리"
description: ""
category: "mac/ios"
tags: [swift, closure, trailing, operator, nested function, infer, context, reference type, reference, strong reference cycle, shorthand argument name, closure expression, map]
---
{% include JB/setup %}

## 클로저(Closure)

클로저는 사용자의 코드 안에서 전달되어 사용할 수 있는 기능이며 이 기능을 포함하는 독립적인 블럭임. Swift에 클로저는 C와 Objective-C 언어의 블럭과 유사하며 다른 언어의 람다와도 유사함.

클로저는 저신이 정의된 컨텍스트로부터 임의의 상수와 변수에 참조(reference)를 획득하고 저장할 수 있음. 이는 상수와 변수를 제약하는 특징으로 "클로저"라는 이름이 유래됨. Swift는 획득한 모든 메모리 관리를 다룸.

"획득" 개념은 친근하지 않지만 값 획득 항목에서 상세히 설명함.

앞에서 소개한 전역 및 중첩 함수는 실제론 클로저의 특수한 경우임. 클로저는 세가지 중 하나의 형태를 취함.

* 전역 함수는 이름은 있지만 아무런 값을 가지지 않는 클로저.
* 중첩 함수는 이름이 있고, 내부 함수에서 값을 획득할 수 있는 클로저.
* 클로저 표현식은 둘러싸고 있는 컨텍스트에서 값을 획득하는 가벼운 문법으로 작성된 이름 없는 클로저.

Swift 클로저 표현식은 일반적인 경우에 깨끗하고, 명확한 스타일로 최적화되어 간략하고, 깔끔한 문법을 가짐. 이러한 최적하는 다음을 포함함.

* 컨텍스트로부터 인자와 반환 값 타입을 유추
* 단일 표현식 클로저로부터 명확한 반환
* 축약 인자 이름
* 후행 클로저 문법

### 클로저 표현식(Closure Expressions)

중첩 함수는 더 큰 함수의 일부로써 독립적인 코드 블럭을 정의하거나 명명하는 편리한 방법임. 그러나 때때로 완전한 선언과 이름 없는 더 짧은 버전의 함수 같은 구조가 더 유용할 때가 있음. 이것은 다른 함수들이 하나 이상의 인자로 받는 함수로 작업할 때 특히 그러함.

클로저 표현식은 인라인 클로저로 이는 간략하고 문법에 초점을 맞추어 작성하는 방법. 클로저 표현식은 명확성이나 의도를 잃지 않은 축약된 형태로 몇가지 문법 최적화를 제공함. 아래에 클로저 표현식 예제는 하나의 sorted 함수의 예제를 세련되게 최적화 하도록 소개함.

#### 정렬 함수(The Sorted Function)

Swift 표준 라이브러리는 sorted 함수를 제공하며 알려진 타입의 값의 배열을 정렬하여 출력하는 정렬 클로저임. 정렬 과정이 끝나면 정렬 함수는 기존 배열에서 같은 타입과 크기의 새로운 배열을 반환하며 정렬된 순서로 구성됨. 기존 배열은 정렬 함수에 의해 수정되지 않음.

다음은 역순으로 된 문자열 배열이며 이 배열을 정렬함.

	let names = ["Chris", "Alex", "Ewa", "Barry", "Daniella"]

정렬 함수는 두개의 인자를 취함.

* 알려진 타입의 값들로 된 배열.
* 클로저는 배열의 내용이 동일한 타입의 인자를 가지며, 첫번째 값이 두번째 값보다 앞에 나와야 할지 알려주는 Bool 값을 반환. 정렬 클로저는 true 값 반환이 필요하며 이는 첫번째 값이 두번째 값보다 앞에 있어야 하며 반대의 경우는 false임.

열이 예제는 문자열 값의 배열을 정렬하며, 정렬 클로저는 `(String, String) -> Bool` 타입의 함수가 되어야 함.

정렬 클로저를 제공하는 한가지 방법은 맞는 타입의 일반 함수를 작성하며, 이 함수를 정렬 함수의 두번째 인자로 넘겨줌.

	func backwards(s1: String, s2: String) -> Bool {
	    return s1 > s2
	}
	var reversed = sorted(names, backwards)
	// reversed is equal to ["Ewa", "Daniella", "Chris", "Barry", "Alex"]

첫번쨰 문자열(s1)은 두번쨰 문자열(s2)보다 크다면, backwards 함수는 true를 반환하며, 정렬된 함수에 s1는 s2 앞에 나타나도록 표시함. 문자열에 문자에서 "더 크다"라는 의미는 알파벳이 나중에 나타난다는 의미. 즉, 글자 "B"는 "A"보다 크며 문자열 "Tom"은 "Tim"보다 더 큼. 알파벳 역순 정렬에 "Barry"는 "Alex" 앞에 옴.

즉, s1이 s2보다 크면 그자리 그대로 있고, s1이 s2보다 작으면 정렬됨.

그러나 단일 표현 함수(a > b)로 작성되기에는 너무 장황함. 이 예제에서 클로저 표현식 문법을 사용하여 정렬 클로저 인라인을 작성하는 것이 더 바람직함.

#### 클로저 표현식 문법(Closure Expression Syntax)

클로저 표현식 문법의 일반 형식은 다음과 같음.

	{ (parameters) -> return type in
	    statements
	}

클로저 표현식 문법은 상수 인자, 변수 인자, `inout` 인자를 사용할 수 있음. 기본 값은 주어지지 않음. 가변인자는 명명하고 인자 목록에 마지막에 위치시키면 사용할 수 있음. 튜플은 인자 타입과 반환 타입으로 사용할 수 있음.

다음은 backwards 함수의 클로저 표현식 버전 예제임.

	reversed = sorted(names, { (s1: String, s2: String) -> Bool in
	    return s1 > s2
	})

인라인 클로저를 위한 인자와 반환 타입의 선언은 backwards 함수의 정의와 동일함. 두 경우 모두 `(s1: String, s2: String) -> Bool`으로 작성되었음. 그러나 인라인 클로저 표현식에 인자와 반환 타입은 중괄호 안에 쓰여야 하며, 밖에서는 알 수 없음.

클로저의 내용은 `in` 키워드로 시작하며 이 키워드는 클로저 인자와 반환 타입의 정의가 끝났고 클로저 내용이 시작함을 가르킴.

클로저 내용이 매우 짧기 때문에 한줄로 작성할 수 있음.

	reversed = sorted(names, { (s1: String, s2: String) -> Bool in return s1 > s2 } )

#### 컨텍스트로부터 타입 유추

정렬 클로저는 함수에 인자로 전달되기 때문에, Swift는 인자의 타입과 정렬 함수의 두번째 인자의 타입으로부터 반환되는 값의 타입에서 유추할 수 있음. 인자는 타입 `(String, String) -> Bool`의 함수를 예상하며 `(String, String)`과 Bool 타입은 클로저 표현식 정의 부분에서 작성할 필요가 없음. 모든 타입은 유추할 수 있고 반환 화살표(->)와 인자의 이름을 감싼 괄호도 제외할 수 있음.

	reversed = sorted(names, { s1, s2 in return s1 > s2 } )

인라인 클로저 표현식으로서 클로저 함수를 넘길 때, 인자 타입과 반환 타입을 유추하는 것이 언제나 가능함. 결과적으로 인라인 클로저는 함수 인자로 사용할 때 모든 형식을 쓸 필요가 없음.

그럼에도 불구하고 코드 가독성에 모호함을 피하기 위해 타입을 명시적으로 만들 수 있음. 정렬 함수의 경우에서 클로저의 목적은 정렬이 일어난다는 사실로부터 명확하며, 코드를 읽는 사람이 문자열 의 배열을 정렬하는 것을 돕기 때문에, 클로저가 문자열 값과 같이 작업한다고 가정하면 안전함.

#### 단일 표현식 클로저로부터 암시적 반환(Implicit Returns from Single-Expression Closures)

단일 표현식 클로저는 클로저 정의에서 `return` 키워드를 생략한 단일 표현식 결과를 암시적으로 반환할 수 있음.

	reversed = sorted(names, { s1, s2 in s1 > s2 } )

정렬 함수의 두번째 인자의 함수 타입은 클로저가 Bool 값을 반환함을 명확하게 함. 따라서 클로저 내용은 Bool 값을 반환하는 단일 표현식(s1 > s2)을 포함하므로, 뚜렷하며 `return` 키워드를 생략할 수 있음.

#### 축약 인자 이름(Shorthand Argument Names)

Swift는 자동적으로 인라인 클로저에 축약 인자 이름을 부여하는데 클로저 인자의 값은 `$0, $1, $2` 등의 이름으로 참조하여 사용할 수 있음.

축약 인자 이름을 클로저 표현식에 사용할 때, 클로저 정의로부터 클로저 인자 목록을 상략할 수 있으며 축약 인자 이름의 타입과 숫자는 함수 타입으로부터 영향을 받음. `in` 키워드는 클로저 표현식이 클로저 내용에 모두 만들어지므로 생략할 수 있음.

	reversed = sorted(names, { $0 > $1 } )

$0과 $1은 클로저의 첫번째와 두번째 문자열 인자를 참조함.

#### 연산자 함수(Operator Functions)

위의 클로저 표현식은 더 짧은 방식으로 작성할 수 있음. Swift의 문자열 타입은 문자열에 특화된 크기 비교 연산자(`>`)와 `Bool` 타입의 반환 값을 갖는 함수로 정의함. 이는 정렬 함수의 두번째 인자가 필요한 함수 타입과 정확하게 일치함. 그러므로 더 큰 연산자에 간단하게 넘길 수 있고 Swift는 문자열 전용 구현체를 사용하길 원하는 것을 추론할 수 있음. 

	reversed = sorted(names, >)

### 후행 클로저(Trailing Closures)

긴 클로저 표현식을 함수의 마지막 인자로 함수를 전달할 필요가 있다면 후행 클로저로 유용하게 대신 사용할 수 있음. 후행 클로저는 함수 표현식으로 함수 괄호 밖에서 작성되어 지원함.

	func someFunctionThatTakesAClosure(closure: () -> ()) {
	    // function body goes here
	}
	 
	// here's how you call this function without using a trailing closure:
	 
	someFunctionThatTakesAClosure({
	    // closure's body goes here
	})
	 
	// here's how you call this function with a trailing closure instead:
	 
	someFunctionThatTakesAClosure() {
	    // trailing closure's body goes here
	}

함수 표현식은 함수의 인자 하나뿐이며 후행 클로저로 표현식을 작성하면, 함수 호출 시 함수 이름 뒤에 괄호를 쓸 필요가 없음.

앞에서 클로저 표현식 문법의 문자열 정렬 클로저는 후행 클로저로 정렬 함수 괄호 밖에 작성됨.

	reversed = sorted(names) { $0 > $1 }

후행 클로저는 한줄에 쓸 수 없는 클로저를 작성할 때 아주 유용함. Swift의 배열 타입은 `map` 메소드를 가지며 이 메소드는 단일 인자로 클로저 표현식을 가짐. 이 클로저는 배열에 각 항목마다 호출되며, 그 아이템에 새로이 매핑된 값을 반환함. 매핑의 특성과 반환값의 타입은 클로저에 의하여 지정되어 남음.

각 배열 항목마다 제공된 클로저를 적용 한 후, `map` 메소드는 새로운 모든 매핑된 값을 포함하는 새로운 배열을 반환하며 기존 배열에 같은 값으로 순서가 배치됨.

후행 클로저에 `map` 메소드를 사용하여 Int 값의 배열을 문자열 값의 배열로 변환하도록 하는 예제임.

	let digitNames = [
	    0: "Zero", 1: "One", 2: "Two",   3: "Three", 4: "Four",
	    5: "Five", 6: "Six", 7: "Seven", 8: "Eight", 9: "Nine"
	]
	let numbers = [16, 58, 510]

위 코드는 영어와 숫자간의 매핑 사잔을 생성하며 문자열로 변환할 숫자 배열을 정의함.

numbers 배열을 사용하여 문자열 값을 가진 배열을 만드는데 배열의 `map` 메소드에 후행 클로저로 된 클로저 표현식을 넘겨줌. numbers.map을 호출하는데 map 뒤에 괄호를 실 필요가 없는데 map 메소드는 오직 한 개의 인자만 가지고 인자는 후행 클로저를 지원하기 때문임.
정
	let strings = numbers.map {
	    (var number) -> String in
	    var output = ""
	    while number > 0 {
	        output = digitNames[number % 10]! + output
	        number /= 10
	    }
	    return output
	}
	// strings is inferred to be of type [String]
	// its value is ["OneSix", "FiveEight", "FiveOneZero"]


`map` 메소드는 배열에 각 항목마다 클로저 표현식을 호출함. 클로저의 입력 인자, number 타입을 지정할 필요가 없는데 이미 매핑될 배열의 값에서 타입을 추측하기 때문임.

이 예제에서 클로저의 number 인자는 변수 인자로 정의되고 이는 인자의 값이 클로저 안에서 수정될 수 있어 새로운 지역 변수로 선언하여 값을 할당할 필요가 없음을 의미함. 클로저 표현식은 또한 문자열 반환 타입을 지정하는데 이 타입은 매핑된 결과 배열의 타입을 가르키기 위함.

클로저 표현식은 호출될 때 마다 `output`이라는 문자를 만듬. number의 마지막 숫자를 나머지 연산자(number % 10)을 사용하여 계산한 뒤 digitNames 딕셔너리에 숫자와 맞는 문자열을 찾아 사용함. 클로저는 0보다 큰 숫자를 문자열로 다시 표현하도록 사용함.

digitNames 딕셔너리의 서브스크립트를 호출하면 느낌표(!)가 따름. 이는 딕셔너리 서브크립트는 옵셔널 값을 반환하는데 딕셔너리에서 만약 키로 찾는데 값이 없을수도 있기 때문임. 따라서 digitNames 딕셔너리에서 `number % 10`이 항상 유요한 서브크립트 키가 항상 보장되어야 하며, 느낌표는 서브스크립트의 옵셔널 반환 값에 문자열 값이 저장되도록 강제 언래핑하게 사용함.

digitNames 딕셔너리에서 가져온 문자열은 output 앞에 추가되며 숫자의 역순으로 문자열 버전이 효율적으로 만들어짐. (number % 10 표현식은 16에서 6을, 58에서 8을, 510에서 0을 얻음.)

number 변수는 10으로 나뉘는데 이는 정수이며 소숫점 아래 값은 버려짐.

이 과정이 number /= 10이 0이 될때까지 반복하여 output 문자열이 클로저로부터 반환되고 map 함수에 의해 출력 배열에 추가가 됨.

후위 클로저 문법을 앞선 예제에 사용하여 깔끔하게 캡슐화 함.

### 값 획득하기(Capturing Values)

클로저는 자신이 정의된 주변 컨텍스트로부터 상수와 변수를 획득할 수 있음. 클로저는 상수와 변수들이 정의된 범위가 더이상 존재하지 않는 경우에조자도 값을 참조하거나 수정할 수 있음.

Swift에서 가장 간단한 클로저는 다른 함수 내에 작성된 중첩 함수임. 중첩함수는 밖에 있는 상수와 변수를 획득할 수 있고 밖에 있는 함수의 인자도 획득할 수 있음.

incrementor 중첩 함수를 포함하는 mackIncrementor 함수 예제. incrementor 중첩 함수는 두 개의 값 runningTotal과 amount 값을 둘러싸고 있는 컨텍스트로부터 획득할 수 있음. 이들 값을 획득한 후 incrementor는 호출될 때 마다 runningTotal과 amount를 호출될 때 마다 증가시키는 mackIncrementor로부터 반환됨.

	func makeIncrementor(forIncrement amount: Int) -> ( () -> Int ) {
	    var runningTotal = 0
	    func incrementor() -> Int {
	        runningTotal += amount
	        return runningTotal
	    }
	    return incrementor
	}

makeIncrementor는 반환 타입이 `() -> Int`임. 간단한 값 대신 함수를 반환함을 의미. 이 함수는 인자를 가지지 않고 매번 호출될 때 마다 Int 값을 반환함.

makeIncrementor 함수는 runningTotal 정수 변수를 정의하며 현재 실행중인 incrementor의 총합을 저장하고 반환할 것임. 이 값은 0으로 초기화 되어 있음.

makeIncrementor 함수는 단일 Int 인자를 가지며 forIncrement 외부 이름, amount는 지역 이름. 인자로 전달된 인자 값은 runningTotal을 매번 incrementor 함수가 호출될 떄마다 얼마나 증가해야 할 지 정함.

makeIncrementor는 incrementor로 불리는 중첩함수를 정의하고 실제로 증가를 수행함. 이 함수는 runningTotal에 amount를 더 해 그 결과를 반환함.

고립된 상황을 볼 때 incrementor 중첩 함수는 특이하게 보여짐.

	func incrementor() -> Int {
	    runningTotal += amount
	    return runningTotal
	}

incrementor 함수는 인자가 지만 runningTotal과 amount를 함수 내부에서 참조함. 자신의 함수 내에서 둘러까지 있는 함수로부터 runningTotal과 amount의 존재하는 값을 획득하여 사용함.

따라서 amount 값을 수정하지 않기 때문에 incrementor는 실제로 amount에 저장된 값을 획득하고 값의 복사본에 저장함.

그러나 runningTotal 변수는 호출될 때 마다 변경되는데 이는 incrementor는 현재 runningTotal 변수 참조를 획득하기 때문이며 초기 값의 복사는 하지 않음. 참조 획득은 makeIncrementor이 호출되고 끝날 때 사라지지 않음을 보증하며, incrementor 함수가 호출되고 난 다음에도 runningTotal이 계속 사용 가능함을 보증함.

Swift는 값을 복사할지 참조하여 획득할지 결정함. amount나 runningTotal을 중첩함수에서 사용할지 명시할 필요가 없음. Swift는 runningTotal이 incrementor 함수로부터 더이상 필요하지 않을 때 메모리 관리에서 정리함.

다음은 makeIncrementor의 동작 예제.

	let incrementByTen = makeIncrementor(forIncrement: 10)

이 예제는 incrementor함수에서 호출될때마다 runningTotal에 10씩 더하도록 참조하는 incrementByTen 상수를 정의함.

다음은 함수를 여러번 호출하여 수행하도록 한 예제.

	incrementByTen()
	// returns a value of 10
	incrementByTen()
	// returns a value of 20
	incrementByTen()
	// returns a value of 30

만약 두번째 incrementor를 만들더라도 runningTotal 변수는 분리되어 참조됨.

	let incrementBySeven = makeIncrementor(forIncrement: 7)
	incrementBySeven()
	// returns a value of 7

클로저를 클래스 인스턴스의 속성으로 할당하고 클로저가 인스턴스 또는 그 멤버를 참조하여 인스턴스를 획득한다면, 클로저와 인스턴스 사이에 강력한 참조 순환을 만듬.

Swift는 강력한 참조 순환을 깨기 위해 캡쳐 리스트(capture lists)를 사용함.

### 참조 타입인 클로저(Closure Are Reference Types)

위에 예제에서 incrementBySeven과 incrementByTen은 상수지만 클로저는 여전히 runningTotal 변수를 증가시키도록 참조함. 이것은 함수와 클로저는 참조 타입이기 때문임.

함수나 클로저를 상수에 할당하는 때는 그 상수에 함수나 클로저를 가르키는 참조를 할당하는 것임. 위의 예제에서 incrementByTen 상수는 클로저를 참조하며, 클로저 내용은 아님.

이 의미는 다른 두개의 상수나 변수에 동일한 클로저를 할당하면 같은 클로저를 참조한다는 의미.

	let alsoIncrementByTen = incrementByTen
	alsoIncrementByTen()
	// returns a value of 50


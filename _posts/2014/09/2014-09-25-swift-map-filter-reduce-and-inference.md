---
layout: post
title: "[Swift]Map, Filter, Reduce 그리고 추론"
description: ""
category: "mac/ios"
tags: [swift, map, filter, reduce, inference, closure]
---
{% include JB/setup %}

우선 Swift의 Map, Filter, Reduce에 설명하기 앞서 Closure에서 사용될 추론에 대해 먼저 설명하고자 합니다.<br/><br/>

## 추론(Inference)

애플 문서에도 나와있지만 Swift에서 추론은 아주 강력하며, 코드의 양을 줄여줍니다. 대신, 추론을 이해하지 못하면 코드의 가독성이 떨어집니다.

다음은 클로저와 가변 인자로 인자를 가지는 함수 코드입니다.

	func sumOfSquare(clousre: (Double -> Double), numbers: Double...) -> Double {
	    var result: Double = Double()
	    for number in numbers {
	        result += clousre(number)
	    }
	    return result
	}

위 함수는 가변 인자의 값들을 클로저를 통한 값들로 모두 합치는 역할을 합니다.

다음은 클로저에 넣을 함수 정의 코드입니다.

	func square(value: Double) -> Double {
	    return value * value
	}

위의 코드를 정의하여 다음과 같이 사용할 수 있습니다.

	sumOfSquare(square, 1,2,3,4,5,6)
	// 55.0

함수를 인자에 할당하였기 때문에 추론을 사용하지 않습니다. 그렇다면 추론을 통한 클로저를 작성합니다.

위의 square 함수 역할을 하는 클로저를 만들어 인자에 할당하도록 합니다.

	sumOfSquare( {(value: Double) -> Double in return value * value}, 1,2,3,4,5 )

아직 추론으로 코드를 줄이지 않은 클로저를 만들었습니다.

위 클로저에서 반환 타입 Double은 value 값의 타입을 통해 반환 타입이 추론되므로 생략 가능합니다.

	sumOfSquare( { (value: Double) in return value * value }, 1,2,3,4,5 )

클로저에서 항상 in 뒤에는 return이 따라오므로 return이 생략 가능합니다.

	sumOfSquare( { (value: Double) in value * value }, 1,2,3,4,5 )

클로저의 value 값의 타입은 sumOfSquare 함수에 정의되어 있기 때문에 생략 가능합니다.

	sumOfSquare( { value in value * value }, 1,2,3,4,5 )

이제 클로저의 value는 중복해서 쓰이기 때문에 인자로 들어오는 순대로 $0번부터 시작하여 사용할 수 있습니다. 따라서 어떻게 값을 반환할지만 남기고 value와 in은 생략 가능합니다.

	sumOfSquare( { $0 * $0 }, 1,2,3,4,5 )

이 클로저에서는 연산자 *만 사용하는데 연산자 *은 중위 연산자로 왼쪽 값과 오른쪽 값이 필요합니다. 하지만 이 클로저에서는 인자를 하나만 가지기 때문에 왼쪽 값과 오른쪽 값을 추론하지 못합니다. 따라서 위 코드가 최종적인 추론을 통한 클로저입니다.

만일 인자가 2개라면 *는 중위 연산자이기 때문에 다음과 같이 추론하여 생략 가능합니다.

	sumOfSquare( *, 1,2,3,4,5 )

즉, 왼쪽 값과 오른쪽 값을 곱한다고 추론하기 때문에 위의 코드처럼 생략 할 수 있습니다.<br/><br/>


## 순차 작업

Swift의 표준 배열 라이브러리는 map, filter, reduce라는 세가지 기능을 제공합니다.

### Map

클로저로 각 항목들을 반영한 결과물을 가진 새로운 배열을 반환합니다.

	// Declaration
	func map<U>(transform: (T) -> U) -> Array<U>

	[x1, x2, ... xn].map(f) -> [f(x1), f(x2), ... , f(xn)]

transform을 지원하는 클로저는 변경된 값을 반환하기 위해 해당 타입의 값을 반환해야 합니다.

다음은 [1, 2, 3, 4]인 배열에서 2씩 곱한 배열을 얻는 예제입니다.

	let array = [0, 1, 2, 3]
	let multipliedArray = array.map( { (value: Int) -> Int in return value * 2 } )
	// [2, 4, 6, 8]

map에서도 추론하여 코드를 생략할 수 있습니다. 우선, value의 타입 Int와 return 키워드는 추론을 통해 생략 가능합니다.

	array.map( { (value) -> Int in value * 2 } )

-> Int도 생략 가능합니다.

	array.map( {value in value * 2 } )

value는 여러번 사용하므로 $0으로 축약할 수 있습니다.

	array.map( {$0 * 2} )

또한, 괄호도 생략 가능합니다.

	array.map { $0 * 2 }

만약 값에 문자열 "Number : "를 붙인다면 다음과 같이 사용할 수 있습니다.

	array.map{ "Number :  \($0)" }

### Filter

클로저로 각 항목들을 비교하여 일치하는 결과물을 가진 새로운 배열을 반환합니다.

	// Declaration
	func filter(includeElement: (T) -> Bool) -> Array<T>

`includeElement`를 지원하는 클로저는 항목이 포함되는지(`true`) 또는 제외되는지(`false`) 나타내기 위해 Boolean 값을 반환해야 합니다.

다음은 앞의 예제에서 사용한 배열에 홀수 값 항목만 가지는 배열을 얻는 예제입니다.

	let oddArray = array.filter( { (value: Int) -> Bool in return (value % 2 == 0) } )
	//[2, 4]

앞에서 했던 방식으로 코드를 생략 가능합니다.

	array.filter { $0 % 2 == 0 }

### Reduce

	// Declaration
	func reduce<U>(initial: U, combine: (U, T) -> U) -> U

배열의 각 항목들을 재귀적으로 클로저를 적용시켜 하나의 값을 만듭니다.

	array.reduce(0, { (s1: Int, s2: Int) -> Int in
	    return s1 + s2
	})

클로저는 함수의 마지막에 위치하면 다른 인자와 분리하여 작성할 수 있습니다.

	array.reduce(0) { (s1: Int, s2: Int) -> Int in
	    return s1 + s2
	}

위 코드에서 s1, s2의 타입은 추론하므로 생략 가능합니다.

	array.reduce(0) { (s1, s2) in s1 + s2 }

s1과 s2는 $0, $1로 대신하여 사용할 수 있습니다.

	array.reduce(0) { $0 + $1 }

+ 연산자는 중위 연산자로 왼쪽 값이 $0, 오른쪽 값이 $1임을 추론 가능하므로 다음과 같이 생략 가능합니다.

	array.reduce( 0, + )

만일 initial 값이 0이라면 초기 항목은 `{0 + 1}`입니다. 값이 1이라면 `{1 + 1}`입니다.

클로저는 이전 결과와 다음 항목을 계속 호출하여 다음과 같은 과정을 거쳐 하나의 값을 얻습니다.

`{0 + 1}`, `{1 + 2}`, `{3 + 3}`, `{6 + 4}`이며, 결과는 10입니다. 
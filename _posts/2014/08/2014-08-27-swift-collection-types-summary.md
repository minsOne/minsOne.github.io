---
layout: post
title: "[Swift]Collection Types 정리"
description: ""
category: "mac/ios"
tags: [swift, collection, type, array, dictionary, nsarray, nsmutablearray, nsdictionary, nsmutabledictionary, for-in]
---
{% include JB/setup %}

## 컬렉션 타입(Collection Types)

Swift는 두 가지 컬렉션 타입 Array와 Dictionary를 제공.

Array는 같은 타입의 값을 순서대로 저장. Dictionary는 같은 타입의 값을 순서 상관없이 저장하며 유일한 식별자(Key)를 통해 값을 찾음.

Array와 Dictionary는 저장 시 키와 값의 타입에 명확해야 하며 실수로 Array나 Dictionary에 실수로 다른 타입의 값이 저장되지 않음을 의미.

<div class="alert-info">
Swift에서 명시적인 타입 컬렉션 사용은 코드가 타입이 명확해야 하며 개발시 맞지 않은 타입을 빠르게 찾을 수 있음.
</div>


### 가변 컬렉션(Mutability of Collections)

변수에 할당된 컬렉션은 가변적임. 컬렉션은 만들어 진 후 컬렉션에 있는 아이템이 추가되고 재배치되고 변경되기 때문. 

반면, 상수는 불변으로 크기나 내용은 변경할 수 없음.


### 배열(Arrays)

배열은 같은 타입의 다중 값이 정렬된 순서로 저장함. 배열에서 같은 값이지만 시간이 다르면 각각 다른 위치에 있음.

<div class="alert-info">
Swift의 Array는 Objective-C의 NSArray나 NSMUtableArray 클래스와는 다른 종류로, 후자는 어떤 종류의 객체를 저장해도 반환시 아무런 정보를 제공해주지 않음. Swift에서는 배열에 저장할 타입은 항상 명시적으로 타입을 선언하거나 타입 추정을 통해 명확함.
</div>


#### 축약 배열 타입 문법(Array Type Shorthand Syntax)

Swift의 Array 타입은 `Array<SomeType>`으로 작성, SomeType은 배열에 저장될 타입. 간단하게 쓰면 `[SomeType]`으로 작성 가능.


#### 배열 표현식(Array Literals)

배열은 하나 이상의 값을 축약 방식으로 작성하여 배열 컬렉션을 초기화 할 수 있음.

배열 표기법은 값 목록을 콤마(,)로 분리하며 한 쌍의 중괄호로 감싸여 표현함.

	[value 1, value 2, value 3]

	var shoppingList: [String] = ["Eggs", "Milk"]
	// shoppingList has been initialized with two initial items

또한, `[String]`에 영향을 받아 타입 추론을 통해 변수에 배열을 초기화하여 할당할 수 있음.

	var shoppingList = ["Eggs", "Milk"]


#### 배열의 접근과 수정(Accessing and Modifying an Array)

배열에 메소드와 속성 또는 아래 첨자 문법을 통해 접근 및 수정할 수 있음.

다음은 배열의 개수를 확인하는 읽기 전용 `count` 속성임.
	
	println("The shopping list contains \(shoppingList.count) items.")
	// prints "The shopping list contains 2 items."

`count` 속성을 이용하지 않고 `isEmpty` 속성을 통해 빠르게 배열이 비었는지 확인이 가능.

	if shoppingList.isEmpty {
	    println("The shopping list is empty.")
	} else {
	    println("The shopping list is not empty.")
	}
	// prints "The shopping list is not empty."

배열에 `append` 메소드를 통해 배열 끝에 새로운 값을 추가할 수 있음.

	shoppingList.append("Flour")
	// shoppingList now contains 3 items, and someone is making pancakes

하나 이상 적절한 값을 가진 배열을 추가 할당 연산자(+=)를 이용하여 추가할 있음.

	shoppingList += ["Baking Powder"]
	// shoppingList now contains 4 items
	shoppingList += ["Chocolate Spread", "Cheese", "Butter"]
	// shoppingList now contains 7 items

배열에 인덱스로 접근하여 값을 얻을 수 있음. 또한, 인덱스로 접근하여 값을 변경할 수 있음.

	var firstItem = shoppingList[0]
	// firstItem is equal to "Eggs"

	shoppingList[0] = "Six eggs"
	// the first item in the list is now equal to "Six eggs" rather than "Eggs"

배열에 인덱스 범위를 통해 접근하여 값을 변경하거나 배열을 대체함.

	shoppingList[4...6] = ["Bananas", "Apples"]
	// shoppingList now contains 6 items
	// replace "Chocolate Spread", "Cheese" and "Butter" to "Bananas" and "Apples"

배열의 `insert(atIndex:)` 메소드를 호출하여 특정 인덱스에 삽입할 수 있음.

	shoppingList.insert("Maple Syrup", atIndex: 0)
	// shoppingList now contains 7 items
	// "Maple Syrup" is now the first item in the list

`removeAtIndex` 메소드를 호출하여 특정 인덱스의 값을 제거할 수 있음.

	let mapleSyrup = shoppingList.removeAtIndex(0)
	// the item that was at index 0 has just been removed
	// shoppingList now contains 6 items, and no Maple Syrup
	// the mapleSyrup constant is now equal to the removed "Maple Syrup" string

배열의 마지막 값을 삭제하고자 한다면 `removeAtIndex` 보다 `removeLast` 메소드를 이용하여 삭제하기 더 좋음. count 속성을 호출하는 것을 안하기 때문.

	let apples = shoppingList.removeLast()
	// the last item in the array has just been removed
	// shoppingList now contains 5 items, and no apples
	// the apples constant is now equal to the removed "Apples" string

#### 배열에서 반복문 사용하기(Iterating Over an Array)

for-in 문을 사용하여 배열의 모든 값을 접근할 수 있음.

	for item in shoppingList {
	    println(item)
	}
	// Six eggs
	// Milk
	// Flour
	// Baking Powder
	// Bananas

각 아이템에 정수 인덱스와 그 값이 필요하다면, `enumerate` 전역 함수를 사용함. `enumerate` 함수는 배열에 각 아이템의 인덱스와 값으로 구성된 튜플을 반환함.

	for (index, value) in enumerate(shoppingList) {
	    println("Item \(index + 1): \(value)")
	}
	// Item 1: Six eggs
	// Item 2: Milk
	// Item 3: Flour
	// Item 4: Baking Powder
	// Item 5: Bananas


#### 배열 생성과 초기화

초기화 문법을 사용하여 특정 타입의 빈 배열을 만듬.

	var someInts = [Int]()
	println("someInts is of type [Int] with \(someInts.count) items.")
	// prints "someInts is of type [Int] with 0 items."


someInt 변수는 `[Int]`에 영향을 받음. 이는 `[Int]` 초기화의 결과물에 설정됨.

한번이라도 타입이 설정되면 `[]`로 초기화하여도 타입은 유지됨.

	someInts.append(3)
	// someInts now contains 1 value of type Int
	someInts = []
	// someInts is now an empty array, but is still of type [Int]

Swift에 배열 타입은 특정 크기와 그 크기에 기본 값으로 설정할 수 있는 생성자를 제공.
이 생성자에 몇 개의 아이템을 넣을 것인지(count 호출), 적합한 타입의 기본 값(repeatedValue 호출)을 넘겨줌.

	var threeDoubles = [Double](count: 3, repeatedValue: 0.0)
	// threeDoubles is of type [Double], and equals [0.0, 0.0, 0.0]

서로 같은 타입의 배열이 있으면 덧셈 연산자(+)를 이용하여 배열을 생성. 이 배열 타입은 앞에 배열에서 영감받아 같은 타입.

	var anotherThreeDoubles = [Double](count: 3, repeatedValue: 2.5)
	// anotherThreeDoubles is inferred as [Double], and equals [2.5, 2.5, 2.5]
	 
	var sixDoubles = threeDoubles + anotherThreeDoubles
	// sixDoubles is inferred as [Double], and equals [0.0, 0.0, 0.0, 2.5, 2.5, 2.5]


### 딕셔너리(Dictionaries)

딕셔너리는 같은 타입의 여러 값을 저장하고 있는 컨테이너. 각각의 값은 유일한 식별자는 딕셔너리 안에 값과 연관됨. 배열과는 다르게 특정한 순서를 가지지 않음.

딕셔너리를 사용할 때는 식별자를 기반으로 값을 찾을 때임.

<div class="alert-info">
Swift의 딕셔너리는 Objective-C의 NSDictionary와 NSMutableDictionary 클래스와는 다름. Swift의 배열과 마찬가지로 딕셔너리는 정해진 타입의 객체만 저장이 가능함.
</div>


#### 축약 딕셔너리 타입 문법(Dictionary Type Shorthand Syntax)

Swift 딕셔너리 타입은 `Dictionary<KeyType, ValueType>`으로 쓰며, `KeyType`은 딕셔너리 키로 사용되는 값 타입, `ValueType`은 딕셔너리에 저장되는 값으로 키에 매칭되는 값 타입.

딕셔너리 타입의 축약 문법은 `[KeyType: ValueType]`


#### 딕셔너리 표현식(Dictionary Literals)

딕셔너리 표현법으로 딕셔너리를 초기화할 수 있으며 배열 표현법과 유사한 형태임. 각각의 키와 값으로 쌍을 이루어 콤마로 구분되며 중괄호로 감싸진 형태.

	[key 1: value 1, key 2: value 2, key 3: value 3]

다음은 딕셔너리 표현식으로 초기화하는 예제.

	var airports: [String: String] = ["TYO": "Tokyo", "DUB": "Dublin"]

airport 딕셔너리는 `[String: String]` 타입을 가지며 이는 키는 문자열 타입, 값도 문자열 타입 의미.

또한 앞에서 배열과 같이 딕셔너리 초기화를 통해 타입을 추론하여 변수의 타입을 지정할 수 있음.

	var airports = ["TYO": "Tokyo", "DUB": "Dublin"]


#### 딕셔너리 접근과 수정(Accessing and Modifying a Dictionary)

딕셔너리는 메소드와 속성 또는 서브스크립트 문법을 통해 접근과 수정이 가능. 딕셔너리에서 아이템 개수를 찾을 때 읽기 전용 count 속성을 통해 확인할 수 있음.

	println("The airports dictionary contains \(airports.count) items.")
	// prints "The airports dictionary contains 2 items."

isEmpty 속성을 통해 빈 딕셔너리인지 확인 가능.

	if airports.isEmpty {
	    println("The airports dictionary is empty.")
	} else {
	    println("The airports dictionary is not empty.")
	}
	// prints "The airports dictionary is not empty."

서브스크립트 문법을 통해 딕셔너리에 새로운 아이템을 추가 가능. 

	airports["LHR"] = "London"
	// the airports dictionary now contains 3 items

서브스크립트 문법을 사용하여 특정 키에 연관된 값을 변경할 수 있음.

	airports["LHR"] = "London Heathrow"
	// the value for "LHR" has been changed to "London Heathrow"

서브스크립트 문법 대신하여 딕셔너리의 `updateValue(forKey:)` 메소드를 사용하여 값 변경 가능.

`updateValue(forKey:)` 메소드는 옵셔널 값을 반환하므로 값이 있는지 확인해야 함.

	if let oldValue = airports.updateValue("Dublin International", forKey: "DUB") {
	    println("The old value for DUB was \(oldValue).")
	}
	// prints "The old value for DUB was Dublin."

또한, 서브스크립트 문법을 통해 값을 확인할 수 있는데, 이때 값이 없다면 nil을 반환함.

	if let airportName = airports["DUB"] {
	    println("The name of the airport is \(airportName).")
	} else {
	    println("That airport is not in the airports dictionary.")
	}
	// prints "The name of the airport is Dublin International."

서브스크립트 문법을 통해 딕셔너리에 할당된 값을 nil로 할당하여 key-value를 제거할 수 있음.

	airports["APL"] = "Apple International"
	// "Apple International" is not the real airport for APL, so delete it
	airports["APL"] = nil
	// APL has now been removed from the dictionary

`removeValueForKey` 메소드를 통해 key-value를 제거할 수 있음. 이 메소드는 값이 있으면 제거된 값을, 없으면 nil을 반환.

	if let removedValue = airports.removeValueForKey("DUB") {
	    println("The removed airport's name is \(removedValue).")
	} else {
	    println("The airports dictionary does not contain a value for DUB.")
	}
	// prints "The removed airport's name is Dublin International."

#### 딕셔너리 반복문 사용하기(Iterating Over a Dictionary)

for-in 반복문을 사용. 각각의 딕셔너리에 아이템은 `(key, value)` 튜플로 반환되는데 일시적인 상수나 변수로 튜플의 멤버로 분리할 수 있음.

	for (airportCode, airportName) in airports {
	    println("\(airportCode): \(airportName)")
	}
	// LHR: London Heathrow
	// TYO: Tokyo

딕셔너리의 `keys`와 `values` 속성을 가지고 접근한 키나 값의 컬렉션을 반복하여 검색할 수 있음.

	for airportCode in airports.keys {
	    println("Airport code: \(airportCode)")
	}
	// Airport code: LHR
	// Airport code: TYO
	 
	for airportName in airports.values {
	    println("Airport name: \(airportName)")
	}
	// Airport name: London Heathrow
	// Airport name: Tokyo

딕셔너리의 키나 값을 `keys`나 `values`속성을 가지고 새로운 배열 인스턴스를 초기화 가능.

	let airportCodes = [String](airports.keys)
	// airportCodes is ["LHR", "TYO"]
	 
	let airportNames = [String](airports.values)
	// airportNames is ["London Heathrow", "Tokyo"]


#### 빈 딕셔너리 생성(Creating an Empty Dictionary)

배열처럼 딕셔너리도 초기화 문법을 사용하여 특정 타입의 빈 딕셔너리를 만들 수 있음.

	var namesOfIntegers = [Int: String]()
	// namesOfIntegers is an empty [Int: String] dictionary

배열과 마찬가지로 이미 타입이 정해져 있는 딕셔너리를 빈 딕셔너리로 초기화하여도 타입은 그대로 유지.

빈 딕셔너리 표현법은 `[:]`로 사용.

	namesOfIntegers[16] = "sixteen"
	// namesOfIntegers now contains 1 key-value pair
	namesOfIntegers = [:]
	// namesOfIntegers is once again an empty dictionary of type [Int: String]

#### 딕셔너리 키 타입을 위한 해쉬 값(Hash Values for Dictionary Key Types)

Swift의 모든 기본 타입(String, Int, Double, Bool)은 기본적으로 해쉬가 가능하며 이 모든 타입은 딕셔너리의 키로 사용됨.

<div class="alert-info">
자신만의 타입을 딕셔너리에 넣어 사용하고자 한다면 Swift 표준 라이브러리로 부터 Hashable 프로토콜을 만들어 따라야함.
</div>














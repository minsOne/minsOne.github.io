---
layout: post
title: "Swift - Generics 정리"
description: ""
category: "mac/ios"
tags: [swift, generic, protocol, type parameter, extend, type constraint, associated type, where]
---
{% include JB/setup %}

## 제네릭(Generics)

제네릭 코드는 유연하게 작성할 수 있고, 재사용가능한 함수와 타입이 어떤 타입과 작업할 수 있도록 요구사항을 정의한다. 중복을 피하고 의도를 명확하게 표현하고, 추상적인 방법으로 코드를 작성할 수 있다.

제네릭은 Swift에서 가장 강력한 기능 중 하나로 Swift 표준 라이브러리 대다수는 제네릭 코드로 만들졌다. Swift의 배열과 딕셔너리 타입은 제네릭 타입이며, Int 값을 가지는 배열이나 String 값을 가지는 배열 또는 다른 타입으로 배열을 만들 수 있다. 유사하게 지정된 타입의 값을 저장하는 딕셔너리를 만들 수 있으며, 이러한 타입은 제한이 없다.

### 제네릭으로 문제 해결(The Problem That Generics Solve)

다음은 제네릭을 사용하지 않는 일반적인 함수 예제이다.

	func swapTwoInts(inout a: Int, inout b: Int) {
	    let temporaryA = a
	    a = b
	    b = temporaryA
	}

위 함수는 in-out 인자를 통해서 두 값을 바꾸도록 만든다. 

	var someInt = 3
	var anotherInt = 107
	swapTwoInts(&someInt, &anotherInt)
	println("someInt is now \(someInt), and anotherInt is now \(anotherInt)")
	// prints "someInt is now 107, and anotherInt is now 3"

swapTwoInts 함수는 Int 값만 사용할 수 있다. String 값이나 Double 값을 바꾸고 싶으면 함수를 더 작성해야 한다.

	func swapTwoStrings(inout a: String, inout b: String) {
	    let temporaryA = a
	    a = b
	    b = temporaryA
	}
	 
	func swapTwoDoubles(inout a: Double, inout b: Double) {
	    let temporaryA = a
	    a = b
	    b = temporaryA
	}

제네릭 코드를 가지고 함수를 유연하게 만들어 하나의 함수로 작성할 수 있다.


### 제네릭 함수(Generic Functions)

제네릭 함수는 어떤 타입으로도 작업할 수 있다. 다음은 위의 swapTwoInts 함수를 제네릭 함수로 변경한 예제이다.

	func swapTwoValues<T>(inout a: T, inout b: T) {
	    let temporaryA = a
	    a = b
	    b = temporaryA
	}

swapTwoValues 함수 내에서 swapTwoInts 함수의 내용과 같다. 그러나 함수 정의 부분이 다르다.

	func swapTwoInts(inout a: Int, inout b: Int)
	func swapTwoValues<T>(inout a: T, inout b: T)

함수의 제네릭 버전은 자리 표시 타입 이름(이 경우 T라는 이름을 사용)을 실제 타입 이름(Int, String, Double 같은) 대신 사용한다. 자리 표시 타입 이름은 `T`에 대해서 아무 말도 하지 않지만, a와 b는 T 타입이라고 말한다. 실제 타입의 사용은 swapTwoValues 함수가 매번 호출 될 때마다 `T`가 결정된다.

제네릭 함수의 이름의 다른 차이점은 `T` 이름을 꺽쇠(`<T>`)로 감싼다. 꺽쇠는 Swift에게 swapTwoValues함수 정의 내에서 `T`가 자리 표시 타입 이름이라고 말한다. `T`가 자리 표시이기 때문에, Swift는 `T`라는 실제 타입을 찾지 않는다.

swapTwoValues 함수는 swapTwoInts와 같은 방식으로 호출지만, 예외라면 어떤 타입이든지 넘길 수 있다. 매번 swapTwoValues이 호출되면 `T`는 함수에 넘겨진 타입의 값으로부터 추론하여 타입을 사용한다.

	var someInt = 3
	var anotherInt = 107
	swapTwoValues(&someInt, &anotherInt)
	// someInt is now 107, and anotherInt is now 3
	 
	var someString = "hello"
	var anotherString = "world"
	swapTwoValues(&someString, &anotherString)
	// someString is now "world", and anotherString is now "hello"

<div class="alert-info">
	swapTwoValues 함수는 swap이라는 제네릭 함수로부터 영감을 받아 정의되는데, 이는 Swift 표준 라이브러리의 한 부분이다. 만약 swapTwoValues 함수 행동이 필요하다면, Swift의 기존 swap 함수를 사용하는 것이 낫다.
</div>


### 타입 인자(Type Parameters)

swapTwoValues 예제에서 자리표시 타입 `T`는 타입 인자이다. 타입 인자는 자리 표시 타입을 정하고 명명하고 함수 이름 뒤에 바로 사용한다.

타입 인자를 정하면 함수의 인자 타입을 정의하는데 사용하거나 함수의 반환 타입 또는 함수 내에서 타입 표시로 사용할 수 있다. 각 경우에서 자리 표시 타입은 함수가 호출될 때 실제 타입으로 대체되도록 표시한다. 가령 Int 타입으로 인자가 들어오면 T는 Int 타입으로 대체된다.

하나 이상의 타입 인자를 사용할 수 있으며, 꺽쇠 안에서 타입 인자 이름을 콤마로 분리하여 작성한다. (ex. <T, M>)

### 타입 인자 명명하기(Naming Type Parameters)

제네릭 함수를 추가하면 Swift는 자신만의 제네릭 타입을 정의할 수 있다. 사용자 클래스, 구조체 그리고 열거형은 어떤 타입으로도 작업할 수 있으며, 유사하게는 배열과 딕셔너리가 있다.

stack이라는 제네릭 컬렉션 타입을 작성한다. 스택은 값의 순서로 설정되어 있으며, 배열과 유사하지만, Swift 배열 타입보다 좀 더 엄격하다. 배열은 새로운 요소를 배열 안에 어디에서든 넣고 제거할 수 있다. 스택은 새로운 아이템은 컬렉션 끝에만 추가할 수 있다. 스택은 컬렉션의 마지막만 제거할 수 있다.

다음은 스택의 Push / Pop 행동을 보여주는 그림이다.

<img src="/../../../../image/2014/09/stackPushPop_2x.png" alt="stackPushPop_2x" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

다음은 제네릭이 아닌 버전의 스택 예제이다.

	struct IntStack {
	    var items = [Int]()
	    mutating func push(item: Int) {
	        items.append(item)
	    }
	    mutating func pop() -> Int {
	        return items.removeLast()
	    }
	}

items라는 배열 속성은 스택 안에서 값을 저장한다. Stack은 두 개의 메소드 push, pop을 제공한다. 이들 메소드는 mutating으로 표시되었는데, 구조체의 items 배열을 수정해야 할 필요가 있기 때문이다.

위 구조체는 Int 타입만 가질 수 있지만 제네릭을 사용한 스택 클래스는 타입에 유연하게 사용할 수 있다.

	struct Stack<T> {
	    var items = [T]()
	    mutating func push(item: T) {
	        items.append(item)
	    }
	    mutating func pop() -> T {
	        return items.removeLast()
	    }
	}

제네릭 버전의 스택은 실제 타입인 Int를 대신하여 자리 표시 타입 인자로 T를 사용한다. 타입 인자는 꺽쇠`<T>`를 구조체 이름 뒤에 바로 위치해야 한다.

`T`는 "어떤 타입 `T`"을 위한 자리 표시 이름을 정의하며, 장래 타입은 `T`로서 구조체 정의 내에서 어디든 참조된다. 이 경우에서는 세 곳에서 사용된다.

* items라는 속성을 만들기 위해 타입 T의 빈 배열이 초기화된다.
* push 메소드가 item이라는 단일 인자를 가지도록 정하기 위해 타입 T를 가 된다.
* pop 메소드가 타입 T의 값을 반환하도록 정한다.

제네릭 타입이기 때문에, 스택은 Swift 내에서 유효한 타입의 스택을 만들 수 있고, 이는 배열과 딕셔너리와 비슷하다.

	var stackOfStrings = Stack<String>()
	stackOfStrings.push("uno")
	stackOfStrings.push("dos")
	stackOfStrings.push("tres")
	stackOfStrings.push("cuatro")
	// the stack now contains 4 strings

다음은 스택에 네 개의 값이 들어가는 모습을 나타낸 그림이다.

<img src="/../../../../image/2014/09/stackPushedFourStrings_2x.png" alt="stackPushedFourStrings" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

스택에서 마지막 값을 제거한다.

	let fromTheTop = stackOfStrings.pop()
	// fromTheTop is equal to "cuatro", and the stack now contains 3 strings

다음은 스택에서 마지막 값이 나온 후의 모습을 나타낸 그림이다.

<img src="/../../../../image/2014/09/stackPoppedOneString_2x.png" alt="stackPoppedOneString" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>


### 제네릭 타입 확장(Extending a Generic Type)

제네릭 타입을 확장할 때, 확장의 정의 한 부분으로서 타입 인자 목록을 제공하지 않는다. 대신, 기존 타입 정의로부터 타입 인자 목록은 확장의 내에서 가능하며, 기존 타입 인자 이름은 기존 정의로부터 타입 인자를 참조하는데 사용된다.

다음은 제네릭 스택 태입을 확장하는 예제로, topItem이라는 계산 속성이 추가된다.

	extension Stack {
	    var topItem: T? {
	        return items.isEmpty ? nil : items[items.count - 1]
	    }
	}

topItem 속성은 옵셔널 타입 T 값을 반환하며, 스택이 비었으면 nil을, 스택이 비지 않으면 topItem은 items 배열에 마지막 요소를 반환한다.

확장은 타입 인자 목록을 정의하지 않음을 유의한다. 대신 스택 타입의 기존 타입 인자 이름 T는 topItem 계산 속성의 옵셔널 타입을 나타내는 확장에 사용된다.

topItem 계산 속성은 어디에서나 접근 및 조회가 가능하다.

	if let topItem = stackOfStrings.topItem {
	    println("The top item on the stack is \(topItem).")
	}
	// prints "The top item on the stack is tres."


### 타입 제약(Type Constraints)

제네릭 함수와 제네릭 타입을 사용할 때 특정 타입으로 강제하면 유용한 경우가 있다. 타입 강제는 특정 클래스로부터 타입 인자가 상속받아야 하거나, 특정 프로토콜 또는 프로토콜 결합과 일치해야 한다.

Swift의 딕셔너리 타입은 사용되는 키의 타입이 제한된다. 딕셔너리의 키 타입은 해쉬로 된다. 이는 독자적으로 표현되는 방법을 제공하는 것이다. 딕셔너리는 키를 해쉬로서 필요하고 특정 값을 이미 포함하고 있는지 확인할 수 있다. 요구수항 없이 딕셔너리는 특정 키에 대한 값을 추가하거나 교체할 수 없다. 주어진 키로 값을 찾아야한다.

딕셔너리를 위한 키에서 타입 제약이 요구사항에서 강제되며, 키 타입은 Hashable 프로토콜에 일치하도록 지정되며, 이 프로토콜은 Swift 표준 라이브러리에 정의되어 있다. 모든 Swift 기본 타입(String, Int, Double, Bool 같이)은 기본적으로 해쉬이다.

사용자 제네릭 타입을 만들 때 타입 제약을 정의할 수 있으며, 이들 제약은 제네릭 프로그램의 능력을 제공한다. Hashable 같은 추상 개념은 명확한 타입보다 개념적 특성의 측면에서 타입을 특성화 한다.

#### 타입 제약 문법(Type Constraint Syntax)

다음은 배열에서 문자열을 찾는 일반 함수 예제이다.

	func findStringIndex(array: [String], valueToFind: String) -> Int? {
	    for (index, value) in enumerate(array) {
	        if value == valueToFind {
	            return index
	        }
	    }
	    return nil
	}

하지만 위 함수는 문자열에만 유용하며 다른 타입의 값은 찾을 때 사용하지 않는다. 다음은 제네릭 버전의 함수로 변경하여 작성된 예제이다. 유의해야 할 사항으로 함수의 반환 값은 여전히 Int?로, 함수는 옵셔널 인덱스 숫자를 반환하기 때문이다. 

	func findIndex<T>(array: [T], valueToFind: T) -> Int? {
	    for (index, value) in enumerate(array) {
	        if value == valueToFind {
	            return index
	        }
	    }
	    return nil
	}

위 함수는 컴파일이 되지 않는다. 이는 Swift의 모든 타입이 동등 연산자(==)로 비교될 수 없기 때문이다. 만약에 복잡한 데이터 모델을 표현한 클래스나 구조체를 만든다면, Swift에서 같다라고 추측할 수 없다. 이때문에, 모든 가능한 타입 T에 대해 보장해주지 못한다.  따라서 컴파일 에러가 발생한다.

Equatable인 타입은 findIndex 함수에서 안전하게 사용될 수 있다. 동등 연산자를 지원하는 것에 대해선 보장한다. 이러한 사실로 표현하기 위해 함수를 정의할 때 타입 인자의 정의의 한 부분으로서 Equatable의 타입 제약으로 작성한다. 

	func findIndex<T: Equatable>(array: [T], valueToFind: T) -> Int? {
	    for (index, value) in enumerate(array) {
	        if value == valueToFind {
	            return index
	        }
	    }
	    return nil
	}

findIndex를 위한 단일 타입 인자는 `T: Equatable`로 쓰여지며, 이는 Equatable 프로토콜에 일치하는 어떤 타입 T를 의미한다.

findIndex 함수는 성공적으로 컴파일 되며, Double 또는 String 같은 Equatable의 타입을 사용할 수 있다.

	let doubleIndex = findIndex([3.14159, 0.1, 0.25], 9.3)
	// doubleIndex is an optional Int with no value, because 9.3 is not in the array
	let stringIndex = findIndex(["Mike", "Malcolm", "Andrea"], "Andrea")
	// stringIndex is an optional Int containing a value of 2

### 연관 타입(Associated Types)

프로토콜을 정의할 때, 프로토콜 정의의 한 부분으로서 하나이상의 연관 타입을 선언하면 유용하다. 연관 타입은 자리표시 이름을 타입에 주며, 이는 프로토콜의 부분으로서 사용된다. 연관 타입을 위한 실제 타입 사용은 프로토콜이 도입될 때까지 정해지지 않는다. 연관 타입은 `typealias` 키워드로 지정된다.

#### 연관 타입 사용(Associated Types in Action)

다음은 ItemType이라는 연관 타입을 가지는 프로토콜 예제이다.
	
	protocol Container {
	    typealias ItemType
	    mutating func append(item: ItemType)
	    var count: Int { get }
	    subscript(i: Int) -> ItemType { get }
	}

Container 프로토콜은 세가지 필요한 능력을 정의한다.

* append 메소드를 통해 새로운 아이템을 컨테이너에 추가할 수 있다.
* 아이템의 갯수를 접근하기 위해 컨테이너 안에 count 속성은 Int 값으로 반환한다.
* 컨테이너에 서브스크립트는 Int 인덱스 값을 가지고 각 요소를 받을 수 있다.

프로토콜은 어떻게 컨테이너 내에 저장하는 방법이나 아이템의 타입을 지정하지 않는다. 프로토콜은 오로지 Container로 타입이 되도록 하기 위해 세가지 기능을 지정한다. 일치하는 타입은 세가지 요구사항을 만족하는 추가 기능을 제공해야 한다.

Container 프로토콜에 일치하는 타입은 저장하는 값의 타입을 지정할 수 있다. 특히, 컨테이너에 올바른 타 항목을 추가하도록 해야하며, 서브스크립으로부터 반환되는 요소의 타입에 대해 명확해야 한다.

이들 요구사항을 정의하기 위해 Container 프로토콜은 컨테이너가 가지는 요소의 타입을 참조하는 방법이 필요하며, 특정 컨테이너를 위해 알 필요가 없다. Container 프로토콜은 append 메소드에 어떤 값을 넘기는지 지정해야할 필요가 있으며, append 메소드는 Container의 요소 타입으로서 같은 타입을 가져야 한다. 그리고 값은 컨테이너의 요소 타입으로부터 같은 타입인 컨테이너의 서브스크립트로부터 반환된다.

Container 프로토콜은 ItemType이라는 연관 타입을 선언하며, `typealias ItemType`으로 작서오딘다. 프로토콜은 `ItemType`이 어느 타입에 대한 별칭인지 선언하지 않는다. - 정보는 일치하는 타입이 제공되도록 남겨져야 한다. 그럼에도 불구하고 `ItemType` 별칭은 Container 안에 요소의 타입을 참조하고, append 메소드와 서브스크립트를 사용하기 위한 타입을 정의하고 Container 예상 행동을 강제하는 방법을 제공한다.

다음은 Container 프로토콜이 일치하고 도입된 구조체 예제이다.

	struct IntStack: Container {
	    // original IntStack implementation
	    var items = [Int]()
	    mutating func push(item: Int) {
	        items.append(item)
	    }
	    mutating func pop() -> Int {
	        return items.removeLast()
	    }
	    // conformance to the Container protocol
	    typealias ItemType = Int
	    mutating func append(item: Int) {
	        self.push(item)
	    }
	    var count: Int {
	        return items.count
	    }
	    subscript(i: Int) -> Int {
	        return items[i]
	    }
	}

IntStack 타입은 Container 프로토콜의 요구사항의 세가지를 구현하며, 개별적으로 IntStack 타입의 기존 기능에 만족하는 요구사항의 부분을 감싼다.

더나아가 IntStack은 Container의 구현을 정하며, 적합한 ItemType 은 Int 타입으로 사용된다. `typealias ItemType =  Int`의 정의는 ItemType의 추상 타입을 Container 프로토콜의 구현을 위해 Int의 구체화된 타입으로 바꾼다.

Swift의 타입 추론 덕분에, 실제로 Int의 구체화된 ItemType을 선언할 필요가 없다. IntStack은 Container 프로토클의 모든 요구사항을 일치하기 때문에, Swift는 적합한 ItemType을 추론하여 사용할 수 있다. append 메소드의 item 인자 타입과 서브스크립트의 반환 타입을 단순히 봐도 추론할 수 있다. 만약 `typealias ItemType = Int` 줄을 삭제한다고 하더라도, 여전히 작동하는데, 이는 ItemType이 명확하게 사용되기 때문이다.

제네릭 Stack 타입이 Container 프로토콜에 일치하도록 만들 수 있다.

	struct Stack<T>: Container {
	    // original Stack<T> implementation
	    var items = [T]()
	    mutating func push(item: T) {
	        items.append(item)
	    }
	    mutating func pop() -> T {
	        return items.removeLast()
	    }
	    // conformance to the Container protocol
	    mutating func append(item: T) {
	        self.push(item)
	    }
	    var count: Int {
	        return items.count
	    }
	    subscript(i: Int) -> T {
	        return items[i]
	    }
	}

자리표시 타입 인자 T는 append 메소드의 item 인자와 서브스크립트 반환 타입의 타입으로서 사용된다. 그러므로 Swift는 T가 특정 컨테이너를 위한 ItemType으로서 적합한 타입으로 사용하도록 추론할 수 있다.

#### 기존 타입에 연관 타입으로 지정하여 확장(Extending an Existing Type To Specify an Associated Type)

프로토콜에 일치하도록 추가하여 기존 타입을 확장할 수 있다. 

Swift의 배열 타입은 이미 append 메소드, count 속성 그리고 요소를 반환받기 위한 Int 인덱스를 사용하는 서브스크립트를 제공한다. 이들 세가지 기능은 Container 프로토콜의 요구사항과 일치한다. 배열은 Container 프로토콜을 도입하도록 선언한 것만으로도 일치하여 확장할 수 있다는 의미이다. 

	extension Array: Container {}

배열의 기존 append 메소드와 서브스크립트는 Swift가 ItemType을 위한 적절한 타입을 추론하여 사용하도록 한다. 확장 정의 뒤에 Container로서 배열을 사용할 수 있다.

### Where 절(Where Clauses)

타입 제약은 타입 인자에 요구사항에 제네릭 함수나 타입을 연관하여 정의할 수 있게 한다.

연관된 타입을 위한 요구사항을 정의하는데 유용할 수 있다. Where 절은 연관 타입이 특정 프로토콜에 일치하도록 특정 타입 인자와 연관 타입이 같게 필요하다. Where 절은 `where` 키워드를 타입 인자 목록 뒤에 위치하며, 연관 타입을 위한 하나 이상의 제약과 타입과 연관 타입 간의 하나 이상의 관계가 따른다.


다음은 두 개의 컨테이너가 같은 타입을 가짐을 확인하는 예제로, 타입 제약과 Where 절의 결합을 통해 제약조건을 표현하였다.

	func allItemsMatch<
	    C1: Container, C2: Container
	    where C1.ItemType == C2.ItemType, C1.ItemType: Equatable>
	    (someContainer: C1, anotherContainer: C2) -> Bool {
	        
	        // check that both containers contain the same number of items
	        if someContainer.count != anotherContainer.count {
	            return false
	        }
	        
	        // check each pair of items to see if they are equivalent
	        for i in 0..<someContainer.count {
	            if someContainer[i] != anotherContainer[i] {
	                return false
	            }
	        }
	        
	        // all items match, so return true
	        return true
	        
	}

someContainer 인자는 C1 타입이고, anotherContainer 인자는 C2 타입이다. C1과 C2는 자리 표시 타입 인자이며, 두 컨테이너 타입은 함수가 호출될 때 결정된다.

함수의 타입 인자 목록은 두 개의 타입 인자에 필요조건에 위치한다.

* C1은 Container 프로토콜에 일치해야 한다.(C1 : Container)
* C2는 Container 프로토콜에 일치해야 한다.(C2 : Container)
* C1의 ItemType은 C2의 ItemType과 일치해야 한다.(C1.ItemType == C2.ItemType)
* C1의 ItemType은 Equatable 프로토콜에 일치해야 한다.(C1.ItemType: Equatable)

세번쨰와 네번째 요구하항은 Where 절의 한 부분으로서 정의된다.

이들 요구사항은 다음과 같다.

* someContainer는 타입 C1의 container이다.
* anotherContainer는 타입 C2의 container이다.
* someContainer와 anotherContainer는 요소의 같은 타입을 포함한다.
* someContainer에 요소는 다른 요소들과 다르다는 것을 `!=`로 확인할 수 있다.

다음은 두 컨테이너가 일치하는지 찾는 예제이다.

	var stackOfStrings = Stack<String>()
	stackOfStrings.push("uno")
	stackOfStrings.push("dos")
	stackOfStrings.push("tres")
	 
	var arrayOfStrings = ["uno", "dos", "tres"]
	 
	if allItemsMatch(stackOfStrings, arrayOfStrings) {
	    println("All items match.")
	} else {
	    println("Not all items match.")
	}
	// prints "All items match."


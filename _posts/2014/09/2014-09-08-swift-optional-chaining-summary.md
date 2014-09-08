---
layout: post
title: "Swift - Optional Chaining 정리"
description: ""
category: "mac/ios"
tags: [swift, optional chaining, nil, question mark, exclamation mark, instance, class, unwrapping, property, method, subscript]
---
{% include JB/setup %}

## 옵셔널 체이닝(Optional Chaining)

옵셔널 체이닝은 옵셔널이 nil이 될 수 있는 속성, 메소드 그리고 서브스크립트를 조회하고 호출하는 과정. 값, 속성, 메소드 또는 서브스크립트를 포함하는 옵셔널이 성공적으로 호출하고, 옵셔널이 nil이면 속성, 메소드 또는 서브스크립트는 nil을 반환한다. 다중 질의는 같이 연쇄될 수 있고, 전체 연쇄 실패는 연쇄 안에서 특정 링크가 nil인 경우에 우아하게 실패한다.

<div class="alert-info">
	Swift에서 옵셔널 체이닝은 Objective-C에서 nil 메시지를 보내는 것과 유사하지만, 어떠한 타입이든 작업할 수 있으며 성공 또는 실패로 검사할 수 있다.
</div>

### 강제 언래핑 대안으로서 옵셔널 체이닝(Optional Chaining as an Alternative to Forced Unwrapping)

만약 옵셔널이 nil이 아니라면 호출하고자 하는 속성, 메소드 또는 서브스크립트의 옵셔널 값 뒤에 물음표(?)가 위치하여 옵셔널 채이닝을 지정한다. 매우 유사하게 옵셔널 값 뒤에 느낌표(!)가 위치하여 값을 강제 언래핑하도록 할 수 있다. 주된 차이점은 옵셔널 체이닝은 옵셔널이 nil이면 우아하게 실패할 수 있지만, 강제 언래핑은 옵셔널이 nil일 때 런타입 에러를 발생한다.

옵셔널 체이닝은 nil 값이 호출될 수 있는 사실을 반영하도록 옵셔널 체이닝의 결과는 항상 옵셔널 값을 호출해야 하고, 심지어 속성, 메소드 또는 서브스크립트는 옵셔널이 아닌 값을 반환하도록 질의한다. 옵셔널 체이닝이 성공적으로 호출했는지 연쇄에서 nil 값으로 성공하지 못했는지 옵셔널 반환 값을 검사하는데 사용할 수 있다.

특히, 옵셔널 체이닝의 결과는 옵셔널에 감싸진 예상되는 반환 값이 같은 타입이다. 속성은 일반적으로 `Int`는 옵셔널 체이닝으로 접근할 때 `Int?`로 반환한다.

다음은 옵셔널 체이닝이 강제 언래핑과 다른지 보여주는 예제임.

첫번째로, Person과 Residence라는 두 개의 클래스가 정의된다.

	class Person {
	    var residence: Residence?
	}
	 
	class Residence {
	    var numberOfRooms = 1
	}

Residence 인스턴스는 기본 값 1을 가지는 numberOfRooms라는 Int 속성을 하나 가진다. Person 인스턴스는 Residence? 타입의 옵셔널 residence 속성을 가진다.

Person 인스턴스를 새로 만든다면 residence 속성은 옵셔널의 특징으로 nil로 초기화된다. 

	let john = Person()

만일 residence 뒤에 느낌표(!)를 표시하여 값을 강제 언래핑하면 런타임 에러가 발생한다. 이는 residence에 값이 없기 때문이다.

	let roomCount = john.residence!.numberOfRooms
	// this triggers a runtime error

john.residence에 값이 nil이 아닌 값을 가져서 성공적이면 roomCount에 방 번호가 포함되어 저장된다. 하지만 residence에 nil이라면 항상 런타임 에러가 발생한다.

옵셔널 체이닝은 numberOfRooms의 값에 접근할 수 있는 대안을 제공하며, 옵셔널 체이닝을 사용하도록 느낌표 자리 대신 물음표 자리를 사용한다.

	if let roomCount = john.residence?.numberOfRooms {
	    println("John's residence has \(roomCount) room(s).")
	} else {
	    println("Unable to retrieve the number of rooms.")
	}
	// prints "Unable to retrieve the number of rooms."

numberOfRooms에 접근하려는 시도는 잠재적으로 실패하기때문에 옵셔널 체이닝은 Int? 또는 옵셔널 Int 타입의 값을 반환하도록 해야한다. residence는 nil일때 옵셔널 Int는 또한 nil이고, numberOfRooms에 접근할 수 없다는 사실을 반영한다.

numberOfRooms이 옵셔널 Int가 아닐지라도, 옵셔널 체인은 numberOfRooms가 항상 Int 대신 Int?를 반환한다.

Residence 인스턴스를 john.residence에 할당할 수 있는데 더 이상 nil 값을 가지지 않아서이다.

	john.residence = Residence()

john.residence는 nil 대신 실제 Residence 인스턴스를 가진다. 이전에 같은 옵셔널 체이닝으로 numberOfRooms로 접근을 한다면 이제는 numberOfRooms에 값 1을 가지는 Int?를 반환한다.

	if let roomCount = john.residence?.numberOfRooms {
	    println("John's residence has \(roomCount) room(s).")
	} else {
	    println("Unable to retrieve the number of rooms.")
	}
	// prints "John's residence has 1 room(s)."

### 옵셔널 체이닝을 위한 모델 클래스 정의(Defining Model Classes for Optional Chaining)

속성, 메소드 그리고 서브스크립트를 한 단계 이상 깊이 호출하는 옵셔널 체이닝을 사용할 수 있다. 연관된 타입의 복잡한 모델 안으로 서브속성을 뚫어서 서브속성에 속성, 메소드 그리고 서브스크립트에 접근 가능한지 확인하는 것이 가능하다.

이전에는 다음과 같은 방법으로 Person 클래스가 정의되었다.

	class Person {
	    var residence: Residence?
	}

Residence 클래스는 이전보다 더 복잡해지는데, rooms라는 [Room] 타입의 초기화된 빈 배열 변수 속성을 정의한다.

	class Residence {
	    var rooms = [Room]()
	    var numberOfRooms: Int {
	        return rooms.count
	    }
	    subscript(i: Int) -> Room {
	        get {
	            return rooms[i]
	        }
	        set {
	            rooms[i] = newValue
	        }
	    }
	    func printNumberOfRooms() {
	        println("The number of rooms is \(numberOfRooms)")
	    }
	    var address: Address?
	}

Residence의 버전은 Room 인스턴스의 배열을 저장하며, numberOfRooms 속성은 저장 속성이 아니라 계산 속성으로서 구현된다. 계산 numberOfRooms 속성은 rooms 배열로부터 count 속성의 값을 단순히 반환한다.

rooms 배열에 접근하는 단축키로서 읽기-쓰기 서브스크립트는 rooms 배열에 요청한 인덱스의 방을 접근하도록 가능한 버전이다. printNumberOfRooms라는 메소드는 residence에 방 번호를 출력한다. 마지막으로 Residence는 address라는 옵셔널 속성을 정의하며 Address? 타입을 가진다. 

Room 클래스는 name이라는 속성을 가지고 이니셜라이저가 방 이름으로 속성을 설정한다.

	class Room {
	    let name: String
	    init(name: String) { self.name = name }
	}

Address 클래스는 String? 타입의 세 개 옵셔널 속성을 가진다. 두 개의 속성 buildingName과 buildingNumber는 주소의 부분으로서 특정 빌딩을 식별하기 위한 대안 방법이다. 세번째 속성 street는 주소에 거리 이름이 사용된다.

	class Address {
	    var buildingName: String?
	    var buildingNumber: String?
	    var street: String?
	    func buildingIdentifier() -> String? {
	        if buildingName != nil {
	            return buildingName
	        } else if buildingNumber != nil {
	            return buildingNumber
	        } else {
	            return nil
	        }
	    }
	}

Address는 buildingIdentifier라는 메소드가 String? 타입을 반환한다. 이 메소드는 buildingName과 buildingNumber 속성을 확인하고 buildingName 또는 buildingNumber을 반환한다.

### 옵셔널 체이닝을 통한 속성 접근(Accessing Properties Through Optional Chaining)

옵셔널 값에 속성을 접근하고, 속성 접근이 성공한지 검사하도록 옵셔널 체이닝을 사용할 수 있다.

	let john = Person()
	if let roomCount = john.residence?.numberOfRooms {
	    println("John's residence has \(roomCount) room(s).")
	} else {
	    println("Unable to retrieve the number of rooms.")
	}
	// prints "Unable to retrieve the number of rooms."

이는 john.residence가 nil이기 때문에 옵셔널 체이닝이 실패한다.

또한 옵셔널 체이닝을 통해 속성의 값을 설정할 수 있다.

	let someAddress = Address()
	someAddress.buildingNumber = "29"
	someAddress.street = "Acacia Road"
	john.residence?.address = someAddress

john.residence의 address 속성을 설정할 수 있는데 이는 john.residence가 nil이기 때문이다.

### 옵셔널 체이닝을 통한 메소드 호출(Calling Methods Through Optional Chaining)

옵셔널 값에 메소드를 호출하거나 메소그 호출하여 성공한지 검사하기 위해 옵셔널 체이닝을 사용한다. 메소드는 반환 값을 정의하지 않더라도 말이다. 

printNumberOfRooms 메소드는 Residence 클래스에서 numberOfRooms의 현재 값을 출력한다.

	func printNumberOfRooms() {
	    println("The number of rooms is \(numberOfRooms)")
	}

이 메소드는 암시적인 Void 반환 타입을 가진다. 만약 옵셔널 체이닝으로 옵셔널 값을 메소드로 호출하면 메소드는 Void가 아닌 Void?를 반환하는데 이는 옵셔널 체이닝을 통해 호출할 때 항상 옵셔널 타입으로 반환한다. 따라서 반환 값이 없는 메소드인 printNumberOfRooms이라도 옵셔널 체이닝을 통해 호출이 가능하다.

	if john.residence?.printNumberOfRooms() != nil {
	    println("It was possible to print the number of rooms.")
	} else {
	    println("It was not possible to print the number of rooms.")
	}
	// prints "It was not possible to print the number of rooms."

옵셔널 체이닝을 통해서 속성에 값을 할당할 수 있다.

	if (john.residence?.address = someAddress) != nil {
	    println("It was possible to set the address.")
	} else {
	    println("It was not possible to set the address.")
	}
	// prints "It was not possible to set the address."

### 옵셔널 체이닝을 통한 서브스크립트 접근(Accessing Subscript Through Optional Chaining)

옵셔널 체이닝은 서브스크립트로부터 옵셔널 값으로 속성의 값을 설정하고 받으며 성공적인지 검사할 수 있다.

<div class="alert-info">
	옵셔널 체이닝을 통한 옵셔널 값에 서브스크립트를 접근할 때, 서브스크립트 괄호 전에 물음표를 붙인다. 옵셔널 체이닝 물픔표는 항상 옵셔널 표현 뒤에 바로 붙는다.
</div>

john.residence 속성의 rooms 배열에 첫번째 방 이름을 받는 예제로 Residence 클래스에 정의된 서브스크립트를 사용한다. john.residence는 현재 nil이고 서브스크립트는 호출하면 실패된다.

	if let firstRoomName = john.residence?[0].name {
	    println("The first room name is \(firstRoomName).")
	} else {
	    println("Unable to retrieve the first room name.")
	}
	// prints "Unable to retrieve the first room name."

서브스크립트 안에서 옵셔널 체이닝 물음표는 john.residence 바로 뒤에, 서브스크립트 괄호 전에 위치하는데 이는 john.residence가 옵셔널 값이기 때문에 옵셔널 체이닝을 시도할 수 있다.

유사하게 옵셔널 체이닝을 가진 서브스크립트를 통해서 새로운 값을 설정할 수 있다.

	john.residence?[0] = Room(name: "Bathroom")

설정해서 실패하는데, 이유는 residence가 nil이기 때문이다.

john.residence에 실제 Residence 인스턴스를 만들고 할당하면, 옵셔널 체이닝을 통해서 rooms 배열에 실제 항목을 서브스크립트로 접근하여 사용할 수 있다.

	let johnsHouse = Residence()
	johnsHouse.rooms.append(Room(name: "Living Room"))
	johnsHouse.rooms.append(Room(name: "Kitchen"))
	john.residence = johnsHouse
	 
	if let firstRoomName = john.residence?[0].name {
	    println("The first room name is \(firstRoomName).")
	} else {
	    println("Unable to retrieve the first room name.")
	}
	// prints "The first room name is Living Room."

#### 옵셔널 타입의 서브스크립트 접근(Accessing Subscripts of Optional Type)

만약 서브스크립트가 옵셔널 타입 값을 반환하면 서브스크립트 괄호 닫힌 후에 물음표를 사용하여 옵셔널 반환 값으로 연쇄하도록 한다.

	var testScores = ["Dave": [86, 82, 84], "Tim": [79, 94, 81]]
	testScores["Dave"]?[0] = 91
	testScores["Tim"]?[0]++
	testScores["Brian"]?[0] = 72
	// the "Dave" array is now [91, 82, 84] and the "Tim" array is now [80, 94, 81]

### 체이닝의 여러 단계 연결(Linking Multiple Levels of Chaining)

모델 안에 속성, 메소드 그리고 서브스크립트를 파고 들어가서 옵셔널 체이닝의 여러 단계로 연결할 수 있다. 옵셔널 체이닝의 여러 단계는 반환 값에 더 많은 옵셔널 단계를 추가할 수 없다.

* 받는 타입이 옵셔널이 아니라면, 옵셔널 체이닝으로 인해 옵셔널로 되어야 한다.
* 받는 타입이 이미 옵셔널이라면 옵셔널 체이닝으로 더이상 옵셔널이 되지 않는다.

그러므로

* 옵셔널 체이닝으로 Int 값을 받으려고 한다면 항상 Int?로 반환받으며, 많은 체이닝의 단계가 사용되었는지 상관없다.
* 비슷하게 옵셔널 체이닝으로 Int? 값을 받으려고 한다면 항상 Int?로 받환받으며, 많은 체이닝의 단계가 사용되었는지 상관없다.

john의 residence 속성에 address 속성에 street 속성에 접근하려면 옵셔널 체이닝을 통해 접근할 수 있다.

	if let johnsStreet = john.residence?.address?.street {
	    println("John's street name is \(johnsStreet).")
	} else {
	    println("Unable to retrieve the address.")
	}
	// prints "Unable to retrieve the address."

john.residence가 유효한 Residence 인스턴스를 가지는데 john.residence.address가 nil이면 john.residence?.address?.street는 실패한다. 만약 nil이 아니고 유효한 값을 가진다면 street의 문자열을 반환하고 nil이 아니기 때문에 street의 이름이 출력된다.

### 옵셔널 반환 값을 가진 메소드에서 체이닝(Chaining on Methods With Optional Return values)

다음은 Address 클래스의 buildingIdentifier 메소드는 옵셔널 체이닝을 통해서 호출되는 예제로 String? 타입의 값을 반환한다. 따라서 최종적인 메소드의 반환 타입은 홉셔널 체이닝이 String? 뒤에 호출된다.

	if let buildingIdentifier = john.residence?.address?.buildingIdentifier() {
	    println("John's building identifier is \(buildingIdentifier).")
	}
	// prints "John's building identifier is The Larches."

만일 메소드 반환 값에 옵셔널 체이닝을 동작하길 원하면 옵셔널 체이닝 물음표를 메소드 괄호 뒤에 위치하게 한다.

	if let beginsWithThe =
	    john.residence?.address?.buildingIdentifier()?.hasPrefix("The") {
	        if beginsWithThe {
	            println("John's building identifier begins with \"The\".")
	        } else {
	            println("John's building identifier does not begin with \"The\".")
	        }
	}
	// prints "John's building identifier begins with "The"."

<div class="alert-info">
	옵셔널 체이닝 물음표가 괄호 뒤에 위치하는데, 이는 옵셔널 값이 buildingIdentifier 메소드의 반환 값에 옵셔널 체이닝이지만 buildingIdentifier 메소드 자체가 아니기 때문이다.
</div>
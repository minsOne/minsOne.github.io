---
layout: post
title: "[Swift]Enumerations 정리"
description: ""
category: "mac/ios"
tags: [swift, enumeration, if, raw value, toRaw, fromRaw, associated value, member, switch]
---
{% include JB/setup %}

## 열거형(Enumerations)

열거형은 관련 있는 값들의 그룹에 대한 일반적인 타입으로 정의되며 코드 내에 이들 값이 타입-안전 방법으로 작업하는 것이 가능함.

C 언어와 친하다면 C 열거형은 관련있는 이름에 정수 값을 할당함. Swift 열거형은 매우 유연하며, 열거형 각 숫자마다 값을 제공할 필요가 없음. 만약 각 열거형 항목에 값(원시 값)이 제공된다면, 그 값은 문자열, 문자, 정수나 부동 소수점 타입의 값일 수 있음.

또한, 열거형 항목은 각각 다른 항목 값을 연관되는 타입의 값으로 저장하여 지정할 수 있음. 열거형의 한 부분으로서 연관된 항목의 일반적인 집합으로 정의할 수 있으며, 각각의 열거자는 적당한 타입의 값들의 다양한 집합을 가짐.

Swift에 열거자는 일급-클래스 타입이며 많은 특징들이 적용되는데, 전통적으로 열거형의 현재 값에 대한 추가적인 정보를 제공하는 계산된 속성과 열거형이 표시하는 값들과 연관된 기능들을 제공하는 인스턴스 메소드로 지원함. 열거형은 또한 초기화한 멤버 값을 제공하는 초기화(initializer)를 정의하고, 원래 구현을 넘어서 기능을 확장할 수 있으며, 표준 기능을 제공하기 위한 프로토콜을 따름.


### 열거형 문법

`enum` 키워드를 사용하여 열거형을 선언하는 일반적인 형태

	enum SomeEnumeration {
	    // enumeration definition goes here
	}

나침반의 네 개의 주요 위치를 가진 열거형 예제.

	enum CompassPoint {
	    case North
	    case South
	    case East
	    case West
	}

열거형(North, South, East, West)에 정의된 값은 열거형의 멤버 값(또는 멤버). `case` 키워드는 멉버 값의 새 줄이 정의될 것을 나타냄.

<div class="alert-info">
C와 Objective-C와는 다르게, Swift 열거형 멤버는 생성시 기본 정수 값을 할당하지 않음. CompassPoint 예제에서 North, South, East, West는 명시적으로 0, 1, 2, 3과는 같지 않음. 대신에 다른 열거형 멤버는 명시적으로 CompassPoint 타입으로 정의되어 완벽하게 갖춘 값임.
</div>

여러 멤버 값은 콤마로 분리되어 한줄로 나타낼 수 있음.

	enum Planet {
	    case Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus, Neptune
	}

각 열거형 정의는 새로운 타입 종류로 정의. Swift에 다른 타입과 마찬가지로 열거형 이름(CompassPoint, Planet)은 대문자로 시작해야 함. 열거형 타입은 복수형 이름보다 단수형 이름으로하여 읽기 쉽게 함.

	var directionToHead = CompassPoint.West

directionToHead 타입은 CompassPoint의 가능한 값 중 하나로 초기화될 때 추론함. directionToHead은 CompassPoint로 선언되면, 짧게 점(.) 구문을 사용하여 다른 CompassPoint 값으로 설정할 수 있음.

	directionToHead = .East

directionToHead의 타입은 이미 알려져 있어, 값을 설정할 때 표시하지 않을 수 있음. 이는 명시적으로 타입 열거형 값으로 작업할 때 높은 가독성 코드를 만듬.

### 열거형 값과 스위치 문 일치하기(Matching Enumeration Values With a Switch Statement)

각 열거형 값과 switch 문과 일치시킬 수 있음.

	directionToHead = .South
	switch directionToHead {
	case .North:
	    println("Lots of planets have a north")
	case .South:
	    println("Watch out for penguins")
	case .East:
	    println("Where the sun rises")
	case .West:
	    println("Where the skies are blue")
	}

위의 코드를 다음과 같이 읽을 수 있음. "directionToHead 값을 생각해봅시다.  .North값과 같은 경우라면 'Lots of planets have a north'라고 출력이 되며 .South와 같다면 'Watch out for penguins'를 출력한다."

제어 흐름 항목에서 설명한 switch 문은 열거형 멤버를 고려할 때 완전히 해야함. .West가 생략된 경우라면 코드는 컴파일 하지 않는데, 이는 CompassPoint 멤버의 완전한 목록을 고려하지 않았기 때문임. 완전한 열거형 멤버들의 보장 필요성은 실수로 생략하는 것을 막음.

모든 열거형 멤버를 case로 표시할 필요가 없다면, default 경우를 제공하여 명시적으로 언급되지 않은 멤버들을 포괄함.

	let somePlanet = Planet.Earth
	switch somePlanet {
	case .Earth:
	    println("Mostly harmless")
	default:
	    println("Not a safe place for humans")
	}
	// prints "Mostly harmless"

### 연관 값

이전 항목의 예제에서 열거형 멤버가 어떻게 정의되었는지를 보여주었음. 상수 및 변수가 Planet.Earth 값으로 설정할 수 있고, 나중에 이 값을 검사할 수도 있음. 그러나 때론 멤버 값들과 함께 연관된 다른 타입의 값을 저장하는데 유용함. 이는 추가적인 사용자 정보를 멤버 값과 함께 저장하도록 하며, 코드 안에서 멤버가 매번 그 정보를 변경하도록 하용함.

특정 주어진 타입의 연관된 값을 저장하는 Swift 열거형으로 정의하며, 필요할 경우 열거형의 각 멤버에 따라 다른 값 타입이 다를 수 있음. 열거형은 차별화된 공용체(discriminated unions)와 태그된 공용체(tagged unions) 또는 변형체(variants)로 다른 언어에 알려져 있음.

예를 들어 두개의 다른 바코드 타입으로 부터 상품을 추적하는 재고 추적 시스템이 필요있다고 가정함. 어떤 제품은 0부터 9까지 숫자를 사용하는 UPC-A 형식의 1D 바코드로 꼬리표를 붙이임. 각각의 바코드는 "번호 체계" 숫자를 가지는데 다섯자리 "제조사 코드" 숫자와 다섯자리 "상품 코드" 숫자임. 이들 숫자 뒤에 각 코드가 제대로 확인되었는지 검증하기 위한 코드인 "확인"숫자를 붙임.

<img src="/../../../../image/2014/08/barcode_UPC_2x.png" alt="barcode_UPC" style="width: 400x;"/><br/>	

다른 상품은 ISO 8859-1 문자가 사용가능한 2,953 글자 길이를 가지는 QR 코드 형식의 2D 바코드 꼬리표를 붙임.


<img src="/../../../../image/2014/08/barcode_QR_2x.png" alt="barcode_QR" style="width: 400x;"/><br/>

재고 추적 시스템은 4개의 정수인 튜플로서 UPC-A 바코드를 저장하고 임의의 길이의 문자열로 QR 코드 바코드를 저장하면 편할 것임.

Swift에서 각 유형 제품의 바코드를 정의하는 열거형은 다음과 같이 보여질 것임.

	enum Barcode {
	    case UPCA(Int, Int, Int, Int)
	    case QRCode(String)
	}

이것은 다음과 같이 읽을 수 있음. "Barcode로 불리는 열거형 정의는 (Int, Int, Int, Int) 타입의 UPCA값이거나 문자열 타입의 QRCode이다."

이 정의는 실제로 정수나 문자열 값을 주지 않음. 단지 바코드 상수 및 변수들이 Barcode.UPCA 또는 Barcode.QRCode 중 하나와 같을 때, 그와 연관된 값들의 타입만 정의

새로운 바코드는 두가지 타입 중 하나로 만들어짐.

	var productBarcode = Barcode.UPCA(8, 85909, 51226, 3)

productBarcode로 불리는 새로운 변수를 만들고 Barcode.UPCA에 (8, 85909, 51226, 3)의 튜플 값을 할당함.

같은 제품은 다른 바코드의 타입으로 할당 할 수 있음.

	productBarcode = .QRCode("ABCDEFGHIJKLMNOP")

이때, 원래 Barcode.UPCA와 정수 값은 새로운 Barcode.QRCode의 문자열 값으로 치환됨. Barcode 타입의 상수와 변수는 .UPCA나 QRCode로 저장할 수 있으나 한번에 둘 중 하나만 저장할 수 있음.

이전에 다른 바코드 타입은 switch문을 사용하여 검사할 수 있었음. 그러나 이제는 연관된 값들은 switch문의 일부로 나올 수 있는데, 상수(접두사로 let)이나 변수(접두사로 var)로서 각각 연관된 값은 switch 경우 내에 사용되도록 내 보낼 수 있음.

	switch productBarcode {
	case .UPCA(let numberSystem, let manufacturer, let product, let check):
	    println("UPC-A: \(numberSystem), \(manufacturer), \(product), \(check).")
	case .QRCode(let productCode):
	    println("QR code: \(productCode).")
	}
	// prints "QR code: ABCDEFGHIJKLMNOP."

열거형에 모든 연관 값이 상수 또는 변수로 내보낸다면 멤버 이름 앞에 var또는 let으로 표시할 수 있음.

	switch productBarcode {
	case let .UPCA(numberSystem, manufacturer, product, check):
	    println("UPC-A: \(numberSystem), \(manufacturer), \(product), \(check).")
	case let .QRCode(productCode):
	    println("QR code: \(productCode).")
	}
	// prints "QR code: ABCDEFGHIJKLMNOP."

### 원시 값(Raw Values)

앞에서의 바코드 예제는 다른 타입의 연관 값을 저장하는 열거형 멤버의 정의를 보여줌.  열거형 멤버는 모든 타입에 기본 값을 미리 입력할 수 있음.

다음은 원시 ASCII 값을 열거형 멤버에 저장하는 예제.

	enum ASCIIControlCharacter: Character {
	    case Tab = "\t"
	    case LineFeed = "\n"
	    case CarriageReturn = "\r"
	}

ASCIIControlCharacter 열거형의 원시 값은 Character 타입으로 정의되며 더 일반적인 ASCII 제어 문자로 설정되었음.

원시 값은 연관 값과 같지 않음. 원시 값는 열거형을 코드에 처음 정의할 때 미리 값을 설정함. 특정 열거형 멤버의 원시 값은 항상 동일함. 연관 값은 열거형의 멤버 중 하나에 기초로 하여 새로운 상수와 변수를 생성할 때 설정되며, 이는 무엇을 하느냐에 따라 매번 다름.

원시 값은 문자열, 문자, 정수, 부동 소수점 타입이 가능함. 각 원시 값은 열거형 정의 안에 유일해야 함. 원시 값에 정수를 사용했다면 열거형 멤버의 일부가 아무런 값도 설정되지 않은 경우 자동 증가함.

아래의 열거형은 앞선 Planet 열거형을 재 정의한 것임.

	enum Planet: Int {
	    case Mercury = 1, Venus, Earth, Mars, Jupiter, Saturn, Uranus, Neptune
	}

자동 증가는 Planet.Venus는 원시 값 2를 갖는 식으로 의미함.

열거형 멤버의 `toRaw` 메소드를 가지고 원시 값을 접근함.

	let earthsOrder = Planet.Earth.toRaw()
	// earthsOrder is 3

열거형 `fromRaw` 메소드를 사용하여 특정 원시 값의 열거형 멤버를 찾을 수 있음. 다음은 원시 값 7을 통해 Uranus를 찾는 예제.

	let possiblePlanet = Planet.fromRaw(7)
	// possiblePlanet is of type Planet? and equals Planet.Uranus

모든 Int 값에 맞는 planet을 찾을 수 있는 것은 아님. 만약 `fromRaw` 메소드는 옵셔널 열거형 멤버를 반환함. 다음은 Planet? 타입의  possiblePlanet 또는 옵셔널 Planet를 나타내는 예제.

만약 9번째 위치에 있는 Planet을 찾는다면 fromRaw를 통한 옵셔널 Planet 값은 
nil을 반환함.

	let positionToFind = 9
	if let somePlanet = Planet.fromRaw(positionToFind) {
	    switch somePlanet {
	    case .Earth:
	        println("Mostly harmless")
	    default:
	        println("Not a safe place for humans")
	    }
	} else {
	    println("There isn't a planet at position \(positionToFind)")
	}
	// prints "There isn't a planet at position 9"

옵셔널 바인딩 예제는 원시 값 9로 행성을 접근하려고 함. `if let somePlanet = Planet.fromRaw(9)` 구문은 옵셔널 Planet을 받고, 만약 값을 받으면 somePlanet에 옵셔널 Planet 내용을 설정함. 이 경우에는 9번째 위치한 행성을 주지 못하므로, else 부분에서 대신 실행함.

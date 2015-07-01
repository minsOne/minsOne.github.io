---
layout: post
title: "Enumeration를 이용한 Error Handling in Swift"
description: ""
category: "Mac/iOS"
tags: [swift, generic, enum, enumeration, switch, case, box, class]
---
{% include JB/setup %}

### Enumeration

Swift에서 Enum을 사용할 때 연관된 값(Associated Values)을 통해서 연관된 다른 타입의 값을 저장할 수 있습니다.

다음은 애플 문서에 작성 예제입니다. 

	enum Barcode {
	    case UPCA(Int, Int, Int, Int)
	    case QRCode(String)
	}

	// 방법 1
	switch productBarcode {
	case .UPCA(let numberSystem, let manufacturer, let product, let check):
	    println("UPC-A: \(numberSystem), \(manufacturer), \(product), \(check).")
	case .QRCode(let productCode):
	    println("QR code: \(productCode).")
	}
	// prints "QR code: ABCDEFGHIJKLMNOP."

	// 방법 2
	switch productBarcode {
	case let .UPCA(numberSystem, manufacturer, product, check):
	    println("UPC-A: \(numberSystem), \(manufacturer), \(product), \(check).")
	case let .QRCode(productCode):
	    println("QR code: \(productCode).")
	}
	// prints "QR code: ABCDEFGHIJKLMNOP."

위의 코드에서 Switch를 통해 우선 바코드 값이 UPCA인지, QRCode인지를 나눌 수 있고, 각 case에 따라 저장된 값을 출력합니다. 

이를 이용하여 제네릭을 함께 사용하면 동작 수행 후 결과가 성공 또는 실패 그리고 각 enum에는 정보가 저장되는 코드를 작성할 수 있습니다.

	enum Result<T> {
	  case Success(T)
	  case Failure(NSError)
	}	

위의 코드에서 Success와 Failure는 제네릭을 통해 각기 다른 타입의 데이터를 저장할 수 있게 됩니다. 그리고 switch 문을 통해서 Success, Failure 구분하여 결과를 달리 처리할 수 있습니다.

	let result = Result.Success("I got it")
	switch result {
		case let .Success(value):
			return "Success : \(value)"
		case let .Failure(err):
			return "Error : \(err)"
	}

	// prints "Success : I got it"

만약 위의 Swift 1.0을 사용하고 있다면 위의 코드가 컴파일되지 않을 것입니다. Swift 1.2에서 정상적으로 되며, Swift 1.0에서 다음과 같은 방법을 사용할 수 있습니다.

	final class Box<T> {
	    let value: T
	     
	    init(value: T) {
	        self.value = value
	    }
	}
	 
	enum Result<T> {
	    case Success(Box<T>)
	    case Failure(NSError)
	}

	let result = Result.Success(Box(value: "hello"))

	switch result {
	    case .Success(let box):
	        println(box.value)
	    case .Failure(let error):
	        println(error.description)
	}

	// prints "hello"

### 정리

enum에 값이 저장되는 특성을 이용한 위와 같은 방법을 사용할 수 있었습니다. 이러한 방식은 Rust에서도 쓰이고 있고, 이러한 형태를 지원하는 언어들에서는 일반적으로 사용하는 방법이지 않나 합니다. 

많은 결과에 대한 분기를 처리할 수 있어 좀 더 나은 코드를 작성할 수 있을 것으로 생각됩니다.

### 참고 자료

* [Swift - Enumerations 정리(한글)][minsone]
* [Swift - Enumerations 원문][Apple_Doc_Enumerations]
* [Swift: Putting Your Generics in a Box][Natasha The Robot]
* [Thoughts on Swift 2 Errors][Gist]

[minsone]: ../swift-enumerations-summary/
[Apple_Doc_Enumerations]: https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Enumerations.html#//apple_ref/doc/uid/TP40014097-CH12-ID148
[Natasha The Robot]: http://natashatherobot.com/swift-generics-box/
[Gist]: https://gist.github.com/nicklockwood/21495c2015fd2dda56cf
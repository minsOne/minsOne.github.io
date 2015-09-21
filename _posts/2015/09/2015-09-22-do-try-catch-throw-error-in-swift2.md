---
layout: post
title: "[Swift]Error handling in Swift2 - Try/Throw/Catch/ErrorType"
description: ""
category: "Mac/iOS"
tags: [swift, swift2, do, try, catch, throw, throws, error, errortype, enum, case, where]
---
{% include JB/setup %}

### Swift2

Swift 2에서 에러를 던지고 받을 수 있습니다. 기존 Objective-C에서도 지원이 되었지만, Swift2에서는 ErrorType을 확장하여 사용할 수 있습니다. 즉, 유저가 Custom Error를 던지고, 받을 수 있게 된 것이죠.

### Try, Throw, Catch, ErrorType

Swift2에서는 다음과 같이 Custom Error를 구현할 수 있습니다.

	enum CheckError {
		case A
		case B
		case C
	}

	extension CheckError: ErrorType { }

	// or 

	enum CheckError: ErrorType {
		case A
		case B
		case C
	}

각 코드 작성 규칙에 따라 enum으로 작성하고 extension으로 확장하는 방법과, 처음부터 ErrorType 프로토콜을 받는 방법이 있습니다.

Error를 던지기 위해서는 함수 선언부에 `throws`를 표시해야 하며, `throw`로 Error를 던집니다.

	func t2() throws -> Bool {
		throw CheckError.C
	}

하지만 return 값으로 Bool 타입을 반환하도록 선언하였지만, Error를 던지고 함수가 종료됩니다. 따라서 위의 코드는 정상적인 코드입니다.

t2 함수는 Error를 던지도록 해주는 함수이므로, 함수 호출하는 부분 앞에 try를 붙입니다.

	try t2()

t2 함수에서 Error를 던지므로 Error를 받기위해 do-try-catch문을 통해 에러를 받을 수 있습니다.

	do {
		try t2()
	} catch {
		print(error)
	}

catch에서 각 Error에 따라 다르게 호출할 수 있도록 할 수 있습니다.

	do {
		try t2()
	} catch CheckError.A {
		print("CheckError A")
	} catch CheckError.B {
		print("CheckError B")
	} catch CheckError.C {
		print("CheckError C")
	} catch {
		print(error)
	}

do-try-catch문을 통해서 내부에서 호출한 Error를 모두 관리할 수 있습니다. 즉, 중첩된 함수에서 Error를 던지더라도 가장 밖의 do-try-catch문에서 Error를 받을 수 있습니다.

	func t2() throws -> Bool {
		throw CheckError.C
	}

	func t1() throws -> Bool {
		return try t2()
	}

	do {
		try t1()
	} catch {
		print(error)
	}

여기까지가 기본적인 문법입니다. 조금 더 살펴보겠습니다.

### 좀 더 보기

#### Enum

Enum에 값을 넣어서 전달할 수 있습니다. Error를 던질때에도 사용할 수 있습니다.

	enum VendingMachineError: ErrorType {
		case InvalidSelection
		case InsufficientFunds(coinsNeeded: Int)
		case OutOfStock
	}

	func someFunction() throws -> Bool {
		throw VendingMachineError.InsufficientFunds(coinsNeeded: 5)
	}

	do {
		try someFunction()
	} catch VendingMachineError.InsufficientFunds(let coinsNeeded) where coinsNeeded < 5 {
		print("under 5")
	} catch VendingMachineError.InsufficientFunds(let coinsNeeded) where coinsNeeded == 5 {
		print("same 5")
	} catch VendingMachineError.InsufficientFunds(let coinsNeeded) where coinsNeeded == 5 {
		print("more 5")
	}

#### Error를 Optional Value로 변경

try?를 사용하여 Error 대신 nil로 값을 받습니다.

	let x = try? someFunction() // nil

또한, do-try-catch문을 통해서 값을 초기화 할 수 있습니다.

	let y: Bool?
	do {
		y = try someFunction()
	} catch {
		y = nil 	// nil
	}

위의 코드는 someFunction에서 Error를 던졌기 때문에, y값을 nil로 초기화 합니다.



#### defer

Swift2에서 `defer`라는 키워드가 추가되었습니다. defer는 함수가 끝나고 난 뒤 마지막으로 호출됩니다. 다음 코드를 살펴보면 좀 더 이해하기 쉽습니다.

	func isOpenFile(fileName: String) throws -> Bool {
		let file = fopen(fileName, "r")
		defer {
			fclose(file)
		}
		return file != nil ? true : false
	}

다음 코드를 살펴보면 defer는 파일을 닫는 기능을 수행합니다. 즉, defer는 함수가 끝난 뒤 호출됩니다. 또한, defer가 여러번 호출되면 나중에 호출된 defer가 먼저 호출되고, 처음에 호출된 defer가 마지막에 호출됩니다.

다음 코드를 통해 확인할 수 있습니다.

	func checkCondition(a: Bool, _ b: Bool) throws -> Bool {
		print("Checking A")
		guard a else { return false }
		defer {
			print("Closing A")
		}
		print("Checking B")
		guard b else { return false }
		defer {
			print("Closing B")
		}
		print("Finish")
		return true
	}

	try checkCondition(true, true)

	// Output
	Checking A
	Checking B
	Finish
	Closing B
	Closing A

#### Closure와 rethrows

Swift2에서 map, flapMap 함수등에서 다음과 같이 선언되어 있습니다.

	@rethrows public func map<T>(@noescape transform: (Self.Generator.Element) throws -> T) rethrows -> [T]
	@rethrows public func flatMap<T>(@noescape transform: (Self.Generator.Element) throws -> T?) rethrows -> [T]

Swift2에서는 Error를 던지는 Closure도 함수의 인자로 넣을 수 있습니다. 하지만 Closure를 인자로 넣을 경우, 함수의 throws는 rethrows로 변경됩니다. 이는 에러를 다시 던지도록 rethrows로 표시해야 합니다.

따라서 다음과 같이 선언하고 사용할 수 있습니다.

	func functionWithCallback(callback: () throws -> Int) rethrows {
		try callback()
	}

### 정리

이제 Custom Error를 정의하고 사용할 수 있게 되면서 코드의 복잡도는 좀 더 감소될 것으로 보입니다. 그러면서, Error에 대하 설계도 요구되며 적절한 Error 설계는 개발자를 춤추게 만듭니다.

이번에 [JailBrokenDector](https://github.com/0dayZh/JailbrokenDetector) 프로젝트를 Swift2로 [MOJailBrokenDector](https://github.com/minsOne/MOJailBrokenDector)프로젝트를 작성하면서 throw Error를 이용하니 코드의 이해도가 올라갔습니다.

### 참고자료

* [Apple Document](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Declarations.html#//apple_ref/doc/uid/TP40014097-CH34-ID351)
* [hackingwithswift](https://www.hackingwithswift.com/new-syntax-swift-2-error-handling-try-catch)
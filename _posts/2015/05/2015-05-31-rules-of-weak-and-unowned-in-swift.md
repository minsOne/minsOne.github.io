---
layout: post
title: "weak와 unowned 사용 방법 in Swift"
description: ""
category: "Mac/iOS"
tags: [swift, weak, unowned, reference cycle, reference, arc, nil, self, lazy]
---
{% include JB/setup %}

강력 순환 참조(Strong Reference Cycle)를 벗어나기 위해 약한 참조(weak reference)와 미소유 참조(unowned reference)를 사용합니다. 

이전 Objective-C를 사용할 때는 강력 참조와 약한 참조를 통해서 참조 계수(reference count)를 다루었습니다. 그러나 Swift가 익숙하지 않아 미소유 참조에 대해 잘 몰랐습니다. 그래서 `weak`와 `unowned`를 언제 사용해야 하는지 다시 정리해보았습니다.

### weak와 unowned

#### Optional

`weak`와 `unowned`의 차이점은 옵셔널이냐 옵셔널이 아니냐의 차이입니다. 즉, `unowned`는 값이 있음을 가정하고 사용하며, `unowned` 값이 nil이라고 한다면 크래쉬가 발생할 수 있습니다.

다음은 weak를 사용하는 코드입니다.

	class Person {
		let name: String
		init(name: String) { self.name = name }
		var apartment: Apartment?
		deinit { println("\(name) is being deinitialized") }
	}
	 
	class Apartment {
		let number: Int
		init(number: Int) { self.number = number }
		weak var tenant: Person?
		deinit { println("Apartment #\(number) is being deinitialized") }
	}

<br/>다음은 unowned를 사용하는 코드입니다.

	class Customer {
		let name: String
		var card: CreditCard?
		init(name: String) {
			self.name = name
		}
		deinit { println("\(name) is being deinitialized") }
	}
	 
	class CreditCard {
		let number: UInt64
		unowned let customer: Customer
		init(number: UInt64, customer: Customer) {
			self.number = number
			self.customer = customer
		}
		deinit { println("Card #\(number) is being deinitialized") }
	}

Apartment 클래스에서 tenant 변수는 옵셔널로 사용하기 때문에 순환 참조를 피하기 위해서는 `weak`로 사용합니다. CreditCard 클래스에서 customer 상수는 항상 값을 가지고 있어야 하므로 순환 참조를 피하고자 `unowned`로 사용합니다.

#### Lazy initialization

객체가 초기화된 후에 `Lazy`를 통해 사용하기 직전에 property 값을 초기화할 때, 클로저가 변수에 대해 값을 획득하기 때문에 순환 참조가 발생할 수 있습니다. 따라서 self에 접근하는 경우 self는 값이 있음을 가정하므로 `[unowned self]`를 사용하여 self에 대해 접근할 수 있습니다.

	class Car {
		var name: String

		lazy var greeting: String = {
			[unowned self] in
			return "Hello, \(self.name)"
		}()

		init(name: String) {
			self.name = name
		}
	}

### 참고 자료

* [stackoverflow](http://stackoverflow.com/a/24320474)
* [Swift - Automatic Reference Counting 정리](../swift-automatic-reference-counting-summary/)
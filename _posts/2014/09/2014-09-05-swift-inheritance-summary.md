---
layout: post
title: "Swift - inheritance 정리"
description: ""
category: "mac/ios"
tags: [swift, class, superclass, subclass, inheritance, base class, override, property, subscript, super, getter, setter, instance, final]
---
{% include JB/setup %}

## 상속(inheritance)

클래스는 메소드, 속성 그리고 다른 클래스로부터 다른 특징을 상속받음. 다른 클래스로부터 상속받으면, 상속 클래스는 서브클래스(subclass)라고 하며, 이 클래스를 상속 해주는 클래스는 슈퍼클래스(superclass)라고 함. Swift에서 상속은 다른 타입의 클래스와 차별하기 위한 기본적인 방법임.

Swift에서 클래스는 상위 클래스에 속한 메소드, 속성 그리고 서브스크립트를 호출하고 접근할 수 있고, 해당 메소드, 속성 그리고 서브스크립트의 행동을 재정의하거나 수정하도록 오버라이딩을 지원함. Swift는 오버라이드 정의가 일치하는 슈퍼클래스 정의를 가지는지 확인하여 오버라이드가 정확하게 되었음을 보장하도록 도와줌.

<div class="alert-info">
클래스는 또한 속성 감시자를 상속받은 속성에 추가하여 속성의 값이 바뀔때 순서대로 통지함. 속성 감시자는 저장 또는 계산 속성에서 정의되어 있는지 상관없이 모든 속성에 추가할 수 있음.
</div>

### 기반 클래스 정의(Defining a Base Class)

다른 클래스로부터 상속받지 않은 클래스를 기반 클래스라고 함.

Swift 클래스는 보편적인 기반 클래스로부터 상속받지 않음. 지정한 슈퍼 클래스가 없으면 클래스는 자동으로 기반 클래스가 됨.

아래 예제에서 Vehicle이라는 기반 클래스를 정의하는데, 이 클래스는 currentSpeed라는 저장 속성으로 기본 값이 0.0으로 정의됨. currentSpeed 속성의 값은 description이라는 문자열 타입의 읽기 전용 속성이 사용하며 Vehicle의 설명을 반환함.

Vehicle 기반 클래스는 makeNoise라는 메소드를 정의하는데, 기반 Vehicle 인스턴를 위한 어떠한 행동도 하지 않지만 나중에 Vehicle의 서브클래스에서 바뀔것임.

	class Vehicle {
	    var currentSpeed = 0.0
	    var description: String {
	        return "traveling at \(currentSpeed) miles per hour"
	    }
	    func makeNoise() {
	        // do nothing - an arbitrary vehicle doesn't necessarily make a noise
	    }
	}

초기화 문법으로 새로 만든 Vehicle 인스턴스는 타입 명과 뒤에 빈 괄호로 작성됨.

	let someVehicle = Vehicle()

새로 만든 Vehicle 인스턴스는 description 속성을 접근하여 차의 현재 속도를 사람이 읽을 수 있는 설명으로 출력함.

	println("Vehicle: \(someVehicle.description)")
	// Vehicle: traveling at 0.0 miles per hour

Vehicle 클래스는 임의의 Vehicle의 일반적인 특징을 정의하지만, 그 자체로는 충분하지 않음. 더 유용하게 만들기 위해선 Vehicle의 더 많은 종류를 설명하도록 재 정의할 필요가 있음.

### 서브클래스(Subclassing)

서브클래스는 기존 클래스를 기반으로 새로운 클래스를 만드는 작업. 서브클래스는 기존 클래스로부터 특징을 상속받아 재정의할 수 있음. 서브클래스에 새로운 특징을 추가할 수도 있음.

서브클래스는 슈퍼클래스를 가지고 있음을 나타내기 위해 슈퍼클래스 이름 앞에 서브클래스 이름을 쓰고 콜론으로 분리함.

	class SomeSubclass: SomeSuperclass {
	    // subclass definition goes here
	}

다음은 Vehicle 슈퍼클래스를 가진 Bicycle이라는 서브클래스 정의 예제임.

	class Bicycle: Vehicle {
	    var hasBasket = false
	}

새로운 Bicycle 클래스는 자동적으로 currentSpeed와 description 속성 그리고 makeNoise 메소드인 Vehicle의 특징을 모두 얻음.

상속 특성에 추가하여 Bicycle 클래스는 기본 값 false를 갖는 새로운 저장 속성 hasBasket을 정의함.

기본적으로, 모든 새로운 Bicycle 인스턴스는 basket을 가지지 않을 것임. 인스턴스를 생성한 후에 특정 Bicycle 인스턴스의 hasBasket 속성에 true로 설정할 수 있음.

	let bicycle = Bicycle()
	bicycle.hasBasket = true

Bicycle 인스턴스의 상속받은 currentSpeed 속성을 변경할 수 있으며 인스턴스의 상속받은 description 속성을 조회할 수 있음.

	bicycle.currentSpeed = 15.0
	println("Bicycle: \(bicycle.description)")
	// Bicycle: traveling at 15.0 miles per hour

서브클래스는 스스로가 서브클래스화 할 수 있음. 다음은 Bicycle의 서브클래스임.

	class Tandem: Bicycle {
	    var currentNumberOfPassengers = 0
	}

Tandem은 Bicycle로부터 모든 속성과 메소드를 상속받고 Vehicle의 모든 속성과 메소드를 상속받음. 또한 Tandem 서브클래스는 기본값 0을 가지는 currentNumberOfPassengers라는 새로운 저장 속성을 추가함.

Tandem 인스턴스를 생성하면 상속받은 속성과 새로 만든 속성으로 작업할 수 있으며 그리고 Vehicle로부터 상속받은 읽기전용 description 속성을 조회 할 수 있음.

	let tandem = Tandem()
	tandem.hasBasket = true
	tandem.currentNumberOfPassengers = 2
	tandem.currentSpeed = 22.0
	println("Tandem: \(tandem.description)")
	// Tandem: traveling at 22.0 miles per hour

### 오버라이딩(Overriding)

서브클래스는 자신만의 인스턴스 메소드, 클래스, 메소드, 인스턴스 속성, 클래스 속성 또는 서브스크립트 구현하거나 그렇지 않으면 슈퍼클래스로부터 상속받음. 이것을 오버라이딩(override)이라고 함.

상속받은 특성을 오버라이드하기 위해선 `override` 키워드를 오버라이드 정의 앞에 작성함. 오실수로 일치하는 정의를 오버라이드하지 않기 않도록 명확하게 만드는 의도임. 오버라이딩 사고는 예상치 못한 행동을 야기하며, `override` 키워드가 없는 오버라이드는  컴파일시 에러로 진단함.

`override` 키워드는 Swift 컴파일러에 오버라이드하는 클래스의 슈퍼클래스가 오버라이드 선언한 것과 일치하는지 확인하도록 말함. 이러한 확인은 오버라이드 정의가 맞음을 보증함.

#### 슈퍼클래스 메소드, 속성 그리고 서브스크립트 접근(Accessing Superclass Methods, Properties, and Subscripts)

서브클래스를 위한 메소드, 속성 또는 서브스크립트에 오버라이드를 만들 때, 때때로 오버라이드의 한 부분으로서 기존 슈퍼클래스 구현을 사용하면 유용함. 기존 구현 행동을 재정의하거나 기존에 상속받은 변수에 변경된 값을 저장할 수 있음.

적절한 위치에 있다면, `super` 접두사를 사용하여 메소드, 속성 또는 서브스크립트의 슈퍼 클래스 버전을 접근함.

* `someMethod` 이름을 가진 오버라이드된 메소드는 someMethod의 슈퍼클래스 버전를 오버라이드하는 메소드 구현안에서 `super.someMethod()`로 호출할 수 있음.
* `someProperty`라는 오버라이드된 속성은 someProperty의 슈퍼클래스 버전을 오버라이드하는 getter 또는 setter 구현안에 `super.someProperty`로 접근할 수 있음.
* `someIndex`를 위한 오버라이드된 서브스크립트는 같은 서브스크립트의 슈퍼클래스 버전을 오버라이드하는 서브스크립트 구현안에 `super[someIndex]`로 접근할 수 있음.

#### 메소드 오버라이딩(Overriding Methods)

서브클래스 안에 특정 목적에 맞거나 대체하는 메소드 구현을 제공하기 위해 상속받은 인스턴스 또는 클래스 메소드를 오버라이드 할 수 있음.

Train이라는 Vehicle의 새로운 서브클래스를 정의하는 예제로, Vehicle에서 상속받은 Train은 makeNoise 메소드를 오버라이드함.

	class Train: Vehicle {
	    override func makeNoise() {
	        println("Choo Choo")
	    }
	}

#### 속성 오버라이딩(Overriding Properties)

자신만의 속성을 위한 getter와 setter을 지원하거나, 속성 값이 변경될 때 감시하기 위한 오버라이드 속성을 가능하도록 속성 감시자를 추가하도록 상속받은 인스턴스나 클래스 속성은 오버라이드 할 수 있음.

##### 속성 getter와 setter 오버라이딩(Overriding Property Getters and Setters)

특정 상속받은 속성을 오버라이드 하기 위한 사용자 getter(적합하다면 setter도)를 지원할 수 있으며, 상속받은 속성은 저장 또는 계산 속성으로서 이 구현됨. 상속받느 속성의 저장 및 구현 특성은 서브클래스는 알지 못하며, 상속받은 속성이 특정 이름과 타입만을 가지고 있다는 것만 알고 있음. 항상 오버라이딩 하는 속성의 타입과 이름만 지정해야 하며, 컴파일러는 슈퍼클래스 속성에 이름과 타입 똑같이 일치하는지 확인 할 수 있음.

서브클래스 속성을 오버라이읽기-쓰기 속성으로서 상속받은 읽기 전용 속성으로 줄 수 있음.

서브클래스 속성을 오버라이드할 때 getter와 setter를 제공하여 읽기-쓰기 속성으로서 상속받은 읽기전용 속성으로 나타낼 수 있음. 그러나 읽기전용 속성에서 상속받은 읽기-쓰기 속성으로는 나타낼 수 없음.

<div class="alert-info">
오버라이드 속성의 부분으로서 setter을 준다면, 오버라이드를 위한 getter을 줄 수 있음. 오버라이딩 getter안에 상속받은 속성의 값을 수정하길 원치 않는다면 상속받은 값에 getter로부터 <code>super.someProperty</code>를 반환하도록 넘겨줄 수 있으며, someProperty는 오버라이딩하는 속성 이름임.
</div>

다음은 Vehicle의 서브클래스로서 Car라는 새로운 클래스를 정의함. Car 클래스는 기본값 1을 가지는 gear라는 새로운 저장 속성을 나타냄. Car 클래스는 description 속성을 Vehicle로부터 오버라이드하여 현재 gear를 포함하는 사용자 description을 제공함.

	class Car: Vehicle {
	    var gear = 1
	    override var description: String {
	        return super.description + " in gear \(gear)"
	    }
	}

description 속성의 오버라이드는 super.description을 호출하는데, Vehicle 클래스의 description 속성을 반환함. Car 클래스의 description 버전은 현재 gear의 정보를 description 끝에 추가함. 

Car 클래스의 인스턴스를 만들고 gear와 currentSpeed 속성을 설정하면 Car 클래스 안에서 정의된 맞춤 설명을 반환하여 description 속성을 볼 수 있음.

	let car = Car()
	car.currentSpeed = 25.0
	car.gear = 3
	println("Car: \(car.description)")
	// Car: traveling at 25.0 miles per hour in gear 3

#### 속성 감시자 오버라이딩(Overriding Property Observers)

상속받은 속성에 속성 감시자를 추가하는 오버라이딩을 사용할 수 있음. 상속받은 속성의 값이 변경되었을 때 알려주도록 하며, 기존에 속성이 어떻게 구현되었는지는 필요없음.

<div class="alert-info">
상속받은 상수 저장 속성이나 읽기 전용 계산 속성에는 속성 감시자를 추가할 수 없음. 이들 속성의 값은 설정되지 못하며, 오버라이드의 한 부분으로 <code>willSet</code> 또는 <code>didSet</code> 구현은 적합하지 않음.
</div>

같은 속성에서 setter 오버라이딩과 속성 감시자 오버라이딩은 지원되지 않으니 주의할 것. 속성 값 변경을 감시하길 원하면, 이미 사용자 setter가 제공되고 있으며, 사용자 setter 안에서 어떤 값이 바뀌더라도 간단히 감시할 수 있음.

다음은 AutomaticCar라는 Car의 서브클래스 정의 예제임. AutomaticCar 클래스는 자동기어박스를 가지는 자동차로 표시되며, 자동적으로 현재 속도에 맞추어 적합한 기어를 선택함.

	class AutomaticCar: Car {
	    override var currentSpeed: Double {
	        didSet {
	            gear = Int(currentSpeed / 10.0) + 1
	        }
	    }
	}

AutomaticCar 인스턴스의 currentSpeed를 설정할 때, 속성의 didSet 감시자는 새로운 속도에 적합한 기어 선택을 하여 인스턴스의 gear 속성을 설정함. 특히 속성 감시자는 새로운 currentSpeed 값을 10으로 나누고 나머지는 버리고 1을 더한 기어를 선택함. 속도가 10이면 기어는 1, 속도가 35면 기어는 4임.

	let automatic = AutomaticCar()
	automatic.currentSpeed = 35.0
	println("AutomaticCar: \(automatic.description)")
	// AutomaticCar: traveling at 35.0 miles per hour in gear 4

### 오버라이드 방지(Preventing Overrides)

`final`로 표시하여 오버라이드로부터 메소드, 속성 또는 서브스크립트를 막을 수 있음. 메소드, 속성 또는 서브스크립트의 `final var`, `final func`, `final class func`그리고 `final subscript`같은 소개 키워드 앞에 `final` 수식어를 작성하여 수행함.

서브클래스 안에서 final 메소드, 속성 또는 서브스크립트를 오버라이드하려는 시도는 컴파일 타임에러로 보고됨. 메소드, 속성 또는 서브스크립트는 확장 정의안에 final로서 표시하여 클래스에 추가할 수 있음.

클래스 정의에서 class 키워드 앞에 final 수식어를 쓰도록 하여 final로서 모든 클래스를 표시할 수 있음(final class). final 클래스를 서브클래스로 하려는 시도는 컴파일 타임에러로 보고될 것임.

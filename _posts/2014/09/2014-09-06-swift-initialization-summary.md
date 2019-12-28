---
layout: post
title: "[Swift]Initialization 정리"
description: ""
category: "mac/ios"
tags: [swift, initialization, initializer, stored property, computed property, default, init, override, convenience, designated initializer, convenience initializer, parameter name, local parameter name, external parameter name, required, optional, superclass, subclass, inheritance, instance, delegation, closure, function, chaining, value type, self, structure]
---
{% include JB/setup %}

## 초기화(Initialization)

초기화는 클래스, 구조체 또는 열거형을 사용하기 위한 준비하는 과정. 각각의 저장 속성을 위해 초기화된 값을 설정하는 것과 사용하기 위한 새로운 인스턴스르 준비하기전에 필요한 그외 다른 설정 또는 초기화를 진행함.

이니셜라이저(initializer) 정의로 초기화 진행을 구현하는데, 특정 메소드에서 특정 타입의 인스턴스를 만들기 위해 호출될 수 있음. Objective-C 이니셜라이저와는 다르게 Swift 이니셜라이저는 값을 반환하지 않음. 주된 역할은 처음 사용하기 전에 새로운 타입의 인스턴스가 정확하게 초기화되는지 보증하도록 함.

클래스 타입의 인스턴스는 디이니셜라이저(deinitializer)을 구현할 수 있는데 클래스의 인스턴스가 할당 해제되기 전에 사용자 정리를 수행함.

### 저장 속성을 위한 초기 값 설정(Setting Initial Values for Stored Properities)

클래스와 구조체는 클래스나 구조체의 인스턴스가 만들어질 때 마다 적합한 초기 값을 저장 속성에 모두 설정해야 한다. 저장 속성은 애매한 상태를 남길 수 없다.

이니셜라이저 내에서 저장 속성에 초기 값을 설정하거나 속성의 정의 부분으로서 기본 속성 값을 할당해야 한다. 

<div class="alert-info">
저장속성에 기본 값을 할당할 때나 이니셜라이저 내에서 초기 값을 설정할 때, 속성의 값은 속성 감시자를 호출하지 않고 직접 설정한다.
</div>

#### 이니셜라이저(Initializers)

이니셜라이저는 특정 타입의 새로운 인스턴스를 만들기 위해 호출하며, 인자가 없는 인스턴스 메소드와 유사한 형식으로 `init` 키워드를 사용한다.

	init() {
	    // perform some initialization here
	}

아래는 Fahrenheit라는 새로운 구조체로 화씨 크기를 표현하는 온도를 저장한다. Fahrenheit 구조체는 Double 타입의 temperature 저장 속성을 가진다.

	struct Fahrenheit {
	    var temperature: Double
	    init() {
	        temperature = 32.0
	    }
	}
	var f = Fahrenheit()
	println("The default temperature is \(f.temperature)° Fahrenheit")
	// prints "The default temperature is 32.0° Fahrenheit"

이 구조체는 인자를 가지지 않는 단일 이니셜라이저 `init`으로 정의하며 32.0 값으로 이니셜라이저가 temperature에 저장한다.

#### 기본 속성 값(Default Property Values)

위에서 이니셜라이저 내에서 저장 속성의 초기 값을 설정할 수 있다. 대신 속성의 선언의 부분으로 기본 속성 값을 지정한다. 초기화를 정의할 때 속성에 초기 값을 할당하도록 기본 속성 값을 지정한다.

<div class="alert-info">
	한 속성이 같은 초기화 값을 취하면 이니셜라이저 내에서 설정 값 보다 기본 값을 우선으로 제공한다. 결과로는 같지만 기본 값은 속성 초기화와 선언은 매우 밀접하게 엮여 있다. 짧고 명확한 이니셜라이저를 만들며 기본 값으로부터 속성의 타입을 추론 하도록 만든다. 기본 값은 기본 이니셜라이저과 이니셜라이저 상속의 이점을 얻기 쉽게 만든다.
</div>

위에서 작성한 temperature 속성에 기본 값을 제공하는 간단한 Fahrenheit 구조체 형식는 다음과 같이 정의된다.

	struct Fahrenheit {
	    var temperature = 32.0
	}

### 사용자 정의 초기화(Customizing initialization)

입력 인자와 옵셔널 속성 타입 또는 초기화 하는 동안 수정하는 상수 속성으로 초기화 과정을 사용자 정의할 수 있다.

#### 초기화 인자(initialization Parameters)

이니셜라이저의 정의 한 부분으로 초기화 인자가 주어지며 사용자 정의하는 초기화 과정에 타입과 값 이름을 정의할 수 있다. 초기화 인자는 함수와 메소드 인자와 같은 특징과 문법을 가진다.

다음은 Celsius 구조체로 두 개의 사용자 이니셜라이저 init(fromFahrenheit:)와 init(fromKelvin:)을 가지며, 각각 다른 온도 값을 가지는 구조체임.

	struct Celsius {
	    var temperatureInCelsius: Double
	    init(fromFahrenheit fahrenheit: Double) {
	        temperatureInCelsius = (fahrenheit - 32.0) / 1.8
	    }
	    init(fromKelvin kelvin: Double) {
	        temperatureInCelsius = kelvin - 273.15
	    }
	}
	let boilingPointOfWater = Celsius(fromFahrenheit: 212.0)
	// boilingPointOfWater.temperatureInCelsius is 100.0
	let freezingPointOfWater = Celsius(fromKelvin: 273.15)
	// freezingPointOfWater.temperatureInCelsius is 0.0

첫번째 이니셜라이저는 단일 초기화 인자로 외부 이름 fromFahrenheit과 내부 이름 fahrenheit를 가지며, 두번째 이니셜라이저는 외부 이름 fromKelvin과 내부 이름 kelvin을 가진다.

#### 지역과 외부 인자 이름(Local and External Parameter Names)

초기화 인자는 호출할 때 외부 이름을, 이니셜라이저 내부에서는 내부 이름을 가진다. 이니셜라이저의 인자의 이름과 타입은 호출할 때 식별하기 위한 중요한 역할로 수행하는데, 이는 외부 이름을 작성하지 않아도 이니셜라이저에 모든 인자에 외부 이름을 자동으로 사용하도록 하기 때문이다. 자동으로 외부 이름과 내부 이름을 동일하게 하며 이는 해쉬 기호(#)를 사용한 것과 동일하다.

다음은 Color라는 구조체 예제로 지역과 외부 인자 이름이 동일한 것을 보여주는 예제이다.

	struct Color {
	    let red, green, blue: Double
	    init(red: Double, green: Double, blue: Double) {
	        self.red   = red
	        self.green = green
	        self.blue  = blue
	    }
	    init(white: Double) {
	        red   = white
	        green = white
	        blue  = white
	    }
	}

이니셜라이저를 사용하여 새로운 Color 인스턴스를 만들 수 있다.

let magenta = Color(red: 1.0, green: 0.0, blue: 1.0)
let halfGray = Color(white: 0.5)

외부 인자 이름 없이는 이니셜라이저를 호출할 수 없다. 무시하고 이니셜라이저를 사용한다면 컴파일 타입 에러가 발생한다.

	let veryGreen = Color(0.0, 1.0, 0.0)
	// this reports a compile-time error - external names are required

#### 외부 이름 없는 이니셜라이저 인자(initializer Parameters Without External Names)

이니셜라이저 이름에 외부 이름을 사용하기 원치 않으면 밑줄(_)을 명시적인 외부 이름 대신 오버라이드 하여 사용한다.

	struct Celsius {
	    var temperatureInCelsius: Double
	    init(fromFahrenheit fahrenheit: Double) {
	        temperatureInCelsius = (fahrenheit - 32.0) / 1.8
	    }
	    init(fromKelvin kelvin: Double) {
	        temperatureInCelsius = kelvin - 273.15
	    }
	    init(_ celsius: Double) {
	        temperatureInCelsius = celsius
	    }
	}
	let bodyTemperature = Celsius(37.0)
	// bodyTemperature.temperatureInCelsius is 37.0

이니셜라이저는 Celsius(37.0)으로 호출하여 외부 인자 이름을 사용할 필요가 없다는 의도를 명확하게 보여준다.

#### 옵셔널 속성 타입(Optional Property Types)

논리적으로 값이 없음을 허용한다면 속성을 옵셔널 타입으로 선언해야 하며, 이니셜라이저는 자동으로 값을 nil올 초기화한다.

다음은 response라는 옵셔널 문자열 속성을 가진 클래스 선언 예제이다.

	class SurveyQuestion {
	    var text: String
	    var response: String?
	    init(text: String) {
	        self.text = text
	    }
	    func ask() {
	        println(text)
	    }
	}
	let cheeseQuestion = SurveyQuestion(text: "Do you like cheese?")
	cheeseQuestion.ask()
	// prints "Do you like cheese?"
	cheeseQuestion.response = "Yes, I do like cheese."

response 속성에 기본값으로 nil이 할당되며, 이는 새로운 SurveyQuestion 인스턴스가 초기화될 때 아직 값이 없음을 의미한다.

#### 초기화 중에 동안 상수 속성 변경(Modifying Constant Properties During Initialization)

초기화 하는 중에 상수 속성의 값은 수정할 수 있으며, 초기화가 끝난 후에는 명확한 값으로 설정된다.

<div class="alert-info">
	클래스 인스턴스에서 상수 속성은 초기화 중에만 수정할 수 있으며, 서브클래스에 의한 수정은 할 수 없다.
</div>

아래는 text 속성을 변수 속성에서 상수 속성으로 바꾸어 수행하는 예제로 text가 초기화할 때 값이 들어가 상수임에도 값이 바뀌는 것을 확인할 수 있다.

	class SurveyQuestion {
	    let text: String
	    var response: String?
	    init(text: String) {
	        self.text = text
	    }
	    func ask() {
	        println(text)
	    }
	}
	let beetsQuestion = SurveyQuestion(text: "How about beets?")
	beetsQuestion.ask()
	// prints "How about beets?"
	beetsQuestion.response = "I also like beets. (But not with cheese.)"

### 기본 이니셜라이저(Default Initializers)

Swift는 기본 값을 주어 이니셜라이저를 사용할 필요없이 어떤 구조체나 기반 클래스에도 기본 이니셜라이저를 지원한다.

	class ShoppingListItem {
	    var name: String?
	    var quantity = 1
	    var purchased = false
	}
	var item = ShoppingListItem()

모든 속성이 기본 값을 가지고 있고 슈퍼클래스가 없기 때문에 자동으로 기본 이니셜러이저가 구현되며, 새로운 인스턴스는 모든 속성에 기본 값이 설정되어 있다.

#### 구조체 타입을 위한 멤버 이니셜라이저(Memberwise Initializers for Structure Types)

구조체 타입은 사용자 이니셜라이저를 정의하지 않으면 자동으로 멤버 이니셜라이저를 받는다. 또한, 구조체의 저장 속성은 기본 값을 가지고 있지 않아도 된다.

멤버 이니셜라이저는 새로운 구조체 인스턴스의 멤버 속성을 초기화하는 축약 방법.

아래 구조체에서 멤버 이니셜라이저를 자동으로 받아 인스턴스를 구현하는 예제.

	struct Size {
	    var width = 0.0, height = 0.0
	}
	let twoByTwo = Size(width: 2.0, height: 2.0)

### 값 타입을 위한 이니셜라이저 델리게이션(Initializer Delegation for Value Types)

이니셜라이저는 인스턴스의 초기화 수행 부분 중에 다른 이니셜라이저를 호출할 수 있으며, 이는 이니셜라이저 델리게이션이라고 알려져있고, 다중 이니셜라이저에 중복 코드를 피할 수 있다.

이니셜라이저 델리게이션 작업은 값 타입과 클래스 타입에 따라 다른 역할을 수행한다. 값 타입은 상속을 지원하지 않기 때문에 이니셜라이저 델리게이션 진행은 상대적으로 단순하다. 이는 다른 이니셜라이저가 제공해준 것으로 대신 하기 때문이다. 

클래스는 다른 클래스로부터 상속을 받는데, 이 의미는 초기화 중에 상속받는 모든 저장 속성에 값이 맞는지 보장해야하는 책임을 가진다.

값 타입은 사용자 이니셜라이저를 작성할 때 같은 값 타입에서 다른 이니셜라이저를 참조하도록 `self.init`을 사용할 수 있다. `self.init`은 이니셜라이저 안에서만 호출이 가능하다.

값 타입을 위한 사용자 이니셜라이저를 정의하면 더이상 기본 이니셜라이저를 접근할 수 없으며, 이러한 제약은 필수적인 설정을 제공하는 복잡한 이니셜라이저 대신 자동 이니셜라이저를 사용하여 사고를 방지한다.

<div class="alert-info">
	기본 이니셜라이저와 멤버 이니셜라이저 그리고 자신만의 이니셜라이저로 사용자 값 타입을 초기화하길 원하면 값 타입에 기본 구현 보다 확장을 사용하는 것이 더 바람직하다.
</div>

다음은 사각형 구조체에 필요한 두 개의 구조체 Size, Point가 모든 속성에 기본 값 0을 갖는 예제.

	struct Size {
	    var width = 0.0, height = 0.0
	}
	struct Point {
	    var x = 0.0, y = 0.0
	}

다음은 Rect 구조체를 3가지 방법으로 초기화하는 예제.

	struct Rect {
	    var origin = Point()
	    var size = Size()
	    init() {}
	    init(origin: Point, size: Size) {
	        self.origin = origin
	        self.size = size
	    }
	    init(center: Point, size: Size) {
	        let originX = center.x - (size.width / 2)
	        let originY = center.y - (size.height / 2)
	        self.init(origin: Point(x: originX, y: originY), size: size)
	    }
	}

첫번째 이니셜라이저 init()는 구조체에서 기본 이니셜라이저와 동일한 기능을 하여 속성에 정의된 기본 값으로 초기화된다.

	let basicRect = Rect()
	// basicRect's origin is (0.0, 0.0) and its size is (0.0, 0.0)

두번째 이니셜라이저 init(origin:size:)는 멤버 이니셜라이저와 같은 기능을 가지며 origin과 size 저장 속성에 간단하게 할당한다.

	let originRect = Rect(origin: Point(x: 2.0, y: 2.0),
	    size: Size(width: 5.0, height: 5.0))
	// originRect's origin is (2.0, 2.0) and its size is (5.0, 5.0)

세번째 이니셜라이저 init(center:size:)는 조금 복잡한데 중앙 좌표와 크기를 기반으로 origin 속성을 설정한다. 그리고 init(center:size) 이니셜라이저는 기존에 제공되는 이니셜라이저의 이점을 이용하여 더 편리하다.

### 클래스 상속과 초기화(Class Inheritance and Initialization)

슈퍼클래스로부터 상속받은 모든 저장 속성은 초기화할 때 초기 값을 할당받아야 함.

Swift는 클래스 타입에 모든 저장 속성에 초기 값을 받도록 도와주는 두가지 이니셜라이저를 정의함. 이를 지정 이니셜라이저(designated initializers)와 편의 이니셜라이저(convenience initializers)라고 함.

#### 지정 이니셜라이저와 편의 이니셜라이저(Designated Initializers and Convenience Initializers)

클래스의 주 이니셜라이저는 지정 이니셜라이저로, 클래스의 모든 속성을 완전히 초기화한다. 적합한 슈퍼클래스 이니셜라이저를 호출하여 초기화 과정을 부모클래스로 연쇄하도록 한다.

모든 클래스는 하나 이상의 지정 이니셜라이저를 가진다. 지정 이니셜라이저는 깔때기를 통해 초기화 과정의 연쇄를 슈퍼클래스로 진행시킨다.

편의 이니셜라이저는 호출하는 지정 이니셜라이저 인자에 기본 값으로 설정할 수 있다. 또한 특정 쓰임새나 입력 값 타입을 위한 클래스의 인스턴스를 생성하기 위해 편의 이니셜라이저를 정의할 수 있다.

만약 클래스에 편의 이니셜라이저를 쓸 필요가 없다면 사용하지 않아도 된다. 일반적인 이니셜라이저 패턴을 단축할 때 만든 편의 이니셜라이저는 시간을 단축시키거나 클래스의 이니셜라이저 의도를 명확하게 만들 수 있다.

#### 지정 이니셜라이저와 편의 이니셜라이저 문법(Syntax for Designated and Convenience Initializers)

값 타입을 위한 간단한 지정 이니셜라이저는 다음과 같이 사용한다.

	init(parameters) {
	    statements
	}

편의 이니셜라이저는 같은 형식이지만 `convenience` 수식어가 `init` 키워드 앞에 위치하며 공백으로 분리어 사용된다.

	convenience init(parameters) {
	    statements
	}

#### 이니셜라이저 연쇄(Initializer Chaining)

지정 이니셜라이저와 편의 이니셜라이저의 관계를 간단하게 하기 위해 Swift는 다음 세가지 규칙을 적용하였다.

* 규칙 1. 지정 이니셜라이저는 직접 관련있는 슈퍼클래스로부터 지정 이니셜라이저를 호출해야 한다.
* 규칙 2. 편의 이니셜라이저는 같은 클래스에서 다른 이니셜라이저 호출해야 한다.
* 규칙 3. 편의 이니셜라이저는 지정 이니셜라이저로 끝맺어야 한다.

간단하게 다음 사항을 기억하면 된다.

* 지정 이니셜라이저는 항상 위로 위임을 한다.
* 편의 이니셜라이저는 항상 가로질러 위임한다.

이들 규칙은 다음 그림으로 표현함.

<img src="{{ site.production_url }}/image/2014/09/initializerDelegation01_2x.png" alt="initializerDelegation01" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

슈퍼클래스는 지정 이니셜라이저 하나와 편의 이니셜라이저 두개를 가진다. 편의 이니셜라이저는 다른 편의 이니셜라이저를 호출하고 지정 이니셜라이저 호출을 돌려준다. 이는 규칙 2와 3을 만족하며, 이 슈퍼클래스는 위에 슈퍼클래스가 없기 때문에 규칙 1이 적용되지 않는다.

서브클래스는 지정 이니셜라이저 두개와 편의 이니셜라이저 하나를 가진다. 편의 이니셜라이저는 지정 이니셜라이저 하나를 호출하는데, 같은 클래스에서 다른 이니셜라이저를 유일하게 호출할 수 있다. 이는 규칙 2와 3을 만족하며, 지정 이니셜라이저들은 슈퍼클래스의 지정 이니셜라이저를 호출하기 때문에 규칙 1을 만족한다.

<div class="alert-info">
	이 규칙은 각 클래스의 인스턴스를 생성하는데 영향을 주지 않는다. 이니셜라이저가 속한 클래스의 전체 초기화된 인스턴스를 만드는데 사용된다. 이 규칙은 클래스 구현을 작성하는데 영향을 미칠 뿐이다.
</div>

아래 그림은 네개의 클래스 계층 구조이다. 이 그림에서 지정 이니셜라이저가 클래스 초기화를 위한 깔대기로서 계층 역활을 하는 것을 보여주며, 클래스 연쇄의 연관성을 간략하게 한다.

<img src="{{ site.production_url }}/image/2014/09/initializerDelegation02_2x.png" alt="initializerDelegation02" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

#### 두 단계 초기화(Two-Phase Initialization)

Swift에서 클래스 초기화는 두 간계로 진행되며, 첫 단계는 각각의 클래스 저장 속성이 초기 값으로 할당된다. 두번째 단계를 시작할 때 모든 저장 속성에 초기 상태는 결정되었으며, 각각의 클래스는 사용하기 위한 인스턴스를 준비하기 전에 저장 속성을 사용자 정의할 기회가 주어진다.

두 단계 초기화 사용은 초기화를 안전하게 만들도록 진행하며, 클래스 계층에 각각의 클래스에 완전히 유연하도록 한다. 두 단계 초기화는 초기화되지 전에 속성 값에 접근하는 것을 방지하며, 다른 이니셜라이저로부터 속성 값에 다른 값으로 설정되는 예기치못한 상태를 막는다.

<div class="alert-info">
	Swift의 두 단계 이니셜라이저 과정은 Objective-C의 초기화와 유사하다 주된 차이점이라면 일 단계에서 Objective-C는 0또는 nil 값을 모든 속성에 할당하는데, Swift의 초기화 과정은 사용자 초기 값을 설정하도록 하게 하여 더 유연해지며, 0 또는 nil이 기본 값으로 유효하지 않은 타입에 대처할 수 있다.
</div>

Swift 컴파일러는 두 단계 초기화가 에러없이 완벽하도록 네가지 안전 점검을 수행한다.

* 안전 점검 1. 지정 이니셜라이저는 클래스에 도입된 모든 속성이 슈퍼클래스 이니셜라이저에 위임되기 전에 초기화되는지 확실하게 해야한다.

객체를 위한 메모리는 저장 속성의 초기 상태가 알려져야 완전히 초기화 되었다고 간주한다. 이 규칙에 만족하기 위해선 지정 이니셜라이저는 모든 클래스의 자기 속성이 연쇄를 위로 올리기 전에 초기화되어야 한다.

* 안전 점검 2. 지정 이니셜라이저는 상속받은 속성에 값을 할당하기 전에 슈퍼 클래스 이니셜라이저로 위임해야 한다. 그렇지 않으면 지정 이니셜라이저에 새로운 값은 슈퍼클래스의 초기화로부터 덮어씌여질 것이다.

* 안전 점검 3. 편의 이니셜라이저는 특정 속성에 값을 할당하기 전에 다른 이니셜라이저에 위임해야 하며, 같은 클래스에 정의된 속성을 포함해야 한다. 그렇지 않으면 클래스의 지정 이니셜라이저에 의해 편의 이니셜라이저의 새로운 값이 덮어씌여질 것이다.

* 안전 점검 4. 이니셜라이저는 인스턴스 메소드를 호출할 수 없으며 인스턴스 속성의 값을 읽을 수 있거나 초기화 첫 단계가 완료될 때까지 값으로 self로 참조한다.

클래스 인스턴스는 일 단계가 끝나기 전까지 완전히 유효하지 않다. 속성은 접근만 가능하고 메소드는 호출만 가능하다면 클래스 인스턴스는 일단계가 끝나며 유효하게 된다.

**1단계**

* 지정 또는 편의 초기화는 클래스 상에서 호출된다.
* 클래스의 새로운 인스턴스를 위한 메모리가 할당되며, 이 메모리는 아직 초기화되지 않았다.
* 클래스를 위한 지정 이니셜라이저는 클래스에 도입된 모든 저장 속성이 값을 가짐을 확신한다. 이들 저장 속성 메모리는 지금 초기화된다.
* 이 작업의 연쇄는 클래스 상속 계층의 맨 꼭대기에 다다를때까지 계속 된다.
* 연쇄가 꼭대기에 다다르면 연쇄의 마지막 클래스는 모든 저장 속성이 값을 가짐을 확신하게 되며, 인스턴스 메모리는 모두 초기화되었고, 1단계가 끝났음을 간주한다.

**2단계**

* 연쇄의 꼭대기에서 거꾸로 내려오면서 작업을 하여, 연쇄 안에 각각의 지정 이니셜라이저는 추가로 인스턴스를 사용자 정의할 수 있는 옵션을 가진다. 이니셜라이저는 이제 self에 접근이 가능하며 속성을 수정할 수 있고, 인스턴스 메소드를 호출할 수 있다.
* 마지막으로 연쇄안에 편의 이니셜라이저는 self로 작업을 하고 인스턴스를 사용자 정의할 수 있는 옵션을 가진다.

다음은 가상의 서브클래스와 슈퍼클래스를 호출하는 1단계 초기화 그림이다.

<img src="{{ site.production_url }}/image/2014/09/twoPhaseInitialization01_2x.png" alt="twoPhaseInitialization01" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

초기화는 서브클래스 상에서 편의 이니셜라이저를 호출 시작한다. 편의 이니셜라이저는 속성을 수정하지 못한다. 같은 클래스에서 지정 클래스로 위임을 넘긴다.

지정 이니셜라이저는 안전 점검 1에서 모든 서브클래스 속성이 값을 가지고 있다고 확신한다. 슈퍼클래스 상에 지정 이니셜라이저를 초기화 연쇄를 계속하도록 호출한다.

슈퍼클래스의 지정 이니셜라이저는 모든 슈퍼클래스 속성에 값을 가지도록 확실히 한다. 더 이상 초기화를 위한 슈퍼클래스가 없으면 위임을 더이상 하지 않는다.

모든 슈퍼클래스의 속성이 초기 값을 가지면 메모리는 완전 초기화 되었다고 가정하고 1단계를 끝낸다.

다음은 2단계 초기화 호출 그림이다.

<img src="{{ site.production_url }}/image/2014/09/twoPhaseInitialization02_2x.png" alt="twoPhaseInitialization02" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

슈퍼클래스의 지정 이니셜라이저는 인스턴스에 사용자 정의를 위한 기회를 이제 가진다.

슈퍼클래스의 지정 이니셜라이저가 끝나면 서브클래스의 지정 이니셜라이저가 추가적인 사용자 정의를 수행할 수 있다.

마지막으로 서브클래스의 지정 이니셜라이저가 끝나면, 편의 이니셜라이저는 추가적인 사용자 정의를 수행하도록 호출된다.

#### 이니셜라이저 상속과 오버라이딩(Initializer Inheritance and Overriding)

Objective-C의 서브클래스와는 다르게, Swift 서브클래스는 기본적으로 슈퍼클래스 이니셜라이저를 상속받지 않는다. Swift는 단순한 부모 클래스의 이니셜라이저가 더 복잡한 서브클래스에 상속받는 상황을 방지하며, 서브클래스의 새로운 인스턴스가 완전하지 않거나 올바르지 않게 초기화되어 만들어 지는 것을 막는다.

<div class="alert-info">
	슈퍼클래스 이니셜라이저는 어떤 상황에서 상속을 받지만, 그 상황에 안전하고 적합할 때만 그렇다.
</div>

슈퍼클래스로서 같은 이니셜라이저를 하나 이상 더 많이 서브클래스에 표현하고자 한다면 서브클래스 안에 사용자 이니셜라이저 구현을 할 수 있다.

슈퍼클래스의 지정 이니셜라이저와 일치하는 서브클래스 이니셜라이저를 작성할 때, `override` 수식어를 서브클래스의 이니셜라이저 정의 앞에 작성하여 자동적으로 기본 이니셜라이저로 오버라이딩 된다.

오버라이드된 속성, 메소드 또는 서브스크립트는 `override` 수식어로 표현한다.

<div class="alert-info">
	<code>override</code> 수식어는 슈퍼클래스 지정 이니셜라이저를 오버라이드 할 때 쓴다.
</div>

반대로 슈퍼클래스 편의 이니셜라이저와 일치하는 서브클래스 이니셜라이저를 쓰면, 슈퍼클래스 편의 이니셜라이저는 서브클래스로 직접 호출할 수 없으며 위의 Initializer Chaining의 규칙이다. 따라서 엄격하게 말하면 슈퍼클래스 이니셜라이저의 오버로딩은 서브클래스에선 지원하지 않는다. 그 결과로 `override` 수식어는 슈퍼클래스 편의 이니셜라이저의 구현에는 쓰지 않는다.

다음은 Vehicle이라는 기반 클래스 정의로, 기본 값 0을 가지는 numberOfWheel이라는 저장 속성을 선언한다. 이 numberOfWheel 속성은 description이라는 문자열 계산 속성이다.

	class Vehicle {
	    var numberOfWheels = 0
	    var description: String {
	        return "\(numberOfWheels) wheel(s)"
	    }
	}

Vehicle 클래스는 사용자 이니셜라이저를 가지지 않고 속성에 기본 값만 가진다.  기본 이니셜라이저는 항상 클래스를 위한 지정 이니셜라이저이고 새로운 Vehicle 인스턴스를 만들기 위해 사용할 수 있음.

	let vehicle = Vehicle()
	println("Vehicle: \(vehicle.description)")
	// Vehicle: 0 wheel(s)

Bicycle이라는 Vehicle의 서브클래스 정의 예제

	class Bicycle: Vehicle {
	    override init() {
	        super.init()
	        numberOfWheels = 2
	    }
	}

Bicycle 서브클래스는 사용자 지정 이니셜라이저 init()을 정의한다. 지정 이니셜라이저는 슈퍼클래스의 지정 이니셜라이저와 일치하며 `override`로 표시한다.

Bicycle의 init() 이니셜라이저는 super.init() 호출로 시작하며 Bicycle 클래스의 슈퍼 클래스 Vehicle 에 기본 이니셜라이저를 호출한다. numberOfWheels 상속 속성은 Vehicle로 초기화 된 다음 Bicycle에서 속성을 변경하는 기회를 가지게 되는데, numberOfWheels의 원래 값 0을 새로운 값 2로 대신한다.

	let bicycle = Bicycle()
	println("Bicycle: \(bicycle.description)")
	// Bicycle: 2 wheel(s)

<div class="alert-info">
	서브클래스는 초기화 하는 동안 변수 슈퍼클래스 속성을 변경하는 것만 가능하게 하며, 상속받은 상수 속성은 변경할 수 없다.
</div>

#### 자동 이니셜라이저 상속(Automatic Initializer Inheritance)

서브클래스는 기본적으로 슈퍼클래스 이니셜라이저를 상속받지 않는다. 그러나 슈퍼클래스 이니셜라이저는 어떤 조건을 만족한다면 자동으로 상속된다. 이 의미는 불필요하게 이니셜라이저를 오버라이드를 하지 않아도 된다.

서브클래스에서 도입한 새로운 속성에 기본 값을 준다고 가정하면 두가지 규칙을 따라야 한다.

* 규칙 1. 서브클래스는 지정 이니셜라이저를 정의하지 않으면 자동으로 슈퍼클래스의 지정 이니셜라이저를 상속받는다.
* 규칙 2. 서브클래스는 모든 슈퍼클래스 지정 이니셜라이저의 구현을 지원하며 자동적으로 모든 슈퍼클래스의 이니셜라이저를 상속한다.

이 규칙은 편의 이니셜라이저는에도 추가 적용된다.

<div class="alert-info">
	서브클르새는 규칙 2를 만족하는 슈퍼클래스 편의 이니셜라이저로서 슈퍼클래스 지정 이니셜라이즈를 구현할 수 있다.
</div>

#### 실제로 하는 지정 이니셜라이저와 편의 이니셜라이저

지정 이니셔라이저와 편의 이니셜라이저 그리고 자동 이니셜라이저 상속 예제를 보여줄 것임. Food, RecipeIngredient, ShoppingListItem이라는 세개의 클래스 계층을 정의하며 어떻게 이니셜라이저가 수행하는지 증명한다.

Food라는 계층의 기반 클래스는 단순히 식품의 이름을 캡슐화한다. Food 클래스는 name이라는 문자열 속성과 Food 인스턴스를 위한 이니셜라이저 두개를 제공한다.

	class Food {
	    var name: String
	    init(name: String) {
	        self.name = name
	    }
	    convenience init() {
	        self.init(name: "[Unnamed]")
	    }
	}

다음은 Food 클래스에 이니셜라이저 연쇄를 보여주는 그림이다.

<img src="{{ site.production_url }}/image/2014/09/initializersExample01_2x.png" alt="initializersExample01" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

클래스는 기본 멤버 이니셜라이저는를 가지고 있지 않고 name이라는 인자를 기자는 지정 이니셜라이저를 제공한다. 이니셜라이저는 특정 이름을 가지는 새로운 Food 인스턴스를 만들도록 사용할 수 있다.

	let namedMeat = Food(name: "Bacon")
	// namedMeat's name is "Bacon"

Food 클래스에서 init(name: String) 이니셜라이저는 지정 이니셜라이저로 제공되며 이는 새로운 Food 인스턴스의 모든 저장 속성가 완전히 초기화 되었음을 보장한다. Food 클래스는 슈퍼클래스를 기지지 않으며 init(name: String) 이니셜라이저는 super.init()을 호출할 필요가 없다.

Food 클래스는 또한 편의 이니셜라이저 init()을 제공한다. init() 이니셜라이저는 새로운 음식의 이름으로 기본 자리 표시 이름을 제공하는데 Food 클래스의 name 값 [Unname]을 가지는 init(name: String)로 위임된다.

	let mysteryMeat = Food()
	// mysteryMeat's name is "[Unnamed]"

RecipeIngredient라는 Food의 서브클래스는 요리법에 재료를 모은다. quantity라는 정수 속성을 가져오고 RecipeIngredient 인스턴스를 만드는 이니셜라이저 두개를 정의한다.

	class RecipeIngredient: Food {
	    var quantity: Int
	    init(name: String, quantity: Int) {
	        self.quantity = quantity
	        super.init(name: name)
	    }
	    override convenience init(name: String) {
	        self.init(name: name, quantity: 1)
	    }
	}

RecipeIngredient 클래스를 위한 이니셜라이저 연쇄를 보여주는 그림이다.

<img src="{{ site.production_url }}/image/2014/09/initializersExample02_2x.png" alt="initializersExample03" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

RecipeIngredient 클래스는 단일 지정 이니셜라이저 init(name: String, quantity: Int)를 가지며, 새로운 RecipeIngredient 인스턴스의 모든 속성이 있도록 사용할 수 있다. 이니셜라이저는 quantity 인자를 quantity 속성에 넘겨줘 할당하는 것을 시작한다. 이니셜라이저는 Food 클래스의 init(name: String) 이니셜라이저에 위임을 한다. 이는 안전 점검 1을 만족하는 과정이다.

RecipeIngredient는 편의 이니셜라이저 init(name: String)를 정의하는데, name으로만 RecipeIngredient 인스턴스를 만드는데 사용된다. 편의 이니셜라이저는 명시적인 수량이 필요없이 수량 1로 가정한다. 편의 이니셜라이저 정의는 RecipeIngredient 인스턴스를 좀 더 빠르고 편리하게 만들며 RecipeIngredient 인스턴스를 만들 때 중복 코드를 피할 수 있다. 편의 이니셜라이저는 단순히 클래스의 지정 이니셜라이저에다 quantity 값 1을 넘겨 위임하도록 한다.

init(name: String) 편의 이니셜라이저는 Food의 지정 이니셜라이저 init(name: String)과 같은 인자를 갖는다. 편의 이니셜라이저는 슈퍼클래스로부터 지정 이니셜라이저를 오버라이드 하기 때문에 `override` 수식어를 붙여야 한다.

RecipeIngredient는 init(name: String) 이니셜라이저가 편의 이니셜라이저로 지원되기 때문에 RecipeIngredient는 슈퍼클래스의 지정 이니셜라이저의 구현을 지원한다. 그러므로 RecipeIngredient는 자동으로 슈퍼클래스의 편의 이니셜라이저를 상속한다.

	let oneMysteryItem = RecipeIngredient()
	let oneBacon = RecipeIngredient(name: "Bacon")
	let sixEggs = RecipeIngredient(name: "Eggs", quantity: 6)

ShoppingListItem이라는 RecipeIngredient 서브클래스는 쇼핑 목록을 나타내는 요리 재료 수량을 만든다. 

쇼핑 목록의 모든 항목은 구매되지 않음으로 시작하며, 실제로는 purchased라는 논리 속성으로 표시되며 기본 값은 false를 가진다. ShoppingListItem은 계산 속성인 description이 추가되며 ShoppingListItem 인스턴스의 설명을 지원한다.

	class ShoppingListItem: RecipeIngredient {
	    var purchased = false
	    var description: String {
	        var output = "\(quantity) x \(name)"
	            output += purchased ? " ✔" : " ✘"
	            return output
	    }
	}

<div class="alert-info">
	ShoppingListItem는 이니셜라이저가 정의되지 않고 purchased값만 초기 값으로 제공되는데, 이는 쇼핑 목록 항목이 항상 구매되지 않음으로 시작하기 때문임.
</div>

모든 속성의 초기값을 제공하고, 어떤 이니셜라이저도 스스로 정의하지 않기 때문에 ShoppingListItem은 자동적으로 모든 지정 이니셜라이저와 편의 이니셜라이저를 부모 클래스에서 상속받음.

밑에 그림은 세 개의 클래스의 이니셜라이저 연쇄를 보여준다.

<img src="{{ site.production_url }}/image/2014/09/initializersExample03_2x.png" alt="initializersExample03" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

새로운 ShoppingListItem 인스턴스는 상속받은 세 개의 이니셜라이저를 통해 만들 수 있다.

	var breakfastList = [
	    ShoppingListItem(),
	    ShoppingListItem(name: "Bacon"),
	    ShoppingListItem(name: "Eggs", quantity: 6),
	]
	breakfastList[0].name = "Orange juice"
	breakfastList[0].purchased = true
	for item in breakfastList {
	    println(item.description)
	}

breakfastList라는 배열은 [ShoppingListItem]로 추론되는 타입이며, 배열이 만들어 진후에 첫번째 항목은 이름이 변경되고 구매가 되었다고 표시된다. 

#### 필수 이니셜라이저(Required Initializers)

`required` 수식어를 클래스 이니셜라이저 앞에 정의하여 해당 클래스의 모든 클래스는 이니셜라이저를 구현해야 한다고 표시한다.

	class SomeClass {
	    required init() {
	        // initializer implementation goes here
	    }
	}

`required` 수식어를 필수 이니셜라이저의 구현 앞에 붙이면 후에 서브클래스 연쇄를 필수적으로 적용된다. 따라서 굳이 `override` 수식어를 오버라이드하는 지정 이니셜라이저에 붙일 필요가 없다.

	class SomeSubclass: SomeClass {
	    required init() {
	        // subclass implementation of the required initializer goes here
	    }
	}

<div class="alert-info">
	상속받은 이니셜라이저가 요구 사항을 충족할 수 있다면 필수 이니셜라이저를 명시적으로 구현하여 가지고 있지 않아도 된다.
</div>

### 클로저나 함수로 기본 속성 값 설정(Setting a Default Property Value with a Closure or Function)

저장 속성의 기본 값은 몇몇의 사용자 정의나 설정이 필요하다면, 속성에 사용자 정의 기본 값을 제공하기 위한 클로저나 전역 함수를 사용할 수 있다. 타입의 새로운 인스턴스에 있는 속성이 초기화되었을 때, 클로저 또는 함수는 호출되고 속성의 기본 값으로 반환 값을 할당한다.

이러한 클로저나 함수의 유형은 일반적으로 속성으로서 같은 타입의 임시 값을 만들거나 원하는 초기 상태로 값을 표현하여 맞추고, 속성의 기본 값으로서 임시 값을 속성의 기본 값으로 사용되게 반환한다.

다음은 클로저가 어떻게 기본 속성 값을 제공할 수 있게 되는지 뼈대가 되는 예제.

	class SomeClass {
	    let someProperty: SomeType = {
	        // create a default value for someProperty inside this closure
	        // someValue must be of the same type as SomeType
	        return someValue
	        }()

클로저 끝에 빈 괄호가 오도록 유의한다. 이는 Swift에 즉시 클로저를 실행하라고 명령한다. 만약 괄호를 생략한다면, 클로저의 반환 값을 할당하는 것이 아니라 속성에 클로저 자체를 할당한다.

<div class="alert-info">
	만약 클로저를 속성 초기화하는데 사용한다면, 인스턴스의 나머지는 클로저가 실행된 시점에서 아직 초기화되지 않았음을 기억해야 한다. 이는 클로저내에서 다른 속성 값을 접근할 수 없다는 의미로, 속성들이 기본 값을 가졌음에도 할 수 없다. 또한, 암시적인 self 속성을 사용할 수 없으며 어떠한 인스턴스 메소드도 호출할 수 없다.
</div>

다음은 Checkerboard라는 구조체로 Checker 게임 보드판을 만든 예제임.

<img src="{{ site.production_url }}/image/2014/09/checkersBoard_2x.png" alt="checkersBoard" style="width: 500px;display: block;margin-left: auto;margin-right: auto;"/><br/>

Checker 게임은 10x10 보드판이며, 흰색, 검은색 사각형을 가진다. 게임판으로 Checkerboard 구조체로 표현되며 boardColors라는 단일 속성을 가지는데 100개의 값의 배열이다. 검은 사각형은 true로 흰색 사각형은 false로 표시된다. boardColors 배열은 클로저로 색상 값이 설정 초기화된다.

	struct Checkerboard {
	    let boardColors: [Bool] = {
	        var temporaryBoard = [Bool]()
	        var isBlack = false
	        for i in 1...10 {
	            for j in 1...10 {
	                temporaryBoard.append(isBlack)
	                isBlack = !isBlack
	            }
	            isBlack = !isBlack
	        }
	        return temporaryBoard
	        }()
	    func squareIsBlackAtRow(row: Int, column: Int) -> Bool {
	        return boardColors[(row * 10) + column]
	    }
	}

새로운 Checkerboard 인스턴스가 생성될 때, 클로저가 실행되고 boardColors의 기본 값은 계산되고 반환된다. 위 예제에서 클로저는 임시 변수인 temporaryBoard에 적합한 색상을 설정하고, 클로저 반환 값으로 임시 배열을 반환하고 설정이 완료된다. 반환된 열은 boardColors에 저장되고 squareIsBlackAtRow 기능 함수로 조회할 수 있다.
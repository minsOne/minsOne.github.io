---
layout: post
title: "[Swift]Automatic Reference Counting 정리"
description: ""
category: "mac/ios"
tags: [swift, ARC, strong, weak, unowned, in, instance, reference type, reference, optional, var, let, strong reference cycle]
---
{% include JB/setup %}

## 자동 참조 계수(Automatic Reference Counting)

Swift는 앱의 메모리 사용을 추적하고 관리하는 자동 참조 계수(ARC)를 사용. 대부분의 경우에 메모리 작업은 잘 작동하며, 메모리 관리를 생각할 필요 없다. ARC는 인스턴스가 더이상 필요가 없을 때 클래스 인스턴스에 사용된 메모리를 자동적으로 해제한다.

몇가지 경우에 ARC는 메모리 순서에서 코드 부분들의 사이 관계에 대한 더 많은 정보가 필요하다. 

<div class="alert-info">
	참조 계수는 클래스의 인스턴스에만 적용되며, 구조체와 열거형은 값 타입이지 참조 타입이 아니며 참조를 저장 못하고 넘기지 못한다.
</div>

### ARC 작업 방법(How ARC Works)

매시간 클래스의 새로운 인스턴스를 만들며, ARC는 인스턴스에 대한 정보를 메모리 덩어리에 저장하기 위해 할당한다. 메모리는 인스턴스의 타입 정보와 저장 속성에 할당된 인스턴스 값을 쥔다. 

게다가 인스턴스가 더이상 필요가 없으면 ARC는 인스턴스에 사용된 메모리를 해제하고 메모리는 다른 목적을 위해 사용되어진다. 더 이상 필요가 없을 때 메모리에는 클래스 인스턴스가 공간을 차지하지 않는다는 확신한다.

그러나 ARC는 사용중에 인스턴스를 할당 해제하면 인스턴스의 속성 접근이나 인스턴스 메소드 호출이 더이상 가능하지 않다. 대신에 인스턴스를 접근하려고 하면, 앱은 크래쉬가 날 수 있다.

인스턴스가 필요한 동안에는 사라지지 않게 하기 위해선, ARC는 많은 속성, 상수 그리고 변수가 현재 각 클래스 인스턴스를 참조하기 위해 추적한다. ARC는 적어도 하나의 활성화 참조가 있는 이상 인스턴스는 할당 해제되지 않고 계속 존재한다.

속성, 상수 또는 변수에 클래스 인스턴스를 할당할 때, 속성, 상수 또는 변수는 인스턴스에 강한 참조를 만든다. "강한" 참조라는 참조는 인스턴스르 강하게 유지하며, 강한 참조가 남아있다면 해당 인스턴스를 할당 해제하지 못한다.

### ARC 사용(ARC in Action)

	class Person {
	    let name: String
	    init(name: String) {
	        self.name = name
	        println("\(name) is being initialized")
	    }
	    deinit {
	        println("\(name) is being deinitialized")
	    }
	}

Person 클래스는 이니셜라이저를 가지며 인스턴스의 name 속성을 설정하고 초기화 진행중이다고 표시하는 메시지를 출력한다. Person 클래스는 디이니셜라이저를 가지며 클래스의 인스턴스가 해제될 때 메시지를 출력한다.

다음은 Person 타입의 세 개 변수를 정의하여 다양한 참조를 설정 사용하는 예제이다.

	var reference1: Person?
	var reference2: Person?
	var reference3: Person?

변수 중 첫번째는 Person 인스턴스를 만들어 할당한다.

	reference1 = Person(name: "John Appleseed")
	// prints "John Appleseed is being initialized"

Person 클래스의 이니셜라이저가 호출되는 시점에 메시지를 출력하는데, 이는 초기화가 확실하게 되었음을 말한다. 

새로운 Person 인스턴스가 reference1 변수에 할당되었기 때문에, reference1에 새로운 Person 인스턴스가 강력참조로 된다. ARC는 Person 인스턴스가 메모리에서 유지되고 할당 해제되지 않도록 한다.

다음은 같은 Person 인스턴스를 나머지 두개의 변수에 할당한다.

	reference2 = reference1
	reference3 = reference1

이제 하나의 Person 인스턴스에 세 개의 강한 참조가 있다. 

만약 강한 참조 중 두개를 nil로 할당하여 깨진다면, 하나의 강력 참조만 남고 Person 인스턴스는 할당 해제되지 않는다.

ARC는 세번째 강력 참조가 깨지기 전까지 Person 인스턴스가 할당 해제되지 않고, 세변째 변수에 nil로 정리하면 Person 인스턴스는 할당 해제 된다.

	reference3 = nil
	// prints "John Appleseed is being deinitialized"

### 클래스 인스턴스 사이의 강력 참조 순환(Strong Reference Cycles Between Class Instances)

ARC는 새로운 인스턴스를 만들고 더 이상 필요 없을 때 Person 인스턴스를 할당 해제하는 참조 수를 추적할 수 있다.

클래스 인스턴스가 강력 참조를 0개 가지지 못하도록 작성해야 한다. 두 클래스 인스턴스가 서로 강력 참조를 쥐고 있다면, 각 인스턴스는 서로 살게 유지한다. 이를 강력 참조 순환이라고 한다.

강력 참조 순환은 강력 참조 대신 약한 참조(weak reference)나 미소유 참조(unowned reference)로 클래스 간의 관계를 정의하여 해결할 수 있다. 

다음은 강력 참조 순환이 발생하는 예제이다.

	class Person {
	    let name: String
	    init(name: String) { self.name = name }
	    var apartment: Apartment?
	    deinit { println("\(name) is being deinitialized") }
	}
	 
	class Apartment {
	    let number: Int
	    init(number: Int) { self.number = number }
	    var tenant: Person?
	    deinit { println("Apartment #\(number) is being deinitialized") }
	}

모든 Person 인스턴스는 문자열 타입의 name 속성과 nil로 초기화되는 옵셔널 apartment 속성을 가진다. apartment 속성은 옵셔널이고, person은 항상 apartment를 가지지 않을 수 있다.

모든 Apartment 인스턴스는 정수 타입의 number 속성과 nil로 초기화되는 옵셔널 tenant 속성을 가진다. tenant 속성은 옵셔널로, apartment는 항상 tenant를 가지지 않을 수 있다.

다음은 옵셔널 타입의 두 변수를 정의하는데 지정된 Apartment와 Person 인스턴스를 가지는데 nil로 우선 초기화된다.

	var john: Person?
	var number73: Apartment?

각각 인스턴스를 만들어 변수에 할당한다.

	john = Person(name: "John Appleseed")
	number73 = Apartment(number: 73)

두 인스턴스가 만들어지고 할당 된 후에 강력 참조가 어떻게 보이는지 다음 그림에서 나타난다. john 변수는 새로운 Person 인스턴스에 강력 참조를 가지며, number73 변수는 새로운 Apartment 인스턴스에 강력 참조를 가진다.

<img src="/../../../../image/2014/09/referenceCycle01_2x.png" alt="referenceCycle01" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

이제 두 인스턴스를 연결하도록 Person는 apartment를 가지고, apartment는 tenant를 가지도록 한다. 느낌표를 사용하여 옵셔널 변수인 john과 number73를 언래핑하고 인스턴스에 접근하여 각 인스턴스의 속성에 설정한다.

	john!.apartment = number73
	number73!.tenant = john

두 인스턴스를 서로 연결한 후에 강력 참조가 보이는 그림이다.

<img src="/../../../../image/2014/09/referenceCycle02_2x.png" alt="referenceCycle02" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

두 인스터느는 강력 참조 순환으로 연결된다. Person 인스턴스는 Apartment 인스턴르를 강력 참조로, Apartment 인스턴스는 Person 인스턴스를 강력 참조로 가진다. 그래서 john과 number73 변수가 쥐고 있는 강력 참조를 끊을 때, 참조 계수는 0으로 떨어지지 않고 ARC는 인스턴스를 할당 해제하지 않는다.

	john = nil
	number73 = nil

디이니셜라이저는 두 변수가 nil로 설정될 때 호출되는데, 강력 참조 순환이 Person와 Apartment 인스턴스가 할당 해제되는 것을 막고, 앱에서 메모리 누수를 야기한다.

다음은 john과 number73이 nil로 설정된 후에 어떻게 강력 참조가 보이는지 나타낸 그림이다.

<img src="/../../../../image/2014/09/referenceCycle03_2x.png" alt="referenceCycle03" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

Person 인스턴스와 Apartment 인스턴스 간의 강력 참조는 끊어지지 않고 남아있다.

### 클래스 인스턴스 간의 강력 참조 순환 해결 방안(Resolving Strong Reference Cycles Between Class Instances)

Swift는 강력 순환 참조를 해결할 수 있는 두가지 방법 - 약한 참조와 미소유 참조가 있다.

약한 참조와 미소유 참조는 참조 순환 안에 있는 인스턴스가 다른 인스턴스에 강한 참조를 유지할 필요 없이 참조한다. 인스턴스는 강력 참조 순환을 만들지 않고 각각을 참조할 수 있다.

약한 참조는 객체가 살아 있는 동안 참조가 nil이 될 때 사용된다. 반면, 미소유 참조는 초기화되는 동안 설정되고 이후에 절대로 nil이 되지 않는다라는 것을 알 때 사용한다.

#### 약한 참조(Weak References)

약한 참조는 인스턴스가 다른 인스턴스 참조를 강력하게 유지하지 않으며, ARC는 참조된 인스턴스를 버리는 것을 멈추지 않게 한다. 이러한 행동은 참조가 강력 참조 순환의 일부가 되는 것을 방지한다. 약한 참조는 속성이나 변수 선언 앞에 `weak` 키워드를 앞에 놓는다.

참조가 어느 순간 "값 없음"을 참조하게 될 때, 약한 참조를 사용하여 참조 순환을 피하도록 한다. 참조가 값을 항상 가진다면, 미소유 참조를 대신 사용한다. 위의 Apartment 예제에서 apartment가 특정 시점에 tenant가 없음을 가지는 것이 적합하면, 약한 참조는 참조 순환을 깨는 적합한 방법이다.

<div class="alert-info">
	약한 참조는 변수에 선언되어야 하고 값은 실행 중에 변경될 수 있음을 나타낼 수 있다. 약한 참조는 상수로 선언될 수 없다.
</div>

약한 참조는 "값 없음"을 가지는 것을 허락되어지며, 옵셔널 타입을 가짐으로서 모든 약한 참조를 선언 해야 한다. Swift에서 옵셔널 타입은 "값 없음"을 위한 가능성을 표현하는 바람직한 방법이다.

약한 참조는 인스턴스를 참조하는 것을 강력하게 쥐는 것을 유지하지 않는데, 약한 참조는 참조하고 있는 동안에 인스턴스를 할당 해제하는 것이 가능하다. 그러므로, ARC는 인스턴스 참조가 할당 해제될 때, 자동적으로 약한 참조는 nil로 설정된다. 다른 옵셔널 값 처럼, 약한 참조에 값이 있는지 확인할 수 있고, 더이상 존재하지 않는 잘못된 인스턴스에 대한 참조는 끝나지 않는다.

다음은 약한 참조로 선언된 Apartment와 Person 인스턴스 예제이다.

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

두 변수(john과 number73)로부터 강력 참조와 두 인스턴스 간의 연결한다.

<img src="/../../../../image/2014/09/weakReference01_2x.png" alt="weakReference01" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

Person 인스턴스는 강력 참조하는 Apartment 인스턴스를 가지지만, Apartment 인스턴스는 약한 참조하는 Person 인스턴스 가진다. 이는 강력 순환 참조가 깨어졌음을 의미한다.

<img src="/../../../../image/2014/09/weakReference02_2x.png" alt="weakReference02" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

Person 인스턴스에 대한 강한 참조가 더이상 없기에 인스턴스는 할당 해제된다.

	john = nil
	// prints "John Appleseed is being deinitialized"

Apartment 인스턴스에 대한 강한 참조는 number73 변수에 대한 것만 남아있다. 강력 참조를 깬다면, Apartment 인스턴스에 대한 강한 참조가 남아있지 않게 된다.

<img src="/../../../../image/2014/09/weakReference03_2x.png" alt="weakReference03" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

Apartment 인스턴스에 강력 참조는 할당 해제된다.

	number73 = nil
	// prints "Apartment #73 is being deinitialized"

number73에 nil 값을 설정하여 Person 인스턴스와 Apartment 인스턴스의 디이니셜라이저는 할당 해제된 메시지를 출력한다. 즉, 강력 순환 참조가 깨어졌음을 의미한다.


#### 미소유 참조(Unowned References)

약한 참조와 비슷하게, 미소유 참조는 인스턴스에 대한 참조를 강하게 하지 않는다. 약한 참조와는 다르게 미소유 참조는 항상 값이 있음을 가정한다. 이는 미소유 참조는 항상 옵셔널이 아닌 타입으로 정의된다. 속성이나 변수 선언 전에 `unowned` 키워드를 붙인다.

미소유 참조는 옵셔널이 아니기 때문에, 사용할 떄마다 미소유 참조를 언래핑할 필요가 없다. 미소유 참조는 항상 직접적으로 접근하는 것이 가능하다. 그러나 ARC는 인스턴스 참조를 할당 해제할 때 참조를 nil로 설정할 수 없다. 이는 옵셔널이 아닌 타입의 변수는 nil로 설정될 수 없기 때문이다.

<div class="alert-info">
	만약 인스턴스 참조가 할당 해제된 후에 미소유 참조에 접근하려고 한다면 런다임 에러가 발생할 것이다. 미소유 참조는 참조가 항상 인스턴스를 참조하고 있음을 확실할 때 사용한다.

	Swift는 앱이 인스턴스 참조가 할당 해제된 후에 직접 접근할 때 크래쉬가 일어난다는 것을 보장함을 주의해야한다. 이 상황에서 예상치 못한 행동은 직면할 수 없다.(즉, 예상된 행동만 직면한다.) 앱은 항상 확실하게 충돌이 발생할 것이다.
</div>

아래는 강력 참조 순환이 잠재적으로 발생하는 두 클래스 예제이다.

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

앞에서 Apartment와 Person 클래스와 유사한 관계를 가지는데, 앞에서는 약한 참조를 사용하였고, 지금은 미소유 참조를 사용한다. CreditCard 클래스의 customer 속성은 미소유 참조를 사용하는데, customer 속성은 Customer 타입의 상수이다. 항상 값을 가지고 있음을 말하는 상수이기 때문에 미소유 참조를 사용하여 강력 참조 순환을 피하도록 한다.

<div class="alert-info">
	CreditCard 클래스의 number 속성은 Int 대신 UInt64 타입으로 정의되었는데 number 속성의 용량은 32-bit와 64-bit 시스템에서 16자리 카드 숫자를 가질 수 있도록 한다.
</div>

다음은 특정 customer에 참조를 저장하도록 한다.

	var john: Customer?

	john = Customer(name: "John Appleseed")
	john!.card = CreditCard(number: 1234_5678_9012_3456, customer: john!)

다음은 두 인스턴스가 연결된 참조를 나타내는 그림이다.

<img src="/../../../../image/2014/09/unownedReference01_2x.png" alt="unownedReference01" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

Customer 인스턴스는 CreditCard 인스턴스에 강력 참조를 가지며, CreditCard 인스턴스는 Customer 인스턴스에 미소유 참조를 가진다.

미소유 customer 참조때문에, john 변수가 가지는 강력 참조를 깨면, Customer 인스턴스에 강력 참조는 더 이상 없다.

<img src="/../../../../image/2014/09/unownedReference02_2x.png" alt="unownedReference01" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

Customer 인스턴스는 강력 참조가 없으므로 할당 해제된다. 그다음에 CreditCard 인스턴스도 강력 참조도 없기 때문에 할당 해제된다.

	john = nil
	// prints "John Appleseed is being deinitialized"
	// prints "Card #1234567890123456 is being deinitialized"

따라서 Customer 인스턴스와 CreditCard 인스턴스의 디이니셜라이저는 john 변수에 nil이 설정된 후에 할당 해제 메시지를 출력한다.


#### 미소유 참조와 암시적인 언래핑된 옵셔널 속성(Unowned References and Implicitly Unwrapped Optional Properties)

초기화가 되면 속성은 nil이라도 값을 가진다고 한다면 미소유 속성을 가진 클래스와 암시적인 언래핑된 옵셔널 속성을 가진 다른 클래스를 결합해야 유용하다.

초기화가 끝나면 참조 직접 속성에 접근 가능하며, 참조 순환을 피할 수 있다. 

다음은 Country와 City라는 클래스를 정의한다. 모든 country는 수도와 도시를 가져야 한다. Country 클래스는 capitalCity 속성을 가지고 City 클래스는 country 속성을 가지도록 하는 예제이다.

	class Country {
	    let name: String
	    let capitalCity: City!
	    init(name: String, capitalName: String) {
	        self.name = name
	        self.capitalCity = City(name: capitalName, country: self)
	    }
	}
	 
	class City {
	    let name: String
	    unowned let country: Country
	    init(name: String, country: Country) {
	        self.name = name
	        self.country = country
	    }
	}

두 클래스 간에 상호 의존성을 설정하기 위해, 이니셜라어저는 Country 인스턴스에 City를 가지게 하고 country 속성에 자기자신을 저장한다.

City 클래스의 이니셜라이저는 Country에 이니셜라이저 안에서 호출된다. 그러나 Country 이니셜라이저는 self를 City 이니셜라이저에 새로운 Country 인스턴스가 완전히 초기화될때까지 넘길 수 없다.

Country의 capitalCity 속성은 암시적인 언래핑된 옵셔널 속성으로 선언하며 타입 끝에 느낌표로 나타낸다. 이는 capitalCity 속성이 기본 값으로 nil을 가짐을 의미하지만 언래핑 할 필요 없이 접근할 수 있다.

capitalCity가 기본 값 nil을 가지기 때문에, 새로운 Country 인스턴스는 이니셜라이저 안에서 name 속성이 설정되어 완전히 초기화 되었다고 간주한다. 이는 Country 이니셜라이저는 참조를 시작하고 name 속성이 설정된 후에 암시적인 self 속성을 넘겨줄 수 있다. Country 이니셜라이저는 Country 이니셜라이저가 자신의 capitalCity 속성을 설정할 때, City 이니셜라이저에 self를 하나의 인자로 넘겨줄 수 있다.

강력 참조 순환 없이 두 클래스간의 관계를 만들 수 있음을 의미한다.

	var country = Country(name: "Canada", capitalName: "Ottawa")
	println("\(country.name)'s capital city is called \(country.capitalCity.name)")
	// prints "Canada's capital city is called Ottawa"

암시적인 언래핑된 옵셔널은 두 클래스 이니셜러이저 필요를 만족시킨다. capitalCity 속성은 초기화가 완료될 때 옵셔널 아닌 값처럼 접근할 수 있고 사용되며, 강력 참조 순환을 피할 수 있다.

### 클로저를 위한 강력 참조 순환(Strong Reference Cycles for Closures)

클래스 인스턴스의 속성에 클로저를 할당하면 강력 참조 순환이 발생하고, 클로저 내에서 인스턴스를 획득한다. 클로저 내에서 self.someProperty 같이 인스턴스의 속성을 접근하거나 클로저가 인스턴스에 self.someMethod() 같은 메소드를 호출하기 때문에 획득이 발생한다. 클로저가 self를 획득하도록 접근하여 강력 참조 순환이 만들어진다.

강력 참조 순환은 클래스와 비슷하게 클로저가 참조 타입이기 때문에 발생한다. 클로저를 속성에 할당하면, 클로저에 참조를 할당한다. 따라서 두 개의 강력 참조가 각각 서로 살아있게 한다. 

Swift는 클로저 획득 목록으로 이 문제를 해결한다.

다음은 강력 참조 순환이 발생하는 예제이다.

	class HTMLElement {
	    
	    let name: String
	    let text: String?
	    
	    lazy var asHTML: () -> String = {
	        if let text = self.text {
	            return "<\(self.name)>\(text)</\(self.name)>"
	        } else {
	            return "<\(self.name) />"
	        }
	    }
	    
	    init(name: String, text: String? = nil) {
	        self.name = name
	        self.text = text
	    }
	    
	    deinit {
	        println("\(name) is being deinitialized")
	    }
	    
	}

HTMLElement 클래스는 name 속성을 정의하며 각 요소의 이름을 나타낸다. HTMLElement 클래스는 옵셔널 text 속성을 정의하며 HTML 요소 안에 문자열을 만들어 표현하여 설정한다.

HTMLElement 클래스는 asHTML이라는 지연 속성을 정의한다. 이 속성은 클로저를 참조하며 name과 text를 HTML 문자열로 결합한다. asHTML 속성은 `() -> String` 타입으로, 인자를 가지지 않고 문자열 값을 반환한다.

기본적으로 asHTML 속성은 클로저가 할당되며 HTML 태그 문자열을 반환한다. 태그는 옵셔널 text 값을 포함한다. 

asHTML 속성은 인스턴스 메소드와 같이 명명되고 사용된다. asHTML이 인스턴스 메소드가 아니라 클로저 속성이기 때문에 asHTML 속성에 기본값을 사용자 클로저로 대체할 수 있다.

<div class="alert-info">
	asHTML 속성은 지연 속성으로 선언되며 항목이 실제로 만들어질 때 사용된다. asHTML이 지연 속성이라는 의미는 기본 클로저 안에 self를 참조할 수 있기 때문인데, 지연 속성은 초기화가 끝나기전까지 접근할 수 없고 self를 알지 못한다.
</div>

다음은 HTMLElement 클래스 인스턴스를 만드는 예제이다.

	var paragraph: HTMLElement? = HTMLElement(name: "p", text: "hello, world")
	println(paragraph!.asHTML())
	// prints "<p>hello, world</p>"

<div class="alert-info">
	paragraph 변수는 옵셔널 HTMLElement로 정의되었는데, nil로 설정하여 강력 참조 순환을 표현 할 수 있도록 한다.
</div>

HTMLElement 클래스는 기본 asHTML에 클로저와 인스턴스 간의 강력 순환 참조가 만들어진다.

<img src="/../../../../image/2014/09/closureReferenceCycle01_2x.png" alt="closureReferenceCycle01" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

인스턴스의 asHTML 속성은 클로저의 강력 참조를 유지한다. 클로저 내에서 self를 참조하기 떄문에 클로저는 self를 획득한다. 이는 강력 참조가 HTMLElement 인스턴스를 유지한다. 강력 참조 순환은 둘 사이 간에 만들어진다.

<div class="alert-info">
	클로저가 여러번 self를 참조하더라도 HTMLElement 인스턴스를 위한 강력 참조는 하나만 획득한다.
</div>

paragraph 변수에 nil을 설정하여 HTMLElement 인스턴스를 위한 강력 참조를 부슨다면 HTMLElement 인스턴스나 클로저는 할당 해제되지 않는데, 이는 강력 참조 순환이기 때문이다.

	paragraph = nil

HTMLElement 디이니셜라이저 안에 메시지가 출력되지 않았는데 이는 HTMLElement 인스턴스가 할당 해제되지 않았음을 보여준다는 것을 유의해야 한다.

### 클로저를 위한 강력 참조 순환 해결(Resolving Strong Reference Cycles for Closures)

클로저와 클래스 인스턴스 간의 강력 참조 순환은 클로저 정의의 한 부분으로 획득 목록을 정의하여 해결한다. 획득 목록은 클로저 내에서 하나 이상의 참조 타입을 획득할 때 사용하는 규칙을 정의한다. 두 클래스 인스턴스 간의 강력 참조 순환은 강력 참조 보다 약한 참조나 미소유 참조로 참조를 획득하게 선언하였다. 

<div class="alert-info">
	Swift는 클로저 내에서 self의 멤버를 참조할 때 self.someProperty나 self.someMethod(somePropery나 someMethod보다)를 작성 요구한다. 이는 self를 획득하여 사고를 막도록 돕는다.
</div>

#### 획득 목록 정의(Defining a Capture List)

획득 목록의 각 항목은 self나 someInstance같은 클래스 인스턴스와 참조간의 약한 참조 또는 미소유 참조의 쌍이다 

클로저 인자 목록과 반환 타입 앞에 획득 목록을 붙인다.

	lazy var someClosure: (Int, String) -> String = {
	    [unowned self] (index: Int, stringToProcess: String) -> String in
	    // closure body goes here
	}

만일 특정 인자나 반환 타입이 없다면, 컨텍스트로부터 추론할 수 있기 때문에 클로저의 시작 부분에 획득 목록을 위치하고 `in` 키워드가 뒤따른다.

	lazy var someClosure: () -> String = {
	    [unowned self] in
	    // closure body goes here
	}

#### 약한 참조와 미소유 참조(Weak and Unowned References)
클로저와 인스턴스가 항상 서로를 참조하고 항상 같은 시간에 할당 해제될 때, 클로저에 미소유 참조로서 획득을 정의한다.

반면 획득된 참조가 나중에 nil이 될 때, 클로저에 약한 참조로서 획득을 정의한다. 약한 참조는 항상 옵셔널 타입이며 인스턴스 참조가 해제될 때 자동으로 nil이 되기 때문이다. 클로저 내에서 인스턴스가 존재하는지 검사하는 것이 가능하다.

<div class="alert-info">
	획득된 참조는 절대로 nil이 되지 않는다면, 약한 참조보단 미소유 참조로 되어야 한다.
</div>

미소유 참조는 HTMLElement 예제 안에서 강력 참조 순환을 해결하는 적합한 획득 방법이다.

	class HTMLElement {
	    
	    let name: String
	    let text: String?
	    
	    lazy var asHTML: () -> String = {
	        [unowned self] in
	        if let text = self.text {
	            return "<\(self.name)>\(text)</\(self.name)>"
	        } else {
	            return "<\(self.name) />"
	        }
	    }
	    
	    init(name: String, text: String? = nil) {
	        self.name = name
	        self.text = text
	    }
	    
	    deinit {
	        println("\(name) is being deinitialized")
	    }
	    
	}

HTMLElement 구현은 이전 구현과는 다르게 asHTML 클로저 안에 획득 목록이 추가되었다. 이 경우에 획득 목록은 [unowned self]로 "강력 참조보다 미소유 참조로서 self를 획득한다" 라는 의미이다.

	var paragraph: HTMLElement? = HTMLElement(name: "p", text: "hello, world")
	println(paragraph!.asHTML())
	// prints "<p>hello, world</p>"

다음은 획득 목록을 통한 클로저와 인스턴스 간 참조가 보이는 그림이다.

<img src="/../../../../image/2014/09/closureReferenceCycle02_2x.png" alt="closureReferenceCycle02" style="width: 600px;display: block;margin-left: auto;margin-right: auto;"/><br/>

클로저에 미소유 참조는 HTMLElement 인스턴스가 더이상 강하게 유지되지 않게 한다. 만약 paragraph 변수에 nil로 강한 참조를 설정하면 HTMLElement 인스턴스는 할당 해제되고 디이니셜라이저 메시지가 출력된다.

	paragraph = nil
	// prints "p is being deinitialized"
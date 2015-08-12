---
layout: post
title: "[Swift]Class와 Structure 정리"
description: ""
category: "mac/ios"
tags: [swift, reference, variable, constants, function, dot, enumerations, class, structure, Identity Operator, encapsulate, instance, value type, reference type, property, Assignment, copy]
---
{% include JB/setup %}

## 클래스와 구조체(Classes and Structures)

클래스와 구조체는 프로그램 코드 블럭을 만들도록 유연하게 구성하는 것이 일반적인 목적임. 속성과 메소드는 클래스와 구조체에 상수, 변수, 함수로서 동일한 구문을 정확하게 사용하여 기능을 추가하도록 정의함.

와다른 프로그래밍 언어와는 달리 Swift는 사용자 클래스와 구조체를 위한 인터페이스 파일과 구현 파일을 나누어 만들 필요가 없음. 단일 파일에 클래스나 구조체를 정의하고, 외부 인터페이스로 다른 코드에 사용하기 위한 클래스와 구조체는 자동으로 만들어 짐.

<div class="alert-info">
클래스 인스턴스는 전통적으로 객체로 알려져있음. 그러나 Swift 클래스와 구조체는 다른 언어보다도 기능에 더 가까우며 이 챕터 대부분은 클래스나 구조체 타입의 인스턴스를 적용할 수 있는 기능을 설명함. 이 때문에, 일반적인 용어로 인스턴스가 사용됨.</div>

### 클래스와 구조체 비교(Comparing Classes and Structures)

Swift에서 클래스와 구조체는 비슷한 점을 많이 가지고 있음.

* 값을 저장하는 속성을 정의
* 기능을 제공하는 메소드를 정의
* 서브스크립트 구문을 사용하여 값을 접근할 수 있는 서브스크립트를 정의
* 초기 상태를 설정하는 초기화를 정의
* 기본적인 구현을 넘어선 기능을 확장시킬 수 있도록 확장이 가능함.
* 특정 종류의 표준 기능을 제공하는 프로토콜을 따름.

<div class="alert-info">
코드에 구조체가 전달될 때 항상 복사되며, 참조 카운팅(reference counting)을 사용하지 않음.
</div>

#### 정의 문법(Definition Syntax)

클래스와 구조체는 유사한 정의 문법을 가지며 class는 `class` 키워드를, 구조체는 `struct` 키워드를 사용함. 

	class SomeClass {
	    // class definition goes here
	}
	struct SomeStructure {
	    // structure definition goes here
	}

<div class="alert-info">
새로운 클래스나 구조체를 정의할 때, 특유의 새로운 Swift 타입을 효율적으로 정의할 수 있음. UpperCamelCase 이름(someClass와 someStructure) 타입은 표준 Swift 타입(String, Int와 Bool)의 대문자와 일치함. 거꾸로 말하면, 속성과 메소드는 lowerCamelCase 이름(frameRate, incrementCount)로 타입 이름과는 구분이 되도록 해야 함.
</div>

다음은 구조체와 클래스 정의 예제.

	struct Resolution {
	    var width = 0
	    var height = 0
	}
	class VideoMode {
	    var resolution = Resolution()
	    var interlaced = false
	    var frameRate = 0.0
	    var name: String?
	}

이 예제에서 Resolution 구조체는 픽셀 기반 해상도를 설명함. 이 구조체에서 width와 height 라는 두 개의 저장 속성을 가짐. 이 저장 속성은 클래스나 구조체의 한 부분으로서 구성되고 저장되는 상수나 변수임. 이 두 개 속성은 초기 값 0으로 설정되어 타입 Int로부터 추론됨.

VideoMode라는 새로운 클래스는 비디오 화면을 위한 특정 비디오 모드를 서명함. 이 클래스는 네 개의 저장 속성을 가짐. 첫번째 resolution은 Resolution 구초제 인스턴스로 초기화되며, Resolution 타입 속성으로 추론됨. 다른 세 개 속성에서 VideoMode 인스턴스는 interlaced가 false로, frameRate은 0.0으로, name은 옵셔널 String 값으로 초기화됨. name 속성은 기본 값 nil로 주어지며, 이는 옵셔널 타입이기 때문임.

#### 클래스와 구조체 인스턴스(Class and Structure Instance)

Resolution 구조체와 VideoMode 클래스 정의는 오직 Resolution 또는 VideoMode가 보이는 것만 설명하며 특정 해상도나 비디오 모드를 설명하지 않음. 그렇기 때문에 구조체나 클래스 인스턴스를 만들 필요가 있음.

구조체와 클래스는 인스턴스를 생성하는 문법이 매우 유사함.

	let someResolution = Resolution()
	let someVideoMode = VideoMode()

구조체와 클래스는 새로운 인스턴스를 위해 초기화 문법을 사용함. 초기화 문법의 가장 단순한 형태는 클래스나 구조체의 이름 타입에 빈 괄호를 Resolution()이나 VideoMode() 처럼 사용하는 것임. 클래스나 구조체의 새로운 인스턴스를 생성하며, 모든 속성은 기본 값으로 초기화함.

#### 속성 접근하기(Accessing Properties)

점(dot, .) 구문을 사용하여 인스턴스의 속성을 접근할 수 있음. 

점 구문으로 인스턴스 이름 뒤에 공백 없이 점으로 분리하여, 바로 속성 이름을 씀.

	println("The width of someResolution is \(someResolution.width)")
	// prints "The width of someResolution is 0"

이 예제에서 someResolution.width는 someResolution의 width 속성을 참고하며 기본 초기 값 0을 반환함.

VideoMode의 Resolution 속성에 width 속성 같은 내부 속성으로 들어갈 수 있음.

	println("The width of someVideoMode is \(someVideoMode.resolution.width)")
	// prints "The width of someVideoMode is 0"

또한, 점 구문을 사용하여 변수 속성에 새로운 값을 할당할 수 있음.

	someVideoMode.resolution.width = 1280
	println("The width of someVideoMode is now \(someVideoMode.resolution.width)")
	// prints "The width of someVideoMode is now 1280"

<div class="alert-info">
Objective-C와는 다르게, Swift는 직접 구조체 속성의 내부 속성을 설정하는 것이 가능함. 마지막 예제에서 someVideoMode의 resolution 속성의 width 속성은 직접 설정하며 resolution 속성 전체에 새로운 값을 설정할 필요가 없음.
</div>

#### 구조체 타입을 위한 멤버들의 초기화(Memberwise Initializers for Structure Types)

모든 구조체는 자동 생성된 멤버 초기화를 가지며, 이는 새로운 구조체 인스턴스의 멤버 속성을 초기화 하도록 사용할 수 있음. 새로운 인스턴스의 속성을 위한 초기 값은 이름을 멤버 초기화에다 넘겨줌.

	let vga = Resolution(width: 640, height: 480)

구조체와는 다르게 클래스 인스턴스는 기본 멤버 초기화를 받지 않음.

### 구조체와 열거형은 값 타입(Structures and Enumerations Are Value Type)

값 타입은 타입이며 이 값은 상수나 변수에 할당하거나 함수에 넘겨질 때 복사가 됨.

이전 챕터까지 넓게 값 타입에 대해서 사용하였음. 실제로 Swift에선 기본 타입인 정수형, 부동 소수점, 논리형, 문자열, 배열, 딕셔너리는 모두 값 타입이며, 뒤에 구조체로 구현되어 있음.

Swift에서 모든 구조체와 열거형은 값 타입임. 이 의미는 생성하는 모든 구조체와 열거형 인스턴스 - 모든 값 타입은 속성으로 가짐 - 는 코드 내에 전달될 때 항상 복사됨을 의미.

	let hd = Resolution(width: 1920, height: 1080)
	var cinema = hd

위 예제에서 hd라는 상수는 Resolution 인스턴스로 풀 HD 비디오 크기로 초기화되어 선언되었음.

cinema라는 변수는 hd의 현재 값으로 설정되어 선언됨. Resolution은 구조체이고 기존 인스턴스의 복사본이 만들어져, 이 복사본이 cinema에 할당됨. 심지어 hd와 cinema는 같은 크기를 가지더라도 뒷단에서는 전혀 다른 인스턴스임.

다음으로 cinema의 width 속성은 디지털 시네마 프로젝트로 slightly-wider 2K 표준 가로로 수정하는 예제임.

	cinema.width = 2048

cinema의 width 속성이 변경되었는지 확인할 수 있음.

	println("cinema is now \(cinema.width) pixels wide")
	// prints "cinema is now 2048 pixels wide"

그러나 기존 hd 인스턴스의 width 속성은 여전히 이전 값 1920을 가짐.

	println("hd is still \(hd.width) pixels wide")
	// prints "hd is still 1920 pixels wide"

hd의 현재 값을 cinema에 줬을 때, 새로운 cinema 인스턴스로 hd에 저장된 값이 복사가 되었음. 같은 정수 값을 포함하여 가지고 있더라도, 끝에는 두개의 완전히 분리된 인스턴스로 되었음. 따라서 분리된 인스턴스는 hd에 저장된 가로가 2048로 설정된 cinema의 가로에 아무런 영향을 주지 않았음.

열거헝에 같은 방식을 적용한 예제임.

	enum CompassPoint {
	    case North, South, East, West
	}
	var currentDirection = CompassPoint.West
	let rememberedDirection = currentDirection
	currentDirection = .East
	if rememberedDirection == .West {
	    println("The remembered direction is still .West")
	}
	// prints "The remembered direction is still .West"

rememberedDirection은 currentDirection 값이 할당 될 때, 실제로 복사본을 설정함. currentDirection 값이 변경하더라도 rememberedDirection에 저장된 기존 값에는 영향을 끼치지 않음.

### 클래스는 참조 타입(Classes Are Reference Types)

값 타입과는 다르게 참조 타입은 변수나 상수에 할당하거나 함수에 넘길 때 복사하지 않음. 복사 대신에 기존에 같은 인스턴스에 참조가 사용됨.

다음은 VideoMode 클래스 정의 사용임.

	let tenEighty = VideoMode()
	tenEighty.resolution = hd
	tenEighty.interlaced = true
	tenEighty.name = "1080i"
	tenEighty.frameRate = 25.0

tenEighty라는 새로운 상수는 VideoMode 클래스의 새로운 인스턴스를 참조하도록 설정하고 선언함. 비디오 모드는 HD 1920 x 1080 해상도와 interlaced를 설정하고 "1080i" 이름이 주어졌음. 마지막으로 초당 25 프레임의 프레임 비율을 설정함.

다음으로 tenEighty을 새로운 상수 alsoTenEighty에 할당하고 alsoTenEighty 프레임 비율을 수정함.

	let alsoTenEighty = tenEighty
	alsoTenEighty.frameRate = 30.0

클래스는 참조 타입이기때문에, tenEighty와 alsoTenEighty는 실제로 같은 VideoMode 인스턴스를 참조함. 사실상 동일한 하나의 인스턴스를 두 개의 다른 이름으로 가짐.

tenEighty 속성의 frameRate 속성을 확인하여 30 프레임 비율이 나오는지 확인하는 예제임.

	println("The frameRate property of tenEighty is now \(tenEighty.frameRate)")
	// prints "The frameRate property of tenEighty is now 30.0"

tenEighty와 alsoTenEighty은 변수가 아닌 상수로 선언되었음. 그러나 tenEighty.frameRate와 alsoTenEighty.frameRate는 변경할 수 있는데, 이는 tenEighty와 alsoTenEighty 상수의 값은 실제로 변경되지 않았기 때문임. tenEighty와 alsoTenEighty는 VideoMode 인스턴스를 저장하는 것이 아니고 참조만 하는 것임. 잠재적인 VideoMode에 frameRate는 변경되지만 VideoMode에 상수 참조 값은 변경되지 않음.

#### Identity Operators

클래스는 참조 타입이기 때문에 여러 상수나 변수가 같은 하나의 클래스 인스턴스를 참조하는 것이 가능함.(구조체와 열거형에서는 상수와 변수로 할당되거나 함수로 넘길 때 항상 값이 복사가 되기 때문에 같지 않음.)

식별 연산자는 두 개의 상수나 변수가 같은 클래스 인스턴스를 참조하는지 찾을 때 유용함.

* 동일한(===)
* 동일하지 않은(!==)

두 상수나 변수가 같은 인스턴스를 참조하는지 확인하는 연산자 예제.

	if tenEighty === alsoTenEighty {
	    println("tenEighty and alsoTenEighty refer to the same VideoMode instance.")
	}
	// prints "tenEighty and alsoTenEighty refer to the same VideoMode instance."

"동일한"(===)는 "같은"(==)과는 같은 의미가 아님.

* "동일한" 의미는 클래스 타입의 두 상수나 변수가 정확하게 같은 클래스 인스턴스를 참조한다는 의미.
* "같은" 의미는 두 인스턴스가 같은 값을 가지고 있음을 의미함.

#### 포인터(Pointer)

C, C++, Objective-C에서, 메모리 주소를 참조하기 위해 포인터를 사용함. C에 포인터와 유사하게 Swift 상수나 변수는 특정 참조 타입의 인스턴스를 참조하지만, 메모리 주소에 직접 가르키진 않으며, 참조를 만들 때 별표(*)를 사용하여 나타낼 필요가 없음. 

대신 참조는 Swift의 다른 상수나 변수처럼 정의됨.

### 클래스와 구조체 중 선택하기(Choosing Between Classes and Structures)

프로그램 코드의 구성된 블럭으로서 사용자 데이터 타입으로 정의하는 클래스나 구조체를 사용할 수 있음.

그러나 구조체 인스턴스는 값을 항상 넘기며, 클래스 인스턴스는 항상 참조를 넘겨줌. 이 의미는 서로 다른 작업의 종류에 적합하다는 의미. 프로젝트에 필요한 데이터 구조와 기능을 고려하여, 각각의 데이터는 클래스나 구조체로 정의하도록 구성해야 함.

구조체를 생성 시 아래의 조건에 한 가지 이상일 경우 적용하면 좋음.

* 구조체의 최우선 목표는 몇몇 단순 데이터 값을 캡슐화 하는 경우
* 캡슐화된 값이 그 구조체의 인스턴스가 할당되거나 넘겨질 때 참조보다 복사하는 것일 경우
* 구조체에 저장되는 값 속성이 참조보다 복사가 예상되는 값 타입인 경우
* 다른 기존 타입에서 기능이나 속성이 상속될 필요가 없는 경우

다음은 구조체가 포함하면 좋은 속성 예제.

* Double 타입인 width 속성과 height 속성을 캡슐화하는 기하학 모형의 크기
* Int 타입인 start 속성과 length 속성을 캡슐화하는 시리즈의 범위를 참조하는 방법
* Double 타입인 x, y와 z 속성을 캡슐화하는 3D 좌표 시스템.

### 문자열, 배열 그리고 딕셔너리를 위한 할당과 복사(Assignment and Copy Behavior for Strings, Arrays and Dictionaries)

Swift의 문자열, 배열 그리고 딕셔너리 타입은 구조체로서 구현되었음. 문자열, 배열 그리고 딕셔너리는 새로운 상수나 변수에 할당하거나 함수나 메소드에 넘겨줄 때 복사되다는 의미.

이러한 행동은 Foundation에 NSString, NSArray 그리고 NSDictionary과는 다른데 이 것들은 구조체가 아니라 클래스로 구현이 되었음. NSString, NSArray 그리고 NSDictionary 인스턴스는 복사보단 기존 인스턴스에 참조를 언제나 할당하고 넘겨줌.

<div class="alert-info">
위 설명은 문자열, 배열 그리고 딕셔너리의 "복사"를 참조함. 항상 복사본이 위치해있음으로서 항상 보는 행동을 함.(??) 그러나 Swift는 이러한 작업이 필요할 때 실제로 뒷단에서 복사하는 작업을 함. Swift는 최적화 작업으로 값 복사를 보증하며, 이 최적화 작업을 선점하도록 노력하기 위해 할당을 피함.
</div>
---
layout: post
title: "Swift - Access Control 정리"
description: ""
category: "mac/ios"
tags: [swift, access control, private, internal, public, protocol, extension, type, access level]
---
{% include JB/setup %}

## 접근 제어(Access Control)

접근 제어는 다른 소스 파일과 모듈에 코드로부터 코드의 일부에 접근을 제한한다. 코드의 상세 구현을 숨기며, 코드가 접근하고 사용하도록 바람직한 인터페이스를 지정한다. 

지정한 접근 수준을 개별적인 타입(클래스, 구조체, 열거형)에 할당 할 수 있으며, 뿐만 아니라 이들 타입이 속한 속성, 메소드, 이니셜라이저 그리고 서브스크립트도 포함한다. 프로토콜은 전역 상수, 변수 그리고 함수 같은 특정 컨텍스트로 제한될 수 있다.

접근 제어의 다양한 수준을 제공할 뿐만 아니라, Swift는 전형적인 시나리오에서 기본 접근 수준 제공을 제공함으로써 명시적인 접근 제어 수준을 지정하는 필요를 줄인다. 사실 단일 타겟 앱을 만든다면 명시적인 접근 제어 수준을 지정할 필요가 없을 수도 있다.

<div class="alert-info">
	간략하게 다양한 방면에서 속성, 타입, 함수 등이 시나리오에서 실체를 참조하도록 접근 제어를 접근할 수 있다.
</div>

### 모듈과 소스 파일(Modules and Source Files)

Swift의 접근 제어 모델은 모듈과 소스파일의 개념이 기반이다.

모듈은 코드 배포의 하나의 단위이다. - 프레임워크나 어플리케이션은 하나의 실체로서 만들고 적재하며 Swift의 `import` 키워드와 같이 다른 모듈을 가져올 수 있다.

Xcode에서 각각의 빌드 타겟은 Swift에 나뉜 모듈로서 다뤄진다. 만약 독립 프레임워크로서 앱 코드의 형태를 같이 묶는다면, - 아마 여러 앱에 코드를 캡슐화하고 재사용을 하기 위해 - 앱에서 가져오고 사용될 때 또는 다른 프페임워크 안에서 사용될 때 프레임워크는 분리한 모듈의 부분으로서 정의한다.

소스 파일은 모듈 내에 하나의 Swift 소스 코드 파일이다(사실상 앱이나 프레임워크 내에서 단일 파일). 별도의 소스 파일에 개개의 타입을 정의하는 것이 일반적이지만, 하나의 소스 파일은 여러 타입, 함수 등을 위한 정의를 포함할 수 있다.

### 접근 수준(Access Levels)

Swift는 코드 내에서 실체를 위한 세 가지 다른 접근 수준을 제공한다. 이들 접근 수준은 실체가 정의 되는 것에 소스 파일이 관련있고, 소스 파일 속에 모듈에도 관련있다.

* Public 접근은 실체가 정의 모듈에서 모든 소스 파일 내에서 사용될 수 있으며, 정의 모듈을 가지고 온 다른 모듈로부터 소스 파일 내에서도 사용될 수 있다. 보통 프레임워크에 대한 public 인터페이스를 지정할 때 공용 접근을 사용한다.
* Internal 접근은 실체가 정의 모듈에서 모든 소스 파일 내에서 사용될 수 있지만 모듈의 밖으로 소스 파일이 사용되지 않는다. 보통 앱이나 프레임워크의 내부 구조체를 정의할 때 internal 접근을 사용한다.
* Private 접근은 정의 소스 파일의 실체의 사용을 제한한다. private 접근은 기능의 지정된 부분의 구현 상세를 숨길 때 사용한다.

Public 접근은 높은 제어 수준(제약이 없는)이고 Private 접근은 낮은 접근 수준(제약이 많은)이다.

#### 접근 수준의 지도 원칙(Guiding Principle of Access Levels)

Swift에서 접근 수준은 전반적인 지도 원칙을 따른다. 실체는 낮은 제어 수준(제약이 많은) 다른 실체의 관점에서 정의할 수 없다.

* public 변수는 internal이나 private 타입을 갖도록 정의되지 않는다. 이는 타입이 모든 장소에서 사용되지 못할 수 있기 때문에 public 변수가 사용된다.
* 함수는 인자 타입과 반환 타입보다 높은 접근 제어를 가지지 못한다. 이는 함수는 구성 타입이 코드로 둘러 쌓인 곳에서 사용되기 때문이다.

#### 기본 접근 수준(Default Access Levels)

코드에 모든 실체는 명확한 접근 수준을 지정하지 않으면 내부의 기본 접근 수준을 가진다. 그 결과 많은 경우에 명확한 접근 수준을 지정할 필요가 없다.

#### 단일 타켓 앱을 위한 접근 수준(Access Levels for Single-Target Apps)

간단한 단일 타겟 앱을 만든다면 앱 내에서 자기 자신의 코드가 포함되며 앱 모듈의 밖에서 사용하도록 만들 필요가 없다. 내부의 기본 접근 수준은 이미 요구사항과 준수한다. 그러므로 사용자 접근 수준을 지정할 필요가 없다. 그러나 앱 모듈 내에 다른 코드로부터 구현 상세를 숨기고자 private로 표시하길 원할수도 있다.

#### 프레임워크를 위한 접근 수준(Access Levels for Frameworks)

프레임워크를 개발할 때, 다른 모듈에 보이고 접근되도록 public으로서 프레임워크에 공용 직면 인터페이스로 표시한다. 공용 직면 인터페이스는 프레임워크를 위한 어플리케이션 프로그래밍 인터페이스(또는 API)이다.

<div class="alert-info">
	프레임워크의 internal 구현 상세는 internal의 기본 접근 수준으로 사용하거나 프레임워크의 internal 코드의 일부를 숨기길 원하면 private로 표시할 수 있다. 프레임워크의 API 부분이 되도록 하길 원하면 public으로 실체를 표시한다.
</div>

### 접근 제어 문법(Access Control Syntax)

`public`, `internal` 또는 `private` 수식어 중 하나를 놓아 실체의 도입부 앞에 놓아 접근 수준을 정의한다.

	public class SomePublicClass {}
	internal class SomeInternalClass {}
	private class SomePrivateClass {}
	 
	public var somePublicVariable = 0
	internal let someInternalConstant = 0
	private func somePrivateFunction() {}

기본 접근 수준은 `internal`이며, 이는 SomeInternalClass와 someInternalConstant는 명확한 접근 수준 수식어가 필요없이 작성되며, internal의 접근 수준을 가진다.

	class SomeInternalClass {}              // implicitly internal
	var someInternalConstant = 0            // implicitly internal

### 사용자 타입(Custom Types)

만약 사용자 타입을 위한 명확한 접근 수준을 지정하길 원하면 타입을 정의하는 시점에 해야 한다. 새로운 타입은 접근 수준이 어디에서나 사용되도록 용인되어 사용한다. private 클래스를 정의한다면, 클래스는 private 클래스가 정의된 소스 파일 안에서 속성의 타입이나 함수 인자 또는 반환 타입으로서 사용된다.

타입의 접근 제어 수준은 타입의 멤버(속성, 메소드, 이니셜라이저 그리고 서브스크립트)의 기본 접근 수준에도 영향을 미친다. 만약 private로서 타입의 접근 수준을 정의하면, 멤버의 기본 접근 수준도 private가 된다. 만약 internal 또는 public으로 타입의 접근 수준을 정의한다면, 타입의 멤버에 기본 접근 수준은 internal이 된다.

	public class SomePublicClass {          // explicitly public class
	    public var somePublicProperty = 0    // explicitly public class member
	    var someInternalProperty = 0         // implicitly internal class member
	    private func somePrivateMethod() {}  // explicitly private class member
	}
	 
	class SomeInternalClass {               // implicitly internal class
	    var someInternalProperty = 0         // implicitly internal class member
	    private func somePrivateMethod() {}  // explicitly private class member
	}
	 
	private class SomePrivateClass {        // explicitly private class
	    var somePrivateProperty = 0          // implicitly private class member
	    func somePrivateMethod() {}          // implicitly private class member
	}

#### 튜플 타입(Tuple Types)

튜플 타입에서 접근 수준은 튜플에 사용되는 모든 타입의 가장 제한적인 접근 수준이다. 다른 두 개의 타입은 internal 접근과 private 접근을 가지는데 이로부터 튜플을 구성한다면, 결합된 튜플 타입의 접근 수준은 private가 된다.

<div class="alert-info">
	튜플 타입은 클래스, 구조체, 열거형 그리고 함수와 방법의 단독 정의를 가지지 않는다. 튜플 타입의 접근 수준은 튜플 타입이 사용되고 명시적으로 지정되지 않을 때 자동으로 추론된다.
</div>

#### 함수 타입(Function Types)

함수 타입을 위한 접근 수준은 함수의 인자 타입과 반환 타입의 가장 제한적인 접근 수준으로서 계산된다. 함수의 계산된 접근 수준이 상황에 맞는 기본과 준수하지 않으면, 함수의 정의의 한 부분으로서 접근 수준을 명시적으로 지정해야 한다.

다음은 접근 수준 수식어 없는 함수 예제이다. 기본적인 접근 수준이 internal로 예상되지만 아래 예제에서는 그렇지 않다.

	func someFunction() -> (SomeInternalClass, SomePrivateClass) {
	    // function implementation goes here
	}

someFunction은 컴파일되지 않는다. 함수의 반환 값이 튜플 타입으로 두 개의 사용자 클래스로부터 결합되어 있다. 이들 클래스 중 하나는 `internal`로 정의되었고, 나머지 하나는 `private`로 정의되었다. 그러므로 결합된 튜플 타입의 전체적인 접근 수준은 `private`이다.(튜플의 구성 타입의 최소한 접근 수준)

함수의 반환 타입이 `private`이기 떄문에, 함수의 전체적인 접근 수준을 `private` 수식어로 표시해야 함수 선언이 유효하게 된다.

	private func someFunction() -> (SomeInternalClass, SomePrivateClass) {
	    // function implementation goes here
	}

someFunction 정의는 `public` 또는 `internal` 수식어 또는 기본 internal 설정 사용으로 표시하면 유효하지 않다. 이는 함수의 public 또는 internal 유저는 함수 반환 타입에서 private 클래스에 적합한 접근을 하지 못한다.

#### 열거형 타입(Enumeration Types)

열거형의 각각의 경우 자동적으로 같은 접근 수준이 된다. 개별적인 열거형 경우에 다른 접근 수준으로 지정할 수 없다.

	public enum CompassPoint {
	    case North
	    case South
	    case East
	    case West
	}

North, South, East, West는 CompassPoint 클래스의 접근 수준인 public을 따르기 때문에 각 경우의 접근 수준은 public이 된다.

#### 원시 값과 연관 값(Raw Values and Associated Values)

열거형 정의에 원시 값 또는 연관 값에 사용되는 타입은 열거형의 접근 수준으로 적어도 높은 접근 수준을 가져야 한다. 열거형의 원시 값 타입으로 `private` 타입은 사용할 수 없고 `internal` 접근 수준이다.

#### 중첩 타입(Nested Types)

중첩 타입은 자동적인 private 접근 수준을 가지는 private 타입 안에서 정의한다. 중첩 타입은 internal의 자동 접근 수준을 가지는 public 타입 또는 internal 타입 안에서 정의한다. 만약 public 타입 내에서 중첩 타입을 원한다면 public으로 중첩 타입을 명시적으로 선언해야 한다.

### 서브클래스싱(Subclassing)

현재 접근 맥락에서 접근할 수 있는 클래스를 서브클래싱 할 수 있다. 서브클래스는 슈퍼클래스보다 더 높은 접근 수준을 가질 수 없다. - 예를 들어 internal 슈퍼클래스의 public 서브클래스로 쓸 수 없다.

게다가 특정 접근 맥락에서 볼 수 있는 모든 클래스 멤버(메소드, 속성, 이니셜라이저 또는 서브스크립트)를 오버라이드 할 수 있다.

오버라이드는 슈퍼클래스 버전 보다 더 접근성 있는 상속받은 클래스 멤버를 만들 수 있다. 

	public class A {
	    private func someMethod() {}
	}
	 
	internal class B: A {
	    override internal func someMethod() {}
	}

클래스 A는 public 클래스이고 someMethod라는 private 메소드를 가진다. 클래스 B는 A의 서브클래스이고 "internal"의 접근 수준을 감소된다. 그럼에도 불구하고 클래스 B는 someMethod를 오버라이드로 internal 접근 수준으로 제공하며, 이는 원래 someMethod의 구현보다 더 높은 수준이다.

심지어 서브클래스 멤버가 서브클래스 멤버보다 낮은 접근 권한을 갖는 슈퍼클래스 멤버를 호출하는 것은, 허용된 접근 수준 맥락 내에서 발생한 슈퍼클래스의 멤버를 호출하는 것이다.

	public class A {
	    private func someMethod() {}
	}
	 
	internal class B: A {
	    override internal func someMethod() {
	        super.someMethod()
	    }
	}

슈퍼클래스 A와 서브클래스 B는 같은 소스 파일 안에서 정의되었기 때문에, 클래스 B의 someMethod 구현은 super.someMethod() 호출하는 것이 유효하다.

### 상수, 변수, 속성 그리고 서브스크립트(Constants, Variables, Properties, and Subscripts)

상수, 변수 또는 변수는 이들 타입보다 더 public이 되지 못한다. 이는 private 타입으로 public 속성을 작성하는 것이 유효하지 않다. 유사하게 서브스크립트는 인덱스 타입 또는 반환 타입 보다 더 public이 되지 못한다.

만약 상수, 변수, 속성 또는 서브스크립트가 private 타입, 상수, 변수, 속성 또는 서브스크립트의 사용은 private로 표시되도록 한다.

	private var privateInstance = SomePrivateClass()

#### Getters와 Setters

상수와 변수, 속성 그리고 서브스크립트를 위한 getter와 setter는 자동적으로 상수, 변수, 속성 또는 서브스크립트가와 같은 접근 레벨을 받는다.

setter는 대응하는 getter보다 더 낮은 접근 수준을 가지며, 변수, 속성, 또는 서브스크립트의 읽기-쓰기 범위를 제한한다. `var` 또는 `subscript` 소개자 앞에 `private(set)` 또는 `internal(set)`으로 낮은 접근 수준을 할당한다.

<div class="alert-info">
	이 규칙은 저장 속성 뿐만 아니라 계산 속성에도 적용된다. 심지어 저장 속성을 위한 명시적인 getter와 setter를 쓰지 않더라도 말이다. Swift는 계속 저장 속성의 백업 저장공간을 접근하기 위한 암시적인 getter와 setter로 종합한다. 계산 속성에 명시적인 setter와 같은 방법으로 <code>private(set)</code>과 <code>internal(set)</code>이 합쳐진 setter의 접근 수준을 변경하는데 사용한다.
</div>

다음은 TrackedString이라는 구조체 예제로 문자열이 몇번이나 변경되었는지 추적하는 예제이다.

	struct TrackedString {
	    private(set) var numberOfEdits = 0
	    var value: String = "" {
	        didSet {
	            numberOfEdits++
	        }
	    }
	}

TrackedString 구조체는 value라는 저장 문자열 속성을 정의하고 ""로 초기화한 값을 갖는다. 또한 구조체는 numberOfEdits이라는 저장 정수 속성을 정의하며 value가 몇번 변경되었는지 추적하도록 사용된다. didSet 속성으로 구현된 수정 추적은 value 속성을 감시하고 value 속성이 새로운 값으로 설정될 때 마다 numberOfEdits가 증가한다.

TrackedString 구조체와 value 속성은 명시적인 접근 수준 수식어를 제공하지 않지만, internal의 기본 접근 수준을 받는다. 그러나 numberOfEdits 속성을 위한 접근 수준은 `private(set)`으로 표시하여 TrackedString 구조체의 정의로서 같은 소스 파일 내에서 속성을 설정하도록 나타낸다. 속성의 getter는 internal의 기본 접근 수준을 여전히 가지지만, setter는 TrackedString이 정의된 소스 파일에 private가 된다. 내부적으로 numberOfEdits 속성을 수정하기 위해 TrackedString이 할 수 있으나, 같은 모듈 내에 다른 소스 파일로 사용될 때 읽기-전용 속성으로 속성을 표현할 수 있다.

TrackedString 인스턴스를 만들고 몇번 문자열 값을 수정하면, numberOfEdits 속성 값이 갱신됨을 볼 수 있다.

	var stringToEdit = TrackedString()
	stringToEdit.value = "This string will be tracked."
	stringToEdit.value += " This edit will increment numberOfEdits."
	stringToEdit.value += " So will this one."
	println("The number of edits is \(stringToEdit.numberOfEdits)")
	// prints "The number of edits is 3"

다른 소스 파일로부터 numberOfEdits 속성의 현재 값을 조회할지라도 다른 소스 파일로부터 속성을 수정할 수 없다. 이 제한은 해당 기능의 측면에 편리하게 접근을 제공하는동안, TrackedString 수정 추적 기능의 구현 상세를 보호한다.

필요하다면 getter와 setter를 위한 명시적인 접근 수준을 할당할 수 있다. TrackedString 구조체는 public의 명시적인 접근 수준을 정의된다. 구조체의 멤버는 기본 internal 접근 수준을 가진다. 구조체의 numberOfEdits 속성 getter public과 속성 setter private를 `public`과 `private(set)` 접근 수준 수식어로 결합하여 만들 수 있다.

	public struct TrackedString {
	    public private(set) var numberOfEdits = 0
	    public var value: String = "" {
	        didSet {
	            numberOfEdits++
	        }
	    }
	    public init() {}
	}

### 이니셜라이저(Initializers)

사용자 이니셜라이저는 타입 초기화와 같거나 적은 접근 수준이 할당된다. 단 하나의 예외라면 필수 이니셜라이저이다. 필요 이니셜라이저는 속한 클래스로서 같은 접근 수준을 가져야 한다.

함수와 메소드 인자, 이니셜라이저의 인자 타입은 이니셜라이저의 자기자신의 접근 수준보다 더 private되면 안된다.

#### 기본 이니셜라이저(Default Initializers)

Swift는 모든 속성을 위한 기본 값을 주는 구조체와  기본 클래스를 위한 인자가 없이 기본 이니셜라이저를 제공한다.

Swift는 모든 속성을 위한 기본 값을 주는 구조체 또는 기본 클래스를 위한 인자를 가지지 않는 기본 이니셜라이저를 제공하며, 적어도 하나의 이니셜라이저 자체를 제공하지 않는다. 기본 이니셜라이저는 타입 초기화로서 같은 접근 수준을 가진다.

<div class="alert-info">
	public으로 타입이 정의된 경우, 기본 이니셜라이저는 internal로 간주된다. 만약 다른 모듈에 사용할 때 인자 없는 초기화하는 이니셜라이저를 위해서 public 타입을 원한다면, 타입 정의의 부분으로 public 인자가 없는 이니셜라이저르 제공해야 한다.
</div>

#### 구조체 타입을 위한 기본 Memberwise 이니셜라이저(Default Memberwise Initialziers for Structure Types)

만약 구조체의 저장 속성이 private라면 구조체 타입을 위한 기본 Memberwise 이니셜라이저는 private로 간주된다. 반면 이니셜라이저는 internal의 접근 수준을 가진다.

다른 모듈에서 사용될 때 public 구조체 타입이 초기화되지 않은 Memberwise로 초기화되길 원한다면, public Memberwise이 타입의 정의의 일부로서 자신을 초기화하도록 제공해야 한다.

### 프로토콜(Protocols)

프로토콜 타입에 명시적인 접근 수준을 할당하길 원하면, 프로토콜을 정의하는 시점에 해야한다. 특정 접근 맥락 내에서 채택할 수 있는 프로토콜을 만들 수 있다.

프로토콜 정의 내에서 각 요구사항의 접근 수준은 자동으로 프로토콜과 같은 접근 수준으로 설정된다. 프로토콜이 지원하는 것보다 다른 접근 수준으로 프로토콜 요구사항을 설정할 수 없다. 프로토콜이 도입된 타입으로 모든 프로토콜의 요구사항이 보이도록 한다.

<div class="alert-info">
	만약 public 프로토콜을 정의한다면, 프로토콜의 요구사항은 요구사항이 구현될 때, 이들 요구사항을 위한 public 접근 수준을 요구한다. 이러한 행동은 public 타입 정의가 타입 멤버를 위한 internal의 접근 수준을 의미하는 곳과 다르다.
</div>

#### 프로토콜 상속(Protocol Inheritance)

기존 프로토콜로부터 상속받은 새로운 프로토콜을 정의한다면, 새로운 프로토콜은 상속받은 프로토콜과 거의 같은 접근 수준을 가질 수 있다. internal 프로토콜로부터 상속하는 public 프로토콜은 작성할 수 없다.

#### 프로토콜 준수(Protocol Conformance)

타입은 타입 자신보다 낮은 접근 수준으로 프로토콜에 준수할 수 있다. 다른 모듈에서 사용되는 public 타입을 정의할 수 있지만 internal 프로토콜에 준수는 internal 프로토콜의 정의 모듈 내에서만 사용된다.

특정 프로토콜에 타입 준수에서 컨텍스트는 타입의 접근 수준과 프로토콜의 접근 수준의 최소이다. 타입이 public이라면 프로토콜은 internal로 준수되며, 타입의 프로토콜에 준수는 internal이 된다.

프로토콜을 준수하는 타입을 확장하거나 작성할 때, 각각의 프로토콜 요구사항의 타입 구현이 적어도 프로토콜을 준수하는 타입으로서 같은 접근 수준을 가져야 함을 보장해야 한다. 만약 public 타입은 internal 프로토콜을 준수한다면, 각각의 프로토콜 요구사항의 타입 구현은 적어도 "internal"이 되어야 한다.

<div class="alert-info">
	Swift에서 Objective-C와 같이 프로토콜 준수는 전역이다. - 이는 같은 프로그램 내에 다른 두가지 방법에서 타입이 프로토콜을 준수하기 위해서 가능하지 않다.
</div>

### 확장(Extensions)

클래스, 구조체, 또는 열거형이 가능한 모든 접근 컨텍스트에서 클래스, 구조체 또는 열거형을 확장 할 수 있다. 모든 타입 멤버는 원래 타입으로 확장된 타입 멤버 선언으로서 같은 기본 접근 수준을 가진 확장이 추가된다. public 타입을 확장한다면, 새로운 타입 멤버는 internal의 기본 접근 수준을 가지도록 추가한다.

반면, 확장 내에서 정의된 모든 멤버에 대한 새로운 기본 접근 수준으로 설정하는 명시적인 접근 수준 수식어로 확장을 표시할 수 있다. 새로운 기본 접근 수준은 여전히 개별 타입 멤버에 대한 확장 내에서 오버라이드 될 수 있다.

#### 확장에 프로토콜 준수 추가(Adding Protocol Conformance with an Extension)

프로토콜 준수를 확장에 추가하도록 사용한다면, 확장을 위한 명시적인 접근 수준 수식어를 제공할 수 없다. 대신, 프로토콜의 자기자신의 접근 수준이 확장 내에서 각각의 프로토콜 요구사항 구현을 위한 기본 접근 수준으로 제공하도록 사용된다.

### 제네릭(Generics)

제네릭 타입 또는 제네릭 함수를 위한 접근 수준은 제네릭 타입 또는 함수 자신의 접근 수준과 타입 인자에 모든 타입 제약의 접근 수준의 최소이다.

### 타입 별칭(Type Aliaes)

모든 타입 별칭은 접근 제어의 목적을 위한 별개의 타입으로 다루도록 정의한다. 타입 별칭은 타입 별칭의 접근 수준이 같거나 낮게 가진다. private 타입 별칭은 private, internal, 또는 public 타입을 지칭할 수 있지만 public 타입은 internal 또는 private 타입으로 지칭할 수 없다.

<div class="alert-info">
	이 규칙은 연관 타입이 프로토콜 준수를 만족하기 위해 타입 별칭을 적용한다.
</div>
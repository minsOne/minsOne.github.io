---
layout: post
title: "[Swift]Properties 정리"
description: ""
category: "mac/ios"
tags: [swift, static, type, struct, class, newValue, oldValue, observer, setter, getter, set, get, willSet, didSet, computed property, type property, lazy, stored property, variable, constant]
---
{% include JB/setup %}

## 속성(Properties)

속성은 특정 클래스, 구조체나 열거형을 값과 연결함. 저정 속성은 인스턴스의 부분으로서 상수와 변수를 저장하며, 어디서나 계산 속성은 값을 저장하는 것 보다 결정함. 계산속성은 클래스, 구조체 그리고 열거형으로 사용할 수 있음. 저장 속성은 클래스와 구조체로만 사용됨.

저장 및 계산 속성은 특정 타입의 인스턴스와 연결되지만, 이들 속성은 또한 타입 자체와 연결이 되기도 함. 이러한 속성은 타입 속성(Type Properties)이라고 함.

게다가 속성의 값이 변경되는 것을 감시하는 속성 감시자(property observer)를 정의할 수 있으며, 사용자 동작으로 대응할 수 있게 함. 속성 감시자는 직접 정의한 저장 속성과 자신의 부모 클래스로부터 상속받은 자식 클래스 속성이 추가됨.

### 저장 속성(Stored Properties)

간단한 형식으로 저장 속성은 상수나 변수이며 특정 클래스나 구조체의 인스턴스의 부분으로서 저장됨. `var` 키워드가 붙으면 변수 저장 속성, `let` 키워드가 붙으면 상수 저장 속성임.

정의의 한 부분으로 저장 속성에 기본 값을 줄 수 있음. 또한, 저장 속성을 초기화 하는 동안 초기 값을 설정 및 수정할 수 있음. 

다음은 FixedLengthRange라는 구조체 정의로 생성 시 범위 길이는 바꾸지 않는 정수 범위를 설명하는 예제임.

	struct FixedLengthRange {
	    var firstValue: Int
	    let length: Int
	}
	var rangeOfThreeItems = FixedLengthRange(firstValue: 0, length: 3)
	// the range represents integer values 0, 1, and 2
	rangeOfThreeItems.firstValue = 6
	// the range now represents integer values 6, 7, and 8

FixedLengthRange 인스턴스는 firstValue라는 변수 저장 속성과 length라는 상수 저장 속성을 가짐. 위 예제에서 length는 새로운 범위가 만들어 질 때 초기화되며 이후에는 변경될 수 없는데 상수 속성이기 때문임.

#### 상수 구조체 인스턴스의 저장 속성

구조체 인스턴스를 만들고 상수에 인스턴스를 할당한다면, 변수 속성으로서 선언한다고 하더라도 인스턴스 속성을 수정할 수 없음.

	let rangeOfFourItems = FixedLengthRange(firstValue: 0, length: 4)
	// this range represents integer values 0, 1, 2, and 3
	rangeOfFourItems.firstValue = 6
	// this will report an error, even though firstValue is a variable property

rangeOfFourItems는 `let` 키워드를 통해 상수로 선언되었기 때문이며, firstValue가 변수 속성이더라도 firstValue 속성은 변경할 수 없음.

이는 구조체가 값 타입이기 때문인데 값 타입의 인스턴스는 상수로 표시되면 모든 속성이 상수로 표시됨.

클래스는 참조 타입으로 다름. 참조 타입의 인스턴스를 상수에 할당하더라도 인스턴스의 변수 속성은 바꿀 수 있음.

#### 지연 저장 속성(Lazy Stored Properties)

지연 저장 속성은 처음으로 사용하기 전까지 초기 값을 계산하지 않음. 지연 저장 속성은 `lazy` 수식어를 선언 선언 이전에 씀.

<div class="alert-info">
변수로서 지연 속성을 항상 선언할 수 있는데, 초기 값은 인스턴스 초기화가 끝난 후에도 받을 수 있을지도 모르기 때문임. 상수 속성은 초기화 전에 항상 값을 가지고 있기 때문에 lazy로서 선언할 수 없음.
</div>

지연 속성은 인스턴스의 초기화가 끝난 후에도 외부 인자에 의존하는 속성의 값을 알지 못할 때 유용함. 지연 속성은 또한 속성의 초기 값이 복잡하거나 필요할 때 까지 수행하지 않아도 되는 경우에 유용함.

다음은 지연 저장 속성을 사용하여 복잡한 클래스의 불필요한 초기화를 피하는 예제임. 이 예제에서 DataImporter와 DataManager 두 클래스가 정의됨.

	class DataImporter {
	    /*
	    DataImporter is a class to import data from an external file.
	    The class is assumed to take a non-trivial amount of time to initialize.
	    */
	    var fileName = "data.txt"
	    // the DataImporter class would provide data importing functionality here
	}
	 
	class DataManager {
	    lazy var importer = DataImporter()
	    var data = [String]()
	    // the DataManager class would provide data management functionality here
	}
	 
	let manager = DataManager()
	manager.data.append("Some data")
	manager.data.append("Some more data")
	// the DataImporter instance for the importer property has not yet been created

DataManager 클래스는 data라는 저장 속성을 가지며 문자열 값의 빈 배열을 초기화함. 기능이 전부 보여지지 않았지만 DataManager 클래스의 목적은 문자열 데이타의 배열을 접근하여 관리하는 것임.

DataManager 클래스의 기능 중 하나는 파일에서 데이터를 가져오는 것임. DataImporter 클래스 기능으로 제공되며 초기화 하는데 적지 않은 시간을 쓴다고 가정하자. DataImporter 인스턴스가 초기화 될 때, 파일을 열고 메모리에서 컨텐츠를 읽기 때문임.

DataManager 인스턴스는 파일에서 데이터를 가져오지 않아도 관리할 수 있음. DataManager가 만들어 질 때 새로운 DataImporter 인스턴스를 만들 필요가 없기 때문임. 대신, 처음으로 사용 할 때 DataImporter 인스턴스를 만드는 것이 더 좋음.

`lazy` 수식어로 표시하기 때문에 importer 속성을 위한 DataImporter 인스턴스는 fileName 속성이 조회될 때 처럼 importer 속성이 처음 접근 될 때 생성됨.

	println(manager.importer.fileName)
	// the DataImporter instance for the importer property has now been created
	// prints "data.txt"

#### 저장 속성과 인스턴스 변수

Objective-C의 경험을 가지고 있다면, 클래스 인스턴스의 부분으로서 값과 참조를 저장하는 두 가지 방법을 알 것임. 속성 이외에도, 속성에 값을 저장하여 백업 저장소로서 인스턴스 변수를 사용할 수 있음.

Swift는 이러한 개념을 속성 선언 하나로 통합시켰음. Swift 속성은 대응하는 인스턴스 변수와 직접적으로 속성에 접근하는 백업 저장소를 가지지 않음. 혼란을 피하기 위해 속성의 선언을 단순하게 하여 정의함.

속성에 대한 모든 정보는 - 이름, 타입, 메모리 관리 특징을 포함 - 타입 정의의 부분으로서 단일 위치에 정의됨.

### 계산 속성(Computed Properties)

저장 속성외에도 클래스, 구조체 그리고 열거형은 계산 속성으로 정의되며, 이들은 실제로는 값을 저장하지 않음. 대신에 getter와 선택적인 setter을 제공하며 간접적으로 값을 설정하거나 받음.

	struct Point {
	    var x = 0.0, y = 0.0
	}
	struct Size {
	    var width = 0.0, height = 0.0
	}
	struct Rect {
	    var origin = Point()
	    var size = Size()
	    var center: Point {
	        get {
	            let centerX = origin.x + (size.width / 2)
	            let centerY = origin.y + (size.height / 2)
	            return Point(x: centerX, y: centerY)
	        }
	        set(newCenter) {
	            origin.x = newCenter.x - (size.width / 2)
	            origin.y = newCenter.y - (size.height / 2)
	        }
	    }
	}
	var square = Rect(origin: Point(x: 0.0, y: 0.0),
	    size: Size(width: 10.0, height: 10.0))
	let initialSquareCenter = square.center
	square.center = Point(x: 15.0, y: 15.0)
	println("square.origin is now at (\(square.origin.x), \(square.origin.y))")
	// prints "square.origin is now at (10.0, 10.0)"

세 개의 구조체는 기하학 모형을 작업하기 위한 예제임.

* Point는 (x,  y) 좌표를 캡슐화함.
* Size는 width와 height를 캡술화함.
* Rect는 기존 좌표와 크기로 사각형을 정의함.

Rect 구조체는 center라는 계산 속성이 있으며, Rect의 현재 중앙 좌표는 언제나 origin과 size로부터 결정됨. 명확한 Point 값ㅇ으로서 중앙 좌표에 저장할 필요가 없음. 대신에 Rect는 center라는 계산 변수를 위한 사용자 getter와 setter로 정의하며, 마치 실제 저장 속성인 것 처럼 사각형의 center로 작업이 가능함.

앞선 예제는 square라는 새로운 Rect 변수를 만듬. square 변수는 기본 좌표 (0,0)와 가로 세로가 10으로 초기화 됨. 이 정사각형은 아래 그림에서 파란 정 사각형으로 표시됨.

square 변수의 center 속성은 점 문법(square.center)로 접근되며 이는  center 속성 값을 반환하는 getter를 호출하게 됨. 실제로 존재하는 값을 반환하는 것이 아닌, getter는 사각형의 중심을 표현하는 새로운 Point를 반환하고 계산함. getter는 (5, 5)의 중심 좌표를 정확하게 반환함.

center 속성은 새로운 값 (15, 15)로 설정되며, 우측 방향으로 위로 이동함. 새로운 좌표는 아래 그림에서 오랜지 색상 사각형으로 보여짐. center 속성 값을 설정하기 위해 setter를 호출하는데 저장된 origin 속성의 값 x, y는 변경되며 새로운 좌표로 사각형이 이동함.

<img src="/../../../../image/2014/09/computedProperties_2x.png" alt="computedProperties" style="width: 400px;"/><br/>


#### 축약 Setter 선언(Shorthand Setter Declaration)

계산 속성의 setter는 새로운 값으로 설정하기 위한 이름을 정의할 수 없으며, 기본 이름인 newValue를 사용함. 다음은 Rect 구조체를 축약 표시를 통한 버전 예제임.

	struct AlternativeRect {
	    var origin = Point()
	    var size = Size()
	    var center: Point {
	        get {
	            let centerX = origin.x + (size.width / 2)
	            let centerY = origin.y + (size.height / 2)
	            return Point(x: centerX, y: centerY)
	        }
	        set {
	            origin.x = newValue.x - (size.width / 2)
	            origin.y = newValue.y - (size.height / 2)
	        }
	    }
	}

#### 읽기 전용 계산 속성(Read-Only Computed Properties)

계산 속성에 getter가 있고 setter가 없으면 읽기 전용 계산 속성이라고 함. 읽기 전용 계산 속성은 항상 값을 반환하며, 점 문법으로 접근할 수 있음. 그러나 다른 값으로 설정할 수 없음.

<div class="alert-info">
계산 속성(읽기 전용 계산 속성 포함)을 변수 속성으로 선언해야해야 하는데 값이 고정되지 않기 때문임. let 키워드는 오직 상수 속성에만 사용하는데, 인스턴스 초기화 부분으로서 한번 설정하면 값을 바꿀 수 없기 때문임.
</div>

읽기 전용 계산 속성은 get 키워드를 제거하여 선언하면 간단하게 할 수 있음.

	struct Cuboid {
	    var width = 0.0, height = 0.0, depth = 0.0
	    var volume: Double {
	        return width * height * depth
	    }
	}
	let fourByFiveByTwo = Cuboid(width: 4.0, height: 5.0, depth: 2.0)
	println("the volume of fourByFiveByTwo is \(fourByFiveByTwo.volume)")
	// prints "the volume of fourByFiveByTwo is 40.0"

이 예제는 Cuboid라는 새로운 구조체를 정의할 수 있는데, width, height, depth 속성으로 3D 사각형 박스를 표현함. 또한, 이 구조체는 volume이라는 읽기 전용 계산 속성을 가지며 Cuboid의 현재 부피를 계산하여 반환함. volume은 setter가 없는데, 이는 특정 volume 값을 사용하게 되면 width, height 그리고 depth 값이 모호할 수 있기 때문임. 그럼에도 불구하고 Cuboid에 읽기 전용 속성은 외부 유저에게 현재 계산된 부피를 줄 수 있어 유용함.

### 속성 감시자(Property Observers)

속성 감시자는 속성 값의 변경을 감시하고 대응함. 속성 감시자는 속성이 설정되는 매시간 호출되며, 심지어 새로운 값이 속성의 현재 값과 같더라도 호출이 됨.

속성 감시자는 어떠한 저장 속성에도 감시하도록 정의하여 추가할 수 있는데, 지연 저장 속성 만은 예외임. 속성 감시자는 자식 클래스 안에서 속성이 오버라이딩하여 상속 받은 속성에도 감시할 수 있음.

<div class="alert-info">
속성 감시자를 오버라이드 되지 않은 계산 속성에 정의할 필요가 없는데, 계산 속성의 setter 안에서 직접 값의 변경을 감시하고 대응하기 때문임.
</div>

속성에 둘 중 하나의 감시자를 정의할 수 있음.

* `willSet`은 값이 저장되기 전에 호출됨.
* `didSet`은 새로운 값이 저장된 후에 즉시 호출됨.

만약 `willSet` 감시자를 구현한다면, 상수 인자로 새로운 속성 값을 넘겨줘야 함. `willSet` 구현의 부분으로서 인자에 이름을 정할 수 있음. 만약에 인자 이름을 꾸지 않는다고 하더라도 인자는 기본 인자 이름인 `newValue`로 만들어져 사용 가능함.

유사하게, didSet 감시자를 구현한다면, 이전 속성 값을 포함하는 상수 인자를 넘김. 인자 이름을 원한다면 명명할 수 있고, 그렇지 않다면 기본 인자 이름인 `oldValue`를 사용함.

<div class="alert-info">
<code>willSet</code>`과 <code>didSet</code>의 예제임. 아래의 예제는 StepCounter라는 새로운 클래스 예제로서 걷는 동안 사람의 모든 발걸음을 추적함. 이 클래스는 만보계나 다른 보수계로부터 입력 데이터를 받아 사람의 운동 추적하도록 사용될 것임.
</div>

	class StepCounter {
	    var totalSteps: Int = 0 {
	        willSet(newTotalSteps) {
	            println("About to set totalSteps to \(newTotalSteps)")
	        }
	        didSet {
	            if totalSteps > oldValue  {
	                println("Added \(totalSteps - oldValue) steps")
	            }
	        }
	    }
	}
	let stepCounter = StepCounter()
	stepCounter.totalSteps = 200
	// About to set totalSteps to 200
	// Added 200 steps
	stepCounter.totalSteps = 360
	// About to set totalSteps to 360
	// Added 160 steps
	stepCounter.totalSteps = 896
	// About to set totalSteps to 896
	// Added 536 steps

StepCounter 클래스는 Int 타입의 totalSteps 속성으로 선언되며 `willSet`과 `didSet` 감시자를 가지는 저장 속성임.

totalSteps을 위한 `willSet`과 `didSet` 감시자는 새로운 값이 할당될 때 마다 호출 되며, 새로운 값이 현재 값과 같다고 하더라도 호출이 됨.

`willSet` 감시자 예제는 newTotalSteps 이름인 사용자 인자를 가짐. 이 예제는 값이 설정되면 단순히 그 값을 출력함.

`didSet` 감시자는 totalSteps 값이 갱신된 후에 호출되며, totalSteps의 새로운 값을 이전 값과 비교함. 만약 총 발걸음 수가 증가하면 얼마나 많이 걸었는지 출력함. `didSet` 감시자는 이전값에 사용자 인자 이름을 지원하지 않고, 대신 oldValue 기본 이름으로 사용함.

<div class="alert-info">
<code>didSet</code> 감시자 자체에서 속성을 할당한다면, 새로 할당한 값은 좀 전에 막 설정되었던 값을 대신할 것임.
</div>

### 전역 변수와 지역 변수(Global and Local Variables)

계산 속성과 관찰 속성은 전역 변수와 지역 변수에도 가능함. 전역 변수는 함수나 메소드, 클로저 또는 타입 컨텍스트 밖에서 정의된 변수이며, 지역 변수는 함수, 메소드나 클로저 컨텍스트 안에서 정의된 변수임.

전역 변수와 지역 변수는 저장 변수이며, 이 저장 변수는 저장 속성과 비슷하여 특정 타입의 값을 위한 저장소를 지원하며 값을 설정하거나 받을 수 있도록 할 수 있음.

전역 또는 지역 범위 중 하나에서 저장 변수를 위한 감시자와 계산 변수를 정의할 수 있음. 계산 변수는 값이 저장하는 것보다 계산하며, 계산 속성과 같은 방식을 취함.

<div class="alert-info">
전역 상수와 변수는 언제나 지연 계산되며, 이는 지연 저장 속성과 유사한 방법임. 지연 저장 속성과는 다르게 전역 상수와 변수는 <code>lazy</code> 수식어를 표시할 필요가 없음.
</div>

지역 상수와 변수는 절대로 지연 계산되지 못함.

### 타입 속성(Type Properties)

인스턴스 속성은 특정 타입의 인스턴스에 속한 속성임. 해당 타입의 인스턴스가 새로 생성될 때 마다, 다른 모든 인스턴스로 부터 분리된 자신만의 속성 값으로 설정됨.

타입의 어떤 하나의 인스턴스가 아닌, 타입 자신에 속한 속성을 정의할 수 있음.

얼마나 많은 타입 인스턴스를 만드는 것에는 상관없이 이 들 속성 중 하나의 복사본이 됨. 이러한 종류의 속성은 타입 속성이라고 함.

타입 속성은 모든 인스턴스가 사용하는 상수 속성(C에서 정적 상수)나 타입의 모든 인스턴스가 전역으로 값이 저장되는 변수 속성(C에서 정적 변수) 처럼, 특정 타입의 모든 인스턴스는 값을 정의하는데 유용함.

값 타입(구조체나 열거형)을 위해 저장 속성과 계산 속성을 정의할 수 있음.

클래스를 위해 계산 타입 속성만 정의할 수 있음.

값 타입을 위한 저장 타입 속성은 변수나 상수임. 계산 타입 속성은 변수 속성으로서 항상 선언되며, 같은 방법으로는 계산 인스턴스 속성임.

<div class="alert-info">
저장 인스턴스 속성과는 다르게 저장 타입 속성은 기본 값이 항상 주어짐. 이는 타입 스스로가 초기화를 가질 수 없기 때문이며 초기화 하는 시간에 저장 타입 속성에서 값을 할당함.
</div>

#### 타입 속성 문법(Type Property Syntax)

C와 Objective-C에서 정적 상수와 변수를 전역 정적 변수로서 연결하여 정의하였음. 그러나 Swift에서는 타입 속성은 타입 정의의 부분으로서 쓰이며, 타입의 외부 중괄호 안에 있고, 각 타입 속성은 그 타입이 지원하는 명시적인 범위임.

`static` 키워드로 값 타입을 위한 타입 속성을 정의할 수 있으며, `class` 키워드로 클래스 타입을 위한 타입 속성을 정의함.

다음은 저장 타입 속성과 계산 타입 속성의 문법 예제임.

	struct SomeStructure {
	    static var storedTypeProperty = "Some value."
	    static var computedTypeProperty: Int {
	        // return an Int value here
	    }
	}
	enum SomeEnumeration {
	    static var storedTypeProperty = "Some value."
	    static var computedTypeProperty: Int {
	        // return an Int value here
	    }
	}
	class SomeClass {
	    class var computedTypeProperty: Int {
	        // return an Int value here
	    }
	}

<div class="alert-info">
위의 계산 타입 속성 예제는 읽기 전용 계산 타입 속성이지만, 같은 문법으로 계산 인스턴스 속성으로서 읽기-쓰기 계산 타입 속성으로 정의할 수 있음.
</div>

#### 타입 속성 조회와 설정(Querying and Setting Type Properties)

인스턴스 속성과 같이 타입 속성은 점 문법으로 조회하고 설정할 수 있음. 그러나 타입 속성은 타입의 인스턴스가 아니라 타입에 조회하고 설정함.

	println(SomeClass.computedTypeProperty)
	// prints "42"
	 
	println(SomeStructure.storedTypeProperty)
	// prints "Some value."
	SomeStructure.storedTypeProperty = "Another value."
	println(SomeStructure.storedTypeProperty)
	// prints "Another value."

이 예제에서 많은 오디오 채널을 위한 오디오 레벨 미터 모듈은 구조체의 한 부분으로서 두 개의 저장 타입 속성을 사용함. 각 채널은 0에서 10을 포함하는 정수 오지오 레벨을 가짐.

아래 그림은 두 오디오 채널이 오디오 레벨 미터 모델과 어떻게 결합하는지를 보여줌. 채널의 오디오 레벨이 0일 때, 채널에는 아무런 빛이 없음. 오디오 레벨 10이면 채널에 모든 빛이 들어옴. 그림처럼 왼쪽 채널은 레벨 9이며 오른쪽 채널은 레벨 7임.

<img src="/../../../../image/2014/09/staticPropertiesVUMeter_2x.png" alt="staticPropertiesVUMeter" style="width: 400px;"/><br/>

위 오디오 채널은 AudioChannel 구조체의 인스턴스로 표시할 있음.

	struct AudioChannel {
	    static let thresholdLevel = 10
	    static var maxInputLevelForAllChannels = 0
	    var currentLevel: Int = 0 {
	        didSet {
	            if currentLevel > AudioChannel.thresholdLevel {
	                // cap the new audio level to the threshold level
	                currentLevel = AudioChannel.thresholdLevel
	            }
	            if currentLevel > AudioChannel.maxInputLevelForAllChannels {
	                // store this as the new overall maximum input level
	                AudioChannel.maxInputLevelForAllChannels = currentLevel
	            }
	        }
	    }
	}

AudioChannel 구조체는 기능을 지원하는 두 개의 저장 타입 속성을 정의함. 첫번째로, thresholdLevel은 오디오 레벨 최대 임계 값으로 정의함. 이 값은 모든 AudioChannel 인스턴스에 상수 값이 10으로 정의됨. 오디오 신호가 10보다 큰 값이 온다면 이 임계 값으로 정해질 것임.

두번째 타입 속성은 변수 저장 속성으로 maxInputLevelForAllChannels임. AudioChannel 인스턴스로부터 최대 입력 값을 받아 추적하고 유지함. 초기 값은 0으로 시작함.

AudioChannel 구조체는 currentLevel라는 저장 인스턴스 속성으로 정의되며 채널의 현재 오디오 레벨을 표시하는데 크기는 0에서 10임.

currentLevel 속성은 `didSet` 속성 감시자를 가지는데, 감시자는 값이 설정될때 마다 currentLevel 값을 확인함.

* currentLevel의 새로운 값이 thresholdLevel보다 크다면 속성 감시자는 currentLevel을 thresholdLevel로 맞춤.
* currentLevel의 새로운 값이 이전에 AudioChannel 인스턴스로부터 받은 값보다 크다면 속성 감시자는 새로운 currentLevel 값을 maxInputLevelForAllChannels 정적 속성에 저장함.

<div class="alert-info">
둘 가지 확인 사항에서 전자는 <code>didSet</code> 감시자는 currentLevel을 다른 값으로 설정함. 그렇지 않다면 감시자는 다시 한번 호출함.
</div>

두개의 새로운 AudioChannel 구조체를 만들어서 오디오 스테레오 음향 시스템을 표현하는 예제임.

	var leftChannel = AudioChannel()
	var rightChannel = AudioChannel()

왼쪽 채널의 currentLevel이 7로 설정되고 maxInputLevelForAllChannels 타입 속성이 7로 갱신되는 것을 볼 수 있음.

	leftChannel.currentLevel = 7
	println(leftChannel.currentLevel)
	// prints "7"
	println(AudioChannel.maxInputLevelForAllChannels)
	// prints "7"

오른쪽 채널의 currentLevel을 11로 설정한다면 오른쪽 채널의 currentLevel 속성은 최대 값 10으로 맞추어서 설정되며 maxInputLevelForAllChannels 타입 속성은 10으로 갱신됨.

	rightChannel.currentLevel = 11
	println(rightChannel.currentLevel)
	// prints "10"
	println(AudioChannel.maxInputLevelForAllChannels)
	// prints "10"


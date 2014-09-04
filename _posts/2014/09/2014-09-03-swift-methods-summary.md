---
layout: post
title: "Swift - Methods 정리"
description: ""
category: "mac/ios"
tags: [swift, method, instance, type method, instance method, class, structure, enumeration, function, static, property, mutating, func, self]
---
{% include JB/setup %}

## 메소드(Methods)

메소드는 특정 타입과 연관된 함수. 클래스, 구조체 그리고 열거형에서 인스턴스 메소드로 정의할 수 있으며, 주어진 타입의 인스턴스에 작업을 위한 특정 작업이나 기능을 캡슐화 함. 클래스, 구조체 그리고 열거형은 또한, 타입 메소드로 정의되며 타입 스스로와 연결됨. 타입 메소드는 Objective-C에 클래스 메소드와 비슷함.

Swift에서 구조체와 열거형은 C와 Objective-C와는 많이 다름. Objective-C에서 클래스는 오직 타입으로 메소드를 정의할 수 있음. Swift에서는 클래스, 구조체 또는 열거형을 정할 지 선택할 수 있으며, 직접 만든 타입에서 메소드를 정의하여 유연하게 가질 수 있음.

### 인스턴스 메소드(Instance Methods)

인스턴스 메소드는 특정 클래스, 구조체 또는 열거형 인스턴스에 속한 함수. 각 인스턴스의 기능을 지원하는데, 인스턴스 속성에 접근하고 수정하는 방법 또는 인스턴스의 목적에 맞는 기능을 제공함. 인스턴스 메소드는 함수와 같은 문법을 가지며 함수 항목에서 설명되어 있음.

인스턴스 메소드를 해당 타입의 괄호 안에 작성함. 인스턴스 메소드는 해당 타입의 나머지 모든 인스턴스 메소드와 속성을 암시적으로 접근할 수 있음. 인스턴스 메소드는 타입에 속한 특정 인스턴스를 호출할 수 있음. 하지만 인스턴스 없이 독립적으로 호출되지 못함.

아래는 간단한 Counter 클래스 예제로 작업 횟수를 셈.

	class Counter {
	    var count = 0
	    func increment() {
	        count++
	    }
	    func incrementBy(amount: Int) {
	        count += amount
	    }
	    func reset() {
	        count = 0
	    }
	}

Counter 클래스는 세 가지 인스턴스 메소드를 가짐.

* increment는 count에 1을 증가 시킴.
* incrementBy(amount: Int)는 특정 정수 양만큼 counter를 증가시킴.
* reset은 counter를 0으로 재설정함.

Counter 클래스는 변수 속성으로 선언할 수 있는데, 현재 counter 값을 추적 유지하는 count임.

인스턴스 메소드는 속성처럼 점 문법으로 호출함.

	let counter = Counter()
	// the initial counter value is 0
	counter.increment()
	// the counter's value is now 1
	counter.incrementBy(5)
	// the counter's value is now 6
	counter.reset()
	// the counter's value is now 0

#### 메소드를 위한 지역 및 외부 인자 이름(Local and External Parameter Names for Methods)

함수 인자는 함수 내부에서 사용할 지역 이름과 함수를 호출할 때 사용하기 위한 외부 이름을 가질 수 있음. 메소드는 타입과 연관된 함수임. 그러나 함수와 메소드에서 지역 이름과 외부 이름의 기본 행동은 다름.

Swift에서 메소드는 Objective-C와 매우 유사함. Objective-C 처럼 Swift에 메소드 이름은 with, for나 by같은 전치사를 사용하는 메소드의 첫번째 인자를 전형적으로 참조하는데, Counter 클래스 예제에서 incrementBy에서 본 것임.

전치사 사용은 메소드를 호출할 때 문장으로서 읽을 수 있도록 함. Swift는 다른 기본 접근법을 사용하여 작성하는데 함수 인자를 사용하는 것보다 메소드 인자를 사용호도록 만듬.

구체적으로 Swift는 기본적으로 지역 인자 이름이 메소드 내에서 첫번째 인자 이름이 되고 두번째 인자 부터는 기본적으로 내부와 외부 인자 이름이 주어짐. 이 규칙은 대표적인 작명과 호출 관습은 Objective-C로 작성된 메소드와 유사함. 그리고 인자 이름을 받을 필요 없이 알아보기 쉬운 메소드를 호출할 수 있음.

아래는 Counter 클래스를 좀 더 복잡한 형식을 가진 incrementBy 메소드임.

	class Counter {
	    var count: Int = 0
	    func incrementBy(amount: Int, numberOfTimes: Int) {
	        count += amount * numberOfTimes
	    }
	}

incrementBy 메소드는 두 개의 인자 - amount와 numberOfTimes - 을 가짐. 기본적으로 Swift는 amount를 지역 이름으로, numberOfTimes은 지역과 전역 이름으로 다룸. 메소드를 아래와 같이 호출함.

	let counter = Counter()
	counter.incrementBy(5, numberOfTimes: 3)
	// counter value is now 15

첫번째 인자 값을 위한 외부 인자 이름을 정의할 필요가 없음. 왜냐하면 함수 이름 incrementBy가 명확한 목적이기 때문임. 그러나 두 번째 인자는 외부 인자 이름을 가져야 하는데 이는 함수가 호출될 때 명확한 목적을 만들기 위함.

기본 행동은 numberOfTimes 인자 앞에 해쉬 기호(#)가 작성된 것처럼 다룰 수 있음.

	func incrementBy(amount: Int, #numberOfTimes: Int) {
	    count += amount * numberOfTimes
	}

위의 기본 동작은 Swift에서는 Objective-C 문법 스타일와 같은 메소드 정의를 의미하며, 자연스러운 표현 방법임.

#### 메소드를 위한 외부 인자 이름 동작 변경하기(Modifying External Parameter Name Behavior for Methods)

때로 기본 동작이 아니더라도, 메소드에 첫번째 인자를 위한 외부 인자 이름이 주어지면 유용함. 명확한 외부 이름을 추가하거나 외부 이름으로서 내부 이름을 해쉬 기호를 첫번째 인자 이름 앞에 넣을 수 있음.

거꾸로 말하면 메소드의 두번째 인자에 외부 이름이 제공되는 것을 원치 않으면, 명확한 외부 인자 이름으로 밑줄(_)을 사용하여 기본 행동을 오버라이드 함.

	class Counter {
	    var count: Int = 0
	    func incrementBy(amount: Int, _: Int) {
	        count += amount
	    }
	}

#### self 속성(The self Property)

모든 타입 인스턴스는 `self`라는 명확한 속성을 가지며, 인스턴스 자신과 정확하게 동일함. `self` 속성을 사용하여 자신의 인스턴스 메소드 내에서 현재 인스턴스를 참조함.

아래 예제에서 increment 메소드는 다음과 같이 작성됨.

	func increment() {
	    self.count++
	}

위 예제에서 굳이 self를 쓸 필요가 없음. 명확하게 self를 쓰지 않으면, Swift는 메소드 안에서 알고있는 속성이나 메소드 이름을 사용할 때 현재 인스턴스의 속성이나 메소드로 참조하도록 가정함. 이 가정은 Counter를 위한 세 개의 인스턴스 메소드 내에서 count의 사용하므로 입증됨.

이 규칙에서 인스턴스 메소드에 인자 이름이 인스턴스의 속성과 같은 이름을 가질 때 주된 예외가 발생함. 이 상황에서 인자 이름은 우선으로 취하며, 더 나은 방법으로 속성을 필수적으로 참조됨. self 속성은 인자 이름과 속성 이름을 분리하도록 사용됨.

다음은 self는 x라는 메소드 인자와 x라는 인스턴스 속성을 명확하게 하는 예제.

self 접두사가 없다면 Swift는 x라는 메소드 인자를 참조하여 사용하도록 가정함.

#### 인스턴스 메소드 안에서 값 타입 수정하기(Modifying Value Types from Within Instance Methods)

구조체와 열거형은 값 타입임. 기본적으로 값 타입의 속성은 인스턴스 메소드 안에서 수정할 수 없음.

그러나 특정 메소드 안에 구조체나 열거형의 속성을 수정할 필요가 있다면, 메소드에 변경 동작을 선택할 수 있음. 그러면 메소드는 속성을 변경할 수 있으며, 모든 변경은 메소드가 끝날 때 기존 구조체가 쓰여진 후에 적용됨.  메소드는 암시적인 self 속성에 새로운 인스턴스를 완전히 할당할 수 있으며, 새로운 인스턴스는 메소드가 끝난 뒤에 교체됨.

`mutating` 키워드를 메소드 키워드인 `func`앞에 위치하도록 해서 이 동작을 선택할 수 있음.

	struct Point {
	    var x = 0.0, y = 0.0
	    mutating func moveByX(deltaX: Double, y deltaY: Double) {
	        x += deltaX
	        y += deltaY
	    }
	}
	var somePoint = Point(x: 1.0, y: 1.0)
	somePoint.moveByX(2.0, y: 3.0)
	println("The point is now at (\(somePoint.x), \(somePoint.y))")
	// prints "The point is now at (3.0, 4.0)"

위에서 Point 구조체는 변경 moveByX 메소드를 정의하는데, 특정 양만큼 Point 인스턴스를 움직임. 새로운 포인터를 반환하는 대신, 이 메소드는 호출하여 좌표를 수정함. `mutating` 키워드는 속성을 수정 가능하도록 정의함.

구조체의 상수에서 변경 메소드를 호출하지 않는다면, 변수 속성일지라도 변경되지 않음. 

	let fixedPoint = Point(x: 3.0, y: 3.0)
	fixedPoint.moveByX(2.0, y: 3.0)
	// this will report an error

#### 변경 메소드 내 self 할당(Assigning to self Within a Mutating Method)

변경 메소드는 암시적인 self 속성에 새로운 인스턴스를 전부 할당할 수 있음.

	struct Point {
	    var x = 0.0, y = 0.0
	    mutating func moveByX(deltaX: Double, y deltaY: Double) {
	        self = Point(x: x + deltaX, y: y + deltaY)
	    }
	}

변경 moveByX 메소드는 x와 y값으로 설정된 새로운 구조체를 생성함. 호출 결과는 이전 버전과 동일함.

열거형에서 변경 메소드는 같은 열거형에서 다른 멤버로 되는 암시적인 self 인자로 설정됨.

	enum TriStateSwitch {
	    case Off, Low, High
	    mutating func next() {
	        switch self {
	        case Off:
	            self = Low
	        case Low:
	            self = High
	        case High:
	            self = Off
	        }
	    }
	}
	var ovenLight = TriStateSwitch.Low
	ovenLight.next()
	// ovenLight is now equal to .High
	ovenLight.next()
	// ovenLight is now equal to .Off

위 예제는 세 가지 상태 스위치 열거형을 정의함. 스위치는 매번 next 메소드가 호출될때마다 세가지 다른 전력 상태(Off, Low 그리고 High)로 순환함.

### 타입 메소드(Type Methods)

인스턴스 메소드는 특정 타입의 인스턴스에서 호출되는 메소드이며, 타입 자체에서 호출되는 메소드가 정의되며, 타입 메소드라고 불림. 클래스를 위한 타입 메소드는 func 키워드 앞에 `class` 키워드를 작성하여 나타내며, 구조체와 열거형을 위한 타입 메소드는 `func` 키소드 앞에 `static` 키워드를 작성함.

Objective-C에서 타입-레벨 메소드는 Objective-C 클래스에서만 정의할 수 있었음. Swift는 타입-레벨 메소드는 모든 클래스, 구조체 그리고 열거형에도 정의할 수 있음. 각각의 타입 메소드는 지원하는 타입에 명시적으로 범위를 정함.

타입 메소드는 인스턴스 메소드 처럼 점 문법으로 호출. 그러나 타입에서 타입 메소드를 호출하지만 타입 인스턴스에서는 하지 못함. 다음은 someClass라는 클래스에서 타입 메소드를 호출하는 예제임.

	class SomeClass {
	    class func someTypeMethod() {
	        // type method implementation goes here
	    }
	}
	SomeClass.someTypeMethod()

타입 메소드 내에서 암시적인 self 속성은 타입 인스턴스 보다 타입 자체를 참조. 구조체나 열거형에서 self는 단지 인스턴스 속성과 인스턴스 메소드 인자로서 정적 속성과 정적 메소드 인자를 구분하기 위해 사용. 

좀 더 일반적으로 어떤 사용 제한이 없는 메소드와 속성 이름은 타입 메소드 내에서 다른 타입 레벨 메소드와 속성을 참조하는데 사용됨. 타입 메소드는 다른 메소드의 이름과 같이 다른 타입 메소드가 호출되는데 타입 이름이 앞에 필요없음. 유사하게 구조체와 열거형의 타입 메소드는 타입 이름 접두사 없이 정적 속성 이름을 사용하는 정적 속성에 접근할 수 있음.

아래 예제는 LevelTracker라는 구조체를 정의함. 이 구조체는 플레이어의 게임의 다른 레벨이나 스테이지로의 진행을 추적함. 단일 플레이어 게임은 단일 기기 상에서 여러 플레이어의 정보를 저장함.

모든 게임 레벨은 처음에 실행하면 잠겨져 있음. 플레이어가 레벨을 마칠때 마다 기기 상의 모든 플레이어를 풀어줌. LevelTracker 구조체는 정적 속성과 메소드를 사용하며 게임 레벨을 풀어주도록 추적하고 유지함. 

	struct LevelTracker {
	    static var highestUnlockedLevel = 1
	    static func unlockLevel(level: Int) {
	        if level > highestUnlockedLevel { highestUnlockedLevel = level }
	    }
	    static func levelIsUnlocked(level: Int) -> Bool {
	        return level <= highestUnlockedLevel
	    }
	    var currentLevel = 1
	    mutating func advanceToLevel(level: Int) -> Bool {
	        if LevelTracker.levelIsUnlocked(level) {
	            currentLevel = level
	            return true
	        } else {
	            return false
	        }
	    }
	}

LevelTracker 구조체는 어떤 플레이어가 푼 레벨 중 가장 높은 레벨의 트랙을 추적 유지함. highestUnlockedLevel라는 정적 속성에 이 값이 저장됨.

LevelTracker는 highestUnlockedLevel 속성으로 작업하는 두 개 타입 함수로 정의함. 첫번째 타입 함수는 unlockLevel로, 새로운 값이 풀릴때 highestUnlockedLevel 값이 갱신됨. 두번째는 levelIsUnlocked라는 편리한 타입 함수로, 특정 레벨이 이미 풀렸다면 true를 반환함. 

게다가 정적 속성과 타입 메소드에서 LevelTracker는 각각의 플레이어 게임 진행도를 추적하며, currentLevel이라는 인스턴스 속성을 사용하여 플레이어의 현재 진행 레벨을 추적함.

currentLevel 속성을 관리하는데 도움이 되도록 LevelTracker는 advanceToLevel라는 인스턴스 메소드를 정의함. 이 메소드는 currentLevel를 갱신하기 전에 새로운 레벨이 열렸는지 확인 요청함. advanceToLevel 메소드는 currentLevel이 실제로 설정되는지 아닌지 나타내기 위해 논리값을 반환함.

다음은 Player클래스와 같이 LevelTracker 구조체를 사용하여 각각의 플레이어 진행을 추적하고 갱신하는 예제임.

	class Player {
	    var tracker = LevelTracker()
	    let playerName: String
	    func completedLevel(level: Int) {
	        LevelTracker.unlockLevel(level + 1)
	        tracker.advanceToLevel(level + 1)
	    }
	    init(name: String) {
	        playerName = name
	    }
	}

Player 클래스는 LevelTracker의 새로운 인스턴스를 생성하여 플레이어의 진행을 추적함. completedLevel이라는 메소드는 특정 레벨을 플레이어가 완료할 때마다 호출됨. 이 메소드는 모든 플레이어를 위한 다음 레벨을 풀며 다음 레벨로 플레이어의 진행을 이동하도록 갱신함.

다음은 새로운 플레이어를 위한 Player 클래스의 인스턴스를 생성하여 레벨 1을 완료할 때 발생하는 예제.

	var player = Player(name: "Argyrios")
	player.completedLevel(1)
	println("highest unlocked level is now \(LevelTracker.highestUnlockedLevel)")
	// prints "highest unlocked level is now 2"

두 번째 플레이어를 만든다면, 게임에서 아직 풀리지 않은 레벨로는 이동할 수 없으며 현재 레벨을 설정하려는 시도는 실패할 것임.

	player = Player(name: "Beto")
	if player.tracker.advanceToLevel(6) {
	    println("player is now on level 6")
	} else {
	    println("level 6 has not yet been unlocked")
	}
	// prints "level 6 has not yet been unlocked"
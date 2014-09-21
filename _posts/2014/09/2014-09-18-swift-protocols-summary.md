---
layout: post
title: "Swift - Protocols 정리"
description: ""
category: "mac/ios"
tags: [swift, protocol, class, struct, enumeration, instance, method, requirement, optional, extension, final, subscript, mutating, delegation, property, type, operator, conformance, adoption, inheritance]
---
{% include JB/setup %}

## 프로토콜(Protocols)

프로토콜은 메소드, 속성 그리고 다른 특정 작업 또는 기능의 부분에 맞는 요구 사항의 청사진을 정의한다. 프로토콜은 실제로 이들 요구사항 구현을 제공하지 않는다. - 구현 처럼 보이도록 설명한다. 프로토콜은 이들 요구사항의 실제 구현을 제공하기 위한 클래스, 구조체 또는 열거형에 적용된다. 프로토콜의 요구사항을 만족하면 어떤 타입이라도 프로토콜에 준수한다라고 말한다.

프로토콜은 준수 타입이 특정 인스턴스 속성, 인스턴스 메소드, 타입 메소드, 연산자 그리고 서브스크립트를 가지는 것이 필요하다.

### 프르토콜 문법(Protocol Syntax)

프로토콜은 클래스, 구조체 그리고 열거형과 매우 유사한 방법으로 정의한다.

	protocol SomeProtocol {
	    // protocol definition goes here
	}

사용자 타입 상태는 타입 이름 뒤에 프로토콜 이름이 위치하여 부분적인 프로토콜을 적용한다. 다중 프로토콜은 콤마로 분리하여 나열할 수 있다.

	struct SomeStructure: FirstProtocol, AnotherProtocol {
	    // structure definition goes here
	}

클래스가 슈퍼클래스를 가지면, 프로토콜 앞에 슈퍼클래스를 먼저 기록한다.

	class SomeClass: SomeSuperclass, FirstProtocol, AnotherProtocol {
	    // class definition goes here
	}

### 속성 요구사항(Property Requirements)

프로토콜은 특정 이름과 타입을 가진 인스턴스 속성 또는 타입 속성을 제공하기 위한 준수하는 타입이 필요하다. 프로토콜은 속성이 저장 속성이거나 계산 속성으로 지정되지 않는다 - 이는 필요한 속성 이름과 타입만 지정한다. 또한 프로토콜은 각 속성이 읽기 또는 읽기/쓰기인지 지정한다.

만약 프로토콜이 읽기/쓰기로 속성이 필요하다면, 속성 요구사항은 상수 저장 속성 또는 읽기 계산 속성으로는 채울 수 없다. 만약 프로토콜이 읽기가 필요한 속성만을 요구한다면, 요구사항은 어떤 속성의 종류으로도 만족할 수 있고, 쓰기가 필요한 속성에도 유효하다.

속성 요구사항은 항상 변수 속성으로 선언되어야 하며, var 키워드를 앞에 붙여야 한다. 읽기와 쓰기 속성은 `{ get set }` 를 타입 선언 뒤에 타나내며, 읽기 속성은 `{ get }`을 작성하여 나타낸다.

	protocol SomeProtocol {
	    var mustBeSettable: Int { get set }
	    var doesNotNeedToBeSettable: Int { get }
	}

항상 접두사 `class` 키워드와 함께하는 타입 속성 요구사항은 프로토콜에 정의될 때 사용된다. 이 규칙은 타입 속성 요구사항에 구조체나 열거형에 구현될 때 `static` 키워드를 앞에 붙여 연관된다.

	protocol AnotherProtocol {
	    class var someTypeProperty: Int { get set }
	}

단일 인스턴스 속성 요구사항 프로토콜 예제이다.

	protocol FullyNamed {
	    var fullName: String { get }
	}

FullyNamed 프로토콜은 완전한 이름을 제공하기 위해 연관 타입이 필요하다. 프로토콜은 연관 타입의 특성에 대한 것을 지정하지 않는다 - 타입은 스스로를 위해 전체 이름을 제공한다. 프로토콜 상태는 특정 FullyNamed 타입은 fullName이라는 읽기 인스턴스 속성을 가지며, 이 타입은 문자열 타입이다.

	struct Person: FullyNamed {
	    var fullName: String
	}
	let john = Person(fullName: "John Appleseed")
	// john.fullName is "John Appleseed"

Person이라는 구조체는 특정 사람 이름을 표현한다. FullyNamed 프로토콜을 적용한 상태이다. 각 Person의 인스턴스는 fullName이라는 단일 저장 속성을 가지며 문자열 타입이다. FullyNamed 프로토콜의 단일 요구사항에 준수하며 Person은 프로토콜에 준수하도록 연관된다.

좀 더 복잡한 클래스에서 FullyNamed 속성에 연관되고 적용된다.

	class Starship: FullyNamed {
	    var prefix: String?
	    var name: String
	    init(name: String, prefix: String? = nil) {
	        self.name = name
	        self.prefix = prefix
	    }
	    var fullName: String {
	        return (prefix != nil ? prefix! + " " : "") + name
	    }
	}
	var ncc1701 = Starship(name: "Enterprise", prefix: "USS")
	// ncc1701.fullName is "USS Enterprise"

이 클래스는 startship을 위한 계산 읽기 속성으로서 fullName 속성 요구사항을 구현한다. 각 Starship 클래스 인스턴스는 의무적인 name과 선택적인 prefix를 저장한다. fullName 속성은 prefix 값을 사용하며, Starship을 위한 전체 이름에 시작 부분에 붙인다.

### 메소드 요구사항(Method Requirements)

프로토콜은 연관 타입을 구현하기 위해서 지정 인스턴스 메소드와 타입 메소드가 필요할 수 있다. 이들 메소드는 일반 인스턴스와 타입 메소드로서 정확히 같은 방법으로 프로토콜의 정의를 작성된다. 가변 인자는 가능하고, 일반 메소드로서 같은 규칙을 사용한다.

<div class="alert-info">
	프로토콜은 같은 메소드로서 같은 문법을 사용하고, 메소드 인자를 위한 기본 값이 허락되지 않는다.
</div>

타입 속성 요구사항으로서 프로토콜이 정의될 때, `class` 키워드를 타입 메소드 요구사항 앞에 항상 붙인다. 이 규칙은 구조체나 열거형이 구현되었을 때, 타입 메소드 요구사항 앞에 `static` 키워드를 붙인다.
	
	protocol SomeProtocol {
	    class func someTypeMethod()
	}

인스턴스 메소드 요구사항과 함께 프로토콜을 정의하는 예제이다.

	protocol RandomNumberGenerator {
	    func random() -> Double
	}

RandomNumberGenerator 프로토콜은 random이라는 연관 메소드를 가지는 연관 타입을 필요로 하고 호출할 때 Double 값을 반환한다. 

RandomNumberGenerator 프로토콜은 어떻게 난수를 생성하는지에 대해서 정보가 없다. - 이는 단순히 새로운 난수를 만들기 위한 표준 방법을 제공하기 위한 생성자가 필요하다.

다음은 RandomNumberGenerator 프로토콜을 클래스 구현에 적용하고 연관하는 예제이다.

	class LinearCongruentialGenerator: RandomNumberGenerator {
	    var lastRandom = 42.0
	    let m = 139968.0
	    let a = 3877.0
	    let c = 29573.0
	    func random() -> Double {
	        lastRandom = ((lastRandom * a + c) % m)
	        return lastRandom / m
	    }
	}
	let generator = LinearCongruentialGenerator()
	println("Here's a random number: \(generator.random())")
	// prints "Here's a random number: 0.37464991998171"
	println("And another one: \(generator.random())")
	// prints "And another one: 0.729023776863283"

### 변이 메소드 요구사항(Mutating Method Requirements)

때론 메소드를 위해서 속한 인스턴스를 변경할 필요가 있다. 값 타입 상에서 인스턴스 메소드를 위해 `mutating` 키워드를 메소드의 `func` 키워드 앞에 위치하고 메소드는 인스턴스를 수정하도록 해준다.

만약 프로토콜 인스턴스 메소드 요구사항이 타입의 인스턴스로 변이하도록 의도하도록 정의한다면 프로토콜 정의의 부분으로서 `mutating` 키워드를 메소드에 표시한다.

<div class="alert-info">
	<code>mutating</code> 으로서 프로토콜 인스턴스 메소드 요구사항을 표시한다면, 클래스를 위한 메소드 구현을 작성할 때 <code>mutating</code> 키워드를 작성할 필요가 없다. <code>mutating</code> 키워드는 구조체와 열거형에만 사용된다.
</div>

다음 Togglable이라는 프로토콜 예제로 toggle이라는 단일 인스턴스 메소드 요구사항을 정의하는 예제이다. toggle 메소드는 연관 타입의 상태를 토글 또는 거꾸로 의도하며, 일반적으로 타입의 속성을 변경한다.

	protocol Togglable {
	    mutating func toggle()
	}

Togglable 프로토콜을 구조체나 열거형에 구현한다면, 구조체나 열거형은 `mutating`으로 표시된 toggle 메소드의 구현을 받는 프로토콜에 준수할 수 있다.

다음은 두가지 상태를 토글하는 열거형으로 열거형의 toggle 구현은 `mutating`으로 표시되어 Togglable 프로토콜 요구사항과 준수하는 예제이다.

	enum OnOffSwitch: Togglable {
	    case Off, On
	    mutating func toggle() {
	        switch self {
	        case Off:
	            self = On
	        case On:
	            self = Off
	        }
	    }
	}
	var lightSwitch = OnOffSwitch.Off
	lightSwitch.toggle()
	// lightSwitch is now equal to .On

### 이니셜라이저 요구사항

프로토콜은 준수하는 타입을 구현한 특정 이니셜라이저가 필요할 수 있다. 이들 이니셜라이저를 프로토콜 정의의 한 부분으로서 일반적인 이니셜라이저와 같은 방법으로 작성하지만 괄호나 이니셜라이저 내용은 없다.

	protocol SomeProtocol {
	    init(someParameter: Int)
	}

#### 프로토콜 이니셔라이저 요구사항의 클래스 구현

지정 이니셜라이저 또는 편의 이니셜라이저로서 준수하는 클래스에서 프로토콜 이니셜라이저 요구사항을 구현할 수 있다. 이러한 경우, 이니셜라이저 구현에 `required` 수식어를 표시해야 한다.

	class SomeClass: SomeProtocol {
	    required init(someParameter: Int) {
	        // initializer implementation goes here
	    }
	}

`required` 수식어 사용은 준수하는 클래스의 모든 서브클래스 상에서 명확하거나 상속된 이니셜라이저 요구사항의 구현을 제공함을 확신한다. 또한, 프로토콜과 준수해야 한다.

<div class="alert-info">
	프로토콜 이니셜라이저 구현을 클래스에 <code>required</code> 수식어로 표시할 필요가 없다면 <code>final</code> 수식어로 표현해야 한다. 이는 final 클래스는 서브클래스가 될 수 없다.
</div>

만약 서브클래스가 슈퍼클래스로부터 지정 이니셜라이저와 준수하는 이니셜라이저 요구사항의 구현을 오버라이드 한다면, 이니셜라이저 구현에 `required`와 `override` 수식어를 표시한다.

	protocol SomeProtocol {
	    init()
	}
	 
	class SomeSuperClass {
	    init() {
	        // initializer implementation goes here
	    }
	}
	 
	class SomeSubClass: SomeSuperClass, SomeProtocol {
	    // "required" from SomeProtocol conformance; "override" from SomeSuperClass
	    required override init() {
	        // initializer implementation goes here
	    }
	}

### 타입으로서 프로토콜(Protocols as Types)

프로토콜은 실제론 기능을 구현하지 않는다. 그럼에도 불구하고 프로토콜은 코드에서 다른 타입으로 사용될 수 있다.

이는 타입이기 때문에, 타입이 허락하는 한 많은 곳에 프로토콜을 사용할 수 있다.

* 함수, 메소드 또는 이니셜라이저 안에서 인자 타입 또는 반환 타입으로
* 상수, 변수 또는 속성 타입으로
* 배열, 딕셔너리, 다른 컨테이너 안에서 요소의 타입으로

<div class="alert-info">
	프로토콜은 타입이기 때문에, 대문자로 시작해야 하며(FullyNamed과 RandomNumberGenerator과 같은), 이는 Swift의 다른 타입의 이름과 준수해야 한다(Int, String, Double과 같은).
</div>

다음은 타입으로서 프로토콜 사용하는 예제이다.

	class Dice {
	    let sides: Int
	    let generator: RandomNumberGenerator
	    init(sides: Int, generator: RandomNumberGenerator) {
	        self.sides = sides
	        self.generator = generator
	    }
	    func roll() -> Int {
	        return Int(generator.random() * Double(sides)) + 1
	    }
	}

Dice 클래스는 generator 라는 속성을 가지며, RandomNumberGenerator 타입이다. 따라서 Dice 인스턴스는 RandomNumberGenerator 프로토콜이 적용되었다. 

Dice는 초기 상태를 설정하는 이니셜라이저를 가지는데, generator라는 인자는 RandomNumberGenerator 타입이다. 새로운 Dice 인스턴스를 초기활 때 준수하는 타입의 값을 넘겨줘야 한다.

Dice는 rool이라는 인스턴스 메소드를 가지는데, generator의 random 메소드를 호출하여 새로운 난수 값을 만든다. generator는 RandomNumberGenerator이 적용되었다고 알려졌기 떄문에, random 메소드를 호출하는 것이 보장된다.

다음은 Dice 인스턴스를 생성하여 난수를 만드는 인스턴스 예제이다. 

	var d6 = Dice(sides: 6, generator: LinearCongruentialGenerator())
	for _ in 1...5 {
	    println("Random dice roll is \(d6.roll())")
	}
	// Random dice roll is 3
	// Random dice roll is 5
	// Random dice roll is 4
	// Random dice roll is 5
	// Random dice roll is 4


### 위임(Delegation)

위임은 디자인패턴으로 클래스나 구조체가 다른 타입의 인스턴스에게 책임을 일부 위임한다. 디자인 패턴은 준수한 타입이 기능이 위임받음을 보장하는 것 같이, 위임된 책임을 캡슐화하는 프로토콜을 정의하는 것을 구현한다. 위임은 특정 행동이나 소스의 기반 타입을 알 필요 없는 외부 소스로부터 받은 데이터를 응답하는데 사용된다.

다음은 두 개의 프로토콜을 정의하는 예제로, 주사위 보드 게임에 사용한다.

	protocol DiceGame {
	    var dice: Dice { get }
	    func play()
	}
	protocol DiceGameDelegate {
	    func gameDidStart(game: DiceGame)
	    func game(game: DiceGame, didStartNewTurnWithDiceRoll diceRoll: Int)
	    func gameDidEnd(game: DiceGame)
	}

이전에 제어 흐름에서 사용했던 뱀과 사다리 게임으로 DiceGame 프로토콜을 적용시켰으며, 진행 사항을 DiceGameDelegate으로 통지한다.

	class SnakesAndLadders: DiceGame {
	    let finalSquare = 25
	    let dice = Dice(sides: 6, generator: LinearCongruentialGenerator())
	    var square = 0
	    var board: [Int]
	    init() {
	        board = [Int](count: finalSquare + 1, repeatedValue: 0)
	        board[03] = +08; board[06] = +11; board[09] = +09; board[10] = +02
	        board[14] = -10; board[19] = -11; board[22] = -02; board[24] = -08
	    }
	    var delegate: DiceGameDelegate?
	    func play() {
	        square = 0
	        delegate?.gameDidStart(self)
	        gameLoop: while square != finalSquare {
	            let diceRoll = dice.roll()
	            delegate?.game(self, didStartNewTurnWithDiceRoll: diceRoll)
	            switch square + diceRoll {
	            case finalSquare:
	                break gameLoop
	            case let newSquare where newSquare > finalSquare:
	                continue gameLoop
	            default:
	                square += diceRoll
	                square += board[square]
	            }
	        }
	        delegate?.gameDidEnd(self)
	    }
	}

SnakesAndLadders 클래스는 DiceGame 프로토콜이 적용되어, dice 속성과 play 메소드가 프로토콜과 준수함을 알 수 있다.(dice 속성은 상수 속성으로 선언되었는데, 이는 초기화 후에 변경할 필요가 없기 때문이며, 프로토콜은 읽기가 필요만 하면 된다.)

모든 게임 로직은 프로토콜의 play 메소드로 움직이며, 프로토콜의 필요한 dice 속성은 주사위 값을 주는데 사용된다.

delegate 속성은 옵셔널 DiceGameDelegate으로 정의되었는데, 이는 위임이 게임을 하는 것에 필요하지 않다. 이는 옵셔널 타입이기 때문에, delegate 속성은 자동으로 초기 값이 nil로 설정된다. 

DiceGameDelegate은 게임의 진행을 추적하기 위한 세 개의 메소드를 제공하는데, play 메소드는 옵셔널 체이닝을 사용하여 각각 위임에서 메소드를 호출한다. 만약 delegate 속성이 nil이면 우아하게 호출이 실패한다. 

다음은 DiceGameTracker라는 클래스로 DiceGameDelegate 프로토콜을 적용하는 예제이다.

	class DiceGameTracker: DiceGameDelegate {
	    var numberOfTurns = 0
	    func gameDidStart(game: DiceGame) {
	        numberOfTurns = 0
	        if game is SnakesAndLadders {
	            println("Started a new game of Snakes and Ladders")
	        }
	        println("The game is using a \(game.dice.sides)-sided dice")
	    }
	    func game(game: DiceGame, didStartNewTurnWithDiceRoll diceRoll: Int) {
	        ++numberOfTurns
	        println("Rolled a \(diceRoll)")
	    }
	    func gameDidEnd(game: DiceGame) {
	        println("The game lasted for \(numberOfTurns) turns")
	    }
	}

DiceGameTracker는 DiceGameDelegate가 필요로 하는 세 개의 메소드를 구현하였다. numberOfTurns 속성은 게임 시작하면 0으로 설정되고, 매 번 새로운 턴이 시작되면 증가하고, 게임이 끝나면 전체 수를 출력한다.

gameDidStart 메소드는 DiceGame 타입의 game 인자를 가지고, gameDidStart는 DiceGame 프로토콜의 한 부분으로서 구현된다. 그러나 메소드는 기반 인스턴의 타입을 조회하여 타입을 변경하여 사용한다.

또한, gameDidStart는 game 인자에 dice 속성을 접근한다. game은 DiceGame 프로토콜과 준수되었다고 알려졌기 때문에, dice 속성을 가지는 것을 보장되며 gameDidStart 메소드는 dice의 side 속성을 접근하여 출력할 수 있다.

### 확장을 프로토콜 준수에 추가(Adding Protocol Conformance with an Extension)

새로운 프로토콜에 기존 타입을 적용시키고 준수시켜 확장할 수 있으며, 심지어 기존 타입에서 소스코드에 접근할 수 없던 것도 확장할 수 있다. 확장은 새로운 속성, 메소드 그리고 서브스크립트를 기존 타입에 추가하고, 프로토콜에서 요구하는 요구사항을 추가할 수 있다.

<div class="alert-info">
	기존 타입의 인스턴스는 자동으로 프로토콜을 채택시키고 준수시키며, 준수는 확장에서 인스턴스의 타입에 추가될 때이다.
</div>

다음은 특정 타입을 구현하는 프로토콜이다.

	protocol TextRepresentable {
	    func asText() -> String
	}

앞에서 본 Dice 클래스를 TextRepresentable를 도입하고 준수하도록 확장할 수 있다.

	extension Dice: TextRepresentable {
	    func asText() -> String {
	        return "A \(sides)-sided dice"
	    }
	}

이 확장은 기존 구현상에서 Dice에다 새로운 프로토콜을 도입시킨다. 프로토콜 이름은 타입 이름 뒤에 쓴다.

Dice 인스턴스는 이제 TextRepresentable로서 다루게 된다.

	let d12 = Dice(sides: 12, generator: LinearCongruentialGenerator())
	println(d12.asText())
	// prints "A 12-sided dice"

유사하게, SnakesAndLadders 게임 클래스는 TextRepresentable 프로토콜을 채택하고 준수시켜 확장될 수 있다.

	extension SnakesAndLadders: TextRepresentable {
	    func asText() -> String {
	        return "A game of Snakes and Ladders with \(finalSquare) squares"
	    }
	}
	println(game.asText())
	// prints "A game of Snakes and Ladders with 25 squares"


#### 확장에 프로토콜 도입 선언

만약 타입이 이미 프로토콜의 모든 요구사항을 준수한지만 아직 프로토콜을 도입하는 상태가 아니라면, 빈 확장에 프로토콜을 도입하도록 만들 수 있다.

	struct Hamster {
	    var name: String
	    func asText() -> String {
	        return "A hamster named \(name)"
	    }
	}
	extension Hamster: TextRepresentable {}

Hamster 인스턴스는 TextRepresentable이 필요한 타입인 곳에 사용될 수 있다.

	let simonTheHamster = Hamster(name: "Simon")
	let somethingTextRepresentable: TextRepresentable = simonTheHamster
	println(somethingTextRepresentable.asText())
	// prints "A hamster named Simon"

위 예제에서 somethingTextRepresentable은 TextRepresentable 프로토콜 타입이므로 asText 메소드만 사용할 수 있다. 따라서 Hamster 인스턴스인 simonTheHamster 인스턴스를 값 복사된 somethingTextRepresentable은 asText 메소드만 사용가능하다.

<div class="alert-info">
	타입은 요구사항이 만족만 한다고 해서 자동으로 프로토콜을 도입하지 않는다. 프로토콜의 도입을 항상 명시적으로 선언해야 한다.
</div>

### 프로토콜 타입의 컬렉션(Collections of Protocol Types)

프로토콜은 배열 또는 딕셔너리 같은 컬렉션에 저장하는 타입을 사용할 수 있다. 다음은 TextRepresentable의 배열 예제이다.

	let things: [TextRepresentable] = [game, d12, simonTheHamster]

배열에 각 항목을 반복문으로 출력하는 것이 가능하다.

	for thing in things {
	    println(thing.asText())
	}
	// A game of Snakes and Ladders with 25 squares
	// A 12-sided dice
	// A hamster named Simon

실제로는 Dice, DiceGame, Hamster 타입이다. 그럼에도 불구하고 이들 타입은 TextRepresentable 프로토콜을 도입하였고, TextRepresentable 프로토콜은 asText 메소드를 가지고 있음을 알려져있다. 따라서 thing.asText를 매번 호출하는 것이 안전하다.

### 프로토콜 상속

프로토콜은 하나 이상의 프로토콜을 상속할 수 있고 요구사항 위에 요구사항을 상속하여 추가할 수 있다. 프로토콜 상속 문법은 클래스 상속 문법과 비슷하다.

	protocol InheritingProtocol: SomeProtocol, AnotherProtocol {
	    // protocol definition goes here
	}

다음은 TextRepresentable 프로토콜을 상속받은 프로토콜 예제이다.

	protocol PrettyTextRepresentable: TextRepresentable {
	    func asPrettyText() -> String
	}

새로운 프로토콜 PrettyTextRepresentable는 TextRepresentable로부터 상속 받았다. PrettyTextRepresentable는 TextRepresentable를 강제로 모든 요구사항을 만족하며 PrettyTextRepresentable의 추가적인 요구사항을 강제로 더한다. 다음은 PrettyTextRepresentable가 asPrettyText 인스턴스 메소드를 제공하는 단일 요구사항을 추가한 예제이다.

	extension SnakesAndLadders: PrettyTextRepresentable {
	    func asPrettyText() -> String {
	        var output = asText() + ":\n"
	        for index in 1...finalSquare {
	            switch board[index] {
	            case let ladder where ladder > 0:
	                output += "▲ "
	            case let snake where snake < 0:
	                output += "▼ "
	            default:
	                output += "○ "
	            }
	        }
	        return output
	    }
	}

	println(game.asPrettyText())
	// A game of Snakes and Ladders with 25 squares:
	// ○ ○ ▲ ○ ○ ▲ ○ ○ ▲ ▲ ○ ○ ○ ▼ ○ ○ ○ ○ ▼ ○ ○ ▼ ○ ▼ ○


### 클래스 전용 프로토콜(Class-Only Protocols)

클래스 타입에 클래스 키워드 `class`를 프로토콜 상속 목록에 추가하여 프로토콜을 도입하는 것에는 제한할 수 있다. `class` 키워드는 항상 첫번째 프로토콜 상속 목록 앞에 있어야 한다.

	protocol SomeClassOnlyProtocol: class, SomeInheritedProtocol {
	    // class-only protocol definition goes here
	}

SomeClassOnlyProtocol은 클래스 타입에만 도입되며 구조체나 열거형 정의에 SomeClassOnlyProtocol를 도입하려고 하면 컴파일 에러가 발생한다.

<div class="alert-info">
	클래스 전용 프로토콜은 프로토콜의 요구사항이 준수한 타입이 값 의미보다 참조 의미를 가지는 것을 가정하거나 필요로 하는 것을 정의하는 행동일 때 사용된다.
</div>


### 프로토콜 구성(Protocol Comsposition)

필요한 타입을 준수하는 다중 프로토콜로 사용할 수 있다. 다중 프로토콜을 단일 요구사항인 프로토콜 구성으로 결합할 수 있다. 프로토콜 구성은 `protocol<SomeProtocol, AnotherProtocol>` 형태로 가진다. 

다음은 두 개의 프로토콜을 하나의 프로토콜 구성 요구사항으로 결합하는 예제이다.

	protocol Named {
	    var name: String { get }
	}
	protocol Aged {
	    var age: Int { get }
	}
	struct Person: Named, Aged {
	    var name: String
	    var age: Int
	}
	func wishHappyBirthday(celebrator: protocol<Named, Aged>) {
	    println("Happy birthday \(celebrator.name) - you're \(celebrator.age)!")
	}
	let birthdayPerson = Person(name: "Malcolm", age: 21)
	wishHappyBirthday(birthdayPerson)
	// prints "Happy birthday Malcolm - you're 21!"

위에서 wishHappyBirthday라는 함수는 celebrator라는 인자를 취한다. 이 인자의 타입은 `protocol<Name, Aged>`이며, Name과 Age 프로토콜을 준수하는 타입이라는 의미이다. 함수에 특정 타입으로 넘겨줄 필요가 없고, 필요한 프로토콜과 준수하는 타입만 넘겨주면 된다.

따라서 wishHappyBirthday 함수에 Person 인스턴스를 넘겨주는데, Person은 두 프로토콜과 준수하기 때문에 인자로 념겨받을 수 있다.

<div class="alert-info">
	프로토콜 구성은 새로운 영구 프로토콜 타입을 정의하는 것이 아니다. 모든 프로토콜의 결합된 요구사항을 가지는 임시 지역 프로토콜을 정의한다.
</div>


### 프로토콜 준수를 위한 검사(Checking for Protocol Conformance)

`is`와 `as` 연산자를 사용하여 프로토콜 준수를 위한 검사로 사용할 수 있으며, 특정 프로토콜로 캐스팅할 수 있다. 타입을 캐스팅하고 검사하는 문법으로 프로토콜을 확인하고 캐스팅할 수 있다.

	* `is` 연산자는 인스턴스가 프로토콜과 준수하면 true, 그렇지 않다면 false를 반환한다.
	* `as?`는 연산자 다운캐스팅 버전으로 프로토콜의 타입의 옵셔널 값을 반환하며, 이 값은 인스턴스가 프로토콜과 준수하지 않으면 nil 값을 가진다.
	* `as`는 연산자 다운캐스팅 버전으로 프로토콜 타입을 강제로 다운캐스팅을 하며, 만약 다운캐스팅이 성공하지 않으면 런타임 에러가 발생한다.

다음은 HasArea라는 프로토콜 정의 예제로, area라는 Double 속성의 요구사항을 가진다.

	@objc protocol HasArea {
	    var area: Double { get }
	}

<div class="alert-info">
	프로토콜이 <code>@objc</code> 속성으로 표시된다면, 프로토콜 준수를 검사할 수 있다. 이 속성은 프로토콜이 Objective-C 코드에 드러나도록 한다. 심지어 Objective-C와 상호 운용을 하지 않아도 프로토콜에 <code>@objc</code> 속성을 표시해야 한다. 그래야 프로토콜 준수를 검사가 가능하다.

	<code>@objc</code> 프로토콜은 클래스에만 도입되며 구조체와 열거형에는 도입되지 않는다. 만약 프로토콜에 <code>@objc</code>를 표시하여 준수를 검사한다면, 클래스 타입에만 프로토콜이 적용 가능 할 것이다.
</div>

다음은 HasArea 프로토콜을 준수시킨 두 개의 클래스 예제이다.

	class Circle: HasArea {
	    let pi = 3.1415927
	    var radius: Double
	    var area: Double { return pi * radius * radius }
	    init(radius: Double) { self.radius = radius }
	}
	class Country: HasArea {
	    var area: Double
	    init(area: Double) { self.area = area }
	}

Circle 클래스는 계산 속성으로서 area 속성 요구사항을 구현한다. Country 클래스는 저장 속성으로서 area 요구사항을 구현한다. 이들 클래스는 정확히 HasArea 프로토콜을 준수시킨다.

다음은 HasArea 프로토콜을 준수시키지 않은 클래스 예제이다.

	class Animal {
	    var legs: Int
	    init(legs: Int) { self.legs = legs }
	}

Circle, Country, Animal 클래스는 공유된 기반 클래스가 없다. 그럼에도 불구하고 이들 클래스는 AnyObject 타입으로 배열에 저장하여 사용할 수 있다.

	let objects: [AnyObject] = [
	    Circle(radius: 2.0),
	    Country(area: 243_610),
	    Animal(legs: 4)
	]

다음은 objects 배열은 반복하여 배열의 각 객체에서 HasArea 프로토콜과 준수하는지 검사하는 예제이다.

	for object in objects {
	    if let objectWithArea = object as? HasArea {
	        println("Area is \(objectWithArea.area)")
	    } else {
	        println("Something that doesn't have an area")
	    }
	}
	// Area is 12.5663708
	// Area is 243610.0
	// Something that doesn't have an area

객체가 HasArea 프로토콜과 준수하면 옵셔널 값은 `as?` 연산자가 objectWithArea라는 상수에 옵셔널 바인딩과 함께 드러나 반환된다. objectWithArea 상수는 HasArea 타입으로 알려졌기 때문에 area 속성을 접근하는 것이 안전하다.

또한, objectWithArea 상수는 HasArea 타입으로만 알려졌기 때문에 area 속성만 접근이 가능하다.

### 옵셔널 프로토콜 요구사항(Optional Protocol Requirement)

프로토콜을 위한 옵셔널 요구사항을 정의할 수 있는데, 이들 요구사항은 프로토콜에 준수하는 타입을 구현하지 않는다. 옵셔널 요구사항은 프로토콜의 정의 한 부분으로 `optional` 수식어를 앞에 붙인다.

옵셔널 프로토콜 요구사항은 옵셔널 체이닝으로 호출될 수 있으며, 요구사항은 프로토콜에 준수하는 타입이 구현되지 않는다.

옵셔널 요구사항의 구현을 위해 `someOptionalMethod?(someArgument)`와 같이 호출될 때 요구 사항의 이름 뒤에 물음표가 적혀있는지 검사한다. 옵셔널 속성 요구사항과 옵셔널 메소드 요구사항은 접근하거나 호출될 때 항상 적합한 타입의 옵셔널 값을 반환하며, 옵셔널 요구사항이 구현되지 않았음을 반영한다.

<div class="alert-info">
	옵셔널 프로토콜 요구사항은 프로토콜이 <code>@objc</code> 속성으로 표시된다면 지정 될 수 있다. 심지어 Objective-C에 상호 운용되지 않더라도 옵셔널 요구사항에 <code>@objc</code>를 표시해야 한다.

	<code>@objc</code> 프로토콜은 클래스에만 도입되고 구조체나 열거형에는 도입되지 않는다. 옵셔널 요구사항에 지정되게 <code>@objc</code>를 프로토콜에 표시한다면 클래스 타입에 프로토콜이 적용될 것이다.
</div>

다음은 증감 연산자 프로토콜로 두가지 옵셔널 요구사항을 가지는 예제이다.

	@objc protocol CounterDataSource {
	    optional func incrementForCount(count: Int) -> Int
	    optional var fixedIncrement: Int { get }
	}

<div class="alert-info">
	엄밀히 말하면 프로토콜 요구사항을 전혀 구현하지 않고 CounterDataSource에 준수하는 클래스를 만들 수 있다. 이는 옵셔널이기 때문이지만, 가능은 하지만 좋은 방법은 아니다.
</div>

다음은 CounterDataSource? 타입의 옵셔널 속성 dataSource를 가지는 클래스 예제이다.

	@objc class Counter {
	    var count = 0
	    var dataSource: CounterDataSource?
	    func increment() {
	        if let amount = dataSource?.incrementForCount?(count) {
	            count += amount
	        } else if let amount = dataSource?.fixedIncrement? {
	            count += amount
	        }
	    }
	}

Counter 클래스는 increment라는 메소드를 정의하며, 매번 count 속성을 호출할 때 마다 증가시킨다.

increment 메소드는 dataSource에서 incrementForCount 메소드가 구현되어 있는지 찾는데, increment 메소드는 옵셔널 체이닝으로 incrementForCount를 호출 시도한다. 그리고 메소드의 단일 인자로서 count 값을 넘긴다.

옵셔널 체이닝의 두 단계에 대해 주의해야 한다. 첫번째, dataSource가 nil일 가능성이 있어 dataSource는 incrementForCount 호출하기 전에 물음표를 붙여 나타낸다. 두번째로 dataSource는가 존재하지만 incrementForCount가 구현되었다는 보장이 없다. 이는 옵셔널 요구사항이기 때문이다. 따라서 incrementForCount 메소드 다음에 물음표를 표시한다.

마찬가지로 dataSource의 fixedIncrement 속성도 옵셔널이기 때문에 옵셔널 체이닝을 통해 접근하게 된다.

다음은 CounterDataSource를 구현한 간단한 클래스 예제이다.

	class ThreeSource: CounterDataSource {
	    let fixedIncrement = 3
	}

이 클래스는 fixedIncrement 옵셔널 요구사항과 준수한다.

Counter 인스턴스에 dataSource로서 ThreeSource 인스턴스를 사용할 수 있다.

	var counter = Counter()
	counter.dataSource = ThreeSource()
	for _ in 1...4 {
	    counter.increment()
	    println(counter.count)
	}
	// 3
	// 6
	// 9
	// 12

다음은 CounterDataSource를 도입한 조금 더 복잡한 클래스 예제이다.

	class TowardsZeroSource: CounterDataSource {
	    func incrementForCount(count: Int) -> Int {
	        if count == 0 {
	            return 0
	        } else if count < 0 {
	            return 1
	        } else {
	            return -1
	        }
	    }
	}


TowardsZeroSource 클래스는 CounterDataSource 프로토콜로부터 기존 incrementForCount 메소드를 구현한다. 

따라서 Counter 클래스는 increment 메소드에서 incrementForCount 메소드가 구현되었기 때문에 호출이 가능하다.

	counter.count = -4
	counter.dataSource = TowardsZeroSource()
	for _ in 1...5 {
	    counter.increment()
	    println(counter.count)
	}
	// -3
	// -2
	// -1
	// 0
	// 0

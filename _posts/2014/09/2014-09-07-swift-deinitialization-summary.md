---
layout: post
title: "Swift - Deinitialization 정리"
description: ""
category: "mac/ios"
tags: [swift, deinitializer, deallocation, class, deinitialization, deinit, init, initializer, nil, reference, arc]
---
{% include JB/setup %}

## 초기화 해제(Deinitialization)

디이니셜라이저는 클래스 인스턴스가 할당 해지되기전에 즉각 호출되며, 이니셜라이저의 `init` 키워드와 비슷하게 `deinit` 키워드를 사용한다. 또한, 클래스 타입에서만 가능하다.

### 초기화 해제 작업 방법(How Deinitialization Works)

Swift는 자동적으로 더이상 필요가 없으면 인스턴스를 리소스에서 할당 해제한다. Swift는 인스턴스 메모리 관리를 ARC로 다루며, 인스턴스가 할당 해제될 때 수동으로 정리할 필요가 없다. 만약 할당 해지할 때 필요한 작업을 수행할 수 있다.

클래스마다 하나 정도는 디이니셜라이저를 가지고 있으며, 어떠한 인자도 취하지 않는다.

	deinit {
	    // perform the deinitialization
	}

디이니셜라이저는 인스턴스 할당 해제 전에 자동으로 호출되어, 수동으로 호출하는 것을 허락하지 않는다. 슈퍼클래스 디이니셜라이저는 서브클래스에 상속하며, 서브클래스 디이니셜라이저 작업이 끝나면 자동으로 슈퍼클래스 디이니셜라이저가 호출된다. 서브클래스에 디이니셜라이저가 제공되지 않더라도 슈퍼클래스 디이니셜라이저가 항상 호출된다.

디이니셜라이저가 호출될때까지 인스턴스를 할당 하제 하지 못하기때문에 디이니셜라이저는 인스턴스의 모든 속성에 접근할 수 있으며, 이들 속성을 가지고 변경 작업을 호출할 수 있다(가령 파일이 닫힐 때 파일 이름을 찾는 동작).

### 디이니셜라이저 사용(Deinitializers in Action)

Bank와 Player 두 개의 새로운 타입을 정의하며, Bank 구조체는 통화를 관리하고 만개의 동전까지만 유통할 수 있다. 또한, 현재 상태를 관리 및 저장하기 위해 정적 속성과 메소드를 가진다.

	struct Bank {
	    static var coinsInBank = 10_000
	    static func vendCoins(var numberOfCoinsToVend: Int) -> Int {
	        numberOfCoinsToVend = min(numberOfCoinsToVend, coinsInBank)
	        coinsInBank -= numberOfCoinsToVend
	        return numberOfCoinsToVend
	    }
	    static func receiveCoins(coins: Int) {
	        coinsInBank += coins
	    }
	}

Bank는 동전의 현재 갯수를 coinsInBank 속성으로 추적 유지한다. 두 개의 메소드는 동전의 수집과 분배를 다룬다.

vendCoins는 분배하기 전에 은행에 동전이 충분한지 검사하며 충분치 않다면 남은 동전 모두를 반환한다. numberOfCoinsToVend 변수 인자는 메소드 내에서 숫자를 수정할 수 있으며 새로운 변수를 선언할 필요가 없다.

receiveCoins 메소드는 은행 동전에서 받은 수의 동전을 단순히 더한다.

Player 클래스는 사용자를 설명하는데, 각 사용자는 얼마만큼의 동전을 가지며 이는 사용자의 coinsInPurse 속성에 표현된다.

	class Player {
	    var coinsInPurse: Int
	    init(coins: Int) {
	        coinsInPurse = Bank.vendCoins(coins)
	    }
	    func winCoins(coins: Int) {
	        coinsInPurse += Bank.vendCoins(coins)
	    }
	    deinit {
	        Bank.receiveCoins(coinsInPurse)
	    }
	}

각 Player 인스턴스는 초기화 하는 동안 은행으로부터 얼마만큼의 동전을 받고 시작을 하며, Player 인스턴스는 은행이 충분히 돈이 많지 않다면 얼마 못받을 것이다. 

Player 클래스는 winCoins 메소드를 정의하는데 은행으로부터 얼마만큼의 동전을 받아 사용자 지갑에 추가한다. Player 클래스는 디이니셜라이저를 수행하여 Player 인스턴스가 할당 해제되기 전에 호출된다. 디이니셜라이저는 은행에 사용자의 모든 동전을 돌려준다.

	var playerOne: Player? = Player(coins: 100)
	println("A new player has joined the game with \(playerOne!.coinsInPurse) coins")
	// prints "A new player has joined the game with 100 coins"
	println("There are now \(Bank.coinsInBank) coins left in the bank")
	// prints "There are now 9900 coins left in the bank"

새로운 Player 인스턴스가 생성되면 100개 동전을 요청한다. Player 인스턴스는 playerOne이라는 옵셔널 Player 변수에 저장되고, 옵셔널 변수가 사용된 것은 수시로 게임을 나갈 수 있기 때문이다. 옵셔널은 사용자가 게임에서 있는지 추적하도록 한다.

playerOne은 옵셔널이기 때문에, coinsInPurse 속성이 기본 동전 수를 출력하기 위해 접근될 때, 그리고 winCoins 메소드가 호출될 때 느낌표를 사용한다.

	playerOne!.winCoins(2_000)
	println("PlayerOne won 2000 coins & now has \(playerOne!.coinsInPurse) coins")
	// prints "PlayerOne won 2000 coins & now has 2100 coins"
	println("The bank now only has \(Bank.coinsInBank) coins left")
	// prints "The bank now only has 7900 coins left"

사용자는 2,000개 동전을 가지는데, 이제는 2,100 개 동전을 가지며, 은행은 7,900개 동전만 남는다.

	playerOne!.winCoins(2_000)
	println("PlayerOne won 2000 coins & now has \(playerOne!.coinsInPurse) coins")
	// prints "PlayerOne won 2000 coins & now has 2100 coins"
	println("The bank now only has \(Bank.coinsInBank) coins left")
	// prints "The bank now only has 7900 coins left"

사용자가 게임에서 나간다고 하면 옵셔널 playerOne 변수는 nil로 설정되고 사용자 인스턴스 가 없다라는 의미가 된다. 이 동작이 발생하는 시점에서 playerOne 변수의 player 인스턴스 참조는 깨진다. Player 인스턴스에 아무런 속성 또는 변수를 참조하지 않고 메모리에서 할당해제가 된다. 이러한 동작이 발생하기 전에 디이니셜라이저는 자동적으로 호출되며, 동전은 은행으로 돌아간다.
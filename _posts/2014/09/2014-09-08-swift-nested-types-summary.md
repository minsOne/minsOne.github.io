---
layout: post
title: "Swift Nested Types Summary"
description: ""
category: "mac/ios"
tags: [swift, nested type, structure, enumeration, class]
---
{% include JB/setup %}

## 중첩 타입(Nested Types)

열거형은 종종 특정 클래스나 구조체의 기능을 지원하기 위해 만든다. 기능 클래스와 구조체를 좀 더 복잡한 타입의 컨텍스트 안에서 사용하도록 정의한다. Swift는 중첩 타입은 중첩을 지원하는 열거형, 클래스 그리고 구조체를 내장 타입으로 사용하도록 정의한다.

다른 타입에서 타입을 중첩하기 위해서는 타입의 괄호 밖에 정의해야 하며, 타입은 필요한 만큼의 여러 수준으로 중첩할 수 있다.

### 중첩 타입 사용(Nested Types in Action)

BalckjackCard라는 구조체는 블랙잭 게임에서 사용하는 게임 카드로 만들어 정의한다. BalckjackCard 구조체는 Suit와 Rank라는 두가지 열거형 타입을 포함한다.

블랙잭은 일에서 십일까지 값인 에이스카드를 가진다. 이러한 특징은 Values라는 구조체를 표현하는데 Rank 열거형 안에 중첩되어 있다.

	struct BlackjackCard {
	    
	    // nested Suit enumeration
	    enum Suit: Character {
	        case Spades = "♠", Hearts = "♡", Diamonds = "♢", Clubs = "♣"
	    }
	    
	    // nested Rank enumeration
	    enum Rank: Int {
	        case Two = 2, Three, Four, Five, Six, Seven, Eight, Nine, Ten
	        case Jack, Queen, King, Ace
	        struct Values {
	            let first: Int, second: Int?
	        }
	        var values: Values {
	            switch self {
	            case .Ace:
	                return Values(first: 1, second: 11)
	            case .Jack, .Queen, .King:
	                return Values(first: 10, second: nil)
	            default:
	                return Values(first: self.toRaw(), second: nil)
	                }
	        }
	    }
	    
	    // BlackjackCard properties and methods
	    let rank: Rank, suit: Suit
	    var description: String {
	        var output = "suit is \(suit.toRaw()),"
	            output += " value is \(rank.values.first)"
	            if let second = rank.values.second {
	                output += " or \(second)"
	            }
	            return output
	    }
	}

Suit 열거형은 일반 게임 카드 네 벌을 설명하며, 그에 해당하는 문자 기호를 함께 나타낸다.

Rank 열거형은 13가지 게임 카드 랭크와 그에 맞는 정수 값을 나타낸다. 

Rank 열거형은 Values라는 중첩된 구조체를 정의하며, 이 구조체는 대부분의 카드는 한 개의 값을 가지지만 에이스 카드는 두개의 값을 가진다는 사실을 캡슐화 한다. Values 구조체는 다음 두 개의 속성을 표시하여 정의한다. 

* Int 타입의 first
* Int? 나 옵셔널 Int 타입의 second

Rank는 계산 속성으로 values를 정의하며 Values 구조체의 인스턴스를 반환한다. 계산 속성은 카드의 순위를 고려하고 새로운 Values 인스턴스를 순위를 기반으로 적합한 값으로 초기화한다.

BlackjackCard 구조체는 두개의 속성 rank와 suit 속성을 가지며 description이라는 계산 속성은 저장된 rank와 suit의 값을 사용하여 이름 설명과 카드의 값을 만든다.

BlackjackCard 구조체는 사용자 이니셜라이저를 가지지 않으며, 암시적인 멤버 이니셜라이저를 가진다. 이니셜라이저는 theAceOfSpades 상수를 초기화하도록 사용할 수 있다.

	let theAceOfSpades = BlackjackCard(rank: .Ace, suit: .Spades)
	println("theAceOfSpades: \(theAceOfSpades.description)")
	// prints "theAceOfSpades: suit is ♠, value is 1 or 11"

BlackjackCard 안에 중첩된 Rank와 Suit가 있다고 할지라도 이들 타입은 컨텍스트로부터 추론되며, 인스턴스의 초기화는 멤버 이름으로부터 열거형 이름을 참조할 수 있다(.Ace와 .Spades).

### 중첩 타입 인용(Referring to Nested Types)

정의 컨텍스트 밖에서 중첩타입을 사용하고자 한다면, 자신의 중첩 타입 이름 앞에 접두사를 붙인다.

	let heartsSymbol = BlackjackCard.Suit.Hearts.toRaw()
	// heartsSymbol is "♡"

위 예제에서 Suit, Rank 그리고 Value의 이름은 일부로 짧게 유지하는것이 가능하다. 이들 이름이 정의된 컨텍스트에 의해 자연스럽게 제한되기 때문이다.
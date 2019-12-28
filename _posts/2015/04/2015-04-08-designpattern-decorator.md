---
layout: post
title: "[DesignPattern]데코레이터 패턴(Decorator Pattern)"
description: ""
category: "programming"
tags: [designPattern, decorator, wrapper, swift, super, class, protocol, component, decorator, concrete, abstract, generator]
---
{% include JB/setup %}

## 데코레이터 패턴(Decorator Pattern)

데코레이터 패턴은 기존의 코드를 건드리지 않고 확장하도록 합니다. 디자인의 원칙 중 하나인 OCP(Open-Closed Principle)을 준수합니다. 

<br/><img src="{{ site.production_url }}/image/2015/Decorator_UML.png" alt="Decorator_UML" style="width: 400px;"/><br/><br/>

출처 : Head First Design Pattern

* Component
: 추상 클래스로 데코레이터로 감싸져 사용될 수 있음. 
* ConcreteComponent
: 인터페이스를 동적으로 추가함.
* Decorator
: Decorator 안에는 Component 객체를 가짐. 자신이 장식할 구성요소와 같은 인터페이스 또는 추상 클래스를 구현함.
* ConcreteDecorator
: Decorator가 감싸고 있는 Component 객체를 위한 인스턴트 변수가 있어 Component 상태를 확장할 수 있음. 

### 데코레이터 패턴 예제

커피 주문시 추가 주문이 들어왔을 때 데코레이터 패턴을 통해 기존 코드를 건드리지 않고 확장하도록 하는 예제입니다.

Component로 사용할 추상클래스 Coffee를 만듭니다.

	protocol Coffee {
		func getCost() -> Double
		func getIngredients() -> String
	}

<br/>
추상클래스 Coffee를 상속받은 SimpleCoffee를 만들어 ConcreteComponent 역할을 수행하도록 합니다. SimpleCoffee는 다른 추가 주문이 들어올 때 감싸지도록 합니다.

	class SimpleCoffee: Coffee {
		func getCost() -> Double {
			return 1.0
		}

		func getIngredients() -> String {
			return "Coffee"
		}
	}

<br/>추상 클래스 Coffee를 확장하여 Decorator 역할을 수행하도록 합니다.

	class CoffeeDecorator: Coffee {
		private let decoratedCoffee: Coffee
		private let ingredientSeparator: String = ", "

		required init(decoratedCoffee: Coffee) {
			self.decoratedCoffee = decoratedCoffee
		}

		func getCost() -> Double {
			return decoratedCoffee.getCost()
		}

		func getIngredients() -> String {
			return decoratedCoffee.getIngredients()
		}
	}

<br/>CoffeeDecorator를 상속받아 상태를 확장하여 ConcreteDecorator 역할을 수행하도록 합니다.

	class Milk: CoffeeDecorator {
		required init(decoratedCoffee: Coffee) {
			super.init(decoratedCoffee: decoratedCoffee)
		}

		override func getCost() -> Double {
			return super.getCost() + 0.5
		}

		override func getIngredients() -> String {
			return super.getIngredients() + ingredientSeparator + "Milk"
		}
	}

	class WhipCoffee: CoffeeDecorator {
			required init(decoratedCoffee: Coffee) {
				super.init(decoratedCoffee: decoratedCoffee)
			}

			override func getCost() -> Double {
				return super.getCost() + 0.7
			}

			override func getIngredients() -> String {
				return super.getIngredients() + ingredientSeparator + "Whip"
			}
	}

<br/>Milk와 WhipCoffee는 Decorator를 상속받아 동적으로 인스턴스 객체를 바꿈으로서 객체를 감쌉니다. 따라서 구성을 활용함으로서 조합을 마음대로 선택하여 만들 수 있습니다.

### 코드 수행

	var someCoffee: Coffee = SimpleCoffee()
	println("Cost : \(someCoffee.getCost()); Ingredients: \(someCoffee.getIngredients())")
	// Cost : 1.0; Ingredients: Coffee

	someCoffee = Milk(decoratedCoffee: someCoffee)
	println("Cost : \(someCoffee.getCost()); Ingredients: \(someCoffee.getIngredients())")
	// Cost : 1.5; Ingredients: Coffee, Milk

	someCoffee = WhipCoffee(decoratedCoffee: someCoffee)
	println("Cost : \(someCoffee.getCost()); Ingredients: \(someCoffee.getIngredients())")
	// Cost : 2.2; Ingredients: Coffee, Milk, Whip

<br/>

getCost를 수행하면 super.getCost를 먼저 수행하므로 감싸져있는 SimpleCoffee를 찾아 getCost를 수행하고 그다음으로 감싸져있는 Milk, Whip를 차례로 더하여 최종 결과를 가져옵니다.

코드를 건드리지 않고 확장하여 OCP를 준수하고 있음을 확인할 수 있습니다.

### 참고 자료

* Head First Design Pattern
* [자바지기][javajigi]
* [Swift Code][GitHub Swift Decorator]

[javajigi]: http://www.javajigi.net/display/SWD/ch03_decoratorpattern
[GitHub Swift Decorator]: https://github.com/ochococo/Design-Patterns-In-Swift#-decorator
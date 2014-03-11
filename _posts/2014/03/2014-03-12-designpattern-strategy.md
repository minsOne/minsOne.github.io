---
layout: post
title: "디자인패턴 - 입문 및 전략패턴"
description: ""
category: "designPattern"
tags: [designPattern, strategy, pattern, interface, class, inheritance, constructor, abstract]
---
{% include JB/setup %}

## 들어가기

개발하면서 디자인패턴에 대한 이야기를 많이 들었지만 실제로 사용을 잘 하지는 못합니다. 은연중에 이렇게 하면 안된다는 것은 알지만 어떻게 구체적으로 해야하는지에 대한 개념이 명확하지 않아 나중에 유지보수할 때 점점 복잡해지는 코드들을 보게 됩니다.

그래서 똑같은 문제를 경험했고, 그 문제를 해결했던 다른 개발자들이 익혔던 지혜와 교훈을 왜 활용해야 하는지, 그리고 어떻게 활용할 수 있는지에 대해서 설명합니다.

## 기본적인 클래스 구조

다양한 오리 종류를 보여주려고 하는 클래스를 만들려고 합니다. 부모 클래스인 Duck 클래스를 생성하고 그 클래스를 확장하여 다른 모든 종류의 오리를 만듭니다.
	
> 부모 클래스 MODuck 

	 // MODuck.h
	 #import <Foundation/Foundation.h>
	 @interface MODuck : NSObject
	 // 모든 오리들이 행동할 수 있도록 추상메소드로 작성
	 - (void)quack;
	 - (void)swim;
	 - (void)display;
	 @end
 
 	 // MODuck.m
 	 #import "MODuck.h"
 	 @implementation MODuck
	 @end

> 자식 클래스 MOMallardDuck, MORedheadDuck
	
	 // MOMallardDuck.h
	 #import "MODuck.h"
 	 @interface MOMallardDuck : MODuck
 	 - (void)display;
 	 @end

 	 // MOMallardDuck.m
 	 #import "MOMallardDuck.h"
 	 @implementation MOMallardDuck
	 @end


	 // MORedheadDuck.h
	 #import "MODuck.h"
	 @interface MORedheadDuck : MODuck
	 - (void)display;
	 @end

	 // MORedheadDuck.m
	 #import "MORedheadDuck.h"
	 @implementation MORedheadDuck
	 @end


이제 여기에서 오리들이 날 수 있도록 추가해야 합니다. 그러면 보통은 부모 클래스에 fly라는 추상메소드를 작성하여 자식 클래스에서 상속 받도록 합니다.

> 부모 클래스 MODuck 

	 // MODuck.h
	 #import <Foundation/Foundation.h>
	 @interface MODuck : NSObject	 
	 // 모든 오리들이 행동할 수 있도록 추상메소드로 작성
	 - (void)quack;
	 - (void)swim;
	 - (void)display;
	 - (void)fly;	// 오리들이 날 수 있도록 추가	 
	 @end


그런데 모든 오리들이 다 날 수 있는 것은 아니라는 문제가 발생합니다. 모형오리인 경우에는 날지를 못하니 말이죠. 

그래서 fly 메소드를 override를 하여 아무것도 하지 않도록 작성합니다.

> 자식 클래스 MORubberDuck

	 // MORubberDuck.h
	 #import "MODuck.h"
 	 @interface MORubberDuck : MODuck
 	 @end

 	 // MORubberDuck.m
	 #import "MODuck.h"
 	 @interface MORubberDuck : MODuck
 	 @end

만약 다양한 오리들이 계속 나오고 각각의 오리들이 다른 소리를 내거나 특성을 가진다면 모두 override해야 한다는 것이 됩니다. 

모든 특성을 가지되 행동하지 않게 만들어버리는 형태로 되기 때문에 코드가 지저분해지고 재사용성이 떨어집니다.

그렇다면 어떻게 해야 할지 살펴봅시다.

### 디자인 원칙

`애플리케이션에서 달라지는 부분을 찾아내고, 달라지지 않는 부분으로부터 분리시키는 것`이 원칙 중 하나입니다. 즉, 코드에 새로운 요구사항이 있을 때마다 바뀌는 부분이 있다면, 그 행동을 바뀌지 않는 다른 부분으로부터 골라내서 분리해야 한다는 것을 알 수 있습니다. 

그렇다면 바뀌는 부분을 따로 분리시켜 캡슐화하면 다른 부분에 영향을 미치지 않은 채로 수정하거나 확장할 수 있습니다.

변화하는 부분과 그대로 있는 부분을 분리하려면 두 개의 클래스 집합을 만들어야 합니다. 하나는 나는 것과 관련된 집합이고 다른 하나는 꽥꽥거리는 것과 관련된 부분입니다. 각 클래스 집합에는 각각의 행동을 구현한 것을 집어 넣습니다.

두 클래스 집합을 디자인하기 위해서는 최대한 유연하게 하도록 합니다. 따라서 `구현이 아닌 인터페이스에 맞춰서 프로그래밍`하도록 합니다.

나는 행동과 꽥꽥거리는 행동은 MODuck에서 구현하지 않고 특정 행동만을 목적으로 하는 클래스 집합으로 구현합니다.

- 나는 행동

> 추상 인터페이스 FlyBehavior
	
	 // MOFlyBehavior.h
 	 #import <Foundation/Foundation.h>
  	 @interface MOFlyBehavior : NSObject
 	 - (void)fly;
 	 @end

 	 // MOFlyBehavior.m
 	 #import "MOFlyBehavior.h"
 	 @implementation MOFlyBehavior
 	 @end

> 구상 인터페이스 FlyWithWings, MOFlyBehavior

	 // MOFlyWithWings.h
	 #import "MOFlyBehavior.h"
	 @interface MOFlyWithWings : MOFlyBehavior
	 @end

 	 // MOFlyWithWings.m
	 #import "MOFlyWithWings.h"
	 @implementation MOFlyWithWings
	 - (void)fly{
	     //Do SomeThing
	 }
	 @end

 	 // MOFlyNoWay.h
	 #import "MOFlyBehavior.h"
	 @interface MOFlyNoWay : MOFlyBehavior
	 @end

 	 // MOFlyNoWay.m
	 #import "MOFlyNoWay.h"
	 @implementation MOFlyNoWay
	 - (void)fly{
	     //Don`t doing
	 }
	 @end

- 꽥꽥거리는 행동

> 추상 인터페이스 MOQuackBehavior

	 // MOQuackBehavior.h
	 #import <Foundation/Foundation.h>
 	 @interface MOQuackBehavior : NSObject
	 - (void)quack;
	 @end

	 // MOQuackBehavior.m
 	 #import "MOQuackBehavior.h"
 	 @implementation MOQuackBehavior
 	 @end

> 구상 인터페이스 MOQuack, MOSqueak, MOMutuQuack

	 // MOQuack.h
	 #import "MOQuackBehavior.h"
 	 @interface MOQuack : MOQuackBehavior
 	 @end

 	 // MOQuack.m
 	 #import "MOQuack.h"
 	 @implementation MOQuack
	 - (void)quack{
	     //speak that Quack
	 }
	 @end

	 // MOSqueak.h
 	 #import "MOQuackBehavior.h"
 	 @interface MOSqueak : MOQuackBehavior
 	 @end

 	 // MOSqueak.m
 	 #import "MOSqueak.h"
 	 @implementation MOSqueak
	 - (void)quack{
	     //speak squeak
	 }
	 @end

	 // MOMutuQuack.h
 	 #import "MOQuackBehavior.h"
 	 @interface MOMutuQuack : MOQuackBehavior
 	 @end

 	 // MOMutuQuack.m
 	 #import "MOMutuQuack.h"
 	 @implementation MOMutuQuack
	 - (void)quack{
	     // Don`t doing
	 }
	 @end

위에 구현되는 객체가 코드에 고정이 되지 않도록 추상 인터페이스에 맞춰서 프로그래밍을 함으로써 다형성을 활용하였습니다. 따라서 `인터페이스에 맞춰서 프로그래밍`하는 것은 객체에 변수를 대입할 때 추상 인터페이스 같은 형식을 구체적으로 구현한 형식이라면 어떤 객체든 넣을 수 있기 때문입니다.


### 인터페이스 통합하기

앞에서 작성한 인터페이스 클래스들을 MODuck 클래스에 추가를 합니다. 나는 행동과 꽥꽥거리는 행동은 MOFlyBehavior MOQuackBehavior 인터페이스에 옮겨놨기 때문에 Duck 클래스 및 모든 서브클래스에서 fly(), quack() 메소드를 제거해야 합니다. 대신 performFly(), performQuack() 메소드를 추가합니다.

> 부모 클래스 MODuck
	 
	 // MODuck.h
	 #import <Foundation/Foundation.h>
	 #import "MOFlyBehavior.h"
	 #import "MOQuackBehavior.h"
 	 @interface MODuck : NSObject
 	 @property (nonatomic) MOFlyBehavior *flyBehavior;
	 @property (nonatomic) MOQuackBehavior *quackBehavior;
 	 - (void)swim;
	 - (void)display;
	 - (void)performQuack;
	 - (void)performFly;
 	 @end

 	 // MODuck.m
 	 #import "MODuck.h"
 	 @implementation MODuck
 	 - (void)performFly{
 	     [self.flyBehavior fly];
 	 }
 	 - (void)performQuack{
 	     [self.quackBehavior quack];
 	 }
 	 - (void)swim{}
 	 - (void)display{}

 	 @end
> 자식 클래스 MORubberDuck

	 // MORubberDuck.h
	 #import "MODuck.h"
 	 @interface MORubberDuck : MODuck
 	 @end

 	 // MORubberDuck.m
 	 #import "MORubberDuck.h"
	 #import "MOMutuQuack.h"
	 #import "MOFlyNoWay.h"
 	 @implementation MORubberDuck
 	 - (id)init
	 {
	     self = [super init];
	     if (self) {
	         self.quackBehavior = [[MOMutuQuack alloc]init];
	         self.flyBehavior = [[MOFlyNoWay alloc]init];
	     }
	     return self;
	 }
	 - (void)display{
	     NSLog(@"오리인형입니다.");
	 }
 	 @end


각 오리에는 MOFlyBehavior, MOQuackBehavior가 있으며 각각 행동을 위임받습니다. 두 클래스를 이런 식으로 합치는 것을 `구성(composition)`을 이용하는 것이라고 부릅니다. 여기에 나와있는 오리 클래스에서는 행동을 상속받는 대신, 올바른 행동 객체로 구성됨으로써 행동을 부여받게 됩니다. `상속보다는 구상을 이용`하여 시스템을 만들면 유연성을 크게 향상시킬 수 있으며 별도의 클래스 집합으로 캡슐화할 수 있도록 하며 실행시 행동을 바꿀 수도 있게 해줍니다.

지금 적용한 방식이 전략 패턴(Strategy Pattern)입니다. 다시 정의하자면 알고리즘군을 정의하고 각각을 캡슐화하여 교환해서 사용할 수 있도록 만듭니다. 전략 패턴을 활용하면 알고리즘을 사용하는 클라이언트와는 독립적으로 알고리즘을 변경할 수 있습니다.

## 정리하기

다른 개발자나 같은 팀에 있는 사람들과 패턴을 이용하여 의사소통을 할 때는 패턴 이름 뿐 아니라 그 패턴이 내포하고 있는 모든 내용, 특성, 제약조건 등을 함께 이야기할 수 있습니다. 따라서 패턴을 이용하면 객체와 클래스를 구현하는 것과 관련된 자잘한 내용에 대해 시간을 버릴 필요 없이 디자인 수준에서 초점을 맞출 수 있습니다.
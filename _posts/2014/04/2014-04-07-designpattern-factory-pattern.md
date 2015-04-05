---
layout: post
title: "디자인패턴 - 팩토리 패턴(Factory Pattern)"
description: ""
category: "programming"
tags: [designPattern, factory, pattern, interface, class, inheritance, constructor, abstract]
---
{% include JB/setup %}

## 팩토리 패턴(Factory Pattern)

팩토리 메소드 패턴에서는 객체 생성을 처리하는 클래스를 정의합니다. 다수의 클래스를 생성하고 상황에 맞는 클래스를 가지고 객체를 생성을 하는데 생성 클래스의 변경에 따른 소스 변경이 줄어듭니다. 그렇기때문에 생성되는 로직은 알 필요가 없고 클래스 객체만 그대로 가져다 사용을 하면 됩니다.

다음은 팩토리 패턴으로 사용할 예제 UML입니다.
<br/><img src="/../../../../image/2014/04/FactoryPattern-UML.png" alt="FactoryPattern-UML" style="width: 600px;"/><br/><br/>

UFOEnemyShip과 RocketEnemyShip은 EnemyShip에서 상속을 받아 객체를 생성을 하고 EnemyShipFactory에서는 Client에서 EnemyShip 클래스들을 생성할 부분을 가져와서 객체를 생성하여 반환하는 역할을 합니다.

### 팩토리 패턴을 사용하지 않는 경우

RocketEnemyShip과 UFOEnemyShip을 사용하기 위한 EnemyShip 클래스를 생성합니다.

	// MOEnemyShip.h
	#import <Foundation/Foundation.h>

	@interface MOEnemyShip : NSObject
 
	- (void)followHeroShip;
	- (void)displayEnemyShip;
	- (void)enemyShipShoots;
	- (void)setDamage:(double)dmg;
	- (double)getDamage;
	- (NSString *)getName;
	- (void)setName:(NSString *)newName;
 
	@end

	// MOEnemyShip.m
	#import "MOEnemyShip.h"

	@interface MOEnemyShip () {
		NSString *name;
		double amtDamage;
	}
	@end

	@implementation MOEnemyShip

	- (void)setName:(NSString *)newName {
		name = newName;
	}
	- (NSString *)getName {
			return name;
	}
	- (void)setDamage:(double)dmg {
		amtDamage = dmg;
	}
	- (double)getDamage {
		return amtDamage;
	}
	- (void)followHeroShip {
		NSLog(@"%@ is following the hero", name);
	}
	- (void)enemyShipShoots {
		NSLog(@"%@ attacks and does %f", name, amtDamage);
	}
	- (void)displayEnemyShip {
		NSLog(@"%@ is on the screen", name);
	}
	@end

<br/>상속해줄 EnemyShip을 만들었으니 상속받을 UFOEnemyShip과 RocketEnemyShip을 생성합니다.

	// MOEnemyShip.h
	#import "MOEnemyShip.h"
	@interface MOUFOEnemyShip : MOEnemyShip
	@end

	// MOEnemyShip.m
	#import "MOUFOEnemyShip.h"

	@implementation MOUFOEnemyShip

	-(id)init {
		self = [super init];
		if (self) {
			[self setName:@"UFO Enemy Ship"];
			[self setDamage:20.0f];
		}
		return self;
	}
	@end

	// MOEnemyShip.h
	#import "MOEnemyShip.h"
	@interface MORocketEnemyShip : MOEnemyShip
	@end

	// MOEnemyShip.m
	#import "MORocketEnemyShip.h"

	@implementation MORocketEnemyShip

	- (id)init {
		self = [super init];
		if (self) {
			[self setName:@"Rocket Enemy Ship"];
			[self setDamage:10.0f];
		}
		return self;
	}
	@end

<br/>이제 실행할 위의 객체를 실행하여 호출할 코드를 작성합니다.

	MOEnemyShip *ship;
	if([shipName isEqualToString:@"UFO"]) {
		ship = [[MOUFOEnemyShip alloc]init];
	} else {
		ship = [[MORocketEnemyShip alloc]init];
	}
	[ship displayEnemyShip];
	[ship followHeroShip];
	[ship enemyShipShoots];

만약 EnemyShip을 상속받는 클래스들이 많다면 코드에서 판단하여 객체를 넣기에는 너무나도 많은 조건문이 들어가게 되고 코드의 가독성은 떨어지게 됩니다.

### 팩토리 패턴을 사용하는 경우

팩토리 클래스를 생성하여 호출하는 부분의 조건문들을 가져와 조건을 판단하여 객체를 반환합니다.
	
	// MOEnemyShipFactory.h
	#import <Foundation/Foundation.h>
	#import "MOEnemyShip.h"
 
	@interface MOEnemyShipFactory : NSObject
	+ (MOEnemyShip *)makeEnemyShip:(NSString *)newShipType;
	@end

	// MOEnemyShipFactory.m
	#import "MOEnemyShipFactory.h"
	#import "MORocketEnemyShip.h"
	#import "MOUFOEnemyShip.h"

	@implementation MOEnemyShipFactory

	+ (MOEnemyShip *)makeEnemyShip:(NSString *)newShipType {
		if ([newShipType isEqualToString:@"UFO"]) {
			return [[MOUFOEnemyShip alloc]init];
		} else if ([newShipType isEqualToString:@"Rocket"]) {
			return [[MORocketEnemyShip alloc]init];
		} else {
			return nil;
		}
	}
	@end

<br/>이제 팩토리 클래스에서 UFOEnemyShip 또는 RocketEnemyShip 객체를 가져올 수 있습니다.

위의 메소드를 사용할 코드를 작성합니다.

	MOEnemyShip *ship;
	ship = [MOEnemyShipFactory makeEnemyShip:@"Rocket"];
	[ship displayEnemyShip];
	[ship followHeroShip];
	[ship enemyShipShoots];

조건문으로 객체를 생성하던 부분이 클래스로 빠져나가서 객체생성을 캡슐화하고 유연성을 증가시킵니다.


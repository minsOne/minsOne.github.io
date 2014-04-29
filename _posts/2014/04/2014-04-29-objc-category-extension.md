---
layout: post
title: "[Objc]메소드 정의 방법 - Category, Extension"
description: ""
category: "programming"
tags: [objectivec, objc, programming, category, extension, private, public, interface, implementation, class, instance, 카테고리, 익스텐션]
---
{% include JB/setup %}

## 카테고리

카테고리는 클래스 선언 부분 중 특정 부분에 따로 이름을 붙이는 방법입니다. 자바에서 클래스를 하나의 묶음으로 선언해야 사용할 수 있지만 오브젝티브C에서는 클래스를 여러 개의 외부 메소드로 나누어 선언할 수 있습니다. 이렇게 나누어진 클래스들을 `카테고리`라고 부릅니다.

카테고리는 @interface와 @implementation 명령을 사용해 클래스와 동일한 방법으로 선언하지만 이름을 표현할 때 클래스 이름 다음에 소괄호로 둘러싼 카테고리 이름을 연결합니다.
	
	// NSUserDefaults+Secure.h
	@interface NSUserDefaults (Secure)

	-(void)setSecure:(NSString *)secure;
	-(BOOL)isSecure;

	@end

카테고리는 클래스에 인스턴스 변수를 추가할 수 없으며 메소드만 추가할 수 있습니다. 대신 `클래스 메소드`와 `인스턴스 메소드`를 모두 선언할 수 있습니다.

나중에 프로그램이 복잡해지면 하나의 클래스에서 많은 메소드를 관리하는 것보다 카테고리로 나누어 관리할 수 있습니다. 즉, 메소드를 기능별로 각자의 모듈로 구분할 수 있으며 따로 클래스를 만들거나 복잡한 구조를 차용할 필요가 없어집니다. 클래스의 갯수가 줄어들면 의존성도 줄어들어 어플리케이션 전체의 구조가 간결하게 정리됩니다.

또 다르게 사용하는 방법은 클래스의 인터페이스 중 일부를 내부적으로만 사용하고자 할 때 숨기는 작업입니다. 헤더에서는 카테고리로 메소드를 나누었기 때문에 카테고리로 나누어진 메소드들은 자연스럽게 숨겨지게 됩니다. 

주의해야 할 부분은 같은 메소드를 선언하는 경우 카테고리의 메소드가 기존 클래스의 메소드를 덮어 씌워 호출하게 되면 카테고리의 메소드가 호출이 됩니다.

<br/>
## 익스텐션

오브젝티브C 2.0부터 익스텐션 개념이 추가되었습니다. 오브젝티브C의 익스텐션은 `익명 카테고리`(anonymous category)라고 할 수 있습니다.

익스텐션을 사용하면 클래스의 @interface 부분을 나누어 사용할 수 있지만 @implementation 부분은 분리할 수 없습니다. 일부 메소드의 프로토타입을 인터페이스로 공개하지 않게 구성할 때 유용합니다.

익스텐션은 @interface에 카테고리 이름을 지정하지 않으며 원래 클래스의 @implementation 부분에 구현해야 합니다.


	// Ship.h
	#import <Foundation/Foundation.h>
	#import "Person.h"
	 
	@interface Ship : NSObject
	 
	@property (strong, readonly) Person *captain;
	 
	-(id)initWithCaptain:(Person *)captain;
	 
	@end

	// Ship.m
	#import "Ship.h"
	 
	// The class extension.
	@interface Ship()
	 
	@property (strong, readwrite) Person *captain;
	 
	@end
	 
	 
	// The standard implementation.
	@implementation Ship
	 
	@synthesize captain = _captain;
	 
	-(id)initWithCaptain:(Person *)captain {
	    self = [super init];
	    if (self) {
	        // This WILL work because of the extension.
	        [self setCaptain:captain];
	    }
	    return self;
	}
	 
	@end


클래스 내부에서는 자유롭게 값을 변경할 수 있지만 외부에서는 공개되지 않기 때문에 사용할 수 없습니다.

<br/><br/>※ 자바개발자를 위한 오브젝티브C 책을 참고하였습니다.
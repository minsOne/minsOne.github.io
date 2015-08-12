---
layout: post
title: "[Objective-C]메소드 선언 - Protocol"
description: ""
category: "Mac/iOS"
tags: [objc, programming, protocol, delegate]
---
{% include JB/setup %}

## 프로토콜

프로토콜은 @protocol 명령으로 선언하며 @protocol 명령 안에는 해당 프로토콜에 필요한 메소드를 나열합니다. 자바의 인터페이스처럼 프로토콜에는 인스턴스 변수가 들어가지 않으며 메소드만 포함됩니다.

	@interface Attacks : Game<Living>
 
 	@end
 
 	@protocol Living
 	@required
 	- (float)age;
 	- (float)health;
 	@optional
 	- (NSDictionary \*)healthInfo;

 	@end
 
위에서 Living이라는 프로토콜을 구현하기 위해 선언하였고 Attacks 클래스는 Living 프로토콜을 사용하기 위해서 프로토콜 이름을 중괄호 안에 적어 부모 클래스 바로 뒤에 표시합니다. 

프로토콜에 required라고 정의된 모든 메소드를 구현해야 하며 구현하지 않은 메소드가 있다면 컴파일러가 오류를 알려줍니다. optional이라고 정의된 부분은 메소드가 구현되어도 되고 구현 되지 않아도 됩니다.

Attacks 클래스를 상속받는 클래스인 경우 다시 Living 프로토콜을 선언할 필요가 없습니다. 클래스처럼 상속이 가능하며 추가된 메소드들도 상속됩니다.

<br/>

## 비공식 프로토콜(informal protocol)

비공식 프로토콜은 특정 객체가 구현했을 것이라고 개발자가 예상하는 메소드들의 집합이며, 공식적으로 선언된 메소드는 아닙니다.

비공식 프로토콜은 두가지 장점이 있는데 첫번째로 대입 연산이 이뤄질 때 오브젝티브C가 객체의 자료형을 따로 확인하지 않는 다는 점, 즉 객체의 메소드를 호출하기전까지 해당 클래스가 특정 프로토콜을 따른다거나 특정 메소드를 구현했는지의 여부를 오브젝티브C가 확인하지 않습니다. 따라서 변수에 할당할 객체가 필요한 메소드를 구현한다고 가정하고 넘어갈 수 있으므로 실제 기능이 동작하는지 여부를 보장할 수 없습니다. 두번째로 필요한 메소드를 구현하고 있는지를 쉽게 확인할 수 있어 특정 기능이 필요할 때 해당 기능이 있는지 확인하고 동작 요청을 할 수 있습니다.

코코아 프레임워크에서는 위임 객체(delegate) 객체를 통해서 처리할 수 있습니다. 우선 화면에 창을 닫으려고 하는 요청을 받으려는 객체는 delegate로 등록합니다. 그리고 창을 닫기전에 delegate가 windowShouldClose 메소드로 구현하고 있는지 확인하고 delegate의 windowShouldClose 메소드를 호출하여 메소드 실행 결과를 받습니다.

	if([delegate respondsToSelector:@selector(windowShouldClose:)]) // delegate 메소드 구현 여부 확인 
	{
		shouldClose = [delegate windowShouldClose:self];	// delegate 객체에 메소드 전달
	}


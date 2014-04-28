---
layout: post
title: "[Objc]description - 객체 설명 메소드"
description: ""
category: "programming"
tags: [objectivec, objc, description]
---
{% include JB/setup %}

Java에서 toString이 있다면 ObjectiveC에서는 description이 있습니다.

기본 타입이 아닌 우리가 임의로 생성한 타입의 객체를 생성하고 그 객체를 출력하려고 하면 description 메소드를 작성을 해줍니다.

	-(NSString *)description {
		NSString *str = ...
		return str;
	}

호출할 객체에 메소드로 선언을 해주면 NSLog로 객체를 출력하면 description에 정의된 문자열이 반환되어 출력됩니다.	
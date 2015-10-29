---
layout: post
title: "[Objective-C]Generics를 사용하세요."
description: ""
category: "programming"
tags: [objc, generics, swift, nsarray, nsdictionary]
---
{% include JB/setup %}

Objective-C에서도 generics을 사용할 수 있다는 것을 아시나요? 이전에 Objective-C를 사용하면서 불만스러웠던 것 중 하나가 `NSArray`나 `NSDictionary`, `NSSet` 등에서 값을 넣을 때, `id` 타입으로 들어간다는 점이었습니다. 즉, 어떤 타입의 객체라도 넣을 수 있었다는 말이죠. 역으로 말하면, 꺼내서 사용하기 전까지는 어떤 타입의 값인지를 알 수 없고, 확인하기 위해 타입 비교하거나, 이전 코드를 찾아 분석해야 합니다.

이 같은 사실을 Swift를 만나기 전까지는 머리 한구석에 밀어 넣고 있었습니다. Swift는 generics을 지원하기 때문에, 타입을 명확하게 합니다. 그리고 이제는 Objective-C도 generics을 지원합니다. 단지 경량화된 버전으로 말이죠. 

하지만 NSArray, NSDictionary 등에서 generics을 사용하면 코드는 조금 길어지긴 하지만 무슨 타입인지 명확하게 합니다. 따라서 다른 타입을 가진 객체를 넣어 값비싼 비용을 지불하는 것 보다 generics를 사용하는 것이 좋습니다.

<li>generics을 사용하지 않은 예제</li>

	NSMutableArray *array = [@[] mutableCopy];
	[array addObject:@"first"];
	[array addObject:@1];

<li>generics 사용한 예제</li>

	NSMutableArray<NSNumber *> *array = [@[] mutableCopy];
	[array addObject:@1];
	[array addObject:@2];

앞의 예제와 뒤의 예제의 차이는 generics 사용입니다. 앞의 예제는 어떤 타입이든지 넣을 수 있지만, 뒤의 예제는 NSNumber 타입만 넣도록 하고 있습니다. 

뒤의 예제는 코드는 조금 길어지긴 하였지만, 안정성을 보장합니다. 하지만 다른 타입의 객체를 넣을 수 있으나, 컴파일러가 경고를 띄워줍니다. 그리고 컴파일러 설정에서 경고에 대해 엄격하게 하여 확실하게 안정성을 보장할 수 있습니다.

만약 generics을 쓰지 않고 있으시다면, 이번 기회에 generics을 적용한 코드로 바꿔보는 것은 어떨까요? 좀 더 나은 코드를 위해서 말이죠.
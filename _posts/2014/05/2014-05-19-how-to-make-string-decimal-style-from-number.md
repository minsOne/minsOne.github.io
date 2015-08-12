---
layout: post
title: "[Objective-C]숫자에서 3자리마다 ,를 추가시키기 - NSNumberFormatter"
description: ""
category: "Mac/iOS"
tags: [objc, decimal, dot, string, style, number]
---
{% include JB/setup %}

`NSNumberFormatter`에는 여러가지 NumberStyle이 있는데 그 중 `NSNumberFormatterDecimalStyle`이 있습니다.

`NSNumberFormatterDecimalStyle`는 10진수로 나타내는 방식이며 3자리 수마다 ,를 찍습니다.

	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

	NSNumber *num = @1234567890.1234;
	NSLog(@"Result : %@", [numberFormatter stringFromNumber:num]);

	//Result : Result : 1,234,567,890.1234

<br />

그러면 다른 스타일을 확인해보겠습니다.

`NSNumberFormatterNoStyle`는 소수점 이하를 버립니다.

	NSNumber *num = @1234567890.1234;
	[numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
    NSLog(@"Result : %@", [numberFormatter stringFromNumber:num]);
    //Result : 1234567890

<br />

`NSNumberFormatterPercentStyle`는 소수점 3자리 이하를 버리고 소수점이 없어지며 끝에 %가 붙습니다. 그리고 3자리 수마다 ,를 찍습니다.

	NSNumber *num = @1234567890.1234;
	[numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    NSLog(@"Result : %@", [numberFormatter stringFromNumber:num]);
    //Result : 123,456,789,012%

<br />

`NSNumberFormatterCurrencyStyle`는 소수점 이하를 버리고 통화량 기호가 앞에 붙습니다. 그리고 3자리 수마다 ,를 찍습니다.

	NSNumber *num = @1234567890.1234;
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSLog(@"Result : %@", [numberFormatter stringFromNumber:num]);
    //Result : ₩1,234,567,890

<br />

`NSNumberFormatterScientificStyle`는 좀 더 정확한 수로 표현합니다.

	NSNumber *num = @1234567890.1234;
    [numberFormatter setNumberStyle:NSNumberFormatterScientificStyle];
    NSLog(@"Result : %@", [numberFormatter stringFromNumber:num]);
    //Result : 1.23456789012345E9

<br />

`NSNumberFormatterSpellOutStyle`는 언어에 맞는 문자로 표현합니다.

	NSNumber *num = @1234567890.1234;
	[numberFormatter setNumberStyle:NSNumberFormatterSpellOutStyle];
    NSLog(@"Result : %@", [numberFormatter stringFromNumber:num]);
    //Result : 십이억 삼천사백오십육만 칠천팔백구십점일이삼사오

<br />

만일 인스턴스 메소드로 호출하지 않고 클래스 메소드로 호출하고자 하는 경우 `[NSNumberFormatter localizedStringFromNumber:]`를 이용하면 위에서 얻는 결과를 동일하게 얻을 수 있습니다.

    NSString *str = [NSNumberFormatter localizedStringFromNumber:@1111111.1111 numberStyle:NSNumberFormatterDecimalStyle];
    NSLog(@"Result : %@", str);
    //Result : 1,111,111.111

<br />

[Apple 문서](https://developer.apple.com/library/mac/documentation/cocoa/reference/foundation/classes/NSNumberFormatter_Class/Reference/Reference.html#//apple_ref/occ/cl/NSNumberFormatter)에서 좀 더 많은 정보를 볼 수 있습니다.

---
layout: post
title: "[Swift]NSDate ↔ String"
description: ""
category: "mac/ios"
tags: [swift, objc, NSJSONSerialization, NSDictionary, NSDate, String, NSNumber, NSArray, NSNull]
---
{% include JB/setup %}

NSDictionary를 JSON 형태의 String으로 변경하여 값을 저장하려다 에러가 발생하여 살펴보니 NSJSONSerialization에서 NSDate는 사용할 수 없었습니다. 

그래서 하는 수 없이 NSDictionary의 데이터를 모두 까서 NSDate형태를 String으로 변경하였습니다.

나중에 NSDate를 String으로, String을 NSDate로 변환하는 상황이 가끔 발생하므로 참고하기 위해 기록합니다.

	let formatter = NSDateFormatter()
	formatter.dateFormat = "yyyy-MM-dd 'T' HH:mm:ss.SSS"

	let now = NSDate()												// "Aug 5, 2015, 1:21 AM"
	let str = formatter.stringFromDate(now)		// "2015-08-05 T 01:21:03.109"
	let date = formatter.dateFromString(str)	// "Aug 5, 2015, 1:21 AM"

다음은 JSON으로 변환할 때, 다음 속성에 대해서만 유효합니다.

* 최상위 레벨의 객체는 NSArray, NSDictionary이다.
* NSString, NSNumber, NSArray, NSDictionary 또는 NSNull 인스턴스를 가진다.
* 모든 딕셔너리 키는 NSString 인스턴스이다.
* 숫자는 NaN 또는 무한이 아니다.

### 참고 자료

* [Apple Document - NSJSONSerialization](https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSJSONSerialization_Class/index.html)

<br/>ps. 문서 좀 보고 코딩 할껄,, 괜히 삽질만 ㅠㅠ
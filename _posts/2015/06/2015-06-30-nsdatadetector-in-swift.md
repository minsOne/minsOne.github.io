---
layout: post
title: "[Swift]NSDataDetector"
description: ""
category: "Mac/iOS"
tags: [NSDataDetector, swift, NSRange, NSTextCheckingType, block, closure, url, date, timezone, duration, link, PhoneNumber, Address]
---
{% include JB/setup %}

### NSDataDetector

NSDataDetector 클래스는 NSRegularExpression의 서브클래스로 매칭하는 데이터를 찾도록 설계되었습니다.

몇 가지 형태의 데이터들을 탐지하여 해당 형태로 반환해주는데, NSTextCheckingTypeDate는 date, timeZone, duration를 가지고, NSTextCheckingTypeLink는 URL 등을 가집니다.

더 많은 타입을 보시려면 [다음][NSTextCheckingType]에서 확인할 수 있습니다.

NSDataDetector는 두 가지 방법으로 작성할 수 있는데, 모든 매치된 결과를 받아서 일치하는 것을 찾는 방법과, 클로저를 이용하여 매칭 결과를 하나씩 얻는 방법이 있습니다.

모든 매치된 결과를 받아서 사용하는 방법입니다.

	let now = "2015-06-29 10:41:20"

	var err: NSError?
	var detector = NSDataDetector(types: NSTextCheckingType.Date.rawValue, error: &err)
	if let detector = detector {
		let matchs = detector.matchesInString(now, options: nil, range: NSMakeRange(0, (now as NSString).length))
		for match in matchs {
			let matchRange = match.range
			if match.resultType == NSTextCheckingType.Date {
				let date = match.date
				println(date)
			}
		}
	}

	// Print : Optional(2015-06-29 01:41:20 +0000)

위에서는 매칭되는 결과를 `for in`문을 통해서 반복해서 찾도록 합니다.

<br/>다음은 클로저 이용하여 매칭된 결과를 찾는 방법입니다.

	let now = "2015-06-29 10:41:20"

	var detectedDate: NSDate?
	var detector = NSDataDetector(types: NSTextCheckingType.Date.rawValue, error: &err)
	if let detector = detector {
		detector.enumerateMatchesInString(
			now,
			options: nil,
			range: NSMakeRange(0, (now as NSString).length),
			usingBlock: {
				(result: NSTextCheckingResult!,
				flags: NSMatchingFlags,
				stop: UnsafeMutablePointer<ObjCBool>) -> Void in
			detectedDate = result.date
			println(result.date)
		})
	}

	// Print : Optional(2015-06-29 01:41:20 +0000)

클로저를 통해서 하나씩 결과를 얻으나, 몇 개가 일치하는지는 알 수 없습니다. 따라서 활용에 따라 두 가지 방법을 사용하는 것이 적절합니다.

### 정리

별도의 정규식을 사용하지 않고 데이터를 얻을 수 있다는 점에서 좋습니다. 하지만 기존에 정형화된 패턴으로 매칭하므로 정확한 데이터가 들어올 수 있음을 확신할 수 없습니다. 

이는, 개발자가 정규식을 작성한 것이 아니므로 정확한 패턴 매칭을 한다는 보장할 수 없기 때문입니다.

따라서 NSDataDetector 클래스를 사용하기 전에 데이터의 형태를 확인하고 사용해야 합니다.

### 참고자료

* [Apple Document][Apple_Document_NSDataDetector_Class]

[NSTextCheckingType]: https://developer.apple.com/library/mac/documentation/AppKit/Reference/NSTextCheckingResult_Class/index.html#//apple_ref/c/tdef/NSTextCheckingType
[Apple_Document_NSDataDetector_Class]: https://developer.apple.com/library/mac/documentation/Foundation/Reference/NSDataDetector_Class/
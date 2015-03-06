---
layout: post
title: "NSUserDefaults 값 초기화하기 in Swift"
description: ""
category: "Mac/iOS"
tags: [ios, NSUserDefaults, swift]
---
{% include JB/setup %}

### NSUserDefaults 값 모두 초기화 하기

간혹 테스트 및 초기 값 상태에서 작업할 시 NSUserdefault 값을 다 날려야할 경우가 있는데 이를 수행하는 Code Snippet 입니다.

	for key in NSUserDefaults.standardUserDefaults().dictionaryRepresentation().keys {
		NSUserDefaults.standardUserDefaults().removeObjectForKey(key.description)
	}

다음 코드로 위의 코드를 수행하기 전 후의 Key 개수를 알 수 있습니다.

	println(NSUserDefaults.standardUserDefaults().dictionaryRepresentation().keys.array.count)


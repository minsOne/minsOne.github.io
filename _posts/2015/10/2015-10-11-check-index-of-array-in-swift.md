---
layout: post
title: "[Swift]안전하게 배열 조회하기"
description: ""
category: "programming"
tags: [swift, array, subscript, safe, index, CollectionType, indices, startIndex, endIndex]
---
{% include JB/setup %}

### 안전하게 배열 조회하기

배열에서 특정 위치의 값을 얻기 위해서는 배열의 크기를 체크해야하는 조건이 필요합니다.

	if index < array.count {
		// 작업 수행
	}

범위를 확인하지 않고 값을 조회하면, 다음과 같은 에러가 발생할 가능성이 있습니다.

	fatal error: Array index out of range

<br/><br/>
다음과 같은 방법을 사용하여 안전하게 배열을 조회해봅시다.

CollectionType은 indices라는 값을 가지는데, 이 값은 유효한 값의 범위를 가집니다. 이를 사용하여 다음과 같이 확장하여 안전하게 배열에서 값을 얻을 수 있습니다.

	extension Array {
	    subscript (safe index: Int) -> Element? {
	    	// iOS 9 or later
	        return indices ~= index ? self[index] : nil	
	        // iOS 8 or earlier
	        // return startIndex <= index && index < endIndex ? self[index] : nil
	        // return 0 <= index && index < self.count ? self[index] : nil
	    }
	}

	let list = [1, 2, 3]
	list[safe: 4] // nil
	list[safe: 2] // 3

indices는 iOS9부터 사용이 가능하므로, iOS8 하위호환을 가지기 위해 startIndex, endIndex 등의 방법을 사용하여 안전하게 배열을 조회할 수 있습니다.

### 참고 자료

* [stackoverflow](http://stackoverflow.com/a/30593673/2749449)
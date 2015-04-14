---
layout: post
title: "BubbleSort in swift"
description: ""
category: "programming"
tags: [swift, bubblesort, algorithm, sort]
---
{% include JB/setup %}

### Bubble Sort

두 인접한 원소를 검사하여 정렬하는 방법으로 시간 복잡도는 O(n^2)입니다.

	func bubbleSort<T: Comparable where T == T>(var arr: [T]) -> [T]{
		for (i, iValue) in enumerate(arr) {
			for (j, jValue) in enumerate(arr[0..<arr.count-1]) {
				if arr[j] > arr[j+1] { 
					swap(&arr[j], &arr[j+1]) 
				}
			}
		}
		return arr
	}

<br/>

### 참고 자료

* [거품정렬](http://ko.wikipedia.org/wiki/거품_정렬)
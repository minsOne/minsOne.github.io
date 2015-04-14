---
layout: post
title: "Quick Sort in swift"
description: ""
category: "programming"
tags: [swift, quicksort, algorithm, lamda, function, sort]
---
{% include JB/setup %}

### Quick Sort

QuickSort는 분할 정복(Divide and Conquer) 방법을 통해 리스트를 정렬합니다. 따라서 분할하는 부분에 대해서 고차함수인 filter를 이용하여 처리할 수 있습니다.

	func quickSort(var array: [Int]) -> [Int] {
	  if array.isEmpty { return [] }
	  let pivot = array.removeAtIndex(0)
	  return quickSort(array.filter{$0 <= pivot}) + [pivot] + quickSort(array.filter{$0 > pivot})
	}

또한, 제네릭을 이용하여 Comparable 타입을 사용하는 모든 리스트를 정렬할 수 있습니다.

	func quickSort<T: Comparable>(var array: [T]) -> [T] {
	  if array.isEmpty { return [] }
	  let pivot = array.removeAtIndex(0)
	  return quickSort(array.filter{$0 <= pivot}) + [pivot] + quickSort(array.filter{$0 > pivot})
	}
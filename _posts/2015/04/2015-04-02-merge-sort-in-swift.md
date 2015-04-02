---
layout: post
title: "MergeSort in swift"
description: ""
category: "programming"
tags: [swift, mergesort, algorithm]
---
{% include JB/setup %}

### MergeSort

MergeSort의 로직은 다음과 같습니다.

1. 정렬되지 않은 리스트를 n개의 서브리스트를 만들고 리스트의 개수가 1이라면 정렬된 것으로 처리합니다.
2. 1개의 서브리스트로 될때까지 정렬하면서 합칩니다.

다음은 정렬되지 않은 리스트를 n개의 서브리스트로 만듭니다.

	func mergeSort(var list: [Int]) {
		if list.count <= 1 {
			return list
		}

		var lList: [Int] = []
		var rList: [Int] = []

		let mid = list.count / 2
		lList += list[0..<mid]
		rList += list[mid..<list.count]

		var left = mergeSort(lList)
		var right = mergeSort(rList)

		return merge(left, right)
	}

서브리스트들을 가지고 합치는 역할을 합니다.
우선 리스트 두개를 가지고 앞에서 하나씩 비교하면서 리스트에 하나씩 빼서 새로운 리스트에다 넣습니다. 그리고 남은 리스트는 새로운 리스트 뒤에 추가합니다.

	func merge(var left: [Int], var right: [Int]) -> [Int] {
	  var result: [Int] = []
	  while !left.isEmpty && !right.isEmpty {
	    let value = left[0] < right[0] ? left.removeAtIndex(0) : right.removeAtIndex(0)
	    result += [value]
	  }
	  if !left.isEmpty {
	    result += left
	  }
	  if !right.isEmpty {
	    result += right
	  }
	  return result
	}

또한, 제네릭을 이용하여 Comparable 타입을 사용하는 리스트를 정렬할 수 있습니다.

	func merge<T: Comparable where T == T>(var left: [T], var right: [T]) -> [T]
	func mergeSort<T: Comparable where T == T>(var list: [T])


### 참고 자료

* [MergeSort](http://en.wikipedia.org/wiki/Merge_sort)
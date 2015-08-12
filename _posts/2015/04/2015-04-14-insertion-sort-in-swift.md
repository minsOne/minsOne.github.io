---
layout: post
title: "[Swift]Insertion Sort"
description: ""
category: "programming"
tags: [swift, insertionsort, algorithm, sort]
---
{% include JB/setup %}

### Insertion Sort

삽입 정렬은 이전에 정렬된 배열과 비교하여 자신의 위치를 찾아 삽입합니다. 시간복잡도는 O(n<sup>2</sup>)입니다.

의사 코드는 다음과 같습니다.

	function insertionSort(array A)
		 for i from 1 to length[A]-1 do
				 value := A[i] 
				 j := i-1
				 while j >= 0 and A[j] > value do
						 A[j+1] := A[j]
						 j := j-1
				 done
				 A[j+1] = value
		 done

다음은 Swift로 작성된 삽입 정렬입니다.

	func insertionSort<T: Comparable>(var list: Array<T>) -> Array<T> {
		for i in 1..<list.count {
			var j = i
			while(j > 0 && list[j] < list[j-1] ) {
				swap(&list[j], &list[j-1])
				j--
			}
		}
		return list
	}

### 참고자료

* [Insertion Sort](http://en.wikipedia.org/wiki/Insertion_sort)
---
layout: post
title: "[Swift][일일 코드 #6]오일러 프로젝트 005"
description: ""
category: "programming"
tags: [swift, closure, filter]
---
{% include JB/setup %}

### Problem 005

1 ~ 10 사이의 어떤 수로도 나누어 떨어지는 가장 작은 수는 2520입니다.

그러면 1 ~ 20 사이의 어떤 수로도 나누어 떨어지는 가장 작은 수는 얼마입니까?

### Solution

증가하는 값이 클로저 안에 있는 코드

	func factor(list: [Int]) -> (Void -> Int?) {
		var num = 0
		return {
			num++
			return list.filter{ num % $0 != 0 }.isEmpty ? num : 0
		}
	}

	//let isFilter = factor([Int](1...10))
	let isFilter = factor([2,3,5,7,11,13,17,19])

	while true {
		if let num = isFilter() where num != 0 {
			println(num)
			break;
		}
	}

<br/>

증가하는 값이 반복문에 있는 코드

	func factor(list: [Int]) -> (Int -> Bool) {
		return { s1 in
			return list.filter{ s1 % $0 != 0 }.isEmpty
		}
	}

	//let isFilter = factor([Int](1...10))
	let isFilter = factor([2,3,5,7,11,13,17,19])

	var num = 0
	while true {
		if isFilter(++num) {
			println(num)
			break;
		}
	}

### 문제 출처

* [사이냅 소프트의 오일러 프로젝트](http://euler.synap.co.kr/prob_detail.php?id=5)
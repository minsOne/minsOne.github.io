---
layout: post
title: "[Swift][일일 코드 #4]오일러 프로젝트 003"
description: ""
category: "programming"
tags: [swift, closure]
---
{% include JB/setup %}

### Problem 2

어떤 수를 소수의 곱으로만 나타내는 것을 소인수분해라 하고, 이 소수들을 그 수의 소인수라고 합니다.

예를 들면 13195의 소인수는 5, 7, 13, 29 입니다.

600851475143의 소인수 중에서 가장 큰 수를 구하세요.

### Solution

	func factor(n: Int) -> [Int] {
		if n <= 1 { return [] }

		var prime: Int?, index = 2
		for(; index < n; index++) {
			if n % index == 0 {
				prime = index
				break;
			}
		}

		if let prime = prime {
			return [prime] + factor(n/index)
		}
		else {
			return [index] + factor(n/index)
		}
	}

	let result = factor(600851475143)
	println(result.last)

### 문제 출처

* [사이냅 소프트의 오일러 프로젝트](http://euler.synap.co.kr/prob_detail.php?id=3)
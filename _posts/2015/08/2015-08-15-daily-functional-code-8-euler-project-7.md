---
layout: post
title: "[Swift][일일 코드 #8]오일러 프로젝트 007"
description: ""
category: "programming"
tags: [swift]
---
{% include JB/setup %}

### Problem 007

소수를 크기 순으로 나열하면 2, 3, 5, 7, 11, 13, ... 과 같이 됩니다.

이 때 10,001번째의 소수를 구하세요.

### Solution

	func isPrime(num: Int) -> Bool {
		var index = 2
		var prime: Int?
		for(; index < num; index++) {
			if num % index == 0 {
				prime = index
				break
			}
		}

		if let prime = prime {
			return false
		}
		return true
	}

	var num = 2
	var list = [Int]()
	while true {
		if isPrime(num) {
			list += [num]
			if list.count == 10001 {
				break
			}
		}
		num++
	}

	println(list.last)

<br/>

### 문제 출처

* [사이냅 소프트의 오일러 프로젝트](http://euler.synap.co.kr/prob_detail.php?id=7)
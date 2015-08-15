---
layout: post
title: "[Swift][일일 코드 #11]오일러 프로젝트 010"
description: ""
category: "programming"
tags: [swift]
---
{% include JB/setup %}

### Problem 010

10 이하의 소수를 모두 더하면 2 + 3 + 5 + 7 = 17 이 됩니다.

이백만(2,000,000) 이하 소수의 합은 얼마입니까?

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
	var sum = 0
	while true {
		if isPrime(num) {
			sum += num
			if sum > 2000000 {
				break;
			}
		}
		num++
	}

	println(sum)

<br/>

### 문제 출처

* [사이냅 소프트의 오일러 프로젝트](http://euler.synap.co.kr/prob_detail.php?id=10)
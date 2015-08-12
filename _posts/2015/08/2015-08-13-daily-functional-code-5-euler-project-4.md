---
layout: post
title: "[Swift][일일 코드 #5]오일러 프로젝트 004"
description: ""
category: "programming"
tags: [swift, map, filter, closure]
---
{% include JB/setup %}

### Problem 4

앞에서부터 읽을 때나 뒤에서부터 읽을 때나 모양이 같은 수를 대칭수(palindrome)라고 부릅니다.

두 자리 수를 곱해 만들 수 있는 대칭수 중 가장 큰 수는 9009 (= 91 × 99) 입니다.

세 자리 수를 곱해 만들 수 있는 가장 큰 대칭수는 얼마입니까?

### Solution

	let palindromeList = [Int](100..<1000)

	let palindrome = palindromeList.map { (pLeft) -> (Int) in
		let palindromes = palindromeList.filter{ (pRight) in
			let result = pLeft * pRight
			var str = String(result)
			if str == String(reverse(str)) {
				return true
			}
			return false
		}

		if !palindromes.isEmpty {
			return (pLeft * maxElement(palindromes))
		}
		return 0
	}

	println(maxElement(palindrome)) // 906609

<br/>

### 문제 출처

* [사이냅 소프트의 오일러 프로젝트](http://euler.synap.co.kr/prob_detail.php?id=4)
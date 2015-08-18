---
layout: post
title: "[Swift][일일 코드 #17]오일러 프로젝트 016"
description: ""
category: "programming"
tags: [swift, reduce]
---
{% include JB/setup %}

### Problem 016

2^15 = 32768 의 각 자리수를 더하면 3 + 2 + 7 + 6 + 8 = 26 입니다.

2^1000의 각 자리수를 모두 더하면 얼마입니까?

### Solution

	let result = reduce(Array(String(format:"%.0f", pow(Double(2), 1000))), 0){ String($1).toInt()! + $0 }
	println(result)	// 1366

### 문제 출처

* [사이냅 소프트의 오일러 프로젝트](http://euler.synap.co.kr/prob_detail.php?id=16)
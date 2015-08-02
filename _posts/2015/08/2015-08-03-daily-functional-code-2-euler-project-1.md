---
layout: post
title: "일일 함수형 코드 #2 - 오일러 프로젝트 001"
description: ""
category: "programming"
tags: [swift, filter, reduce]
---
{% include JB/setup %}

### Problem 1

10보다 작은 자연수 중에서 3 또는 5의 배수는 3, 5, 6, 9 이고, 이것을 모두 더하면 23입니다.

1000보다 작은 자연수 중에서 3 또는 5의 배수를 모두 더하면 얼마일까요?

### Solution

	[Int](1...100).filter{ ($0 % 3 == 0) || ($0 % 5 == 0) }.reduce(0){ $0 + $1 }

	or

	[Int](1...100).filter{ ($0 % 3 == 0) || ($0 % 5 == 0) }.reduce(0, combine:+)

<br/>

### 문제 출처

* [사이냅 소프트의 오일러 프로젝트](http://euler.synap.co.kr/prob_detail.php?id=1)
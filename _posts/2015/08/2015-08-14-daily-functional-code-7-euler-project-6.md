---
layout: post
title: "[Swift][일일 코드 #7]오일러 프로젝트 006"
description: ""
category: "programming"
tags: [swift, closure, reduce]
---
{% include JB/setup %}

### Problem 006

1부터 10까지 자연수를 각각 제곱해 더하면 다음과 같습니다 (제곱의 합).

1^2 + 2^2 + ... + 10^2 = 385
1부터 10을 먼저 더한 다음에 그 결과를 제곱하면 다음과 같습니다 (합의 제곱).

(1 + 2 + ... + 10)^2 = 55^2 = 3025
따라서 1부터 10까지 자연수에 대해 "합의 제곱"과 "제곱의 합" 의 차이는 3025 - 385 = 2640 이 됩니다.

그러면 1부터 100까지 자연수에 대해 "합의 제곱"과 "제곱의 합"의 차이는 얼마입니까?

### Solution

	let result = Int(pow(Double([Int](1...100).reduce(0) { $0 + $1 }), 2)
		- [Int](1...100).reduce(0) { $0 + pow(Double($1), 2) })

	println(result)

<br/>
### 문제 출처

* [사이냅 소프트의 오일러 프로젝트](http://euler.synap.co.kr/prob_detail.php?id=6)
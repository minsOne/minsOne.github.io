---
layout: post
title: "[Swift][일일 코드 #21]오일러 프로젝트 020"
description: ""
category: "programming"
tags: [swift, reduce, Array]
---
{% include JB/setup %}

### Problem 020

n! 이라는 표기법은 n × (n − 1) × ... × 3 × 2 × 1을 뜻합니다.

예를 들자면 10! = 10 × 9 × ... × 3 × 2 × 1 = 3628800 이 되는데,<br/>
여기서 10!의 각 자리수를 더해 보면 3 + 6 + 2 + 8 + 8 + 0 + 0 = 27 입니다.

100! 의 자리수를 모두 더하면 얼마입니까?

### Solution

Swift는 BigInteger를 지원하지 않기 때문에 [BigInteger](https://github.com/kirsteins/BigInteger) 라이브러리를 사용했다가 가정하고 풀었습니다.

위 코드는 런타임 시 에러가 발생할 수 있습니다.


	let factorial = Array(String(reduce(1...100, 1){ $0 * $1 }))
	let result = factorial.reduce(0) { String($1).toInt()! + $0 }

	println(result)

### 문제 출처

* [사이냅 소프트의 오일러 프로젝트](http://euler.synap.co.kr/prob_detail.php?id=20)
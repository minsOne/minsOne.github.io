---
layout: post
title: "[Swift][일일 코드 #3]오일러 프로젝트 002"
description: ""
category: "programming"
tags: [swift, closure]
---
{% include JB/setup %}

### Problem 002

피보나치 수열의 각 항은 바로 앞의 항 두 개를 더한 것이 됩니다. 1과 2로 시작하는 경우 이 수열은 아래와 같습니다.

1, 2, 3, 5, 8, 13, 21, 34, 55, 89, ...

짝수이면서 4백만 이하인 모든 항을 더하면 얼마가 됩니까?

### Solution

모든 변수는 클로저 내에서 다루며, 합계에 대해서만 밖에서 처리하여 계속 실행 할 것인지를 정합니다.
	
	// 값이 짝수이면 피보나치 수열 값을, 홀수이면 0을 반환한다.
	func fibo() -> ( () -> (UInt64)) {
	    var p1: UInt64 = 0, p2: UInt64 = 1

	    return {
	        (p1, p2) = (p2, p1 + p2)
	        return p2 % 2 == 0 ? p2 : 0
	    }
	}

	let next = fibo()
	var sum: UInt64 = 0
	while sum < 4000000 {
	    sum += next()
	}

	println(sum)

<br/>

### 문제 출처

* [사이냅 소프트의 오일러 프로젝트](http://euler.synap.co.kr/prob_detail.php?id=2)
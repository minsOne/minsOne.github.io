---
layout: post
title: "[Swift][일일 코드 #10]오일러 프로젝트 009"
description: ""
category: "programming"
tags: [swift]
---
{% include JB/setup %}

### Problem 009

세 자연수 a, b, c 가 피타고라스 정리 a^2 + b^2 = c^2 를 만족하면 피타고라스 수라고 부릅니다 (여기서 a < b < c ).

예를 들면 3^2 + 4^2 = 9 + 16 = 25 = 5^2이므로 3, 4, 5는 피타고라스 수입니다.

a + b + c = 1000 인 피타고라스 수 a, b, c는 한 가지 뿐입니다. 이 때, a × b × c 는 얼마입니까?

### Solution

a^2 + b^2 = c^2 과 a + b + c = sum이라는 조건을 가지고 다음 식을 얻었습니다.

a = ((sum * sum)/2 - sum * b) / (sum - b)

위의 식을 가지고 다음 코드를 작성할 수 있습니다.

	let sum = 1000
	for var b = 1; b < sum / 2; b++ {
		var a = Double(((sum * sum)/2 - sum * b)) / Double((sum - b))
		if a % 1 == 0 {
			println("Result = \(Int(a) * b * (sum - Int(a) - b))")	// 31875000
			break;
		}
	}

### 문제 출처

* [사이냅 소프트의 오일러 프로젝트](http://euler.synap.co.kr/prob_detail.php?id=9)
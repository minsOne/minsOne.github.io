---
layout: post
title: "[Swift][일일 코드 #16]오일러 프로젝트 015"
description: ""
category: "programming"
tags: [swift, reduce]
---
{% include JB/setup %}

### Problem 015

아래와 같은 2 × 2 격자의 왼쪽 위 모서리에서 출발하여 오른쪽 아래 모서리까지 도달하는 길은 모두 6가지가 있습니다 (거슬러 가지는 않기로 합니다).

그러면 20 × 20 격자에는 모두 몇 개의 경로가 있습니까?

### Solution

가로 n, 세로 m이므로, 모든 경우의 수는 `(n + m)! / n! / m!` 입니다.

	let width = 20
	let height = 20

	let totalCases = reduce(1...width+height, 1.0){ $0 * Double($1) }
	let widthCases = reduce(1...width, 1.0){ $0 * Double($1) }
	let heightCases = reduce(1...height, 1.0){ $0 * Double($1) }

	println(totalCases / widthCases / heightCases) // 137846528820

### 문제 출처

* [사이냅 소프트의 오일러 프로젝트](http://euler.synap.co.kr/prob_detail.php?id=15)
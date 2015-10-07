---
layout: post
title: "[Swift][일일 코드 #26]코딩도장 - 가장 짧은 지점 구하기"
description: ""
category: "programming"
tags: [swift, map, zip, tuple]
---
{% include JB/setup %}

### Problem - 가장 짧은 지점 구하기 (Level 2)

1차원의 점들이 주어졌을 때, 그 중 가장 거리가 짧은 것의 쌍을 출력하는 함수를 작성하시오. (단 점들의 배열은 모두 정렬되어있다고 가정한다.)

예를들어 S={1, 3, 4, 8, 13, 17, 20} 이 주어졌다면, 결과값은 (3, 4)가 될 것이다.

### Solution

두 지점 경우를 구한 뒤, 경우들에서 지점의 거리를 구하고, 그중 가장 짧은 거리를 찾습니다.

	let p = [1, 3, 4, 8, 13, 17, 20]
	let r = zip(p, p[1..<p.count]).map { ($0.0, $0.1, $0.1 - $0.0) }.sort { $0.2 < $1.2 }.first
	print(r!.0, r!.1)

### 문제 출처

* [코딩도장](http://codingdojang.com/scode/408)
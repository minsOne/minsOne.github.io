---
layout: post
title: "[Swift][일일 코드 #27]코딩도장 - Special Sort"
description: ""
category: "programming"
tags: [swift, filter, array]
---
{% include JB/setup %}

### Problem - Special Sort (Level 2)

n개의 정수를 가진 배열이 있다. 이 배열은 양의정수와 음의 정수를 모두 가지고 있다. 이제 당신은 이 배열을 좀 특별한 방법으로 정렬해야 한다.

정렬이 되고 난 후, 음의 정수는 앞쪽에 양의정수는 뒷쪽에 있어야 한다. 또한 양의정수와 음의정수의 순서에는 변함이 없어야 한다.

	예. -1 1 3 -2 2 ans: -1 -2 1 3 2.

### Solution

0보다 작은 경우, 0이거나 0보다 큰 경우를 합칩니다.

	let l = [-1, 1, 3, -2, 2]
	let r = l.filter { $0 < 0 } + l.filter { $0 >= 0 }
	print(r) // [-1, -2, 1, 3, 2]

### 문제 출처

* [코딩도장](http://codingdojang.com/scode/414)
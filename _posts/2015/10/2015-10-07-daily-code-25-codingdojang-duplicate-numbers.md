---
layout: post
title: "[Swift][일일 코드 #25]코딩도장 - Duplicate Numbers"
description: ""
category: "programming"
tags: [swift, map, string, reduce]
---
{% include JB/setup %}

### Problem - Duplicate Numbers(Level 1)

0~9까지의 문자로 된 숫자를 입력 받았을 때, 이 입력 값이 0~9까지의 숫자가 각각 한 번 씩만 사용된 것인지 확인하는 함수를 구하시오.

* sample inputs: 0123456789 01234 01234567890 6789012345 012322456789
* sample outputs: true false false true false

### Solution

한번씩 사용된 경우인 0123456789의 UTF-8 Code Unit을 각각 더한 값을 기준으로, 입력받은 값과 기준 값이 같은지 판별합니다.

	let answer = "0123456789".utf8.reduce(0) { $0 + Int($1) }
	let inputs = ["0123456789", "01234", "01234567890", "6789012345", "012322456789"];
	let outputs = inputs.map { $0.utf8.reduce(0) { $0 + Int($1) } == answer }

	print(outputs) // [true, false, false, true, false]

### 문제 출처

* [코딩도장](http://codingdojang.com/scode/488)
---
layout: post
title: "[Swift][일일 코드 #23]오일러 프로젝트 022"
description: ""
category: "programming"
tags: [swift, reduce, map, sorted]
---
{% include JB/setup %}

### Problem 022

여기 5천개 이상의 영문 이름들이 들어있는 46KB짜리 텍스트 파일 names.txt 이 있습니다 (우클릭해서 다운로드 받으세요).
이제 각 이름에 대해서 아래와 같은 방법으로 점수를 매기고자 합니다.

* 먼저 모든 이름을 알파벳 순으로 정렬합니다.
* 각 이름에 대해서, 그 이름을 이루는 알파벳에 해당하는 숫자(A=1, B=2, ..., Z=26)를 모두 더합니다.
* 여기에 이 이름의 순번을 곱합니다.
예를 들어 "COLIN"의 경우, 알파벳에 해당하는 숫자는 3, 15, 12, 9, 14이므로 합이 53, 그리고 정렬했을 때 938번째에 오므로 최종 점수는 938 × 53 = 49714가 됩니다.

names.txt에 들어있는 모든 이름의 점수를 계산해서 더하면 얼마입니까?

### Solution

	if let path = NSBundle.mainBundle().pathForResource("names", ofType: "txt") {
		if let names = String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil) {
			let result = names.componentsSeparatedByString(",")
				.sorted(<)
				.map { name in
					Array(name.unicodeScalars).reduce(0){ Int($1.value) + $0 - 64 }
				}
				.reduce((sum: 0, index: 1)){ result, nameValue in
					let result = (result.sum + nameValue * result.index, result.index + 1)
					return result
				}.sum
			println(result)
		}
	}

### 문제 출처

* [사이냅 소프트의 오일러 프로젝트](http://euler.synap.co.kr/prob_detail.php?id=22)
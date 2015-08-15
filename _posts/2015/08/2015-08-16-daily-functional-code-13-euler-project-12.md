---
layout: post
title: "[Swift][일일 코드 #13]오일러 프로젝트 012"
description: ""
category: "programming"
tags: [swift]
---
{% include JB/setup %}

### Problem 012

1부터 n까지의 자연수를 차례로 더하여 구해진 값을 삼각수라고 합니다.

예를 들어 7번째 삼각수는 1 + 2 + 3 + 4 + 5 + 6 + 7 = 28이 됩니다.

이런 식으로 삼각수를 구해 나가면 다음과 같습니다.

1, 3, 6, 10, 15, 21, 28, 36, 45, 55, ...

이 삼각수들의 약수를 구해봅시다.

 1: 1<br/>
 3: 1, 3<br/>
 6: 1, 2, 3, 6<br/>
10: 1, 2, 5, 10<br/>
15: 1, 3, 5, 15<br/>
21: 1, 3, 7, 21<br/>
28: 1, 2, 4, 7, 14, 28<br/>
위에서 보듯이, 5개 이상의 약수를 갖는 첫번째 삼각수는 28입니다.

그러면 500개 이상의 약수를 갖는 가장 작은 삼각수는 얼마입니까?

### Solution

	func getTriangleNumber() -> (Void -> Int) {
	    var sum = 0, index = 1
	    return {
	        sum = sum + index++
	        return sum
	    }
	}

	func factor(n: Int) -> Int {
	    if n <= 1 { return 1 }
	    var count = 2;
	    for var index = 2; index <= Int(ceil(sqrt(Double(n)))); index++ {
	        if n % index == 0 {
	            count += 2
	        }
	    }
	    return count
	}

	let next = getTriangleNumber()
	while true {
	    let triangleNumber = next()
	    let list = factor(triangleNumber)
	    if factor(triangleNumber) >= 500 {
	        println(triangleNumber)
	        break
	    }
	}

### 문제 출처

* [사이냅 소프트의 오일러 프로젝트](http://euler.synap.co.kr/prob_detail.php?id=12)
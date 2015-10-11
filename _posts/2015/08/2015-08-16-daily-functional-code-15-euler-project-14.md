---
layout: post
title: "[Swift][일일 코드 #15]오일러 프로젝트 014"
description: ""
category: "programming"
tags: [swift, cache]
---
{% include JB/setup %}

### Problem 014

양의 정수 n에 대하여, 다음과 같은 계산 과정을 반복하기로 합니다.

n → n / 2 (n이 짝수일 때)<br/>
n → 3 n + 1 (n이 홀수일 때)

13에 대하여 위의 규칙을 적용해보면 아래처럼 10번의 과정을 통해 1이 됩니다.

13 → 40 → 20 → 10 → 5 → 16 → 8 → 4 → 2 → 1<br/>
아직 증명은 되지 않았지만, 이런 과정을 거치면 어떤 수로 시작해도 마지막에는 1로 끝나리라 생각됩니다. <br/>
(역주: 이것은 콜라츠 추측 Collatz Conjecture이라고 하며, 이런 수들을 우박수 hailstone sequence라 부르기도 합니다)<br/>

그러면, 백만(1,000,000) 이하의 수로 시작했을 때 1까지 도달하는데 가장 긴 과정을 거치는 숫자는 얼마입니까?

### Solution

<ul><li>수정 전</li></ul>

		var maximum:(index: Int, value: Int) = (0, 0)
		var cacheSequence = [Int:Int]()

		func hailstoneSequence(n: Int) -> Int {
			if n == 1 { return 1 }

			if let cached = cacheSequence[n] {
				return cached
			} else {
				return 1 + ( (n % 2 == 0) ?
					hailstoneSequence(n/2) :
					hailstoneSequence(n*3+1))
			}
		}

		for i in 1...1_000_000 {
			let result = hailstoneSequence(i)
			cacheSequence[i] = result
			if result > maximum.value { maximum = (i, result) }
		}

		println(maximum)	// (837799, 525)

<ul><li>1차 수정</li></ul>

	let result = reduce(1...1_000_000, (0,0)) { maximum, i in
	    let result = hailstoneSequence(i)
	    cacheSequence[i] = result
	    return (result > maximum.0) ? (i, result) : maximum
	}

	println(result)	// (837799, 525)

<ul><li>2차 수정</li></ul>

	func main(x x: Int, y: Int) -> (Int, Int) {
	    func hailstoneSequence(var cacheSequence: [Int:Int]) -> Int -> Int {
	        func hailstoneSequenceF(n: Int) -> Int {
	            if n == 1 { return 1 }
	            if let cached = cacheSequence[n] { return cached }
	            let result = 1 + ( (n % 2 == 0) ? hailstoneSequenceF(n/2) : hailstoneSequenceF(n*3+1))
	            cacheSequence[n] = result
	            return result
	        }
	        return hailstoneSequenceF
	    }

	    return (x...y).reduce( (result: (index: 0, maximum: 0), f: hailstoneSequence([Int:Int]())) ) {
	        let length = $0.0.f($0.1)
	        if length > $0.0.result.maximum {
	            return (($0.1, length), $0.0.f)
	        }
	        return $0.0
	    }.result
	}

	print(main(x: 1, y: 1_000_000)) // (525, 837799)
	

### 문제 출처

* [사이냅 소프트의 오일러 프로젝트](http://euler.synap.co.kr/prob_detail.php?id=14)
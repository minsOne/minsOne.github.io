---
layout: post
title: "[Swift][일일 코드 #24]오일러 프로젝트 023"
description: ""
category: "programming"
tags: [swift, reduce]
---
{% include JB/setup %}

### Problem 023

자신을 제외한 약수(진약수)를 모두 더하면 자기 자신이 되는 수를 완전수라고 합니다.
예를 들어 28은 1 + 2 + 4 + 7 + 14 = 28 이므로 완전수입니다.
또, 진약수의 합이 자신보다 작으면 부족수, 자신보다 클 때는 초과수라고 합니다.

12는 1 + 2 + 3 + 4 + 6 = 16 > 12 로서 초과수 중에서는 가장 작습니다.
따라서 초과수 두 개의 합으로 나타낼 수 있는 수 중 가장 작은 수는 24 (= 12 + 12) 입니다.

해석학적인 방법을 사용하면, 28123을 넘는 모든 정수는 두 초과수의 합으로 표현 가능함을 보일 수가 있습니다.
두 초과수의 합으로 나타낼 수 없는 가장 큰 수는 실제로는 이 한계값보다 작지만, 해석학적인 방법으로는 더 이상 이 한계값을 낮출 수 없다고 합니다.

그렇다면, 초과수 두 개의 합으로 나타낼 수 없는 모든 양의 정수의 합은 얼마입니까?

### Solution

	func factor(n: Int) -> [Int] {
		if n <= 1 { return [] }

		var prime: Int?, index = 2
		for(; index < n; index++) {
			if n % index == 0 {
				prime = index
				break;
			}
		}

		if let prime = prime {
			return [prime] + factor(n/index)
		}
		else {
			return [index] + factor(n/index)
		}
	}


	let limit = 28123

<ul><li>수정 전</li></ul>

	let abundantList = reduce(1..<limit, [Int]()){ abundants, number in
		let primeNums = factor(number).reduce([Int:Int]()){ primes, _num in
			var _primes = primes
			if let count = primes[_num] {
				_primes[_num] = count + 1
			} else {
				_primes[_num] = 1
			}
			return _primes
		}

		let result = primeNums.keys.array.reduce(1){ divisorSum, prime in
			if let count = primeNums[prime] {
				return divisorSum * reduce(0...count, 0) { $0 + Int(pow(Double(prime), Double($1))) }
			} else {
				return divisorSum
			}
		}

		if result > (number * 2) {
			return abundants + [number]
		}
		return abundants
	}

<ul><li>수정 후</li></ul>

	let primeLists = reduce(1..<limit, [Int:[Int:Int]]()) { primes, number in
		let primeNums = factor(number).reduce([Int:Int]()){ primes, num in
			var _primes = primes
			if let count = primes[num] {
				_primes[num] = count + 1
			} else {
				_primes[num] = 1
			}
			return _primes
		}
		var _primes = primes
		_primes[number] = primeNums
		return _primes
	}

	let abundantList = primeLists.keys.array.filter { number in
		// 자기 자신을 제외한 모든 소수의 합을 구한다.
		let result = primeLists[number]?.keys.array.reduce(1) { divisorSum, prime in
			if let count = primeLists[number]?[prime] {
				return divisorSum! * reduce(0...count, 0) {
					$0 + Int(pow(Double(prime), Double($1)))
				}
			} else {
				return divisorSum
			}
		}
		return (result > (number * 2)) ? true : false
	}

<br/>

	var isNotAbundantList = Array(count: limit, repeatedValue: false)
	for n in abundantList {
		for m in abundantList {
			if limit > n + m {
				isNotAbundantList[n + m] = true
			}
		}
	}

	var abundantSum = reduce(1..<isNotAbundantList.count, 0) {
		return (!isNotAbundantList[$1]) ? $0 + $1 : $0
	}

	println(abundantSum) // 4179871

### 문제 출처

* [사이냅 소프트의 오일러 프로젝트](http://euler.synap.co.kr/prob_detail.php?id=23)
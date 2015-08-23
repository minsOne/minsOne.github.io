---
layout: post
title: "[Swift][일일 코드 #22]오일러 프로젝트 021"
description: ""
category: "programming"
tags: [swift, reduce, prime, amicable number]
---
{% include JB/setup %}

### Problem 021

n의 약수들 중에서 자신을 제외한 것의 합을 d(n)으로 정의했을 때,서로 다른 두 정수 a, b에 대하여 d(a) = b 이고 d(b) = a 이면 a, b는 친화쌍이라 하고 a와 b를 각각 친화수(우애수)라고 합니다.

예를 들어 220의 약수는 자신을 제외하면 1, 2, 4, 5, 10, 11, 20, 22, 44, 55, 110 이므로 그 합은 d(220) = 284 입니다.<br/>
또 284의 약수는 자신을 제외하면 1, 2, 4, 71, 142 이므로 d(284) = 220 입니다.<br/>
따라서 220과 284는 친화쌍이 됩니다.

10000 이하의 친화수들을 모두 찾아서 그 합을 구하세요.

### Solution

`number = a^b * c^d`라고 한다면 약수의 합은 `(a^b + a^(b-1) + ... a^1 + a^0) * (c^d + c^(d-1) + ... c^1 + c^0)` 이 됩니다.

약수들의 합은 다음과 같이 구할 수 있습니다.

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

	let divisorDictionary = reduce(1...10000, [Int:Int]()){ divisors, number in
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

		if result - number != 1 {
			var _divisors = divisors
			_divisors[number] = result - number
			return _divisors
		}
		return divisors
	}

	let amicableSum = divisorDictionary.keys.array.reduce(0) { sum, number in
		if let amicable = divisorDictionary[number]
			where divisorDictionary[amicable] == number && amicable != number {
				return sum + number
		}
		return sum
	}

	println(amicableSum)	// 31626

### 문제 출처

* [사이냅 소프트의 오일러 프로젝트](http://euler.synap.co.kr/prob_detail.php?id=21)
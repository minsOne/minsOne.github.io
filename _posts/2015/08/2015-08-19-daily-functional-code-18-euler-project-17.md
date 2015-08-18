---
layout: post
title: "[Swift][일일 코드 #18]오일러 프로젝트 017"
description: ""
category: "programming"
tags: [swift]
---
{% include JB/setup %}

### Problem 017

1부터 5까지의 숫자를 영어로 쓰면 one, two, three, four, five 이고,
각 단어의 길이를 더하면 3 + 3 + 5 + 4 + 4 = 19 이므로 사용된 글자는 모두 19개입니다.

1부터 1,000까지 영어로 썼을 때는 모두 몇 개의 글자를 사용해야 할까요?

참고: 빈 칸이나 하이픈('-')은 셈에서 제외하며, 단어 사이의 and 는 셈에 넣습니다. 예를 들어 342를 영어로 쓰면 three hundred and forty-two 가 되어서 23 글자, 115 = one hundred and fifteen 의 경우에는 20 글자가 됩니다.

### Solution

	let digits = ["one","two","three","four","five","six","seven","eight","nine","ten","eleven","twelve","thirteen","fourteen","fifteen",
		"sixteen","seventeen","eighteen","nineteen"]
	let tenDigits = ["twenty","thirty","forty","fifty","sixty","seventy","eighty","ninety"]

	func makeDigitStr(number: Int) -> String {
		switch(number) {
		case _ where number == 0:
			return ""
		case _ where number < 20:
			return digits[number-1]
		case _ where 20 <= number && number < 100:
			return tenDigits[(number / 10) - 2] + makeDigitStr(number % 10)
		case _ where 100 <= number && number < 1000 && number % 100 == 0:
			return makeDigitStr(number/100) + "hundred"
		case _ where 100 <= number && number < 1000 && number % 100 != 0:
			return makeDigitStr(number/100) + "hundred" + "and" + makeDigitStr(number % 100)
		case _ where number == 1000:
			return "onethousand"
		default:
			return ""
		}
	}

	let result = count(reduce(1...1000, ""){ $0 + makeDigitStr($1) })

	println(result)	// 21124


### 문제 출처

* [사이냅 소프트의 오일러 프로젝트](http://euler.synap.co.kr/prob_detail.php?id=17)
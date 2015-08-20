---
layout: post
title: "[Swift][일일 코드 #20]오일러 프로젝트 019"
description: ""
category: "programming"
tags: [swift, reduce]
---
{% include JB/setup %}

### Problem 019

다음은 달력에 관한 몇 가지 일반적인 정보입니다 (필요한 경우 좀 더 연구를 해 보셔도 좋습니다).

* 1900년 1월 1일은 월요일이다.
* 4월, 6월, 9월, 11월은 30일까지 있고, 1월, 3월, 5월, 7월, 8월, 10월, 12월은 31일까지 있다.
* 2월은 28일이지만, 윤년에는 29일까지 있다.
* 윤년은 연도를 4로 나누어 떨어지는 해를 말한다. 하지만 400으로 나누어 떨어지지 않는 매 100년째는 윤년이 아니며, 400으로 나누어 떨어지면 윤년이다

20세기 (1901년 1월 1일 ~ 2000년 12월 31일) 에서, 매월 1일이 일요일인 경우는 총 몇 번입니까?

### Solution

	func daysInMonth(month: Int, year: Int) -> Int {
		switch month {
		case 1, 3, 5, 7, 8, 10, 12:
			return 31
		case 4, 6, 9, 11:
			return 30
		case 2:
			return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0) ? 29 : 28
		default:
			return 0
		}
	}

<ul><li>수정 전</li></ul>

	var firstSundays = 0, remainDays = 1
	for year in 1900...2000 {
		for month in 1...12 {
			if remainDays == 0 && year >= 1901{
				firstSundays++
			}
			remainDays = (remainDays + daysInMonth(month, year)) % 7
		}
	}

	println(firstSundays)

<ul><li>수정 후</li></ul>

	let result = reduce(1900...2000, (firstSundays: 0, remainDays: 1)) { sum, year in
		return reduce(1...12, sum){ _sum, month in
			let result = (
				(_sum.remainDays == 0 && year >= 1901)
					? _sum.firstSundays + 1
					: _sum.firstSundays,
				(_sum.remainDays + daysInMonth(month, year)) % 7
			)
			return result
		}
	}

	println(result.firstSundays)	// 171


### 문제 출처

* [사이냅 소프트의 오일러 프로젝트](http://euler.synap.co.kr/prob_detail.php?id=19)
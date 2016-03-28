---
layout: post
title: "[Swift]Hashable 프로토콜"
description: ""
category: "programming"
tags: [swift, Hashable, protocol, Equatable, extension]
---
{% include JB/setup %}

Swift에서는 hashable이라는 프로토콜을 통해 커스텀 구조 및 고유 값을 만들 수 있습니다.

	struct Point {
		let x: Int
		let y: Int
	}

	extension Point: Hashable {
		var hashValue: Int {
			return x.hashValue ^ y.hashValue
		}
	}

	func ==(lhs: Point, rhs: Point) -> Bool {
		return lhs.x == rhs.x && lhs.y == rhs.y
	}

Hashable 프로토콜을 사용하면 hashValue 계산 속성과 == 연산자를 선언해야 합니다.

이제 Point 배열에서 고유 값들만 추출할 수 있습니다.

	extension Array where Element : Hashable {
		var unique: [Element] {
			return Array(Set(self))
		}
	}

	let uniqueList = [Point(x: 1, y: 1), ... ].unique

Set에 배열을 넣기 위해서는 배열의 원소가 Hashable 프로토콜을 지원해야합니다. 따라서 Point 구조체는 Hashable을 지원하므로 Set을 통한 고유 값 집합을 만들고, 다시 배열로 만들 수 있습니다.

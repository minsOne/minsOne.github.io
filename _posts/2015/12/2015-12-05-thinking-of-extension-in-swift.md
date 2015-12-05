---
layout: post
title: "[Swift][Objective-C]Extension 단상"
description: ""
category: "programming"
tags: [swift, extension, struct, class]
---
{% include JB/setup %}

Swift는 Extension, Objective-C는 Category로 구조체와 클래스 확장이 가능합니다.

역할에 맞게 코드를 Extension에 넣습니다. 한 파일에 코드가 많아지면 유용하게 사용합니다. 

최근에는 좀 더 자주 사용하고 있는데, 우선은 다음 코드를 봅시다.

	struct a {
		let a = [1,2,3]
	}

	func twoTime(list: [Int]) -> [Int] {
		return list.map { $0 * 2 }
	}

<br/>값을 두 배 곱하는 twoTime 메소드를 작성했습니다. 다른 코드를 살펴봅시다.

	struct a {
		let a = [1,2,3]
	}

	extension CollectionType where Generator.Element == Int {
		var twoTime: [Int] {
			get {
				return self.map { $0 * 2 }
			}
		}
	}

<br/>두 코드는 다음과 같이 작성됩니다.

	// 첫 번째 경우
	twoTime(a().a)	// 2, 4, 6

	// 두 번째 경우
	a().a.twoTime 	// 2, 4, 6

첫 번째 경우는 두 배를 곱한 결과를 얻는다 어떤 값에, 이렇게 읽히는데 반해, 두 번째 경우는 어떤 값을 두 배 곱한 결과를 얻는다고 읽습니다.

최근에는 위와 같이 단순 값을 얻는 메소드가 자주사용하는 경우, 두 번째 경우의 코드로 조금씩 사용하고 있습니다.

실제로 얻는 장단점은 구조체 또는 클래스에 함수를 선언하지 않기 때문에 내용이 작아진다는 장점, 하지만 단점으로는 끝까지 읽어야 무슨 값인지 알 수 있다는 점입니다.
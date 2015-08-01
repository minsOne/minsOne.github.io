---
layout: post
title: "일일 함수형 코드 #1 - 이동하는 방향 확인하기 in Swift"
description: ""
category: "programming"
tags: [swift, closure, switch, direction]
---
{% include JB/setup %}

클로저를 이용하여 이동하는 방향을 얻는 코드입니다.

	typealias Direction = (CGFloat -> Bool)

	func direct(initializedOffset: CGFloat) -> (CGFloat -> Bool) {
		var lastOffset = initializedOffset	// 초기 위치를 저장하여 캡쳐링 됩니다.
		func isDirection(offSet: CGFloat) -> Bool {
			let result = lastOffset > offSet ? false : true	// 현재 위치가 마지막 위치보다 크면 true, 작거나 같으면 false를 반환합니다.
			lastOffset = offSet 	// 마지막 위치를 갱신합니다.
			return result;
		}
		return isDirection
	}

	let checkUpDown: Direction = direct(5)
	checkUpDown(10)		// true
	checkUpDown(-20)	// false
	checkUpDown(30)		// true
	checkUpDown(-40)	// false

	let checkLeftRight: Direction = direct(3.0)
	checkLeftRight(10)	// true
	checkLeftRight(-20)	// false
	checkLeftRight(30)	// true
	checkLeftRight(-40)	// false

<br/>위의 함수를 통해서 얻은 결과로 방향을 print 함수로 출력할 수 있습니다.

	func printDirection(isUpDown: Bool, isLeftRight: Bool) {
	    switch (isUpDown, isLeftRight) {
	    case (true, true):
	        println("Direction is Up and Right")
	    case (true, false):
	        println("Direction is Up and Left")
	    case (false, true):
	        println("Direction is Down and Right")
	    case (false, true):
	        println("Direction is Down and Right")
	    case (true, _):
	        println("Direction is Up")
	    case (false, _):
	        println("Direction is Down")
	    case (_, true):
	        println("Direction is Right")
	    case (_, false):
	        println("Direction is Left")
	    default:
	        println("It is impossible")
	    }
	}

	printDirection(checkUpDown(-20), checkLeftRight(-30))

<br/>
---
layout: post
title: "[Swift]Set 정리"
description: ""
category: "mac/ios"
tags: [swift, set, type]
---
{% include JB/setup %}

이번에 업데이트 된 Swift 1.2에서는 Set 타입이 추가되었습니다. 따라서 Set을 정리해볼려고 합니다. 더 자세한 내용을 보길 원하시면 [Apple Document][Apple Document]를 참고하시기 바랍니다.

### Set

Swift의 Set 타입은 NSSet 클래스를 브릿지된 형태입니다. 

Set 타입은 순서가 중요하지 않거나 하나의 항목만 가져야 할 때 사용할 수 있습니다.

#### Set 문법

Set 타입의 문법은 `Set<SomeType>`로 작성되며, 다음과 같이 초기화 할 수 있습니다.

	var strs = Set<String>()

만약 이미 초기화가 되어 있다면, 다음과 같이 빈 Set 객체로 만들 수 있습니다.

	strs = []

<br/>값이 들어간 상태로 초기화 한다면 다음과 같이 사용할 수 있습니다.

	strs = Set(["A", "B", "C", "D"])

<br/>Set 객체에 `insert`, 'remove' 메소드를 통해 추가, 삭제할 수 있습니다.
	
	strs.insert("E")
	strs.remove("B")	// "B"

<br/>특정 항목이 포함되어 있는지 `contains` 메소드로 확인할 수 있습니다.

	strs.contains("C") // true

<br/>Set 객체에 `count`, `isEmpty` 속성를 통해 크기를 알 수 있습니다.

	strs.isEmpty 	// false
	strs.count 	// 4

<br/>`For Loops`를 통해 Set 객체의 항목을 하나씩 얻을 수 있습니다.

	for str in strs {
	  println(str)
	}

<br/>

#### Set 연산 작업 및 비교

집합처럼 두 개의 Set을 결합하여 모두 포함하는지, 포함하지 않는지, 일부만 포함하는지 등을 수행할 수 있습니다. 

#### Set 연산 작업

<br/><img src="{{ site.production_url }}/image/flickr/20588695009_bc5b70e88e.jpg" width="500" height="379" alt="setVennDiagram"><br/><br/>

union : 합집합으로 두 Set을 합쳐 새로운 Set을 만듭니다.

subtract : 겹치는 부분을 제외하여 새로운 Set을 만듭니다.

intersect : 두 Set의 겹치는 부분으로 새로운 Set을 만듭니다.

exclusiveOr : 두 Set의 겹치는 부분을 제외한 나머지 부분으로 새로운 Set을 만듭니다.

	let oddDigits: Set = [1, 3, 5, 7, 9]
	let evenDigits: Set = [0, 2, 4, 6, 8]
	let singleDigitPrimeNumbers: Set = [2, 3, 5, 7]
	sorted(oddDigits.union(evenDigits))
	// [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
	sorted(oddDigits.intersect(evenDigits))
	// []
	sorted(oddDigits.subtract(singleDigitPrimeNumbers))
	// [1, 9]
	sorted(oddDigits.exclusiveOr(singleDigitPrimeNumbers))
	// [1, 2, 9]

<br/><br/>

#### Set 비교

<br/><img src="{{ site.production_url }}/image/flickr/20587459798_95dcf36955.jpg" width="500" height="293" alt="setEulerDiagram"><br/><br/>

isSubsetOf : Set의 모든 값이 특정 Set에 포함되는지를 확인합니다.

isSupersetOf : Set의 모든 값이 특정 Set을 포함하는지 확인합니다.

isDisjointWith : 두 Set이 일치하지 않는지 확인합니다.

	let houseAnimals: Set = ["🐶", "🐱"]
	let farmAnimals: Set = ["🐮", "🐔", "🐑", "🐶", "🐱"]
	let cityAnimals: Set = ["🐦", "🐭"]

	houseAnimals.isSubsetOf(farmAnimals)  // true
	farmAnimals.isSupersetOf(houseAnimals)  // true
	farmAnimals.isDisjointWith(cityAnimals) // true

### 참고자료 

* [Apple Document][Apple Document]

<br/><br/>

[Apple Document]: https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/CollectionTypes.html#//apple_ref/doc/uid/TP40014097-CH8-ID484
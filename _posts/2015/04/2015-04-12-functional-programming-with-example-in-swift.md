---
layout: post
title: "[Swift]예제로 살펴본 함수형 프로그래밍"
description: ""
category: "programming"
tags: [functional programming, FP, swift, battle ship, refactoring, pure function, first-class function, function, set, module, type, lamda]
---
{% include JB/setup %}

## 들어가기전에

이 글은 [Functional Programming in Swift][Functional Programming in Swift]의 BattleShip 예제를 참고하였으며, 해당 예제는 1994년에 작성된 [논문][BattleShip Example]에서 확인할 수 있습니다.

## 함수형 프로그래밍

함수형 프로그래밍은 자료처리를 수학적 함수( f(x)=y )의 계산으로 취급하고 상태와 가변 데이터를 멀리하는 프로그래밍 패러다임의 하나입니다.

일반적으로 명령형 프로그래밍은 상태 값을 변경할 수 있어 예측하지 못한 에러를 유발할 수 있습니다. 그러나 함수형 프로그래밍은 입력된 인자에만 의존하기 때문에 항상 예측할 수 있는 결과가 나옵니다. 즉, 인자에 x라는 값을 넣으면 f(x)라는 결과가 출력이 됩니다.

<!-- 
### 고계 함수(Higher-order functions)

고계 함수는 다음 중 하나 이상을 따릅니다.
* 입력에 하나 이상의 함수를 취한다.
* 출력이 함수이다.

이는 함수를 값으로 다루기 때문에 위의 조건을 따르게 됩니다. 일반적으로 고계 함수는 map, filter, reduce를 기본적으로 가지며, 인자로 리스트와 함수 f를 취합니다. 그리고 리스트 각각의 요소를 함수 f로 적용하여 새로운 결과를 받습니다. map은 함수 f를 적용하여 변경된 결과를 받으며, filter는 함수 f를 적용하여 해당되는 결과만 받고, reduce는 함수 f를 적용하여 하나의 결과만 받습니다. 이 부분에 대해서는 [이전 글][Map_Reduce_Filter_inSwift]을 참고하시면 됩니다.
 -->
<!-- ### 클로저(Closure)

사용자의 코드 안에서 전달되어 사용될 수 있는 기술이며, 독립적인 블럭입니다. 클로저는 자신이 정의된 컨텍스트로부터 임의의 상수와 변수로부터 레퍼런스를 획득하고 저장할 수 있습니다. -->

### 순수한 함수(Pure functions)

순수한 함수는 메모리나 I/O로부터 side effects를 가지지 않습니다. 순수한 함수는 몇가지 유용한 속성을 가지며, 코드 최적화하는데 사용됩니다.

* 순수한 표현식의 결과가 사용되지 않다면, 다른 표현식에 영향을 주지 않고 제거할 수 있습니다.
* 순수한 함수는 부작용을 발생하지 않는 인자를 호출할 때, 결과 값은 인자 리스트에 관련한 상수입니다. 순수한 함수가 같은 인자를 호출한다면, 같은 결과를 받을 것입니다.
* 두 개의 순수한 표현식 사이에 데이터 의존성이 없는 경우, 순서는 반대로 되거나 병렬로 수행될 수 있고, 서로 간의 간섭을 할 수 없습니다.(thread-safe)
* 모든 언어가 부작용을 허용하지 않는 경우, 어떠한 평가 전략이 사용됩니다; 프로그램 내의 순서를 변경하거나 식 계산을 결합을 위한 자유를 컴파일러에게 제공합니다.(deforestation)

### 일급 함수(First-class function)

함수를 객체로 다루면서 인자로 함수를 넘기고 변수에 함수를 저장하며, 값으로 함수를 반환할 수 있습니다. 

### 함수형 프로그래밍 디자인 조건

함수형 프로그래밍을 높은 품질로 디자인 하기 위해서는 다음과 같은 요건이 필요합니다.

* 모듈 방식 : 각각의 프로그램을 반복하여 작은 단위로 쪼개야 합니다. 모든 기능 조각을 조립하여 완성된 프로그램을 정의할 수 있습니다. 거대한 프로그램을 작은 조각으로 분해할 때 각각의 조각들이 상태를 공유하는 것을 피해야 합니다.
* 상태 오염 : 가변 상태를 피하도록 값을 통해 프로그래밍합니다. 부작용이 발생하지 않도록 데이터의 의존성이 생기지 않도록 해야 합니다.
* 타입 : 타입의 사용을 신중하게 해야 합니다. 데이터 타입의 신중한 선택은 코드를 견고하게 작성하도록 도와주어 안전하고 강력하게 만듭니다.

출처 : [Functional Programming in Swift][Functional Programming in Swift]

## 예제로 보는 함수형 프로그래밍

[Functional Programming in Swift][Functional Programming in Swift]에서 소개된 예제로 함선을 통해 설명하고 있습니다.

명령형을 통한 문제 해결과 함수형을 통한 문제 해결을 비교하도록 하겠습니다.

### 명령문을 통한 코드 작성

첫번째로 사거리 내에서 적군 함선이 있는지 확인하는 함수입니다.

<img src="{{ site.production_url }}/image/flickr/20564775360_d91473dfe3.jpg" width="496" height="500" alt="inRange1"><br/>

(0, 0)에서 target까지 거리를 구하여 사거리 안에 포함되어 있는지 확인합니다.

	typealias Position = CGPoint
	typealias Distance = CGFloat

	func inRange1(target: Position, range: Distance) -> Bool {
		return sqrt(target.x * target.x + target.y * target.y) <= range
	}

<br/>이제 현재 자신의 함선이 이동하는 경우를 구해봅시다.

<img src="{{ site.production_url }}/image/flickr/20130158534_f48a7cb215.jpg" width="448" height="437" alt="inRange2"><br/><br/>

(0,0)에서 ownPosition으로 이동하여 target이 사거리 안에 포함되어 있는지 확인합니다.

	func inRange2(target: Position, ownPosition: Position, range: Distance) -> Bool {
		let dx = ownPosition.x - target.x
		let dy = ownPosition.y - target.y
		let targetDistance = sqrt(dx * dx + dy * dy)
		return targetDistance <= range
	}

<br/>적군 함선에게 발사하려면 최소 사거리보다 멀어야 되는 조건을 추가해 봅시다.

<br/><img src="{{ site.production_url }}/image/flickr/20726495026_e18fdd3a5e.jpg" width="468" height="436" alt="inRange3"><br/><br/>

	let minimumDistance: Distance = 2.0

	func inRange3(target: Position, ownPosition: Position, range: Distance) -> Bool {
		let dx = ownPosition.x - target.x
		let dy = ownPosition.y - target.y
		let targetDistance = sqrt(dx * dx + dy * dy)
		return targetDistance <= range && targetDistance >= minimumDistance
	}

<br/>마지막으로 아군 함선이 사거리 내에 들어왔을 때 제외하는 조건을 추가해 봅시다.

	func inRange4(target: Position, ownPosition: Position, friendly: Position, range: Distance) -> Bool {
		let dx = ownPosition.x - target.x
		let dy = ownPosition.y - target.y
		let targetDistance = sqrt(dx * dx + dy * dy) 

		let friendlyDx = friendly.x - target.x
		let friendlyDy = friendly.y - target.y
		let friendlyDistance = sqrt(friendlyDx * friendlyDx + friendlyDy * friendlyDy)

		return targetDistance <= range
					&& targetDistance >= minimumDistance
					&& (friendlyDistance >= minimumDistance)
	}

점점 조건이 늘어남에 따라 로직의 복잡도가 증가함을 볼 수 있습니다. 이제 다음으로 함수형으로 위의 코드를 리팩토링해보겠습니다.

### 함수형 프로그래밍을 통한 리팩토링

먼저 수학적으로 접근해 봅시다.

자신의 함선은 최대 사거리 내에서 최소 사거리보다 커야 합니다. 따라서 최대 사거리를 A라고 하고 최소 사거리를 B라고 한다면 A-B를 통해 사거리 지역을 얻을 수 있습니다. 또한, 아군 함선의 지역은 제외하여야 하므로 아군 함선 지역을 C라고 한다면 최종적으로 도출해야할 식은 `(A-B)-C`가 됩니다.

함선이 특정 좌표에 있을 때 사거리 내에 있는지 확인하는 함수를 타입으로 만듭니다.

	typealias Region = Position -> Bool

두번째로는 사거리를 표현하는 함수 circle을 만듭니다.

	func circle(radius: Distance) -> Region {
		return { point in 
			sqrt(point.x * point.x + point.y * point.y) <= radius
		}
	}

circle 함수는 함수를 반환하게 됩니다. 즉, f(x)=y 형태로 반환하게 되며, 외부에 영향을 받지 않습니다. 반환받은 함수에서 최종적으로 사격 가능 여부를 판단할 수 있습니다.

<br/>이제 자신의 함선 위치가 옮겨 졌을 때 조건을 추가해 봅시다.

	func circle2(radius: Distance, center: Position) -> Region {
		return { point in 
			let shiftedPoint = Position(x: point.x + center.x, y: point.y + center.y)
			return sqrt(shiftedPoint.x * shiftedPoint.x + shiftedPoint.y * shiftedPoint.y) <= radius
		}
	}

이렇게 작성하게 되면 앞에서 한 것과 같이 동일하게 조건을 추가한 것입니다. 만약에 사각형이나 삼각형 등의 조건으로 변경이되면 또다시 함수를 만들어야 합니다. 따라서 이동만 시켜주는 함수를 별도로 만들어야 합니다.

	func shift(offset: Position, region: Region) -> Region {
		return { point in
			let shiftedPoint = Position(x: point.x - offset.x, y: point.y - offset.y)
			return region(shiftedPoint)
		}
	}

Region 함수를 인자로 받고 좌표를 region 함수에 넘겨주게 되면 region이 어떻든 원하는 결과를 넘겨주게 됩니다. 즉, f(x) = y가 되는 것이게 됩니다.

자신의 위치가 (2, 2)만큼 이동하고 사거리가 10, 적군 함선의 위치가 (5, 5)이면 다음으로 표시할 수 있습니다.

	shift(Position(x: 2, y: 2), circle(10))(Position(x: 5, y: 5))

또는 

	var checkFn = shift(Position(x: 2, y: 2), circle(10))
	checkFn(Position(x: 5, y: 5))

<br/>이제 특정 지점이 포함이 안되는지 확인하는 함수를 작성합니다.; 여집합으로 A<sup>C</sup>가 됩니다.

	func invert(region: Region) -> Region {
		return { point in
			!region(point)
		}
	}

<br/>특정 지점이 두 개의 지역에 동시에 포함되는지 확인하는 함수를 작성합니다; 교집합으로 A ∩ B 됩니다.

	func intersection(region1: Region, region2: Region) -> Region {
		return { point in
			region1(point) && region2(point)
		}
	}

<br/>특정 지점이 두 개의 지역 중 하나라도 포함되는지 확인하는 함수를 작성합니다; 합집합으로 A ∪ B 됩니다.

	func union(region1: Region, region2: Region) -> Region {
		return { point in
			region1(point) || region2(point)
		}
	}

<br/>특정 지점이 한 지역에 포함되고 한 지역에는 포함되지 않는지 확인하는 함수를 작성합니다; 차집합으로 A-B -> A ∩ B<sup>C</sup>가 됩니다.

	func difference(region: Region, minusRegion: Region) -> Region {
		return intersection(region, invert(minusRegion))
	}

#### 최종 리팩토링 코드

	let minimumDistance: Distance = 2.0

	func inRange(ownPosition: Position, target: Position, friendly: Position, range: Distance) -> Bool{
		let rangeRegion = difference(circle(range), circle(minimumDistance))
		let targetRegion = shift(ownPosition, rangeRegion)
		let friendlyRegion = shift(friendly, circle(minimumDistance))
		let resultRegion = difference(targetRegion, friendlyRegion)

		return resultRegion(target)
	}

우선 자신의 함선 사거리를 A, 최소 사거리 B, 아군 지역 C라고 표시합니다. 사격 가능한 구역을 `(A-B)-C`로 표시할 수 있습니다.

코드 하나씩 살펴봅시다.<br/><br/>

첫번째 코드는 자신의 함선 사거리 지역과 최소 사거리 지역의 차집합을 얻습니다; `A-B = D`

	let rangeRegion = difference(circle(range), circle(minimumDistance))

<br/>두번째 코드는 자신의 함선 위치를 ownPosition으로 옮겨 지역을 설정합니다.

	let targetRegion = shift(ownPosition, rangeRegion)

<br/>세번째 코드는 아군 함선의 위치를 friendly로 옮겨 아군 함선의 지역을 설정합니다.

	let friendlyRegion = shift(friendly, circle(minimumDistance))

<br/>네번째 코드는 자신의 지역과 아군 함선의 지역의 차집합을 얻습니다; `D-C`

	let resultRegion = difference(targetRegion, friendlyRegion)

<br/>다섯번째 코드에서 target의 좌표를 넣어 사격 가능 여부를 판단하게 됩니다.

	return resultRegion(target)

<br/>다음과 같이 결과를 확인할 수 있습니다.

	inRange(ownPosition: Position(x: 5, y: 5), target: Position(x: 7, y: 7), friendly: Position(x: 1, y: 1), range: 10) // true
	inRange(ownPosition: Position(x: 5, y: 5), target: Position(x: 6, y: 6), friendly: Position(x: 1, y: 1), range: 10) // false
	inRange(ownPosition: Position(x: 5, y: 5), target: Position(x: 8, y: 8), friendly: Position(x: 7, y: 7), range: 10) // true

### 정리

위의 예제를 해결하기 위해서는 집합을 알고 있어야 합니다. 차집합, 여집합, 합집합, 교집합의 개념을 모르면 해결할 수 없습니다.

함수의 개념으로 접근하여 하나씩 풀어나가면 쉽게 해결할 수 있습니다.

리팩토링 된 예제 코드는 [다음][Gist]에서 확인할 수 있습니다.

### 참고 자료

* [위키피디아-함수형 프로그래밍 Ko][Wikipedia_Ko_FP]
* [위키피디아-함수형 프로그래밍 En][Wikipedia_En_FP]
* [Functional Programming in Swift][Functional Programming in Swift]
* [집합][집합]

[Wikipedia_Ko_FP]: http://ko.wikipedia.org/wiki/함수형_프로그래밍
[Wikipedia_En_FP]: http://en.wikipedia.org/wiki/Functional_programming
[Functional Programming in Swift]: http://www.objc.io/books/
[BattleShip Example]: http://cpsc.yale.edu/sites/default/files/files/tr1049.pdf
[Map_Reduce_Filter_inSwift]: ../../../mac/ios/swift-map-filter-reduce-and-inference/
[집합]: http://ko.wikipedia.org/wiki/집합
[Gist]: https://gist.github.com/minsOne/416344202593cfe64b99
---
layout: post
title: "[Swift3]Phantom Type"
description: ""
category: "programming"
tags: [swift, enum, phantom type, protocol, struct, compiler, generics, strongly typed language]
---
{% include JB/setup %}

## Phantom type(팬텀 타입)

Phantom Type은 저장 공간을 가지고 있지 않은 숨겨진 제네릭 매개 변수가 포함된 매개 변수화된 데이터로, 이 용어는 [하스켈](https://wiki.haskell.org/Phantom_type)에서 확인할 수 있습니다.

Swift에서는 Phantom Type을 어떻게 사용할까요? 아래 코드를 살펴봅시다.

```swift
protocol Distance {}

enum Kilometres : Distance {}
enum Miles : Distance {}

struct Unit<U: Distance> {
	let length: Double
}
```

Distance 프로토콜은 Kilometres와 Miles 타입에 아무런 기여를 하지 않지만 Distance 프로토콜을 따르므로, 존재하지만 실체는 없는 이 Distance 프로토콜을 Phantom Type이라고 합니다.

위의 Unit 구조체는 Distance 프로토콜을 따르는 타입을 사용하도록 제약 조건이 추가되지만, 구조체가 더 커지거나 별도의 정보를 들고 있지 않습니다. 

그리고 Unit은 다음과 같이 사용할 수 있습니다.

```
let km = Unit<Kilometres>(length: 10)
let mile = Unit<Miles>(length: 10)
```

Phantom Type으로 인해 제약조건이 추가되었으므로, Kilometres에서 Miles로 변경을 하기 위해선 convert 라는 외부 함수가 필요합니다. 

하지만 타입 변환을 하기 위해 covert 함수가 외부에 선언될 필요는 없습니다. 

그러면 어떻게 타입 변환을 할 지 더 살펴보도록 합시다.

Kilometer를 기본 단위로 정하고, Meter, Feet, Miles로 단위를 바꿀 수 있도록 하며, 해당 기준 값은 Kilometer를 기준으로 값을 정합니다.

```swift
protocol Distance {
	static var factor: Double { get }
}

enum Kilometers: Distance {
	static let factor: Double = 1.0
}
enum Miles: Distance {
	static let factor: Double = 0.621371
}
enum Meters: Distance {
	static let factor: Double = 1000
}
enum Feet: Distance {
	static let factor: Double = 3280.84
}
```

아까 위와 같이 Unit 구조체를 선언하고, 다른 단위로 변경할 수 있는 함수를 만듭니다.

```swift
struct Unit<U: Distance> {
	let length: Double

	func covert<D: Distance>() -> Unit<D> {
        let baseLength = length / U.factor
        let covertLength = baseLength * D.factor
        return Unit<D>(length: covertLength)
    }
}

extension Unit {
	var km: Unit<Kilometers> { return covertTo() }
	var mile: Unit<Miles> { return covertTo() }
	var meter: Unit<Meters> { return covertTo() }
	var feet: Unit<Feet> { return covertTo() }
}

let km = Unit<Kilometers>(length: 10)
let mils = Unit<Miles>(length: 10)
let meter  = Unit<Meters>(length: 10)

print(km.km.length) // Output : 10.0
print(mils.km.length) // Output : 16.0934449789256
print(km.meter.length) // Output : 10000.0
print(meter.km.length) // Output : 0.01
print(meter.feet.length) // Output : 32.8084
```

Kilometers, Miles, Meters, Feet 단위는 각각 다르지만 km로 선언된 값을 쉽게 miles, meter로 변경하기 쉽습니다. 이는 Phantom Type을 제약조건으로 가지기 때문입니다.

그리고 각 단위는 유니크하여 잘못 사용할 수 없도록 컴파일러가 항상 검사합니다.

## 참고자료

* [Swift: Money with Phantom Types](https://www.natashatherobot.com/swift-money-phantom-types/)
* [The Type System is Your Friend](https://realm.io/news/swift-summit-johannes-weiss-the-type-system-is-your-friend/)
* [Measurements and Units with Phantom Types](https://oleb.net/blog/2016/08/measurements-and-units-with-phantom-types/)
* [Functional Snippet #13: Phantom Types](https://www.objc.io/blog/2014/12/29/functional-snippet-13-phantom-types/)

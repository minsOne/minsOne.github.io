---
layout: post
title: "[Swift]Iterator 패턴 구현하기"
description: ""
category: "Mac/iOS"
tags: [swift, iterator, protocol, sequencetype, generatortype, generate, next, for, struct, class]
---
{% include JB/setup %}

때때로 사용자 클래스 또는 구조체에서 Iterator를 구현하여 쓰고 싶을 때가 있습니다. Swift에서는 SequenceType 프로토콜을 이용하여 구현할 수 있는데, SequenceType 프로토콜은 generate 메소드 구현을 필요로 합니다. 또한, generate 메소드는 GeneratorType을 반환하는데 다음과 같이 정의되어 있습니다.

	protocol GeneratorType {
			typealias Element
			mutating func next() -> Element?
	}

<br/>GeneratorType은 next 메소드 구현이 필요하며, 다음 객체를 반환합니다. 따라서 GeneratorType 프로토콜을 사용하는 클래스를 작성할 수 있습니다.

	class Building {}

	class BuildingGenerator: GeneratorType {
		
		private var buildings: Array<Building>
		private var nextIndex: Int

		init(buildings: Array<Building>) {
			self.buildings = buildings
			nextIndex = buildings.count-1
		}
		
		func next() -> Building? {
			if (nextIndex < 0) {
				return nil
			}
			return self.buildings[nextIndex--]
		}
		subscript(n: Int) -> Building? {
			return n >= buildings.count ? nil : buildings[n];
		}
	}

<br/>BuildingGenerator는 다음과 같이 사용할 수 있습니다.

	let buildings = BuildingGenerator(buildings: [Building(), Building(), Building()])
	buildings.next()

<br/><br/>Iterator를 구현은 하였지만 SequenceType 프로토콜을 가지지 않기 때문에 for문에서 사용할 수 없습니다. 그래서 SequenceType과 GeneratorType을 둘다 가지는 GeneratorOf 프로토콜을 사용하여 구현할 수 있으며, 다음과 같이 정의되어 있습니다.

	struct GeneratorOf<T> : GeneratorType, SequenceType {
		init(_ nextElement: () -> T?)
		init<G : GeneratorType where T == T>(_ base: G)

		mutating func next() -> T?
		func generate() -> GeneratorOf<T>
	}

<br/>generate는 GeneratorOf를 반환하여 Sequence가 CollectionType으로 되도록 만들어 버립니다. 이번에는 GeneratorOf를 사용하여 구조체로 작성하였습니다.

	// Swift 1.x
	struct BuildingSequence<T>: SequenceType {
		var building: [T] = [T]()
		typealias Generator = GeneratorOf<T>
		
		func generate() -> Generator {
			var i = 0
			return GeneratorOf { return i >= self.building.count ? nil : self.building[i++] }
		}
	}

	// Swift 2.x
	struct BuildingSequence<T>: SequenceType {
	    var building: [T] = []
		typealias Generator = AnyGenerator<T?>

		func generate() -> Generator {
			var i = 0
			return anyGenerator {
				if i >= self.building.count {
					return nil;
				}
				else {
					return self.building[i++]
				}
			}
		}
		subscript(n: Int) -> T? {
	    	return n >= self.building.count ? nil : self.building[n];
	    }
	}

<br/>BuildingSequence는 다음과 같이 사용할 수 있습니다.

	// Swift 1.x
	let buildings = BuildingSequence(building: ["one", "two", "three"])

	for building in buildings {
		println("Building Name : \(building)")
	}

	// Swift 2.x
	let buildings = BuildingSequence(building: ["one", "two", "three"])

	for building in buildings {
		print("Building Name : \(building)")
	}

Iterator를 통해 범위에서 벗어날 경우 nil을 반환하여 안전하게 사용할 수 있도록 합니다.


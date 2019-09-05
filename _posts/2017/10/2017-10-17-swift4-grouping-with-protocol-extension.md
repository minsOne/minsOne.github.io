---
layout: post
title: "[Swift4]Protocol Extension, associatedtype, Generic을 이용하여 기능(변수, 함수)을 그룹화하기"
description: ""
category: "Programming"
tags: [Swift, Protocol, extension, associatedtype, Generic, computed, variable, function]
---
{% include JB/setup %}

Protocol Extension에 원하는 기능을 추가하는 경우 계산 속성 또는 함수들을 그룹화하여 접근하려면 다음과 같이 작성해야만 했습니다.

```
protocol TestProtocol {
	func testFunction()
}

protocol TestType {
	var test: TestProtocol { get }
}

class Test: TestProtocol, TestType {
	init() {}
	
	var test: TestProtocol { return self }

	func testFunction() {}
}

let test = Test().test
test.testFunction()
```

위 코드에서 TestProtocol에 정의된 함수를 반드시 구현해야 하거나, test 변수를 통하지 않고도 Test 객체로 접근한다면 testFunction 함수 접근 가능합니다.

위 코드는 protocol에 정의된 함수와 변수를 반드시 구현해야 한다는 장점이자 단점이 있으며, 직접 프로토콜 타입 변수를 접근하지 않고도 프로토콜에 정의된 함수나 변수를 직접 접근이 가능하다는 장점이자 단점이 있습니다.

위 코드의 단점을 해결할 수 있는 방안이 있을까요? RxSwift나 KingFisher 등의 라이브러리에서 rx, kf 등의 변수를 통해 라이브러리를 접근하도록 하고 있습니다. 어떻게 이렇게 하는지 살펴봅시다.

## 그룹화하기

첫번째로 특정 타입을 가지는 구조체를 선언하며, `Base`는 클래스를 사용하도록 var가 아닌 let으로 선언합니다.

만약 구조체를 사용하려고 한다면 var로 사용하면 됩니다.

```
struct Extension<Base> {
    let base: Base
    init(_ base: Base) {
        self.base = base
    }
}
```

그룹화할 변수를 정의하는 ExtensionCompatible 프로토콜을 선언하고, Base에는 어떤 타입일지 모르기 때문에 associatedtype을 사용합니다. static var는 static 변수나 함수가 필요한 경우 추가하면 됩니다.

```
protocol ExtensionCompatible {
    associatedtype Compatible
    var ex: Extension<Compatible> { get set }
    static var ex: Extension<Compatible>.Type { get set }
}
```

ExtensionCompatible 프로토콜 `Extension`에 정의했던 그룹화할 변수를 구현합니다.

```
extension ExtensionCompatible {
    var ex: Extension<Self> {
        get {
            return Extension(self)
        }
        set {

        }
    }
    static var ex: Extension<Self>.Type {
        get {
            return Extension<Self>.self
        }
        set {

        }        
    }
}
```

앞에서 작성했던 Test 클래스에 `ExtensionCompatible` 프로토콜을 따르도록 하고, 값을 가지는 변수를 선언합니다.

```
class Test: ExtensionCompatible {
	var value: Int

	init(value: Int) {
		self.value = value
	}
}
```

이제 Test 클래스는 `ExtensionCompatible` 프로토콜을 따르기 때문에 앞에서 TestType 프로토콜에 정의된 TestProtocol 타입 변수처럼 `ex`를 통해서 접근이 가능합니다.

그러면 ex 변수로만 접근 가능한 함수와 변수를 만들어 봅시다.

```
extension Extension where Base == Test {
	var result: Int {
        return base.value
    }
    
    func add(value: Int) {
        base.value += value
    }
}
```

이제 우리는 ex를 통해 result라는 계산 속성, add(value:) 함수를 접근 할 수 있으며, Test 클래스의 value 값을 얻거나 수정이 가능합니다.

```
let test = Test(value: 10)
print(test.ex.result) // Output : 10
test.ex.add(value: 10)
print(test.ex.result) // Output : 20
```

따라서 Test 클래스에다 직접 변수나 함수를 정의할 필요가 없이 기능 추가가 가능합니다.

## 다중 그룹화

위의 경우는 하나만 그룹화 한 경우입니다. 만약 경우를 나눠 구현하고자 한다면 앞에서 작성한 방식과 동일하게 정의한 후, 프로토콜을 따르게 하면 됩니다. 

다음과 같이 ViewModel이라는 타입에 Input, Output 그룹화할 수 있습니다.

```
public struct ViewModelInputExtension<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol ViewModelInputExtensionCompatible {
    associatedtype Compatible
    var input: ViewModelInputExtension<Compatible> { get set }
    static var input: ViewModelInputExtension<Compatible>.Type { get set }
}

public extension ViewModelInputExtensionCompatible {
    public var input: ViewModelInputExtension<Self> {
        get {
            return ViewModelInputExtension(self)
        }
        set {
            // this enables using Extension to "mutate" base object
        }
    }
    public static var input: ViewModelInputExtension<Self>.Type {
        get {
            return ViewModelInputExtension<Self>.self
        }
        set {
            // this enables using Extension to "mutate" base type
        }
    }
}

public struct ViewModelOutputExtension<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol ViewModelOutputExtensionCompatible {
    associatedtype Compatible
    var output: ViewModelOutputExtension<Compatible> { get set }
    static var output: ViewModelOutputExtension<Compatible>.Type { get set }
}

public extension ViewModelOutputExtensionCompatible {
    public var output: ViewModelOutputExtension<Self> {
        get {
            return ViewModelOutputExtension(self)
        }
        set {
            // this enables using Extension to "mutate" base object
        }
    }
    public static var output: ViewModelOutputExtension<Self>.Type {
        get {
            return ViewModelOutputExtension<Self>.self
        }
        set {
            // this enables using Extension to "mutate" base type
        }
    }
}

class ViewModel: ViewModelOutputExtensionCompatible, ViewModelInputExtensionCompatible {}

let vm = ViewModel()
vm.input
vm.output
```

## 참고

* [RxSwift issue - \[RxCocoa\] Move from `rx_` prefix to a `rx.` proxy (for Swift 3 update ?)](https://github.com/ReactiveX/RxSwift/issues/826)
* [Jérôme Alves - Safe collection subscripting in Swift](https://medium.com/@jegnux/safe-collection-subsripting-in-swift-3771f16f883)
* [KingFisher](https://github.com/onevcat/Kingfisher)
* [WorldDownTown/ExtensionCompatibleSample.swift](https://gist.github.com/WorldDownTown/3e0ac74b0add9b22f9188421de608d1a)
* [Natasha The Robot - Using Swift Extensions The “Wrong” Way](https://www.natashatherobot.com/using-swift-extensions/)

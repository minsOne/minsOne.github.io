---
layout: post
title: "[Swift] 다른 이름의 프로토콜에서 같은 이름의 속성과 함수를 가질때 '@_implements' 속성을 이용하여 해결하기"
tags: [Swift, "@_implements", Protocol]
---
{% include JB/setup %}

우리는 아주 가끔 특정 프로토콜에서 정의된 속성과 함수 이름이 다른 프로토콜과 겹칠 때가 있습니다.

```swift
/// Module: Alpha

public protocol ServiceInterface {
  var value: Int { get set }
  func update()
  func update(value: Int)
}

/// Module: Beta

public protocol ServiceInterface {
  var value: String { get set }
  func update()
  func update(value: Int)
}
```

위와 같이 두 모듈에서 선언된 프로토콜 `ServiceInterface`은 `value` 라는 속성의 타입만 다를 뿐입니다.

그러면 이를 구현하는 타입에서 update 함수는 동일하니 정의할 순 있지만, value 속성은 Int, String 타입을 둘다 가져야 하는데, 컴파일러에서 이를 지원해주지 않습니다.

```swift
/// Module: App

struct ServiceImpl: Alpha.ServiceInterface, Beta.ServiceInterface {
  var value: Int
  var value: String

  func update() {}
  func update(value: Int) {}
}
```

위 코드는 에러가 발생합니다.

그러면 일반적인 방법은 두 프로토콜을 나누어 각 프로토콜을 준수하는 타입을 만들고, 해당 타입을 속성으로 가지는 방식이 있습니다.

```swift
/// Module: App

struct AlphaServiceImpl: Alpha.ServiceInterface {
  var value: Int = 10
  func update() {}
  func update(value: Int) {}
}

struct BetaServiceImpl: Beta.ServiceInterface {
  var value: String = "10"
  func update() {}
  func update(value: Int) {}
}

struct Service {
    let alphaService: Alpha.ServiceInterface
    let betaService: Beta.ServiceInterface
}

let service = Service(alphaService: AlphaServiceImpl(), 
                      betaService: BetaServiceImpl())
```

## **@_implements**를 이용하여 다른 이름으로 호출하기

<br/>

Swift에서 비공식적으로 지원하는 [`@_implements`](https://github.com/apple/swift/blob/main/docs/ReferenceGuides/UnderscoredAttributes.md#_implementsprotocolname-requirement) 속성을 이용하여 다른 이름으로 불릴 수 있게 할 수 있습니다.

```swift
/// Module: App

class ServiceImpl: Alpha.ServiceInterface, Beta.ServiceInterface {
  @_implements(Alpha.ServiceInterface, value)
  var value_Alpha: Int = 2022

  @_implements(Alpha.ServiceInterface, update())
  func update_Alpha() {
    print(#function)
  }

  @_implements(Alpha.ServiceInterface, update(value:))
  func update_Alpha(value: Int) {
    print(#function, value)
    value_Alpha = value
  }

  @_implements(Beta.ServiceInterface, value)
  var value_Beta: String = "2022"

  @_implements(Beta.ServiceInterface, update())
  func update_Beta() {
    print(#function)
  }

  @_implements(Beta.ServiceInterface, update(value:))
  func update_Beta(value: Int) {
    print(#function, value)
    value_Beta = "\(value)"
  }
}
```

컴파일러가 중간에서 바꿔치기 때문에 사용할때, 명시적인 타입을 사용해야 의도한 대로 동작하게 됩니다.

```swift
let serviceAlpha: Alpha.ServiceInterface = ServiceImpl()
print(serviceAlpha.value) // Output : Int(2022)
serviceAlpha.update() // Output : update_Alpha()
serviceAlpha.update(value: 2023) // Output : update_Alpha(value:) 2023
print(serviceAlpha.value) // Output : Int(2023)

let serviceBeta: Beta.ServiceInterface = ServiceImpl()
print(serviceBeta.value) // Output : "2022"
serviceBeta.update() // Output : update_Beta()
serviceBeta.update(value: 2023) // Output : update_Beta(value:) 2023
print(serviceBeta.value) // Output : "2023"



let service = ServiceImpl()
print(service.value) // ❌ value_Alpha, value_Beta 속성을 접근해야 함
print(service.value_Alpha, service.value_Beta) // 🟢 Output: 2022 2022

service.update() // ❌ update_Alpha(), update_Beta() 함수를 사용해야 함
service.update_Alpha() // 🟢 Output: update_Alpha()

service.update(value: 2023) // ❌ update_Alpha(value:), update_Beta(value:) 함수를 사용해야 함
service.update_Beta(value: 2023) // 🟢 Output : update_Beta(value:) 2023
```

<br/>

## 참고자료

* Github
  * [apple/swift - UnderscoredAttributes](https://github.com/apple/swift/blob/main/docs/ReferenceGuides/UnderscoredAttributes.md)
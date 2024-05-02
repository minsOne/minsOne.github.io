---
layout: post
title: "[Swift] 타입 시스템을 활용하여 보다 안전하게 데이터 유효성 검증하기"
tags: [Swift, Type-Safe, Validation]
---
{% include JB/setup %}

데이터 유효성 검증은 소프트웨어 개발에서 필수적인 부분입니다. 잘못된 데이터가 시스템으로 들어가는 것을 방지하고, 안전한 상태를 유지하기 위해 필수적입니다. 그러나 코드를 작성하다 보면 많은 유효성 검증 로직을 작성하게 되어 코드가 복잡해지고 유지보수가 어려워지는 경우가 있습니다.

예를 들어, 이름과 나이를 전달받아 유효성을 검증하는 코드를 작성한다고 가정해봅시다.

```swift
func register(name: String, age: Int) {
  guard !name.isEmpty, age > 0 else { return }

  service.register(name: name, age: age)
}
```

위의 코드에서는 이름과 나이를 검증하고 있지만, 이러한 검증 로직이 함수 내에 있어 히스토리 없이 수정하거나 삭제하는 경우 서비스의 register 함수를 검증 없이 호출할 수 있는 문제가 발생할 수 있습니다.

우리는 Swift에서 제공하는 강력한 타입 시스템을 활용하여 이러한 일반적인 실수를 방지하고 안전한 데이터 유효성 검증을 수행할 수 있습니다.

## Custom Initialization을 통한 유효성 검증

생성자를 사용하여 값이나 객체가 생성될 때 데이터의 유효성을 검증할 수 있습니다. 생성자 내에서 필요한 유효성 검사를 수행하여 잘못된 데이터로 객체가 생성되는 것을 방지할 수 있습니다.

예를 들어, 입력된 이름과 나이를 유효성 검사하는 코드를 다음과 같이 작성할 수 있습니다.

```swift
struct UserName {
  let rawValue: String
  init?(_ name: String) {
    guard !name.isEmpty else { return nil }
    rawValue = name
  }
}

struct UserAge {
  let rawValue: Int
  init?(_ age: Int) {
    guard age > 0 else { return nil }
    rawValue = age
  }
}
```

위의 코드에서 `UserName`과 `UserAge` 구조체의 생성자를 통해 각각의 유효성을 검사합니다. 옵셔널을 반환하는 생성자는 잘못된 데이터로 값이 생성되지 않도록 보장합니다.

`UserName`과 `UserAge`를 조합하여 `User` 구조체를 통해 유효성 검증을 수행할 수 있습니다.

```swift
struct User {
  let name: String
  let age: Int

  init?(name: String, age: Int) {
    guard 
      let name = UserName(name), 
      let age = UserAge(age) 
    else { return nil }

    self.name = name.rawValue
    self.age = age.rawValue
  }
}
```

위의 코드에서는 User 구조체를 통해 초기화될 때 입력된 값의 유효성을 검사합니다. 이를 통해 사용자는 유효한 상태의 값이 생성될 것임을 쉽게 예측할 수 있습니다.

`register` 함수를 업데이트하여 `User` 생성자를 사용하도록 변경할 수 있습니다.

```swift
func register(name: String, age: Int) {
  guard let user = User(name: name, age: age) else { return }

  service.register(name: user.name, age: user.age)
}
```

위의 코드에서는 User 값을 생성할 때 필요한 모든 로직을 생성자 내부에 캡슐화하여 사용자가 유효한 상태의 값이 생성될 것임을 보장합니다. 이는 코드의 이해를 돕고, 다른 개발자들이 코드를 빠르게 이해할 수 있도록 도와줍니다.

또한, 초기화 로직이 한 곳에 모여 있어 변경 사항이 생겼을 때 수정할 부분을 쉽게 찾을 수 있으며, 데이터의 유효성을 보다 확실히 검증할 수 있도록 테스트를 작성할 수 있습니다.

타입 확장(Extensions)을 활용하여 유효성 검사 로직을 추가할 수도 있지만, 해당 타입에 결합되므로 주의가 필요합니다. 

## 정리

Swift의 타입 시스템을 활용하여 데이터 유효성을 검증하는 것은 코드의 안전성을 높이고 버그를 줄이는 데 도움이 됩니다. Custom Initialization을 통해 생성자 내에서 유효성 검사를 수행하면 객체가 생성될 때마다 데이터의 유효성을 보장할 수 있습니다. 이는 코드의 신뢰성을 높이고 유지보수성을 향상시킵니다. 데이터의 유효성을 보장하기 위해 타입 시스템을 적극적으로 활용하는 것은 안정성과 확장성 있는 애플리케이션을 개발하는 데 중요한 요소입니다.

## 참고자료

* [Type-safe validation](https://swiftology.io/articles/tydd-part-2/)
* [Environment variables type safety and validation with Zod](https://creatures.dev/blog/env-type-safety-and-validation/)
* [Wikipedia - Type safety](https://en.wikipedia.org/wiki/Type_safety)
* [Type-Safe TypeScript With Type Narrowing](https://betterprogramming.pub/type-safe-typescript-with-type-narrowing-649450d708df)
* [Validate with Fluent Validations in .NET (C#)](https://medium.com/codenx/code-with-fluent-validations-in-net-c-da2fb517566d)

* GitHub
  * [donflopez/ttype-safe](https://github.com/donflopez/ttype-safe)


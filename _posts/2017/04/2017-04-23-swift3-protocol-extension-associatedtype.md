---
layout: post
title: "[Swift3]Protocol, Extension, AssociatedType 다루기"
description: ""
category: ""
tags: [swift, protocol, extension, associatedType]
---
{% include JB/setup %}

Swift에서는 프로토콜 지향 프로그래밍을 지원하는 언어로, Protocol에 변수, 함수를 규약합니다.

```
protocol A {
    var name: String { get set }
    mutating func set(name: String)
}
```

위의 A라는 프로토콜은 변수 name와 함수 set(name:)이 선언되어 있습니다. 프로토콜 A를 따르는 타입은 변수 name, 함수 set(name:)이 반드시 정의된다고 볼 수 있으므로, 프로토콜 A를 확장(extension)할 수 있습니다.

```
extension A {
    mutating func set(name: String) {
        self.name = name
    }
}
```

변수 name의 타입은 String이므로, 동적으로 타입이 변할 수 없습니다. name의 타입을 동적으로 변하도록 하려면 Associated Type를 이용할 수 있습니다.

```
protocol A {
    associatedtype T
    var name: T { get set }
}

extension A {
    mutating func set(name: T) {
        self.name = name
    }
}
```

associatedtype은 하나 이상 프로토콜에 관련있는 타입에 이름을 지정합니다. 위에서 타입 T인 name은 하나 이상의 프로토콜을 따르므로, 프로토콜에 정의된 변수 또는 함수를 사용할 수 있습니다.

```
protocol B {}
extension B {
    var description: String {
        return "Hello world"
    }
}

protocol A {
    associatedtype T: B
    var name: T { get set }
}

extension A {
    mutating func set(name: T) {
        self.name = name
    }
    
    var description: String {
        return name.description
    }
}
```

변수 name은 타입 T이고, T는 프로토콜 B를 따르기 때문에 name은 프로토콜 B의 description을 사용할 수 있습니다. 그리고 프로토콜 B, C를 동시에 따르는 타입으로도 선언할 수 있습니다.

```
protocol B {}
extension B {
    var description: String {
        return "Hello world"
    }
}
protocol C {}
extension C {
    var debug: String {
        return "Debug"
    }
}

protocol A {
    associatedtype T: B, C
    var name: T { get set }
}

extension A {
    mutating func set(name: T) {
        self.name = name
    }
    
    var description: String {
        return name.description
    }
    var debug: String {
        return name.debug
    }
}
```

타입 T는 프로토콜 B, C를 따르므로 프로토콜 B의 description과 프로토콜 C의 debug를 변수 name에서 접근할 수 있습니다.

<br/>타입 Int를 프로토콜 B, C를 따르는 타입으로 확장합니다.

```
extension Int: B, C {}
```

프로토콜 A를 따르는 타입은 다음과 같이 선언할 수 있습니다.

```
struct AA: A {
    var name: Int
}

print(AA(name: 10).debug)
```

따라서 `associatedtype`을 잘 이용하면 Protocol Extension에서 거의 모든 것을 만들고, 해당 프로토콜을 따르기만 하는 타입을 선언만 하면 됩니다.

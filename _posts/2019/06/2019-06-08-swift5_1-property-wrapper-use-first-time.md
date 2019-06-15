---
layout: post
title: "[Swift5.1] Property Wrapper 사용 - 맛보기"
description: ""
category: "programming"
tags: [propertyWrapper, Property Wrapper, SE-0258, Swift, Annotation]
---
{% include JB/setup %}

Swift 5.1에서 Property Wrapper 라는 기능이 추가되었습니다. 이 기능은 [SE-0258](https://github.com/apple/swift-evolution/blob/master/proposals/0258-property-delegates.md) 제안으로 보여지며, Swift에 있는 [Commit](https://github.com/apple/swift/commit/c02ecf985951e6d437f54372f906799faf5d342a)으로 보았을 때 Property Delegate가 Property Wrapper로 변경되었으로 추정됩니다.

## Property Wrapper 사용 방법

```

fileprivate struct Store {
    static private var stores: [String: Any?] = [:]
    
    static func value(key: String) -> Any? {
        return stores[key] ?? nil
    }
    static func set(key: String, value: Any?) {
        stores.updateValue(value, forKey: key)
    }
}

@propertyWrapper
struct Storage<T> {
    private let key: String
    init(_ key: String) {
        self.key = key
    }
    var value: T? {
        get {
            return Store.value(key: key) as? T
        }
        set {
            Store.set(key: key, value: newValue)
        }
    }
}

class A {
	@Storage("has_visited_app")
	var hasVisitedApp: Bool?
}
```

위와 같이 Static 변수를 가진 Store 구조체에 Storage 구조체가 접근하여 값을 가져옵니다.
`@propertyWrapper`를 추가하면 타입명이 Annotation이 되며, 사용하는 변수에 Annotation을 추가하면 됩니다.

그러면 hasVisitedApp 변수를 접근해서 값을 할당하거나, 가져올 때 Storage의 value를 통해 Store에 접근하게 됩니다.

## 출처
* WWDC2019 - [What's New in Swift](https://developer.apple.com/videos/play/wwdc2019/402/)
* Swift Evolution - [SE-0258](https://github.com/apple/swift-evolution/blob/master/proposals/0258-property-delegates.md)
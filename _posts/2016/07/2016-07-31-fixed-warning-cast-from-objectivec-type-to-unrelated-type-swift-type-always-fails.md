---
layout: post
title: "[Swift][Objective-C]컴파일러 경고 해결 - Cast from objectivec type to unrelated type swift type always fails"
description: ""
category: "programming"
tags: [swift, objectivec, nullability, casting, cast, AnyObject, unrelated type, guard]
---
{% include JB/setup %}

프로젝트에서 Objective-C와 Swift를 혼용해서 쓰다 보면, Objective-C 코드의 결과 값을 Swift에서 받아 처리할 때, 모호한 경우가 있습니다.

예를 들어, Objective-C에서 `NSMutableArray<Channel *>` 값을 반환한다고 할 때 `Nullability`도 명시하지 않았다면, Swift는 `NSMutableArray!`로 판단합니다. 그리고 Swift에서 받은 값을 [Channel]로 Casting 하려고 한다면 `Cast from NSMutableArray to unrelated type [Channel] always fails`라고 컴파일러 경고가 발생합니다.

이는 Objective-C와 Swift의 명확성 차이로 인해 발생하는 문제이기도 합니다. 그러면 위의 컴파일 경고를 제거해보도록 합시다.

첫 번째로, 값이 있는지 없는지 명확해야 합니다. Objective-C에서 Nullability를 명시하지 않으면, Swift는 forced unwrapping 타입으로 받아야 합니다. 따라서 `_Nullable` 또는 `_Nonnull`을 사용하여 값이 있는지, 없는지를 명확하게 하고, 그렇지 않다면 `guard` 또는 `if let`을 사용하여 값이 있는지 없는지 확인해야 합니다.

두 번째로, Objective-C에서 NSArray, NSDictionary를 Swift 형태(ex.[Int:String], [Channel])로 명확하게 전달할 수 없습니다. 따라서 AnyObject로 Casting 한 후, 원하는 타입으로 Casting 합니다.

```swift
	// compiler warning
	guard let channels = DataManager().getData() as? [Channel] else { return }

	// fixed warning
	guard let channels = DataManager().getData() as? AnyObject as? [Channel] else { return }
```

위와 같이 사용하면 Objective-C와 Swift를 같이 사용함에 있어서 문제 없이 원하는 동작을 수행할 수 있습니다.

### 참고 자료

* [Nullability](http://minsone.github.io/mac/ios/nullability-in-objc)
* [Apple blog](https://developer.apple.com/swift/blog/?id=25)

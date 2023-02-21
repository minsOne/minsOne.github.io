---
layout: post
title: "[Swift 5.7+][Objective-C] Dependency Injection (4) - class_getName, class_getInstanceVariable, class_getSuperclass를 사용하여 특정 타입 찾기"
tags: [Swift, Dependency Injection, objc, class_getName, class_getInstanceVariable, class_getClassVariable, class_getSuperclass]
---
{% include JB/setup %}

[이전 글 - objc_getClassList를 사용하여 모든 클래스 목록 얻기]({{ site.production_url }}/ios-dicontainer-3-property-wrapper)에서 모든 클래스 목록을 얻어온 후, 타입 캐스팅을 통해 특정 프로토콜을 찾는 방법을 알아보았습니다.

```swift
classList
    .compactMap { $0 as? any SampleProtocol.Type }
```

하지만, 프로젝트 규모가 커져 코드가 많아지면 클래스 숫자도 늘어나게 됩니다. 이때 수만, 수십만의 클래스를 타입 캐스팅으로 특정 프로토콜을 찾는데는 비용이 많이 듭니다.

또한, 프로토콜을 캐스팅하는데는 성능이 느리다고 합니다. (관련 소스 분석중)

그럼 어떤 방법을 사용하면 좀 더 빠르게 타입을 찾을 수 있을까요?

타입의 이름을 얻어, 그 타입의 이름에 특정 문자가 포함된 것을 찾는 방법, 특정 이름을 변수로 가진 타입을 찾는 방법 그리고 해당 타입의 Super Class와 일치하는지를 찾는 방법 등이 있을 것입니다,

이들 방법을 한번 사용해서 타입을 찾고, 그 뒤에 캐스팅을 하면 캐스팅하는 비용이 줄어들지 않을까 합니다.

<br/>

### 1. 특정 문자열이 포함된 타입 찾기

이전 글에서 사용한 `Runtime` 코드를 사용합니다.

```swift
import Foundation

struct Runtime {
    static var classPtrInfo: (classesPtr: UnsafeMutablePointer<AnyClass>, numberOfClasses: Int)? {
        let numberOfClasses = Int(objc_getClassList(nil, 0))
        guard numberOfClasses > 0 else { return nil }

        let classesPtr = UnsafeMutablePointer<AnyClass>.allocate(capacity: numberOfClasses)
        let autoreleasingClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(classesPtr)
        let count = objc_getClassList(autoreleasingClasses, Int32(numberOfClasses))
        assert(numberOfClasses == count)

        return (classesPtr, numberOfClasses)
    }
}
```

`classPtrInfo`에서 클래스 목록을 가져와, `class_getName`을 사용하여 클래스 명을 추출하고, 특정 문자열이 포함되어 있는지 확인합니다.

```swift
struct Runtime {
    ...   
    static var classList: [any SampleProtocol.Type] {
        guard let (classesPtr, numberOfClasses) = classPtrInfo else { return [] }
        defer { classesPtr.deallocate() }

        var classes = [any SampleProtocol.Type]()

        for i in 0 ..< numberOfClasses {
            let cls: AnyClass = classesPtr[i]
            if String(cString: class_getName(cls)).lowercased().contains("sample"),
            case let cls as any SampleProtocol.Type = cls {
                classes.append(cls)
            }
        }

        return classes
    }
}
```

`class_getName`([Source Code](https://github.com/apple-oss-distributions/objc4/blob/689525d556eb3dee1ffb700423bccf5ecc501dbf/runtime/objc-runtime-new.mm#L6234))는 demangleName을 가져와 사용하므로, 비용이 비싸지 않습니다. 따라서 문자열 비교한 후, 타입 캐스팅을 하니 타입 캐스팅 할 일이 줄어들어 비용이 줄어듭니다.

하지만, 클래스 이름에 `sample` 문자열이 포함되어 있지 않은 타입이라면, 해당 조건에 만족하지 못하고 찾는데 실패합니다. 

`SampleProtocol` 프로토콜을 채택한 타입 이름의 규칙이 있다면 위와 같은 방식도 괜찮을 수 있습니다.

### 2. 특정 이름을 변수로 가진 타입 찾기

`class_getInstanceVariable`을 이용하여 특정 이름을 가진 변수가 있는지 확인할 수 있습니다. 이를 이용한다면, 먼저 해당 함수로 특정 이름을 가진 변수가 있는지 확인 후, 캐스팅 하면 비용이 줄어들 것입니다.

```swift
struct Runtime {
    ...   
    static var classList: [any SampleProtocol.Type] {
        guard let (classesPtr, numberOfClasses) = classPtrInfo else { return [] }
        defer { classesPtr.deallocate() }

        var classes = [any SampleProtocol.Type]()
        let key = "isSample"

        for i in 0 ..< numberOfClasses {
            let cls: AnyClass = classesPtr[i]
            if let _ = class_getInstanceVariable(cls, key),
            case let cls as any SampleProtocol.Type = cls {
                classes.append(cls)
            }
        }

        return classes
    }
}
```

`class_getName`를 사용했던 위의 코드와 거의 유사하게 코드가 작성되었습니다. `class_getInstanceVariable`([Source Code](https://github.com/apple-oss-distributions/objc4/blob/689525d556eb3dee1ffb700423bccf5ecc501dbf/runtime/objc-class.mm#L606))는 실제로 `_class_getVariable`([Source Code](https://github.com/apple-oss-distributions/objc4/blob/689525d556eb3dee1ffb700423bccf5ecc501dbf/runtime/objc-runtime-new.mm#L7418))를 사용하고 있고, 해당 이름을 가진 변수가 있는지 확인후, 없으면 super class에 가서 찾는 재귀방식을 취하고 있습니다.

상속 받은 클래스가 적은 경우는 괜찮지만, 많은 경우는 `class_getName` 보다 비싼 비용을 지불해야 됩니다. 따라서 좋은 방법이라고 하긴 어렵습니다.

유사하게 클래스 변수를 찾는 `class_getClassVariable` 함수도 있으나 방식은 동일합니다.

### 3. 해당 타입의 Super Class와 일치한 타입 찾기

위의 두 방식은 키를 문자열로 만들어 비교하도록 하는 방식이었습니다. 강타입의 특성을 활용하기 어려운 방식으로, 이름이 바뀌게 되면 해당 방식으로는 원하는 타입을 찾을 수 없습니다.

특정 클래스를 상속받도록 만들면 우리가 원하는 타입을 찾을 수 있지 않을까요?

```swift
open class SampleScanType {
    public init() {}
}

public typealias SampleType = SampleScanType & SampleProtocol
```

`SampleScanType` 클래스와 `SampleProtocol` 프로토콜을 상속받고 채택할 타입인 `SampleType`을 만들고, 이 타입을 채택하도록 합니다.

```swift
class SampleSub: SampleType {}
```

아까 클래스 목록을 얻는 코드에서 `SampleProtocol` 프로토콜을 채택한 타입을 찾아봅시다.

```swift
struct Runtime {
    ...   
    static var classList: [any SampleProtocol.Type] {
        guard let (classesPtr, numberOfClasses) = classPtrInfo else { return [] }
        defer { classesPtr.deallocate() }

        let superCls = SampleScanType.self
        var classes = [any SampleProtocol.Type]()

        for i in 0 ..< numberOfClasses {
            let cls: AnyClass = classesPtr[i]
            if class_getSuperclass(cls) == superCls,
            case let cls as any SampleProtocol.Type = cls {
                classes.append(cls)
            }
        }

        return classes
    }
}
```

클래스에서 Super Class의 타입을 얻어와, 준비했던 Super Class와 타입이 일치하는지 비교를 합니다. `class_getSuperclass`([Source Code](https://github.com/apple-oss-distributions/objc4/blob/689525d556eb3dee1ffb700423bccf5ecc501dbf/runtime/objc-class.mm#L799))는 Super Class가 있으면 해당 Super Class 타입을 주고, 없으면 nil을 반환하며, 준비했던 Super Class와 비교를 하니 타입 캐스팅을 덜 하게 되어 비용이 줄어듭니다.

또한, 별도의 문자열이 아닌, 강타입 언어의 특성을 활용했기 때문에 안전하게 클래스 목록을 얻을 수 있습니다.


## 참고자료

* Medium
  * [The Surprising Cost of Protocol Conformances in Swift](https://medium.com/geekculture/the-surprising-cost-of-protocol-conformances-in-swift-dfa5db15ac0c)

* Swift Forum
  * [Understanding code that leads to swift::_checkGenericRequirements calls](https://forums.swift.org/t/understanding-code-that-leads-to-swift-checkgenericrequirements-calls/35128)

* GitHub
  * [Apple/Swift](https://github.com/apple/swift)
    * [Docs - Dynamic Casting Behavior](https://github.com/apple/swift/blob/main/docs/DynamicCasting.md)
    * [DynamicCast.cpp](https://github.com/apple/swift/blob/main/stdlib/public/runtime/DynamicCast.cpp)
    * [Casting.cpp](https://github.com/apple/swift/blob/main/stdlib/public/runtime/Casting.cpp)
  * [apple-oss-distributions/objc4](https://github.com/apple-oss-distributions/objc4)


---
layout: post
title: "[Swift 5.7+][Objective-C] Dependency Injection (3) - objc_getClassList를 사용하여 모든 클래스 목록 얻기"
tags: [Swift, Dependency Injection, objc, objc_getClassList, UnsafeMutablePointer, AutoreleasingUnsafeMutablePointer, class_getName]
---
{% include JB/setup %}

이번 글에서는 모든 클래스 목록을 알아보도록 하겠습니다. Swift 언어에서는 모듈을 import 하지 않고는 타입을 알 수 없으며, 타입 정보를 동적으로도 얻을 수 없습니다. 

Swift만 사용한다면 강타입 언어로서 그럴 수 있지만, iOS, MacOS 등의 환경에서 사용하는 Swift는 조금 다른 의미를 지닙니다. Foundation 모듈과 Objective-C를 적절히 이용하면 모든 클래스 목록을 추출할 수 있습니다.

## Objective-C Runtime

[Objective-C Runtime 도큐먼트](https://developer.apple.com/documentation/objectivec)를 보면 Objective-C 런타임 및 Objective-C 루트 유형의 low-level에 접근할 수 있습니다.

이 중에서 [objc_getClassList](https://developer.apple.com/documentation/objectivec/1418579-objc_getclasslist)를 한번 살펴봅시다.

`objc_getClassList` 함수는 등록된 클래스 정의 목록을 얻을 수 있다고 합니다.

```objectivec
int numClasses;
Class * classes = NULL;
 
classes = NULL;
numClasses = objc_getClassList(NULL, 0);
 
if (numClasses > 0 )
{
    classes = malloc(sizeof(Class) * numClasses);
    numClasses = objc_getClassList(classes, numClasses);
    free(classes);
}
```

위 코드를 Swift 버전으로 변경해봅시다. 

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

위 함수에서 클래스 포인터와 클래스 개수를 얻어낼 수 있었습니다.

그러면 해당 함수에서 얻은 포인터와 클래스 개수를 활용하여 모든 클래스 목록을 얻어봅시다.

```swift
struct Runtime {
    ...   
    static var classList: [AnyClass] {
        guard let (classesPtr, numberOfClasses) = classPtrInfo else { return [] }
        defer { classesPtr.deallocate() }
        return (0 ..< numberOfClasses).map { classesPtr[$0] }
    }
}
```

이렇게 얻은 클래스 목록은 다음과 같습니다.

```swift
dump(Runtime.classList)
```

```
▿ 31204 elements
  - NSLeafProxy #0
  - Object #1
  - __NSGenericDeallocHandler #2
  - __NSAtom #3
  - _NSZombie_ #4
  - __NSMessageBuilder #5
  - ISOverlayEmbossedFolder #6
  - ISEmbossedSmartFolder #7
  - ISEmbossedFolder #8
  - JSExport #9
  - NSProxy #10
  - NSUndoManagerProxy #11
  - NSProtocolChecker #12
  - _UITargetedProxy #19
  - _UIViewServiceUIBehaviorProxy #20
  - _UIViewServiceReplyControlTrampoline #21
  - _UIViewServiceReplyAwaitingTrampoline #22
  - _UIViewServiceImplicitAnimationDecodingProxy #23
  - _UIViewServiceImplicitAnimationEncodingProxy #24
  - _UIViewControllerControlMessageDeputy #25
  - _UIViewServiceViewControllerDeputy #26
  - _UIQueueingProxy #27
  ...
  - UIKit.(unknown context at $12066ea74)._UICustomContentConfiguration #160126
  - Foundation.(unknown context at $120a1f3d0)._CombineRunLoopAction #160127
  - Foundation.NSKeyValueObservation.(unknown context at $1209f8f28).Helper #160128
  - Foundation.NSKeyValueObservation #160129
  - Foundation.(unknown context at $1209f8df8).__KVOKeyPathBridgeMachinery.BridgeKey #160130
  - Foundation.(unknown context at $1209f8df8).__KVOKeyPathBridgeMachinery #160131
  ...
  - OS_xpc_double #181193
  - OS_xpc_bool #181194
  - OS_xpc_null #181195
  - OS_xpc_service #181196
  - OS_xpc_connection #181197
  - UTType #181198
  - _UTTaggedType #181199
  - _UTConstantType #181200
  - _UTRuntimeConstantType #181201
  - _UTCoreType #181202
  - MXMInstrument #181203
```

언어, OS 프레임워크 등의 클래스 목록을 얻을 수 있으며, `unknown context`인 클래스는 Private 클래스로 숨겨진 클래스도 얻을 수 있습니다.

그렇다면, 우리가 만든 타입도 찾을 수 있을꺼라 생각됩니다. [`class_getName`](https://developer.apple.com/documentation/objectivec/1418635-class_getname) 함수를 활용하여 추출한 클래스 목록에서 일치하는 클래스를 찾아봅시다.

```swift
class SampleClass {
    static func output() {
        print("Hello", Self.self)
    }
}

let list = Runtime.classList
    .filter { class_getName($0) == class_getName(SampleClass.self) }
    .compactMap { $0 as? SampleClass.Type }

dump(list)
// Output : ▿ 1 element
//          - ModuleName.SampleClass #0

list.forEach { $0.output() }
// Output : Hello SampleClass
```

모듈에 SampleClass 이름을 가진 클래스는 하나 밖에 없기 때문에, filter를 통해 일치하는 클래스는 하나만 존재하는 것을 확인할 수 있습니다.

---

추출한 클래스 목록에서 특정 클래스를 찾을 수 있다면 특정 프로토콜을 채택한 타입도 찾을 수 있지 않을까요?

```swift
protocol SampleProtocol: AnyObject {
    associatedtype Value
    static func output()
} 

class SampleClassInt: SampleProtocol {
    typealias Value = Int
    static func output() {
        print("Hello", Self.self, Value.self)
    }
}

class SampleClassString: SampleProtocol {
    typealias Value = String
    static func output() {
        print("Hello", Self.self, Value.self)
    }
}
```

SampleProtocol을 채택한 클래스를 찾아봅시다.

```swift
let list = Runtime.classList
    .compactMap { $0 as? any SampleProtocol.Type }

dump(list)
// Output : 
//   ▿ 2 element
//     - ModuleName.SampleClassString #0
//     - ModuleName.SampleClassInt #1

list.forEach { $0.output() }
// Output : 
///  Hello SampleClassString String
///  Hello SampleClassInt Int
```

compactMap으로 타입 캐스팅을 통해서 SampleProtocol을 채택한 클래스를 쉽게 찾을 수 있었습니다.

## 참고자료

* Apple 
  * [Objective-C Runtime](https://developer.apple.com/documentation/objectivec)

* GitHub
  * [ionic-team/capacitor](https://github.com/ionic-team/capacitor/blob/main/ios/Capacitor/Capacitor/CapacitorBridge.swift)
  * [nihp-public/covid-19-app-ios-ag-public](https://github.com/nihp-public/covid-19-app-ios-ag-public/blob/master/NHS-COVID-19/Core/Sources/Scenarios/Runner/ScenarioId.swift)
  * [krzysztofzablocki/Traits](https://github.com/krzysztofzablocki/Traits/blob/master/Traits/Classes/Traits/Trait.swift)
  * [Bob-Playground/Dynamic-Icon-Demo](https://github.com/Bob-Playground/Dynamic-Icon-Demo/blob/master/Dynamic-Icon-Demo/Awake.swift)
  * [sushinoya/lumos](https://github.com/sushinoya/lumos/blob/master/Lumos/Lumos/Sources/RuntimeQueries.swift)
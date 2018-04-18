---
layout: post
title: "[Swift4] KeyPath Get Set 그리고 Observe 사용하기"
description: ""
category: "Programming"
tags: [Swift, KeyPath, KeyValue, NSKeyValueObservation, NSObject]
---
{% include JB/setup %}

## KeyPath를 이용한 Get Set

Swift에서는 KeyPath를 String 형태가 아닌 `KeyPath` 클래스를 이용하여 정적으로 접근할 수 있습니다.

```
struct A {
	var b: Int = 0
}
```

다음과 같은 구조체 A가 있는 경우, KeyPath를 이용하여 값을 변경하거나 접근할 수 있습니다.

```
var a = A()
a[keyPath: \A.b] = 10
print(a.b) // Output 10
print(a[keyPath: \A.b]) // Output 10
```

또한 KeyPath는 Observe도 제공하는데, 타입이 클래스이며, `NSObject`를 상속받아야 합니다. 그리고 관측할 속성은 `@objc dynamic` 키워드를 추가해줘야 합니다.

```
class A: NSObject {
    @objc dynamic var b = 0
}
```

또는 `@objc`를 속성마다 붙이기 귀찮다면 클래스 앞에 `@objcMembers`를 붙여주면 `@objc`를 붙이지 않아도 됩니다.

```
@objcMembers class A: NSObject {
    dynamic var b = 0
}
```

## KeyPath를 이용한 Observation

클래스 A의 속성 i는 KeyPath Observe를 이용하여 값이 변경시 관측할 수 있습니다.

```
var a = A()
let observation: NSKeyValueObservation = A().observe(\.b, options: [.initial, .old, .new]) { (a, change) in 
	print(a, change.oldValue, change.newValue)
}
a.b = 1
a.b = 2
a.b = 3
```

초기값, 변경전 값, 변경후 값을 얻을 수 있습니다.  하지만 `NSKeyValueObservation`을 저장하지 않는다면 deinit 되면서 관측이 해제 됩니다.

RxSwift의 `DisposeBag`를 착안하여 관측하는 변수에 `NSKeyValueObservation` 를 담아두는 방식을 취하면 어떨까 합니다.

### KeyPath Observation의 DisposeBag

KeyPath Observation의 Disposable를 위한 프로토콜 `KeyPathObservationDisposable`을 만듭니다.

```
protocol KeyPathObservationDisposable {

    /// Dispose the signal observation or binding.
    func dispose()

    /// Returns `true` is already disposed.
    var isDisposed: Bool { get }
}
```

그리고 `NSKeyValueObservation` 클래스는 `KeyPathObservationDisposable`를 따르며, dispose시 `invalidate()`를 호출하여 관측을 해제시킵니다.

```
extension NSKeyValueObservation: KeyPathObservationDisposable {
    func dispose() {
        self.invalidate()
    }

    var isDisposed: Bool {
        return observationInfo == nil
    }
}
```

그리고 `KeyPathObservationDisposable`를 담기 위한 `KeyPathObservationDisposeBag`를 만듭니다.

```
protocol KeyPathObservationDisposeBagProtocol: KeyPathObservationDisposable {
    func add(disposable: KeyPathObservationDisposable)
}

class KeyPathObservationDisposeBag: KeyPathObservationDisposeBagProtocol {
    private var disposables: [KeyPathObservationDisposable] = []

    func add(disposable: KeyPathObservationDisposable) {
        disposables += [disposable]
    }

    func dispose() {
        disposables.forEach { $0.dispose() }
        disposables.removeAll()
    }

    var isDisposed: Bool {
        return disposables.isEmpty
    }

    deinit {
        dispose()
    }
}
extension KeyPathObservationDisposable {
    func dispose(in disposeBag: KeyPathObservationDisposeBagProtocol) {
        disposeBag.add(disposable: self)
    }
}
```

이제 `KeyPathObservationDisposeBag`를 가지게 되는 프로토콜 `KeyPathObservationDeallocatable`을 만듭니다. 이때 associatedObject를 이용합니다.

```
// AssociatedObjectStore 소스 출처 : https://github.com/ReactorKit/ReactorKit
protocol AssociatedObjectStore {}

extension AssociatedObjectStore {
    func associatedObject<T>(forKey key: UnsafeRawPointer) -> T? {
        return objc_getAssociatedObject(self, key) as? T
    }

    func associatedObject<T>(forKey key: UnsafeRawPointer, default: @autoclosure () -> T) -> T {
        if let object: T = self.associatedObject(forKey: key) {
            return object
        }
        let object = `default`()
        self.setAssociatedObject(object, forKey: key)
        return object
    }

    func setAssociatedObject<T>(_ object: T?, forKey key: UnsafeRawPointer) {
        objc_setAssociatedObject(self, key, object, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

protocol KeyPathObservationDeallocatable: class, AssociatedObjectStore {
    var keyPathDisposeBag: KeyPathObservationDisposeBag { get }
}

private var keyPathObservationDisposeBagKey = "KeyPathObservationDisposeBagKey"

extension KeyPathObservationDeallocatable {
    var keyPathDisposeBag: KeyPathObservationDisposeBag {
        return self.associatedObject(forKey: &keyPathObservationDisposeBagKey, default: KeyPathObservationDisposeBag())
    }
}
```

`AssociatedObjectStore`는 [ReactorKit 프로젝트](https://github.com/ReactorKit/ReactorKit)에서 발췌하였습니다.

이제 앞에서 정의했던 클래스 A는 다음과 같이 사용됩니다.

```
@objcMembers class A: NSObject, KeyPathObservationDeallocatable {
    dynamic var b = 0
}

let model = A()

model.observe(\.b, options: [.initial, .old, .new]) { (model, change) in }
    .dispose(in: model.keyPathDisposeBag)
```

그리고 model의 생성주기에 Observation이 따르므로, model에 `keyPathDisposeBag`에 KeyPathObservation을 추가하는 것을 숨길 수 있습니다.

```
extension KeyPathObservationDeallocatable where Self: NSObject {
    func subscribe<T>(keyPath: KeyPath<Self, T>,
                      options: NSKeyValueObservingOptions,
                      changeHandler: @escaping (Self, NSKeyValueObservedChange<T>) -> Void) {
        self.observe(keyPath, options: options, changeHandler: changeHandler).dispose(in: keyPathDisposeBag)
    }
}

model.subscribe(\.b, options: [.initial, .old, .new]) { (model, change) in }
```

### KeyPath Observe의 Capture list

observe 함수의 인자 중 `changeHandler`는 클로저이므로, `self`를 쓰기 위해선 Capture list를 사용해야합니다. 예를 들면 다음과 같이 작성해야 합니다.

```
model.observe(\.b, options: [.initial, .old, .new]) { [weak self] (model, change) in }
    .dispose(in: model.keyPathDisposeBag)
```

레퍼런스 타입인 경우, 메모리 릭을 유의해야 하므로, `weak` 또는 `unowned`를 사용해야 하는데, 항상 nil 체크를 해야되는 문제가 있습니다. 그래서 다음과 같이 사용해보면 어떨까 합니다.

```
model.observe(\.b, options: [.initial, .old, .new]) { (`self, model, change) in }
    .dispose(in: model.keyPathDisposeBag)
```

이를 위해 ReactiveKit의 [Bond](https://github.com/DeclarativeHub/Bond)의 `KeyPath Signal`부분과 [Delegated](https://github.com/dreymonde/Delegated) 프로젝트의 부분들을 일부 차용해보았습니다.

```
extension KeyPathObservationDeallocatable where Self: NSObject {
    func target<Target: AnyObject, T>(to target: Target,
                                      keyPath: KeyPath<Self, T>,
                                      options: NSKeyValueObservingOptions,
                                      changeHandler: @escaping (Target, Self, NSKeyValueObservedChange<T>) -> Void) {
        self.observe(keyPath, options: options) { [weak target] (`self`, change) in
            guard let target = target else { return }
            changeHandler(target, `self`, change)
        }.dispose(in: keyPathDisposeBag)
    }
}
```

기존 코드에서 확장하는 방식이므로, ex로 접근하여 사용하도록 그룹화하였습니다. 그리고 `changeHandler`에서 Capture되지 않도록 하였습니다.

위 코드는 다음과 같이 사용할 수 있습니다.

```
model.target(to: self, keyPath: \.b, options: [.initial, .old, .new]) { (`self`, model, change) in }
```

<details>
    <summary>다음은 전체 코드입니다.</summary>
    
```
import ObjectiveC

protocol AssociatedObjectStore {}

extension AssociatedObjectStore {
    func associatedObject<T>(forKey key: UnsafeRawPointer) -> T? {
        return objc_getAssociatedObject(self, key) as? T
    }

    func associatedObject<T>(forKey key: UnsafeRawPointer, default: @autoclosure () -> T) -> T {
        if let object: T = self.associatedObject(forKey: key) {
            return object
        }
        let object = `default`()
        self.setAssociatedObject(object, forKey: key)
        return object
    }

    func setAssociatedObject<T>(_ object: T?, forKey key: UnsafeRawPointer) {
        objc_setAssociatedObject(self, key, object, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

protocol KeyPathObservationDisposeBagProtocol: KeyPathObservationDisposable {
    func add(disposable: KeyPathObservationDisposable)
}

final class KeyPathObservationDisposeBag: KeyPathObservationDisposeBagProtocol {
    private var disposables: [KeyPathObservationDisposable] = []

    func add(disposable: KeyPathObservationDisposable) {
        disposables += [disposable]
    }

    func dispose() {
        disposables.forEach { $0.dispose() }
        disposables.removeAll()
    }

    var isDisposed: Bool {
        return disposables.isEmpty
    }

    deinit {
        dispose()
    }
}
extension KeyPathObservationDisposable {
    func dispose(in disposeBag: KeyPathObservationDisposeBagProtocol) {
        disposeBag.add(disposable: self)
    }
}


protocol KeyPathObservationDeallocatable: class, AssociatedObjectStore {
    var keyPathDisposeBag: KeyPathObservationDisposeBag { get }
}

private var keyPathObservationDisposeBagKey = "KeyPathObservationDisposeBagKey"

extension KeyPathObservationDeallocatable {
    var keyPathDisposeBag: KeyPathObservationDisposeBag {
        return self.associatedObject(forKey: &keyPathObservationDisposeBagKey, default: KeyPathObservationDisposeBag())
    }
}

protocol KeyPathObservationDisposable {

    /// Dispose the signal observation or binding.
    func dispose()

    /// Returns `true` is already disposed.
    var isDisposed: Bool { get }
}

extension NSKeyValueObservation: KeyPathObservationDisposable {
    func dispose() {
        self.invalidate()
    }

    var isDisposed: Bool {
        return observationInfo == nil
    }
}

extension KeyPathObservationDeallocatable where Self: NSObject {
    func subscribe<T>(keyPath: KeyPath<Self, T>,
                      options: NSKeyValueObservingOptions,
                      changeHandler: @escaping (Self, NSKeyValueObservedChange<T>) -> Void) {
        self.observe(keyPath, options: options, changeHandler: changeHandler).dispose(in: keyPathDisposeBag)
    }

    func target<Target: AnyObject, T>(to target: Target,
                                      observe keyPath: KeyPath<Self, T>,
                                      options: NSKeyValueObservingOptions,
                                      changeHandler: @escaping (Target, Self, NSKeyValueObservedChange<T>) -> Void) {
        self.observe(keyPath, options: options) { [weak target] (`self`, change) in
            guard let target = target else { return }
            changeHandler(target, `self`, change)
        }.dispose(in: keyPathDisposeBag)
    }
}
```

</details><br/>



## 참고자료

* [ReactiveKit](https://github.com/DeclarativeHub/ReactiveKit)
* [Bond](https://github.com/DeclarativeHub/Bond)
* [ReactorKit](https://github.com/ReactorKit/ReactorKit)
* [Delegated](https://github.com/dreymonde/Delegated)
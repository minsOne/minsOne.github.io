---
layout: post
title: "[Swift4][ReactiveX]RxSwift를 직접 구현해보기 - Event, Disposable, Observer, Observable"
description: ""
category: "Programming"
tags: [Swift, RxSwift, ReactiveKit, ReactiveCocoa, Event, Disposable, Observer, Observable]
---
{% include JB/setup %}

이 글은 Rx를 알고 있거나, RxSwift 등의 사용에 경험이 있는 대상으로 작성된 글입니다.

---

## Rx 기본 요소 Event, Disposable, Observer, Observable 구현하기

#### 1. Event

Rx에서 Event는 next, error, completed로 구성되어 있습니다.

```
enum Event<T> {
    case next(T)
    case error(Swift.Error)
    case completed
}
```

#### 2. Disposable

Disposable는 사용 후 버리는 리소스를 말하며, error나 completed 등으로 더이상 구독하지 않는 상태가 되었을 때 정리하도록 dispose 함수를 정의합니다.

```
protocol Disposable {
    /// Dispose 상태시 호출
    func dispose()
}
```

AnonymousDisposable는 dispose되면 동작을 수행하는 Disposable입니다.

```
final class AnonymousDisposable: Disposable {
    private let disposedAction: () -> Void

    init(_ disposedAction: @escaping () -> Void) {
        self.disposedAction = disposedAction
    }

    func dispose() {
        disposedAction()
    }
}
```

CompositeDisposable는 여러 개의 Disposable을 가지는 컨테이너입니다. dispose 호출시 각각의 Disposable에 dispose를 호출합니다.

```
final class CompositeDisposable: Disposable {
    private var isDisposed: Bool = false
    private var disposables: [Disposable] = []

    // dispose가 된 상태라면 disposable를 dispose시키고, 그렇지 않으면 Disposable를 추가.
    func add(disposable: Disposable) {
        guard !isDisposed else {
            disposable.dispose()
            return
        }
        disposables.append(disposable)
    }

    func dispose() {
        guard !isDisposed else { return }
        isDisposed = true
        disposables.forEach { $0.dispose() }
    }
}
```

NonDisposable는 아무행위도 하지 않는 Disposable입니다. 별도의 작업 없이 단순히 Disposable 을 반환하는 곳에 쓰기 위함입니다.

```
final class NonDisposable: Disposable {
    func dispose() {}
}
```

#### 3. Observer

ObserverType은 Event를 다루도록 정의합니다.

```
protocol ObserverType {
    /// 옵저버가 볼 수 있는 시퀀스의 요소 타입
    associatedtype E

    /// 시퀀스 이벤트에 대해 옵저버에게 알림
    ///
    /// - parameter event: 발생된 이벤트
    func on(_ event: Event<E>)
}
```

Observer는 ObserverType을 따르며, 이벤트를 받으면 동작할 클로저를 가집니다.

```
final class Observer<E>: ObserverType {
    private let handler: (Event<E>) -> Void

    init(handler: @escaping (Event<E>) -> Void) {
        self.handler = handler
    }

    func on(_ event: Event<E>) {
        handler(event)
    }
}
```

#### 4. Observable

ObservableType은 Observable이 이벤트를 Observer에게 전달하면, Observer가 처리할 수 있도록 정의합니다.

```
protocol ObservableType {
    associatedtype E

    /// Observable을 구독하여 observer에 Event를 전달. Observer의 E와 E를 비교하여 타입 제약함.
    ///
    /// - Parameter observer: Event를 전달받을 Observer
    func subscribe<O: ObserverType>(observer: O) -> Disposable where O.E == E
}
```


Observable은 이벤트를 observer에게 전달합니다.

```
final class Observable<Element>: ObservableType {
    // associatedtype인 E의 타입을 지정
    typealias E = Element

    private let subscribeHandler: (Observer<Element>) -> Disposable

    init(observer subscribeHandler: @escaping (Observer<Element>) -> Disposable) {
        self.subscribeHandler = subscribeHandler
    }

    func subscribe<O : ObserverType>(observer: O) -> Disposable where O.E == E {
        // subscribeHandler의 return 타입이 Disposable이므로 CompositeDisposable에 추가함.
        let compositeDisposable = CompositeDisposable()

        // subscribeHandler에 새로운 observer를 넘기고, 새로운 observer가 event를 전달받으면 observer에 이벤트를 넘겨준다.
        let subscription = subscribeHandler(Observer { event in
            observer.on(event)
            switch event {
            case .error, .completed:
                compositeDisposable.dispose()
            default: break
            }
        })

        compositeDisposable.add(disposable: subscription)
        return compositeDisposable
    }
}
```

지금까지 기본적인 것들을 구현하였습니다.

## Rx 오퍼레이트 구현하기

#### 1. Subscribe

Observable로 부터 발행된 이벤트를 처리하며, next, error, completed 상태에 따라 다르게 정의할 수 있습니다.

```
extension ObservableType {
    func subscribe(onNext: ((E) -> Void)? = nil,
                   onError: ((Swift.Error) -> Void)? = nil,
                   onCompleted: (() -> Void)? = nil) -> Disposable {
        return subscribe(observer: Observer { event in
            switch event {
            case let .next(element): onNext?(element)
            case let .error(e): onError?(e)
            case .completed: onCompleted?()
            }
        })
    }
}
```

#### 2. Just

next와 completed 이벤트를 발행합니다.

```
extension ObservableType {
    static func just(_ value: E) -> Observable<E> {
        return Observable { (observer) -> Disposable in
            observer.on(.next(value))
            observer.on(.completed)
            return NonDisposable()
        }
    }
}
```

#### 3. Map

시퀀스의 요소에 함수를 적용합니다.

```
extension ObservableType {
    func map<U>(_ transform: @escaping (E) -> U) -> Observable<U> {
        return Observable<U> { observer in
            return self.subscribe(observer: Observer { event in
                switch event {
                case let .next(element):
                    observer.on(.next(transform(element)))
                case let .error(error):
                    observer.on(.error(error))
                case .completed:
                    observer.on(.completed)
                }
            })
        }
    }
}
```

만약 함수 내에서 error를 던지는 경우 error 이벤트를 observer에 넘기도록 할 수 있습니다.

```
extension ObservableType {
    func mapThrowsError<U>(_ transform: @escaping (E) throws -> U) -> Observable<U> {
        return Observable<U> { observer in
            return self.subscribe(observer: Observer { event in
                switch event {
                case let .next(element):
                    do {
                        try observer.on(.next(transform(element)))
                    } catch {
                        observer.on(.error(error))    
                    }
                case let .error(error):
                    observer.on(.error(error))
                case .completed:
                    observer.on(.completed)
                }
            })
        }
    }
}
```

#### 4. FlatMap

Observable에서 발행한 아이템을 다른 Observable로 만들며, 만들어진 Observable에서 아이템을 발행합니다.

Map과 다른 점은 next인 경우 transform 클로저를 구독하여 이벤트를 observer에다 넘겨준다는 점입니다.

```
extension ObservableType {
    func flatMap<U>(_ transform: @escaping (E) -> Observable<U>) -> Observable<U> {
        return Observable<U> { observer in
            let composite = CompositeDisposable()
            let subscription = self.subscribe(observer: Observer { event in
                switch event {
                case let .next(element):
                    let transformed = transform(element)
                    let disposable = transformed.subscribe(observer: Observer { event in
                        switch event {
                        case .next(let e):
                            observer.on(.next(e))
                        case .error(let err):
                            observer.on(.error(err))
                        case .completed:
                            observer.on(.completed)
                        }
                    })
                    composite.add(disposable: disposable)
                case let .error(error):
                    observer.on(.error(e))
                case .completed:
                    observer.on(.completed)
                }
            })

            composite.add(disposable: subscription)
            return composite
        }
    }
}
```

#### 5. CombineLatest

여러 Observable이 아이템을 발행하면, 그것들의 최신의 값으로 결합한 아이템을 발행합니다.

```
extension ObservableType {
    func combineLatest<O: ObservableType, U>(with other: O, combine: @escaping (E, O.E) -> U) -> Observable<U> {
        return Observable<U> { observer in
            let compositeDisposable = CompositeDisposable()

            var elements: (my: E?, other: O.E?)
            var completions: (my: Bool, other: Bool) = (false, false)

            func onNext() {
                // 두 값이 있으면 next 이벤트를 observer에 전달
                if let myElement = elements.my, let otherElement = elements.other {
                    let combination = combine(myElement, otherElement)
                    observer.on(.next(combination))
                }
            }

            func onCompleted() {
                // 두 값이 true라면 completed 이벤트를 observer에 전달
                if completions.my && completions.other {
                    observer.on(.completed)
                }
            }

            let selfDisposable = self.subscribe(observer: Observer { event in
                let lock = NSLock()
                defer { lock.unlock() }

                switch event {
                case let .next(e):
                    elements.my = e
                    onNext()
                case let .error(error):
                    observer.on(.error(error))
                case .completed:
                    completions.my = true
                    onCompleted()
                }
            })

            let otherDisposable = other.subscribe(observer: Observer { event in
                let lock = NSLock()
                defer { lock.unlock() }

                switch event {
                case let .next(e):
                    elements.other = e
                    onNext()
                case let .error(error):
                    observer.on(.error(error))
                case .completed:
                    completions.other = true
                    onCompleted()
                }
            })

            compositeDisposable.add(disposable: selfDisposable)
            compositeDisposable.add(disposable: otherDisposable)

            return compositeDisposable
        }
    }
}
```

#### 6. Zip

여러 Observable에서 발행된 아이템을 계속 저장하고 있다가, 모든 Observable에서 아이템을 발행되었다면 그때 아이템들을 결합하여 발행합니다.

```
extension ObservableType {
    func zip<O: ObservableType, U>(with other: O, combine: @escaping (E, O.E) -> U) -> Observable<U> {
        return Observable<U> { observer in
            let compositeDisposable = CompositeDisposable()

            var myBuffer = [E]()
            var otherBuffer = [O.E]()
            var completions: (my: Bool, other: Bool) = (false, false)

            func onNext() {
                // 들어온 값들을 꺼내어 next 이벤트를 전달
                guard !myBuffer.isEmpty && !otherBuffer.isEmpty else { return }
                Swift.zip(myBuffer, otherBuffer)
                    .map { combine($0, $1) }
                    .forEach {
                        myBuffer.removeFirst()
                        otherBuffer.removeFirst()
                        observer.on(.next($0))
                }
            }

            func onCompleted() {
                // 두 값이 true라면 completed 이벤트를 observer에 전달
                if completions.my && completions.other {
                    observer.on(.completed)
                }
            }

            let selfDisposable = self.subscribe(observer: Observer { event in
                let lock = NSLock()
                defer { lock.unlock() }

                switch event {
                case let .next(e):
                    myBuffer.append(e)
                    onNext()
                case let .error(error):
                    observer.on(.error(error))
                case .completed:
                    completions.my = true
                    onCompleted()
                }
            })

            let otherDisposable = other.subscribe(observer: Observer { event in
                let lock = NSLock()
                defer { lock.unlock() }

                switch event {
                case let .next(e):
                    otherBuffer.append(e)
                    onNext()
                case let .error(error):
                    observer.on(.error(error))
                case .completed:
                    completions.other = true
                    onCompleted()
                }
            })

            compositeDisposable.add(disposable: selfDisposable)
            compositeDisposable.add(disposable: otherDisposable)

            return compositeDisposable
        }
    }
}
```

## DisposeBag

iOS에서 View Life Cycle를 절대적으로 따라야 하는데, Rx 코드를 작성하면 작업이 끝날 때(?)까지 살아있습니다. 따라서 View Life Cycle에 맞춰 deinit 될 때 모두 Dispose 시켜줘야 합니다. DisposeBag가 그 역할을 수행합니다.

뷰는 DisposeBag을 속성으로 가지고, DisposeBag은 Disposable들을 관리하며, 뷰가 deinit시 DisposeBag을 deinit합니다. 이 때, DisposeBag이 관리하는 Disposable를 모두 dispose 시켜 메모리에 상주하지 않도록 합니다.

```
final class DisposeBag: Disposable {
    private var disposables = [Disposable]()
    
    func add(disposable: Disposable) {
        disposables.append(disposable)
    }

    func dispose() {
        disposables.forEach { $0.dispose() }
        disposables.removeAll()
    }

    static func += (left: DisposeBag, right: Disposable) {
        left.add(disposable: right)
    }
    
    deinit {
        dispose()
    }
}

extension Disposable {
    func disposed(by bag: DisposeBag) {
        bag += self
    }
}
```

## 코드 사용

이제 위의 코드들을 통해 기존 RxSwift 코드와 같이 동일하게 사용할 수 있습니다.

```
let disposeBag = DisposeBag()

Observable.just(10)
    .map { $0 * 2 }
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
```

만약 메모리 관리와 상관없이 동작하는 코드를 작성해야 한다면 다음과 같이 사용할 수 있습니다.

```
let _ = Observable.just(10)
    .map { $0 * 2 }
    .subscribe(onNext: { print($0) })
```

위 코드에서 Observable.just에서 Complete 이벤트를 전달하기 때문에, dispose되어 메모리 관리하지 않아도 정리됩니다.

## 정리

Rx는 Observer에 이벤트를 전달하고, Observable을 구독하고, Disposable을 관리하는 것이 핵심이라고 생각됩니다.

## 참고자료

* [RxSwift](https://github.com/ReactiveX/RxSwift/)
* [ReactiveKit](https://github.com/ReactiveKit/ReactiveKit)
* [RxSwift 소스 분석 - happyhourguide](http://happyhourguide.blogspot.kr/2016/12/rxswift-1.html)

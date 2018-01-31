---
layout: post
title: "[Swift4][ReactiveX]RxSwift를 직접 구현해보기 - Sink"
description: ""
category: "Programming"
tags: [Swift, RxSwift, ReactiveKit, ReactiveCocoa, Sink, Observable]
---
{% include JB/setup %}

## Rx Observable 리팩토링 - Sink

이전 글에서 Observable를 구현하였습니다.

```
protocol ObservableType {
    associatedtype E

    func subscribe<O: ObserverType>(observer: O) -> Disposable where O.E == E
}

final class Observable<Element>: ObservableType {
    typealias E = Element

    private let subscribeHandler: (Observer<Element>) -> Disposable

    init(observer subscribeHandler: @escaping (Observer<Element>) -> Disposable) {
        self.subscribeHandler = subscribeHandler
    }

    func subscribe<O : ObserverType>(observer: O) -> Disposable where O.E == E {
        let compositeDisposable = CompositeDisposable()
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

#### Sink



Sink는 subscribe 내부 로직을 가지는 헬퍼 클래스로, Disposable과 ObserverType 프로토콜을 따릅니다. 

Disposable을 따르는 이유는 Sink가 CompositeDisposable 대신 반환합니다. 

그리고 ObserverType을 따르는 것은 내부에서 Observer를 만들기도 하지만 Producer를 통해 Observable의 subscribe 함수에 observer를 넘겨줄 때 Sink를 넘겨주기 위함입니다.

```
class Sink<O: ObserverType>: Disposable, ObserverType {
    typealias E = O.E
    typealias Parent = Observable<E>

    private var disposed: Bool = false
    private let observer: O
    private let compositDisposable = CompositeDisposable()

    init(observer: O) {
        self.observer = observer
    }

    func on(event: Event<O.E>) {
        forwardOn(event)
    }

    private func forwardOn(_ event: Event<O.E>) {
        if disposed { return }
        observer.on(event: event)

        switch event {
        case .completed, .error: dispose()
        default: break
        }
    }

    func run(_ parent: Parent) {
        let observer = Observer(handler: forwardOn)
        compositDisposable.add(parent.subscribeHandler(observer))
    }

    func dispose() {
        disposed = true
        compositDisposable.dispose()
    }
}
```

<br/>Observable의 subscribe 함수는 Sink를 사용하여 코드를 줄일 수 있습니다.

```
final class Observable<Element>: ObservableType {
    typealias E = Element
    
    let subscribeHandler: (Observer<E>) -> Disposable
    
    init(_ subscribeHandler: @escaping (Observer<E>) -> Disposable) {
        self.subscribeHandler = subscribeHandler
    }
    
    func subscribe<O>(observer: O) -> Disposable where O : ObserverType, E == O.E {
        let sink = Sink(observer: observer)
        sink.run(self)
        return sink
    }
}
```

## 참고자료

* [RxSwift](https://github.com/ReactiveX/RxSwift/)
* [RxSwift 소스 분석 - happyhourguide](http://happyhourguide.blogspot.kr/2016/12/rxswift-2.html)

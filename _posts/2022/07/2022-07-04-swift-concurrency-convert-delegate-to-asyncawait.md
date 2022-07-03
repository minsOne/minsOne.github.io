---
layout: post
title: "[Swift 5.7+][Concurrency] Delegate 패턴을 async/await로 변환하기"
tags: [Swift, Concurrency, await, async, AsyncSequence, AsyncIteratorProtocol, AsyncStream]
---
{% include JB/setup %}

## Delegate 패턴

우리가 일반적으로 Delegate 패턴을 사용하여 작업을 수행하도록 하는 경우가 많습니다. Apple SDK에서도 Delegate 패턴으로 작성된 코드도 많습니다.

다음과 같이 Delegate 패턴으로 작성된 코드가 있습니다.

```swift
protocol ViewActionListener: AnyObject {
    func tapped()
    func refresh()
}

class SomeView {
    weak var listener: ViewActionListener?
    
    init() {}
    
    func tapped() {
        listener?.tapped()
    }
    func requestRefresh() {
        listener?.refresh()
    }
}

class ViewController: ViewActionListener {
    let view = SomeView()
    
    init() {
        view.listener = self
    }
    
    func tapped() {
        print("tapped")
    }

    func refresh() {
        print("refresh")
    }
}
```

위 코드는 View에서 수행된 액션을 ViewController에게 전달합니다. 그러면 ViewController에서 이를 처리하는 코드를 작성합니다.

ViewController는 ViewActionListener을 준수해야하며, 이를 구현해야 합니다. 그러나 함수가 많아졌습니다. 그래서 그런 함수들을 모아서 enum을 통해 함수 하나로 합칠 수 있습니다.

```swift
enum ViewAction {
    case tapped
    case refresh
}
protocol ViewActionListener: AnyObject {
    func send(action: ViewAction)
}

class SomeView {
    weak var listener: ViewActionListener?
    
    init() {}
    
    func tapped() {
        listener?.send(action: .tapped)
    }
    func requestRefresh() {
        listener?.send(action: .refresh)
    }
}

class ViewController: ViewActionListener {
    let view = SomeView()
    
    init() {
        view.listener = self
    }
    func send(action: ViewAction) {
        switch action {
        case .tapped:
            print("tapped")
        case .refresh:
            print("refresh")
        }
    } 
}
```

## Concurrency

위에서 Delegate 패턴으로 비동기로 Action을 받는 코드입니다. 즉, Delegate 패턴으로 작성된 코드를 Concurrency 형태로 변환할 수 있습니다.

우선 기존 작성된 코드는 쉽게 바꿀 수 없습니다. 하지만, Action을 받아서 처리하는 곳은 Concurrency 형태로 변환할 수 있습니다.

먼저 `ViewActionListener`를 준수하는 `ViewAdapter` 클래스를 선언합니다. 이 클래스는 Delegate를 Closure로 바꿔주는 역할을 합니다.

```swift
class ViewController {
    final class Adapter: ViewActionListener {
        var handler: ((ViewAction) -> Void)?
        
        func send(action: ViewAction) {
            handler?(action)
        }
    }

    let view = SomeView()
    let adapter = Adapter()
    
    init() {
        view.listener = adapter

        adapter.handler = { action in
            switch action {
            case .tapped:
                print("tapped")
            case .refresh:
                print("refresh")
            }
        }
    }
}
```

### AsyncStream

이제 handler 부분을 `AsyncStream`를 이용하여 `for await in loop`로 변환해봅시다.

```swift
class ViewController {
    final class Adapter: ViewActionListener {
        var handler: ((ViewAction) -> Void)?
        
        func send(action: ViewAction) {
            handler?(action)
        }
    }

    let view = SomeView()
    let adapter = Adapter()
    
    init() {
        view.listener = adapter

        Task { @MainActor [weak self] in
            guard let self = self else { return }

            for await action in self.viewActionEvents() {
                switch action {
                case .tapped:
                    print("tapped")
                case .refresh:
                    print("refresh")
                }
            }
        }
    }
    
    func viewActionEvents() -> AsyncStream<ViewAction> {
        let actions = AsyncStream(ViewAction.self) { [weak self] continuation in
            self?.adapter.handler = { action in
                continuation.yield(action)
            }
        }
        return actions
    }
}
```

### AsyncSequence

위에서 `AsyncStream`을 이용하여 `for await in loop`으로 변환이 가능함을 알았으니, `AsyncSequence` 를 이용하여 구현할 수 있음을 의미합니다.

```swift
class ViewController {
    final class Adapter: AsyncSequence, ViewActionListener {
        typealias Element = ViewAction
        
        private var continuation: AsyncStream<Element>.Continuation?
        private var iterator: AsyncStream<Element>.Iterator!

        init() {
            let stream = AsyncStream(Element.self, bufferingPolicy: .unbounded) { [weak self] continuation in
                self?.continuation = continuation
            }
            self.iterator = stream.makeAsyncIterator()
        }
        
        func makeAsyncIterator() -> AsyncStream<Element>.AsyncIterator {
            iterator
        }
        
        func send(action: ViewAction) {
            continuation?.yield(action)
        }
    }

    let view = SomeView()
    let adapter = Adapter()
    
    init() {
        view.listener = adapter
        Task { @MainActor [weak self] in
            guard let self = self else { return }

            for await action in self.adapter {
                switch action {
                case .tapped:
                    print("tapped")
                case .refresh:
                    print("refresh")
                }
            }
        }
    }
}
```

## 정리

Delegate 패턴을 Concurrency 형태로 변환하는 방법을 작성해보았습니다. 여러가지 방법으로 작성하긴 했지만, Closure 형태로 하는게 가장 간단해 보이긴 합니다. 

추후에 위에 작성된 코드들보다 더 좋은 코드로 정리할 수 있도록 하겠습니다.
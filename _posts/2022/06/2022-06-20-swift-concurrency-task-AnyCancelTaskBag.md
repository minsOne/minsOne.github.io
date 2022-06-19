---
layout: post
title: "[Swift 5.7+][Concurrency] Task의 CancelTaskBag 구현하기"
tags: [swift, Concurrency, Task, cancel, AnyCancelTaskBag, AnyCancellableTask]
published: true
---
{% include JB/setup %}

Swift의 Concurrency에서 Task를 이용해서 비동기 작업을 처리합니다. 

```swift
Task { 
    try await Task.sleep(nanoseconds: 10 * 1_000_000_000)
    print("Hello")
}
```

하지만, Task로 비동기 작업 도중에 Task를 실행한 객체가 사라지거나 할 수 있습니다. 

```swift
class Alpha {
    init() {
        print("\(Date()) init")
        Task {
            print("\(Date()) Before Hello Alpha")
            try await Task.sleep(nanoseconds: 10 * 1_000_000_000)
            print("\(Date()) After Hello Alpha")
        }
    }
    
    deinit {
        print("\(Date()) deinit")
    }
}

func run() {
    _ = Alpha()
}

/** Output
2022-06-19 16:16:36 +0000 init
2022-06-19 16:16:36 +0000 deinit
2022-06-19 16:16:36 +0000 Before Hello Alpha
2022-06-19 16:16:46 +0000 After Hello Alpha
*/
```

위와 같이 객체를 생성 후 변수에 할당하지 않기 때문에 바로 deinit 됩니다. 하지만, Task를 실행하였기 때문에, 10초 뒤에 After Hello Alpha 가 출력됩니다.

deinit 되는 시점에는 Task가 취소되어야 합니다.

다행히도 Task는 변수에 담을 수 있습니다. 그러면 변수에 담은 Task를 deinit할때 cancel() 함수를 호출하여 취소하면 됩니다.

```swift
class Alpha {
    var task: Task<(), Error>?
    
    init() {
        print("\(Date()) init")
        self.task = Task {
            try await Task.sleep(nanoseconds: 10 * 1_000_000_000)
            print("\(Date()) Hello Alpha")
        }
    }
    
    deinit {
        print("\(Date()) deinit")
        task?.cancel()
    }
}
```

하지만 매번 Task를 변수에 저장하고, deinit 될때 cancel을 시켜주기에는 귀찮은 작업이 됩니다.

RxSwift의 DisposeBag과 같은 객체를 만들고, 저장한 뒤, DisposeBag이 deinit 될 때, 저장된 Task를 취소하는 방식을 사용하면 어떨까 합니다.

먼저 Task는 Success, Error가 명시적으로 정의되어야 합니다. 하지만, 우리는 Task의 cancel() 함수만 호출하므로 타입을 제거해야 합니다.

cancel 함수가 있는 프로토콜을 정의하고, Task에 Extension에 추가합니다.

```swift
public protocol AnyCancellableTask {
    func cancel()
}

extension Task: AnyCancellableTask {}
```

Task는 cancel 함수가 있으므로, 별도로 구현할 필요가 없습니다.

이제 `AnyCancellableTask` 프로토콜을 담을 객체를 만듭니다.

```swift
public final class AnyCancelTaskBag {
    private var tasks: [any AnyCancellableTask] = []
    
    public func add(task: any AnyCancellableTask) {
        tasks.append(task)
    }

    public func cancel() {
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
    }
    
    deinit {
        cancel()
    }
}


extension Task {
    public func store(in bag: AnyCancelTaskBag) {
        bag.add(task: self)
    }
}
```

이제 `AnyCancelTaskBag` 을 이용하여 Task를 담아봅시다.

```swift
class Alpha {
    let bag = AnyCancelTaskBag()
    
    init() {
        print("\(Date()) init")
        Task {
            print("\(Date()) before Hello Alpha")
            try await Task.sleep(nanoseconds: 10 * 1_000_000_000)
            print("\(Date()) After Hello Alpha")
        }.store(in: bag)
    }
    
    deinit {
        print("\(Date()) deinit")
    }
}

/** Output
2022-06-19 16:49:19 +0000 init
2022-06-19 16:49:19 +0000 deinit
2022-06-19 16:49:19 +0000 before Hello Alpha
*/
```

before Hello Alpha 만 출력하고 10초 뒤에 출력될 After Hello Alpha가 출력되지 않습니다.

deinit 된 후에도 계속 동작할 수 있는 코드들은 위와 같이 Bag과 같이 관리하거나 별도의 변수로 담아 직접 cancel() 호출하는 등의 방법으로 불필요한 동작을 수행하지 않도록 하는 것이 중요합니다.

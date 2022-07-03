---
layout: post
title: "[Swift 5.7+][Concurrency] AsyncStream, AsyncThrowingStream 알아보기 - Continuation vs unfolding"
tags: [Swift, Concurrency, Task, cancel, AsyncStream, AsyncThrowingStream, unfolding]
---
{% include JB/setup %}

Concurrency에서는 AsyncStream이 AsyncSequence을 준수하여 비동기 Iterator를 직접 구현하지 않고도 비동기 시퀀스를 쉽게 작성할 수 있습니다.

AsyncStream의 Continuation에서 yield를 통해 데이터를 스트림에 제공하거나, 더이상 데이터를 받지 못하는 경우, finish를 호출합니다. 혹은 데이터가 성공 또는 실패인지를 `yield.(with: .success())`, `yield.(with: .failure())` 로 전달 가능합니다. failure로 전달할때는 AsyncThrowingStream을 사용하면 됩니다.

한번 CountDown하는 예제를 만들어봅시다.

```swift
func countdown() async {
    let counter = AsyncStream<String> { continuation in
        var countdown = 3
        Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true
        ) { timer in
            guard countdown > 0 else {
                timer.invalidate()
                continuation.yield(with: .success("\(Date()) 🎉 Hello"))
                continuation.finish()
                return
            }
            
            continuation.yield("\(Date()) \(countdown)...")
            countdown -= 1
        }
    }
    
    for await count in counter {
        print(count)
    }
}

func run() {
    Task {
        await countdown()
    }
}

/** Output
2022-06-22 14:46:56 +0000 3...
2022-06-22 14:46:57 +0000 2...
2022-06-22 14:46:58 +0000 1...
2022-06-22 14:46:59 +0000 🎉 Hello
*/
```

Timer를 이용하여 1초마다 카운트다운 하는 기능을 만들었습니다. yield를 호출하여 데이터를 스트림에 넘기도록 하고, countdown 값이 0인 경우 yield에 success로 값을 보내고 finish를 하였습니다.

Timer 기능을 하는 코드를 AsyncStream을 이용하면 쉽게 만들수가 있습니다.

---

다음으로 AsyncThrowingStream 을 이용하여 위와 같은 코드를 구현해봅시다.

```swift
func countdown() async throws {
    let counter = AsyncThrowingStream<String, Error> { continuation in
        var countdown = 3
        Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true
        ) { timer in
            guard countdown > 0 else {
                timer.invalidate()
                continuation.yield(with: .success("\(Date()) 🎉 Hello"))
                continuation.finish()
                return
            }
            if countdown == 1 {
                continuation.finish(throwing: NSError(domain: "error", code: 1))
                return
            }
            continuation.yield("\(Date()) \(countdown)...")
            countdown -= 1
        }
    }
    
    for try await count in counter {
        print(count)
    }
}

func run() {
    Task {
        do {
            try await countdown()
        } catch {
            print(error)
        }
    }
}

/** Output
2022-06-22 15:32:09 +0000 3...
2022-06-22 15:32:10 +0000 2...
Error Domain=error Code=1 "(null)"
*/
```

AsyncThrowingStream는 에러를 던지므로, AsyncThrowingStream를 사용하는 곳에서는 try를 붙여줘야 합니다.

여기에서 카운트다운 값이 1일때, 에러를 던지도록 하였고, Task에서 그 에러를 받아서 처리하도록 하였습니다.

---

다음으로 위에서는 Timer.scheduledTimer를 이용하여 카운트 다운을 하였습니다. 다른 방법으로, AsyncStream의 unfolding을 이용하여 카운트 다운을 구현해봅시다.

```swift
public struct AsyncStream<Element> {
    ...
    public init(unfolding produce: @escaping () async -> Element?, onCancel: (@Sendable () -> Void)? = nil)
}
```

AsyncStream에는 위와 같이 `init(unfolding:onCancel)` 함수가 있는데, Continuation를 직접 호출하지 않으려는 경우, 이 init을 사용하면 됩니다. Element가 옵셔널이므로, nil을 반환하면 스트림이 종료됩니다.

```swift
func countdown() async throws {
    var countdown = 3
    let counter = AsyncStream<String> {
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
        } catch {
            return nil
        }
        
        defer { countdown -= 1 }
        
        switch countdown {
        case (1...): return "\(Date()) \(countdown)..."
        case 0: return "\(Date()) 🎉 Hello"
        default: return nil
        }
    }
    
    for try await count in counter {
        print(count)
    }
}

func run() {
    Task {
        await countdown()
    }
}

/** Output
2022-06-22 15:53:49 +0000 3...
2022-06-22 15:53:50 +0000 2...
2022-06-22 15:53:51 +0000 1...
2022-06-22 15:53:52 +0000 🎉 Hello
*/
```

타이머는 Task.sleep을 이용하여 1초 시간씩 지연하도록 작업하였고, 0보다 작은 경우는 nil을 반환하도록 하여 스트림이 종료되도록 하였습니다.

AsyncStream의 `init(unfolding:onCancel)`을 이용하여 훨씬 간단하게 카운트 다운을 구현할 수 있었습니다.

--- 

AsyncThrowingStream도 마찬가지로 `init(unfolding:)` 을 이용하여 카운트 다운을 쉽게 구현할 수 있습니다.

이전에는 Continuation에 `finish(throwing:)`로 에러를 던져줬지만, 이제는 throw로 에러를 던지면 됩니다.

```swift
func countdown() async throws {
    var countdown = 3
    let counter = AsyncThrowingStream<String, Error> {
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
        } catch {
            return nil
        }
        
        defer { countdown -= 1 }
        
        if countdown == 1 {
            throw NSError(domain: "error", code: 1)
        }
        
        switch countdown {
        case (1...): return "\(Date()) \(countdown)..."
        case 0: return "\(Date()) 🎉 Hello"
        default: return nil
        }
    }
    
    for try await count in counter {
        print(count)
    }
}

func run() {
    Task {
        do {
            try await countdown()
        } catch {
            print(error)
        }
    }
}

/** Output
2022-06-22 15:58:23 +0000 3...
2022-06-22 15:58:24 +0000 2...
Error Domain=error Code=1 "(null)"
*/
```


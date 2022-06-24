---
layout: post
title: "[Swift 5.7+][Concurrency] Continuations - Closure를 async 코드로 감싸 사용하기"
tags: [Swift, Concurrency, await, async, withCheckedContinuation, withCheckedThrowingContinuation]
---
{% include JB/setup %}

Continuation은 프로그램 상태의 불투명한 표현입니다. 비동기 코드에서 연속(continuation)을 만들려면 `withCheckedContinuation(function:_:)`, `withCheckedThrowingContinuation(function:_:)` 와 같은 코드를 호출합니다. 비동기 태스크를 재개하려면, `resume(returning:)`, `resume(throwing:)`, `resume(with:)`, `resume()` 메소드를 호출합니다.

continue에서 두 번 이상 resume을 호출하면 되지 않습니다. 또한, resume을 호출하지 않으면 Task가 무기한 일시 중단된 상태로 유됩니다.

Continuation를 이용하여 기존 비동기 코드(Closure)를 async로 변경해봅시다.

```swift
func request(completion: ((String) -> Void)) {
    completion("Hello")
}

func run() {
    request(completion: {
        print($0)
    })
}
```

위와 같은 Closure 코드를 `withCheckedContinuation(function:_:)` 함수를 이용해 async 코드로 만들어봅시다.

```swift
func requestAsync() async -> String {
    return await withCheckedContinuation { continuation in
        request(completion: {
            continuation.resume(returning: $0)
            // or 
            // continuation.resume(with: .success($0))
        })
    }
}

func run() {
    Task {
        let result = await requestAsync()
        print(result)
    }
}

/** Output
Hello
*/
```

만약 에러를 반환해야 하는 경우, 두 가지 방안이 있습니다. 에러를 던지거나, Result에 에러를 보내는 방식입니다.

첫 번째로, 에러를 던지는 방식의 코드를 작성해봅시다.

```swift
func requestAsync() async throws -> String {
    return try await withCheckedThrowingContinuation{ continuation in
        request(completion: { _ in
            continuation.resume(throwing: NSError(domain: "sample", code: 1))
        })
    }
}

func run() {
    Task {
        do {
            let result = try await requestAsync()
            print(result)
        } catch {
            print(error)
        }
    }
}
/** Output
Error Domain=error Code=1 "(null)"
*/
```

두 번째로, Result에 에러를 담아서 보내는 방식입니다.

```swift
func requestAsync() async -> Result<String, NSError> {
    return await withCheckedContinuation { continuation in
        request(completion: { result in
            continuation.resume(returning: .failure(NSError(domain: "sample", code: 1)))
        })
    }
}

func run() {
    Task {
        let result = await requestAsync()
        switch result {
        case .success(let result): print(result)
        case .failure(let error): print(error)
        }
    }
}
/** Output
Error Domain=error Code=1 "(null)"
*/
```

개인적으로는 Result를 이용하여 에러를 담아 보내는 방식을 선호합니다. 이는 do catch 문에서는 Error 타입을 정확히 알 순 없지만, Result로 에러를 보내게 되면, 해당 에러 타입을 알기 때문에 에러 타입에 따른 분기 처리가 원활하기 때문입니다.



## 참고자료

* [Apple Doc - CheckedContinuation](https://developer.apple.com/documentation/swift/checkedcontinuation)

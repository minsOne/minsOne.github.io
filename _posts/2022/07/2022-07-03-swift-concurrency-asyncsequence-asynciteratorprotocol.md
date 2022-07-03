---
layout: post
title: "[Swift 5.7+][Concurrency] AsyncSequence, AsyncIteratorProtocol"
tags: [Swift, Concurrency, await, async, AsyncSequence, AsyncIteratorProtocol]
---
{% include JB/setup %}

## AsyncSequence, AsyncIteratorProtocol

Collection에서 사용하는 프로토콜인 Sequence, IteratorProtocol을 Concurrency에서 비슷한 방식으로 사용할 수 있도록 AsyncSequence, AsyncIteratorProtocol을 제공합니다.

Sequence로 사용하던 `for in loop` 방식을 AsyncSequence에서도 사용할 수 있습니다.

```swift
// Example
for await i in Counter(howHigh: 10) {
    print(i, terminator: " ")
}
// Prints: 1 2 3 4 5 6 7 8 9 10
```

그러면 AsyncSequence, AsyncIteratorProtocol을 사용하여 Count를 구현해봅시다.

```swift
struct Counter : AsyncSequence {
    typealias Element = Int
    let howHigh: Int

    struct AsyncIterator : AsyncIteratorProtocol {
        let howHigh: Int
        var current = 1
        mutating func next() async -> Int? {
            try? await Task.sleep(nanoseconds: 1_000_000_000)

            guard current <= howHigh else {
                return nil
            }

            let result = current
            current += 1
            return result
        }
    }

    func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(howHigh: howHigh)
    }
}

func main() async {
    for await i in Counter(howHigh: 10) {
        print(i, terminator: " ")
    }
    print()
}

await main()
// Prints: 1 2 3 4 5 6 7 8 9 10
```

위와 같이 `for await in loop` 문을 통해서 1초마다 값이 출력되는 것을 확인할 수 있습니다.


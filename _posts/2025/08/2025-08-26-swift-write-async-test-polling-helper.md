---
layout: post
title: "[Swift6][Concurrency] Swift에서 비동기 호출을 검증하기 (1) - Polling 기반 Concurrency 헬퍼"
tags: [Swift, Concurrency, Test]
---
{% include JB/setup %}

Swift 5.5 부터 Concurrency가 도입되면서 비동기 함수를 훨씬 직관적으로 다룰 수 있게 되었습니다. 하지만 테스트 코드에서는 여전히 문제가 남아 있습니다.
“호출 횟수가 정확히 증가했는지”, “여러 callCount 변수가 특정 값에 도달했는지”를 검증하려면 단순히 XCTAssertEqual만으로는 부족합니다. 왜냐하면 비동기 작업의 완료 시점이 불확실하기 때문입니다.

이 글에서 Polling 테스트 헬퍼를 구현하고, 어떻게 적용할 수 있을지를 살펴보겠습니다.

## 문제 상황

일반적으로 async 함수의 호출 여부를 확인하려면 다음과 같이 작성합니다.

```swift
@Test
func testAsyncFunction() {
  var callCount = 0
  
  Task.detached {
    try? await Task.sleep(nanoseconds: 100_000_000)
    callCount += 1
  }
  
  #expect(callCount == 1)
}
```

이 코드는 대부분 실패합니다. Task.detached 내부의 비동기 호출이 끝나기 전에 검증 코드가 실행되기 때문입니다. 이를 해결하려고 sleep을 넣으면, 테스트가 느려지고, 환경에 따라 테스트가 실패할 수 있습니다.

```swift
/// Bad example
@Test
func testAsyncFunction() async throws {
  var callCount = 0

  Task.detached {
    try? await Task.sleep(nanoseconds: 100_000_000)
    callCount += 1
  }
  try await Task.sleep(nanoseconds: 200_000_000)
  #expect(callCount == 1)
}
```

## 해결 방법 1 - XCTestExpectation

XCTest가 제공하는 공식적인 방법은 XCTestExpectation을 사용하는 것입니다.

다음 코드는 앞의 예제 코드에서 사용했던 sleep 대신 XCTestExpectation를 사용합니다.

```swift
func testAsyncFunction() {
  let exp = XCTestExpectation(description: "callCount 증가")
  var callCount = 0
  
  Task.detached {
    try? await Task.sleep(nanoseconds: 100_000_000)
    callCount += 1
    exp.fulfill()
  }
  
  wait(for: [exp], timeout: 1.0)
  XCTAssertEqual(callCount, 1)
}
```

이 방식으로 비동기 함수의 호출 여부를 검증할 수 있습니다. 하지만 여러 개의 callCount를 동시에 검증하거나, 복잡한 조건이 있다면 해당 코드는 복잡해집니다.

예를 들어 A, B, C 세 가지 값이 각각 1, 2, 3이 되어야 한다면, expectation도 세 개를 만들고, fulfill도 제각각 호출해줘야 합니다.
이 경우 테스트 코드는 `검증`이 아니라 `제어 흐름 관리`에 치중하게 되어, 가독성이 심하게 떨어지는 문제가 있습니다.

## 해결 방법 2 - Polling

보다 나은 방법은 “값이 원하는 상태에 도달할 때까지 일정 간격으로 검사(polling)”하는 것입니다.
이를 위해 assertEventuallyEqual이라는 헬퍼를 만듭니다.

```swift
public enum EventuallyError<T: Equatable & Sendable>:
  Error,
  CustomStringConvertible {
  case timeout(last: T, expected: T)

  public var description: String {
    switch self {
    case let .timeout(last, expected):
      return "Timed out. last=\(last), expected=\(expected)"
    }
  }
}

public func assertEventuallyEqual<T: Equatable & Sendable>(
  _ expected: T,
  _ current: @escaping @Sendable () async -> T,
  timeout: TimeInterval = 2.0,
  interval: TimeInterval = 0.02,
  file: StaticString = #filePath,
  line: UInt = #line
) async throws {
  let deadline = Date().addingTimeInterval(timeout)
  while Date() < deadline {
    let value = await current()
    if value == expected {
      return
    }
    try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
  }
  let last = await current()
  throw EventuallyError.timeout(last: last, expected: expected)
}
```

앞의 예제 코드에서 `assertEventuallyEqual` 를 이용하여 테스트 코드를 작성합니다.

```swift
@Test
func testAsyncFunction() async throws {
  let count = Counter()

  Task {
    try? await Task.sleep(nanoseconds: 100_000_000)
    count.call()
  }

  try await assertEventuallyEqual(1, { count.callCount }, timeout: 5.0)
}
```

이제 XCTAssertEqual 대신 assertEventuallyEqual을 쓰면 비동기 코드도 안정적으로 검증할 수 있고,
여러 조건이 있는 경우에도 XCTestExpectation보다 훨씬 간결하게 표현할 수 있습니다.

## 해결 방법 3 - 다중 조건 검증

여러 callCount 변수를 동시에 검증해야 하는 경우도 자주 있습니다.

예를 들어 A, B 두 개의 호출 카운트가 각각 1, 2가 되어야 한다면, assertEventuallyAllEqual을 활용할 수 있습니다.

```swift
public enum EventuallyErrorAll: Error, CustomStringConvertible {
  case timeoutAll(String)

  public var description: String {
    switch self {
    case let .timeoutAll(message): message
    }
  }
}

public struct Check<T: Equatable & Sendable>: Sendable {
  public let name: String
  public let expected: T
  public let current: @Sendable () async -> T

  public init(
    name: String,
    expected: T,
    current: @escaping @Sendable () async -> T
  ) {
    self.name = name
    self.expected = expected
    self.current = current
  }
}

public func assertEventuallyAllEqual<T: Equatable & Sendable>(
  _ checks: [Check<T>],
  timeout: TimeInterval = 2.0,
  interval: TimeInterval = 0.02,
  file: StaticString = #filePath,
  line: UInt = #line
) async throws {
  let deadline = Date().addingTimeInterval(timeout)

  while Date() < deadline {
    let currents: [T] = await withTaskGroup(of: T.self) { group in
      for c in checks {
        group.addTask { await c.current() }
      }
      return await group.reduce(into: []) { $0.append($1) }
    }

    let allMatch = zip(checks, currents).allSatisfy { $0.expected == $1 }
    if allMatch { return }

    try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
  }

  let results: [(String, T, T)] = await withTaskGroup(of: (String, T, T).self) { group in
    for c in checks {
      group.addTask {
        let v = await c.current()
        return (c.name, v, c.expected)
      }
    }
    return await group.reduce(into: []) { $0.append($1) }
  }

  let diff = results
    .filter { $0.1 != $0.2 }
    .map { "• \($0.0): last=\($0.1) expected=\($0.2)" }
    .joined(separator: "\n")

  throw EventuallyErrorAll.timeoutAll("Timed out waiting for all equal.\n\(diff)\nfile: \(file), line: \(line)")")
}
```

이제 `assertEventuallyAllEqual`을 사용하여 테스트 코드를 작성합니다.

```swift
final class Counter: @unchecked Sendable {
  private(set) var aCallCount = 0
  private(set) var bCallCount = 0
  func call() {
    aCallCount += 1
    bCallCount += 1
  }
}

@Test
func testAsyncFunction() async throws {
  let count = Counter()

  Task.detached {
    try? await Task.sleep(nanoseconds: 100_000_000)
    count.call()
  }

  try await assertEventuallyAllEqual(
    [
      Check(name: "A Count", expected: 1, current: { count.aCallCount }),
      Check(name: "B Count", expected: 1, current: { count.bCallCount })
    ],
    timeout: 5.0)
}
```

assertEventuallyAllEqual 함수를 사용하여, 코드가 짧고, 실패 시에는 어떤 값이 기대치와 달랐는지도 상세하게 출력합니다. 그리고 Expectation을 늘어놓는 것보다 훨씬 직관적입니다.

## 마무리

XCTestExpectation은 비동기 검증의 표준이지만, 조건이 많아질수록 테스트 코드의 가독성이 크게 떨어집니다.

Polling 기반의 헬퍼는 이런 한계를 보완하면서도 다음과 같은 장점을 제공합니다
- 조건 충족까지 대기 → sleep 의존 제거
- 여러 변수 동시 검증 → expectation 난립 방지
- 상세 실패 메시지 출력 → 디버깅 편의성 향상

즉, “테스트 코드가 제어 흐름 관리에 매몰되지 않고 검증 로직 자체에 집중할 수 있게 된다”는 점이 가장 큰 장점입니다.

<br/>

---

## 전체 코드 - [Gist](https://gist.github.com/minsOne/f30cc00217bd88edd6d6dd2716876afb)

```swift
public enum EventuallyError<T: Equatable & Sendable>:
  Error,
  CustomStringConvertible
{
  case timeout(last: T, expected: T)

  public var description: String {
    switch self {
    case let .timeout(last, expected):
      "Timed out. last=\(last), expected=\(expected)"
    }
  }
}

public enum EventuallyErrorAll: Error, CustomStringConvertible {
  case timeoutAll(String)

  public var description: String {
    switch self {
    case let .timeoutAll(message): message
    }
  }
}

public struct Check<T: Equatable & Sendable>: Sendable {
  public let name: String
  public let expected: T
  public let current: @Sendable () async -> T

  public init(
    name: String,
    expected: T,
    current: @escaping @Sendable () async -> T
  ) {
    self.name = name
    self.expected = expected
    self.current = current
  }
}

public func assertEventuallyEqual<T: Equatable & Sendable>(
  _ expected: T,
  _ current: @escaping @Sendable () async -> T,
  timeout: TimeInterval = 2.0,
  interval: TimeInterval = 0.02,
  file: StaticString = #filePath,
  line: UInt = #line
) async throws {
  let deadline = Date().addingTimeInterval(timeout)
  while Date() < deadline {
    let value = await current()
    if value == expected {
      return
    }
    try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
  }
  let last = await current()
  throw EventuallyError.timeout(last: last, expected: expected)
}

public func assertEventuallyAllEqual<T: Equatable & Sendable>(
  _ checks: [Check<T>],
  timeout: TimeInterval = 2.0,
  interval: TimeInterval = 0.02,
  file: StaticString = #filePath,
  line: UInt = #line
) async throws {
  let deadline = Date().addingTimeInterval(timeout)

  while Date() < deadline {
    let currents: [T] = await withTaskGroup(of: T.self) { group in
      for c in checks {
        group.addTask { await c.current() }
      }
      return await group.reduce(into: []) { $0.append($1) }
    }

    let allMatch = zip(checks, currents).allSatisfy { $0.expected == $1 }
    if allMatch { return }

    try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
  }

  let results: [(String, T, T)] = await withTaskGroup(of: (String, T, T).self) { group in
    for c in checks {
      group.addTask {
        let v = await c.current()
        return (c.name, v, c.expected)
      }
    }
    return await group.reduce(into: []) { $0.append($1) }
  }

  let diff = results
    .filter { $0.1 != $0.2 }
    .map { "• \($0.0): last=\($0.1) expected=\($0.2)" }
    .joined(separator: "\n")

  throw EventuallyErrorAll.timeoutAll("Timed out waiting for all equal.\n\(diff)\nfile: \(file), line: \(line)")
}
```
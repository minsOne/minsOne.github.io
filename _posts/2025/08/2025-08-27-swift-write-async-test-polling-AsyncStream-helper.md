---
layout: post
title: "[Swift6][Concurrency] Swift에서 비동기 호출을 검증하기 (2) - AsyncStream을 활용한 이벤트 기반 테스트 헬퍼"
tags: [Swift, Concurrency, Test, AsyncStream]
---
{% include JB/setup %}

Swift 5.5 부터 Concurrency가 도입되면서 비동기 함수를 훨씬 직관적으로 다룰 수 있게 되었습니다. 하지만 테스트 코드에서는 여전히 문제가 남아 있습니다.
“호출 횟수가 정확히 증가했는지”, “여러 callCount 변수가 특정 값에 도달했는지”를 검증하기 위해 흔히 사용하는 방법은 XCTestExpectation입니다. 하지만 expectation을 남발하다 보면 테스트 코드가 제어 흐름 관리에 치중되어 가독성이 떨어지고, 유지보수도 어렵습니다.

이번 글에서는 이러한 한계를 개선하기 위해 AsyncStream을 활용한 이벤트 기반 Polling 헬퍼를 소개합니다. 이 접근은 불필요한 sleep 의존을 줄이고, 상태 변화가 발생하는 순간을 자연스럽게 기다릴 수 있도록 도와줍니다

## 문제 상황

일반적으로 비동기 함수의 호출 여부를 확인하기 위해 XCTestExpectation를 이용합니다.

```swift
@Test
func testAsyncFunction() {
  let exp = XCTestExpectation(description: "callCount 증가")
  var callCount = 0
  
  Task.detached {
    try? await Task.sleep(nanoseconds: 100_000_000)
    callCount += 1
    exp.fulfill()
  }
  
  wait(for: [exp], timeout: 1.0)
  #expect(callCount == 1)
}
```

작은 예제에서는 문제없지만, 여러 개의 상태를 동시에 검증해야 하거나, 값이 특정 범위에 도달했는지를 확인해야 할 때 테스트 코드가 복잡해지고, 의도했던 “검증 로직”보다 “동기화 관리 코드”가 더 눈에 띄게 됩니다.

## 해결 방법 1 - AsyncStream으로 접근하기

보다 나은 방법은 “값이 원하는 상태에 도달할 때까지 일정 간격으로 검사(polling)”하는 것입니다.
AsyncStream을 이용하여 이를 구현할 수 있습니다. makePollingStream이라는 헬퍼를 만듭니다.

```swift
struct EventuallyTimeoutError: Error, CustomStringConvertible {
  let label: String
  let message: String
  var description: String { label.isEmpty ? message : "[\(label)] \(message)" }
  init(label: String = "", message: String) {
    self.label = label
    self.message = message
  }
}

func makePollingStream<T: Sendable>(
  current: @escaping @Sendable () async -> T,
  until: @escaping @Sendable (T) -> Bool,
  interval: Duration = .milliseconds(20),
  timeout: Duration = .seconds(2),
  isSame: (@Sendable (T, T) -> Bool)? = nil
) -> AsyncStream<T> {
  let (stream, continuation) = AsyncStream<T>.makeStream(of: T.self)
  let clock = ContinuousClock()
  Task {
    let start = clock.now
    var last: T? = nil

    var now = await current()
    continuation.yield(now)
    last = now
    if until(now) {
      continuation.finish()
      return
    }

    while clock.now - start < timeout {
      try? await clock.sleep(for: interval)
      now = await current()

      if let cmp = isSame, let prev = last {
        if cmp(now, prev) == false {
          continuation.yield(now)
          last = now
        }
      } else {
        continuation.yield(now)
        last = now
      }

      if until(now) { break }
    }
    continuation.finish()
  }
  return stream
}
```

`makePollingStream` 를 이용하여 비동기 테스트하는 `assertEventually` 함수를 만듭니다.

```swift
func assertEventually<T: Sendable>(
  _ label: String = "",
  current: @escaping @Sendable () async -> T,
  until: @escaping @Sendable (T) -> Bool,
  interval: Duration = .milliseconds(20),
  timeout: Duration = .seconds(2),
  isSame: (@Sendable (T, T) -> Bool)? = nil,
  describe: @escaping (T) -> String = { "\($0)" }
) async throws {
  let stream = makePollingStream(
    current: current,
    until: until,
    interval: interval,
    timeout: timeout,
    isSame: isSame
  )

  var last: T?
  for await value in stream {
    last = value
    if until(value) { return }
  }
  throw EventuallyTimeoutError(
    label: label,
    message: "Timed out. last=\(last.map(describe) ?? "nil")"
  )
}

func assertEventuallyEqual<T: Equatable & Sendable>(
  _ expected: T,
  _ current: @escaping @Sendable () async -> T,
  label: String = "",
  timeout: TimeInterval = 2.0,
  interval: TimeInterval = 0.02,
  describe: @escaping (T) -> String = { "\($0)" }
) async throws {
  try await assertEventually(
    label,
    current: current,
    until: { $0 == expected },
    timeout: timeout,
    interval: interval,
    isSame: { $0 == $1 },
    describe: { "value=\(describe($0)), expected=\(expected)" }
  )
}
```

앞의 예제 코드에서 `assertEventuallyEqual` 를 이용하여 테스트 코드를 작성합니다.

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

  Task {
    try? await Task.sleep(nanoseconds: 100_000_000)
    count.call()
  }

  try await assertEventuallyEqual(1, { count.aCallCount }, timeout: 5.0)
}
```

이제 XCTAssertEqual 대신 assertEventuallyEqual을 쓰면 비동기 코드도 안정적으로 검증할 수 있고,
여러 조건이 있는 경우에도 XCTestExpectation보다 훨씬 간결하게 표현할 수 있습니다.

## 해결 방법 2 - 다중 조건 검증

여러 callCount 변수를 동시에 검증해야 하는 경우도 자주 있습니다.

예를 들어 A, B 두 개의 호출 카운트가 각각 1, 2가 되어야 한다면, assertEventuallyAllEqual을 활용할 수 있습니다.

```swift
struct Check<T: Sendable & Equatable>: Sendable {
  let name: String
  let expected: T
  let current: @Sendable () async -> T
  let describe: @Sendable (T) -> String

  public init(
    name: String,
    expected: T,
    current: @escaping @Sendable () async -> T,
    describe: @escaping @Sendable (T) -> String = { "\($0)" }
  ) {
    self.name = name
    self.current = current
    self.expected = expected
    self.describe = describe
  }

  func isSame(_ lhs: T, _ rhs: T) -> Bool {
    lhs == rhs
  }

  func debugExpectedDescription() -> String {
    "expected=\(describe(expected))"
  }
}

struct ItemResult<T: Sendable>: Sendable {
  let name: String
  let last: T?
  let isSatisfied: Bool
}

func assertEventuallyAllEqual<T: Sendable>(
  _ checks: [Check<T>],
  label: String = "",
  interval: Duration = .milliseconds(20),
  timeout: Duration = .seconds(2)
) async throws {
  let results: [ItemResult<T>] = try await withThrowingTaskGroup(of: ItemResult<T>.self) { group in
    for check in checks {
      group.addTask {
        let stream = makePollingStream(
          current: check.current,
          until: { check.expected == $0 },
          interval: interval,
          timeout: timeout,
          isSame: check.isSame(_:_:)
        )
        var last: T?
        for await value in stream {
          last = value
          if check.expected == value {
            return .init(name: check.name, last: value, isSatisfied: true)
          }
        }
        return .init(name: check.name, last: last, isSatisfied: false)
      }
    }
    var out: [ItemResult<T>] = []
    for try await result in group {
      out.append(result)
    }
    return out
  }

  if results.allSatisfy(\.isSatisfied) { return }

  let lines = results.map { result -> String in
    let check = checks.first { $0.name == result.name }
    guard let check else {
      return "• \(result.name): (unknown check)"
    }
    return result.isSatisfied
      ? "• \(result.name): satisfied (last=\(result.last.map(check.describe) ?? "nil"))"
      : "• \(result.name): ✗ timeout (last=\(result.last.map(check.describe) ?? "nil"), \(check.debugExpectedDescription()))"
  }.joined(separator: "\n")

  throw EventuallyTimeoutError(
    label: label,
    message: "Timed out waiting for all checks.\n" + lines
  )
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
      .init(name: "A Count", expected: 1, current: { count.aCallCount }),
      .init(name: "B Count", expected: 1, current: { count.bCallCount }),
    ],
    timeout: 5.0
  )
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

## 전체 코드 - [Gist](https://gist.github.com/minsOne/91b0538ba95df9dffd0dd6306f9f3f04)

```swift
public struct EventuallyTimeoutError: Error, CustomStringConvertible {
  public let label: String
  public let message: String
  public var description: String { label.isEmpty ? message : "[\(label)] \(message)" }
  public init(label: String = "", message: String) {
    self.label = label
    self.message = message
  }
}

func makePollingStream<T: Sendable>(
  current: @escaping @Sendable () async -> T,
  until: @escaping @Sendable (T) -> Bool,
  interval: Duration = .milliseconds(20),
  timeout: Duration = .seconds(2),
  isSame: (@Sendable (T, T) -> Bool)? = nil
) -> AsyncStream<T> {
  let (stream, continuation) = AsyncStream<T>.makeStream(of: T.self)
  let clock = ContinuousClock()
  Task {
    let start = clock.now
    var last: T? = nil

    var now = await current()
    continuation.yield(now)
    last = now
    if until(now) {
      continuation.finish()
      return
    }

    while clock.now - start < timeout {
      try? await clock.sleep(for: interval)
      now = await current()

      if let cmp = isSame, let prev = last {
        if cmp(now, prev) == false {
          continuation.yield(now)
          last = now
        }
      } else {
        continuation.yield(now)
        last = now
      }

      if until(now) { break }
    }
    continuation.finish()
  }
  return stream
}

public func assertEventually<T: Sendable>(
  _ label: String = "",
  current: @escaping @Sendable () async -> T,
  until: @escaping @Sendable (T) -> Bool,
  timeout: TimeInterval = 2.0,
  interval: TimeInterval = 0.02,
  isSame: (@Sendable (T, T) -> Bool)? = nil,
  describe: @escaping (T) -> String = { "\($0)" }
) async throws {
  let stream = makePollingStream(
    current: current,
    until: until,
    interval: .seconds(interval),
    timeout: .seconds(timeout),
    isSame: isSame
  )

  var last: T?
  for await v in stream {
    last = v
    if until(v) { return }
  }
  throw EventuallyTimeoutError(
    label: label,
    message: "Timed out. last=\(last.map(describe) ?? "nil")"
  )
}

public func assertEventuallyEqual<T: Equatable & Sendable>(
  _ expected: T,
  _ current: @escaping @Sendable () async -> T,
  label: String = "",
  timeout: TimeInterval = 2.0,
  interval: TimeInterval = 0.02,
  describe: @escaping (T) -> String = { "\($0)" }
) async throws {
  try await assertEventually(
    label,
    current: current,
    until: { $0 == expected },
    timeout: timeout,
    interval: interval,
    isSame: { $0 == $1 },
    describe: { "value=\(describe($0)), expected=\(expected)" }
  )
}

public struct Check<T: Sendable & Equatable>: Sendable {
  let name: String
  let expected: T
  let current: @Sendable () async -> T
  let describe: @Sendable (T) -> String

  public init(
    name: String,
    expected: T,
    current: @escaping @Sendable () async -> T,
    describe: @escaping @Sendable (T) -> String = { "\($0)" }
  ) {
    self.name = name
    self.current = current
    self.expected = expected
    self.describe = describe
  }

  public func isSame(_ lhs: T, _ rhs: T) -> Bool {
    lhs == rhs
  }

  public func debugExpectedDescription() -> String {
    "expected=\(describe(expected))"
  }
}

struct ItemResult<T: Sendable>: Sendable {
  let name: String
  let last: T?
  let isSatisfied: Bool
}

public func assertEventuallyAllEqual<T: Sendable>(
  _ checks: [Check<T>],
  label: String = "",
  timeout: TimeInterval = 2.0,
  interval: TimeInterval = 0.02,
) async throws {
  let results: [ItemResult<T>] = try await withThrowingTaskGroup(of: ItemResult<T>.self) { group in
    for check in checks {
      group.addTask {
        let stream = makePollingStream(
          current: check.current,
          until: { check.expected == $0 },
          interval: .seconds(interval),
          timeout: .seconds(timeout),
          isSame: check.isSame(_:_:)
        )
        var last: T?
        for await value in stream {
          last = value
          if check.expected == value {
            return .init(name: check.name, last: value, isSatisfied: true)
          }
        }
        return .init(name: check.name, last: last, isSatisfied: false)
      }
    }
    var out: [ItemResult<T>] = []
    for try await result in group {
      out.append(result)
    }
    return out
  }

  if results.allSatisfy(\.isSatisfied) { return }

  let lines = results.map { result -> String in
    let check = checks.first { $0.name == result.name }
    guard let check else {
      return "• \(result.name): (unknown check)"
    }
    return result.isSatisfied
      ? "• \(result.name): satisfied (last=\(result.last.map(check.describe) ?? "nil"))"
      : "• \(result.name): ✗ timeout (last=\(result.last.map(check.describe) ?? "nil"), \(check.debugExpectedDescription()))"
  }.joined(separator: "\n")

  throw EventuallyTimeoutError(
    label: label,
    message: "Timed out waiting for all checks.\n" + lines
  )
}
```
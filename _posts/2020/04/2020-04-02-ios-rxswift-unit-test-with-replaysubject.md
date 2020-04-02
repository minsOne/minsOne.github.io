---
layout: post
title: "[iOS][RxSwift 5.1] Unit Test 작성시 ReplaySubject의 createUnbounded를 이용하여 모든 이벤트를 저장하고 비교 테스트하기"
description: ""
category: "iOS/Mac"
tags: [iOS, RxSwift, Unit Test, ReplaySubject, createUnbounded, Buffer, toBlocking, Async, expectation, XCTestExpectation, wait, waitForExpectations]
---
{% include JB/setup %}

Unit Test에서 비동기를 테스트할 때, expectation을 이용하여 비동기의 응답값을 테스트 합니다. 

```
// 간단한 비동기 예제 코드
func test_async() {
  var a: Int?
  let exp = expectation(description: "Async Test")

  DispatchQueue.main.after(when: 1) {
    a = 1
    exp.fulfill()
  }

  wait(for: [exp], timeout: 3)
  XCTAssertEqual(a, 1)
}
```

조금 극단적이지만, 비동기 테스트를 할 때 위와 같은 방식으로 테스트 합니다.

RxSwift에서는 RxTest에서 제공하는 `toBlocking` 이라는 연산자를 이용하여 테스트 할 수 있습니다.

```
func test_async() {
  let expectedResult = [1,2,3]

  XCTAssertEqual(
    try Observable.from([1,2,3])
      .toBlocking(timeout: 1)
      .toArray(),
    expectedResult
  )
}
```

위와 같이 `toBlocking`을 이용하여 이벤트를 모아 예상되는 결과와 비교할 수 있습니다.

구독 시점과 이벤트가 발행되는 시점이 다른 경우는 어떻게 해야할까요? 예를 들어, 구현체가 특정 조건을 따르는 Mock을 호출했을 때 호출이 몇번 되었는지 확인하는 테스트를 작성합니다.

```
protocol Listener: class {
  func call(value: Int)
}

class A {
  weak var listener: Listener?
  init() {}
}

class ListenerMock: Listener {
  var callCount = 0
  var callHandler: ((Int) -> Void)?

  init() {}

  func call(value: Int) {
    callCount += 1
    callHandler?(value)
  }
}

func test_async() {
  let listener = ListenerMock()
  let a = A()
  a.listener = listener
  a.listener?.call(value: 1)
}
```

위와 같이 A 클래스는 Listener를 변수로 가지며, Listener를 Mock으로 만들어서 A 에 주입할 수 있습니다. 그리고 listener의 call 함수를 호출합니다.

우리가 만든 ListenerMock이 제대로 호출되었는지 테스트를 할 수 있습니다.

```
XCTAssertEqual(listener.callCount, 1)
```

하지만 함수가 호출되었을 때, 특별한 행위를 해야하는 경우는 Mock의 callHandler에 Closure를 할당해야합니다.

```
listener.handler = { value in
  print(value)
}
```

만약 여러번이 호출되었다면 그 값을 저장한 후, 예측 결과와 비교를 하도록 테스트 해야합니다.

```
func test_async() {
  let exp = expectation(description: "Async Test")

  let expectedResults = [1,2,3]
  var actuallyResults = []

  listener.callHandler = { value in
    actuallyResults += [value]
    if expectedResults.count == actuallyResults { exp.fulfill() }
  }

  a.listener?.call(value: 1)
  a.listener?.call(value: 2)
  a.listener?.call(value: 3)

  wait(for: [exp], timeout: 3)
  XCTAssertEqual(expectedResults, expectedResults)
}
```

위와 같이 테스트 코드를 작성해야 하며, exp를 fulfill() 호출을 해야 timeout이 발생하지 않습니다. 점점 테스트 코드 작성하기가 복잡해집니다. 이는 테스트 시점의 이벤트를 저장하고 있어야하여 발생한 문제입니다.

따라서 `ReplaySubject`의 `createUnbounded`를 이용하여 모든 이벤트를 저장하여 테스트하도록 작성해봅시다.

```
class ListenerMock: Listener {
  private var relay = ReplaySubject<Int>.createUnbounded()
  var stream: Observable<Int> { relay }

  init() {}

  func call(value: Int) {
    relay.onNext(value)
  }
}

func test_async() {
  let listener = ListenerMock()

  let expectedResults = [1,2,3]

  let a = A()
  a.listener = listener

  a.listener?.call(value: 1)
  a.listener?.call(value: 2)
  a.listener?.call(value: 3)

  XCTAssertEqual(
    try listener.stream
      .take(expectedResults.count)
      .toBlocking(timeout: 1)
      .toArray(),
    expectedResults
    )
}
```

`ReplaySubject`가 모든 이벤트를 저장하므로, A 객체의 listener로 call 함수를 호출하고나서 그 뒤에 Stream을 구독하여 예측되는 결과와 비교하여 테스트를 할 수 있습니다.

시점이 다르더라도 모든 이벤트를 저장하고 있어, 테스트가 가능하므로 `expectation`를 이용한 비동기 테스트 코드를 작성할 필요가 없어집니다.

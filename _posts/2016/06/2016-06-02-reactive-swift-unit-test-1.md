---
layout: post
title: "[ReactiveX][RxSwift]Unit Test 1 - 핫 옵저버블과 콜드 옵저버블"
description: ""
category: "programming"
tags: [swift, ReactiveX, RxSwift, RxTests, Observable, Hot Observables, Cold Observables, TestScheduler, hot, cold]
---
{% include JB/setup %}

여러 이벤트들이 발생할 때, 제대로 파악하지 못한다면 흐름이 뒤엉켜 내가 원하는 작업을 제대로 수행하지 못합니다. 기존에 작성하던 방식대로 내가 흐름을 제어하면 괜찮지만, Rx에 일임하여 추상적으로 될 수 밖에 없습니다.

그래서 RxSwift는 지정한 시간에 아이템을 전달하고, 비교해볼 수 있도록 `RxTests`를 제공합니다. 

그러면 첫번째로, Hot Observables과 Cold Observables의 Unit Test를 작성해보도록 합시다.

### Hot Observables

TestScheduler를 생성하고, 지정한 시간에 전달할 아이템을 가지는 Hot Observable을 만듭니다.

```swift
	let scheduler = TestScheduler(initialClock: 0)
	let xs = scheduler.createHotObservable([
		.next(150, 1),
		.next(210, 0),
		.next(220, 1),
		.next(230, 2),
		.next(240, 4),
		.completed(300)
	])
	let res = scheduler.start { xs.map { $0 * 2 } }
```

가상 시간 150, 210, 220, 230, 240에 아이템 1, 0, 1, 2, 4가 전달되며, 가상 시간 300에 종료됩니다.

TestScheduler가 시작하면서, map 함수으로 아이템 값을 2배 만듭니다. 그리고 가상 시간 순으로 이벤트를 기록하여 저장합니다.

<br/>다음은 시간순으로 기록된 이벤트와 우리가 예상한 결과가 일치하는지 예상 결과를 선언하고 비교합니다.

```
	let correctMessages = [
		.next(210, 0 * 2),
		.next(220, 1 * 2),
		.next(230, 2 * 2),
		.next(240, 4 * 2),
		.completed(300)
	]

	let correctSubscriptions = [
		Subscription(200, 300)
	]

	XCTAssertEqual(res.events, correctMessages)
	XCTAssertEqual(xs.subscriptions, correctSubscriptions)
```

TestScheduler가 시작할 때생성, 구독, dispose의 가상 시간을 별도로 설정하지 않는다면, 생성은 100, 구독은 200, dispose는 1000으로 지정됩니다. 

correctMessages에 `next(150, 1 * 2)`이 포함되어야 하지만, 가상 시간을 지정하지 않았기 때문에 구독 시간이 200으로 지정되어 `next(150, 1 * 2)`이 포함되지 않습니다. 

이는 구독 여부에 상관없이 아이템을 발행하는 Hot Observable의 특징으로 인한 것입니다.

그리고 기본 구독 시간이 200이며, 이벤트가 300에 종료되므로 구독은 200에서 시작하고 300에서 종료됩니다.


### Cold Observables

Hot Observable은 구독 여부에 상관없이 아이템을 발행하므로, 구독이 추가되더라도 이전의 아이템을 전달 받을 수 없습니다. 그러나 Cold Observable은 구독을 해야 아이템을 발행합니다.

```swift
	let scheduler = TestScheduler(initialClock: 0)

	let xs1 = scheduler.createColdObservable([
		.next(10, 1),
		.next(20, 2),
		.next(30, 3),
		.completed(100)
		])

	let res = scheduler.start { xs.map { $0 * 2 } }
```

Hot Observable이 아닌 Cold Observable이기 때문에 구독한 후에 아이템을 발행합니다. 기본 구독 시간이 200이므로 가상 시간 210, 220, 230에 아이템이 발행되며, 300에 완료됩니다.

다음에서 우리가 예상한 가상 시간과 아이템 값이 일치하는지 확인할 수 있습니다.

```swift
	XCTAssertEqual(res.events, [
		.next(210, 1 * 2),
		.next(220, 2 * 2),
		.next(230, 3 * 2),
		.completed(300)
		])

	XCTAssertEqual(xs1.subscriptions, [
		Subscription(200, 300)
		])
```

### 참고 자료

* [RxSwift](https://github.com/ReactiveX/RxSwift/)
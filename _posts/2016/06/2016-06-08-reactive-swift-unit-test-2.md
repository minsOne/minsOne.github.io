---
layout: post
title: "[ReactiveX][RxSwift]Unit Test 2 - Subject"
description: ""
category: "programming"
tags: [swift, ReactiveX, RxSwift, RxTests, Observable, Hot Observables, TestScheduler, Subject, BehaviorSubject]
---
{% include JB/setup %}

이전에 다루었던 Subject를 유닛 테스트하려고 합니다. Subject는 Observer와 Observable 두 역할을 수행할 수 있습니다. Subejct는 Observer 역할로서 하나 이상의 Observable을 구독하며, Observable 역할로 아이템을 내보낼 수 있습니다.

다음 조건으로 Subject가 제대로 동작하는지 확인합니다.

* Subject는 지정된 시간에 TestObservable Observable을 구독한다.
* Subject 3개를 만들고 TestScheduler Observable을 구독하고 있는 Subject를 구독한다.
* Subject는 일정 시간 후 구독을 해지한다.
* 전달 받은 아이템을 기록하고, 예상한 결과와 같은지 확인한다.


### Subject

TestScheduler를 생성하고, 지정한 시간에 전달할 아이템을 가지는 Hot Observable을 만듭니다.

```swift
	let scheduler = TestScheduler(initialClock: 0)
	let xs = scheduler.createHotObservable([
		next(70, 1),
		next(110, 2),
		next(220, 3),
		next(270, 4),
		next(340, 5),
		next(410, 6),
		next(520, 7),
		next(630, 8),
		next(710, 9),
		next(870, 10),
		next(940, 11),
		next(1020, 12)
	])
```

<br/>TestScheduler Observable을 구독할 BehaviorSubject를, BehaviorSubject를 구독할 BehaviorSubject 3개는 미리 생성합니다.

```swift
	// TestObservable TestObservable을 구독할 BehaviorSubject 선언
	var subject: BehaviorSubject<Int>! = nil
	var subscription: Disposable! = nil

	// BehaviorSubject을 구독할 Observer 생성
	let results1 = scheduler.createObserver(Int)
	var subscription1: Disposable! = nil

	let results2 = scheduler.createObserver(Int)
	var subscription2: Disposable! = nil

	let results3 = scheduler.createObserver(Int)
	var subscription3: Disposable! = nil
```

<br/>TestScheduler Observable을 구독하는 Subject는 가상 시간 100에 생성, 가상 시간 200에 TestScheduler Observable을 구독하고, 가상 시간 1000에 구독 해지합니다.

```swift
	scheduler.scheduleAt(100) { subject = BehaviorSubject<Int>(value: 100) }
	scheduler.scheduleAt(200) { subscription = xs.subscribe(subject) }
	scheduler.scheduleAt(1000) { subscription.dispose() }
```

<br/>TestScheduler Observable을 구독하는 Subject를 구독하는 Subject 3개(!!!)는 가상 시간 300, 400, 900에 구독하고, 가상 시간 600, 700, 950에 구독 해지합니다.

```swift
	scheduler.scheduleAt(300) { subscription1 = subject.subscribe(results1) }
	scheduler.scheduleAt(400) { subscription2 = subject.subscribe(results2) }
	scheduler.scheduleAt(900) { subscription3 = subject.subscribe(results3) }

	scheduler.scheduleAt(600) { subscription1.dispose() }
	scheduler.scheduleAt(700) { subscription2.dispose() }
	scheduler.scheduleAt(800) { subscription1.dispose() }
	scheduler.scheduleAt(950) { subscription3.dispose() }
```

<br/>TestScheduler를 시작합니다. 이제 Subject를 구독하는 Subject 3개는 우리가 예상한 결과와 맞게 반환했는지 확인해봅시다. BehaviorSubject는 구독 후에 가장 최근 아이템을 전달하므로 BehaviorSubject 특징에 맞게 Assert 코드를 작성해야 합니다.

```swift
	scheduler.start()

	XCTAssertEqual(results1.events, [
		next(300, 4),
		next(340, 5),
		next(410, 6),
		next(520, 7)
		])

	XCTAssertEqual(results2.events, [
		next(400, 5),
		next(410, 6),
		next(520, 7),
		next(630, 8)
		])

	XCTAssertEqual(results3.events, [
		next(900, 10),
		next(940, 11)
		])
```

### 참고 자료

* [RxSwift](https://github.com/ReactiveX/RxSwift/)

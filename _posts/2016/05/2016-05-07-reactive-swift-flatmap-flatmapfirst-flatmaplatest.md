---
layout: post
title: "[ReactiveX][RxSwift]flatMap, flatMapFirst, flatMapLatest"
description: ""
category: "programming"
tags: [swift, ReactiveX, RxSwift, flatMap, flatMapFirst, flatMapLatest, Observable]
---
{% include JB/setup %}

### flatMap

Rx에서 Observable에서 발행한 아이템을 다른 Observable로 만들며, 만들어진 Observable에서 아이템을 발행합니다.

<img src="https://farm8.staticflickr.com/7567/26230104214_635e66ac0b_z.jpg" width="640" height="310" alt="flatMap"><br/>

RxSwift에서 제공하는 예제를 살펴보면 좀 더 쉽게 이해할 수 있습니다.

	let sequenceInt = Observable.of(1, 2, 3)	// Int 타입 시퀀스
	let sequenceString = Observable.of("A", "B", "C", "D")	// String 타입 시퀀스

	sequenceInt
		.flatMap { (x: Int) -> Observable<String> in
			print("Emit Int Item : \(x)")
			return sequenceString
		}
		.subscribeNext {
			print("Emit String Item : \($0)")
	}

	// Output
	Emit Int Item : 1
	Emit String Item : A
	Emit String Item : B
	Emit String Item : C
	Emit String Item : D
	Emit Int Item : 2
	Emit String Item : A
	Emit String Item : B
	Emit String Item : C
	Emit String Item : D
	Emit Int Item : 3
	Emit String Item : A
	Emit String Item : B
	Emit String Item : C
	Emit String Item : D

위의 코드에서 sequenceInt는 Int 아이템을 발생을 하며, flatMap을 통해 새로운 String 타입 Observable 시퀀스를 반환합니다. 

즉, sequenceInt에서 발행한 아이템에서 새로운 Observable을 만들고, 발행한 아이템을 구독하여 출력합니다.

만약 flatMap으로 비동기 Observable을 반환하면 어떻게 될까요?

다음은 타이머 Observable을 만드는 코드입니다.

```swift
	let t = Observable<Int>
		.interval(0.5, scheduler: MainScheduler.instance)	// 0.5초마다 발행
		.take(4)		// 4번 발행

	t.flatMap { (x: Int) -> Observable<Int> in
		let newTimer = Observable<Int>
			.interval(0.2, scheduler: MainScheduler.instance)	// 0.2초마다 발행
			.take(4)		// 4번 발행
			.map { _ in x }		// 전달받은 아이템을 그대로 전달
		return newTimer
		}
		.subscribe {
			print("Result : \($0)")
	}

	// Output
	Result : Next(0)
	Result : Next(0)
	Result : Next(0)
	Result : Next(1)
	Result : Next(0)
	Result : Next(1)
	Result : Next(1)
	Result : Next(2)
	Result : Next(1)
	Result : Next(2)
	Result : Next(2)
	Result : Next(3)
	Result : Next(2)
	Result : Next(3)
	Result : Next(3)
	Result : Next(3)
	Result : Completed
```

위의 코드가 실행되면, flatMap으로 만들어진 타이머 Observable로 인해 0.5초 간격으로 여러 개의 Observable이 동시에 수행하게 됩니다.

위 코드 실행 결과로 다음과 같은 스트림 형태를 나타낼 수 있습니다.

```swift
	t    : ----------0---------1----------2----------3X
	new0 :           ---0---0---0---0x
	new1 :                     ---1---1---1---1x
	new2 :                                ---2---2---2---2x
	new3 :                                           ---3---3---3---3X
	subs : -------------0---0---0-1-0-1---1--21--2---2--32--3---3---3x
```



### flatMapFirst

flatMapFirst는 flatMap과 마찬가지로 새로운 Observable을 만들지만, 새로운 Observable은 동작이 다 끝날 때 까지 새로 발행된 아이템을 무시합니다.

<!-- flamapfirst 이미지 -->
<img src="https://farm8.staticflickr.com/7090/26249223923_1e42d18ae7_z.jpg" width="640" height="266" alt="flatmapfirst"><br/>

위 이미지를 살펴보면, 빨강색 아이템이 발행되고 `flatMapFirst`를 통해 여러 개의 아이템이 발행합니다. 파란색 아이템은 발행되더라도 새로운 Observable에서 빨강색 아이템이 아직 발행이 끝나지 않았기 때문에 무시됩니다. 빨강색 아이템 모두 발행이 끝난 후, 노란색 아이템이 발행되면 무시되지 않고 `flatMapFirst`를 통해 아이템을 발행합니다.

다음 코드를 통해 flatMapFirst를 살펴보도록 합시다.

```swift
	let t = Observable<Int>
		.interval(0.5, scheduler: MainScheduler.instance)	// 0.5초마다 발행
		.take(4)		// 4번 발행

	t.flatMap { (x: Int) -> Observable<Int> in
		let newTimer = Observable<Int>
			.interval(0.2, scheduler: MainScheduler.instance)	// 0.2초마다 발행
			.take(4)		// 4번 발행
			.map { _ in x }		// 전달받은 아이템을 그대로 전달
		return newTimer
		}
		.subscribe {
			print("Result : \($0)")
	}

	// Output
	Result : Next(0)
	Result : Next(0)
	Result : Next(0)
	Result : Next(0)
	Result : Next(2)
	Result : Next(2)
	Result : Next(2)
	Result : Next(2)
	Result : Completed
```

위 코드에서 0.5초마다 아이템을 발행하며, flatMapFirst에서 0.2초마다 발행한 아이템을 4번 재발행합니다. 0.2초마다 아이템을 발행하는 새로운 Observable 때문에 0.5초 후에 아이템 1을 발행하더라도, 새로운 Observable이 수행중이므로 아이템 1은 무시됩니다. 그리고, 아이템 2가 발행되면 새로운 Observable은 4번 발행을 했기 때문에 무시되지 않고 다시 새로운 Observable을 만듭니다.

위 코드 실행 결과로 다음과 같은 스트림 형태를 나타낼 수 있습니다.

```swift
	t    : ----------0----------1----------2----------3X
	new0 :           ---0---0---0---0x
	new2 :                                 ---2---2---2---2X
	subs : -------------0---0---0---0---------2---2---2---2x
```

### flatMapLatest

flatMapLatest는 새로운 Observable을 만들고, 새로운 Observable이 동작하는 중에 새로 발행된 아이템이 전달되면, 만들어진 Observable은 dispose하고 새로운 Observable을 만듭니다.

<!-- flatmaplatest 이미지 -->
<img src="https://farm8.staticflickr.com/7032/26759629302_46b51c4526_z.jpg" width="640" height="350" alt="flatMapLatest"><br/>

위 이미지를 살펴보면, 녹색 아이템이 발행되고 연이어 파란색 아이템이 발행됩니다. 녹색 아이템에서 만들어진 Observable이 아이템을 발행하다 파란색 아이템이 발행되면 녹색 아이템에서 만들어진 Observable을 dispose하고, 파란색 아이템에서 Observable이 만들어지고 아이템이 발행됩니다.

즉, flatMapFirst와는 다르게 flatMapLatest는 이전 Observable을 무시합니다.

다음 코드를 통해 flatMapLatest를 살펴보도록 합시다.

```swift
	let t = Observable<Int>
		.interval(0.5, scheduler: MainScheduler.instance)	// 0.5초마다 발행
		.take(4)		// 4번 발행

	t.flatMap { (x: Int) -> Observable<Int> in
		let newTimer = Observable<Int>
			.interval(0.2, scheduler: MainScheduler.instance)	// 0.2초마다 발행
			.take(4)		// 4번 발행
			.map { _ in x }		// 전달받은 아이템을 그대로 전달
		return newTimer
		}
		.subscribe {
			print("Result : \($0)")
	}


	// Output
	Result : Next(0)
	Result : Next(0)
	Result : Next(1)
	Result : Next(1)
	Result : Next(2)
	Result : Next(2)
	Result : Next(3)
	Result : Next(3)
	Result : Next(3)
	Result : Next(3)
	Result : Completed
```

flatMapFirst와는 다르게 모든 아이템 0,1,2,3이 발행된 것을 알 수 있습니다. 이는 flatMapFirst와는 다르게 새로운 Observable이 있더라도 dispose하고 새로운 Observable을 만든다는 것을 알 수 있습니다.

위 코드 실행 결과로 다음과 같은 스트림 형태를 나타낼 수 있습니다.

```swift
	t    : ----------0---------1----------2----------3X
	new0 :           ---0---0--x
	new1 :                     ---1---1---x
	new2 :                                ---2---2---x
	new3 :                                           ---3---3---3---3X
	subs : -------------0---0-----1---1------2---2------3---3---3---3x
```

### 정리

아이템을 발행하고, 아이템을 어떻게 다룰지에 따라 다양한 조합을 만들 수 있습니다.
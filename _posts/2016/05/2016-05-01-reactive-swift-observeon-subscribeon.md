---
layout: post
title: "[ReactiveX][RxSwift]observeOn, subscribeOn - 작업 스레드 지정하기"
description: ""
category: "programming"
tags: [swift, ReactiveX, RxSwift, Observable, observeOn, subscribe, subscribeOn]
---
{% include JB/setup %}

Rx를 다루다보면 observeOn과 subscribeOn을 같이 쓸 일이 많은데, 이를 정리하고자 합니다.

### ObserveOn, SubscribeOn

observeOn은 Observable이 아이템을 전파할 때, 사용할 스레드를 지정합니다. subscribeOn은 구독(subscribe)에서 사용할 스레드를 지정합니다.

예를 들어, Observable은 네트워크 연결하고, 결과를 받으며, 구독에서 결과를 처리합니다. 그러면 Observable은 백그라운드 스레드에서 네트워크 요청 작업을 수행하고, 구독은 결과를 화면에 보여주기 위해 메인 스레드에서 수행합니다.

Observable은 백그라운드 스레드에서 동작하도록 observeOn으로 백그라운드 스레드를 지정하고, 구독은 메인 스레드에서 동작하도록 subscribeOn으로 메인 스레드를 지정합니다.

따라서 다음과 같이 코드를 작성할 수 있습니다.

```swift
	let backgroundScheduler = SerialDispatchQueueScheduler(globalConcurrentQueueQOS: .Default)
	[1,2,3,4,5]
		.toObservable()
		.observeOn(backgroundScheduler)
		.map { $0 * 2 }
		.subscribeOn(MainScheduler.instance)
		.subscribeNext {
			print("Result : \($0)")
		}
		
	// Output
	Result : 2
	Result : 4
	Result : 6
	Result : 8
	Result : 10
```

<br/>
시퀀스(Sequence)는 아이템을 전파하고, 그 아이템을 구독하여 출력합니다. 그렇다면 시퀀스 아이템을 2배 곱한 아이템을 묶은 후, 다시 전파하려면 어떻게 해야할까요?

observeOn을 추가하면 됩니다. 다음 코드로 살펴보도록 합시다.

```swift
	[1,2,3,4,5]
		.toObservable()
		.observeOn(backgroundScheduler)
		.map { n -> Int in
			print("This is performed on background scheduler")
			return n * 2
		}
		.observeOn(backgroundScheduler)
		.subscribeOn(MainScheduler.instance)
		.subscribeNext {
			print("Result : \($0)")
		}

	// Output
	This is performed on background scheduler
	This is performed on background scheduler
	This is performed on background scheduler
	This is performed on background scheduler
	This is performed on background scheduler
	Result : 2
	Result : 4
	Result : 6
	Result : 8
	Result : 10
```

<br/>
출력 결과를 살펴보면, 시퀀스에서 아이템을 전파하더라도 바로 구독에서 처리하지 않고, 중간에서 아이템을 구독 받은후 전파하는 것을 확인할 수 있습니다.

그러면 map과 observeOn 사이, observeOn과 subscribeOn 사이에 debug를 추가하여 어떻게 진행되는지 살펴봅니다.

다음은 아이템이 전파되는 과정을 디버깅입니다.

```swift
	[1,2,3,4,5]
		.toObservable()
		.observeOn(backgroundScheduler)
		.map { n -> Int in
			print("This is performed on background scheduler")
			return n * 2
		}
		.debug()
		.observeOn(backgroundScheduler)
		.debug()
		.subscribeOn(MainScheduler.instance)
		.subscribeNext {
			print("Result : \($0)")
		}


	// Output
	(DEBUG) subscribed
	(DEBUG) subscribed
	This is performed on background scheduler
	(DEBUG) Event Next(2)
	This is performed on background scheduler
	(DEBUG) Event Next(4)
	This is performed on background scheduler
	(DEBUG) Event Next(6)
	This is performed on background scheduler
	(DEBUG) Event Next(8)
	This is performed on background scheduler
	(DEBUG) Event Next(10)
	(DEBUG) Event Completed
	(DEBUG) Event Next(2)
	Result : 2
	(DEBUG) Event Next(4)
	Result : 4	
	(DEBUG) Event Next(6)
	Result : 6
	(DEBUG) Event Next(8)
	Result : 8
	(DEBUG) Event Next(10)
	Result : 10
	(DEBUG) Event Completed
	(DEBUG) disposed
	(DEBUG) disposed
```

<br/>
디버깅 된 결과를 살펴보도록 합시다. 출력 결과의 4번째 줄 `(DEBUG) Event Next(2)`는 map을 통해 2배가 된 아이템이 전파되고 있음을 알 수 있습니다. 그리고 13번째 줄 `(DEBUG) Event Completed`에서 아이템 전파가 끝났음을 알 수 있습니다. 

Observable은 구독 역할도 가능하기 때문에, 전파받은 아이템을 시퀀스 형태로 가지며, Observable에 구독이 추가되어 있으므로, 2배가 된 아이템을 전파합니다. 14번째 줄 `(DEBUG) Event Next(2)`에서 아이템이 전파되고 있음을 확인할 수 있으며, 24번째 줄 `(DEBUG) Event Completed`에서 전파가 끝났음을 알 수 있습니다.

### 정리

* observeOn은 Observable이 작업할 스레드 지정, subscribeOn은 구독이 작업할 스레드 지정합니다.
* subscribeOn은 구독 앞에서 호출해도 되지만, observeOn보다 먼저 호출하여 어떤 스레드에서 구독 작업을 하는지 지정하는 것도 좋습니다.

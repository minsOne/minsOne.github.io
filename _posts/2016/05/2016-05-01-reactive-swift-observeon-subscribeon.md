---
layout: post
title: "[ReactiveX][RxSwift]Scheduler, observeOn, subscribeOn"
description: ""
category: "programming"
tags: [swift, ReactiveX, RxSwift, Observable, observeOn, subscribe, subscribeOn, Scheduler]
---
{% include JB/setup %}

Rx를 다루다보면 멀티스레드가 필요한 작업이 많아 observeOn과 subscribeOn을 같이 쓸 일이 많은데, 이를 정리하고자 합니다.

### Scheduler

멀티스레드를 사용하여 여러가지 작업을 Observable 연산자로 묶어 수행하는 경우가 있습니다. 가령 백그라운드 스레드에서는 네트워크 작업, 많은 연산이 필요한 작업을 해야하고, 화면에 보여주기 위해서는 메인 스레드에서 작업을 해야합니다.

이 작업들은 Observable 연산자로 묶어 만들 수 있으므로, 각각의 작업에 맞게 스레드 지정을 해야합니다.

Scheduler는 스레드를 가르키는 말입니다.

### ObserveOn, SubscribeOn

subscribeOn은 Observable이 동작하는 스케쥴러를 다른 스케쥴러로 지정하여 동작을 변경합니다. 

observeOn은 Observable이 Observer에게 알리는 스케쥴러를 다른 스케쥴러로 지정합니다.

다음 그림을 한번 살펴보죠.

<img src="https://farm8.staticflickr.com/7756/26417720444_7f391698b3_z.jpg" width="512" height="640" alt="schedulers"><br/><br/>

위 그림에서 subscribeOn은 시작하는 스케쥴러를 나타내는데, subscribeOn 호출 시점과 상관없이 적용됩니다. observeOn은 호출 시점 아래의 스케쥴러가 영향을 받은 것을 알 수 있습니다.

위 그림과는 조금 다르지만 observeOn을 여러번 사용하여 스케쥴러를 변경하는 코드를 작성할 수 있습니다.

```swift
	let backgroundScheduler = SerialDispatchQueueScheduler(globalConcurrentQueueQOS: .Default)

	[1,2,3,4,5].toObservable()
		.subscribeOn(MainScheduler.instance) 	// 1
		.doOnNext {
			UIApplication.sharedApplication().networkActivityIndicatorVisible = true
			return $0
		} 		// 2
		.observeOn(backgroundScheduler) // 3
		.flatMapLatest {
			HTTPBinDefaultAPI.sharedAPI.get($0)
		}		// 4
		.observeOn(MainScheduler.instance) 		// 5
		.subscribe {
			UIApplication.sharedApplication().networkActivityIndicatorVisible = false
			print($0)
		}		// 6
```

단계별로 살펴봅시다.

1. Observable이 동작하는 스케쥴러를 MainScheduler로 지정합니다.
2. 1에서 MainScheduler로 지정하였으므로, networkActivityIndicatorVisible를 표시할 때 MainScheduler에서 동작합니다.
3. Observable이 동작할 스케쥴러를 backgroundScheduler로 지정하여, 아래 Observable을 MainScheduler에서 backgroundScheduler로 지정합니다.
4. backgroundScheduler로 지정되었기 때문에, 네트워크 작업은 backgroundScheduler에서 동작합니다.
5. Observable이 동작할 스케쥴러를 MainScheduler로 지정하여, 아래 subscribe를 backgroundScheduler에서 MainScheduler로 지정합니다.
6. networkActivityIndicatorVisible를 표시하지 않을 때 MainScheduler에서 동작합니다.

### 정리

observeOn은 특정 작업의 스케쥴러를 변경할 수 있어 여러번 사용하고, subscribeOn은 Observable이 동작하는 스케쥴러를 바꾸기 때문에 가급적 한번만 사용하는 것이 좋습니다.

### 참조

* [ReactiveX - subscribeOn](http://reactivex.io/documentation/operators/subscribeon.html)
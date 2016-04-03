---
layout: post
title: "[ReactiveX][RxSwift]Reactive Programming - 1"
description: ""
category: "programming"
tags: [swift, ReactiveX, RxSwift, ReactiveCocoa, Reactive, RxJava, ui]
---
{% include JB/setup %}

# ReactiveX

Reactive Programing은 데이터 흐름을 기반으로 합니다. 이는 비동기 처리와 이벤트 기반 프로그램을 작성하는데 유용하며, 이를 지원하는 라이브러리가 `Reactive Extension(ReactiveX)`입니다.

ReactiveX가 지원하는 언어는 Java, Javascript, .NET, Swift등이 있으며, 여기에서 다룰 언어는 Swift이므로 [RxSwift](https://github.com/ReactiveX/RxSwift) 프로젝트를 사용합니다.

ReactiveX는 Observable 모델을 사용하여 옵저버 패턴을 확장하고 데이터와 이벤트의 순서를 지원합니다. 그리고 non-blocking I/O, 병렬 데이터 구조, 스레드 안전, 동기화 등이 구현되어 있습니다.

ReactiveX의 개념은 [여기](http://gaemi.github.io/android/2015/05/20/RxJava%20with%20Android%20-%201%20-%20RxJava%20사용해보기.html)에서 더 자세히 확인하실 수 있습니다. <!-- https://archive.is/CIcy3 -->

## RxSwift 사용하기

### 설치하기

[여기](https://raw.githubusercontent.com/ReactiveX/RxSwift/master/Documentation/Installation.md)에 에CocoaPods, Carthage, git submodule로 설치하는 방법이 있습니다.

### Observable

Observable을 통해 이벤트를 만들고, subscribe를 통해서 이벤트를 받아 처리할 수 있습니다.

	someObservable
	  .subscribe { (e: Event<Element>) in
	      print("Event processing started")
	      // processing
	      print("Event processing ended")
	  }

또한, 자신만의 Observable을 만들어 사용할 수 있습니다.

	func myJust<E>(element: E) -> Observable<E> {
	    return Observable.create { observer in
	        observer.on(.Next(element))
	        observer.on(.Completed)
	        return NopDisposable.instance
	    }
	}

	myJust(0)
	    .subscribeNext { n in
	      print(n)
	    }

### Event

RxSwift에서 Event는 다음을 사용합니다.

	enum Event<Element>  {
	    case Next(Element)      // next element of a sequence
	    case Error(ErrorType)   // sequence failed with error
	    case Completed          // sequence terminated successfully
	}

Error와 Completed가 발생하면 종료됩니다.

### Dispose

RxSwift에서 메모리 관리는 Subscription을 만든 후 `addDisposableTo(disposeBag)`을 통해서 자동으로 해제하는 방법과, dispose()를 호출하여 수동으로 해제하는 방법이 있습니다.

### subscription 공유

하나의 subscription에서 여러 개의 observable에 이벤트를 전파하고자 할 때 shareReplay를 사용하여 전파합니다.

	let counter = myInterval(0.1)
	    .shareReplay(1)

	print("Started ----")

	let subscription1 = counter
	    .subscribeNext { n in
	       print("First \(n)")
	    }
	let subscription2 = counter
	    .subscribeNext { n in
	       print("Second \(n)")
	    }

	NSThread.sleepForTimeInterval(0.5)

	subscription1.dispose()

	NSThread.sleepForTimeInterval(0.5)

	subscription2.dispose()

	print("Ended ----")

### Variables

`Variable`은 observable 상태를 나타내며, 값을 가지고 있어야 합니다. Variable에 asObservable 메소드 호출을 통해 값의 변경 사항을 계속 알 수 있습니다.

	let variable = Variable(0)

	print("Before first subscription ---")

	_ = variable.asObservable()
	    .subscribe(onNext: { n in
	        print("First \(n)")
	    }, onCompleted: {
	        print("Completed 1")
	    })

	print("Before send 1")

	variable.value = 1

	print("Before second subscription ---")

	_ = variable.asObservable()
	    .subscribe(onNext: { n in
	        print("Second \(n)")
	    }, onCompleted: {
	        print("Completed 2")
	    })

	variable.value = 2

	print("End ---")

### Threading

사실 Rx를 도입하여 사용하는 이유 중 하나는 값 변경에 따라 UI를 변경해주도록 하는 것도 있습니다. 따라서 UI에 반영하기 위해서는 Main Thread를 사용해야하며, `observeOn(MainScheduler.instance)`를 추가해야합니다.

	NSNotificationCenter.defaultCenter()
	    .rx_notification(UIKeyboardWillShowNotification)
	    .observeOn(MainScheduler.instance)
	    .subscribeNext { [weak self] noti in
	        guard let keyboardHeight = noti.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size.height else { return }
	        self?.showKeyboardAnimation(keyboardHeight)
	    }
	    .addDisposableTo(disposeBag)

### Driver

UI layer에서 좀 더 직관적으로 사용하기 위해 제공하는 unit입니다. Observable은 상황에 따라 Main Thread를 쓸지 Background Thread를 쓸지 지정해줘야 하지만, Driver는 Main Thread 상에서 동작을 하며 subscription 공유도 지원합니다.

다음 예제 코드에서 Observable과 Driver 차이를 살펴볼 수 있습니다.

case 1) Main Thread를 잘 다루지 못한 코드

	let results = query.rx_text
	    .throttle(0.3, scheduler: MainScheduler.instance)
	    .flatMapLatest { query in
	        fetchAutoCompleteItems(query)
	    }

	results
	    .map { "\($0.count)" }
	    .bindTo(resultCount.rx_text)
	    .addDisposableTo(disposeBag)

	results
	    .bindTo(resultsTableView.rx_itemsWithCellIdentifier("Cell")) { (_, result, cell) in
	        cell.textLabel?.text = "\(result)"
	    }
	    .addDisposableTo(disposeBag)

위 코드에서 보여지는 문제가 몇가지 있습니다. results라는 subscription은 resultCount, resultsTableView와 bind됩니다. 따라서 shareReplay(1)을 추가해줘야 합니다.

두번째로 fetchAutoCompleteItems가 호출된 후, 그 결과를 resultCount, resultsTableView에 반영하게 되는데 에러 등이 발생한 경우 등을 다루지 않았고, 결과를 UI에 반영해야하므로 Main Thread에서 동작해야 합니다. 

따라서 fetchAutoCompleteItems에 `.observeOn(MainScheduler.instance)`를 추가하여 Main Thread에서 동작하도록 하며, 에러에 대한 처리로 `.catchErrorJustReturn([])`를 추가하여 에러 발생을 UI에 반영할 수 있도록 합니다.

다음은 이를 적용한 코드입니다.

	let results = query.rx_text
	    .throttle(0.3, scheduler: MainScheduler.instance)
	    .flatMapLatest { query in
	        fetchAutoCompleteItems(query)
	            .observeOn(MainScheduler.instance) // results are returned on MainScheduler
	            .catchErrorJustReturn([])                // in worst case, errors are handled
	    }
	    .shareReplay(1)                                  // HTTP requests are shared and results replayed
	                                                     // to all UI elements

	results
	    .map { "\($0.count)" }
	    .bindTo(resultCount.rx_text)
	    .addDisposableTo(disposeBag)

	results
	    .bindTo(resultTableView.rx_itemsWithCellIdentifier("Cell")) { (_, result, cell) in
	        cell.textLabel?.text = "\(result)"
	    }
	    .addDisposableTo(disposeBag)

case 2) case 1을 Driver로 변경한 코드

	let results = query.rx_text.asDriver()        // This converts normal sequence into `Driver` sequence.
	    .throttle(0.3, scheduler: MainScheduler.instance)
	    .flatMapLatest { query in
	        fetchAutoCompleteItems(query)
	            .asDriver(onErrorJustReturn: [])  // Builder just needs info what to return in case of error.
	    }

	results
	    .map { "\($0.count)" }
	    .drive(resultCount.rx_text)               // If there is `drive` method available instead of `bindTo`,
	    .addDisposableTo(disposeBag)              // that means that compiler has proved all properties
	                                              // are satisfied.
	results
	    .drive(resultTableView.rx_itemsWithCellIdentifier("Cell")) { (_, result, cell) in
	        cell.textLabel?.text = "\(result)"
	    }
	    .addDisposableTo(disposeBag)
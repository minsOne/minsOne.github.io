---
layout: post
title: "[ReactiveX][RxSwift]Observable과 Driver"
description: ""
category: "programming"
tags: [swift, ReactiveX, RxSwift, Observable, Driver, asObservable, asDriver, MainScheduler]
---
{% include JB/setup %}

## Driver

RxSwift는 다른 언어의 Rx 구현체와는 다르게 Driver라는 unit을 제공합니다. 하지만 기본으로 Observable을 제공하기 때문에 Driver를 언제 써야 할 지 궁금했습니다.

Driver는 UI layer에서 좀 더 직관적으로 사용하도록 제공하는 unit입니다. Observable는 상황에 따라 MainScheduler와 BackgroundScheduler를 지정해줘야 하지만 Driver는 MainScheduler에서 사용합니다.

	var driverObserveOnScheduler: SchedulerType = MainScheduler.instance
	public func asDriver(onErrorDriveWith onErrorDriveWith: Driver<E>) -> Driver<E> {
	    let source = self
	        .asObservable()
	        .observeOn(driverObserveOnScheduler)
	        .catchError { _ in
	            onErrorDriveWith.asObservable()
	        }
	    return Driver(source)
	}

	public struct Driver<Element> : DriverConvertibleType {
	    public typealias E = Element

	    let _source: Observable<E>

	    init(_ source: Observable<E>) {
	        self._source = source.shareReplayLatestWhileConnected()
	    }
	}

RxSwift에서 asDriver가 구현된 코드를 살펴보면 observer에 MainScheduler를 사용하여 subscription 행동을 하는 것을 알 수 있습니다. 또한, Driver는 subscription 공유도 지원합니다.

다시, 그러면 언제 Observable 대신 Driver를 쓰는 것이 좋을까요? UI 관련된 것에는 Driver를 쓰는 것이 좋습니다. Observable을 쓰게 되면 Thread를 지정해줘야 하는데, 실수가 발생할 수도 있으니까요.


### Driver vs Observable 사용 예제

이제 언제 Driver를 써야 할 지를 예제로 살펴보도록 합시다.

#### UI에서 Driver, Observable 사용 예제

##### Driver

다음은 간단하게 username과 password가 입력되었는지 확인하고 로그인 버튼을 활성화하는 Driver를 사용한 코드입니다.

	// Using Driver
	let usernameValid = loginUsernameTextField.rx_text().asDriver().map { $0.utf8.count > 0 }
	let passwordValid = loginPasswordTextField.rx_text().asDriver().map { $0.utf8.count > 0 }

	let credentialsValid: Driver<Bool> = Driver.combineLatest(usernameValid, passwordValid) { $0 && $1 }

	credentialsValid.driveNext { [weak self] valid in
	    self?.loginBtn.enabled = valid
    }
    .addDisposableTo(disposeBag)

loginUsernameTextField와 loginPasswordTextField는 UI이므로 asDriver로 subscription을 만듭니다.

credentialsValid는 usernameValid와 passwordValid의 subscription을 combine으로 두 개의 결과를 AND 연산을 통해 활성화 여부를 내보냅니다. 

driveNext에서 loginBtn 버튼을 활성화 또는 비활성화합니다.<br/><br/>

##### Observable

다음은 Driver를 Observable로 바꾸어 사용했을 때의 코드입니다.
	
	// Using Observable
	let usernameValid = loginUsernameTextField.rx_text.asObservable().observeOn(MainScheduler.instance).shareReplay(1).map { $0.utf8.count > 0 }
	let passwordValid = loginPasswordTextField.rx_text.asObservable().observeOn(MainScheduler.instance).shareReplay(1).map { $0.utf8.count > 0 }

	let credentialsValid = Observable.combineLatest(usernameValid, passwordValid) { $0 && $1 }.observeOn(MainScheduler.instance)
	credentialsValid.subscribeNext { [weak self] valid in
	    self?.loginBtn.enabled = valid
	    }
	.addDisposableTo(disposeBag)

Observer에게 어떤 Scheduler를 사용할 것인지 일일이 다 지정을 해주며, subscription 공유도 설정해줘야 합니다. UI와 관련되었을 때는 Driver를 통해 작성하는 것이 훨씬 더 간편한 것을 알 수 있습니다.

<br/><br/>

#### MainScheduler, BackgroundScheduler에서 Driver, Observable 예제

##### Observable

다음은 MainScheduler와 BackgroundSchedule을 번갈아 가며 사용하는 Observable 예제입니다.

	// Using Observable	
	let results = query.rx_text
	    .throttle(0.3, scheduler: MainScheduler.instance)
	    .flatMapLatest { query in
	        fetchAutoCompleteItems(query)
	            .observeOn(MainScheduler.instance)
	            .catchErrorJustReturn([])
	    }
	    .shareReplay(1)

	results
	    .map { "\($0.count)" }
	    .bindTo(resultCount.rx_text)
	    .addDisposableTo(disposeBag)

	results
	    .bindTo(resultTableView.rx_itemsWithCellIdentifier("Cell")) { (_, result, cell) in
	        cell.textLabel?.text = "\(result)"
	    }
	    .addDisposableTo(disposeBag)

fetchAutoCompleteItems를 통한 결과를 MainScheduler로 받아서 처리해야 하며, subscription을 공유하기 위해 shareReplay를 사용해야 합니다.

##### Driver

다음은 Observable를 Driver로 바꾸어 사용했을 때의 코드입니다.

	// Using Driver	
	let results = query.rx_text.asDriver()
	    .throttle(0.3, scheduler: MainScheduler.instance)
	    .flatMapLatest { query in
	        fetchAutoCompleteItems(query)
	            .asDriver(onErrorJustReturn: [])
	    }

	results
	    .map { "\($0.count)" }
	    .drive(resultCount.rx_text)
	    .addDisposableTo(disposeBag)

	results
	    .drive(resultTableView.rx_itemsWithCellIdentifier("Cell")) { (_, result, cell) in
	        cell.textLabel?.text = "\(result)"
	    }
	    .addDisposableTo(disposeBag)

Driver를 사용하여 fetchAutoCompleteItems에 asDriver를 사용하여 observeOn을 사용하지 않고 MainScheduler를 사용하도록 하였으며, rx_text에 asDriver를 사용하여 subscription을 공유하고 있습니다.

### 정리

UI 관련된 subscription을 만들 때, Observable보다는 Driver를 사용하는 것이 좀 더 명확합니다.

### 출처

* [RxSwift](https://github.com/ReactiveX/RxSwift)
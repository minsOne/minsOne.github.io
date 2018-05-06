---
layout: post
title: "[Swift4][ReactiveX] 에러 쉽게 다루기"
description: ""
category: "Programming"
tags: [Swift, RxSwift, ReactiveKit, Observable, Stream, Event, Error]
---
{% include JB/setup %}

Rx에서 가장 까다로운 녀석이 Error를 다루는 것이 아닌가 생각합니다. 특히나 UI에 연결한 스트림이 Error이 발생하면 스트림이 깨집니다. 처음 Rx를 다룰 때, 이 것을 생각하지 못하고 막 작성하다가 갑자기 UI 이벤트가 발생하지 않아 어떻게 막막해집니다.

이와 관련하여 다양한 방법들이 있겠지만 현재 제가 사용하고 있는 방법을 소개할려고 합니다.

Stream 끊어서 사용하기, Error를 한 곳에서 다루기 입니다.

## Stream 끊어서 사용하기

Rx 코드를 작성하여 돌리다보면, UI 이 가끔씩 끊어질 때가 있다는 것을 발견할 수 있습니다. 그런 경우는 대개 Error 이벤트가 발행이 되어 Stream이 끊어지는 경우입니다. 만약 처음에 경험이 없거나 미숙한 경우, 이런 경우를 종종 겪게 됩니다.

이런 경우는 UI에 사용된 Rx 코드 중, Error 이벤트를 발행하는 코드를 별도로 호출하는 함수를 만들어서 처리하는 것입니다.

```
enum KError: Error { case user, system }

func publishError<R>() -> Observable<R> {
    return Observable.error(KError.system)
}
```

위 함수는 Error 이벤트를 발행하기 때문에, Stream이 끊어지는 것을 방지하기 위해 다음과 같이 코드를 작성할 수 있습니다.

```
--- before ---

button.rx.tap
    .flatMapLatest { [unowned self] in self.publishError() }
    .subscribe(onNext: { print("success") })
    .disposed(by: disposeBag)

--- after ---

button.rx.tap
    .subscribe(onNext: { [weak self] in self?.subscribePublishError() })
    .disposed(by: disposeBag)

func subscribePublishError() {
    publishError()
        .subscribe(onNext: { print("success") },
                   onError: { _ in print("error") })
        .disposed(by: disposeBag)
}    
```

위 코드처럼 작성하면 버튼을 계속 누르더라도 Stream이 끊어지지 않고 계속 이벤트가 발행됩니다.

## Error를 한 곳에서 다루기

이 방법은 Rx에서는 조금 애매한 방법입니다. ReactiveKit에서는 에러를 발행하지 못하도록 NoError라는 것이 있어 Error를 신경쓰지 않아도 되는 반면, Observable은 로직상에서 Error를 발행 안한다고 하더라도, 명시적으로 Error를 발행하지 못한다고 할 수 없습니다.

Error를 발행하는 PublishSubject를 만들어 에러는 이 Subject에다 발행하도록 합니다. 그러면 이 Subject만 구독하고, 어떤 에러가 들어왔는지만 안다면 쉽게 에러를 다룰 수 있게 됩니다.

Rx의 Event에서는 Swift.Error만 다루고 있으므로, PublishSubject는 Swift.Error 타입이 됩니다. 그리고 이 Subject를 구독합니다.

```
let errorSubject = PublishSubject<Swift.Error>()
```

Error를 한 곳에서 처리할 수 있도록 만들었으니, 기존 코드에서 이제 Error가 발행이 되면, errorSubject에 넘기는 코드를 작성해 봅시다.

첫 번째로 Error가 발행이 되면, Error를 무시하는 Operator가 필요합니다. 그래야 Stream이 깨지지 않기 때문입니다. retry를 살짝 응용하여 Error를 무시하는 Operator를 작성할 수 있습니다.

```
extension ObservableType {
    func suppressError() -> Observable<E> {
        return retryWhen { _ in return Observable<E>.empty()  }
    }
}
```

이제 앞에서 작성했던 Error를 발행하는 함수의 Error를 errorSubject에서 처리하도록 코드를 작성해봅시다.

```
button.rx.tap
    .flatMapLatest { [unowned self, unowned errorSubject] in
        self.publishError()
            .do(onError: { errorSubject.onNext($0) })
            .suppressError()
            .map { 1 }
    }
    .subscribe(onNext: {
        print("button : \($0)")
    })
    .disposed(by: disposeBag)

errorSubject
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
```

doonError를 통해 Error 이벤트를 errorSubject에 넘겨주고, suppressError가 Error로 인한 Stream 깨짐을 방지줍니다.

만약 `doonError` 와 `suppressError`를 쓰기 귀찮다면, 통합한 Operator를 만들 수 있습니다.

```
extension ObservableType {
    func suppressAndFeedError<S: ObserverType>(into listener: S) -> Observable<E> where S.E == Swift.Error {
        return `do`(onError: { listener.onNext($0) })
            .suppressError()
    }
}
```

`suppressAndFeedError` Operator를 이용하여 이전 코드를 아래와 같이 수정할 수 있습니다.

```
button.rx.tap
    .flatMapLatest { [unowned self, unowned errorSubject] in
        self.publishError()
            .suppressAndFeedError(into: errorSubject)
            .map { 1 }
    }
    .subscribe(onNext: {
        print("button : \($0)")
    })
    .disposed(by: disposeBag)
```

ps. RxSwift를 사용하지 않은지 오래되어 일부 방법이 맞지 않을 수 있으므로 참고하시기 바랍니다.

## 참고

* [ReactiveKit](https://github.com/DeclarativeHub/ReactiveKit)
* [RxSwiftExt](https://github.com/RxSwiftCommunity/RxSwiftExt)
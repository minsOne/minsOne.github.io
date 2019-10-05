---
layout: post
title: "[ReactiveX][RxSwift]Single Trait - 장단점"
description: ""
category: "programming"
tags: [swift, ReactiveX, RxSwift, Observable, asObservable, Single, asSingle]
---
{% include JB/setup %}

# Single

## 장점

RxSwift에서는 Single을 지원합니다. Single은 Obvservable의 한 형태이며, 한 가지의 값 또는 에러를 발행합니다. 그렇기에 Single을 구독시 success, error 두 개의 이벤트에 처리를 합니다.

```
func get(parameter: String) -> Single<[String : String]> {
	let requestURL = NSURL(string: url + "get?" + parameter)!

	return Single.create { observer -> Disposable in
		let s = NSURLSession.sharedSession().dataTaskWithURL(requestURL) {
			(data, response, error) in
			if let error = error {
				observer(.error(error))
			}
			guard let
				data = data,
				json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
				args = json["args"] as? [String:String]
				else {
					observer(.error(NSError(domain: "Error", code: 1, userInfo: nil)))
					return
			}
			observer(.success(args))
		}
		s.resume()
		return NopDisposable.instance
	}
}

get(parameter: "")
    .subscribe { event in
        switch event {
            case let .success(json):
                print("JSON: ", json)
            case let .error(error):
                print("Error: ", error)
        }
    }
    .disposed(by: disposeBag)
```

위의 예제처럼 Single을 사용하여 네트워크 요청을 구독하는 기능을 만들 수 있으며, 두 개의 이벤트만 처리하기 때문에 코드가 줄어듭니다. 그리고 간단 명료합니다.

## 단점

하지만 Single이 만능이 아닙니다. Stream에서 Single을 사용한다면 Single로 시작을 해야합니다. Observable로 시작해서 중간에 asSingle로 바꿔 Single을 엮는다거나 하게 되면 문제가 발생합니다.

Observable은 completed 이벤트를 발행하는데, Single은 completed 이벤트를 발행할 수 없습니다. 즉, Single의 이벤트인 success 자체가 next, completed 두 개의 성격을 다 포함하고 있기 때문에, completed 이벤트가 발행되었을 때 이전에 next 이벤트가 들어오지 않으면 에러를 전달하게 됩니다. [코드 1](https://github.com/ReactiveX/RxSwift/blob/master/RxSwift/Observables/SingleAsync.swift#L81)

또한, asSingle 오퍼레이터를 사용했을 때도 마찬가지로, completed 이벤트가 발행되었을 때 이전에 next 이벤트가 들어오지 않으면 에러를 전달하게 됩니다. [코드 2](https://github.com/ReactiveX/RxSwift/blob/master/RxSwift/Observables/AsSingle.swift#L32)

따라서 Single을 사용해야 한다면 반드시 Single로 시작하도록 하고, Observable로 시작한 경우 불필요한 에러를 발행할 수 있기 때문에 가급적 지양하는 것이 좋습니다.
---
layout: post
title: "[ReactiveX][RxSwift]비동기 작업을 스트림으로 만들기 - 네트워크 예제"
description: ""
category: "programming"
tags: [swift, ReactiveX, RxSwift, Observable, subscribeOn, observeOn]
---
{% include JB/setup %}

iOS에서 비동기 작업을 가장 많이 하는 것이 네트워크입니다. 네트워크를 한 번만 요청하는 것이 아니라, 요청한 결과를 받아 다시 요청해야 하거나, 동시에 여러 개를 요청하기도 합니다.

비동기 작업의 대표적인 네트워크 요청을 Rx 연산자를 통해 체이닝 형태로 만들어보려고 합니다.

### 비동기 작업

네트워크 테스트할 때 많이 사용하는 서비스인 HTTPBin을 사용합니다. HTTPBin의 GET은 요청한 인자를 그대로 반환해주는데, 이를 이용해서 인자를 계속 늘려서 결과를 받는 네트워크 작업을 할 것입니다.

다음 코드에서, HTTPBinAPI 프로토콜을 선언하고, HTTPBinDefaultAPI 클래스가 이를 구현합니다. 네트워크 요청 후 받은 결과 값에서 반환받은 인자를 그대로 넘겨줍니다.

```swift
	import UIKit
	import RxSwift
	import RxCocoa

	protocol HTTPBinAPI {
		func get(parameter: String) -> Observable<[String:String]>
	}

	class HTTPBinDefaultAPI: HTTPBinAPI {
		let url = "http://httpbin.org/"
		static let sharedAPI = HTTPBinDefaultAPI()

		func get(parameter: String) -> Observable<[String : String]> {
			let requestURL = NSURL(string: url + "get?" + parameter)!

			return Observable.create { observer -> Disposable in
				let s = NSURLSession.sharedSession().dataTaskWithURL(requestURL) {
					(data, response, error) in
					if let error = error {
						observer.onError(error)
					}
					guard let
						data = data,
						json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
						args = json["args"] as? [String:String]
						else {
							observer.onError(NSError(domain: "Error", code: 1, userInfo: nil))
							return
					}
					observer.onNext(args)
					observer.onComplete()
				}
				s.resume()
				return NopDisposable.instance
			}
		}
	}
```

<br/><br/>Dictionary를 확장하여 HTTPBin에 보낼 인자 문자열을 만듭니다.

```swift
	extension Dictionary where Key:StringLiteralConvertible, Value: StringLiteralConvertible {
		func toParameterString() -> String {
			guard let _self = (self as? AnyObject) as? Dictionary<String, String> else {
				return ""
			}
			if _self.count < 10 {
				return (1..._self.count+1).map { "\($0)=\($0)" }.joinWithSeparator("&")
			}
			return (1..._self.count).map { "\($0)=\($0)" }.joinWithSeparator("&")
		}
	}
```


<br/><br/>버튼과 라벨을 만든 후, 버튼을 누르면 네트워크 요청하여 결과 값을 라벨에 보여주도록 합니다.

```swift
	class ViewController: UIViewController {
		var label: UILabel!
		var disposeBag = DisposeBag()
		let backgroundScheduler = SerialDispatchQueueScheduler(globalConcurrentQueueQOS: .Background)

		override func viewDidLoad() {
			super.viewDidLoad()

			let btn1 = UIButton(frame: CGRectMake(100,100,100,100))
			btn1.backgroundColor = .redColor()
			self.view.addSubview(btn1)

			label = UILabel(frame: CGRectMake(100, 200, 300, 100))
			label.backgroundColor = .whiteColor()
			label.font = UIFont.systemFontOfSize(20)
			self.view.addSubview(label)

			btn1
				.rx_tap
				.subscribeOn(MainScheduler.instance)		// 1
				.map { [String:String]() }		// 2
				.doOnNext { [unowned self] _ in
					UIApplication.sharedApplication().networkActivityIndicatorVisible = true
					self.label.text = "Loading..."
				}		// 3
				.observeOn(backgroundScheduler)		// 4
				.flatMapLatest { p in
					HTTPBinDefaultAPI.sharedAPI.get(p.toParameterString()).retry(2)
						.observeOn(MainScheduler.instance)
						.doOnNext { [unowned self] p in
							self.label.text = "Done"
					}
				}		// 5
				.observeOn(MainScheduler.instance)		// 6
				.subscribe { [unowned self] s in
					UIApplication.sharedApplication().networkActivityIndicatorVisible = false
					guard let e = s.element else {
						self.label.text = ""
						return
					}
					self.label.text = e.description
				}		// 7
				.addDisposableTo(disposeBag)
		}
	}
```

단계적으로 위 코드를 살펴봅시다.

1. subscribeOn으로 Observable이 동작할 스케쥴러를 메인 스레드로 지정합니다.
2. rx_tap은 Void 아이템을 가지므로, HTTPBin에 인자를 넘겨주기 위해 빈 딕셔너리 아이템으로 만듭니다.
3. 네트워크 작업을 하기 전에 라벨에 Loading... 표시와 networkActivityIndicator를 표시합니다. 이는 subscribeOn이 메인 스레드를 지정하였기 때문에 가능합니다.
4. observeOn으로 Observable이 앞으로 동작할 스케쥴러를 백그라운드 스레드로 지정합니다.
5. 네트워크 작업을 수행하는데, retry를 추가하여 에러가 발행한다면 두 번까지 같은 작업을 수행합니다. 그리고 observeOn에 메인 스레드로 지정하여 라벨에 Done으로 표시합니다.
6. observeOn으로 Observable이 앞으로 동작할 스케쥴러를 메인 스레드로 지정합니다. 다음에 호출될 subscribe는 메인 스레드에서 동작합니다.
7. 결과를 라벨에 표시하고, networkActivityIndicator를 보여주지 않습니다.

<br/>지금까지는 어렵지 않았습니다. 그렇다면 인자를 계속 늘리면서 네트워크 작업을 요청은 어떻게 해야 할까요?

간단합니다. 네트워크 작업이 추가된 flatMapLatest를 붙이면 됩니다. 즉, 다음 코드가 반복해서 들어가면 되는 거죠.

```swift
	.flatMapLatest { p in
		HTTPBinDefaultAPI.sharedAPI.get(p.toParameterString()).retry(2)
			.observeOn(MainScheduler.instance)
			.doOnNext { [unowned self] p in
				self.label.text = p.description
		}
	}
	.flatMapLatest { p in
		HTTPBinDefaultAPI.sharedAPI.get(p.toParameterString()).retry(2)
			.observeOn(MainScheduler.instance)
			.doOnNext { [unowned self] p in
				self.label.text = p.description
		}
	}
```

[전체 코드](https://gist.github.com/minsOne/fddfa60bc13989bfd15707894f5d69b2)

<br/><img src="{{ site.production_url }}/image/flickr/26422927964_351a276f9d_z.jpg" width="349" height="640" alt="live"><br/>

이제 비동기 작업의 콜백 지옥에서 벗어나게 되었습니다.(다른 방법도 많지만,,) 스트림 형태로 만들기 때문에, 더더욱 데이터 흐름을 생각하면서 Rx 코드를 작성하게 됩니다.

### 참고

* [RxSwift](https://github.com/ReactiveX/RxSwift)

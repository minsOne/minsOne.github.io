---
layout: post
title: "[ReactiveX][RxSwift]Delegate 패턴을 Rx로 바꾸기"
description: ""
category: "programming"
tags: [swift, ReactiveX, RxSwift, DelegateProxy, DelegateProxyType, Delegate]
---
{% include JB/setup %}

RxCocoa를 사용하다보면, Delegate로 사용해야 할 메소드가 확장되어 사용되는 것을 볼 수 있습니다. 예를 들면, UITableView의 `didSelectRowAtIndexPath` 메소드를 감싼 rx_itemSelected 메소드 등이 있습니다.

Delegate에서 Observable 메소드로 변경하여, Rx에서 사용할 수 있도록 해봅시다. 예제로 사용할 CustomClassDelegate 프로토콜, CustomClass 클래스를 선언합니다.

```swift
	@objc protocol CustomClassDelegate: class {
		optional func willStart(customClass: CustomClass, _ str: String)
		optional func DidEnd(customClass: CustomClass, _ str: String)
	}

	class CustomClass: NSObject {
		weak var delegate: CustomClassDelegate? = nil
		func start() {
			self.delegate?.willStart!(self, "WillStart")
			(0...100).forEach { print($0) }
			self.delegate?.DidEnd!(self, "End")
		}
	}
```

CustomClass는 start 메소드를 호출하면, 자기 자신과 "WillStart" 문자열을 반복문 시작하기 전에 전달하고, 끝나면 자기자신과 "End" 문자열을 전달합니다.

이제 CustomClassDelegate 프로토콜과 CustomClass를 Rx에서 사용할 수 있도록 합니다.

### 1. DelegateProxy 설정

CustomClassDelegate의 인터페이스 역할을 수행합니다.

```swift
	public class RxCustomDelegateProxy: DelegateProxy, DelegateProxyType, CustomClassDelegate {
		public class func currentDelegateFor(object: AnyObject) -> AnyObject? {
			let custom: CustomClass = castOrFatalError(object)
			return custom.delegate
		}
		public class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
			let custom: CustomClass = castOrFatalError(object)
			custom.delegate = castOptionalOrFatalError(delegate)
		}
		public override class func createProxyForObject(object: AnyObject) -> AnyObject {
			let custom = (object as! CustomClass)
			return castOrFatalError(custom.rx_createDelegateProxy())
		}
	}
```

### 2. CustomClass 확장

rx_createDelegateProxy를 통해 CustomClass와 통신하는 Delegate를 만들며, rx_delegate 변수를 통해 Delegate Proxy 객체를 얻습니다.

rx_willStart, rx_DidEnd에서 rx_delegate에 Delegate Selector를 등록하여, 해당 Selector가 호출될 때 인자들을 배열로 내려줍니다.

```swift
	extension CustomClass {
		func rx_createDelegateProxy() -> RxCustomDelegateProxy {
			return RxCustomDelegateProxy(parentObject: self)
		}
		var rx_delegate: DelegateProxy {
			return proxyForObject(RxCustomDelegateProxy.self, self)
		}
		var rx_willStart: Observable<(CustomClass, String)> {
			return rx_delegate.observe(#selector(CustomClassDelegate.willStart(_:_:))).map { a in
				let custom = try castOrThrow(CustomClass.self, a[0])
				let str = try castOrThrow(String.self, a[1])
				return (custom, str)
			}
		}

		var rx_DidEnd: Observable<(CustomClass, String)> {
			return rx_delegate.observe(#selector(CustomClassDelegate.DidEnd(_:_:))).map { a in
				let custom = try castOrThrow(CustomClass.self, a[0])
				let str = try castOrThrow(String.self, a[1])
				return (custom, str)
			}
		}
	}
```

### 3. CustomClass + Rx

위 CustomClass 확장으로 willStart, DidEnd를 구독하여 사용할 수 있습니다.

```swift
	let disposeBag = DisposeBag()
	let custom = CustomClass()
	custom.rx_delegate.setForwardToDelegate(self, retainDelegate: false)
	custom
		.rx_willStart
		.subscribeNext { print($0.0, $0.1) }
		.addDisposableTo(disposeBag)
	custom
		.rx_DidEnd
		.subscribeNext { print($0.0, $0.1) }
		.addDisposableTo(disposeBag)

	custom.start()
```

위의 castOrThrow 등의 메소드는 RxCocoa에 포함되어 있으며, 필요한 경우 다음 코드를 추가해주면 됩니다.

```swift
	func castOptionalOrFatalError<T>(value: AnyObject?) -> T? {
		if value == nil {
			return nil
		}
		let v: T = castOrFatalError(value)
		return v
	}
	func castOrThrow<T>(resultType: T.Type, _ object: AnyObject) throws -> T {
		guard let returnValue = object as? T else {
			throw RxCocoaError.CastingError(object: object, targetType: resultType)
		}

		return returnValue
	}

	func castOptionalOrThrow<T>(resultType: T.Type, _ object: AnyObject) throws -> T? {
		if NSNull().isEqual(object) {
			return nil
		}

		guard let returnValue = object as? T else {
			throw RxCocoaError.CastingError(object: object, targetType: resultType)
		}

		return returnValue
	}

	func castOrFatalError<T>(value: AnyObject!, message: String) -> T {
		let maybeResult: T? = value as? T
		guard let result = maybeResult else {
			rxFatalError(message)
		}

		return result
	}

	func castOrFatalError<T>(value: Any!) -> T {
		let maybeResult: T? = value as? T
		guard let result = maybeResult else {
			rxFatalError("Failure converting from \(value) to \(T.self)")
		}

		return result
	}

	@noreturn func rxFatalError(lastMessage: String) {
		// The temptation to comment this line is great, but please don't, it's for your own good. The choice is yours.
		fatalError(lastMessage)
	}
```

### 정리

Cocoa 프레임워크에 정의된 Delegate 패턴을 위와 같이 확장하여 사용할 수 있습니다. 하지만 이 부분은 아직 이해가 높지 않아 기록용으로 남겨둡니다.

[전체 코드](https://gist.github.com/minsOne/e91b6617c831a66dcf457090bc063acb)

### 참고문서

* [RxSwiftMapViewDelegateProxyExample](https://github.com/mbalex99/RxSwiftMapViewDelegateProxyExample)
* [RxSwift - DelegateProxyType](https://github.com/ReactiveX/RxSwift/blob/master/RxCocoa/Common/DelegateProxyType.swift)

<!--
@objc protocol CustomClassDelegate: class {
    optional func willStart(customClass: CustomClass, _ str: String)
    optional func DidEnd(customClass: CustomClass, _ str: String)
}

class CustomClass: NSObject {
    weak var delegate: CustomClassDelegate? = nil
    func start() {
        self.delegate?.willStart!(self, "WillStart")
        (0...100).forEach { print($0) }
        self.delegate?.DidEnd!(self, "End")
    }
}

public class RxCustomDelegateProxy: DelegateProxy, DelegateProxyType, CustomClassDelegate {
    public class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let custom: CustomClass = castOrFatalError(object)
        return custom.delegate
    }
    public class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let custom: CustomClass = castOrFatalError(object)
        custom.delegate = castOptionalOrFatalError(delegate)
    }
    public override class func createProxyForObject(object: AnyObject) -> AnyObject {
        let custom = (object as! CustomClass)
        return castOrFatalError(custom.rx_createDelegateProxy())
    }
}

extension CustomClass {
    func rx_createDelegateProxy() -> RxCustomDelegateProxy {
        return RxCustomDelegateProxy(parentObject: self)
    }
    internal var rx_delegate: DelegateProxy {
        return proxyForObject(RxCustomDelegateProxy.self, self)
    }
    var rx_willStart: Observable<(CustomClass, String)> {
        return rx_delegate.observe(#selector(CustomClassDelegate.willStart(_:_:))).map { a in
            let custom = try castOrThrow(CustomClass.self, a[0])
            let str = try castOrThrow(String.self, a[1])
            return (custom, str)
        }
    }

    var rx_DidEnd: Observable<(CustomClass, String)> {
        return rx_delegate.observe(#selector(CustomClassDelegate.DidEnd(_:_:))).map { a in
            let custom = try castOrThrow(CustomClass.self, a[0])
            let str = try castOrThrow(String.self, a[1])
            return (custom, str)
        }
    }
}

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    let custom = CustomClass()
    override func viewDidLoad() {
        super.viewDidLoad()

        custom.rx_delegate.setForwardToDelegate(self, retainDelegate: false)
        custom
            .rx_willStart
            .subscribeNext { print($0.0, $0.1) }
            .addDisposableTo(disposeBag)
        custom
            .rx_DidEnd
            .subscribeNext { print($0.0, $0.1) }
            .addDisposableTo(disposeBag)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        custom.start()
    }

}	
-->
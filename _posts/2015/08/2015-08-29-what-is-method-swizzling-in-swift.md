---
layout: post
title: "[Swift] Method Swizzling이란?"
description: ""
category: "Mac/iOS"
tags: [swift, objective-c, swizzling, method swizzling, extension, runtime, selector, class_getInstanceMethod, method_exchangeImplementations]
---
{% include JB/setup %}

### Method Swizzling

Swizzling이란 뒤섞다라는 의미입니다. 그래서 Method Swizzling은 원래의 메소드를 runtime 때 원하는 메소드로 바꾸어 사용할 수 있도록 하는 기법입니다.

원하는 메소드로 바꾸어 사용하게 되면 메소드를 호출하기 전에 사용자 추적, 특정 기능 수행들을 할 수 있는 이점이 있지만, 임의로 바꾸었기 때문에 버그가 발생할 수 있습니다. 

#### 코드

```
extension UIViewController {
    class func swizzleMethod() {
        let originalSelector = #selector(UIViewController.viewWillAppear(_:))
        let swizzledSelector = #selector(UIViewController.minsone_viewWillAppear(animated:))
        guard
            let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector),
            let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector)
            else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }

     @objc public func minsone_viewWillAppear(animated: Bool) {
        print("minsone_viewWillAppear", self)
    }
}
```

그리고 원하는 동작을 하기 위해서는 `swizzleMethod()` 함수를 먼저 호출해줘야 합니다.

```
class AppDelegate: UIResponder, UIApplicationDelegate {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		...
		UIViewController.swizzleMethod()
		...
	}
}
```

그리고 swizzleMethod 메소드에 구현을 하므로, swizzleMethod를 가지는 프로토콜을 만들어, swizzling할 타입을 관리하고 일괄 호출하도록 합니다.

```
protocol SwizzlingMethodProtocol {
	static func swizzleMethod()
}

extension UIViewController: SwizzlingMethodProtocol {
	...
}

class AppDelegate: UIResponder, UIApplicationDelegate {
	let swizzlingMethodTypes: [SwizzlingMethodProtocol.Type] = [UIViewController.self]

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		...
		swizzlingMethodTypes.forEach { $0.swizzleMethod() }
		...
	}
}
```

#### 코드 분석

Method Swizzling은 영향이 전역으로 미치므로, Singleton을 통해서 한번 변경하면 다시 호출되지 않도록 합니다.

```
let originalSelector = #selector(UIViewController.viewWillAppear(_:))
let swizzledSelector = #selector(UIViewController.minsone_viewWillAppear(animated:))
```

위의 코드는 Swizzling 할 메소드들의 Selector를 가져옵니다.

```
let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector)
let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector)
```

UIViewController 클래스의 지정된 인스턴스 메소드를 반환합니다.

추가가 되면 originalSelector와 swizzledSelector를 method_exchangeImplementations로 바꾸어 우리가 원하는 기능을 동작하게 합니다.

```
method_exchangeImplementations(originalMethod, swizzledMethod)
```

#### 결과

	viewWillAppear: <TestView.ViewController: 0x78760d80> minsone_viewWillAppear 
	ViewWillAppear: <TestView.ViewController: 0x78760d80> viewWillAppear
	viewDidAppear: <TestView.ViewController: 0x78760d80> viewDidAppear

### 결론

특정 상황에서 서브 클래스를 만들어 사용하는 것보다 클래스를 런타임 때 특정 기능을 바꾸는 것이 유용할 수 있습니다. 예를 들면, 특정 SDK를 만들어 사용하고자 할 때, 특정 메소드에서는 항상 로그를 출력해야 할때 등이 있습니다. 하지만 버그가 발생할 가능성이 있는 만큼 상황에 따라 사용하는 것이 좋다고 생각됩니다.

### 참고 자료

* [stackoverflow](https://stackoverflow.com/questions/52366310/swift-method-swizzling)
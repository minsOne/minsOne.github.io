---
layout: post
title: "[Swift] Method Swizzling이란?"
description: ""
category: "Mac/iOS"
tags: [swift, objective-c, method, swizzling, method swizzling, extension, singleton, runtime, selector]
---
{% include JB/setup %}

### Method Swizzling

Swizzling이란 뒤섞다라는 의미입니다. 그래서 Method Swizzling은 원래의 메소드를 runtime 때 원하는 메소드로 바꾸어 사용할 수 있도록 하는 기법입니다.

원하는 메소드로 바꾸어 사용하게 되면 메소드를 호출하기 전에 사용자 추적, 특정 기능 수행들을 할 수 있는 이점이 있지만, 임의로 바꾸었기 때문에 버그가 발생할 수 있습니다. 

#### 코드

	extension UIViewController {
		public override class func initialize() {
			struct Static {
				static var token: dispatch_once_t = 0
			}

			// 서브 클래스면 동작하지 않도록 한다.
			if self !== UIViewController.self {
				return
			}

			dispatch_once(&Static.token) {
				let originalSelector = Selector("viewWillAppear:")
				let swizzledSelector = Selector("nsh_viewWillAppear:")

				let originalMethod = class_getInstanceMethod(self, originalSelector)
				let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)

				let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))

				if didAddMethod {
					class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
				} else {
					method_exchangeImplementations(originalMethod, swizzledMethod);
				}
			}
		}

		// MARK: - Method Swizzling

		func nsh_viewWillAppear(animated: Bool) {
			self.nsh_viewWillAppear(animated)
			println("viewWillAppear: \(self)")
		}
	}

#### 코드 분석

Method Swizzling은 영향이 전역으로 미치므로, Singleton을 통해서 한번 변경하면 다시 호출되지 않도록 합니다.

	let originalSelector = Selector("viewWillAppear:")
	let swizzledSelector = Selector("nsh_viewWillAppear:")

위의 코드는 Swizzling 할 메소드들의 Selector를 가져옵니다.

	let originalMethod = class_getInstanceMethod(self, originalSelector)
	let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)

UIViewController 클래스의 지정된 인스턴스 메소드를 반환합니다.

	let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))

그리고 originalSelector 이름과 swizzledMethod의 implementation를 UIViewController 클래스에 추가합니다.

추가가 되면 originalSelector와 swizzledSelector를 class_replaceMethod로 바꾸어 우리가 원하는 기능을 동작하도록 하고, 그렇지 않으면 method_exchangeImplementations로 originalMethod와 swizzledMethod를 바꾸도록 합니다.

	if didAddMethod {
		class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
	} else {
		method_exchangeImplementations(originalMethod, swizzledMethod);
	}

#### 왜 initialize인가?

기존에 Objective-C에서는 load 메소드는 클래스를 한 번만 호출하므로, Singleton을 사용할 필요가 없었습니다. 

하지만 Swift에서는 load 메소드를 사용할 수 없어 initialize 메소드를 사용해야 합니다. 그리고 initialize 메소드는 클래스를 생성할 때마다 호출하므로, Singleton을 사용해야 합니다.

#### 결과

	viewWillAppear: <TestView.ViewController: 0x78760d80> nsh_viewWillAppear 
	ViewWillAppear: <TestView.ViewController: 0x78760d80> viewWillAppear
	viewDidAppear: <TestView.ViewController: 0x78760d80> viewDidAppear

### 결론

특정 상황에서 서브 클래스를 만들어 사용하는 것보다 클래스를 런타임 때 특정 기능을 바꾸는 것이 유용할 수 있습니다. 예를 들면, 특정 SDK를 만들어 사용하고자 할 때, 특정 메소드에서는 항상 로그를 출력해야 할때 등이 있습니다. 하지만 버그가 발생할 가능성이 있는 만큼 상황에 따라 사용하는 것이 좋다고 생각됩니다.

### 참고 자료

* [NSHipster](http://nshipster.com/swift-objc-runtime/)
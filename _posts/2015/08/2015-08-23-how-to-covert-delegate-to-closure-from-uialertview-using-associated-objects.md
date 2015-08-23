---
layout: post
title: "[Swift]Associated Objects로 Delegate에서 Closure로 구현하기"
description: ""
category: "Mac/iOS"
tags: [swift, associatedobject, delegate, closure, runtime, objc_setAssociatedObject, objc_getAssociatedObject, objc_removeAssociatedObjects, uialertview, extension, category, subclass, method, function, property, variable, class]
---
{% include JB/setup %}

### Associated Objects이란

`Associated Objects`는 런타임시 사용자 속성이나 메소드들을 서브클래스를 만들지 않고 추가하거나 제거할 수 있습니다.

Objective-C 2.0 런타임의 기능으로 강력하지만 불안정한 요소를 가지고 있으며, 혹자는 악마와의 거래라고도 합니다.

`runtime.h`에는 Associated Objects 관련 함수가 정의되어 있습니다.

	func objc_setAssociatedObject(object: AnyObject!, key: UnsafePointer<Void>, value: AnyObject!, policy: objc_AssociationPolicy)
	func objc_getAssociatedObject(object: AnyObject!, key: UnsafePointer<Void>) -> AnyObject!
	func objc_removeAssociatedObjects(object: AnyObject!)


objc_setAssociatedObject는 인자로 넘기는 객체에 사용자 객체를 추가하며, 키 값은 메모리 값으로 사용합니다. 또한, 객체의 메모리 관리는 AssociationPolicy에 따라 관리합니다.

objc_getAssociatedObject는 추가된 객체를 접근할 때 사용합니다.
objc_removeAssociatedObjects 추가된 객체를 제거할 때 사용합니다.

AssociationPolicy는 다음과 같습니다.

	OBJC_ASSOCIATION_ASSIGN				// 추가된 객체와 약한 참조
	OBJC_ASSOCIATION_RETAIN_NONATOMIC	// 추가된 객체와 강력 참조 및 nonatomatic으로 설정
	OBJC_ASSOCIATION_COPY_NONATOMIC		// 추가된 객체를 복사 및 nonatomatic으로 설정
	OBJC_ASSOCIATION_RETAIN 			// 추가된 객체와 강력 참조 및 atomatic으로 설정
	OBJC_ASSOCIATION_COPY 				// 추가된 객체를 복사 및 atomatic으로 설정



<!--
ps. Swizzling을 사용하면 앱스토어 심사에서 리젝을 받을 수 있다고 하는데, AFNetwork 등에서도 Swizzling을 사용하므로, 리뷰어에 따라 통과되거나 안될 수 있을 것 같습니다. - [참고](http://stackoverflow.com/questions/8834294/app-store-method-swizzling-legality)
-->

### Delegate를 Closure로!

UIAlertView는 Delegate 방식을 취합니다. 하지만 하나의 ViewController에서 다양한 UIAlertView를 띄워야 한다면, Delegate 방식은 복잡해질 수 밖에 없습니다. 그러면 Delegate 방식을 Closure 방식으로 바꿔서 사용하도록 합니다.


메모리 값으로 사용할 키와, Closure를 가질 클래스를 선언합니다.

	public typealias AVDidDismissClosure = (UIAlertView, Int) -> Void

	private var associatedEventHandle: UInt8 = 0 	// Closure를 관리할 객체의 메모리 주소
	private final class AlertViewClosureWrapper {
		private var didDismiss: AVDidDismissClosure?
	}

이제 UIAlertViewDelegate로 확장된 UIAlertView를 선언합니다. 그리고 ClosureWapper 객체를 만들어 UIAlertView에 추가하고, Delegate를 Self로 정의하여 Delegate로 호출되면 ClosureWapper에 지정된 Closure를 호출합니다.

	extension UIAlertView: UIAlertViewDelegate {
		// UIAlertView에 closureWapper 객체 추가 및 UIAlertView의 Delegate를 Self로 설정
		private var closureWrapper:AlertViewClosureWrapper {
			get {
				if let wrapper = objc_getAssociatedObject(self, &associatedEventHandle) as? AlertViewClosureWrapper {
					return wrapper
				}
				self.closureWrapper = AlertViewClosureWrapper()
				return self.closureWrapper
			}
			set {
				self.delegate = self
				objc_setAssociatedObject(self, &associatedEventHandle, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
			}
		}
		// UIAlertView의 didDismiss 메소드가 호출되면 사용할 didDismiss Closure 변수 선언
		public var didDismiss: AVDidDismissClosure? {
			get { return self.closureWrapper.didDismiss }
			set { self.closureWrapper.didDismiss = newValue }
		}
		// Delegate로부터 호출되면 closureWapper의 didDismiss Closure를 호출
		public func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
			self.closureWrapper.didDismiss?(alertView, buttonIndex)
		}

		// 사용자 초기화를 통해 Closure를 할당함.
		convenience init(title: String, message: String, cancelButtonTitle: String, dismissClosure: AVDidDismissClosure?) {
			self.init()
			self.title = title
			self.message = message
			self.addButtonWithTitle(cancelButtonTitle)
			self.didDismiss = dismissClosure
		}
	}

다음과 같이 호출하여 사용할 수 있습니다.

	let alertView = UIAlertView(title: "Title", message: "Message", cancelButtonTitle: "One") { (alertView, buttonIndex) in
		println("Button Index = \(buttonIndex)")
	}
	alertView.show()

UIAlertView를 호출하고 버튼을 누르면 다음과 같이 순서로 출력됩니다.

	init(title:message:cancelButtonTitle:dismissClosure:)
	alertView(_:didDismissWithButtonIndex:)
	Button Index = 0

전체코드는 [여기](https://gist.github.com/minsOne/5e63c58fd68a0fb76bae)에서 보실 수 있습니다.

### 참고 자료

* [ClosureKit](https://github.com/Reflejo/ClosureKit/)
* [NSHipster](http://nshipster.com/associated-objects/)
* [minorblend](http://minorblend.com/post/40590130886)
* [Apple Document](https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Reference/ObjCRuntimeRef/index.html)

<!--
http://minorblend.com/post/40590130886
http://www.letmecompile.com/aspect-oriented-programming-in-objective-c/
https://github.com/Reflejo/ClosureKit/blob/master/Source/UIWebView%2BClosureKit.swift	
http://nshipster.com/method-swizzling/
http://nshipster.com/associated-objects/
https://blog.newrelic.com/2014/04/16/right-way-to-swizzle/
http://kingscocoa.com/tutorials/associated-objects/
http://nshipster.com/method-swizzling/
https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/CustomizingExistingClasses/CustomizingExistingClasses.html
-->
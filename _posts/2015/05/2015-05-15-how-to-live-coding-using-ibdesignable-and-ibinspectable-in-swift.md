---
layout: post
title: "[Swift]인터페이스 빌더에서 실시간 렌더링을 통한 커스텀 뷰 만들기"
description: ""
category: "Mac/iOS"
tags: [ibdesignable, ibinspectable, render, live, runtime, target_interface_builder, xcode]
---
{% include JB/setup %}

### IBDesignable과 IBInspectable

Xcode6에서 새로운 기능인 IBDesignable과 IBInspectable이 추가되었습니다. 이 기능들은 커스텀 뷰를 만들때 인터페이스 빌더 내에서 라이브로 화면이 어떻게 구성되는지 보여줄 수 있습니다. 이는 커스텀 뷰를 만들기 위해 수 많은 빌드를 통해 실행하여 볼 필요가 없음을 의미합니다.

IBDesignable과 IBInspectable를 이용하여 실제 커스텀 뷰를 만들도록 합니다.

1.프로젝트가 생성되어있음을 가정하고 UIView를 상속받는 커스텀 뷰 클래스를 생성합니다.

<br/><img src="https://farm6.staticflickr.com/5833/20587512820_e6a152ee3f.jpg" width="500" height="292" alt="newCustomView"><br/><br/>

2.클래스 선언부 위에 `@IBDesignable`를 작성하여 CustomRectView를 실시간으로 볼 수 있도록 선언합니다.

	import UIKit

	@IBDesignable
	class CustomRectView: UIView {
		required init(coder aDecoder: NSCoder) {
			super.init(coder: aDecoder)
		}

		override init(frame: CGRect) {
			super.init(frame: frame)
		}
	}

<div class="alert-info">Objective-C로 작성하는 경우 <strong>IB_DESIGNABLE</strong>를 사용합니다.</div><br/>

3.여러가지 타입 변수들을 IBInspectable를 사용하여 선언할 수 있습니다. 다음은 사용되는 예와, 커스텀 뷰 클래스에서 사용할 변수입니다.

	// 사용 타입 예제 코드
	class CustomRectView : UIView {
		@IBInspectable var integer: Int = 0
		@IBInspectable var float: CGFloat = 0
		@IBInspectable var double: Double = 0
		@IBInspectable var point: CGPoint = CGPointZero
		@IBInspectable var size: CGSize = CGSizeZero
		@IBInspectable var customFrame: CGRect = CGRectZero
		@IBInspectable var color: UIColor = UIColor.clearColor()
		@IBInspectable var string: String = "minsOne"
		@IBInspectable var bool: Bool = false
	}

	// 사용 예제 코드 
	class CustomRectView: UIView {
		@IBInspectable var lineWidth: Int = 100
		@IBInspectable var fillColor: UIColor = UIColor.blueColor()
	}

위의 코드는 기본값이며, 인터페이스 빌더에서 변경이 가능합니다.

<br/>4.인터페이스 빌더에 커스텀 뷰를 추가하여 IBInspectable를 사용한 변수들을 확인할 수 있습니다.
<br/><img src="https://farm6.staticflickr.com/5833/20749257446_64dc65ab83.jpg" width="258" height="101" alt="customclass"><br/><br/>
<br/><img src="https://farm1.staticflickr.com/610/20587517640_3be71f3c75.jpg" width="243" height="500" alt="customclass_ibinspectable"><br/><br/>

5.drawRect 메소드를 통해 커스텀 뷰에 그리게 되면 인터페이스 빌더에 실시간으로 보여지게 됩니다.
	
	override func drawRect(rect: CGRect) {
		let context = UIGraphicsGetCurrentContext()
		var myFrame = self.bounds
		CGContextSetLineWidth(context, CGFloat(lineWidth))
		CGRectInset(myFrame, 5, 5)
		fillColor.set()
		UIRectFrame(myFrame)
	}

위의 코드 작성 후 렌더링 되었는지 확인을 하면 변경되어 있는 것을 확인할 수 있습니다.
<br/><img src="https://farm1.staticflickr.com/569/20154548193_cc96dd8d98.jpg" width="500" height="377" alt="customclass_preview"><br/><br/>

만일 다른 색상, 선 폭 크기를 변경하고자 한다면 인터페이스 빌더에서 변경이 가능합니다.
<br/><img src="https://farm1.staticflickr.com/708/20766095512_1defc6f59e.jpg" width="500" height="359" alt="customclass_preview_change"><br/><br/>

인터페이스 빌더에서 값을 변경하면 동시에 User Defined Runtime Attributes에도 동일한 Key Path, Type, Value로 생성이 됩니다.
<br/><img src="https://farm6.staticflickr.com/5825/20154548003_9f7e961a38.jpg" width="257" height="83" alt="customclass_preview_runtime"><br/><br/>

6.인터페이스 빌더 내에서만 커스텀 뷰 코드를 만들고자 한다면 `prepareForInterfaceBuilder` 메소드로부터 코드를 호출할 수 있습니다.

	override func prepareForInterfaceBuilder() {

	}

또한, `TARGET_INTERFACE_BUILDER` 매크로를 통해 특정 코드를 포함하거나 배제하여 사용할 수 있습니다.

	#if !TARGET_INTERFACE_BUILDER
		// connect to the server
	#else
		// don't connect; instead, draw my custom view
	#endif

<br/>7.Assistant Editor를 통해서 코드를 수정하면 커스텀 뷰가 실시간으로 렌더링 되는지 확인할 수 있습니다.

### 정리

점점 어플리케이션 개발시 쓸데없이 빌드를 하는 일이 많이 줄어들고 있으며, IBDesignable이 그 역할을 톡톡히 하지 않을까 합니다. 개발자는 비지니스 로직을 더 고민해야 될 시기이며, UI 개발에 대해서는 크게 신경쓰지 않도록 애플에서 기능들을 추가적으로 더 내놓지 않을까 합니다.

### 참고 자료

* [Apple Document](https://developer.apple.com/library/ios/recipes/xcode_help-IB_objects_media/Chapters/CreatingaLiveViewofaCustomObject.html)
* [App Coda](http://www.appcoda.com/ibdesignable-ibinspectable-tutorial/)
* [We ❤ Swift](https://www.weheartswift.com/make-awesome-ui-components-ios-8-using-swift-xcode-6/)
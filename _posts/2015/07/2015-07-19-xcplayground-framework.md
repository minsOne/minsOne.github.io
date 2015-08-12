---
layout: post
title: "[Xcode]XCPlayground Framework"
description: ""
category: "Mac/iOS"
tags: [swift, XCPlayground, XCPShowView, XCPCaptureValue, XCPSharedDataDirectoryPath, XCPSetExecutionShouldContinueIndefinitely, QuickLookObject, async, Playground]
---
{% include JB/setup %}

### XCPlayground

Xcode의 Playground에서 특정 값 또는 뷰를 실시간으로 그려지는 것을 보거나 비동기 작업을 위해 계속 실행되도록 하는 기능이 있습니다.

XCPlayground Framework에서 Assistant Editor에게 값을 보여줄 수 있는 `XCPCaptureValue`, UIView를 보여주는 `XCPShowView` 그리고 비동기 작업을 위한 `XCPSetExecutionShouldContinueIndefinitely` 함수가 있습니다.

또한, 모든 playground가 공유하는 영속성 데이터가 저장된 경로를 반환하는 `XCPSharedDataDirectoryPath` 상수도 있습니다.

#### XCPShowView

UIView의 실시간으로 렌더링 되는 것을 볼 수 있습니다. 

XCPShowView는 다음과 같이 사용합니다.

	// 함수 선언
	func XCPShowView(identifier: String, view: UIView)

	// 예제 코드
	let containerView = UIView(frame: CGRectMake(0, 0, 100, 100))
	containerView.backgroundColor = UIColor.whiteColor()

	XCPShowView("containerview", containerView)

	let outerRect = CGRectInset(containerView.frame, -10, -10)
	let toPath = UIBezierPath(ovalInRect: outerRect)

	let shape = CAShapeLayer()
	shape.path = toPath.CGPath

	containerView.layer.mask = shape

<br/><img src="/../../../../image/2015/playground1.png" alt="" style="width: 200px;"/><br/><br/>

#### XCPCaptureValue

XCPCaptureValue는 다음과 같이 사용합니다.

	// 함수 선언
	func XCPCaptureValue<T>(identifier: String, value: T)

	// 예제 코드
	XCPCaptureValue("newRect", CGRectMake(10, 10, 100, 100))

<br/><img src="/../../../../image/2015/playground2.png" alt="" style="width: 200px;"/><br/><br/>

value에 들어갈 수 있는 타입은 다음과 같습니다.

* Images : UIImage, NSImage, UIImageView, NSImageView, CIImage, NSBitmapImageRep
* Colors : UIColor, NSColor
* Strings : NSString, NSAttributedString
* Geometry : UIBezierPath, NSBezierPath, CGPoint, CGRect, CGSize
* Locations : CLLocation
* URLs : NSURL
* SpriteKit : SKSpriteNode, SKShapeNode, SKTexture, SKTextureAtlas
* Data : NSData
* Views : UIView

또한, QuickLookObject enum으로 이러한 유형의 값들을 기본으로 사용할 수 있습니다.

	enum QuickLookObject {
	    case Text(String)
	    case Int(Int64)
	    case UInt(UInt64)
	    case Float(Float32)
	    case Double(Float64)
	    case Image(Any)
	    case Sound(Any)
	    case Color(Any)
	    case BezierPath(Any)
	    case AttributedString(Any)
	    case Rectangle(Float64, Float64, Float64, Float64)
	    case Point(Float64, Float64)
	    case Size(Float64, Float64)
	    case Logical(Bool)
	    case Range(UInt64, UInt64)
	    case View(Any)
	    case Sprite(Any)
	    case URL(String)
	}

만일 위의 클래스의 서브클래스인 경우 quick look을 구현해야 가능합니다.

구현을 하기 위해서는 다음 함수를 구현해야 합니다.

	func debugQuickLookObject() -> AnyObject {
		return UIView()
	}

#### XCPSetExecutionShouldContinueIndefinitely

`XCPSetExecutionShouldContinueIndefinitely` 함수는 정해진 시간 만큼 계속 실행합니다.

Xcode 하단에 시간이 10초로 설정되어 있으면 10초까지 비동기 작업들을 진행하여 결과를 볼 수 있으며, 그 이후에는 실행이 모두 종료됩니다.

	XCPSetExecutionShouldContinueIndefinitely()

<br/><img src="/../../../../image/2015/playground3.png" alt="" style="width: 100px;"/><br/><br/>

### 참고 자료

* [NSHipster](http://nshipster.com/quick-look-debugging/)
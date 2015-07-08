---
layout: post
title: "Playground에서 Dimmed를 어떻게 만들까? in swift"
description: ""
category: "Mac/iOS"
tags: [swift, playground, XCPlayground, UIBezierPath, mask, fillRule, kCAFillRuleEvenOdd]
---
{% include JB/setup %}

### MaskLayer

간혹 요구사항 중에 특정 영역을 제외하고 딤드(Dimmed) 처리해달라고 하는 경우가 있습니다. 보통은 튜토리얼 등에서 많이 요구사항으로 받는 부분입니다. 그래서 구현하기 위해서 리소스를 추가하는 방법도 있고, 특정 부분의 영역만 이미지 객체로 만들어 새로운 이미지 객체로 만들어 보여주는 방법도 있습니다.

하지만 CALayer의 fillRule을 이용하여 작업하는 방법도 있습니다.

Playground에서 작업하기 위해 다음 라이브러리가 필요합니다.

    import Foundation
	import UIKit
	import XCPlayground

다음은 딤드 레이어를 씌울 UIView를 만듭니다.

	let containerView = UIView(frame: CGRectMake(0, 0, 1000, 1000))
	containerView.backgroundColor = UIColor.redColor()

UIView의 frame과 같이 CALayer의 frame을 만듭니다.

	let maskLayer = CAShapeLayer()
	maskLayer.fillRule = kCAFillRuleEvenOdd
	maskLayer.frame = containerView.frame

kCAFillRuleEvenOdd는 CGPath가 홀수 일 경우 Path 내부에 Point가 위치한다고 합니다.(정확하게는 파악이 되지 않았지만, 홀수일 경우 내부로 Path가 된다고 하는 것 같습니다.)

이제 내부 영역을 잡도록 합니다.

	let maskLayerPath = UIBezierPath()
	maskLayerPath.appendPath(UIBezierPath(rect: containerView.frame))
	let maskFrame = CGRectMake(250, 250, 500, 500);
	maskLayerPath.appendPath(UIBezierPath(roundedRect: maskFrame, cornerRadius: 10))
	maskLayer.path = maskLayerPath.CGPath

그리고 CALayer를 만들고, mask를 maskLayer로 설정합니다.

	let dimmedLayer = CALayer()
	dimmedLayer.frame = containerView.bounds
	dimmedLayer.backgroundColor = UIColor(white: 0, alpha: 0.6).CGColor
	dimmedLayer.mask = maskLayer

	containerView.layer.addSublayer(dimmedLayer)

containerView의 layer에 dimmedLayer를 추가하여 다음과 같이 내부 영역이 뚤려져있는 것을 확인할 수 있습니다.

<br/><img src="/../../../../image/2015/dimmedLayer.png" alt="" style="width: 500px;"/><br/><br/>

### 코드

다음은 MaskLayer를 적용한 Playground 전체 소스입니다.

    import Foundation
	import UIKit
    import XCPlayground

    let containerView = UIView(frame: CGRectMake(0, 0, 1000, 1000))
    containerView.backgroundColor = UIColor.redColor()

    let maskLayer = CAShapeLayer()
    maskLayer.fillRule = kCAFillRuleEvenOdd
    maskLayer.frame = containerView.frame

    let maskLayerPath = UIBezierPath()
    maskLayerPath.appendPath(UIBezierPath(rect: containerView.frame))
    let maskFrame = CGRectMake(250, 250, 500, 500);
    maskLayerPath.appendPath(UIBezierPath(roundedRect: maskFrame, cornerRadius: 10))
    maskLayer.path = maskLayerPath.CGPath

    let imageLayer = CALayer()
    imageLayer.frame = containerView.bounds
    imageLayer.backgroundColor = UIColor(white: 0, alpha: 0.6).CGColor
    imageLayer.mask = maskLayer

    containerView.layer.addSublayer(imageLayer)

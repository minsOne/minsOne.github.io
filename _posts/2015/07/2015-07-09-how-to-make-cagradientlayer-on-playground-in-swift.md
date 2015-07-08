---
layout: post
title: "Playground에서 CAGradientLayer를 어떻게 적용할까? in Swift"
description: ""
category: "Mac/iOS"
tags: [swift, playground, XCPlayground, CAGradientLayer]
---
{% include JB/setup %}

### Playground

Xcode에서 Playground라는 기능이 추가된 후로부터 빌드 후 검증 등의 작업이 많이 줄었습니다. 역시 UIView에서도 그러한 작업을 수행할 수 있는데요. 

얼마 전에 그러데이션을 넣어야 하는 작업이 있었습니다. Playground로 작업하여 UIView에 어떻게 나오는지를 확인하는 작업을 바로 확인하니 너무 편했습니다.

그래서 Playground로 UIView를 만들고 그러데이션을 적용해보도록 하겠습니다.

첫 번째로, UIView를 만들고 보기 위해서는 다음 라이브러리가 필요합니다.

	import UIKit
	import XCPlayground

다음으로 UIView를 만들도록 합니다.

	let containerView = UIView(frame: CGRectMake(0, 0, 1024, 1024))
	containerView.backgroundColor = UIColor.whiteColor()

<br/><img src="/../../../../image/2015/gradientLayer1.png" alt="" style="width: 500px;"/><br/><br/>

이제 그러데이션을 만들도록 합니다.

	var alphaGradientLayer = CAGradientLayer()
	var colors = [UIColor(red: 1.0, green: 1.0, blue: 0.192, alpha: 1).CGColor]
	colors += [UIColor(red: 1.0, green: 1.0, blue: 0.192, alpha: 0).CGColor]

	alphaGradientLayer.colors = colors
	alphaGradientLayer.startPoint = CGPointMake(0, 1)
	alphaGradientLayer.endPoint = CGPointMake(0, 0.1)

	alphaGradientLayer.frame = containerView.bounds
	containerView.layer.insertSublayer(alphaGradientLayer, atIndex: 0)

containerView의 layer에 alphaGradientLayer를 붙여 containerView에 그라데이션이 적용된 것을 확인할 수 있습니다.

<br/><img src="/../../../../image/2015/gradientLayer3.png" alt="" style="width: 500px;"/><br/><br/>

만약 color의 값을 바꾼다면 실시간으로 갱신되어 색상이 바뀐 그러데이션 레이어를 볼 수 있습니다.

다음은 그러데이션을 적용한 Playground 전체 소스입니다.

	import Foundation
	import UIKit
	import XCPlayground

	let containerView = UIView(frame: CGRectMake(0, 0, 1024, 1024))
	containerView.backgroundColor = UIColor.whiteColor()

	let alphaGradientLayer = CAGradientLayer()
	var colors = [UIColor(red: 1.0, green: 1.0, blue: 0.192, alpha: 1).CGColor]
	colors += [UIColor(red: 1.0, green: 1.0, blue: 0.192, alpha: 0).CGColor]

	alphaGradientLayer.colors = colors
	alphaGradientLayer.startPoint = CGPointMake(0, 1)
	alphaGradientLayer.endPoint = CGPointMake(0, 0.1)

	alphaGradientLayer.frame = containerView.bounds
	containerView.layer.insertSublayer(alphaGradientLayer, atIndex: 0)

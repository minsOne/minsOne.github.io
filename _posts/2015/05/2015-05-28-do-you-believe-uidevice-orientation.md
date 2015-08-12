---
layout: post
title: "[iOS]UIDevice의 Orientation을 믿으시나요?"
description: ""
category: "Mac/iOS"
tags: [swift, uidevice, statusbar, portrait, landscape, orientation, viewdidload]
---
{% include JB/setup %}

iOS 개발하는 중에 믿을 수 없는 값들 중 하나가 UIDevice의 orientation입니다. 화면이 나타나기 전에 UIDevice의 orientation은 정확한 값을 알 수 없습니다.

앱이 Landscape만 가능할 때, viewDidLoad가 호출되는 시점에서 UIDevice는 portrait를, 상태 바에서는 Landscape를 얻을 수 있습니다. 

따라서 우리가 원하는 방향을 정확하게 얻고자 할때는 UIDevice보다는 상태 바를 사용하는 것이 더 좋습니다.

다음 예제에서 어떤 상태로 출력되는지 확인할 수 있습니다.

	override func viewDidLoad() {
	  super.viewDidLoad()
    println(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation))
    println(UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation))
	}

못 믿으시나요? 해보세요~ :)
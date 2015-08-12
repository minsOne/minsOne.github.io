---
layout: post
title: "[iOS]iOS8에서 UIAlertView 대신에 UIAlertController를 사용하자!"
description: ""
category: "Mac/iOS"
tags: [swift, UIAlertView, UIAlertController, Alert, ActionSheet]
---
{% include JB/setup %}

iOS8 이전에는 UIAlertView를 사용하여 Delegate 형태로 입력을 받아 처리하는 형태로 작업하였습니다. 그래서 UIAlertView를 확장하여 클로저 형태로 넘겨 처리하도록 하는 라이브러리도 만들어졌었습니다.

만약에 UIAlertView를 클로저로 구현하지 않고 Delegate로 사용하고 ViewController 내에 여러 UIAlertView를 띄워야 한다고 한다면 어떻게 해야 할지 애매한 상태가 됩니다.

iOS8에서는 UIAlertController를 제공하며 Alert, ActionSheet 두 개의 스타일을 기본적으로 가집니다. 그리고 각각의 UIAlertAction을 추가하여 각기 다른 명령을 수행합니다.

다음은 UIAlertController 사용 예제입니다.

	let alert = UIAlertController(
	    title: "Default Style", 
	    message: "A standard alert.", 
	    preferredStyle: .Alert)

	let cancelAction = UIAlertAction(
	    title: "아니오",
	    style: UIAlertActionStyle.Cancel) {
	        action in
	        println("pressed Cancel Button")
	}
	let okAction = UIAlertAction(
	    title: "예",
	    style: UIAlertActionStyle.Default) {
	        action in
	        println("pressed Cancel Button")
	}

	alert.addAction(cancelAction)
	alert.addAction(okAction)

	self.presentViewController(alert, animated: true) {
	    println("complete")
	}

물론 UIAlertView도 좋지만 iOS 8이상으로 타겟을 한다면 UIAlertController를 사용하는 것이 더 좋을 것 같습니다. UIAlertView는 Apple이 deprecate 된다고는 하였지만 문서상에만 남겨놓았지, 실제 헤더 파일에서는 deprecate 시키지 않았습니다. 하지만 UIAlertController를 사용하는 것이 좀 더 명확하게 코드를 작성할 수 있을 것으로 생각됩니다.

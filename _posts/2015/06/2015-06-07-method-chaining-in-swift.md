---
layout: post
title: "[Swift]Method Chaining"
description: ""
category: "Mac/iOS"
tags: [objc, swift, wrapper, method, extension, self, javascript, method chaining]
---
{% include JB/setup %}

### Method Chaining

가끔 코드를 작성하다 보면 같은 대상에 대해 추가 또는 변경, 삭제 등에 대해 여러 번 해야 하는 경우가 있습니다. 아직 다른 언어들을 많이 다루지는 않았지만 javascript는 다음과 같은 코드를 작성하는 것이 흔합니다.

	bob.setName('Bob').setColor('black');

위의 방식을 `Method Chaining`이라고 하는데, 이러한 방식으로 코드를 작성하고 싶으나 기본적인 라이브러리에서 지원하지 않아 아쉬운 경우들이 많습니다. 

<br/>다음의 경우에서 이러한 아쉬운 경우를 볼 수 있습니다. Swift에서 UISwipeGesture를 추가하는데 Right, Left, Down, Up에 대해서 각각 만들어서 지정해야 합니다.

	var swipeRight = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipeRightGesture:"))
    var swipeLeft = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipeLeftGesture:"))
    var swipeUp = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipeUpGesture:"))
    var swipeDown = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipeDownGesture:"))

    swipeRight.direction = .Right
    swipeLeft.direction = .Left
    swipeUp.direction = .Up
    swipeDown.direction = .Down

    self.redView.addGestureRecognizer(swipeRight)
    self.redView.addGestureRecognizer(swipeLeft)
    self.redView.addGestureRecognizer(swipeUp)
    self.redView.addGestureRecognizer(swipeDown)

위의 코드에서 addGestureRecognizer를 redView라는 UIView에 여러 번 접근해서 추가합니다. 이 경우 self.redView를 여러 번 사용하기 때문에 간단하게 addGestureRecognizer를 감싸 Method Chaining 방법으로 작성할 수 있습니다.

	extension UIView {
	    func addGestureRegonizer(recognizer: UIGestureRecognizer) -> UIView! {
	        self.addGestureRecognizer(recognizer)
	        return self;
	    }
	}

이 addGestureRecognizer는 원래의 addGestureRecognizer와는 다르게 UIView를 반환합니다. 따라서 같은 이름 사용이 가능합니다. 확장 addGestureRecognizer는 UIView를 반환하기 때문에 다시 확장 addGestureRecognizer를 호출할 수 있으므로 Method Chaining 방법이 가능합니다. 

다음은 확장 addGestureRecognizer로 개선한 코드입니다.

	self.redView.addGestureRegonizer(swipeRight)
			    .addGestureRegonizer(swipeLeft)
			    .addGestureRegonizer(swipeUp)
			    .addGestureRegonizer(swipeDown)

앞에서의 addGestureRecognizer를 사용한 것보다 깔끔하게 작성됨을 볼 수 있습니다.

### 정리

자기 자신을 반환하여 Method Chaining을 사용할 수 있습니다.

<br/>ps. UIView의 gestureRecognizer는 array 형태로 한번에 저장할 수 있습니다. <br/>self.redView.gestureRecognizers = [swipeUp, swipeDown, swipeLeft, swipeRight]
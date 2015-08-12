---
layout: post
title: "[Swift]UIGestureRecognizer"
description: ""
category: "Mac/iOS"
tags: [swift, UIGestureRecognizer, UIPanGestureRecognizer, UISwipeGestureRecognizer, UIPinchGestureRecognizer, UIRotationGestureRecognizer, UIScreenEdgePanGestureRecognizer, UILongPressGestureRecognizer, closure, nstimer, transform]
---
{% include JB/setup %}

UIGestureRecognizer를 상속받아 사용할 수 있는 7가지 Gesture Recognizer가 있습니다.

* Tap gesture recognizer
* Swipe gesture recognizer
* Pan gesture recognizer
* Pinch gesture recognizer
* Rotation gesture recognizer
* Screen gesture recognizer
* LongPress gesture recognizer

### UITapGesuteRecognizer

UITapGesuteRecognizer는 다음과 같이 View에 추가할 수 있습니다.

	class ViewController: UIViewController {

		@IBOutlet var redView: UIView!

		override func viewDidLoad() {
			super.viewDidLoad()
			// Do any additional setup after loading the view, typically from a nib.

			var taps = UITapGestureRecognizer(target: self, action: Selector("handleTapGesture:"))
			self.redView.addGestureRecognizer(taps)
		}
	}

	extension ViewController {
		func handleTapGesture(recognizer: UITapGestureRecognizer) {
			println("Touch RedView")
		}
	}


### UISwipeGestureRecognizer

UISwipeGestureRecogizer는 내가 원하는 Swipe 제스쳐에 대해서 만들어 줘야 합니다. 예를 들면, Left, Right 제스쳐를 얻고자 한다면 하나의 UISwipeGestureRecogizer를 만들어 로직을 분리하는 것이 아니라 Left의 UISwipeGestureRecogizer와, Right의 UISwipeGestureRecogizer를 각각 만들어야 합니다.

다음은 UISwipeGestureRecognizer를 만들어 설정하는 코드입니다.

	class ViewController: UIViewController {

		@IBOutlet var redView: UIView!

		override func viewDidLoad() {
			super.viewDidLoad()
			// Do any additional setup after loading the view, typically from a nib.

			var swipeRight = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipeRightGesture:"))
			var swipeLeft = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipeLeftGesture:"))
			var swipeUp = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipeUpGesture:"))
			var swipeDown = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipeDownGesture:"))

			swipeRight.direction = .Right
			swipeLeft.direction = .Left
			swipeUp.direction = .Up
			swipeDown.direction = .Down

			self.redView.gestureRecognizers = [swipeUp, swipeDown, swipeLeft, swipeRight]
		}
	}

	extension ViewController {
		func handleSwipeRightGesture(recognizer: UISwipeGestureRecognizer) {
			println("This swipe is right")
		}
		func handleSwipeLeftGesture(recognizer: UISwipeGestureRecognizer) {
			println("This swipe is left")
		}
		func handleSwipeUpGesture(recognizer: UISwipeGestureRecognizer) {
			println("This swipe is up")
		}
		func handleSwipeDownGesture(recognizer: UISwipeGestureRecognizer) {
			println("This swipe is down")
		}
	}

### UIPanGestureRecognizer

UIPanGestureRecognizer에서 일반적인 표현으로 Drag 대신 Pan이라는 의미가 왜 사용되었는지 알 필요가 있습니다. Panning이라는 의미는 '카메라를 삼각대 위에 고정시켜 놓은 상태에서 움직이는 피사체를 따라 카메라를 수평으로 회전시키는 일'([다음사전][Panning_Dic])으로 디바이스는 고정되어 있는 상태에서 손가락이 움직이기 때문에 Pan이라는 단어를 사용합니다. - [참고][Apple_Document_UIPanGestureRecognizer]

다음은 UIPanGestureRecognizer를 만들어 사용하는 코드입니다.

	class ViewController: UIViewController {

		@IBOutlet var redView: UIView!

		override func viewDidLoad() {
			super.viewDidLoad()
			// Do any additional setup after loading the view, typically from a nib.
			var pan = UIPanGestureRecognizer(target: self, action: Selector("handlePanGesture:"))
			self.redView.addGestureRecognizer(pan)
		}
	}

	extension ViewController {
		func handlePanGesture(recognizer: UIPanGestureRecognizer) {
			var touchLocation = recognizer.locationInView(self.view)
			self.redView.center = touchLocation
			println(recognizer.translationInView(self.view))
		}
	}

redView는 터치 좌표에 따라 중심이 이동합니다. 또한, 최초의 터치 지점으로부터 얼마나 이동했는지 translationInView 함수를 통해 알 수 있습니다. 

### UIPinchGestureRecognizer

UIPinchGestureRecognizer는 두 손가락을 이용하여 화면을 확대하거나 축소할 때 사용하는 경우가 많습니다. 

다음은 특정 뷰 확대/축소를 사용하기 위한 코드입니다.

	class ViewController: UIViewController {

		@IBOutlet var redView: UIView!

		override func viewDidLoad() {
			super.viewDidLoad()
			// Do any additional setup after loading the view, typically from a nib.
			var pinch = UIPinchGestureRecognizer(target: self, action: Selector("handlePinchGesture:"))
			self.redView.addGestureRecognizer(pinch)
		}
	}

	extension ViewController {
		func handlePinchGesture(recognizer: UIPinchGestureRecognizer) {
			if let pinchView = recognizer.view {
				pinchView.transform = CGAffineTransformScale(pinchView.transform, recognizer.scale, recognizer.scale)
				recognizer.scale = 1.0
			}
		}
	}

뷰의 확대/축소를 하고자 한다면 recognizer의 scale를 1.0으로 복구해야 합니다. 그렇지 않으면 핀치 줌을 이용하여 뷰를 확대/축소가 원하는 대로 되지 않습니다.

확대/축소를 제한을 두고자 한다면 다음과 같이 작성할 수 있습니다. [참고][StackOverflow_Pinch]

	func handlePinchGesture(recognizer: UIPinchGestureRecognizer) {
		if recognizer.state == .Began {
			lastScale = recognizer.scale
		}
		if let pinchView = recognizer.view
			where recognizer.state == .Began || recognizer.state == .Changed
		{
			var currentScale = pinchView.layer.valueForKeyPath("transform.scale")?.floatValue
			let kMaxScale:CGFloat = 2.0
			let kMinScale:CGFloat = 0.7

			var newScale = 1.0 - (lastScale - recognizer.scale)
			if let currentScale = currentScale {
				newScale = min(newScale, kMaxScale / (CGFloat)(currentScale))
				newScale = max(newScale, kMinScale / (CGFloat)(currentScale))
				pinchView.transform = CGAffineTransformScale(pinchView.transform, newScale, newScale)
				recognizer.scale = 1.0				
				lastScale = recognizer.scale
			}
		}
	}

최대, 최소의 크기를 정해놓고 Scale을 비교하여 최대, 최소 범위 내에 있는지 확인하고 transform의 scale를 정해줍니다.

### UIRotationGestureRecognizer

UIRotationGestureRecognizer는 두 손가락을 이용하여 뷰를 회전시킵니다. 

다음은 두 손가락을 이용하여 뷰를 회전시키는 코드입니다.

	class ViewController: UIViewController {

		@IBOutlet var redView: UIView!

		override func viewDidLoad() {
			super.viewDidLoad()
			// Do any additional setup after loading the view, typically from a nib.
			var rotation = UIRotationGestureRecognizer(target: self, action: Selector("handleRotationGesture:"))
			self.redView.addGestureRecognizer(rotation)
		}
	}

	extension ViewController {
		func handleRotationGesture(recoginzer: UIRotationGestureRecognizer) {
			if let rotationView = recoginzer.view {
				rotationView.transform = CGAffineTransformRotate(rotationView.transform, recoginzer.rotation)
				recoginzer.rotation = 0.0
			}
		}
	}

UIRotationGestureRecognizer의 rotation 값에 따라 뷰의 회전 값이 달라지게 됩니다.

### UIScreenEdgePanGestureRecognizer

UIScreenEdgePanGestureRecognizer는 스크린 모서리 근처에서 패닝하는 것을 찾습니다. UIScreenEdgePanGestureRecognizer는 뷰에 붙이기 전에 방향을 설정해야 하며, 왼쪽, 오른쪽, 위, 아래를 설정할 수 있습니다.

다음은 스크린 왼쪽에서 패닝하는 것을 찾는 코드입니다.

	class ViewController: UIViewController {

		@IBOutlet var redView: UIView!

		override func viewDidLoad() {
			super.viewDidLoad()
			var leftEdge = UIScreenEdgePanGestureRecognizer(target: self, action: Selector("handleLeftEdgeGesture:"))
			var rightEdge = UIScreenEdgePanGestureRecognizer(target: self, action: Selector("handleRightEdgeGesture:"))

			leftEdge.edges = UIRectEdge.Left
			rightEdge.edges = UIRectEdge.Right

			self.view.gestureRecognizers = [leftEdge, rightEdge]
		}

	extension ViewController {
		func handleLeftEdgeGesture(recoginzer: UIScreenEdgePanGestureRecognizer) {
			println("This Edge is left")
		}
		func handleRightEdgeGesture(recoginzer: UIScreenEdgePanGestureRecognizer) {
			println("This Edge is right")
		}
	}

### UILongPressGestureRecognizer

UILongPressGestureRecognizer는 버튼 또는 뷰 등을 오래 누르는 것을 찾습니다. UILongPressGestureRecognizer는 minimumPressDuration 속성을 통해 특정 시간 후 이벤트를 받아오도록 설정하고, allowableMovement 속성을 통해 누르는 중에 얼마나 이동할 경우 실패할지 대해 설정합니다.

다음은 특정 뷰를 오래 누르는 코드입니다.

	class ViewController: UIViewController {

		@IBOutlet var redView: UIView!

		override func viewDidLoad() {
			super.viewDidLoad()
			var longPress = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPressGesture:"))
			longPress.minimumPressDuration = 0.01
			self.redView.gestureRecognizers = [longPress]
		}

	extension ViewController {
		func handleLongPressGesture(recogizer: UILongPressGestureRecognizer) {
			println("Now Finger is pressing")
		}
	}

위의 코드에서 누른 후 0.01초 후에 이벤트가 발생한 것을 확인할 수 있습니다. 만일 1.0초 이후 이벤트가 시작하기를 원한다면 minimumPressDuration의 값을 1.0으로 설정하면 됩니다.

또한, 터치하다가 다른 곳으로 손가락이 이동한 경우 터치 좌표가 뷰에 내에 있는지 아닌지 판별해야 하는 경우가 있습니다. 이때 CGRectContainsPoint 함수를 이용하여 확인할 수 있습니다.

	func handleLongPressGesture(recogizer: UILongPressGestureRecognizer) {
		var p = recogizer.locationInView(recogizer.view?.superview)
		if let lView = recogizer.view
			where recogizer.state == .Changed {
			if CGRectContainsPoint(lView.frame, p) {
				// Touch Point is inner
			} else {
				// Touch Point is outer
			}
		}
	}

만약 꾹 누르다가 해당 UILongPressGestureRecognizer를 더이상 안받고자 하는 경우 기존 UILongPressGestureRecognizer를 제거하고 다시 추가하면 다시 UILongPressGestureRecognizer를 시작할 수 있습니다.

	extension ViewController {
		func handleLongPressGesture(recogizer: UILongPressGestureRecognizer) {
			println(__FUNCTION__)
			var p = recogizer.locationInView(recogizer.view?.superview)
			let state = recogizer.state
			if let lView = recogizer.view
				where recogizer.state == .Changed
			{
				if CGRectContainsPoint(lView.frame, p) {
					// Touch Point is inner
					count++
				} else {
					// Touch Point is outer
					count++
				}

				if count > 10 {
					println("Remove Gesture")
					count = 0
					var longPress = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPressGesture:"))
					longPress.minimumPressDuration = 0.01
					lView.removeGestureRecognizer(recogizer)
					lView.addGestureRecognizer(longPress)
				}
			} else if (state == .Ended || state == .Cancelled || state == .Failed || state == .Began) {
				count = 0
			}
		}
	}
	
위 코드를 좀 더 확장하여 특정 화면을 특정 시간까지 눌러야 하는 경우, 터치 시작할 때 타이머를 생성하여 특정 시간이 되면 지정된 동작을 수행하거나, 터치 지점이 뷰를 벗어나면 타이머를 취소하도록 할 수 있습니다.

다음은 터치 시작시 타이머 동작하여 특정 시간이 되면 지정된 함수를 수행하는 코드입니다.

첫번째로, 타이머 속성과 남은 시간 확인하는 클로저를 가지는 속성을 정의합니다.

	let kTimer = 20

	class ViewController: UIViewController {

		@IBOutlet var redView: UIView!

		var pressedTouchTimer: NSTimer?
		var elapsedHandler: (Void -> Bool)?

		override func viewDidLoad() {
			super.viewDidLoad()
		}
	}

다음으로 UILongPressGestureRecognizer를 생성하여 붙일 함수를 만듭니다.
	
	func attachLongPressGesture() {
		var longPress = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPressGesture:"))
		longPress.minimumPressDuration = 0.01
		self.redView.gestureRecognizers = [longPress]
	}

<br/>다음은 클로저를 이용하여 특정 값에 도달하면 true/false를 반환하는 함수를 만듭니다.

	func makeElapsedTime() -> ( Void -> Bool) {
		var elapsedTime = kTimer
		func isElapsedTime() -> Bool {
			elapsedTime--
			if elapsedTime < 0 { elapsedTime = 0 }
			return elapsedTime == 0 ? true : false
		}
		return isElapsedTime
	}

<br/>다음은 터치 시작할 때 동작할 타이머와 타이머가 호출될 때 실행될 함수를 만듭니다.

	func startTimer() {
		self.elapsedHandler = makeElapsedTime()

		self.pressedTouchTimer = NSTimer.scheduledTimerWithTimeInterval(
			0.1,
			target: self,
			selector: Selector("longPressTimerHandler"),
			userInfo: nil,
			repeats: true)
	}

	func stopTimer() {
		self.pressedTouchTimer?.invalidate()
		self.pressedTouchTimer = nil
		self.elapsedHandler = nil
	}

	// 지정된 시간이 지날경우 타이머를 종료하고 UILongPressGestureRecognizer를 초기화 하여 더이상 처리하지 않도록 합니다.
	func longPressTimerHandler() {
		if let isElapsedTime = self.elapsedHandler where isElapsedTime() {
			println("Success")
			self.stopTimer()
			self.attachLongPressGesture()
		}
	}

<br/> 이제 UILongPressGestureRecognizer를 처리하는 함수를 만듭니다. 여기에서 터치 시작할 때 타이머를 설정하고 제어합니다.
	
	class ViewController: UIViewController {

		@IBOutlet var redView: UIView!

		var pressedTouchTimer: NSTimer?
		var elapsedHandler: (Void -> Bool)?

		override func viewDidLoad() {
			super.viewDidLoad()

			self.attachLongPressGesture()
		}
		deinit {
			self.stopTimer()
		}

	}

	extension ViewController 
	{
		func handleLongPressGesture(recogizer: UILongPressGestureRecognizer)
		{
			let state = recogizer.state

			if state == .Began {
				self.startTimer()
			}
			else if let lView = recogizer.view
				where recogizer.state == .Changed
			{
				let location = recogizer.locationInView(lView.superview)
				if !CGRectContainsPoint(lView.frame, location) {
					self.stopTimer()
					self.attachLongPressGesture()
				}
			} 
			else if (state == .Ended || state == .Cancelled || state == .Failed) {
				self.stopTimer()
			}
		}
	}

[여기][Gist]에서 해당 코드의 전체 소스를 보실 수 있습니다.

### 정리

UIGestureRecognizer에서 상속받은 7개의 클래스 `UITapGestureRecognizer`, `UISwipeGestureRecognizer`, `UIPanGestureRecognizer`, `UIPinchGestureRecognizer`, `UIRotationGestureRecognizer`, `UIScreenEdgePanGestureRecognizer`, `UILongPressGestureRecognizer`에 대해 정리해보았습니다. UI 개발하면서 어려운 것들은 아니지만 많이 사용하는 클래스이기 때문에, 정리해야될 필요성을 느꼈습니다.

### 참고 자료

* [App Coda](http://www.appcoda.com/ios-gesture-recognizers/)
* [Using Swift's Closures with NSTimer](http://samuelmullen.com/2014/07/using-swifts-closures-with-nstimer/)
* [Apple Document][Apple_Document_UIGestureRecognizer]

[Panning_Dic]: http://dic.daum.net/search.do?q=panning&dic=kor&search_first=Y
[Apple_Document_UIPanGestureRecognizer]: https://developer.apple.com/library/prerelease/ios/documentation/UIKit/Reference/UIPanGestureRecognizer_Class/index.html
[Apple_Document_UIGestureRecognizer]: https://developer.apple.com/library/prerelease/ios/documentation/UIKit/Reference/UIGestureRecognizer_Class/index.html
[StackOverflow_Pinch]: http://stackoverflow.com/a/5446348
[Gist]: https://gist.github.com/minsOne/5b21abd4d3d586885705
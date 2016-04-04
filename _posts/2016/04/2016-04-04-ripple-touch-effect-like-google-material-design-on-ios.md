---
layout: post
title: "[iOS][Swift]구글 매터리얼 디자인의 물결 효과 만들기"
description: ""
category: "Mac/iOS"
tags: [ios, CALayer, CABasicAnimation, CAAnimationGroup, Material]
---
{% include JB/setup %}

<br/><img src="https://farm2.staticflickr.com/1551/25629656254_789d626d8e.jpg" width="315" height="500" alt=""><br/>

가끔씩 매터리얼 디자인의 물결 효과를 보면서 iOS에 적용해볼까 했지만, 이 효과때문에 [Material](https://github.com/CosmicMind/Material) 라이브러리를 추가해야하나 했습니다.
그래서 CALayer를 이용해서 구현해보았습니다.

class ViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap(_:)))
		self.view.addGestureRecognizer(tap)
		self.view.layer.masksToBounds = true
		self.view.backgroundColor = UIColor.orangeColor()
	}

	func tap(recognizer: UITapGestureRecognizer) {
		let hitPoint = recognizer.locationInView(self.view)
		let rippleEffectLayer = CALayer()
		rippleEffectLayer.frame = CGRectMake(hitPoint.x - 5, hitPoint.y - 5, 5, 5)
		rippleEffectLayer.cornerRadius = rippleEffectLayer.frame.height / 2
		rippleEffectLayer.masksToBounds = true;
		rippleEffectLayer.backgroundColor = UIColor(white: 1.0, alpha: 0.2).CGColor
		rippleEffectLayer.zPosition = 1.0
		self.view.layer.addSublayer(rippleEffectLayer)
	}

rippleEffectLayer는 super.layer를 덮을 정도로 커야됩니다. super.layer의 높이와 너비 중 가장 큰 값을 찾고, `CATransform3DMakeScale`를 사용하기 위해 비율을 구합니다.
	
	func tap(recognizer: UITapGestureRecognizer) {
		...
		let maxSize = max(rippleEffectLayer.superlayer!.frame.width, rippleEffectLayer.superlayer!.frame.width)
		let minSize = min(rippleEffectLayer.frame.width, rippleEffectLayer.frame.height)
		let scaleRate = (maxSize / minSize) * 2 * 1.42
	}

CATransform3DMakeScale을 사용하여 rippleEffectLayer를 늘리고, rippleEffectLayer의 backgroundColor를 clearColor로 바꾸도록 애니메이션를 만듭니다.
	
	func tap(recognizer: UITapGestureRecognizer) {
		...
		...
		CATransaction.begin()
		CATransaction.setCompletionBlock {
			rippleEffectLayer.removeFromSuperlayer()
		}
		let group = CAAnimationGroup()
		group.duration = 0.5
		group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)

		let scaleAnimation = CABasicAnimation(keyPath: "transform")
		scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
		scaleAnimation.fromValue = NSValue(CATransform3D: CATransform3DMakeScale(1, 1, 1))
		scaleAnimation.toValue = NSValue(CATransform3D: CATransform3DMakeScale(scaleRate, scaleRate, 1))

		let colorAnimation = CABasicAnimation(keyPath: "backgroundColor")
		colorAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
		colorAnimation.toValue = UIColor.clearColor().CGColor

		group.animations = [scaleAnimation, colorAnimation]

		rippleEffectLayer.addAnimation(group, forKey: "all")

		CATransaction.commit()
	}

다음은 위의 코드를 적용한 화면입니다.

<a data-flickr-embed="true"  href="https://www.flickr.com/photos/134677242@N06/26208502896/in/dateposted-public/" title="rippleEffect"><img src="https://farm2.staticflickr.com/1706/26208502896_28934d832c.jpg" width="282" height="500" alt="rippleEffect"></a><script async src="//embedr.flickr.com/assets/client-code.js" charset="utf-8"></script>

이러한 효과나 화면을 구성하는데는 Xcode Playground를 이용하여 화면을 바로 확인할 수 있으며, 화면 효과등을 실시간으로 보도록 `XCPlaygroundPage.currentPage.liveView`에 view를 할당하면 다음 영상처럼 확인할 수 있습니다.

<a data-flickr-embed="true"  href="https://www.flickr.com/photos/134677242@N06/25629851214/in/dateposted-public/" title="livePage"><img src="https://farm2.staticflickr.com/1585/25629851214_a1fb6aa4b0_c.jpg" width="800" height="500" alt="livePage"></a><script async src="//embedr.flickr.com/assets/client-code.js" charset="utf-8"></script>


---
layout: post
title: "[Swift]SpriteKit을 이용하여 UIView에 눈 내리는 효과 만들기"
description: ""
category: "Mac/iOS"
tags: [swift, spritekit, skview, skscene, particle]
---
{% include JB/setup %}

슬슬 겨울이 다가와 버린 11월 말, 서비스 내에서도 겨울맞이 이벤트 등을 할 때가 있는데요. 그런 이벤트 맞이하여 화면에서 눈이 떨어지는 효과를 추가해보겠습니다.

#### 눈 효과 파티클 만들기

프로젝트 생성 후 파티클을 생성합니다.

<br/><img src="https://farm1.staticflickr.com/649/22741999599_0c7b2ff5ae.jpg" width="500" height="355" alt=""><br/>
<br/><img src="https://farm6.staticflickr.com/5762/22741999509_3e0b4b62e3.jpg" width="500" height="356" alt=""><br/>

파티클 이름을 `snow.sks`로 지정한 후, 눈 내리는 효과를 보여줄 Scene을 만듭니다.

	class SnowScene: SKScene {

		private var presentingView: SKView?
		private var emitter: SKEmitterNode?

		override func didMoveToView(view: SKView) {
			super.didMoveToView(view)
			scaleMode = .ResizeFill
			backgroundColor = UIColor.clearColor()
			presentingView = view
		}

		// 눈 내리는 효과 시작
		func startEmitter() {
			emitter = SKEmitterNode(fileNamed: "snow.sks")
			guard
				let emitter = emitter,
				let presentingView = presentingView
				else { return }

			emitter.particlePositionRange = CGVectorMake(CGRectGetWidth(presentingView.bounds), 0)
			emitter.position = CGPointMake(CGRectGetMidX(presentingView.bounds), CGRectGetHeight(presentingView.bounds))
			emitter.targetNode = self

			addChild(emitter)
		}

		// 눈 내리는 효과 정지
		func stopEmitter() {
			guard let emitter = emitter else { return }
			emitter.particleBirthRate = 0.0
			emitter.targetNode = nil
			emitter.removeFromParent()
			self.emitter = nil
		}
	}

그리고 메인 ViewController에서 SnowScene을 보여줄 SKView, SnowScene 변수를 선언합니다.

	@IBOutlet weak private var snowView: UIView!
	private var sceneView: SKView?
	private var snowScene: SnowScene?

이제 sceneView와 snowScene을 생성하여 UIView인 snowView에 붙여줍니다.

	override func viewDidLoad() {
		super.viewDidLoad()

		sceneView = SKView(frame: self.view.frame)
		snowScene = SnowScene()
		guard
			let sceneView = sceneView,
			let snowScene = snowScene
			else { return }
		sceneView.backgroundColor = UIColor.clearColor()
		sceneView.presentScene(snowScene)
		snowView.addSubview(sceneView)
	}

그리고 화면이 나타나면 눈 내리는 효과를 시작하도록 합니다.

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		guard let snowScene = snowScene else { return }
		snowScene.startEmitter()
	}

그리고 화면이 사라지면 sceneView를 정리하고 눈 내리는 효과를 끕니다.

	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)

		guard
			let snowScene = snowScene,
			let sceneView = sceneView
			else { return }
		sceneView.presentScene(nil)
		sceneView.removeFromSuperview()
		snowScene.stopEmitter()
	}

<br/>특정 기간이 되거나 서버에서 눈 내리는 효과를 보여주라고 전달하면 눈 내리는 효과를 보여주면 됩니다.<br/>

<a data-flickr-embed="true"  href="https://www.flickr.com/photos/134677242@N06/22715895538/in/datetaken/" title="fallingSnow"><img src="https://farm1.staticflickr.com/703/22715895538_58c4f16d08.jpg" width="282" height="500" alt="fallingSnow"></a><script async src="//embedr.flickr.com/assets/client-code.js" charset="utf-8"></script><br/>

<div class="alert warning"><strong>주의</strong> : sceneView의 presentScene을 정리하지 않으면 계속 살아있기 때문에 성능에 영향을 줍니다. 따라서 여러 번 실행하여 성능에 문제가 없는지 확인을 하는 것이 중요합니다.</div>

[여기](https://gist.github.com/minsOne/71e7d761489e70e5f63a)에서 ViewController와 SnowScene 전체 소스를 받으시면 됩니다.<br/><br/>
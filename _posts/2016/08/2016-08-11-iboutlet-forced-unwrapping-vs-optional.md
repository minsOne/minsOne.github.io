---
layout: post
title: "[Swift]@IBOutlet의 Forced Unwrapping Optional(!) vs Optional(?)"
description: ""
category: "Mac/iOS"
tags: [iboutlet, nib, storyboard, forced unwrapping, optional, isViewLoaded, optional chaining, runtime error]
---
{% include JB/setup %}

얼마 전 개발 진행하면서 코드로 UI를 개발하던 부분들을 Storyboard로 이전하다가 예상치 못한 부분이 있었습니다. 바로 `@IBOutlet` 입니다. 

아이폰, 아이패드에 대응하여 개발하다가 Storyboard 하나에 모두 넣기엔 너무 방대해져서, 어떤 화면은 nib, 또는 비슷한 화면을 Storyboard에 넣어 관리하였습니다. 그리고 Storyboard 또는 Nib을 직접 호출하여 객체를 생성하고, 관리했습니다.

문제는 nib과 연결된 UI 속성이 `forced unwrapping optional` 입니다.(ex. @IBOutlet weak var label: UILabel!) 만약 viewDidLoad가 된 상태가 아니라면 nib과 연결된 UI 속성은 아직 객체가 생성되지 않은 상태입니다. 따라서, UI 속성에 객체가 당연히 있다고 가정하고 접근한다면 `EXC_BAD_INSTRUCTION` 런타임 에러가 발생합니다.

런타임 에러가 발생하는 예제입니다.

```swift
	class CustomViewController: UIViewController {
		@IBOutlet weak var label: UILabel!

		func setText(str: String) { self.label.text = str }
	}

	let vc = CustomViewController()
	vc.setText("Hello") // EXC_BAD_INSTRUCTION 런타임 에러 발생
```

이러한 상황을 미리 방지하기 위해 `forced unwrapping optional`이 아니라 `optional` 타입으로 사용하거나, `optional chaining`을 이용하거나, [isViewLoaded](https://developer.apple.com/reference/uikit/uiviewcontroller/1621470-isviewloaded) 함수를 통해 View가 메모리에 적재되었는지 확인을 해야 합니다.

```swift
	// forced unwrapping optional을 optional 타입으로 바꾼 경우
	class CustomViewController: UIViewController {
		@IBOutlet weak var label: UILabel?

		func setText(str: String) { self.label?.text = str }
	}

	// isViewLoaded 함수를 사용한 경우
	class CustomViewController: UIViewController {
		@IBOutlet weak var label: UILabel!

		func setText(str: String) { 
			guard self.isViewLoaded == true else { return }
			self.label.text = str
		}
	}

	// optional chaining을 이용한 경우
	class CustomViewController: UIViewController {
		@IBOutlet weak var label: UILabel!

		func setText(str: String) {
			self.label?.text = str
		}
	}
```

UITabbarController를 사용하는 경우, 여러 ViewController를 childViewControllers에 넣고 사용합니다. 그리고 모든 childViewController의 UI를 업데이트를 하는데 아직 사용하지 않은 childViewController는 View가 Load되지 않았기 때문에 위와 같은 이유로 런타임 에러를 여러 번 겪었습니다.

따라서 `@IBOutlet`을 사용할 때 `optional`를 사용하거나, `forced unwrapping optional`이라도 값이 nil일 수 있으니 optional chaining을 이용하거나, `isViewLoaded` 함수를 통해 View가 Load 되었는지 확인하여 런타임 에러를 해결하였습니다.

## 참고 자료

* [To Optional or Not to Optional: IBOutlet](https://blog.curtisherbert.com/to-optional-or-not-to-optional-iboutlet/)
* [Optional Chaining](http://minsone.github.io/mac/ios/swift-optional-chaining-summary)
* [Apple Document - Using Swift with Cocoa and Objective-C](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/WritingSwiftClassesWithObjective-CBehavior.html)


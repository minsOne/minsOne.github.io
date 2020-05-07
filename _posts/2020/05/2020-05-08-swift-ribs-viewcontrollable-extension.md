---
layout: post
title: "[Swift5][RIBs] Uber의 RIBs 프로젝트에서 얻은 경험 (6) - ViewControllable 확장 및 Wrapper"
description: ""
category: "programming"
tags: [iOS, Swift, Uber, RIBs, ViewControllable, Extension, UIViewController, Wrapper]
---
{% include JB/setup %}

## Extension

RIB에서 ViewControllable 프로토콜을 이용하여 Router에서 ViewControllable에게 어떤 것이 필요한지를 정의하고, ViewControllable를 만족하는 ViewController는 해당 기능을 구현합니다.

```swift
protocol MainViewControllable: ViewControllable {
  func present(viewController: ViewControllable)
  func dismiss(viewController: ViewControllable)
}

class MainViewController: UIViewController, MainViewControllable {
  func present(viewController: ViewControllable) {
  	...
  }

  func dismiss(viewController: ViewControllable) {
  	...
  }
}
```

Router에서는 ViewController에게 요청하는 것들은 대부분 Present, Push, Dismiss, Pop 같은 요청들이 많습니다. 따라서 이러한 것들을 매번 구현하는 것 보다는 공통으로 만들어 사용하는 것이 깔끔합니다.

그래서 ViewControllable을 따르는 NavigateViewControllable를 정의하고, NavigateViewControllable는 대부분의 공통 코드인 Present, Push, Dismiss, Pop을 선언하고, Extension에서 구현합니다.

```
protocol NavigateViewControllable: ViewControllable {
  func presentViewController(viewController: ViewControllable)
  func presentNavigationViewController(root: ViewControllable)
  func dismissViewController(viewController: ViewControllable)
  func pushViewController(viewController: ViewControllable)
  func popViewController(viewController: ViewControllable)
}

extension NavigateViewControllable {
  func presentViewController(viewController: ViewControllable) {
  	uiviewController.present(viewController.uiviewController, animated: true, completion: nil)
  }
  func presentNavigationViewController(root: ViewControllable) {
  	let navi = UINavigationController(rootViewController: viewController.uiviewController)
  	uiviewController.present(navi, animated: true, completion: nil)
  }
  func dismissViewController(viewController: ViewControllable) {
  	viewController.uiviewController.dismiss(animated: true, completion: nil)
  }
  func pushViewController(viewController: ViewControllable) {
  	navigationController?.pushViewController(viewController.uiviewController, animated: true)
  }
  func popViewController(viewController: ViewControllable) {
  	viewController.uiviewController.navigationController?.popToViewController(uiviewController, animated: true)
  }
}
```

## Wrapper

ViewControllable는 UIViewController를 속성으로 가지는 Protocol로, 아주 간단하게 되어 있습니다. 그리고 ViewControllable가 특정 UIViewController를 따르도록 하면 더 쉽게 사용할 수 있습니다. 

하지만 ViewControllable이 특정 UIViewContoller에 사용이 불가피한 경우에는 일반 class 타입이 ViewControllable를 따르도록 하고, UIViewController 객체를 주입하는 방식으로 할 수 있습니다.

```
protocol MainViewControllable: ViewControllable {}

final class MainViewControllerWrapper: MainViewControllable {
  let uiviewController: UIViewController

  init(uiviewController: UIViewController) {
  	self.uiviewController = uiviewController
  }
}
```
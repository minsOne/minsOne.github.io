---
layout: post
title: "[iOS]왜 addChildViewController를 사용해야 하는가? - Container View Controller 구현"
description: ""
category: "Mac/iOS"
tags: [ios, UIViewController, addChildViewController, removeFromParentViewController]
---
{% include JB/setup %}

요즘에 제대로된 iOS 앱 구조를 작성하고 있어, 그동안 자세히 살펴보지 못했던 것들을 보고 있습니다. 그 중에서 Container View Controller에서 Child View Controller를 추가할 때 왜 addChildViewController를 해야하는지 대충 알고는 있었지만, 왜 그렇게 하는지를 정확히는 몰랐습니다.

그래서 Apple Document 중 UIViewController Class의 [Implementing a Container View Controller](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIViewController_Class/index.html)에 서술되어 있는 것을 확인하고 정리하였습니다.

<br/>

# Container View Controller 구현

* Custom UIViewController Subclass는 Container View Controller 역할을 할 수 있음.
* Container View Controller는 소유하고 있는 Child View Controller의 표시를 관리함.
* Child View는 그대로 표시하거나 Container View Controller가 소유한 View와 같이 표시함.

* Container View Controller subclass는 Children View Controller와 연관된 public interface를 선언해야 함.
* Container View Controller에서 한번에 몇 개의 Children View Controller를 보여줄 지 지정해야하며, Container View Controller의 View hierarchy에서 나타남.
* Children View Controller 간에 공유 관계를 Container View Controller가 정의함.
* Container View Controller에 깨끗한 public interface를 구축하여 Children View Controller를 논리적으로 이용이 가능하며, 따라서 어떻게 구현되었는지 상세한 부분은 알 필요가 없음.

* View hierarchy에 Child의 Root View를 추가하기 전에 Child View Controller는 Container View Controller와 연결되어야 함.
* Child View Controller에 정확하게 `이벤트`를 전달하며, View들은 해당 Controller가 관리함.
* Child의 Root View를 Container View hierarchy에서 제거한 후, Child View Controller View Controller는 Container View Controller와 연결을 끊어야 함.
* 연결을 맺거나 끊기 위해선 Container View Controller에서 `addChildViewController`나 `removeFromParentViewController`메소드를 사용한다.

## 참고 자료

* [Apple Document](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIViewController_Class/index.html)

<br/>
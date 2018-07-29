---
layout: post
title: "[Xcode][LLDB]Debugging With Xcode, LLDB and Chisel"
description: ""
category: ""
tags: []
---
{% include JB/setup %}

iOS 개발시 LLDB를 이용하여 디버깅을 하지만, 낮은 수준의 명령어들을 지원하기 때문에 조금은 불편한 점이 있습니다. 관련하여 Facebook에서 [Chisel](https://github.com/facebook/chisel)이라는 프로젝트를 통해 python을 이용하여 높은 수준의 명령어를 지원합니다.

이 Chisel의 명령어들을 알아보겠습니다.

### **pvc** - ViewController Hierarchy를 출력해주는 명령어

```
(lldb) pvc
<UIViewController 0x7f85274116b0>, state: disappeared, view: <UIView 0x7f8527708ad0> not in the window
   + <UIViewController 0x7f8527609180>, state: disappeared, view: <UIView 0x7f8527411c10> not in the window, presented with: <_UIFullscreenPresentationController 0x7f852740e4b0>
   |    + <UIViewController 0x7f8527609f70>, state: disappeared, view: <UIView 0x7f8527602690> not in the window, presented with: <_UIFullscreenPresentationController 0x7f8527609d70>
   |    |    + <UIViewController 0x7f8527501000>, state: appeared, view: <UIView 0x7f8527502520>, presented with: <_UIFullscreenPresentationController 0x7f8527505240>
```

`pvc`를 실행한 결과로 현재 Present된 ViewController의 주소인 `0x7faa7e80cb50`를 찾아냈습니다. 그러면 최상위로 Present된 ViewController를 dismiss하고, 두 번째 최상위 ViewController의 색상을 Red로 변경해봅니다.

```
(lldb) e -l swift --
1 import UIKit
2 let $vc = unsafeBitCast(0x7f8527501000, to: UIViewController.self)
3 $vc.dismiss(animated: true, completion: nil)
4 let $nextvc = unsafeBitCast(0x7f8527609f70, to: UIViewController.self)
5 $nextvc.view.backgroundColor = UIColor.red
```

### **pviews** - View Hierarchy를 출력해주는 명령어
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

### **pvc** - rootViewController로부터 시작하고 UIWindow에 표시하는 모든 UIViewController를 출력하는 명령어

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

### **pviews** - UIWindow에 표시되는 모든 UIView를 출력하는 명령어

```
(lldb) pviews
<UIWindow: 0x7f811ce0cb50; frame = (0 0; 414 736); gestureRecognizers = <NSArray: 0x600000ae1170>; layer = <UIWindowLayer: 0x6000004e8640>>
   | <UITransitionView: 0x7f811cc0e8d0; frame = (0 0; 414 736); autoresize = W+H; layer = <CALayer: 0x6000004e9500>>
   | <UITransitionView: 0x7f811cf062a0; frame = (0 0; 414 736); autoresize = W+H; layer = <CALayer: 0x6000004ef5c0>>
   | <UITransitionView: 0x7f811ce11570; frame = (0 0; 414 736); autoresize = W+H; layer = <CALayer: 0x6000004eeda0>>
   |    | <UIView: 0x7f811cd05950; frame = (0 0; 414 736); autoresize = W+H; layer = <CALayer: 0x6000004e9b00>>
   |    |    | <UIButton: 0x7f811cf064d0; frame = (164 318; 46 30); opaque = NO; autoresize = RM+BM; layer = <CALayer: 0x6000004ee660>>
   |    |    |    | <UIButtonLabel: 0x7f811cc16460; frame = (0.333333 6; 45.6667 18); text = 'Button'; opaque = NO; userInteractionEnabled = NO; layer = <_UILabelLayer: 0x6000027b72a0>>
```
### **fv** - 현재 표시되는 화면에서 특정 UIView 클래스를 찾아 출력하는 명령어

```
(lldb) fv UIButton
0x7f811cf064d0 UIButton
0x7f811cc16460 UIButtonLabel
```

### **fvc** - pvc와 비슷하나 특정 UIViewController 클래스를 찾아 출력하는 명령어

```
(lldb) fvc BaseViewController
0x7f9329c09d50 SampleProject.BaseViewController
```

### **visualize** - UIView를 이미지로 떠 Preview로 열어 보여주는 명령어

```
(lldb) visualize self.view

/// runtime시
(lldb) e -l swift --
1 import UIKit
2 let $view = unsafeBitCast(0x7f8527501000, to: UIView.self)
3
(lldb) visualize $view
```

### **show/hide** - 특정 UIView나 CALayer를 숨기거나 보여주는 명렁어

```
(lldb) show self.view
(lldb) hide self.view
```

### **present/dismiss** - 특정 UIViewController를 presnt하거나 dismiss 하는 명령어

```
(lldb) present viewController
(lldb) dismiss self
```

### **slowanim/unslowanim** -- 애니메이션을 느리게 하거나 정상으로 돌려주는 명령어

```
/// 애니메이션 속도를 느리게 함.
(lldb) slowanim

// 느린 속도의 애니메이션을 끔.
(lldb) unslowanim
```

### **pclass** - 해당 인스턴스의 상속 계층 구조를 보여주는 명령어

```
(lldb) pclass 0x7ff0e2d14330
UIViewController
   | UIResponder
   |    | NSObject
```

## 참고자료
* https://kapeli.com/cheat_sheets/LLDB_Chisel_Commands.docset/Contents/Resources/Documents/index
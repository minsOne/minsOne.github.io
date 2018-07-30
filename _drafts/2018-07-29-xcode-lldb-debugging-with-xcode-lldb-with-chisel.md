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

`pvc`를 실행하여 현재 Present된 ViewController의 주소인 `0x7faa7e80cb50`를 찾았습니다. 그러면 최상위로 Present된 ViewController를 dismiss하고, 두 번째 최상위 ViewController의 색상을 Red로 변경해봅니다.

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

### **pclass** - 해당 인스턴스의 상속 계층 구조를 보여주는 명령어

```
(lldb) pclass 0x7ff0e2d14330
UIViewController
   | UIResponder
   |    | NSObject
```

### **pinternals** - 객체 내부를 보여주는 명령어

```
(lldb) pinternals 0x7fada0624840
(_UITableViewCellSeparatorView) $53 = {
  UIView = {
    UIResponder = {
      NSObject = {
        isa = _UITableViewCellSeparatorView
      }
    }
  }
  _drawsWithVibrantLightMode = false
  _backgroundView = nil
  _overlayView = nil
  _separatorEffect = nil
  _effectView = nil
}
```

### **pkp** - KeyPath를 통해 값울 출력하는 명령어

```
(lldb) pvc
<UITableViewController 0x7fada0406ae0>, state: appeared, view: <UITableView 0x7fada085dc00>
(lldb) pkp 0x7fada0406ae0 .view.backgroundColor
UIExtendedSRGBColorSpace 1 1 1 1
(lldb) pkp 0x7fada0406ae0 .view.isHidden
0
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

/// 또는 메모리 주소만 인자로 넘기는 것도 가능함.
(lldb) visualize 0x7f8527501000
```

### **show/hide** - 특정 UIView나 CALayer를 숨기거나 보여주는 명렁어

```
/// 해당 명령어는 objective-c 코드로 객체를 선언해야 사용 가능함.
(lldb) pviews
<UIWindow: 0x7f80f2e0f480; frame = (0 0; 414 736); gestureRecognizers = <NSArray: 0x6000011ecab0>; layer = <UIWindowLayer: 0x600001ffc660>>
   | <UIView: 0x7f80f2d0f1d0; frame = (0 0; 414 736); autoresize = W+H; layer = <CALayer: 0x600001f8b760>>
   |    | <UIButton: 0x7f80f2d0d540; frame = (164 318; 46 30); opaque = NO; autoresize = RM+BM; layer = <CALayer: 0x600001f8b700>>
   |    |    | <UIButtonLabel: 0x7f80f2c01f20; frame = (0.333333 6; 45.6667 18); text = 'Button'; opaque = NO; userInteractionEnabled = NO; layer = <_UILabelLayer: 0x600003ca6620>>
(lldb) e -l objc -- UIView *$view = (UIView *)0x7f80f2d0d540
(lldb) show $view
(lldb) hide $view
```

### **present/dismiss** - 특정 UIViewController를 presnt하거나 dismiss 하는 명령어

```
/// 해당 명령어는 objective-c 코드로 객체를 선언해야 사용 가능함.
(lldb) pvc
<SampleProject.BaseViewController 0x7f80f2e0e400>, state: disappeared, view: <UIView 0x7f80f2d0f1d0> not in the window
   + <UIViewController 0x7f80f2d103c0>, state: disappeared, view: <UIView 0x7f80f2d08c30> not in the window, presented with: <_UIFullscreenPresentationController 0x7f80f2c0b850>
   |    + <SampleProject.BaseViewController 0x7f80f2c03730>, state: disappeared, view: <UIView 0x7f80f2e02460> not in the window, presented with: <_UIFullscreenPresentationController 0x7f80f2c0aa90>
   |    |    + <UIViewController 0x7f80f2f09170>, state: disappeared, view: <UIView 0x7f80f2f06240> not in the window, presented with: <_UIFullscreenPresentationController 0x7f80f2f05cd0>
   |    |    |    + <SampleProject.BaseViewController 0x7f80f2e16640>, state: appeared, view: <UIView 0x7f80f2f0a860>, presented with: <_UIFullscreenPresentationController 0x7f80f2e018f0>
(lldb) expr -l objc -- UIViewController *$vc = (UIViewController *)0x7f80f2e16640
(lldb) dismiss $vc
```

### **slowanim/unslowanim** -- 애니메이션을 느리게 하거나 정상으로 돌려주는 명령어

```
/// 애니메이션 속도를 느리게 함.
(lldb) slowanim

// 느린 속도의 애니메이션을 끔.
(lldb) unslowanim
```

### **border/unborder** - 해당 View 또는 Layer에 border를 설정하거나 끄는 명령어

```
(lldb) pviews
<UIWindow: 0x7f80f2e0f480; frame = (0 0; 414 736); gestureRecognizers = <NSArray: 0x6000011ecab0>; layer = <UIWindowLayer: 0x600001ffc660>>
   | <UITransitionView: 0x7f80f2e0ec70; frame = (0 0; 414 736); autoresize = W+H; layer = <CALayer: 0x600001fec9e0>>
   | <UIView: 0x7f80f2e10980; frame = (164.333 324; 45.6667 18); alpha = 0.5; tag = 140191808395632; layer = <CALayer: 0x600001ff1a80>>
   | <UITransitionView: 0x7f80f2e16990; frame = (0 0; 414 736); autoresize = W+H; layer = <CALayer: 0x600001ff1c20>>
   |    | <UIView: 0x7f80f2d11b40; frame = (0 0; 414 736); autoresize = W+H; layer = <CALayer: 0x600001fece40>>
   |    |    | <UIButton: 0x7f80f2d11820; frame = (164 318; 46 30); opaque = NO; autoresize = RM+BM; layer = <CALayer: 0x600001fece20>>
   |    |    |    | <UIButtonLabel: 0x7f80f2e17330; frame = (0.333333 6; 45.6667 18); text = 'Button'; opaque = NO; userInteractionEnabled = NO; layer = <_UILabelLayer: 0x600003c97b60>>
(lldb) border 0x7f80f2d11b40
(lldb) border 0x7f80f2d11b40 --color blue
(lldb) border 0x7f80f2d11b40 --color blue --width 10
(lldb) unborder 0x7f80f2d11b40
```

### **vs** - 대화식으로 View를 계층구조 간 이동하도록 하는 명령어

```
(lldb) vs 0x7f80f2d11820

Use the following and (q) to quit.
(w) move to superview
(s) move to first subview
(a) move to previous sibling
(d) move to next sibling
(p) print the hierarchy
```

### **ptv** - 현재 화면에 나타난 최상위의 UITableView를 출력하는 명령어

```
(lldb) ptv
<UITableView: 0x7fada085dc00; frame = (0 0; 414 736); clipsToBounds = YES; autoresize = W+H; gestureRecognizers = <NSArray: 0x6000029668e0>; layer = <CALayer: 0x60000276da40>; contentOffset: {0, -20}; contentSize: {414, 489}; adjustedContentInset: {20, 0, 0, 0}>
```

### **pcells** - 현재 화면에 나타난 최상위의 UITableView에 visible cell을 출력하는 명령어

```
(lldb) pcells
<__NSArrayM 0x600002967330>(
<UITableViewCell: 0x7fada084b200; frame = (0 28; 414 45); clipsToBounds = YES; autoresize = W; layer = <CALayer: 0x600002769580>>,
<UITableViewCell: 0x7fada0838200; frame = (0 73; 414 45); clipsToBounds = YES; autoresize = W; layer = <CALayer: 0x60000276cf80>>,
<UITableViewCell: 0x7fada084e400; frame = (0 118; 414 45); clipsToBounds = YES; autoresize = W; layer = <CALayer: 0x60000276d0c0>>,
<UITableViewCell: 0x7fada085aa00; frame = (0 191; 414 45); clipsToBounds = YES; autoresize = W; layer = <CALayer: 0x60000276d220>>,
<UITableViewCell: 0x7fada085c000; frame = (0 236; 414 45); clipsToBounds = YES; autoresize = W; layer = <CALayer: 0x60000276d360>>,
<UITableViewCell: 0x7fada085ca00; frame = (0 281; 414 45); clipsToBounds = YES; autoresize = W; layer = <CALayer: 0x60000276d4a0>>,
<UITableViewCell: 0x7fada085d000; frame = (0 354; 414 45); clipsToBounds = YES; autoresize = W; layer = <CALayer: 0x60000276d600>>,
<UITableViewCell: 0x7fada1040200; frame = (0 399; 414 45); clipsToBounds = YES; autoresize = W; layer = <CALayer: 0x6000027696e0>>,
<UITableViewCell: 0x7fada085d600; frame = (0 444; 414 45); clipsToBounds = YES; autoresize = W; layer = <CALayer: 0x60000276d720>>
)

```

### **paltrace** - SubView들의 Hierarchy를 출력하는 명령어, 기본은 Key Window로부터 시작함.

```
(lldb) paltrace 
UIWindow:0x7fada06120b0
|   UITableView:0x7fada085dc00
|   |   UITableViewCell:0x7fada085d600
|   |   |   UITableViewCellContentView:0x7fada0617ab0
|   |   |   _UITableViewCellSeparatorView:0x7fada0617ca0
|   |   |   _UITableViewCellSeparatorView:0x7fada0505a60
|   |   UITableViewCell:0x7fada1040200
|   |   |   UITableViewCellContentView:0x7fada070f5c0
|   |   |   _UITableViewCellSeparatorView:0x7fada070f7b0
|   |   |   _UITableViewCellSeparatorView:0x7fada0505540
|   |   UITableViewCell:0x7fada085d000
|   |   |   UITableViewCellContentView:0x7fada06175d0
|   |   |   _UITableViewCellSeparatorView:0x7fada070f240
|   |   |   _UITableViewCellSeparatorView:0x7fada0504e20
|   |   UITableViewCell:0x7fada085ca00
|   |   |   UITableViewCellContentView:0x7fada0617060
|   |   |   _UITableViewCellSeparatorView:0x7fada0617250
|   |   |   _UITableViewCellSeparatorView:0x7fada0504900
|   |   UITableViewCell:0x7fada085c000
|   |   |   UITableViewCellContentView:0x7fada06168f0
|   |   |   _UITableViewCellSeparatorView:0x7fada0616ae0
|   |   |   _UITableViewCellSeparatorView:0x7fada05043e0
|   |   UITableViewCell:0x7fada085aa00
|   |   |   UITableViewCellContentView:0x7fada0616380
|   |   |   _UITableViewCellSeparatorView:0x7fada0616570
|   |   |   _UITableViewCellSeparatorView:0x7fada0503ec0
|   |   UITableViewCell:0x7fada084e400
|   |   |   UITableViewCellContentView:0x7fada0615cd0
|   |   |   _UITableViewCellSeparatorView:0x7fada0615ec0
|   |   |   _UITableViewCellSeparatorView:0x7fada0502430
|   |   UITableViewCell:0x7fada0838200
|   |   |   UITableViewCellContentView:0x7fada0615340
|   |   |   _UITableViewCellSeparatorView:0x7fada0615740
|   |   |   _UITableViewCellSeparatorView:0x7fada0501d10
|   |   UITableViewCell:0x7fada084b200
|   |   |   UITableViewCellContentView:0x7fada070e4e0
|   |   |   _UITableViewCellSeparatorView:0x7fada070e9f0
|   |   |   _UITableViewCellSeparatorView:0x7fada070b0a0
|   |   UITableViewHeaderFooterView:0x7fada0505c70
|   |   |   _UITableViewHeaderFooterViewBackground:0x7fada0506600
|   |   |   _UITableViewHeaderFooterContentView:0x7fada0506100
|   |   |   |   _UITableViewHeaderFooterViewLabel:0x7fada0621d10'Section-1'
|   |   UITableViewHeaderFooterView:0x7fada070dc10
|   |   |   _UITableViewHeaderFooterViewBackground:0x7fada070e280
|   |   |   _UITableViewHeaderFooterContentView:0x7fada070e0a0
|   |   |   |   _UITableViewHeaderFooterViewLabel:0x7fada07135a0'Section-2'
|   |   UITableViewHeaderFooterView:0x7fada0713cb0
|   |   |   _UITableViewHeaderFooterViewBackground:0x7fada0714110
|   |   |   _UITableViewHeaderFooterContentView:0x7fada0713f30
|   |   |   |   _UITableViewHeaderFooterViewLabel:0x7fada0714300'Section-3'
|   |   _UITableViewCellSeparatorView:0x7fada06239d0
|   |   _UITableViewCellSeparatorView:0x7fada0623be0
|   |   _UITableViewCellSeparatorView:0x7fada0623df0
|   |   _UITableViewCellSeparatorView:0x7fada0624000
|   |   _UITableViewCellSeparatorView:0x7fada0624210
|   |   _UITableViewCellSeparatorView:0x7fada0624420
|   |   _UITableViewCellSeparatorView:0x7fada0624630
|   |   _UITableViewCellSeparatorView:0x7fada0624840
|   |   _UITableViewCellSeparatorView:0x7fada0624a50
|   |   _UITableViewCellSeparatorView:0x7fada0624c60
|   |   _UITableViewCellSeparatorView:0x7fada0624e70
|   |   _UITableViewCellSeparatorView:0x7fada0625080
|   |   _UITableViewCellSeparatorView:0x7fada0625290
|   |   _UITableViewCellSeparatorView:0x7fada06254a0
|   |   UIImageView:0x7fada061f1c0
|   |   UIImageView:0x7fada061ef90

(lldb) paltrace 0x7fada085d600

UITableViewCell:0x7fada085d600
|   UITableViewCellContentView:0x7fada0617ab0
|   _UITableViewCellSeparatorView:0x7fada0617ca0
|   _UITableViewCellSeparatorView:0x7fada0505a60
```

## 참고자료
* https://kapeli.com/cheat_sheets/LLDB_Chisel_Commands.docset/Contents/Resources/Documents/index
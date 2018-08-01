---
layout: post
title: "[Xcode][LLDB]Debugging With Xcode, LLDB and Chisel"
description: ""
category: ""
tags: []
---
{% include JB/setup %}

iOS 개발시 LLDB를 이용하여 디버깅을 하지만, 낮은 수준의 명령어들을 지원하기 때문에 조금은 불편한 점이 있습니다. 관련하여 Facebook에서 [Chisel](https://github.com/facebook/chisel)이라는 프로젝트를 통해 python을 이용하여 높은 수준의 명령어를 지원합니다.

## Install

일반적으로 Homebrew를 사용하여 설치합니다.

```
$ brew install chisel
```

그리고 .lldbinit 파일에다 chisel 스크립트를 추가합니다.(없다면 만듭니다.)

```
$ echo 'command script import /usr/local/opt/chisel/libexec/fblldb.py' >> ~/.lldbinit
```

이제 Chisel 명령을 사용할 수 있습니다. 만약 설치가 잘 되지 않는다면 [Chisel](https://github.com/facebook/chisel)의 README.md 파일을 읽어보면 설치가 나와있습니다.

이제 Chisel 명령어들을 살펴보겠습니다.

## Commands

### **pvc** - rootViewController로부터 시작하고 UIWindow에 표시하는 모든 UIViewController를 출력하는 명령어

```
(lldb) pvc
<UIViewController 0x7f85274116b0>, state: disappeared, view: <UIView 0x7f8527708ad0> not in the window
   + <UIViewController 0x7f8527609180>, state: disappeared, view: <UIView 0x7f8527411c10> not in the window, presented with: <_UIFullscreenPresentationController 0x7f852740e4b0>
   |    + <UIViewController 0x7f8527609f70>, state: disappeared, view: <UIView 0x7f8527602690> not in the window, presented with: <_UIFullscreenPresentationController 0x7f8527609d70>
   |    |    + <UIViewController 0x7f8527501000>, state: appeared, view: <UIView 0x7f8527502520>, presented with: <_UIFullscreenPresentationController 0x7f8527505240>
(lldb) pvc 0x7f85274116b0
<UIViewController: 0x7f85274116b0; view = <UIView; 0x7f8527708ad0>; frame = (0, 0; 414, 736)>
```

`pvc`를 실행하여 현재 Present된 ViewController의 주소인 `0x7faa7e80cb50`를 찾았습니다. 그러면 최상위로 Present된 ViewController를 dismiss하고, 두 번째 최상위 ViewController의 색상을 Red로 변경해봅니다.

```
(lldb) settings set target.language swift
(lldb) po
Enter expressions, then terminate with an empty line to evaluate:
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
(lldb) pviews
<UIWindow: 0x7f99505075b0; frame = (0 0; 414 736); gestureRecognizers = <NSArray: 0x6000031e0570>; layer = <UIWindowLayer: 0x600003f86a60>>
   | <UITransitionView: 0x7f9950615d50; frame = (0 0; 414 736); autoresize = W+H; layer = <CALayer: 0x600003ff4da0>>
   | <UITransitionView: 0x7f99507090f0; frame = (0 0; 414 736); autoresize = W+H; layer = <CALayer: 0x600003ff14c0>>
   |    | <UIView: 0x7f9950708cd0; frame = (0 0; 414 736); autoresize = W+H; layer = <CALayer: 0x600003ff0ae0>>
   |    |    | <UIButton: 0x7f995070b050; frame = (164 318; 46 30); opaque = NO; autoresize = RM+BM; layer = <CALayer: 0x600003ff0340>>
   |    |    |    | <UIButtonLabel: 0x7f9950406a00; frame = (0.333333 6; 45.6667 18); text = 'Button'; opaque = NO; userInteractionEnabled = NO; layer = <_UILabelLayer: 0x600001c98190>>

(lldb) pclass 0x7f9950708cd0
UIView
   | UIResponder
   |    | NSObject
```

`pclass` 등 명령어는 Swift를 지원하지 않기 때문에 다음과 같은 명령을 실행하면 에러가 출력합니다.

```
(lldb) pclass self.view
error: error: use of undeclared identifier 'self'
Traceback (most recent call last):
  File "/usr/local/opt/chisel/libexec/fblldb.py", line 84, in runCommand
    command.run(args, options)
  File "/usr/local/Cellar/chisel/1.8.0/libexec/commands/FBPrintCommands.py", line 155, in run
    _printIterative(arguments[0], _inheritanceHierarchy)
  File "/usr/local/Cellar/chisel/1.8.0/libexec/commands/FBPrintCommands.py", line 139, in _printIterative
    for currentValue in generator(initialValue):
  File "/usr/local/Cellar/chisel/1.8.0/libexec/commands/FBPrintCommands.py", line 159, in _inheritanceHierarchy
    instanceClass = fb.evaluateExpression('(id)[(id)' + instanceAddress + ' class]')
TypeError: cannot concatenate 'str' and 'NoneType' objects
```

이를 우회하기 위해선 두 가지 방법을 사용하여 원하는 명령을 실행할 수 있습니다.

```
/// 1. 출력할 객체의 메모리 주소를 얻어 출력하기
(lldb) po self.view
▿ Optional<UIView>
  - some : <UIView: 0x7f9950502a90; frame = (0 0; 414 736); autoresize = W+H; layer = <CALayer: 0x600003ffc560>>
(lldb) pclass 0x7f9950502a90
UIView
   | UIResponder
   |    | NSObject

/// 2. Objective-C 변수를 선언하여 출력하기
(lldb) expr -l objc -- UIView *$view = (UIView *)0x7f9950502a90
(lldb) pclass $view
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


### **fv** - 현재 표시되는 화면에서 정규식을 사용하여 특정 UIView 클래스를 찾아 출력하는 명령어

```
(lldb) fv UIButton
0x7f811cf064d0 UIButton
0x7f811cc16460 UIButtonLabel
```

### **fvc** - pvc와 비슷하지만 정규식을 사용하여 특정 UIViewController 클래스를 찾아 출력하는 명령어

```
(lldb) fvc BaseViewController
0x7f9329c09d50 SampleProject.BaseViewController
```

### **visualize** - UIImage, CGImageRef, UIView, CALayer를 이미지로 만들어 Preview로 열어 보여주는 명령어, **Swift 지원**

```
(lldb) visualize self.view

(lldb) visualize 0x7f8527501000
```

### **show/hide** - 특정 UIView나 CALayer를 숨기거나 보여주는 명렁어

```
(lldb) pviews
<UIWindow: 0x7f80f2e0f480; frame = (0 0; 414 736); gestureRecognizers = <NSArray: 0x6000011ecab0>; layer = <UIWindowLayer: 0x600001ffc660>>
   | <UIView: 0x7f80f2d0f1d0; frame = (0 0; 414 736); autoresize = W+H; layer = <CALayer: 0x600001f8b760>>
   |    | <UIButton: 0x7f80f2d0d540; frame = (164 318; 46 30); opaque = NO; autoresize = RM+BM; layer = <CALayer: 0x600001f8b700>>
   |    |    | <UIButtonLabel: 0x7f80f2c01f20; frame = (0.333333 6; 45.6667 18); text = 'Button'; opaque = NO; userInteractionEnabled = NO; layer = <_UILabelLayer: 0x600003ca6620>>

(lldb) hide 0x7f80f2c01f20
(lldb) show 0x7f80f2c01f20
```

### **present/dismiss** - 특정 UIViewController를 present하거나 dismiss 하는 명령어

```
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

### **mask/unmask** - 투명한 사각형을 View 또는 Layer 위에 노출시키거나 끄는 명령어

```
(lldb) fv UILabel
0x7fdfeee04200 UILabel
(lldb) mask 0x7fdfeee04200 --color red
(lldb) unmask 0x7fdfeee04200
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
(lldb) ptv 0x7fada085dc00
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
|   |   UIImageView:0x7fada061f1c0
|   |   UIImageView:0x7fada061ef90

(lldb) paltrace 0x7fada085d600

UITableViewCell:0x7fada085d600
|   UITableViewCellContentView:0x7fada0617ab0
|   _UITableViewCellSeparatorView:0x7fada0617ca0
|   _UITableViewCellSeparatorView:0x7fada0505a60
```

### **alamborder/alamunborder** - Ambiguous Layouts View들만 border를 설정하거나 끄는 명령어

Constraint를 잘못 적용하여 오토레이아웃 에러가 발생하는 경우, 어디서 잡아야할지 디버깅이 힘든 경우가 많습니다. 이때 `paltrace` 명령어를 실행하면 `AMBIGUOUS LAYOUT` 라는 표시를 볼 수 있습니다.

```
(lldb) paltrace

•UIWindow:0x7fd17b512990 - AMBIGUOUS LAYOUT
|   •UIView:0x7fd17b60d330
|   |   *<UILayoutGuide: 0x6000030607e0 - "UIViewSafeAreaLayoutGuide", layoutFrame = {{0, 20}, {414, 716}}, owningView = <UIView: 0x7fd17b60d330; frame = (0 0; 414 736); autoresize = W+H; layer = <CALayer: 0x600000953e40>>>
|   |   UIButton:0x7fd17b60b480'Button'
|   |   |   UIButtonLabel:0x7fd17b4040f0'Button'
|   |   *UILabel:0x7fd17b60d720'Label'- AMBIGUOUS LAYOUT for UILabel:0x7fd17b60d720'Label'.minY{id: 50}

Legend:
	* - is laid out with auto layout
	+ - is laid out manually, but is represented in the layout engine because translatesAutoresizingMaskIntoConstraints = YES
	• - layout engine host
```

명령어를 실행한 결과에서 UILabel에 오토레이아웃이 에러난 것을 알 수 있습니다. UILabel이 어디에 표시되어있는지 확인하기 위해 `alamborder` 를 사용하여 화면에서 확인할 수 있습니다.

```
(lldb) alamborder 0x7fd17b60d720 --color blue
2018-08-02 01:46:47.432789+0900 ChiselTest[38046:2921119] [LayoutConstraints] Window has a view with an ambiguous layout. See "Auto Layout Guide: Ambiguous Layouts" for help debugging. Displaying synopsis from invoking -[UIView _autolayoutTrace] to provide additional detail.

*UILabel:0x7fd17b60d720'Label'- AMBIGUOUS LAYOUT for UILabel:0x7fd17b60d720'Label'.minY{id: 50}

Legend:
	* - is laid out with auto layout
	+ - is laid out manually, but is represented in the layout engine because translatesAutoresizingMaskIntoConstraints = YES
	• - layout engine host
2018-08-02 01:46:48.669301+0900 ChiselTest[38046:2921119] [LayoutConstraints] View has an ambiguous layout. See "Auto Layout Guide: Ambiguous Layouts" for help debugging. Displaying synopsis from invoking -[UIView _autolayoutTrace] to provide additional detail.

*UILabel:0x7fd17b60d720'Label'- AMBIGUOUS LAYOUT for UILabel:0x7fd17b60d720'Label'.minY{id: 50}

Legend:
	* - is laid out with auto layout
	+ - is laid out manually, but is represented in the layout engine because translatesAutoresizingMaskIntoConstraints = YES
	• - layout engine host
```

`alamunborder` 명령어를 실행하여 설정되어 있던 border를 끌 수 있습니다.

### **caflush** - 즉각적으로 화면을 다시 그리도록 하는 명령어

```
(lldb) fv UILabel
0x7fd17b60d720 UILabel
(lldb) e [((UILabel*) 0x7fd17b60d720) setBackgroundColor:[UIColor blueColor]]
(lldb) caflush
```

### **pa11y** - 접근성이 설정되어 있는 모든 View를 출력하는 명령어

```
(lldb) pa11y
UIWindow (id)[[UIApplication sharedApplication] keyWindow]
   | (UILabel 0x00007fd17b60d720) Label
   | (UIButton 0x00007fd17b60b480) Button
```

## 참고자료

* https://kapeli.com/cheat_sheets/LLDB_Chisel_Commands.docset/Contents/Resources/Documents/index
* http://ios.137422.xyz/83589/
* https://www.slideshare.net/YiyingTseng/debug-lldb-86558535
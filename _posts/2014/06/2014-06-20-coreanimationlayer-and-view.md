---
layout: post
title: "[CoreAnimation]Layer"
description: ""
category: "iOS"
tags: [ios, UIView, CALayer, layer, view]
---
{% include JB/setup %}

### 레이어와 뷰

iOS나 Mac OS 앱을 개발할 때 뷰를 많이 사용합니다. 뷰는 이미지, 비디오, 글자들을 보여주는 객체이며 터치, 제스쳐 등의 유저가 행하는 것을 잡아서 처리할 수 있습니다.
또한, 뷰는 각각의 뷰를 subview로 관리까지 합니다.

UIView에서 렌더링, 레이아웃, 애니메이션 등을 관리하는 코어 애니메이션 클래스인 CALayer가 있습니다. UIView와는 유사한 개념이긴 하지만 화면에 대한 특성만 가지고 있습니다.

모든 UIView는 CALayer 객체인 layer 프로퍼티를 가지고 있습니다. layer는 뒷단 레이어로 알려져있고, view hierarchy의 개념과 매우 유사하게 layer에도 layer tree라는 구조가 있습니다.

CALayer를 사용하는 이유는 shadow, rounded corner, colored border나 3D transform, masking contents, animation을 할 수 있는 기능들을 제공해줍니다.

CALayer를 사용할 때 QuartzCore.framework를 추가해주어야 합니다.

CALayer의 배경색을 파란색으로 만들어 view의 layer에 sublayer형태로 추가하고자 합니다.

CALayer backgroundColor 속성은 CGColorRef 타입이며, Core Graphic 메소드를 사용하여 CGColor를 만들어 적용시킵니다.

<pre><code class="objectivec">
#import "MOViewController.h"

@import QuartzCore;

@interface MOViewController ()

@end

@implementation MOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 1.CALayer 생성
    CALayer *blueLayer = [CALayer layer];
    // 2.CALayer Frame 설정
    blueLayer.frame = CGRectMake(50.0f, 50.0f, 100.0f, 100.0f);
    // 3.CALayer 배경색 설정
    blueLayer.backgroundColor = [UIColor blueColor].CGColor;

    blueLayer.cornerRadius = 10.0f;

    // 4.view layer에 CALayer를 추가
    [self.myView.layer addSublayer:blueLayer];
}
</code></pre><br/>

UIView에 파란색 CALayer를 추가한 화면입니다.

<img src="/../../../../image/2014/06/calayer1.png" alt="CAImage1" style="width: 300px;"/><br/>


### 레이어 이미지

CALayer는 contents 프로퍼티 속성이 있으며 이 속성에 CGImage나 NSImage를 할당하여 이미지를 보이도록 할 수 있습니다.

UIImage 객체를 생성하여 CGImage 프로퍼티로 bridge 캐스팅을 통하여 뷰의 레이어에 할당할 있습니다.

<pre><code class="objectivec">
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    UIImage *image = [UIImage imageNamed:@"younha"];

    self.myView.layer.contents = (__bridge id)image.CGImage;
}
</code></pre><br />

UIViewController에 UIView를 추가하고 거기에 이미지를 추가한 화면입니다.

<img src="/../../../../image/2014/06/calayer2.png" alt="CAImage2" style="width: 300px;"/><br/>

<br/>뷰의 contentMode 속성을 통해서 이미지의 크기나 위치가 변경됩니다. CALayer에서도 비슷한 효과를 줄 수 있는 contentsGravity가 있습니다.

<pre><code class="objectivec">
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    UIImage *image = [UIImage imageNamed:@"younha"];

    self.myView.layer.contents = (__bridge id)image.CGImage;
    self.myView.layer.contentsGravity = kCAGravityCenter;
    self.myView.layer.contentsScale = [[UIScreen mainScreen] scale];

}
</code></pre><br />

화면 비율에 따라 이미지를 커지도록 하였습니다.

<img src="/../../../../image/2014/06/calayer3.png" alt="CAImage3" style="width: 300px;"/><br/>

<br/>하지만 우리가 원하는 뷰의 크기를 벗어나도록 하고자 원하지 않을 경우에는 뷰에서 벗어나면 보이지 않도록 해야합니다. UIView는 clipsToBounds라는 속성을 사용하며, CALayer에서는 masksToBounds라는 속성을 사용합니다. 이 값을 true로 변경하면 위에 이미지에서 외각부분이 보이지 않습니다.

<pre><code class="objectivec">
self.myView.layer.masksToBounds = false;
</code></pre><br/>

<img src="/../../../../image/2014/06/calayer4.png" alt="CAImage4" style="width: 300px;"/><br/>










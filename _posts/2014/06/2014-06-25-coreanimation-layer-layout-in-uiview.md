---
layout: post
title: "[CoreAnimation]CALayer의 AnchorPoint, zPosition"
description: ""
category: "Mac/iOS"
tags: [ios, uiview, calayer, layer, view, anchorpoint, zposition, transform]
---
{% include JB/setup %}

### AnchorPoint

UIView에서 frame, bounds, center 속성은 CALayer에서도 동일하게 frame, bounds, position 속성으로 가지고 있습니다.

frame은 외부에서 바라보는 좌표를 나타내고 bounds는 내부에서 바라보는 좌표를 나타냅니다. 그리고 position 속성은 `anchorPoint`에 상대적인 위치로 가지고 있습니다.

anchorPoint는 기본값으로 CALayer에 상대값으로 가지고 있기 때문에 (0.5, 0.5)를 가집니다.

<img src="/../../../../image/2014/06/anchorPoint.png" alt="anchorPoint" style="width: 800px;"/><br/>

iOS는 왼쪽 상단부터 (0,0)으로 시작하여 오른쪽 하단(1,1)이 됩니다.

만약 CALayer에 anchorPoint를 (0,1)로 한다면 Layer는 오른쪽 상단으로 이동하게 됩니다.

     - (void)viewDidLoad
    {
        [super viewDidLoad];
        // Do any additional setup after loading the view, typically from a nib.

        NSLog(@"Layer Frame : %@", NSStringFromCGRect(self.myView.layer.frame));
        NSLog(@"Layer Bounds : %@", NSStringFromCGRect(self.myView.layer.bounds));
        NSLog(@"Layer Center : %@", NSStringFromCGPoint(self.myView.layer.position));

        self.myView.layer.anchorPoint = CGPointMake(0,1);
        NSLog(@"--------------------------------------");

        NSLog(@"Layer Frame : %@", NSStringFromCGRect(self.myView.layer.frame));
        NSLog(@"Layer Bounds : %@", NSStringFromCGRect(self.myView.layer.bounds));
        NSLog(@"Layer Center : %@", NSStringFromCGPoint(self.myView.layer.position));
    }

AnchorPoint 수정 전
- View Frame : \{\{110, 234\}, \{100, 100\}\}
- View Bounds : \{\{0, 0\}, \{100, 100\}\}
- View Center : \{160, 284\}
- Layer Frame : \{\{110, 234\}, \{100, 100\}\}
- Layer Bounds : \{\{0, 0\}, \{100, 100\}\}
- Layer Position : \{160, 284\}

AnchorPoint 수정 후
- View Frame : \{\{60, 184\}, \{100, 100\}\}
- View Bounds : \{\{0, 0\}, \{100, 100\}\}
- View Center : \{160, 284\}
- Layer Frame : \{\{60, 184\}, \{100, 100\}\}
- Layer Bounds : \{\{0, 0\}, \{100, 100\}\}
- Layer Position : \{160, 284\}

Layer와 View의 Frame이 이동하였지만 Bounds, Center값은 변하지 않았습니다. UIView를 회전을 하게 되면 Center를 기준으로 이동하게 됩니다.

<pre><code class="objectivec">[self.myView setTransform:CGAffineTransformMakeRotation(M_PI * 2.0 * 1/8)];
</code></pre><br/>

다음은 1/8씩 회전한 결과입니다.

<img src="/../../../../image/2014/06/rotation.gif" alt="rotation" style="width: 300px;"/><br/>


### zPosition

CALayer에서는 zPosition을 이용하여 화면 앞으로 표시할 수 있습니다.

우선 다음과 같이 화면을 구성합니다.

<img src="/../../../../image/2014/06/zPosition1.png" alt="zPosition1" style="width: 500px;"/><br/>

빨간 뷰의 레이어의 zPosition을 수정하여 빨간 뷰를 앞으로 표시하도록 합니다.

<pre><code class="objectivec">- (void)viewDidLoad
{
    [super viewDidLoad];
    self.redView.layer.zPosition = 1.0f;
}
</code></pre><br/>

다음은 위의 코드 결과입니다. 빨간 뷰가 앞으로 온 것을 확인할 수 있습니다.

<img src="/../../../../image/2014/06/zPosition2.png" alt="zPosition2" style="width: 500px;"/><br/>
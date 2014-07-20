---
layout: post
title: "[CoreAnimation]Implicit Animations"
description: ""
category: "Mac/iOS"
tags: [ios, transaction, CALayer, layer]
---
{% include JB/setup %}


### Transaction

Transaction은 CATransation Class에서 사용합니다. 직접적으로 CATransaction에 접근하지 못하지만 클래스 메소드인 begin, commit 등을 사용하여 이용할 수 있습니다.

새로운 Transaction을 만들어 동작하도록 해봅시다.

<pre><code class="objectivec">- (IBAction)changeColor:(id)sender
{
    [CATransaction begin];	// begin a new transaction

    [CATransaction setAnimationDuration:1.0f];	// set animation duration

    // a task code for animation
    CGFloat red = arc4random() / (CGFloat)INT_MAX;
    CGFloat greed = arc4random() / (CGFloat)INT_MAX;
    CGFloat blue = arc4random() / (CGFloat)INT_MAX;

    self.colorLayer.backgroundColor = [UIColor colorWithRed:red
                                                      green:greed
                                                       blue:blue
                                                      alpha:1.0].CGColor;

    [CATransaction commit];	// commit the transaction
}
</code></pre><br/>

+begin 클래스 메소드를 호출하여 CATransaction을 사용한다고 선언합니다.
+setAnimationDuration 클래스 메소드를 통해 애니메이션 동작 시간을 설정합니다. 기본적으로 0.25초로 설정되어 있습니다.

애니메이션 동작할 코드를 작성하고 +commit 클래스 메소드를 통하여 위에서 작성된 명령을 동작할 transaction을 끝맺습니다.

만약 애니메이션이 끝난 후에 동작할 행동을 설정하고자 한다면 +setCompletionBlock 클래스 메소드에 block 코드를 넣을 수 있습니다.

<pre><code class="objectivec">[CATransaction setCompletionBlock:^{
    NSLog(@"Transaction is Completion");
}];
</code></pre><br/>

또한, CATransaction을 중지하고자 한다면 +setDisableActions 클래스 메소드를 +begin 클래스 메소드 뒤에 작성하여 애니메이션을 멈추도록 합니다.


### Layer Action

CATransaction으로 애니메이션을 줄 수 있지만 CAAction 프로토콜을 이용하여 layer action을 사용할 수 있습니다.

우선 아래 코드를 살펴봅시다.

<pre><code class="objectivec">- (void)viewDidLoad {
    [super viewDidLoad];

    self.colorLayer = [CALayer layer];
    self.colorLayer.frame = CGRectMake(60.0f, 60.0f, 200.0f, 200.0f);
    self.colorLayer.backgroundColor = [UIColor blueColor].CGColor;

    // set transition
    CATransition *transition = [CATransition animation];
    [transition setType:kCATransitionPush];
    [transition setSubtype:kCATransitionFromTop];
    self.colorLayer.actions = @{@"backgroundColor":transition};

    [self.view.layer addSublayer:self.colorLayer];
}

- (IBAction)changeColor:(id)sender
{
    // a task code for animation
    CGFloat red = arc4random() / (CGFloat)INT_MAX;
    CGFloat greed = arc4random() / (CGFloat)INT_MAX;
    CGFloat blue = arc4random() / (CGFloat)INT_MAX;

    self.colorLayer.backgroundColor = [UIColor colorWithRed:red
                                                      green:greed
                                                       blue:blue
                                                      alpha:1.0].CGColor;
}
</code></pre><br/>

colorLayer에 actions로 값을 설정하면 해당 키에 대해서 변경사항이 생길 경우 생성한 transition으로 애니메이션이 동작합니다.

따로 애니메이션을 지정하지 않고도 변경이 가능하다는 점이 장점이며, 단점으로는 지정된 것만 가능하다는 단점이 있습니다.


### Presentation Layer

CALayer에서는 CATransaction이 일어날 때 어떤 값이 변할지 알아야 합니다. CALayer는 `presentationLayer`와 `modelLayer` 메소드를 지원합니다. presentaionLayer는 현재 화면에서 보여지는 Layer를 말하며 modelLayer는 CATransaction이 일어난 후 최종적인 layer 정보를 가집니다.

따라서 presentaionLayer의 값은 화면에서 이동할때마다 변경이 일어나는 것을 확인할 수 있으며 modelLayer는 최종 layer 정보를 확인할 수 있습니다. CATransaction이 끝나면 presentaionLayer와 modelLayer 값이 같은 것을 알 수 있습니다.

다음은 화면에서 터치를 하였을 때 layer가 이동하거나 색이 변경할 수 있도록 작성된 코드입니다.

여기에서는 presentationLayer를 터치했는지 처리하는 로직이 추가되어 있습니다.

또한, NSTimer를 통해 매 0.1초마다 presentationLayer과 modelLayer값을 확인할 수 있습니다.

<pre><code class="objectivec">- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.colorLayer = [CALayer layer];
    self.colorLayer.frame = CGRectMake(60.0f, 60.0f, 200.0f, 200.0f);
    self.colorLayer.backgroundColor = [UIColor blueColor].CGColor;

    [self.view.layer addSublayer:self.colorLayer];

    NSTimer *collisionTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(collisionCheck) userInfo:nil repeats:YES];
}

- (void)collisionCheck
{
    CALayer *presentLayer =  self.colorLayer.presentationLayer;
    CALayer *modelLayer = self.colorLayer.modelLayer;
    NSLog(@"PresentationLayer = %@, ModelLayer = %@",
          NSStringFromCGRect(presentLayer.frame),
          NSStringFromCGRect(modelLayer.frame));
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject]locationInView:self.view];

    // checking layer touch and change layer backgroundColor
    if ([self.colorLayer.presentationLayer hitTest:point]) {
        CGFloat red = arc4random() / (CGFloat)INT_MAX;
        CGFloat greed = arc4random() / (CGFloat)INT_MAX;
        CGFloat blue = arc4random() / (CGFloat)INT_MAX;

        self.colorLayer.backgroundColor = [UIColor colorWithRed:red
                                                          green:greed
                                                           blue:blue
                                                          alpha:1.0].CGColor;

    }
    // moving the layer with touch point
    else {
        [CATransaction begin];
        [CATransaction setAnimationDuration:1.0];
        self.colorLayer.position = point;
        [CATransaction commit];
    }
}
</code></pre><br/>

다음은 실행 화면입니다.

<img src="/../../../../image/2014/07/transaction_0708.gif" alt="transaction_0708" style="width: 300px;"/><br/>
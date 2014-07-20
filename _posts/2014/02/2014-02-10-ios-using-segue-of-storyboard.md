---
layout: post
title: "[iOS]iOS 프로젝트에서 Storyboard의 Segue를 이용하여 화면 전환하기"
description: ""
category: "Mac/iOS"
tags: [ios, xcode, storyboard, segue]
---
{% include JB/setup %}

## iOS 프로젝트에서 Storyboard의 Segue를 이용하여 화면 전환하기

가존에 xib 파일을 만들고 View Controller를 붙이고 하는 방법에서 Storyboard 기능이 생겨나면서 Storyboard는 각각의 View들을 관리합니다. 또한 화면 이동에 대해서도 기존에는 전환할 화면의 nib을 불러와야 가능했지만 Segue를 이용하면 view의 이름까지도 알 필요는 없습니다.

### Segue 연결하기

RootView Controller에 Button을 추가합니다.

![viewcontroller_button](/../../../../image/2014/viewcontroller_button.png)<br/>

Segue 연결시키는 방법은 두가지 있습니다. 하나는 View Controller에 Segue를 연결시켜 코드상에서 Segue를 호출하여 목적지 View Controller를 호출하는 방법과 Button등 Action을 가지는 UIObject에 대해 직접 연결하는 방법이 있습니다. 이는 스토리보드에서만 처리하므로 코드에서 호출할 필요가 없습니다.

#### View Controller에 Segue연결하기

목적지 View Controller의 Connection Inspector에서 Segue 표시할 방법을 선택하여 호출하는 View Controller에 연결합니다.

![viewController_segue_connection](/../../../../image/2014/viewController_segue_connection.png)<br/>

Segue를 선택하여 Identifier 값을 설정합니다.

![viewcontroller_segue_identifier](/../../../../image/2014/viewcontroller_segue_identifier.png)<br/>

#### Button에 Segue 연결하기

UIButton을 클릭하고 Connection Inspector에 Triggered Segues에 Action을 선택하고 목적지 View Controller를 선택합니다. 

![viewcontroller_button_segue](/../../../../image/2014/viewcontroller_button_segue.png)<br/>

그리고 어떻게 표시할지를 선택합니다. 

![viewcontroller_button_segue_present](/../../../../image/2014/viewcontroller_button_segue_present.png)<br/>

### Segue 호출하기

#### 코드로 Segue 호출하기

Button을 하나 더 만들어 View Controller에 pressButton2 메소드를 만들어 터치하였을 때 Segue를 호출하도록 합니다.

	-(IBAction)pressButton2:(id)sender
	{
        [self performSegueWithIdentifier:@"SecondViewSegue" sender:self];
	}

또한, ViewController를 초기화하거나 그전에 해야할 것들이 있는 경우에는 prepareForSegue를 통해 미리 초기화를 합니다.

	-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
	{
		if([segue.identifier isEqualToString:@"SecondViewSegue"]) {
        UIViewController *controller = (UIViewController *)segue.destinationViewController;
        controller.delegate = self;
	}

#### Button으로 Segue 호출하기

위에서 Button에 Segue에 연결하였기 때문에 실행하여 버튼을 클릭하면 바로 목적지 View Controller가 나타납니다.

![viewcontroller_button_segue_using](/../../../../image/2014/viewcontroller_button_segue_using.png)<br/>

### Custom Segue 만들기

UIStoryboardSegue를 상속받는 새로운 Segue 클래스를 생성합니다.

![viewcontroller_customSegue](/../../../../image/2014/viewcontroller_customSegue.png)<br/>

연결되어 있는 Segue의 Style을 Custom으로 변경합니다.

![viewcontroller_customSegue_style](/../../../../image/2014/viewcontroller_customSegue_style.png)<br/>

Segue 클래스에서는 perform 메소드를 사용하여 Segue를 처리합니다.

	-(void)perform
	{
	    UIViewController *source = (UIViewController *)self.sourceViewController; 
	    UIViewController *destination = (UIViewController *)self.destinationViewController;
	    [UIView transitionFromView:source.view
	                        toView:destination.view
	                      duration:1.0 
	                       options:UIViewAnimationOptionTransitionFlipFromLeft
	                    completion:nil];
	}
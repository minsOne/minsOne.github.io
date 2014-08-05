---
layout: post
title: "NSLayoutConstraint"
description: ""
category: "mac/ios"
tags: [autolayout, xcode, interface builder, storyboard, view, constraint, NSLayoutConstraint, constraintWithItem, constraintsWithVisualFormat]
---
{% include JB/setup %}

## Auto Layout

인터페이스 빌더에서 Auto Layout을 통하여 다중 화면 크기에 대응할 수 있도록 쉽게 화면을 설계 할 수 있습니다. 

런타임시 뷰를 추가하거나 삭제하기 위해 Auto Layout을 코드로 제약 조건을 생성, 추가, 삭제 및 적용할 수 있습니다.

그러기 위해서 View의 translatesAutoresizingMaskIntoConstraints 속성 값을 NO로 설정하여 Auto Layout을 하도록 합니다.

	view.translatesAutoresizingMaskIntoConstraints = NO;

### item으로 제약조건 만들기 

제약조건(Constraint)는 사용하면 느리고 많은 코드를 작성해야 하지만 제약조건을 추가하여 원하는 레이아웃을 얻을 수 있습니다. 다음은 제약조건을 만드는 메소드입니다.

	[NSLayoutConstraint constraintWithItem:(id)view1
				  attribute:(NSLayoutAttribute)attr1
				  relatedBy:(NSLayoutRelation)relation
				  toItem:(id)view2
				  attribute:(NSLayoutAttribute)attr2
				  multiplier:(CGFloat)multiplier
				  constant:(CGFloat)constant];


위 형태에서 제약조건 :

view1.attr1 = view2.attr2 * multiplier + constant<br/><br/>

다음은 constraintWithItem 메소드 인자 설명입니다:

| parameter | Description |
| :------------- | :----------- |
| view1  | 제약조건의 왼쪽 뷰. |
| attr1  | 제약조건의 왼쪽 뷰 속성. |
| relation  | 제약조건의 왼쪽과 오른쪽 뷰 간의 관계. |
| view2  | 제약조건의 오른쪽 뷰.|
| attr2  | 제약조건의 오른쪽 뷰 속성. |
| multiplier  |  attr1 값이 attr2 값에 얻은 값으로 곱하도록 하는 값 |
| constant  | attr1 값이 attr2 값(곱해진 후의 값)에 추가하는 값 |


### NSLayoutAttribute, NSLayoutRelation

	typedef NS_ENUM(NSInteger, NSLayoutRelation) {
	    NSLayoutRelationLessThanOrEqual = -1,
	    NSLayoutRelationEqual = 0,
	    NSLayoutRelationGreaterThanOrEqual = 1,
	};

	typedef NS_ENUM(NSInteger, NSLayoutAttribute) {
	    NSLayoutAttributeLeft = 1,
	    NSLayoutAttributeRight,
	    NSLayoutAttributeTop,
	    NSLayoutAttributeBottom,
	    NSLayoutAttributeLeading,
	    NSLayoutAttributeTrailing,
	    NSLayoutAttributeWidth,
	    NSLayoutAttributeHeight,
	    NSLayoutAttributeCenterX,
	    NSLayoutAttributeCenterY,
	    NSLayoutAttributeBaseline,
	    
	    NSLayoutAttributeNotAnAttribute = 0
	};

### constraintWithItem을 이용한 예제

다음은 Auto Layout을 적용하여 화면 크기에 상관없이 중앙에 사각형 뷰가 나타나는 코드입니다.

	UIView *secondView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    secondView.translatesAutoresizingMaskIntoConstraints = NO;
    [secondView setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:secondView];
    
    // 가로길이 50으로 고정
    NSLayoutConstraint *firstViewConstraintWidth = [NSLayoutConstraint constraintWithItem:secondView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:50];

    // 세로길이 50으로 고정
    NSLayoutConstraint *firstViewConstraintHeight = [NSLayoutConstraint constraintWithItem:secondView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:50];

    // secondView를 self.view 기준으로 x 값 중앙에 위치하도록 함.
    NSLayoutConstraint *firstViewConstraintCenterX = [NSLayoutConstraint constraintWithItem:secondView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0];

    // secondView를 self.view 기준으로 y 값 중앙에 위치하도록 함.
    NSLayoutConstraint *firstViewConstraintCenterY = [NSLayoutConstraint constraintWithItem:secondView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0];

    // 크기 제약조건은 secondView에 추가
    [secondView addConstraints:[NSArray arrayWithObjects:firstViewConstraintHeight, firstViewConstraintWidth, nil]];
    // 화면 레이아웃의 제약조건은 self.view에 추가
    [self.view addConstraints:[NSArray arrayWithObjects:firstViewConstraintCenterX, firstViewConstraintCenterY, nil]];


다음은 위 코드를 적용한 후 화면입니다.

* 세로 이미지
<!-- 세로 이미지 -->
<img src="/../../../../image/2014/08/autolayout-portrait.png" alt="autolayout-portrait" style="width: 200px;"/><br/>
* 가로 이미지
<!-- 가로 이미지 -->
<img src="/../../../../image/2014/08/autolayout-landscape.png" alt="autolayout-landscape" style="height: 200px;"/><br/><br/>

이번에는 화면 크기에 대응하여 뷰의 크기가 바뀌는 코드입니다.

	// 세로길이 50으로 고정
	NSLayoutConstraint *firstViewConstraintHeight = [NSLayoutConstraint constraintWithItem:secondView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:50];

	// secondView를 self.view 기준으로 y 값 중앙에 위치하도록 함.
    NSLayoutConstraint *firstViewConstraintCenterY = [NSLayoutConstraint constraintWithItem:secondView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0];

    // secondView를 self.view와 왼쪽에 거리를 30으로 지정함.
    NSLayoutConstraint *firstViewConstraintLeadingSpace = [NSLayoutConstraint constraintWithItem:secondView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.f constant:30];

    // self.view를 secondView와 오른쪽에 거리를 30으로 지정함.
    NSLayoutConstraint *firstViewConstraintTrailingSpace = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:secondView attribute:NSLayoutAttributeTrailing multiplier:1.f constant:30];
    
    [secondView addConstraints:[NSArray arrayWithObjects:firstViewConstraintHeight, nil]];
    [self.view addConstraints:[NSArray arrayWithObjects:firstViewConstraintCenterY, firstViewConstraintLeadingSpace, firstViewConstraintTrailingSpace, nil]];


다음은 위 코드를 적용한 후 화면입니다.

* 세로 이미지
<!-- 세로 이미지 -->
<img src="/../../../../image/2014/08/autolayout-response-portrait.png" alt="autolayout-response-portrait" style="width: 200px;"/><br/>
* 가로 이미지
<!-- 가로 이미지 -->
<img src="/../../../../image/2014/08/autolayout-response-landscape.png" alt="autolayout-response-landscape" style="height: 200px;"/><br/><br/>


### 시각적 형식 언어(Visual Format Language)

제약조건을 만드는 또 한가지의 방법은 [constraintsWithVisualFormat:options:metrics:views:][1]을 사용합니다. 

**시각적 형식 문자열**(visual format string)은 설명하고자 하는 레이아웃의 시각적인 표현을 제공합니다. **시각적 형식 언어**(visual format language)는 읽을 수 있도록 설계되어 있으며 뷰는 대괄호로 표시되고 뷰간의 연결은 하이픈(또는 뷰들을 떨어뜨리는 숫자에 의해 두개의 분리된 하이픈)을 사용합니다. 더 많은 예제와 시각적 형식 언어 문법을 배울 수 있는 “[Visual Format Language][2]”을 참고하시면 됩니다.

	[NSLayoutConstraint constraintsWithVisualFormat:(NSString *)format
							options:(NSLayoutFormatOptions)options
							metrics:(NSDictionary *)metrics
							  views:(NSDictionary *)views];

다음은 constraintsWithVisualFormat 메소드 인자 설명입니다:

| parameter | Description |
| :------------- | :----------- |
| format  | 제약조건을 시각적 형식으로 나타낸 문자열. |
| options  | 시각적 형식 문자열에 모든 객체들의 속성과 레아아웃의 방향을 설명. |
| metrics  | 시각적 형식 문자열에 나타난 상수의 집합이며, 키는 문자열, 값은 NSNumber 객체. |
| views  | 시각적 형식 문자열에 나타난 뷰의 집합이며 키는 문자열, 값은 뷰의 객체. |


### 시각적 형식 문법

다음은 애플에서 제공하는 제약조건의 시각적 형식 예제입니다.

| 시각적 형식 | 문법 | 설명 |
| :------------- | :------------- | :----------- |
| Standard Space | [button]-[textField] | button과 textField의 사이는 표준 간격 차이, 표준 간격은 8. |
| Fixed Space | H:\|-50-[purpleBox]-50-\| | purpleBox이 superview를 기준으로 왼쪽 50, 오른쪽 50 간격.(Leading, Trailing) |
| Fixed Space | V:\|-75-[label]\| | label이 superview를 기준으로 위에서 75, 아래와 붙어 있도록 함. |
| Fixed Width  | H:[button(50)] | button의 가로는 50으로 고정. |
| Fixed Height  | V:[button(50)] | button의 세로는 50으로 고정. |
| Width Constraint | H:[button(>=50)] | button의 크기는 50보다 크거나 같아야 함. |
| Vertical Layout | V:[topField]-10-[bottomField] | topField와 buttonField의 사이 간격은 10. |
| Flush Views | [maroonView][blueView] | maroonView과 blueView 간격은 없음. |
| Priority | H:[button(100@20)] | button의 가로는 100으로, 우선순위의 값을 20으로 설정 |
| Equal Widths | H:[button1(==button2)] | button1과 button2의 가로 길이는 동일하게 설정 |
| Multiple Predicates | H:[flexibleButton(>=70,<=100)] | flexibleButton의 가로 길이가 70보다 크거나 같고 100보다 작거나 같게 설정 |
| A Complete Line of Layout | \|-[find]-[findNext]-[findField(>=20)]-\| | find, findNext, findField와 superview의 사이는 표준간격이며, findField 크기는 20보다 크거나 같음. |


### constraintsWithVisualFormat를 이용한 예제

다음은 Auto Layout을 적용하여 화면 크기에 상관없이 중앙에 사각형 뷰가 나타나는 코드입니다.

	UIView *superview = self.view;
    UIView *secondView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    secondView.translatesAutoresizingMaskIntoConstraints = NO;
    [secondView setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:secondView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(secondView, superview);
    
    [superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[superview]-(<=0)-[secondView(200)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    [superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[superview]-(<=0)-[secondView(200)]"  options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];


다음은 위 코드를 적용한 후 화면입니다.

* 세로 이미지
<!-- 세로 이미지 -->
<img src="/../../../../image/2014/08/autolayout-portrait-VFS.png" alt="autolayout-portrait-VFS" style="width: 200px;"/><br/>
* 가로 이미지
<!-- 가로 이미지 -->
<img src="/../../../../image/2014/08/autolayout-landscape-VFS.png" alt="autolayout-landscape-VFS" style="height: 200px;"/><br/><br/>

### 화면 레아아웃 디버깅

모든 뷰의 계층(hierarchy)를 요약해서 보여주는 디버깅 명령어.

	(lldb) po [[UIWindow keyWindow] recursiveDescription]

화면에 작성한 제약조건(constraint)가 나타나지 않는다면 다음 디버깅 명령어를 통해 AMBIGUOUS LAYOUT를 확인.

	(lldb) po [[UIWindow keyWindow] _autolayoutTrace]


### 정리

Xcode6 환경에서 Auto Layout을 사용하여 개발하도록 애플에서 많이 밀어주는 것이 많이 보입니다. 

Auto Layout은 항상 생각해야 할 사항은 화면 객체의 크기와 x, y좌표에 대한 제약조건이 반드시 있어야 한다는 사항을 기억해야 합니다.

Auto Layout을 코드로 작성할 때 constraintsWithVisualFormat과 constraintWithItem을 사용하는데 둘 다 장단점이 있습니다.

constraintsWithVisualFormat는 다중 뷰에 대한 Auto Layout을 적용하기 쉽고 문법도 시각적으로 잘 보이지만, 개인적으로는 다중 뷰를 배치할때에 쓰는 것이 좋다고 보여집니다.
constraintWithItem는 제약조건을 하나씩 만든다는 단점이 있지만 스토리보드에서 먼저 작성을 하고 난 뒤 제약조건의 값을 가지고 하나하나 작성할 수 있다는 장점이 있습니다.



[1]: https://developer.apple.com/library/ios/documentation/AppKit/Reference/NSLayoutConstraint_Class/NSLayoutConstraint/NSLayoutConstraint.html#//apple_ref/occ/clm/NSLayoutConstraint/constraintsWithVisualFormat:options:metrics:views:
[2]: https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/VisualFormatLanguage/VisualFormatLanguage.html#//apple_ref/doc/uid/TP40010853-CH3-SW1
---
layout: post
title: "[Swift]오토레이아웃을 위한 새로운 클래스 NSLayoutAnchor"
description: ""
category: "Mac/iOS"
tags: [swift, autolayout, NSLayoutConstraint, NSLayoutAnchor]
---
{% include JB/setup %}

AutoLayout을 사용하기 위해 NSLayoutConstraint 클래스를 사용하여 Constrait를 만들었습니다. 하지만 사용법도 어렵고 잘 이해되지 않아 항상 골치를 썩이던 녀석이었습니다.

이번 WWDC에서 `NSLayoutAnchor`라는 클래스를 보여주었습니다. 좀 더 간결하고 명확하게 사용할 수 있을 것 같습니다. 

다음은 NSLayoutConstraint와 NSLayoutAnchor의 차이를 보여주는 코드입니다.

	// Creating constraints using NSLayoutConstraint
	NSLayoutConstraint(item: subview,
	    attribute: .Leading,
	    relatedBy: .Equal,
	    toItem: view,
	    attribute: .LeadingMargin,
	    multiplier: 1.0,
	    constant: 0.0).active = true
	 
	NSLayoutConstraint(item: subview,
	    attribute: .Trailing,
	    relatedBy: .Equal,
	    toItem: view,
	    attribute: .TrailingMargin,
	    multiplier: 1.0,
	    constant: 0.0).active = true
	 
	 
	// Creating the same constraints using Layout Anchors
	let margins = view.layoutMarginsGuide
	 
	subview.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor).active = true
	subview.trailingAnchor.constraintEqualToAnchor(margins.trailingAnchor).active = true

iOS9.0부터 사용가능하기 때문에, 하위버전에서 사용하지 못한다는 단점이 있으나 조만간 비슷한 형태를 취하는 라이브러리가 만들어지지 않을까 합니다.

### 참고자료

* [Apple Document][Apple Document]

<br/><br/>

[Apple Document]: https://developer.apple.com/library/prerelease/ios/documentation/AppKit/Reference/NSLayoutAnchor_ClassReference/index.html
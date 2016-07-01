---
layout: post
title: "[iOS]ScrollView의 Bounce를 아래에서만 동작하기"
description: ""
category: "Mac/iOS"
tags: [UIScrollView, bounces, contentOffset]
---
{% include JB/setup %}

얼마전에 개발을 하다 아래에만 바운스 기능이 동작하도록 요구사항을 전달받아서 간단하게 처리해보았습니다.

ScrollView의 contentOffset의 y값이 0보다 큰 경우에 bounces를 활성화시켜 아래에서만 바운스가 동작하도록 만들었습니다.

```swift
	func scrollViewDidScroll(scrollView: UIScrollView) {
		scrollView.bounces = scrollView.contentOffset.y > 0
	}
```
<br/>
---
layout: post
title: "iOS 상태바 표시에 대한 설명"
description: ""
category: "Mac/iOS"
tags: [ios, statusbar, viewWillAppear, viewWillDisappear]
---
{% include JB/setup %}

프로젝트 중에 상태바를 표시해야하거나 꺼야 하는 화면이 있습니다.

전체 화면에 상태바를 보이지 않게 하기 위해서는 ProjectName-Info.plist파일을 수정해야 합니다.

다음 항목을 추가합니다.

	<key>UIStatusBarHidden</key>
	<true/>
	<key>UIViewControllerBasedStatusBarAppearance</key>
	<false/>

만약에 특정 화면에서 상태바를 보여야 한다면 viewWillAppear, viewWillDisappear에서 상태바를 설정하면 됩니다.

	-(void)viewWillAppear:(BOOL)animated 
	{
	    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
	}

	-(void)viewWillDisappear:(BOOL)animated 
	{
	    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
	}

만약에 특정 화면에서 상태바를 숨기려고 한다면 반대로 동작하도록 하면 됩니다.
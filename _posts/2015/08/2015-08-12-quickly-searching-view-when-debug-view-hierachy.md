---
layout: post
title: "[Xcode]뷰 디버깅시 접근성 라벨로 뷰 객체를 빠르게 찾자"
description: ""
category: "Mac/iOS"
tags: [xcode, debug, view, hierarchy, accessibility label, tip]
---
{% include JB/setup %}

UIView, UIImageView 등 뷰를 만든 후, 화면 어디에 있는지 찾거나 제약조건이 맞는지, 이미지가 제대로 나오고 있는지 등을 확인할 때 Debug View Hierarchy를 사용합니다.

Xcode 6부터 지원하는 기능인데, 뷰의 계층 구조를 파악하는데 유용합니다. 

<img src="/../../../../image/flickr/19868661463_a3d8ff6b0d_z.jpg" width="300" height="400">

<br/>일반적으로 클래스 명만 보여주기 때문에 커스텀 클래스가 아닌 이상 객체들을 뒤적여야 하는 상황이 발생하기도 합니다.

따라서 뷰 객체를 검색하여 찾을 수 있도록 해당 뷰의 접근성 라벨을 추가합니다.

이는 접근성을 높일 뿐더라 Xcode 7의 새로운 기능인 UI Testing을 할 수 있도록 준비할 수 있습니다.

<img src="/../../../../image/flickr/20301679600_f31ca4c1a2_n.jpg" width="320" height="110">

<img src="/../../../../image/flickr/20496120511_8592b7febe_n.jpg" width="320" height="110">

<br/>위와 같이 접근성 라벨을 추가하면 다음과 같이 확인할 수 있습니다.

<img src="/../../../../image/flickr/19868965883_e3b16a09a0_n.jpg" width="320" height="137">

<br/>그리고 검색을 통해서도 빠르게 뷰 객체를 찾을 수 있습니다.

<img src="/../../../../image/flickr/20489943025_a206b2e1d8_n.jpg" width="320" height="120">

<img src="/../../../../image/flickr/20490153495_5db7279d46_n.jpg" width="320" height="49">
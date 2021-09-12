---
layout: post
title: "[iOS] 준 Clean Architecture With RIBs, ReactorKit 그리고 Tuist를 이용한 프로젝트 모듈화 설계(3) - UserInterface"
description: ""
category: "Mac/iOS"
tags: [Swift, Xcode, Clean Architecture, RIBs, ReactorKit, Tuist]
published: false
---
{% include JB/setup %}

## 들어가기 전

iOS 개발은 프론트 개발입니다. 즉, 화면을 만들고 이를 사용자에게 보여주는 것이 중요합니다. 따라서 화면을 빠르게 개발하여 확인할 수 있어야 합니다. 

모든 화면에서 공통으로 사용해야할 리소스, 리소스를 사용하면서 공통적인 화면을 만들 디자인 시스템, 리소스와 디자인 시스템을 이용하여 화면 개발, 그리고 개발한 화면을 가지고 데모앱을 만들어져야 합니다.

<p style="text-align:left;"><img src="{{ site.development_url }}/image/2021/09/20210911_01.png" style="width: 200px"/></p>

위의 의존성 그림을 토대로 자세한 것을 알아보겠습니다.

## Resources

리소스는 화면을 개발하는 데 필요한 자원이라고 생각하시면 됩니다. 예를 들어, 리소스는 이미지, 동영상, 음악, 음성, 텍스트 등이 있습니다. 

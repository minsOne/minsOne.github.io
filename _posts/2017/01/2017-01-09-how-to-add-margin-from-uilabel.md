---
layout: post
title: "[iOS][Trick]UILabel에 margin 주기 - UIButton을 이용하기"
description: ""
category: "Mac/iOS"
tags: [UIButton, UILabel]
---
{% include JB/setup %}

개발하다 보면 UILabel에 margin을 필요로 하는 상황이 생깁니다. 하지만 UILabel은 text에 따라 크기가 늘어나거나 줄어들고, margin을 줄 수 있는 방법이 없습니다. 그렇다고 상속 받기도 애매합니다. 

xib 또는 Storyboard에서 Autolayout을 사용해야 하므로, 크기를 임의로 정할 수 없습니다. 그러면 어떻게 해야할까요?

UIButton을 살펴봅시다. UIButton은 Content Insets 속성을 가지고 있으며, 이 속성으로 margin을 줄 수 있습니다.

<img src="https://c4.staticflickr.com/1/402/32187787355_484b95fc45.jpg" width="246" height="123" alt="">

그리고 UIButton은 터치 등 액션을 취할 수 있으므로, 다음과 같이 Accessibility에 User Interaction Enable을 끄고, Static Text를 활성화 합니다. 

<img src="https://c1.staticflickr.com/1/685/32150007736_f198b9e5b7.jpg" width="259" height="377" alt="">

그리고 UIButton의 User Interaction Enable를 끕니다.

<img src="https://c8.staticflickr.com/1/539/31377625103_414863c97b.jpg" width="258" height="131" alt="">

그러면 다음과 같이 UIButton은 margin이 추가된 UILabel과 같은 역할을 하게 됩니다.

<img src="https://c5.staticflickr.com/1/413/31346564084_7226e204bd_m.jpg" width="223" height="153" alt="">


---
layout: post
title: "[iOS]View의 Layer 속성 minificationFilter과 magnificationFilter 정리"
description: ""
category: "Mac/iOS"
tags: [view, layer, minificationFilter, magnificationFilter, nearest, linear]
---
{% include JB/setup %}

CGLayer의 property에는 `minificationFilter`, `magnificationFilter`가 있습니다. 

minificationFilter는 이미지 데이터의 크기를 줄일때 사용합니다.

magnificationFilter는 이미지 데이터의 크기를 늘릴때 사용합니다.

각 property의 기본 값은 `linear`로 설정되어 있습니다.

그러나 `nearest`로 설정을 하면 도트단위로 늘리거나 줄일 수 있습니다.

`[Object.layer setMagnificationFilter:kCAFilterNearest];` 같이 사용하여 `nearest` 값을 설정합니다.



#### 값에 따른 효과 비교

- 값이 linear인 경우
<img src="{{ site.production_url }}/image/2014/02/layer-filterRendering-linear.png" alt="linear" style="width: 200px;"/><br/>

- 값이 nearest인 경우
<img src="{{ site.production_url }}/image/2014/02/layer-filterRendering-nearest.png" alt="linear" style="width: 200px;"/>
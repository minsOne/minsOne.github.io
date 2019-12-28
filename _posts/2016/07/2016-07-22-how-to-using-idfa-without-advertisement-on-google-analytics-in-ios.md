---
layout: post
title: "[iOS]Google Analytics에서 광고 없이 IDFA를 사용하여 리뷰 통과하기"
description: ""
category: "Mac/iOS"
tags: [idfa, ga, ios, review, google analytics]
---
{% include JB/setup %}

GA를 사용하면서 특정 데이터(예를 들어, 인구 통계와 관심 분야)를 얻기 위해서는 IDFA를 사용해야 합니다.

사용하는 것은 문제가 되지 않으나 앱 리뷰할 때 다음 항목을 체크해야 합니다.

<img src="{{ site.production_url }}/image/flickr/8500/28454082835_c299292622.jpg" width="500" height="149" alt=""><br/>

만약 앱 내에서 광고를 사용한다면 `App에서 광고를 제공하기 위한 목적`를 체크합니다. 그렇지 않다면 `기존의 광고를 통해 App 설치를 유도하기 위한 목적`과 `기존의 광고를 통해 App에서 특정 행위를 유도하기 위한 목적`을 체크해야 하는데, 기존의 광고라는 의미가 모호합니다.

그래서 언어 설정을 영어로 변경하여 해당 항목을 확인 했습니다.

<img src="{{ site.production_url }}/image/flickr/8813/28422032026_aca7552327.jpg" width="500" height="249" alt=""><br/>

`기존의 광고를 통해`라는 의미는 `previously served advertisement`로 우리가 리뷰하는 앱이 아닌 다른 앱에서 제공된 광고라는 의미로 받아들일 수 있습니다.

따라서 앱 내에서 별도 광고를 하지 않는다면 `기존의 광고를 통해 App 설치를 유도하기 위한 목적`과 `기존의 광고를 통해 App에서 특정 행위를 유도하기 위한 목적`을 체크하면 됩니다.

하지만 이는 절대 사항은 아니므로, 기록으로 남겨놓습니다.
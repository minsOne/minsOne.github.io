---
layout: post
title: "[iOS][Swift] 플러그인 패턴 - 1"
description: ""
category: "programming"
tags: []
---
{% include JB/setup %}

<div class="alert warning"><strong>경고</strong>:본 내용은 이해하면서 작성하는 글이기 때문에 잘못된 내용이 포함될 수 있습니다. 따라서 언제든지 내용이 수정되거나 삭제될 수 있습니다.</div>

이 편에서는 코드를 분석 및 이해하고 다음 편에서 개념을 제대로 다룰 예정입니다.

# Plugin Pattern

어플리케이션의 크기가 커지면, 기능 개발하기에는 빌드 속도가 느려지고, 각 기능간의 커플링 등이 일어날 수 있어 각 기능을 집중해서 개발하도록 모듈로 분리를 합니다.

<p style="text-align:center;"><img src="{{ site.production_url }}/image/2020/06/18_1.png" style="width: 500px"/></p><br/>

위 이미지에서는 각 기능 간의 연결이 없습니다. 하지만 요구사항이 그렇게 만만하지 않습니다. Feature A에서 Feature B를 필요로 할 때도 있고, Feature B에서 Feature A를 필요로 할 때도 있습니다.

<p style="text-align:center;"><img src="{{ site.production_url }}/image/2020/06/18_2.png" style="width: 500px"/></p><br/>

이런 경우는 Feature A와 Feature B가 서로 요구를 하기 때문에, Circular Dependency - 순환 종속성 관계로, 컴파일이 되지 않습니다.

그렇다면 어떻게 해야할까요?

Feature A, B는 App에다 요청을 하여 위임하는 방법이 있습니다. 하지만 깊이가 깊어진다면 요청하기도 쉽지가 않아집니다.

# 참고자료 

* https://github.com/Vinodh-G/NewsApp 
* https://blog.usejournal.com/extending-your-modules-using-a-plugin-architecture-c1972735d728 
* https://gist.github.com/dehrom/ac1a50cfbee3b573fd590150e652f914 
* https://kdata.or.kr/info/info_04_view.html?field=&keyword=&type=techreport&page=223&dbnum=127607&mode=detail&type=techreport 
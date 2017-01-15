---
layout: post
title: "[Swift]컴파일 시간을 아주 많이 줄이기"
description: ""
category: "Mac/iOS"
tags: [swift, compiler, flag]
---
{% include JB/setup %}

Swift를 현업에서 사용하다보면, 고통 받는 시간이 있습니다. 컴파일 시간입니다. 

Objective-C는 1~2분이면 빌드가 끝나고 시뮬레이터에서 동작하거나 ipa 파일을 뱉어 냅니다. 하지만 제가 진행하고 있는 프로젝트의 초기에는 8분, 그리고 현재 13분 걸립니다. 다른 작업과 병행하고 있으면 훨씬 더 많은 시간이 걸립니다. 

처음에는 13인치 맥북프로의 한계거니 했지만 15인치 맥북은 조금 더 빠르게 컴파일 되는 정도? 13인치가 13분 걸리면 15인치는 9분~10분 걸리는 것을 보고 어떻게 하면 속도를 빠르게 할 수 있을까 방안을 찾으러 많은 검색을 하였습니다.

하지만 컴파일 시간을 2분 내로 줄일 순 없었습니다. 

그러나 얼마전 본 글을 통해 1~2분 내로 컴파일 시간을 줄일 수 있었습니다.


1.일반적으로 컴파일러 최적화 레벨은 다음과 같이 설정되어 있습니다.

<img src="https://c1.staticflickr.com/1/514/32285730156_5c3109dc80_o.png" width="748" height="146">

2.다음과 같이 컴파일러 최적화 레벨을 설정합니다.

<img src="https://c1.staticflickr.com/1/282/32174854382_013f7ae20c_o.png" width="768" height="146">

3.다음과 같이 Custom Flags에 Swift Flag를 설정합니다.

<img src="https://c1.staticflickr.com/1/336/32204985471_c6ff6601f7_o.png" width="571" height="142">

이제 클린 후 빌드를 수행하면 시간이 아주 많이 준 것을 확인할 수 있습니다.

이 옵션을 통해 3분 걸리던게 10초로 걸린다는 의견도 있었고, 제 경우는 1분 내외로 빌드 완료됩니다.

하지만 이 옵션이 어떤 영향을 미치는지 아직 파악되지 않았기 때문에, 개발시에만 적용하는 것을 추천드립니다.

## 참고

* [Speeding Up Compile Times of Swift Projects](http://developear.com/blog/2016/12/30/Speed-Swift-Compilation.html)
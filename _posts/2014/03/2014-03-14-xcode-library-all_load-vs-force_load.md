---
layout: post
title: "[Xcode]Library 호출 시 사용하는 all_load, force_load"
description: ""
category: "Mac/iOS"
tags: [Xcode, Framework, linker, all_load, force_load, kakaotalk, objc, library]
---
{% include JB/setup %}

## 들어가기 전에

이번에 프로젝트에 카카오톡 링크 기능을 추가할 필요가 있어서 [카카오톡 개발자 페이지](https://developers.kakao.com)에서 framework을 내려받고 추가하였습니다.

개발 가이드를 보다보니 프로젝트 Build Settings의 Linking에 -all_load를 추가하라는 문구가 있어 일단 하라는 대로 작업을 해보았습니다.

![xcode-build-settings-linkings-all_load](/../../../../image/2014/03/xcode-build-settings-linkings-all_load.png)

만약에 다른 라이브러리들이 추가가 되지 않은 상태라면 정상적인 결과가 나왔겠지만 프로젝트에 여러개의 라이브러리들을 사용하고 있어 다음과 같은 오류 메시지가 출력되었습니다.

![xcode-build-settings-linkings-all_load-error](/../../../../image/2014/03/xcode-build-settings-linkings-all_load-error.png)

그래서 -force_load로 변경하여 카카오톡 framework를 로드하여 정상적으로 수행되었습니다.

	 -force_load $SRCROOT/../ExternalAPIs/KakaoOpenSDK/KakaoOpenSDK.framework/KakaoOpenSDK


## all_load와 force_load

-all_load는 linker가 Object-C Code가 있는지 상관없이 모든 archive로부터 모든 Object file들을 load하도록 합니다. 

-force_load는 Xcode 3.2 이후부터 가능합니다.

-force_load는 정교하게 archive loading을 다룹니다.

각 -force_load 옵션은 archive에 대한 경로여야 하며, archive에 있는 Object file이 load될 것입니다.

<div class="alert-info"><strong>팁</strong>64-bit 어플리케이션에 linker 버그를 방지하기 위해 -ObjC를 추가해야 합니다.</div>

참고 : [Why do I get a runtime exception of "selector not recognized" when linking against an Objective-C static library that contains categories?](https://developer.apple.com/library/mac/qa/qa1490/_index.html)
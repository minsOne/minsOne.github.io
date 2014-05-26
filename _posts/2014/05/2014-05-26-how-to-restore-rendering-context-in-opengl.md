---
layout: post
title: "OpenGL을 사용하는 라이브러리간 화면 객체 충돌을 처리하는 방법"
description: ""
category: "iOS"
tags: [iOS, OpenGL, Context, EAGLContext]
---
{% include JB/setup %}

다른 뷰어 라이브러리들이 OpenGL을 사용하는 경우에 Context가 정리되면서 기존 뷰의 Context들이 사라져버리는 경우들이 있습니다.

`EAGLContext`는 OpenGL ES Rendering context를 관리하며 다른 뷰로 호출할 경우 Context를 저장하여 나중에 복원할 수 있습니다.

`EAGLContext`는 OpenGL를 사용하기 위해 화면에 그릴 수 있도록 필요한 `상태 정보`, `명령`, `리소스`를 가지고 있습니다.

다음은 Context를 저장하여 나중에 기존 뷰로 돌아올 때 복원하는 과정입니다.

	// 기존 Context를 저장하기
	EAGLContext *oldContext = [EAGLContext currentContext];

	// 기존 Context로 복원하기
	[EAGLContext setCurrentContext:oldContext];


### 참고할 내용
* [OpenGL ES Programming Guide for iOS](https://developer.apple.com/library/ios/documentation/3ddrawing/conceptual/opengles_programmingguide/Introduction/Introduction.html)
* [EAGLContext Class Reference](https://developer.apple.com/library/ios/documentation/opengles/reference/EAGLContext_ClassRef/Reference/EAGLContext.html)
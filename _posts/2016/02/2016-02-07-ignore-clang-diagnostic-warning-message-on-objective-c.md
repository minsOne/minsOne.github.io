---
layout: post
title: "[Objective-C][LLVM]Clang diagnostic 경고 무시하기"
description: ""
category: "programming"
tags: [objective-c, llvm, clang, warning, compiler]
---
{% include JB/setup %}

### Clang diagnostic 경고 무시하기

코드를 작성하다 보면 어쩔 수 없이 경고가 발생하더라도 그대로 작업해야 하는 경우가 있습니다. 예를 들면, 컴파일 및 배포를 해도 상관은 없지만 Xcode Server에서 경고 메시지가 하나 이상 있다면 실패로 간주합니다. 그래서 강제로 성공으로 만들기 위해서는 경고를 무시할 필요가 있습니다.

다음은 Clang 경고 메시지를 무시하는 코드입니다.

	#pragma clang diagnostic push
	#pragma clang diagnostic ignored "경고가 발생하는 원인"
	// your code
	#pragma clang diagnostic pop

	ex)
	#pragma clang diagnostic ignored "-Wshadow-ivar"
	#pragma clang diagnostic ignored "-Wmismatched-return-types"
	#pragma clang diagnostic ignored "-Woverriding-method-mismatch"
	#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	#pragma clang diagnostic ignored "-Wundeclared-selector"

더 많은 Clang 경고 메시지를 보시려면 [fuckingclangwarnings.com](http://fuckingclangwarnings.com)에서 확인할 수 있습니다.
---
layout: post
title: "[Shell][Xcode]PlistBuddy를 이용하여 Plist의 CFBundleVersion 다루기"
description: ""
category: "Mac/iOS"
tags: [plist, PlistBuddy, libexec, shell, git, commit, count, rev-list]
---
{% include JB/setup %}

최근에 맡은 프로젝트가 2개가 되고 7개의 앱을 관리하게 되었습니다. 그래서 앱 업데이트를 할 때마다 plist에 있는 버전 정보를 바꾸는 것이 정말로 귀찮아 졌습니다. 특히나 watch를 지원하는 앱인 경우는 watch의 버전 정보와 일치해줘야 합니다.

그래서 버전 값을 바꾸는 스크립트를 python으로 작성을 했었는데, 진짜 간단한 기능인데 분명히 plist를 바꿔주는 녀석이 있을 것이다라고 생각하여 찾아보았습니다. 이미 많은 분들이 `PlistBuddy`를 쓰고 계셨습니다. 그래서 python 코드를 엎고 shellscript로 작성하였습니다.

자주 사용하는 entity인 CFBundleVersion, CFBundleShortVersionString을 PlistBuddy를 이용하여 출력하고 변경할 수 있습니다.

	/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString 17" "bodlebook-Info.plist"
	/usr/libexec/PlistBuddy -c "Set :CFBundleVersion 32" "bodlebook-Info.plist"

	/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "bodlebook-Info.plist"
	// output : 17
	/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "bodlebook-Info.plist"
	// output : 32

만약 CFBundleVersion 값을 git commit 숫자로 하여 신경쓰지 않게 하려면 rev-list를 사용하면 됩니다.

	$ git rev-list --count master
	// output : 532

	#!/bin/sh
	bundleversion="$(git rev-list --count master)"
	/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $bundleversion" "bodlebook-Info.plist"
	/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "bodlebook-Info.plist"
	// output : 532

PlistBuddy에 대해 더 알기를 원한다면 `man PlistBuddy`를 통해 확인할 수 있습니다.<br/><br/>
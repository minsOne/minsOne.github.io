---
layout: post
title: "[Xcode] Release로 실행시 BreakPoint가 동작하지 않는 문제 해결"
description: ""
category: "Mac/iOS"
tags: [Xcode]
---
{% include JB/setup %}

일반적으로 개발 Target과 배포 Target이 분리되어 있는 경우가 많은데, 개발 Target으로 가끔씩 Release 빌드로 실행해야 하는 경우가 있습니다. 그런 경우, BreakPoint를 걸어나도 동작을 하지 않는다면 프로젝트 설정에서 다음 항목을 변경해주면 됩니다.

* Deployment -> `Deployment Postprocessing`를 찾거나 `DEPLOYMENT_POSTPROCESSING`를 검색하여 `No`로 설정

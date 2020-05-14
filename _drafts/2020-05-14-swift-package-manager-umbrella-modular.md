---
layout: post
title: "swift package manager umbrella modular"
description: ""
category: ""
tags: []
---
{% include JB/setup %}

Swift Package Manager (이하 SPM)은 Xcode 11의 기능으로 추가되었습니다. 이에 따라 많은 오픈소스들이 SPM을 지원합니다. 대표적으로 Alamofire, SDWebImage, RxSwift, ReactorKit 등의 오픈소스가 있습니다.

## SPM 적용하기

보통 Workspace 내에 메인 앱 프로젝트가 있고, 여러 개의 타겟을 가지는 형태로 되어 있습니다.

<p style="text-align:center;"><img src="{{ site.production_url }}/image/2020/05/1.png"/></p><br/>

타겟에는 거의 대부분 같은 라이브러리들이 추가됩니다. Alamofire, SDWebImage, RxSwift, ReactorKit 등이 추가될 것이고, 개발 타겟에는 Flex 같은 디버깅 라이브러리가 추가될 것입니다.

그러면 다음과 같은 타겟과 라이브러리 연결 구조가 형성됩니다.

<p style="text-align:center;"><img src="{{ site.production_url }}/image/2020/05/2.png"/></p><br/>



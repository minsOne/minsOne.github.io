---
layout: post
title: "[Xcode 9.3] 새로 추가된 Compiler Option - Compilation Mode의 Single File"
description: ""
category: "Tools"
tags: [Xcode, compiler]
---
{% include JB/setup %}

iOS 개발에서 Objective-C에서 Swift로 넘어오면서 가장 체감을 많이 느끼는건 컴파일 시간입니다. 

프로젝트의 크기에 따라 다르지만, Swift 소스만 수백 또는 천 개 이상 넘어가는 프로젝트인 경우는 컴파일 시간이 몇 분 또는 십 분 이상 넘어가기도 합니다. 이번 Xcode 9.3의 Release Notes에서 다음 항목을 보고 이거다 했습니다.<br/>

>
The choice for compiling Swift code by file or by module moved from the Optimization Level setting to Compilation Mode, which is a new setting for the Swift compiler in the Build Settings pane of the Project editor. Previously this choice was combined with others in the Optimization Level setting. Compiling by file enables building only the files that changed, enabling faster builds. Compiling by module enables better optimization. (36887476)
>

<br/>

파일의 내용을 일부 바꾸더라도 전체 컴파일을 하던 것이 아니라 변경된 파일만 컴파일하여 빌드가 빨라진다고 합니다. 기존 프로젝트에서는 `Build Settings`의 `Swift Compiler - Code Generation` 옵션 중 `Compilation Mode` 값이 아마 `Whole Module`로 설정되어 있을 것이고, Xcode 9.3 으로 새로운 프로젝트를 만든 경우는 `Single File`로 되어 있습니다.(DEBUG 항목)

기존 프로젝트는 `Compilation Mode`의 `Whole Module`에서 `Single File`로 바꿔주면 됩니다.

<div class="alert"><strong>주의 : </strong>티켓 작업과 같이 여러 브랜치로 이동해야 하는 경우, 전체 컴파일을 계속 하기 때문에 소스 파일이 많다면 빌드 속도가 느려질 수 있습니다. 개인적으로 Single File은 한 브랜치에서 오래 작업하는 경우에 추천합니다.</div>

## 출처

* [Xcode Release Notes](https://developer.apple.com/library/content/releasenotes/DeveloperTools/RN-Xcode/Chapters/Introduction.html#//apple_ref/doc/uid/TP40001051-CH1-DontLinkElementID_1)

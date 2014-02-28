---
layout: post
title: "[Xcode]Xcode 플러그인 VVDocumenter-Xcode 소개"
description: ""
categories: [Xcode, iOS, Mac]
tags: [Xcode, iOS, Mac, Comment, Javadoc, Document]
---
{% include JB/setup %}

## VVDocumenter-Xcode

주석 작성할 때 `*`나 `/`를 사용해서 함수앞이나 로직부분에 작성을 하게 되는데 항상 어떻게 작성해야 할지 규칙이 손에 익지 않으면 문서를 보고 다시 작성해야 하는 번거로움이 있습니다. 

[VVDocumenter-Xcode](https://github.com/onevcat/VVDocumenter-Xcode) 플러그인은 `///`을 입력하면 자동으로 양식을 찾아 만들어 줍니다.

또한 VVDocumenter-Xcode는 쉽게 Javadoc 스타일로 주석을 만들어 줍니다. 또한 appleDoc, Doxygen도 호환이 됩니다.

다음은 어떻게 사용하는지에 대한 예제입니다.
![VVDocumenter Xcode](/../../../../image/2014/vvdocumenter-Xcode.gif)

### 설치 방법

1. 우선 [VVDocumenter-Xcode](https://github.com/onevcat/VVDocumenter-Xcode) 프로젝트를 다운 받습니다.

2. 다운받은 프로젝트를 Xcode로 엽니다.

3. Scheme과 Target이 다음과 같이 되어 있는지 확인합니다.<br/>![VVDocumenter Project Image](/../../../../image/2014/vvdocumenter_xcode.png)

4. VVDocumenter-Xcode 프로젝트를 빌드합니다.

5. `~/Library/Application Support/Developer/Shared/Xcode/Plug-ins` 경로 아래에 `VVDocumenter-Xcode.xcplugin`가 있는지 확인합니다.

6. Xcode를 종료를 하고 다시 시작합니다.

7. 위의 사용하는 예제처럼 따라서 해봅니다.
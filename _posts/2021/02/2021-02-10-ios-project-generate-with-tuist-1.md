---
layout: post
title: "[iOS][Tuist] 프로젝트 생성/관리 도구 Tuist(1) - Start"
description: ""
category: "Mac/iOS"
tags: [Swift, Xcode, XcodeGen, Tuist]
---
{% include JB/setup %}

<div class="alert warning"><strong>주의</strong> : 이 글에서 사용하는 Tuist 버전은 1.7.1 이므로 일부 동작이 다르게 될 수 있어 작업시 유의하시기 바랍니다.</div>

Xcode로 개발하다보면 타겟에 새로운 파일을 추가하거나, 프레임워크를 만들거나 등등의 방법이 매우 좋지 않습니다. 그래서 [XcodeGen](https://github.com/yonaskolb/XcodeGen)과 같이 XcodeProj 파일을 만드는 도구를 이용하기도 합니다.

하지만 XcodeGen은 YAML으로 관리하며, 해당 값들은 다 문자열을 입력해야합니다. 이러한 단점을 완벽하지는 않지만 자동완성을 지원해주는 도구인 [Tuist](https://github.com/tuist/tuist)가 있습니다.

프로젝트 초기 셋업, 빌드, 수정등의 명령어를 통해서 쉽게 프로젝트를 관리할 수 있습니다.

### Install

다음 명령어로 설치할 수 있습니다.

```
$ bash <(curl -Ls https://install.tuist.io)
```

### 프로젝트 생성

폴더 생성 후, 다음 명령어를 실행합니다.

```
$ mkdir MyApp
$ cd MyApp
$ tuist init --platform ios
$ tree .
➜  MyApp tree
.
├── Projects
│   ├── MyApp
│   │   ├── Project.swift
│   │   ├── Sources
│   │   │   └── AppDelegate.swift
│   │   └── Tests
│   │       └── MyAppTests.swift
│   ├── MyAppKit
│   │   ├── Playgrounds
│   │   │   └── MyAppKit.playground
│   │   │       ├── Contents.swift
│   │   │       └── contents.xcplayground
│   │   ├── Project.swift
│   │   ├── Sources
│   │   │   └── MyAppKit.swift
│   │   └── Tests
│   │       └── MyAppKitTests.swift
│   └── MyAppSupport
│       ├── Playgrounds
│       │   └── MyAppSupport.playground
│       │       ├── Contents.swift
│       │       └── contents.xcplayground
│       ├── Project.swift
│       ├── Sources
│       │   └── MyAppSupport.swift
│       └── Tests
│           └── MyAppSupportTests.swift
├── Setup.swift
├── Tuist
│   ├── Config.swift
│   ├── ProjectDescriptionHelpers
│   │   └── Project+Templates.swift
│   └── Templates
│       └── framework
│           ├── Template.swift
│           └── project.stencil
└── Workspace.swift

18 directories, 19 files
```

프로젝트 파일, 소스 파일들이 추가된 것을 확인할 수 있습니다.

프로젝트 관련 소스인 Project.swift만을 관리하고 수정하는 명령어인 `tuist edit`를 실행합니다.

```
$ tuist edit
```

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/02/20210210_1.png" style="width: 800px"/>
</p><br/>

그리고 각각의 Project.swift 파일은 다음과 같이 구성되어 있습니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/02/20210210_2.png" style="width: 600px"/>
<img src="{{ site.production_url }}/image/2021/02/20210210_3.png" style="width: 600px"/>
<img src="{{ site.production_url }}/image/2021/02/20210210_4.png" style="width: 600px"/>
</p><br/>

여기에서 원하는 환경으로 설정한 뒤에 `tuist generate` 명령어를 이용하여 프로젝트를 생성합니다.

```
$ tuist generate
Generating workspace MyApp.xcworkspace
Generating project MyApp
Generating project MyAppKit
Generating project MyAppSupport
Project generated.
Total time taken: 6.902s
$ tree
.
├── MyApp.xcworkspace
│   ├── contents.xcworkspacedata
│   ├── xcshareddata
│   │   └── IDEWorkspaceChecks.plist
│   └── xcuserdata
│       └── minsone.xcuserdatad
│           ├── UserInterfaceState.xcuserstate
│           └── xcschemes
│               └── xcschememanagement.plist
├── Projects
│   ├── MyApp
│   │   ├── Derived
│   │   │   └── InfoPlists
│   │   │       ├── MyApp.plist
│   │   │       └── MyAppTests.plist
│   │   ├── MyApp.xcodeproj
│   │   │   ├── project.pbxproj
│   │   │   ├── project.xcworkspace
│   │   │   │   └── contents.xcworkspacedata
│   │   │   └── xcshareddata
│   │   │       ├── xcdebugger
│   │   │       └── xcschemes
│   │   │           ├── MyApp.xcscheme
│   │   │           └── MyAppTests.xcscheme
│   │   ├── Project.swift
│   │   ├── Sources
│   │   │   └── AppDelegate.swift
│   │   └── Tests
│   │       └── MyAppTests.swift
│   ├── MyAppKit
│   │   ├── Derived
│   │   │   └── InfoPlists
│   │   │       ├── MyAppKit.plist
│   │   │       └── MyAppKitTests.plist
│   │   ├── MyAppKit.xcodeproj
│   │   │   ├── project.pbxproj
│   │   │   ├── project.xcworkspace
│   │   │   │   └── contents.xcworkspacedata
│   │   │   └── xcshareddata
│   │   │       ├── xcdebugger
│   │   │       └── xcschemes
│   │   │           ├── MyAppKit.xcscheme
│   │   │           └── MyAppKitTests.xcscheme
│   │   ├── Playgrounds
│   │   │   └── MyAppKit.playground
│   │   │       ├── Contents.swift
│   │   │       └── contents.xcplayground
│   │   ├── Project.swift
│   │   ├── Sources
│   │   │   └── MyAppKit.swift
│   │   └── Tests
│   │       └── MyAppKitTests.swift
│   └── MyAppSupport
│       ├── Derived
│       │   └── InfoPlists
│       │       ├── MyAppSupport.plist
│       │       └── MyAppSupportTests.plist
│       ├── MyAppSupport.xcodeproj
│       │   ├── project.pbxproj
│       │   ├── project.xcworkspace
│       │   │   └── contents.xcworkspacedata
│       │   └── xcshareddata
│       │       ├── xcdebugger
│       │       └── xcschemes
│       │           ├── MyAppSupport.xcscheme
│       │           └── MyAppSupportTests.xcscheme
│       ├── Playgrounds
│       │   └── MyAppSupport.playground
│       │       ├── Contents.swift
│       │       └── contents.xcplayground
│       ├── Project.swift
│       ├── Sources
│       │   └── MyAppSupport.swift
│       └── Tests
│           └── MyAppSupportTests.swift
├── Setup.swift
├── Tuist
│   ├── Config.swift
│   ├── ProjectDescriptionHelpers
│   │   └── Project+Templates.swift
│   └── Templates
│       └── framework
│           ├── Template.swift
│           └── project.stencil
└── Workspace.swift

44 directories, 41 files
```

그리고 워크스페이스 파일을 열면 프로젝트가 만들어진 것을 확인할 수 있습니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/02/20210210_5.png" style="width: 800px"/>
</p><br/>


## 참고

* [Tuist Document - Get started](https://tuist.io/docs/usage/get-started/)
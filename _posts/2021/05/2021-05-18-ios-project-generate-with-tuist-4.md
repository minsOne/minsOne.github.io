---
layout: post
title: "[iOS][Tuist] 프로젝트 생성/관리 도구 Tuist(4) - Plugin"
description: ""
category: "Mac/iOS"
tags: [Swift, Xcode, Plugin, Tuist]
---
{% include JB/setup %}

[Tuist 1.33.0](https://github.com/tuist/tuist/releases/tag/1.33.0)에서 Plugin 이라는 기능이 생겼습니다. 

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Celebrating Friday with a new release - 1.33.0, Plugin!<br><br>🔌 Plugin support! Documentation is still in progress but will soon be available <br>📦 tuist graph for only subset of targets <a href="https://twitter.com/adellibovi?ref_src=twsrc%5Etfw">@adellibovi</a><br>📊 Analytics events<br><br>Check out the full changelog here: <a href="https://t.co/CLSTv1nXwf">https://t.co/CLSTv1nXwf</a></p>&mdash; Tuist.swift (@tuistio) <a href="https://twitter.com/tuistio/status/1357803802896793600?ref_src=twsrc%5Etfw">February 5, 2021</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

<br/>기존에는 Manifests의 Tuist ProjectDescriptionHelpers에 추가해야만 기능을 추가하거나 확장할 수 있었습니다.

하지만 Plugin을 통해서 비대해지는 ProjectDescriptionHelpers의 기능을 일부 이전하여 모듈을 사용하는 방식으로 쉽게 사용하도록 돕습니다.

## Plugin 만들기

1.Root에서 Plugin 폴더를 생성합니다.

```
$ mkdir Plugin
```

2.생성하려는 Plugin의 이름을 가진 폴더, 그리고 그 Plugin 내에 ProjectDescriptionHelpers 폴더를 만듭니다.

```
$ mkdir -p Plugin/UtilityPlugin/ProjectDescriptionHelpers
$ tree Plugin
Plugin
└── UtilityPlugin
    └── ProjectDescriptionHelpers
```

3.UtilityPlugin 폴더에 Plugin.swift 파일을 만들고 Plugin의 이름을 지정합니다.

```
$ touch Plugin/UtilityPlugin/Plugin.swift
$ cat Plugin/UtilityPlugin/Plugin.swift
import ProjectDescription

let utilityPlugin = Plugin(name: "UtilityPlugin")
```

4.Config.swift 파일에 Local Plugin을 지정합니다.
```
$ cat Tuist/Config.swift
import ProjectDescription

let config = Config(
    plugins: [
        .local(path: .relativeToRoot("Plugin/UtilityPlugin"))
    ],
    generationOptions: [
        
    ])
```

5.`tuist edit` 실행하면, Project Navigator에 Plugins 프로젝트가 있는 것을 확인할 수 있으며, Scheme에는 우리가 만든 UtilityPlugin이 있음을 확인할 수 있습니다.있습니다.

```
$ tuist edit
```

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/05/20210518_01.png" style="width: 800px"/>
</p><br/>

6.UtilityPlugin의 ProjectDescriptionHelpers에 필요한 코드들을 추가합니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/05/20210518_02.png" style="width: 800px"/>
</p><br/>

7.`import UtilityPlugin`를 하여 Plugin을 import 하면 해당 코드에서 UtilityPlugin의 코드를 사용할 수 있습니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/05/20210518_03.png" style="width: 800px"/>
</p><br/>

Tuist의 문서에서 [Plugins](https://docs.tuist.io/plugins/using-plugins) 항목을 보면 자세하게 할 수 있습니다.

## 참고자료

* [Tuist - Plugins](https://docs.tuist.io/plugins/using-plugins)
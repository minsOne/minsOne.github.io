---
layout: post
title: "[iOS][Tuist] 프로젝트 생성/관리 도구 Tuist(5) - Local Swift Package와 Proxy Swift Package"
description: ""
category: "Mac/iOS"
tags: [Swift, Xcode, Tuist, Swift Package, SwiftPM]
# published: false
---
{% include JB/setup %}

Tuist에서는 Local Swift Package를 의존성 가지도록 지원하고 있습니다. 프로젝트가 Local Swift Package를 의존성을 가지면 다음과 같이 구성됩니다.

```
$ mkdir ResourcePackage
$ cd ResourcePackage
$ swift package init --type library
```

```
// FileName : Project.swift
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(name: "App",
                      organizationName: "minsone",
                      packages: [.local(path: .relativeToRoot("Projects/ResourcePackage"))],
                      targets: [
                        Target(name: "App",
                               platform: .iOS,
                               product: .app,
                               bundleId: "kr.minsone.App",
                               infoPlist: .default,
                               sources: ["Sources/**"],
                               resources: [],
                               dependencies: [.package(product: "ResourcePackage")]),
                      ])

```

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/06/20210627_01.png" style="width: 800px"/>
</p><br/>

위 그림과 같이 Local Swift Package는 해당 패키지를 의존성을 가지는 프로젝트 내에 위치하도록 만들어집니다. 해당 패키지가 이 프로젝트에만 종속되도록 한게 아니며, 어떤 프로젝트 내에 포함될지 작성자가 알지 못하는 문제가 있습니다.

따라서 워크스페이스에서 패키지가 독립적인 위치를 가지도록 하려고 합니다. 즉, 기존에 만든 패키지는 Proxy 역할을 하고, Proxy 패키지는 실제로 구현된 패키지를 의존성 가지도록 하는 것입니다.

첫번쨰로 Proxy 패키지를 만듭니다.

```
$ mkdir ProxyResourcePackage
$ cd ProxyResourcePackage
$ swift package init --type library
```

ProxyResourcePackage의 dependencies에 ResourcePackage를 추가합니다.

```
// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ProxyResourcePackage",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ProxyResourcePackage",
            targets: ["ProxyResourcePackage"]),
    ],
    dependencies: [
        .package(path: "../ResourcePackage")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ProxyResourcePackage",
            dependencies: ["ResourcePackage"]),
        .testTarget(
            name: "ProxyResourcePackageTests",
            dependencies: ["ProxyResourcePackage"]),
    ]
)
```

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/06/20210627_02.png" style="width: 800px"/>
</p><br/>

아까 위에서 작성했던 Tuist의 Project.swift 파일에서 ResourcePackage 패키지가 아닌 ProxyResourcePackage를 바라보도록 합시다.

```
// FileName : Project.swift
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(name: "App",
                      organizationName: "minsone",
                      packages: [.local(path: .relativeToRoot("Projects/ProxyResourcePackage"))],
                      targets: [
                        Target(name: "App",
                               platform: .iOS,
                               product: .app,
                               bundleId: "kr.minsone.App",
                               infoPlist: .default,
                               sources: ["Sources/**"],
                               resources: [],
                               dependencies: [.package(product: "ProxyResourcePackage")]),
                      ])
```

그리고 Tuist의 generate 명령을 이용하여 프로젝트를 새로 생성합시다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/06/20210627_03.png" style="width: 800px"/>
</p><br/>

프로젝트의 정보에는 ResourcePackage가 의존성 걸려있는지는 확인하긴 어렵지만, 코드에서 ResourcePackage를 import 할 수 있고, 해당 코드를 호출할 수 있음을 확인할 수 있습니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/06/20210627_04.png" style="width: 800px"/>
</p><br/>
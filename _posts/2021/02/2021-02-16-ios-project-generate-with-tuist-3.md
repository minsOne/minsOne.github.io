---
layout: post
title: "[iOS][Tuist] 프로젝트 생성/관리 도구 Tuist(3) - Extension"
description: ""
category: "Mac/iOS"
tags: [Swift, Xcode, XcodeGen, Tuist]
---
{% include JB/setup %}

<!-- 
https://github.com/JulianAlonso/excelsior/blob/acecfb60175c3608e67db00f960ed0e2e7ea8e52/Tuist/ProjectDescriptionHelpers/Dependencies.swift
https://okanghoon.medium.com/xcode-%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8-%EA%B4%80%EB%A6%AC%EB%A5%BC-%EC%9C%84%ED%95%9C-tuist-%EC%95%8C%EC%95%84%EB%B3%B4%EA%B8%B0-6a92950780be
 -->

 <div class="alert warning"><strong>주의</strong> : 이 글에서 사용하는 Tuist 버전은 1.7.1 이므로 일부 동작이 다르게 될 수 있어 작업시 유의하시기 바랍니다.</div>

## Extension

### Dependency

Tuist에서 프로젝트 코드를 추가할 때, 의존성에 다른 프로젝트를 추가할 수 있습니다. 하지만, 그 경로가 각각 다르기 떄문에 수동으로 지정을 해줘야 합니다. 

하지만 ProjectDescriptionHelpers 에서 TargetDependency Extension에 추가하거나 Package Extension에 추가하면, 프로젝트를 생성시 정적으로 쉽게 관리할 수 있습니다.

```
import ProjectDescription

// MARK: Project
public extension TargetDependency {
  static let staticFrameworkKit: TargetDependency = .project(target: "StaticFrameworkKit",
                                                             path: .relativeToRoot("StaticFrameworkKit"))
  static let staticFrameworkKit2: TargetDependency = .project(target: "StaticFrameworkKit2",
                                                              path: .relativeToRoot("StaticFrameworkKit2"))
}

// MARK: Package
public extension TargetDependency {
  static let alamofire: TargetDependency = .package(product: "Alamofire")
  static let kingfisher: TargetDependency = .package(product: "Kingfisher")
}

public extension Package {
  static let alamofire: Package = .package(url: "https://github.com/Alamofire/Alamofire.git", .branch("master"))
  static let kingfisher: Package = .package(url: "https://github.com/onevcat/Kingfisher", from: "5.1.0")
}

// MARK: SourceFile
public extension SourceFilesList {
  static let sources: SourceFilesList = "Sources/**"
  static let tests: SourceFilesList = "Tests/**"
}

// MARK: Resource
public enum ResourceType: String {
  case xibs        = "Sources/**/*.xib"
  case storyboards = "Resources/**/*.storyboard"
  case assets      = "Resources/**"
}

// MARK: Extension
public extension Array where Element == FileElement {
  static func resources(with resources: [ResourceType]) -> [FileElement] {
    resources.map { FileElement(stringLiteral: $0.rawValue) }
  }
}
```

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/02/20210216_1.png" style="width: 800px"/>
</p><br/>


위와 같이 TargetDependency, Package Extension에 코드를 추가하면, Project.swift 에서 의존성을 쉽게 추가할 수 있습니다.

```
// FileName: Project.swift

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  name: "StaticFrameworkKit",
  organizationName: "minsone",
  packages: [
    .alamofire,
    .kingfisher
  ],
  targets: [
    Target(name: "StaticFrameworkKit",
           platform: .iOS,
           product: .staticFramework,
           bundleId: "kr.minsone.StaticFrameworkKit",
           deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
           infoPlist: .default,
           sources: .sources,
           resources: .resources(with: [.storyboards, .assets]),
           actions: [],
           dependencies: [
            .alamofire,
            .kingfisher,
            .staticFramework2
           ]),
    Target(name: "StaticFrameworkKitTests",
           platform: .iOS,
           product: .unitTests,
           bundleId: "kr.minsone.StaticFrameworkKitTests",
           infoPlist: .default,
           sources: .tests,
           dependencies: [
            .target(name: "StaticFrameworkKit")
           ])
  ]
)
```

다음으로 generate 명령을 이용하여 프로젝트를 생성합니다.

```
$ tuist generate
Generating workspace MyApp.xcworkspace
Generating project StaticFrameworkKit
Generating project StaticFrameworkKit2
Command line invocation:
    /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -resolvePackageDependencies -workspace /Users/minsone/tmp/Tuist/MyApp/MyApp.xcworkspace -list

Resolve Package Graph

Resolved source packages:
  Kingfisher: https://github.com/onevcat/Kingfisher @ 5.15.8
  Alamofire: https://github.com/Alamofire/Alamofire.git @ master

Information about workspace "MyApp":
    Schemes:
        StaticFrameworkKit
        StaticFrameworkKit2
        StaticFrameworkKit2Tests
        StaticFrameworkKitTests

Project generated.
Total time taken: 3.902s
```

생성된 StaticFrameworkKit 프로젝트를 열어서 의존성이 잘 연결되었는지 확인합니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/02/20210216_2.png" style="width: 800px"/>
<img src="{{ site.production_url }}/image/2021/02/20210216_3.png" style="width: 800px"/>
</p><br/>

StaticFrameworkKit에 `Alamofire`, `Kingfisher`, `StaticFrameworkKit2`가 Linking되어있는 것을 확인할 수 있습니다.

## Project

Project 생성시 문자열을 넣어 만들어야 하는 부분들이 있습니다. Settings의 configuration의 name, xcconfig, Target의 bundleId, deploymentTarget, sources, Scheme 항목 등이 있습니다. 이러한 항목들은 적절하게 래핑하여 처리하는게 좋습니다. 이러한 코드는 기존에도 ProjectDescriptionHelpers에 `Project+Templates.swift` 파일을 살펴보면 app, framework 함수들이 적절하게 래핑되어 있는 것을 확인할 수 있습니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/02/20210216_4.png" style="width: 800px"/>
</p><br/>

여기에서 [예제](https://github.com/minsOne/TuistSample/tree/main/Example3)를 확인하실 수 있습니다.

## 참고자료

* Github
  * [SEC-Sport-Events-Calendar](https://github.com/wojtek717/SEC-Sport-Events-Calendar)
  * [excelsior](https://github.com/JulianAlonso/excelsior)
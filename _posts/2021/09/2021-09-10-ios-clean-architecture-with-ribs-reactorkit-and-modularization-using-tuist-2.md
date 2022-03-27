---
layout: post
title: "[iOS] 준 Clean Architecture With RIBs, ReactorKit 그리고 Tuist를 이용한 프로젝트 모듈화 설계(2) - Tuist"
description: ""
category: "Mac/iOS"
tags: [Swift, Xcode, Clean Architecture, RIBs, ReactorKit, Tuist]
---
{% include JB/setup %}

* [1편 - 설계편]({{BASE_PATH}}/mac/ios/ios-clean-architecture-with-ribs-reactorkit-and-modularization-using-tuist-1)
* [2편 - Tuist]({{BASE_PATH}}/mac/ios/ios-clean-architecture-with-ribs-reactorkit-and-modularization-using-tuist-2)
* [3편 - UserInterface]({{BASE_PATH}}/mac/ios/ios-clean-architecture-with-ribs-reactorkit-and-modularization-using-tuist-3)
* [4편 - Presentation, Domain]({{BASE_PATH}}/mac/ios/ios-clean-architecture-with-ribs-reactorkit-and-modularization-using-tuist-4)
* [5편 - Repository, Data, DI Container]({{BASE_PATH}}/mac/ios/ios-clean-architecture-with-ribs-reactorkit-and-modularization-using-tuist-5)

## 들어가기 전

Tuist를 이용하여 프로젝트를 구성할 것이므로, 어떻게 구조를 잡을 것인지 염두하고 작업해야 합니다. 그래야 모듈을 쉽게 추가할 수 있어, 확장이 가능합니다.

이 글은 Tuist 1.48.1 이상 버전이 설치되어 있음을 가정하고 작성되었습니다.

## Tuist 구조 설계

**1.** `tuist init` 명령으로 Tuist 초기설정합니다.

```
$ tuist init
$ tree .
.
├── Project.swift
├── Targets
└── Tuist
    ├── Config.swift
    └── ProjectDescriptionHelpers
        └── Project+Templates.swift
```

Targets 폴더와 Project.swift 파일은 삭제합니다.

**2.**  클린 아키텍처에서 따르는 프로젝트 구조를 만족하기 위해 Projects라는 폴더를 만든 후, 다음 구조로 모듈을 구성할 것입니다.
```
$ tree Projects
Projects
├── Application
├── Features
│   ├── Features
│   ├── BaseDependency
│   │   ├── DataRepository
│   │   ├── Domain
│   │   └── UserInterface
│   ├── FeatureLoan
│   │   ├── DataRepository
│   │   ├── Domain
│   │   └── UserInterface
│   ├── FeatureMain
│   │   ├── DataRepository
│   │   ├── Domain
│   │   └── UserInterface
│   └── FeatureSettings
│       ├── DataRepository
│       ├── Domain
│       └── UserInterface
├── Modules
│   ├── AnalyticsKit
│   ├── CoreKit
│   ├── ThirdPartyLibraryManager
│   └── UtilityKit
├── Network
│   ├── NetworkAPIKit
│   ├── NetworkAPICommon
│   ├── NetworkAPIHome
│   ├── NetworkAPILogin
│   ├── NetworkAPIs
│   └── NetworkStub
└── UserInterface
    ├── DesignSystem
    ├── ResourcePackage
    └── UserInterfaceLibraryManager
```

**3.**  각 폴더의 역할을 설명합니다.

* Application - 제품으로 나가는 애플리케이션을 관리하는 프로젝트로, AppDelegate, SceneDelegate, Push Notification, Widget 등을 다루고, 앱 시작시 어떤 기능으로 시작할지, 그리고 값 초기화, 설정 초기화 등을 처리하는 `프로젝트`입니다.
* Features - 화면 또는 비지니스로직 등 기능에서 준 클린 아키텍처 모듈을 모아두도록 하는 `폴더`입니다.
  * Features - 기능를 담당하는 준 클린 아키텍처 모듈의 집합인 Package 들을 의존성을 가지도록 하여 준 클린 아키텍처 모듈 전체를 관리하는 `프로젝트` 입니다.
  * FeatureMain - Main 기능에서 준 클린 아키텍처 모듈이 있는 `폴더`입니다.
    * DataRepository - Main 기능에서 준 클린 아키텍처에서 DataRepository를 담당하는 `프로젝트` 입니다.
    * Domain - Main 기능에서 준 클린 아키텍처에서 Domain을 담당하는 `프로젝트` 입니다.
    * UserInterface - Main 기능에서 준 클린 아키텍처에서 UserInterface을 담당하는 `프로젝트` 입니다.
  * FeatureLoan - 위와 상동
  * FeatureSettings - 위와 상동
* Modules - 각종 기능 모듈을 모아둔 `폴더`입니다.
  * AnalyticsKit - 앱로그를 담당하는 `프로젝트` 입니다.
  * CoreKit - AnalyticsKit, UtilityKit, ThirdPartyLibraryManager 등 모듈을 의존성 가지는 `프로젝트` 입니다. CoreKit을 의존성 가지면 하위 기능들을 다 사용할 수 있습니다.
  * ThirdPartyLibraryManager - 서드파티 라이브러리를 묶어 관리하는 `프로젝트` 입니다.
  * UtilityKit - 유틸리티 기능들을 담당하는 `프로젝트` 입니다.
* Network - 네트워크 모듈을 모아두는 `폴더`입니다.
  * NetworkAPIKit - 네트워크 기능의 기반으로 각종 API들이 만들어지도록 하는 `프로젝트` 입니다.
  * NetworkAPICommon - NetworkAPIKit 기반으로 Common API를 정의한 `프로젝트` 입니다.
  * NetworkAPIHome - NetworkAPIKit 기반으로 Home API를 정의한 `프로젝트` 입니다.
  * NetworkAPILogin - NetworkAPIKit 기반으로 Login API를 정의한 `프로젝트` 입니다.
  * NetworkAPIs - 각종 도메인 API 모듈을 모아서 관리하는 `프로젝트` 입니다.
  * NetworkStub - 빠른 개발을 위해 API의 Mock Response를 모아서 Stub 역할을 하는 `프로젝트` 입니다.
* UserInferface - 사용자 인터페이스 모듈을 모아두는 `폴더`입니다.
  * DesignSystem - 라이브러리를 이용하여 Design System을 정의 및 관리하는 `프로젝트` 입니다.
  * ResourcePackage - 앱에서 사용하는 리소스를 통합 관리하는 `프로젝트` 입니다.
  * UserInterfaceLibraryManager - UserInferface에서 사용할 라이브러리를 관리하는 `프로젝트` 입니다.

**4.** 위와 같이 역할별로 프로젝트를 구성하면 다음과 같은 프로젝트 구조 그래프를 그릴 수 있습니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/09/20210910_01.png"/></p>

## Tuist 코드 작성

**1.**  Tuist에서 커스텀 Plugin을 제공합니다. Plugin을 만들고, 각 모듈 경로를 정의하고, 정적으로 의존성을 가지도록 작업할 수 있습니다.

Tuist Root 경로에서 Plugin 폴더를 만들고, 커스텀 Plugin 폴더를 만듭니다. `Plugin/UtilityPlugin` 그리고 Plugin.swift 파일을 만들어 사용할 플러그인을 정의합니다.

```
$ mkdir -p Plugin/UtilityPlugin/ProjectDescriptionHelpers
$ touch Plugin/UtilityPlugin/Plugin.swift
$ cat <<EOF >Plugin/UtilityPlugin/Plugin.swift
import ProjectDescription

let utilityPlugin = Plugin(name: "UtilityPlugin")
EOF
```

**2.**  경로를 쉽게 사용할 수 있도록 Extension을 정의합니다.

```
$ touch Plugin/UtilityPlugin/ProjectDescriptionHelpers/Alias.swift
$ cat <<EOF >Plugin/UtilityPlugin/ProjectDescriptionHelpers/Alias.swift
import Foundation
import ProjectDescription

public typealias Dep = TargetDependency
EOF

$ touch Plugin/UtilityPlugin/ProjectDescriptionHelpers/PathExtension.swift
$ cat <<EOF >Plugin/UtilityPlugin/ProjectDescriptionHelpers/PathExtension.swift
import Foundation
import ProjectDescription

public extension ProjectDescription.Path {
    static func relativeToModule(_ pathString: String) -> Self {
        return .relativeToRoot("Projects/Modules/\(pathString)")
    }
    static func relativeToFeature(_ pathString: String) -> Self {
        return .relativeToRoot("Projects/Features/\(pathString)")
    }
    static func relativeToUserInterface(_ pathString: String) -> Self {
        return .relativeToRoot("Projects/UserInterface/\(pathString)")
    }
    static func relativeToDomain(_ pathString: String) -> Self {
        return .relativeToRoot("Projects/Domain/\(pathString)")
    }
    static func relativeToDataRepository(_ pathString: String) -> Self {
        return .relativeToRoot("Projects/DataRepository/\(pathString)")
    }
    static func relativeToNetwork(_ pathString: String) -> Self {
        return .relativeToRoot("Projects/Network/\(pathString)")
    }
    static func relativeToCarthage(_ pathString: String) -> Self {
        return .relativeToRoot("Tuist/Dependencies/Carthage/\(pathString)")
    }
    static var app: Self {
        return .relativeToRoot("Projects/App")
    }
}

// MARK: Extension
extension Dep {
    static func module(name: String) -> Self {
        return .project(target: name, path: .relativeToModule(name))
    }
    static func feature(name: String) -> Self {
        return .project(target: name, path: .relativeToFeature(name))
    }
    static func feature(name: String, path: String) -> Self {
        return .project(target: name, path: .relativeToFeature(path))
    }
    static func userInterface(name: String) -> Self {
        return .project(target: name, path: .relativeToUserInterface(name))
    }
    static func domain(name: String) -> Self {
        return .project(target: name, path: .relativeToDomain(name))
    }
    static func dataRepository(name: String) -> Self {
        return .project(target: name, path: .relativeToDataRepository(name))
    }
    static func network(name: String) -> Self {
        return .project(target: name, path: .relativeToNetwork(name))
    }
}
EOF
```

**3.**  우리가 작업할 모듈의 경로를 정의합니다.

```
$ touch Plugin/UtilityPlugin/ProjectDescriptionHelpers/Dependency+Project.swift
$ cat <<EOF >Plugin/UtilityPlugin/ProjectDescriptionHelpers/Dependency+Project.swift
import Foundation
import ProjectDescription

// MARK: Project
extension Dep {
    public struct Project {
        public struct Feature {
            public struct Settings {}
            public struct Main {}
            public struct Loan {}
        }
        public struct Module {}
        public struct Network {} 
        public struct UserInterface {}
    }
}


public extension Dep.Project.Feature {
    static let Features = Dep.feature(name: "Features")

    struct BaseDependency {
        public static let UserInterface  = Dep.feature(name: "FeatureBaseDependencyUserInterface", path: "BaseDependency/UserInterface")
        public static let Domain         = Dep.feature(name: "FeatureBaseDependencyDomain", path: "BaseDependency/Domain")
        public static let DataRepository = Dep.feature(name: "FeatureBaseDependencyDataRepository", path: "BaseDependency/DataRepository")
    }
}

public extension Dep.Project.Feature.Settings {
    static let UserInterface  = Dep.feature(name: "FeatureSettingsUserInterface", path: "FeatureSettings/UserInterface")
    static let Domain         = Dep.feature(name: "FeatureSettingsDomain", path: "FeatureSettings/Domain")
    static let DataRepository = Dep.feature(name: "FeatureSettingsDataRepository", path: "FeatureSettings/DataRepository")
    static let Pacakge: [Dep] = [UserInterface, Domain, DataRepository]
}

public extension Dep.Project.Feature.Main {
    static let UserInterface  = Dep.feature(name: "FeatureMainUserInterface", path: "FeatureMain/UserInterface")
    static let Domain         = Dep.feature(name: "FeatureMainDomain", path: "FeatureMain/Domain")
    static let DataRepository = Dep.feature(name: "FeatureMainDataRepository", path: "FeatureMain/DataRepository")
    static let Pacakge: [Dep] = [UserInterface, Domain, DataRepository]
}

public extension Dep.Project.Feature.Loan {
    static let UserInterface  = Dep.feature(name: "FeatureLoanUserInterface", path: "FeatureLoan/UserInterface")
    static let Domain         = Dep.feature(name: "FeatureLoanDomain", path: "FeatureLoan/Domain")
    static let DataRepository = Dep.feature(name: "FeatureLoanDataRepository", path: "FeatureLoan/DataRepository")
    static let Pacakge: [Dep] = [UserInterface, Domain, DataRepository]
}

public extension Dep.Project.UserInterface {
    static let DesignSystem = Dep.userInterface(name: "DesignSystem")
}

public extension Dep.Project.Module {
    static let AnalyticsKit                          = Dep.module(name: "AnalyticsKit")
    static let CoreKit                               = Dep.module(name: "CoreKit")
    static let DevelopTool                           = Dep.module(name: "DevelopTool")
    static let RxPackage                             = Dep.module(name: "RxPackage")
    static let ThirdPartyDynamicLibraryPluginManager = Dep.module(name: "ThirdPartyDynamicLibraryPluginManager")
    static let ThirdPartyLibraryManager              = Dep.module(name: "ThirdPartyLibraryManager")
    static let UtilityKit                            = Dep.module(name: "UtilityKit")
    static let RepositoryInjectManager               = Dep.module(name: "RepositoryInjectManager")
}

public extension Dep.Project.Network {
    static let APIs   = Dep.network(name: "NetworkAPIs")
    static let APIKit = Dep.network(name: "NetworkAPIKit")
    static let Common = Dep.network(name: "NetworkAPICommon")
    static let Home   = Dep.network(name: "NetworkAPIHome")
    static let Login  = Dep.network(name: "NetworkAPILogin")
}
EOF
```

**4.**  프로젝트 파일에서 사용할 템플릿을 커스텀하게 정의합니다.

```
$ cat <<EOF >Tuist/ProjectDescriptionHelpers/Project+Templates.swift
import ProjectDescription
import UtilityPlugin

public extension Project {
    static func staticLibrary(name: String,
                              platform: Platform = .iOS,
                              packages: [Package] = [],
                              dependencies: [TargetDependency] = [],
                              hasDemoApp: Bool = false) -> Self {
        return project(name: name,
                       packages: packages,
                       product: .staticLibrary,
                       platform: platform,
                       dependencies: dependencies,
                       hasDemoApp: hasDemoApp)
    }
    
    static func staticFramework(name: String,
                                platform: Platform = .iOS,
                                packages: [Package] = [],
                                dependencies: [TargetDependency] = [],
                                hasDemoApp: Bool = false) -> Self {
        return project(name: name,
                       packages: packages,
                       product: .staticFramework,
                       platform: platform,
                       dependencies: dependencies,
                       hasDemoApp: hasDemoApp)
    }
    
    static func framework(name: String,
                          platform: Platform = .iOS,
                          packages: [Package] = [],
                          dependencies: [TargetDependency] = [],
                          hasDemoApp: Bool = false) -> Self {
        return project(name: name,
                       packages: packages,
                       product: .framework,
                       platform: platform,
                       dependencies: dependencies,
                       hasDemoApp: hasDemoApp)
    }
}

public extension Project {
    static func project(name: String,
                        organizationName: String = "minsone",
                        packages: [Package] = [],
                        product: Product,
                        platform: Platform = .iOS,
                        deploymentTarget: DeploymentTarget? = .iOS(targetVersion: "13.0", devices: .iphone),
                        dependencies: [TargetDependency] = [],
                        infoPlist: [String: InfoPlist.Value] = [:],
                        hasDemoApp: Bool = false) -> Project {
        
        let organizationName = "minsone"
        let settings = Settings(base: ["CODE_SIGN_IDENTITY": "",
                                       "CODE_SIGNING_REQUIRED": "NO"])
        
        let target1 = Target(name: name,
                             platform: platform,
                             product: product,
                             bundleId: "kr.minsone.\(name)",
                             deploymentTarget: deploymentTarget,
                             infoPlist: .extendingDefault(with: infoPlist),
                             sources: ["Sources/**"],
                             resources: ["Resources/**"],
                             dependencies: dependencies)
        
        let demoAppTarget = Target(name: "\(name)DemoApp",
                                   platform: platform,
                                   product: .app,
                                   bundleId: "kr.minsone.\(name)DemoApp",
                                   deploymentTarget: deploymentTarget,
                                   infoPlist: .extendingDefault(with: [
                                     "UIMainStoryboardFile": "",
                                     "UILaunchStoryboardName": "LaunchScreen"
                                   ]),
                                   sources: ["Demo/**"],
                                   resources: ["Demo/Resources/**"],
                                   dependencies: [
                                    .target(name: "\(name)")
                                   ])
        
        let testTargetDependencies: [TargetDependency] = hasDemoApp
            ? [.target(name: "\(name)DemoApp")]
            : [.target(name: "\(name)")]
        let testTarget = Target(name: "\(name)Tests",
                                platform: platform,
                                product: .unitTests,
                                bundleId: "kr.minsone.\(name)Tests",
                                deploymentTarget: deploymentTarget,
                                infoPlist: .default,
                                sources: "Tests/**",
                                dependencies: testTargetDependencies)

        let targets: [Target] = hasDemoApp
            ? [target1, testTarget, demoAppTarget]
            : [target1, testTarget]
        
        return Project(name: name,
                       organizationName: organizationName,
                       packages: packages,
                       settings: settings,
                       targets: targets,
                       schemes: schemes)
    }
}
EOF
```

**5.**  이제 프로젝트 파일을 생성합니다. 다음은 FeatureLoan의 UserInterface, Domain, DataRepository 프로젝트 파일을 생성하는 예제 코드입니다.

```
$ mkdir -p Projects/Features/FeatureLoan/UserInterface
$ touch Projects/Features/FeatureLoan/UserInterface/Project.swift
$ cat <<EOF >Projects/Features/FeatureLoan/UserInterface/Project.swift
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project
    .staticFramework(name: "FeatureLoanUserInterface",
                     dependencies: [
                        .Project.Feature.BaseDependency.UserInterface,
                     ])
EOF

$ mkdir -p Projects/Features/FeatureLoan/Domain
$ touch Projects/Features/FeatureLoan/Domain/Project.swift
$ cat <<EOF >Projects/Features/FeatureLoan/Domain/Project.swift
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project
    .staticFramework(name: "FeatureLoanDomain",
                     dependencies: [
                        .Project.Feature.BaseDependency.Domain,
                        .Project.Feature.Loan.UserInterface,
                     ])
EOF

$ mkdir -p Projects/Features/FeatureLoan/DataRepository
$ touch Projects/Features/FeatureLoan/DataRepository/Project.swift
$ cat <<EOF >Projects/Features/FeatureLoan/DataRepository/Project.swift
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project
    .staticFramework(name: "FeatureLoanDataRepository",
                     dependencies: [
                        .Project.Feature.BaseDependency.DataRepository,
                        .Project.Feature.Loan.Domain,
                     ])
EOF
```

**6.** 위와 같은 구조로 프로젝트를 파일을 생성한 후, `tuist generate`를 실행하면 각각의 프로젝트 파일과 워크스페이스 파일이 생성됩니다.

ps. Tuist로 프로젝트 구조 생성한 프로젝트는 [Github 저장소](https://github.com/minsOne/iOSApplicationTemplate)에 공개되어 있습니다. 모든 코드를 여기 글에 적지 못한 점 양해바랍니다.
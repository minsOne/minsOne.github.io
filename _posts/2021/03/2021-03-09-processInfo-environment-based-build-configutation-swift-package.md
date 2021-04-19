---
layout: post
title: "[Swift][SwiftPM] Swift Package - ProcessInfo Environment 기반 빌드 환경설정"
description: ""
category: "programming"
tags: [Swift, SPM, Swift Package Manager, Swift Package, Module, ProcessInfo]
---
{% include JB/setup %}

<div class="alert warning"><strong>주의</strong> : 본 글은 Swift Package Manager의 문서에 나와있는 방식이 아니므로 작업시 유의하시기 바랍니다.</div>

## Step 1 - Swift Package의 Custom Preprocessor

Swift Package는 기본적으로 그자체만으로도 동작해야 합니다. 그렇기 때문에 XCConfig 같은 Xcode에 의존하는 설정들은 사용할 수 없습니다. 

개발에서 다양한 환경에 배포를 하기 위해서는 많은 Preprocessor(DEV, TEST, QA, PROD 등)가 필요로 합니다. 따라서 Xcode에서 사용하던 Preprocessor를 Swift Package에 접목시키기는 불가능합니다.

하지만 예외로 처리할 수 있는 방법이 있습니다. 

먼저 다음과 같은 구조를 가진 프로젝트를 만듭니다.

<div class="mermaid"> 
graph LR;
    App-->ModuleA;
</div>

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/03/20210309_2.png" style="width: 800px"/>
</p><br/>


Swift Package인 ModuleA의 Package.swift 파일을 한번 살펴봅시다.

```
/// FileName: Package.swift

import PackageDescription

let package = Package(
    name: "ModuleA",
    products: [
        .library(
            name: "ModuleA",
            targets: ["ModuleA"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "ModuleA",
            dependencies: []),
        .testTarget(
            name: "ModuleATests",
            dependencies: ["ModuleA"]),
    ]
)
```

이 파일이 제대로 되었는지, 그리고 의존성이 맞는지를 확인하는 작업을 수행합니다. 이 작업은 Swift Package가 워크스페이스 또는 프로젝트에 추가되어 있을 때, 워크스페이스 또는 프로젝트 파일이 열렸을 때 등의 경우에 수행하는 Resolve Swift Packages 에서 검증합니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/03/20210309_3.png" style="width: 800px"/>
</p><br/>

이 파일에 print 함수를 한번 추가해봅시다.

```
/// FileName: Package.swift

import PackageDescription

let package = Package(
    name: "ModuleA",
    products: [
        .library(
            name: "ModuleA",
            targets: ["ModuleA"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "ModuleA",
            dependencies: []),
        .testTarget(
            name: "ModuleATests",
            dependencies: ["ModuleA"]),
    ]
)

print("Hello ModuleA Package")
```

그러면 Resolve Swift Packages 화면에 `Hello ModuleA Package` 값이 출력된 것을 확인할 수 있습니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/03/20210309_4.png" style="width: 800px"/>
</p><br/>

Resolve Swift Package에 임의의 로그를 남길 수 있음을 의미합니다.

다음으로 Apple의 Swift Package Manager 프로젝트의 [Package.swift](https://github.com/apple/swift-package-manager/blob/main/Package.swift#L321) 파일을 살펴보려고 합니다. 

하단에서 ProcessInfo의 environment 값을 이용하여 조건문을 활용하고 있음을 확인할 수 있습니다.

```
/// FileName: Package.swift

...

// Add package dependency on llbuild when not bootstrapping.
//
// When bootstrapping SwiftPM, we can't use llbuild as a package dependency it
// will provided by whatever build system (SwiftCI, bootstrap script) is driving
// the build process. So, we only add these dependencies if SwiftPM is being
// built directly using SwiftPM. It is a bit unfortunate that we've add the
// package dependency like this but there is no other good way of expressing
// this right now.
/// When not using local dependencies, the branch to use for llbuild and TSC repositories.
let relatedDependenciesBranch = "main"

if ProcessInfo.processInfo.environment["SWIFTPM_LLBUILD_FWK"] == nil {
    if ProcessInfo.processInfo.environment["SWIFTCI_USE_LOCAL_DEPS"] == nil {
        package.dependencies += [
            .package(url: "https://github.com/apple/swift-llbuild.git", .branch(relatedDependenciesBranch)),
        ]
    } else {
        // In Swift CI, use a local path to llbuild to interoperate with tools
        // like `update-checkout`, which control the sources externally.
        package.dependencies += [
            .package(path: "../llbuild"),
        ]
    }
    package.targets.first(where: { $0.name == "SPMLLBuild" })!.dependencies += ["llbuildSwift"]
}
```

ProcessInfo의 environment에 값을 넣을 수 있다면 위의 코드 처럼 ModuleA의 Package.swift에서 Preprocessor를 조건에 맞게 넣을 수 있지 않을까요?

[Swift Forum 글](https://forums.swift.org/t/how-to-switch-package-dependencies-in-xcode-after-deprecation-of-generate-xcodeproj/42130)에서 환경변수를 앞에 놓고 뒤에 코드를 두면 ProcessInfo의 environment에 값을 주입할 수 있음을 찾을 수 있습니다.

```
$ USE_ANOTHER_DEP=1 open Package.swift
```

실제로 주입한 환경변수 값이 출력되는지 확인해봅시다.

앞서 ModuleA의 Package.swift에 다음 코드를 추가합니다.

```
/// FileName: Package.swift

import PackageDescription
import Foundation

let package = Package(
    name: "ModuleA",
    products: [
        .library(
            name: "ModuleA",
            targets: ["ModuleA"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "ModuleA",
            dependencies: []),
        .testTarget(
            name: "ModuleATests",
            dependencies: ["ModuleA"]),
    ]
)

print(ProcessInfo.processInfo.environment)
```

그리고 BUILD_CONFIG 환경 변수에 DEV 라는 값을 넣어 워크스페이스 파일을 엽니다.

```
$ BUILD_CONFIG="DEV" open Workspace.xcworkspace
```

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/03/20210309_5.png" style="width: 800px"/>
</p><br/>

```
Showing All Messages
["BUILD_CONFIG": "DEV", "ITERM_SESSION_ID": "w0t6p0:14255DF6-DB82-4F04-9346-5322D2B74083", "USER": "minsone", "CA_DEBUG_TRANSACTIONS": "1", "COLORTERM": "truecolor", "PAGER": "less", "XPC_SERVICE_NAME": "application.com.apple.dt.Xcode.89111425.89156796", "LC_TERMINAL": "iTerm2", "XPC_FLAGS": "0x0", "LANG": "ko_KR.UTF-8", "SECURITYSESSIONID": "186bc", "TERM_PROGRAM": "iTerm.app", "OLDPWD": "/Users/minsone/Workspace/FileBasedConfigutationSwiftPackage/Module/ModuleA", "TERM": "xterm-256color", "LSCOLORS": "Gxfxcxdxbxegedabagacad", "dummy": "dummy", "__CF_USER_TEXT_ENCODING": "0x1F5:0x3:0x33", "PATH": "/Applications/Xcode.app/Contents/Developer/usr/bin:/Users/minsone/.rbenv/shims:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Apple/usr/bin", "COLORFGBG": "7;0", "_": "/usr/bin/open", "ITERM_PROFILE": "Default", "PackageConfigure": "DEV", "TERM_SESSION_ID": "w0t6p0:14255DF6-DB82-4F04-9346-5322D2B74083", "CA_ASSERT_MAIN_THREAD_TRANSACTIONS": "1", "PWD": "/Users/minsone/Workspace/FileBasedConfigutationSwiftPackage", "TMPDIR": "/var/folders/lx/9b77vhjn49j1q2t3jmqqh81c0000gn/T/", "SHELL": "/bin/zsh", "LaunchInstanceID": "594ACFAD-1BE4-42D5-956C-27A2DA0AD42C", "__CFBundleIdentifier": "com.apple.dt.Xcode", "NVM_DIR": "/Users/minsone/.nvm", "HOME": "/Users/minsone", "COMMAND_MODE": "unix2003", "LOGNAME": "minsone", "NVM_RC_VERSION": "", "SHLVL": "1", "NVM_CD_FLAGS": "-q", "LESS": "-R", "ZSH": "/Users/minsone/.oh-my-zsh", "SSH_AUTH_SOCK": "/private/tmp/com.apple.launchd.cQcS2rZu7M/Listeners", "MallocNanoZone": "0", "LC_TERMINAL_VERSION": "3.4.1", "TERM_PROGRAM_VERSION": "3.4.1", "RBENV_SHELL": "zsh"]
```

Resolve Swift Packages의 실행 로그에서 BUILD_CONFIG의 값이 DEV임을 확인할 수 있습니다.

ProcessInfo의 environment 값을 이용하여 특정 Preprocessor 설정을 할 수 있습니다.

ModuleA의 Package.swift는 BUILD_CONFIG 값에 따라 Preprocessor를 DEV, TEST, QA, PROD를 넣을 수 있습니다.

```
// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let package = Package(
    name: "ModuleA",
    products: [
        .library(
            name: "ModuleA",
            targets: ["ModuleA"]),
    ],
    dependencies: [
    ]
)


let moduleTarget: Target = .target(name: "ModuleA", dependencies: [])
let moduleTestsTarget: Target = .testTarget(name: "ModuleATests", dependencies: ["ModuleA"])

package.targets = [moduleTarget, moduleTestsTarget]

let config = ProcessInfo.processInfo.environment["BUILD_CONFIG"] ?? ""
print("ModuleA Environment Variable = \(config)\n.")

switch config {
case "DEV":
    moduleTarget.swiftSettings = [.define("DEV")]
case "TEST":
    moduleTarget.swiftSettings = [.define("TEST")]
case "QA":
    moduleTarget.swiftSettings = [.define("QA")]
case "PROD":
    moduleTarget.swiftSettings = [.define("PROD")]
default:
    print("Define : Nothing\n")
}

```

ModuleA.swift 파일에서도 Preprocessor로 분기 처리하여 어떻게 출력되는지 살펴봅시다.

```
/// FileName: ModuleA.swift

public struct ModuleA {
    public init() {
        print("==== Initilized ModuleA ====")
        #if DEV
        print("ModuleA - DEV")
        #elseif TEST
        print("ModuleA - TEST")
        #elseif QA
        print("ModuleA - QA")
        #elseif PROD
        print("ModuleA - PROD")
        #else
        print("ModuleA - Other")
        #endif
    }
}
```

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/03/20210309_6.png" style="width: 800px"/>
</p><br/>

ProcessInfo의 environment를 이용하여 기존 Xcode 프로젝트의 Preprocessor를 사용하는 것 처럼 동일하게 사용할 수 있음을 확인하였습니다.



## Step 2 - Multiple Swift Package

프로젝트가 커지면 많은 모듈이 필요하고, 많은 Swift Package가 동일한 환경변수를 기반으로 Preprocessor를 정의해야 합니다. 환경변수가 ModuleA는 QA를, ModuleB는 TEST를 바라보면 안됩니다.

하지만 ProcessInfo의 environment를 이용하면 모든 Swift Package가 동일한 값을 바라보게 됩니다.

다음과 같이 Diamond dependency 구조로 하려고 합니다.

<div class="mermaid"> 
graph LR;
    App-->ModuleA;
    ModuleA-->ModuleB-->ModuleD;
    ModuleA-->ModuleC-->ModuleD;
</div>

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/03/20210309_8.png" style="width: 800px"/>
</p><br/>


ModuleB, ModuleC, ModuleD의 Package.swift 파일에 ModuleA의 Package.swift 파일에서 ProcessInfo의 environment를 이용하여 Preprocessor를 정의하는 코드를 추가합니다.

그러면 Resolve Swift Packages 수행 후, 동일한 환경변수 값을 읽었다는 것을 확인할 수 있습니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/03/20210309_9.png" style="width: 800px"/>
</p><br/>

ModuleA의 ModuleA.swift 파일처럼 ModuleB, ModuleC, ModuleD의 소스파일에 Preprocessor로 분기하여 코드 작성합니다.

그리고 ModuleA.swift에서 ModuleB, ModuleC, ModuleD 를 생성하여 Preprocessor로 분기되었는지 확인합니다.

```
/// FileName: ModuleA.swift

import ModuleB
import ModuleC
import ModuleD

public struct ModuleA {
    public init() {
        print("==== Initilized ModuleA ====")
        #if DEV
        print("ModuleA - DEV")
        #elseif TEST
        print("ModuleA - TEST")
        #elseif QA
        print("ModuleA - QA")
        #elseif PROD
        print("ModuleA - PROD")
        #else
        print("ModuleA - Other")
        #endif
        
        _ = ModuleB()
        _ = ModuleC()
        _ = ModuleD()
    }
}

/// FileName: ModuleB.swift

public struct ModuleB {
    public init() {
        print("==== Initilized ModuleB ====")
        #if DEV
        print("ModuleB - DEV")
        #elseif TEST
        print("ModuleB - TEST")
        #elseif QA
        print("ModuleB - QA")
        #elseif PROD
        print("ModuleB - PROD")
        #else
        print("ModuleB - Other")
        #endif
    }
}

/// FileName: ModuleC.swift

public struct ModuleC {
    public init() {
        print("==== Initilized ModuleC ====")
        #if DEV
        print("ModuleC - DEV")
        #elseif TEST
        print("ModuleC - TEST")
        #elseif QA
        print("ModuleC - QA")
        #elseif PROD
        print("ModuleC - PROD")
        #else
        print("ModuleC - Other")
        #endif
    }
}

/// FileName: ModuleD.swift

public struct ModuleD {
    public init() {
        print("==== Initilized ModuleD ====")
        #if DEV
        print("ModuleD - DEV")
        #elseif TEST
        print("ModuleD - TEST")
        #elseif QA
        print("ModuleD - QA")
        #elseif PROD
        print("ModuleD - PROD")
        #else
        print("ModuleD - Other")
        #endif
    }
}
```

그리고 실행하면 다음과 같이 환경변수에 맞게 분기된 결과가 출력됨을 확인할 수 있습니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/03/20210309_10.png" style="width: 800px"/>
</p><br/>

### 참고자료

* [Apple - Swift Package Manager의 Package.swift](https://github.com/apple/swift-package-manager/blob/main/Package.swift#L321)
* [Swift Forums - Compilation conditions and swift packages](https://forums.swift.org/t/compilation-conditions-and-swift-packages/34627/4)
* [Swift Forums - How to switch package dependencies in Xcode after deprecation of ‘generate-xcodeproj’?](https://forums.swift.org/t/how-to-switch-package-dependencies-in-xcode-after-deprecation-of-generate-xcodeproj/42130/2)
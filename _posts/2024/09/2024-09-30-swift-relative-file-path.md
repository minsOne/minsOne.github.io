---
layout: post
title: "[Swift][Tuist] 파일 경로 간의 상대 경로 계산하기"
tags: [Swift, Tuist]
---
{% include JB/setup %}

Xcode의 프로젝트 파일의 빌드 세팅에서 해당 프로젝트 파일의 경로를 기준으로 상대 경로를 지정하는 것을 권장합니다. 이는, 모든 개발자가 동일한 개발 환경을 구성한다는 보장이 없기 때문입니다. 예를 들어, 특정 프레임워크의 위치를 절대 경로로 지정한다면, 모든 개발자, CI/CD 등의 모든 환경을 동일하게 구축해야하는데, 이는 불가능합니다. 따라서 상대 경로를 지정해주는 것이 좋습니다.

그러나, 상대 경로를 지정하는 것은 쉽지 않습니다. 프로젝트가 여러개 있는 경우, 각 프로젝트는 조금씩 다른 경로를 가질 수 있습니다.

```
Projects
ㄴ ABC
    ㄴ ABC
        ㄴ A
        ㄴ B
        ㄴ C
ㄴ DEF
    ㄴ D
    ㄴ E
    ㄴ F
```

따라서, 각 프로젝트 기준으로 특정 파일의 경로까지의 상대 경로를 계산하면 됩니다. 이를 위해서는 현재 파일의 위치를 알아야 합니다.

## 상대 경로 계산하기 

Swift에서는 `#file`를 이용하여 해당 파일이 있는 절대 경로를 얻을 수 있습니다.

```swift
print("#file: ", #file) // /Users/minsone/Developer/iOSApplication/iOS_App/Project.swift
```

`#file`의 값에서 뒤의 파일 이름을 제거하면 해당 파일이 있는 디렉토리의 경로를 얻을 수 있습니다.

```swift
let url = URL(fileURLWithPath: #file).deletingLastPathComponent()
print("url: ", url) // file:///Users/minsone/Developer/iOSApplication/iOS_App/
```

## 상대 경로 계산하기

Macro.macro 라는 파일의 경로를 얻으려고 합니다. `Macro.macro`의 절대 경로는 `/Users/minsone/Developer/iOSApplication/Projects/Macros/Macro/Macro.macro` 라고 가정해봅시다.

Tuist에서는 코드를 공유하는 모듈인 `ProjectDescriptionHelpers` 에서 `Macro.macro` 파일의 절대 경로를 만들어, 다른 파일들에서 상대 경로를 계산할 수 있도록 합니다.

```swift
// File : Tuist/ProjectDescriptionHelpers/FilePathURL.swift

import Foundation

public func macroPathURL() -> URL {
    URL(fileURLWithPath: #file) // #file: /Users/minsone/Developer/iOSApplication/Tuist/ProjectDescriptionHelpers/FilePath.swift
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appending(path: "Projects/Macros/Macro/Macro.macro")
    // Output : file:///Users/minsone/Developer/iOSApplication/Projects/Macros/Macro/Macro.macro
}
```

프로젝트 파일의 경로는 `/Users/minsone/Developer/iOSApplication/iOS_App/`, 찾으려는 Macro 파일의 경로는 `/Users/minsone/Developer/iOSApplication/Projects/Macros/Macro/Macro.macro` 입니다.

두 경로에서 상대 경로를 계산해봅시다.

```swift
let basePath = URL(fileURLWithPath: #file).deletingLastPathComponent()
let targetPath = macroPathURL()

if let relativePath = targetPath.relativePath(from: basePath) {
    print("Relative path: \(relativePath)") // Output: ../Projects/Macros/Macro/Macro.macro
} else {
    print("Cannot compute relative path.")
}

extension URL {
    /// 메소드는 두 경로 간의 공통 경로를 찾아 나머지 부분을 기반으로 상대 경로를 계산
    func relativePath(from base: URL) -> String? {
        // base와 target의 경로 컴포넌트를 추출
        let basePaths = base.standardized.pathComponents
        let targetPaths = standardized.pathComponents
        
        // 공통 경로의 끝 지점 찾기
        var commonIndex = 0
        while commonIndex < basePaths.count &&
              commonIndex < targetPaths.count &&
              basePaths[commonIndex] == targetPaths[commonIndex] {
            commonIndex += 1
        }
        
        // 공통 경로 이후의 남은 경로
        let backtrackPaths = Array(repeating: "..", count: basePaths.count - commonIndex)
        let remainingTargetPaths = targetPaths[commonIndex...]
        
        // 두 배열을 결합하여 상대 경로 반환
        return (backtrackPaths + remainingTargetPaths).joined(separator: "/")
    }
}
```

위의 코드를 이용하여 상대 경로를 얻을 수 있었습니다. 

그러면 Tuist를 활용하여 Xcode 프로젝트 파일의 Build Settings에서는 해당 프로젝트의 경로인 환경변수인 `PROJECT_DIR`, `xcodeproj` 파일이 있는 경로인 `SRCROOT`와 계산한 상대 경로를 합쳐 원하는 경로를 지정할 수 있습니다.

```swift
let pluginPath = "$(PROJECT_DIR)/\(relativePath)"
let settings: SettingsDictionary = [
    "OTHER_SWIFT_FLAGS": "$(inherited) -Xfrontend -load-plugin-executable \(pluginPath)#MacroPlugin"
]

let targets: Target = 
  .target(
    ...
    settings: .settings(base: settings)
  )

```

## 정리

* Tuist를 이용하여 프로젝트를 동적으로 생성하는 과정에서 해당 프로젝트와 특정 파일의 상대 경로를 계산할 수 있습니다.
---
layout: post
title: "[Swift 5.9][Xcode 15] Swift Package를 사용하지 않고 Swift의 Macros를 사용할 수 있을까? (2) - Prebuild Macro"
tags: [Swift, Macros]
---
{% include JB/setup %}

이번 글에서는 빌드 없이도 Macro를 사용할 수 있는 방법을 소개하겠습니다.

Swift Package에서는 Macro를 다음과 같이 정의합니다:

```swift
import PackageDescription
import CompilerPluginSupport
import Foundation

let package = Package(
    name: "MyMacro",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    ...
    targets: [
        .macro(
            name: "MyMacroMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        ...
```

첫 번째 단계로, `MyMacroMacros`를 빌드하여 `.build/arm64-apple-macosx/debug` 경로에 바이너리를 생성합니다.

```shell
$ swift build --product MyMacroMacros
```

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2023/12/04.png" style="border: 1px solid #555;"/></p><br/>

생성된 Macro 바이너리는 `-load-plugin-executable` 컴파일 옵션을 통해 사용할 수 있습니다.

이를 위해 `Command Line Tool`을 이용해 프로젝트를 생성하고, 이전에 생성한 `MyMacroMacros` 바이너리를 프로젝트 경로에 추가합니다.

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2023/12/05.png" style="border: 1px solid #555;"/></p><br/>

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2023/12/06.png" style="border: 1px solid #555;"/></p><br/>

다음으로, `Build Settings`의 `OTHER_SWIFT_FLAGS`에 `-load-plugin-executable` 옵션을 추가하고, 여기에 `MyMacroMacros` 모듈 경로를 지정합니다.

```
-load-plugin-executable ${SRCROOT}/MyCommand/MyMacroMacros#MyMacroMacros
```

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2023/12/07.png"/></p><br/>

소스코드에서는 `MyMacroMacros`의 `StringifyMacro`를 연결하고, 빌드 후 실행하여 정상적으로 결과가 출력되는지 확인합니다.

```swift
/// FileName : main.swift
import Foundation

@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "MyMacroMacros", type: "StringifyMacro")

let a = 17
let b = 25

let (result, code) = #stringify(a + b)

print("The value \(result) was produced by the code \"\(code)\"")
```

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2023/12/08.png"/></p><br/>

---

이제, Dynamic Framework에서 Macro를 정의하고 사용하는 방법을 살펴보겠습니다.

Macro를 모듈 간에 사용할 수 있도록 의존 관계를 구축합니다.

<div class="mermaid" style="display:flex;justify-content:center;"> 
graph TD;
    App-->ModuleA-->MacroKit;
</div>

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2023/12/09.png"/></p><br/><br/>

`MacroKit`에서 `MyMacroMacros`를 복사합니다. `Build Phases`에서 `Copy Files Phase`를 추가하여 `MyMacroMacros` 바이너리를 Build Production Directory에 추가하고, 이를 소스 코드 컴파일 이전에 복사되도록 설정합니다.

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2023/12/10.png"/></p><br/>

`MacroKit`의 `Build Settings`에서는 `OTHER_SWIFT_FLAGS`에 `-load-plugin-executable` 옵션을 추가하고, Macro 경로로 `${BUILT_PRODUCTS_DIR}/MyMacroMacros#MyMacroMacros`를 지정합니다.

```
OTHER_SWIFT_FLAGS = -load-plugin-executable ${BUILT_PRODUCTS_DIR}/MyMacroMacros#MyMacroMacros
```

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2023/12/15.png"/></p><br/>

다른 모듈에서도 Macro를 사용하기 위해서는, `MyMacroMacros` 바이너리의 경로를 지정해야 합니다. 빌드 시 `MyMacroMacros` 바이너리를 복사해두면, 다른 모듈에서 `${BUILT_PRODUCTS_DIR}`에 있는 경로를 쉽게 지정할 수 있습니다.

이어서, MacroKit 모듈에 `Marco.swift` 파일을 추가하고 매크로를 정의합니다.

```swift
/// Module : MacroKit
/// FileName : Macro.swift

import Foundation

@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "MyMacroMacros", type: "StringifyMacro")
```

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2023/12/11.png"/></p><br/>

FeatureA 모듈에서는 MacroKit 모듈을 추가하고, Build Settings에서 `-load-plugin-executable ${BUILT_PRODUCTS_DIR}/MyMacroMacros#MyMacroMacros` 옵션을 지정합니다. 이를 통해 FeatureA 모듈에서 MacroKit 모듈을 import하고 `stringify` 매크로를 사용할 수 있습니다.

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2023/12/12.png"/></p><br/>

```swift
import Foundation
import MacroKit

public struct ServiceA {
    public static func run() {
        let a = 17
        let b = 25
        
        let (result, code) = #stringify(a + b)
        
        print(#file, "The value \(result) was produced by the code \"\(code)\"")
    }
}
```

마지막으로, App에서도 MacroKit 모듈을 추가하고, Build Settings에서 `-load-plugin-executable ${BUILT_PRODUCTS_DIR}/MyMacroMacros#MyMacroMacros` 옵션을 지정합니다.

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2023/12/13.png"/></p>
<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2023/12/14.png"/></p><br/>

이제 App에서도 `stringify` 매크로를 사용할 수 있습니다.

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2023/12/16.png"/></p><br/>

이제 SampleApp을 실행하면, 콘솔에서 Macro가 성공적으로 실행되는 것을 확인할 수 있습니다.

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2023/12/17.png"/></p><br/>

이러한 방법을 통해, Swift Package뿐만 아니라 직접 Macro를 다루고 다른 모듈에서 쉽게 사용할 수 있는 방법을 알아보았습니다.

--- 

위 코드의 샘플은 [여기](https://github.com/minsOne/Experiment-Repo/tree/master/20231218)에서 확인하실 수 있습니다.
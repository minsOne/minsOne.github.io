---
layout: post
title: "[Swift 5.9][Xcode 15] Swift Package를 사용하지 않고 Swift의 Macros를 사용할 수 있을까? (3) - Prebuild Swift-Syntax"
tags: [Swift, Macros, Swift-Syntax, XCFramework]
---
{% include JB/setup %}

이번 글에서는 Macro에서 필요한 Swift-Syntax를 Prebuild하여 사용할 수 있는 방법을 소개합니다.

Macro를 쉽게 사용하기 위해서 Swift-Syntax가 필요합니다. 하지만 Swift-Syntax가 빌드하는데 오래 걸리기 때문에 미리 빌드된 Swift-Syntax를 사용하는 것을 고려해볼 수 있습니다.

이 글에서 사용하는 스크립트는 [GitHub - sjavora/swift-syntax-xcframeworks](https://github.com/sjavora/swift-syntax-xcframeworks)을 참고하였습니다.

## SwiftSyntaxWrapper.xcframework 생성

먼저, MyMacro 폴더를 생성한 후, 매크로 패키지를 생성합니다.

```shell
$ mkdir MyMacro && cd MyMacro
$ swift package init --type macro
```

다음으로, Swift-Syntax를 빌드하여 XCFramework를 만드는 쉘 스크립트 파일인 `swift_syntax_build.sh`를 생성합니다.

```shell
#!/bin/bash

SWIFT_SYNTAX_VERSION=$1
SWIFT_SYNTAX_NAME="swift-syntax"
SWIFT_SYNTAX_REPOSITORY_URL="https://github.com/apple/$SWIFT_SYNTAX_NAME.git"
SEMVER_PATTERN="^[0-9]+\.[0-9]+\.[0-9]+$"
WRAPPER_NAME="SwiftSyntaxWrapper"
ARCH="arm64"
CONFIGURATION="debug"

#
# Verify input
#

if [ -z "$SWIFT_SYNTAX_VERSION" ]; then
    echo "Swift syntax version (git tag) must be supplied as the first argument"
    exit 1
fi

if ! [[ $SWIFT_SYNTAX_VERSION =~ $SEMVER_PATTERN ]]; then
    echo "The given version ($SWIFT_SYNTAX_VERSION) does not have the right format (expected X.Y.Z)."
    exit 1
fi

#
# Print input
#

cat << EOF

Input:
swift-syntax version to build:  $SWIFT_SYNTAX_VERSION

EOF

set -eux

#
# Clone package
#

git clone --branch $SWIFT_SYNTAX_VERSION --single-branch $SWIFT_SYNTAX_REPOSITORY_URL

#
# Add static wrapper product
#

sed -i '' -E "s/(products: \[)$/\1\n    .library(name: \"${WRAPPER_NAME}\", type: .static, targets: [\"${WRAPPER_NAME}\"]),/g" "$SWIFT_SYNTAX_NAME/Package.swift"

#
# Add target for wrapper product
#

sed -i '' -E "s/(targets: \[)$/\1\n    .target(name: \"${WRAPPER_NAME}\", dependencies: [\"SwiftCompilerPlugin\", \"SwiftSyntax\", \"SwiftSyntaxBuilder\", \"SwiftSyntaxMacros\", \"SwiftSyntaxMacrosTestSupport\"]),/g" "$SWIFT_SYNTAX_NAME/Package.swift"

#
# Add exported imports to wrapper target
#

WRAPPER_TARGET_SOURCES_PATH="$SWIFT_SYNTAX_NAME/Sources/$WRAPPER_NAME"

mkdir -p $WRAPPER_TARGET_SOURCES_PATH

tee $WRAPPER_TARGET_SOURCES_PATH/ExportedImports.swift <<EOF
@_exported import SwiftCompilerPlugin
@_exported import SwiftSyntax
@_exported import SwiftSyntaxBuilder
@_exported import SwiftSyntaxMacros
EOF

#
# Build the wrapper
#

swift build --package-path $SWIFT_SYNTAX_NAME --arch $ARCH -c $CONFIGURATION -Xswiftc -enable-library-evolution -Xswiftc -emit-module-interface

#
# Create XCFramework
#

PATH_TO_LIBRARY="$SWIFT_SYNTAX_NAME/.build/$ARCH-apple-macosx/$CONFIGURATION/lib$WRAPPER_NAME.a"
XCFRAMEWORK_NAME="$WRAPPER_NAME.xcframework"
xcodebuild -create-xcframework -library $PATH_TO_LIBRARY -output $XCFRAMEWORK_NAME

MODULES=(
    "SwiftBasicFormat"
    "SwiftCompilerPlugin"
    "SwiftCompilerPluginMessageHandling"
    "SwiftDiagnostics"
    "SwiftIDEUtils"
    "SwiftOperators"
    "SwiftParser"
    "SwiftParserDiagnostics"
    "SwiftRefactor"
    "SwiftSyntax"
    "SwiftSyntaxBuilder"
    "SwiftSyntaxMacroExpansion"
    "SwiftSyntaxMacros"
    "SwiftSyntaxMacrosTestSupport"
    "_SwiftSyntaxTestSupport"
    "$WRAPPER_NAME"
)

for MODULE in ${MODULES[@]}; do
    PATH_TO_INTERFACE="$SWIFT_SYNTAX_NAME/.build/$ARCH-apple-macosx/${CONFIGURATION}/${MODULE}.build/${MODULE}.swiftinterface"
    cp "${PATH_TO_INTERFACE}" "${XCFRAMEWORK_NAME}/macos-${ARCH}"
done

rm -rf swift-syntax
mkdir -p XCFramework
mv SwiftSyntaxWrapper.xcframework XCFramework/SwiftSyntaxWrapper.xcframework
```

생성한 `swift_syntax_build.sh`를 실행하여 `SwiftSyntaxWrapper.xcframework`를 생성합니다.

```shell
$ sh swift_syntax_build.sh 509.0.2
$ ls XCFramework
SwiftSyntaxWrapper.xcframework
```

다음으로, Package.swift 파일에서 기존 swift-syntax 패키지를 XCFramework 폴더에 있는 `SwiftSyntaxWrapper.xcframework`로 교체합니다.

```swift
// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "MyMacro",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MyMacro",
            targets: ["MyMacro"]
        ),
        .executable(
            name: "MyMacroClient",
            targets: ["MyMacroClient"]
        ),
    ],
    dependencies: [],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "MyMacroMacros",
            dependencies: [
                .target(name: "SwiftSyntaxWrapper"),
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(name: "MyMacro", dependencies: ["MyMacroMacros"]),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(name: "MyMacroClient", dependencies: ["MyMacro"]),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "MyMacroTests",
            dependencies: [
                "MyMacroMacros",
                .target(name: "SwiftSyntaxWrapper"),
            ]
        ),
        .binaryTarget(name: "SwiftSyntaxWrapper", path: "XCFramework/SwiftSyntaxWrapper.xcframework")
    ]
)
```

이제 `swift build` 명령을 실행하여 빌드합니다.

```shell
$ swift build
Building for debugging...
[9/9] Linking MyMacroClient
Build complete! (5.69s)
```

시간이 5.69초 밖에 걸리지 않았습니다.

`swift run` 명령을 실행하여 Macro가 잘 동작하는지 확인해봅시다.

```shell
$ swift run
Building for debugging...
Build complete! (0.38s)
The value 42 was produced by the code "a + b"
```

우리가 원했던 결과가 출력되었습니다.

그러면 Xcode Project에서 Macro를 사용할 수 있는지 확인해봅시다.

## Xcode Project 적용

`MacroToolKit` 이라는 Dynamic Framework를 가진 애플리케이션 프로젝트를 생성합니다.

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2024/01/01.png"/></p><br/>

그리고 이전에 만들었던 `MyMacro` 패키지를 프로젝트에 추가하며, `MacroToolKit`에 `MyMacro`를 추가합니다.

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2024/01/02.png"/></p><br/>

이제 `MacroToolKit`을 의존하는 곳에서 `import MyMacro`를 추가하면, Macro를 쉽게 사용할 수 있습니다.

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2024/01/03.png"/></p><br/>

<br/>
이러한 방법을 통해, Swift Macro를 쉽게 사용할 수 있는 방법을 알아보았습니다.

---

위 코드의 샘플은 [여기](https://github.com/minsOne/Experiment-Repo/tree/master/20240110)에서 확인하실 수 있습니다.

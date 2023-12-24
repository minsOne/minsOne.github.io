---
layout: post
title: "[Swift 5.9][Xcode 15] Swift Package를 사용하지 않고 Swift의 Macros를 사용할 수 있을까? - 1"
tags: [Swift, Macros]
---
{% include JB/setup %}

Swift 5.9에서 새롭게 도입된 매크로는 현재 Swift 패키지를 통해서만 사용 가능합니다. 이 사실은 WWDC 2023에서 열린 [What’s new in Swift](https://developer.apple.com/videos/play/wwdc2023/10164/), [Expand on Swift macros](https://developer.apple.com/videos/play/wwdc2023/10167/), [Write Swift macros](https://developer.apple.com/videos/play/wwdc2023/10166) 세션들을 통해, 매크로가 Swift 패키지를 통해 사용되는 모습을 보여주며 확인할 수 있습니다. 현재로서는 Xcode 프로젝트 타겟에 직접 추가하는 방법은 제공되지 않습니다.

애플이 제안한 방식을 따를 경우, [apple/swift-syntax](https://github.com/apple/swift-syntax) 라이브러리에 의존해야 합니다. 이 라이브러리가 바이너리를 제공하지 않기 때문에, 매회 빌드 시 전체적인 빌드 시간이 증가하는 문제가 발생합니다.

Xcode 15를 사용하면 기본 Swift Macro 템플릿을 활용해 Swift Package를 쉽게 생성할 수 있습니다. 

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2023/12/01.png" style="border: 1px solid #555;"/></p><br/>

해당 템플릿으로 생성된 Swift Package로 클라이언트를 빌드할 경우, M1 에어를 기준으로 초기 빌드 시간은 약 23.2초가 소요됩니다.

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2023/12/02.png" style="border: 1px solid #555;"/></p><br/>

전체 빌드 시간에 Macro 사용으로 인해 23초가 추가되는 것은, 특히 CI나 UI Preview 확인 시 등 빠른 빌드가 필요한 환경에서 큰 제약으로 작용합니다. 이 문제를 해결하기 위해, swift-syntax 바이너리를 생성해 Macro와 연결한다면 빌드 시간을 단축할 수 있을 것입니다.

## -load-plugin-executable

Macro 소스를 살펴보겠습니다. 

```swift
@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "MyMacroMacros", 
                                                                      type: "StringifyMacro")
```

`stringify` 매크로는 `MyMacroMacros` 모듈 내의 `StringifyMacro` 타입을 활용합니다. 

`MyMacroMacros` 모듈의 의존성을 확인하기 위해, 해당 Swift Package의 `Package.swift`를 살펴보겠습니다.

```swift
let package = Package(
    name: "MyMacro",
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
     ]
)
```

여기서 `swift-syntax` 패키지를 사용하고 있음을 확인할 수 있습니다.

`MyMacro` 모듈로 돌아가 보겠습니다. 

이 모듈은 `Package.swift`에서 새로운 타겟 유형인 `macro`를 어떻게 연결하는지가 중요합니다.

빌드 로그를 살펴봅시다.

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2023/12/03.png" style="border: 1px solid #555;"/></p><br/>

빌드 로그를 통해 `MyMacroMacros` 모듈을 어떻게 포함하는지 확인할 수 있습니다. `-load-plugin-executable` 옵션을 사용해 `MyMacroMacros` 모듈 경로를 포함하는 것을 볼 수 있습니다.

```
-Xfrontend -load-plugin-executable -Xfrontend /Users/minsone/Library/Developer/Xcode/DerivedData/MyMacro-gbgoxackjnklrdefccvlgwrfzacs/Build/Products/Debug/MyMacroMacros\#MyMacroMacros
```

`MyMacroMacros`의 세부사항을 파악하기 위해, 먼저 `file` 명령을 사용해 파일 유형을 확인합니다.

```shell
$ file MyMacroMacros
MyMacroMacros: Mach-O 64-bit executable arm64
```

이 파일이 실행 파일임을 알 수 있습니다.

다음으로, `otool`을 이용해 어떤 동적 라이브러리를 의존하는지 확인해봅시다.

```shell
$ otool -L MyMacroMacros
MyMacroMacros:
	/System/Library/Frameworks/Foundation.framework/Versions/C/Foundation (compatibility version 300.0.0, current version 2202.0.0)
	/usr/lib/libobjc.A.dylib (compatibility version 1.0.0, current version 228.0.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1336.61.1)
	/usr/lib/libc++.1.dylib (compatibility version 1.0.0, current version 1600.157.0)
	/usr/lib/swift/libswiftCore.dylib (compatibility version 1.0.0, current version 5.9.2)
	/usr/lib/swift/libswiftCoreFoundation.dylib (compatibility version 1.0.0, current version 120.100.0, weak)
	/usr/lib/swift/libswiftDarwin.dylib (compatibility version 1.0.0, current version 0.0.0)
	/usr/lib/swift/libswiftDispatch.dylib (compatibility version 1.0.0, current version 34.0.2, weak)
	/usr/lib/swift/libswiftIOKit.dylib (compatibility version 1.0.0, current version 1.0.0, weak)
	/usr/lib/swift/libswiftOSLog.dylib (compatibility version 1.0.0, current version 4.0.0, weak)
	/usr/lib/swift/libswiftObjectiveC.dylib (compatibility version 1.0.0, current version 8.0.0, weak)
	/usr/lib/swift/libswiftXPC.dylib (compatibility version 1.0.0, current version 29.0.2, weak)
	/usr/lib/swift/libswiftos.dylib (compatibility version 1.0.0, current version 1040.0.0)
	/usr/lib/swift/libswiftFoundation.dylib (compatibility version 1.0.0, current version 1.0.0)
```

다음으로, `nm` 명령을 사용해 `swift-syntax` 라이브러리가 포함되어 있는지 확인합니다.

```shell
$ nm MyMacroMacros
...
00000001009399c4 T _$s11SwiftParser06TriviaB0V05parseC0_8positionSay0A6Syntax03RawC5PieceOGAF0F4TextV_AF0C8PositionOtFZ
000000010093b344 t _$s11SwiftParser06TriviaB0V05parseC0_8positionSay0A6Syntax03RawC5PieceOGAF0F4TextV_AF0C8PositionOtFZSbs7UnicodeO6ScalarVXEfU0_
000000010093b370 t _$s11SwiftParser06TriviaB0V05parseC0_8positionSay0A6Syntax03RawC5PieceOGAF0F4TextV_AF0C8PositionOtFZSbs7UnicodeO6ScalarVXEfU1_
...
00000001004c4c68 T _$s11SwiftSyntax010BorrowExprB0V016unexpectedBeforeC7KeywordAA015UnexpectedNodesB0VSgvM
00000001004c4cb0 t _$s11SwiftSyntax010BorrowExprB0V016unexpectedBeforeC7KeywordAA015UnexpectedNodesB0VSgvM.resume.0
00000001004c4810 T _$s11SwiftSyntax010BorrowExprB0V016unexpectedBeforeC7KeywordAA015UnexpectedNodesB0VSgvg
...
0000000100827444 T _$s16SwiftDiagnostics07GroupedB0V10SourceFileV11diagnosticsSayAA10DiagnosticVGvM
0000000100827454 t _$s16SwiftDiagnostics07GroupedB0V10SourceFileV11diagnosticsSayAA10DiagnosticVGvM.resume.0
00000001008273e4 T _$s16SwiftDiagnostics07GroupedB0V10SourceFileV11diagnosticsSayAA10DiagnosticVGvg
...
```

swift-syntax에서 사용하는 라이브러리가 포함되어 있는 것을 확인할 수 있습니다.

결론적으로, 우리는 `MyMacroMacros`와 같은 파일을 직접 만들거나 `swift-syntax` 관련 라이브러리를 `XCFramework`로 제공함으로써 빌드 시간을 줄일 수 있는 가능성이 있습니다. 다음 글에서는 이에 대한 구체적인 방법을 논의하겠습니다.

## 참고자료

* [Apple Swift Evolution - SE-0394 Package Manager Support for Custom Macros](https://github.com/apple/swift-evolution/blob/main/proposals/0394-swiftpm-expression-macros.md)
* GitHub
  * [jjrscott/SwiftCompilerPlugin](https://github.com/jjrscott/SwiftCompilerPlugin)
  * [ssly1997/MacrosDemo](https://github.com/ssly1997/MacrosDemo)
  * [chiragramani/SwiftMacroRepro](https://github.com/chiragramani/SwiftMacroRepro)
  * [sjavora/swift-syntax-xcframeworks](https://github.com/sjavora/swift-syntax-xcframeworks)
* Swift Forums
  * [How to import macros using methods other than SwiftPM](https://forums.swift.org/t/how-to-import-macros-using-methods-other-than-swiftpm)
  * [Macros and XCFrameworks](https://forums.swift.org/t/macros-and-xcframeworks)
* [How to import Swift macros without using Swift Package Manager](https://www.polpiella.dev/binary-swift-macros)
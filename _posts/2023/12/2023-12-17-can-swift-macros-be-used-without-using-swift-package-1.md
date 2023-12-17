---
layout: post
title: "[Swift 5.9][Xcode 15] Swift Package를 사용하지 않고 Swift의 Macros를 사용할 수 있을까? - 1"
tags: [Swift, Macros]
---
{% include JB/setup %}

Swift 5.9에서 공개된 Macro는 Swift Package로만 지원이 가능한 것으로 보입니다. 이는, WWDC 2023의 [What’s new in Swift](https://developer.apple.com/videos/play/wwdc2023/10164/), [Expand on Swift macros](https://developer.apple.com/videos/play/wwdc2023/10167/), [Write Swift macros](https://developer.apple.com/videos/play/wwdc2023/10166) 등의 세션에서 Swift Package를 통해서 사용하는 것을 보여주고 있으며, Xcode 프로젝트의 타겟으로는 추가하는 방법은 보여지지 않습니다.

애플이 보여준 방식대로 진행할 경우, [apple/swift-syntax](https://github.com/apple/swift-syntax) 라이브러리를 의존해야하고, swift-syntax에서 바이너리를 제공하지 않는 이상, 매번 빌드를 하여, 전체적인 빌드 시간이 증가됨을 의미합니다.

Xcode 15에서는 기본 Swift Macro 템플릿을 이용해 Swift Package를 생성할 수 있습니다.

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2023/12/01.png" style="border: 1px solid #555;"/></p><br/>

위의 템플릿으로 만든 Swift Package에서 Client를 빌드하면, 초기 빌드 시간은 23.2초(M1 에어 기준)입니다.

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2023/12/02.png" style="border: 1px solid #555;"/></p><br/>

Macro를 사용하기 위해 전체 빌드 시간에서 23초가 늘어나는 문제가 발생하였습니다.

빌드 시간이 늘어날수록, 빌드가 빨라야 가능한 환경들에서는 제약으로 발생합니다. 예를 들면, CI에서 23초 증가, UI의 Preview를 확인할 때 23초 증가하는 경우들이 있습니다.

결국 swift-syntax 바이너리를 만들어, Macro에 연결하여 사용할 수 있다면, 빌드 시간을 줄일 수 있지 않을까요?

## -load-plugin-executable

첫 번째로, Macro 소스를 살펴봅시다.

```swift
@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "MyMacroMacros", 
                                                                      type: "StringifyMacro")
```

`stringify` 매크로는 `MyMacroMacros` 라는 모듈에 `StringifyMacro` 타입을 사용합니다. 

그러면 `MyMacroMacros` 모듈을 살펴봅시다. Swift Package의 Package.swift를 열어 `MyMacroMacros`의 의존성을 살펴봅시다.

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

`MyMacroMacros`는 swift-syntax 패키지를 사용한다는 것을 확인할 수 있습니다.

다시 `stringify` 매크로가 정의된 모듈인 `MyMacro`로 돌아갑시다.

`MyMacro`는 Package.swift에서 새로운 타겟 유형인 `macro`를 어떻게 연결했을까요?

빌드 로그를 통해서 살펴봅시다.

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2023/12/03.png" style="border: 1px solid #555;"/></p><br/>

빌드 로그에서 빌드 옵션에서 `MyMacroMacros` 모듈을 어떻게 넣는지 살펴봅시다.

`MyMacroMacros`를 검색하면, `-load-plugin-executable` 옵션에 `MyMacroMacros` 모듈 경로를 넣는 것을 확인할 수 있습니다.

```
-Xfrontend -load-plugin-executable -Xfrontend /Users/minsone/Library/Developer/Xcode/DerivedData/MyMacro-gbgoxackjnklrdefccvlgwrfzacs/Build/Products/Debug/MyMacroMacros\#MyMacroMacros
```

`MyMacroMacros`가 어떤 것인지 살펴봅시다.

첫 번째로, `file` 명령을 이용하여 해당 파일 유형을 확인합니다.

```shell
$ file MyMacroMacros
MyMacroMacros: Mach-O 64-bit executable arm64
```

`MyMacroMacros`는 실행파일임을 확인하였습니다.

다음으로, 어떤 동적 라이브러리를 의존하는지 확인해봅시다.

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

다음으로, `nm` 명령을 통해 swift-syntax 라이브러리가 포함되어 있는지 확인해봅시다.

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

그러면, 우리는 `MyMacroMacros`와 같은 파일을 만들거나 swift-syntax 관련 라이브러리를 XCFramework로 제공할 수 있다면 빌드 시간을 줄일 수 있지 않을까요?

---

다음 편에서 빌드 시간을 줄일 수 있는 방법을 이야기하겠습니다.

## 참고자료

* GitHub
  * [jjrscott/SwiftCompilerPlugin](https://github.com/jjrscott/SwiftCompilerPlugin)
* [ssly1997/MacrosDemo](https://github.com/ssly1997/MacrosDemo)
* [chiragramani/SwiftMacroRepro](https://github.com/chiragramani/SwiftMacroRepro)
* [sjavora/swift-syntax-xcframeworks](https://github.com/sjavora/swift-syntax-xcframeworks)
* Swift Forums
  * [How to import macros using methods other than SwiftPM](https://forums.swift.org/t/how-to-import-macros-using-methods-other-than-swiftpm)
  * [Macros and XCFrameworks](https://forums.swift.org/t/macros-and-xcframeworks)
* [How to import Swift macros without using Swift Package Manager](https://www.polpiella.dev/binary-swift-macros)
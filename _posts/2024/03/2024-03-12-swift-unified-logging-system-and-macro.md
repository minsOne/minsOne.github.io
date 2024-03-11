---
layout: post
title: "[Swift][Xcode 15] 통합 로깅 시스템(Unified Logging System)과 Macro"
tags: [Swift, Xcode, Logger, Debug, Log, OSLog]
---
{% include JB/setup %}

Swift 통합 로깅 시스템(Unified Logging System)은 iOS, macOS, watchOS, tvOS 등 모든 Apple 플랫폼에서 일관되게 로그를 기록하고 관리하는 시스템입니다.

WWDC 2023의 ["Debug with structured logging" 세션](https://developer.apple.com/videos/play/wwdc2023/10226/)에서 콘솔 로그에 상세한 정보를 추가하는 방법을 소개하였습니다. 기존 print(), NSLog 등과 달리 구조화된 로그를 남길 수 있습니다.

<p style="text-align:center;"><img src="{{ site.prod_url }}/image/2024/03/01.png" style="border: 1px solid #555;"/></p><br/>

위 화면에서 콘솔 로그를 살펴보면 로그 레벨, 메시지 등을 표시하고, 오른쪽에는 Logger 호출 위치를 확인할 수 있으며, 화살표를 눌러 해당 코드로 이동할 수 있습니다. 이 기능은 로그 출력 위치를 빠르게 찾아 디버깅에 유용합니다.

하지만, 다음과 같이 Logger를 감싸서 호출하면 이 기능을 사용할 수 없게 됩니다.

```swift
import OSLog

struct WrapperLogger {
  func debug(msg: String) {
    let logger = Logger(subsystem: "kr.minsone.feature.logger", category: "debug")
    logger.log(level: .debug, "\(msg)")
  }
}

let logger = WrapperLogger()
logger.debug(msg: "Hello World")
```

<p style="text-align:center;"><img src="{{ site.prod_url }}/image/2024/03/02.png" style="border: 1px solid #555;"/></p><br/>

추상화된 코드 위치가 아닌 실제 Logger 호출 위치를 표시하고 있습니다. Xcode 15 버전에서는 이 문제를 해결할 수 있는 방법이 없습니다.

추상화하지 않는다면, 매번 Logger를 만들거나 전역으로 선언해야하는데, 이는 매 작업시 불편함을 유발하므로, 자동으로 코드를 만들어주는 방법이 필요합니다.

Xcode 15부터 Swift 5.9를 지원하고, Swift 5.9에서는 Swift Macro를 지원합니다. Swift Macro를 이용한다면 매번 작성해야하는 Logger를 생성하는 코드를 생성할 수 있지 않을까요?

## Swift Macro

Swift Macro에 `@attached(member)`를 사용하면 매크로를 적용하는 코드에 별도의 속성을 추가할 수 있습니다. 즉, `Logger`를 만들 수 있습니다.

Logger 생성 매크로를 만들어봅시다.

```swift
/// Module : LoggingMacros
/// FileName : LoggingMacro.swift

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

public struct LoggingMacro: MemberMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    in context: some MacroExpansionContext) throws -> [DeclSyntax] {        
        let allowTypes: [SyntaxKind] = [
          .classDecl,
          .structDecl,
          .actorDecl,
        ]

        guard allowTypes.contains(declaration.kind) else {
          let msg = "@Logger는 Class, Struct, Actor에만 사용 가능합니다."
          throw MacroExpansionErrorMessage(msg)
        }

        return [
          DeclSyntax(
            #"""
            lazy var logger: Logger = {
                LoggingMacroHelper.generateLogger(category: String(describing: Self.self))
            }()
            """#),
        ]
    }
}

/// Module : Logging
/// FileName : MemberMacros.swift

import Foundation
@_exported import OSLog

@attached(member, names: named(logger))
public macro Logging() = #externalMacro(module: "LoggingMacros", type: "LoggingMacro")

// MARK: - Helper

public enum LoggingMacroHelper {
  public static func generateLogger(_ fileID: String = #fileID, category: String) -> Logger {
    let subsystem = fileID.components(separatedBy: "/").first.map { "kr.minsone.\($0)" }
    return subsystem.map { Logger(subsystem: $0, category: category) }
        ?? Logger()
    }
}

```

위와 같이 매크로를 작성한 뒤, 다음과 같이 사용할 수 있습니다.

```swift
/// FileName : Example.swift

@Logging
class ABC {
    func sendLog() {
        logger.log(level: .debug, "\(Self.self) \(#function), log")
    }
}

ABC().sendLog() // Output : ABC sendLog(), log
```

<p style="text-align:center;"><img src="{{ site.prod_url }}/image/2024/03/03.png" style="border: 1px solid #555;"/></p><br/>

## 정리

* Swift Macro를 이용하여 Logger를 생성하고, 쉽게 사용할 수 있음

## 참고자료

* Apple
  * WWDC 2023 - [Debug with structured logging](https://developer.apple.com/videos/play/wwdc2023/10226/)

* GitHub
  * [JamesSedlacek/Logging](https://github.com/JamesSedlacek/Logging)
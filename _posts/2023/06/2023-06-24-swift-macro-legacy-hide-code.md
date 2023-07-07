---
layout: post
title: "[Swift 5.9+][Macros][리팩토링] Codable 이전 시대의 Response 코드를 Macros를 이용하여 정리하기"
tags: [Swift, Macros, SwifyJSON, Response, JSON]
---
{% include JB/setup %}

Swift4에서 Codable 프로토콜이 추가되었습니다. 그러나 그전에 개발하고 서비스하고 있던 서비스에서는 Codable로의 전환이 쉽지가 않습니다. 많은 Parameter, Response 타입을 전환하기에는 이미 코드가 잘 돌아가고 있고, Codable로의 전환하는데 비용이 꽤나 크기 때문입니다. 대신 새로운 서비스 등에서는 Codable을 적용할 수 있습니다.

Codable 이전에는 Response 정보를 파싱을 도와주는 ObjectMapper, SwiftyJSON 등을 이용하여 값을 만들었습니다.

```swift
/**
 {
 "title": "Init Response",
 "msg": "Hello World",
 "year_mm": "202306"
 }
 */

import SwiftyJSON

public protocol JSONResponse {
    var json: JSON { get }
    init(json: JSON)
}

public struct SomeResponse: JSONResponse {
    public let json: JSON

    public var title: String { json["title"].stringValue }
    public var msg: String { json["msg"].stringValue }
    public var yearMonth: String { json["year_mm"].stringValue }

    public init(json: JSON) { 
        self.json = json
    }
}
```

위와 같이 SwifyJSON을 활용하면 Codable 만큼은 아니지만, 코드를 나름 간결하게 만들 수 있습니다. 하지만 Codable에 비하면 불편한건 사실입니다.

## Macros

Swift 5.9 이전까지는 json을 접근하여 값을 가져오는 상용구 코드는 줄일 수 없습니다. WWDC 2023의 [Expand on Swift macros](https://developer.apple.com/videos/play/wwdc2023/10167/) 세션 중에 나온 예제가 위의 코드와 아주 유사하였습니다. 세션에 나온 예제와 비슷하게 작업하여 코드를 줄일 수 있을 것으로 추론해볼 수 있습니다.

Macros에 대해서는 WWDC에서 자세히 다루기 때문에 상세한 이야기는 생략하겠습니다.

위의 코드를 Macros를 활용하여 다음과 같이 코드를 줄일려고 합니다.

```swift
import SwiftyJSON

@ResponseInit
public struct SomeResponse {
    @ResponseJSON 
    public var title: String
    @ResponseJSON 
    public var msg: String
    @ResponseJSON(key: "year_mm") 
    public var yearMonth: String
}
```

그러면 Macros 코드를 작성해봅시다.

첫 번째로, `@ResponseInit` 매크로를 사용하면 `JSONResponse` 프로토콜을 준수하고 채택하도록 만들려고 합니다.

`ResponseInit` 매크로를 정의합니다.

```swift
/// Module : ResponseMacro
/// FileName : ResponseMacro.swift

@attached(member,
          names: named(init),
          named(json))
@attached(conformance)
public macro ResponseInit() = #externalMacro(module: "ResponseMacros", type: "ResponseInitMacro")
```

다음으로 `ResponseInitMacro` 를 구현합니다.

```swift
/// Module : ResponseMacros
/// FileName : ResponseInitMacro.swift

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ResponseInitMacro {}

extension ResponseInitMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let _ = declaration.as(StructDeclSyntax.self) else {
            throw CustomError.message("@ResponseInit can only be applied to a struct declarations.")
        }
        let access = declaration.modifiers?.first(where: \.isNeededAccessLevelModifier)
        return [
            "\(access)var json: JSON",
            "\(access)init(json: JSON) { self.json = json }",
        ]
    }
}

extension ResponseInitMacro: ConformanceMacro {
    public static func expansion(
        of attribute: AttributeSyntax,
        providingConformancesOf decl: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [(TypeSyntax, GenericWhereClauseSyntax?)] {
        return [("JSONResponse", nil)]
    }
}

enum CustomError: Error, CustomStringConvertible {
    case message(String)
    
    var description: String {
        switch self {
        case .message(let text):
            return text
        }
    }
}

extension DeclModifierSyntax {
    var isNeededAccessLevelModifier: Bool {
        switch self.name.tokenKind {
        case .keyword(.public): return true
        default: return false
        }
    }
}
```

`@ResponseInit` 매크로를 사용하여 다음 결과를 얻을 수 있습니다.

```swift
@ResponseInit
public struct SomeResponse {
    public var title: String = ""
    public var msg: String = ""
    public var yearMonth: String = ""
}

// Expand Macro

public struct SomeResponse {
    public var title: String = ""
    public var msg: String = ""
    public var yearMonth: String = ""
    public var json: JSON

    public init(json: JSON) {
        self.json = json
    }
}

extension SomeResponse : JSONResponse  {}
```

`@ResponseInit` 매크로를 이용하여 JSONResponse 프로토콜을 준수하고 채택하였음을 확인할 수 있습니다.<br/>

두 번째로, 각 변수들은 해당 이름이 키로 사용하거나, 지정된 키를 통해 json을 접근하여 값을 얻어오도록 만들어주는 `ResponseJSON` 매크로를 만들어봅시다.

```swift
/// Module : ResponseMacro
/// FileName : ResponseMacro.swift

@attached(accessor)
public macro ResponseJSON(key: String? = nil) = #externalMacro(module: "ResponseMacros", type: "ResponseJSONMacro")
```

다음으로 `ResponseJSONMacro` 를 구현합니다.

```swift
/// Module : ResponseMacros
/// FileName : ResponseJSONMacro.swift

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ResponseJSONMacro {}

extension ResponseJSONMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let property = declaration.as(VariableDeclSyntax.self),
              let binding = property.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
              let type = binding.typeAnnotation?.type,
              binding.accessor == nil
        else {
            return []
        }

        var key = identifier.text
        
        if case let .argumentList(arguments) = node.argument,
           let expression = arguments.first?.expression,
           let stringSegment = expression.as(StringLiteralExprSyntax.self)?.segments.first,
           case let .stringSegment(manualKey) = stringSegment {
            key = manualKey.content.text
        }

        let typeDesc = type.as(SimpleTypeIdentifierSyntax.self)?.description
        let jsonValueText: String = switch typeDesc {
        case "String": ".stringValue"
        case "Int": ".intValue"
        default: ""
        }
        let getAccessor: AccessorDeclSyntax =
      """
      get {
        json[\(literal: key)]\(raw: jsonValueText)
      }
      """
        
        return [getAccessor]
    }
}
```

`@ResponseJSON` 매크로를 사용하여 다음 결과를 얻을 수 있습니다.

```swift
public struct SomeResponse {
    @ResponseJSON 
    public var title: String
    @ResponseJSON 
    public var msg: String
    @ResponseJSON(key: "year_mm") 
    public var yearMonth: String
}

// Expand Macro

public struct SomeResponse {
    public var title: String
    {
        get {
          json["title"].stringValue
        }
    }
    public var msg: String
    {
        get {
          json["msg"].stringValue
        }
    }
    public var yearMonth: String
    {
        get {
          json["year_mm"].stringValue
        }
    }
}
```

다음으로, `ResponseInit`, `ResponseJSON` 매크로를 모두 적용한 결과입니다.

```swift
import SwiftyJSON

@ResponseInit
public struct SomeResponse {
    @ResponseJSON 
    public var title: String
    @ResponseJSON 
    public var msg: String
    @ResponseJSON(key: "year_mm") 
    public var yearMonth: String
}

// Expand Macro

public struct SomeResponse {
    public var title: String
    {
        get {
          json["title"].stringValue
        }
    }
    public var msg: String
    {
        get {
          json["msg"].stringValue
        }
    }
    public var yearMonth: String
    {
        get {
          json["year_mm"].stringValue
        }
    }
    public var json: JSON

    public init(json: JSON) {
        self.json = json
    }
}
extension SomeResponse : JSONResponse  {}
```

위의 코드는 [GitHub](https://github.com/minsOne/Experiment-Repo/tree/master/20230622-ResponseMacros)에서 확인하실 수 있습니다.

## 참고자료

* WWDC23
  * [Expand on Swift macros](https://developer.apple.com/videos/play/wwdc2023/10167/)
  * [Write Swift macros](https://developer.apple.com/videos/play/wwdc2023/10166/)

* GitHub
  * [DougGregor/swift-macro-examples](https://github.com/DougGregor/swift-macro-examples)

* [Swift AST Explorer](https://swift-ast-explorer.com/)
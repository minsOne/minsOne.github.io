---
layout: post
title: "[Swift 5.4+] SE-0289 ResultBuilder"
tags: [Swift, _functionBuilder, resultBuilder, NSAttributedString]
---
{% include JB/setup %}

## ResultBuilder

Swift 5.4에서 [SE-0289의 ResultBuilder](https://github.com/apple/swift-evolution/blob/main/proposals/0289-result-builders.md)가 도입되었습니다. 

이미 Swift 5.1에서 `_functionBuilder` 라는 이름으로 [구현되었으며](https://github.com/apple/swift/pull/33972), Swift 5.4에서 ResultBuilder라는 이름으로 사용되게 되었습니다. 지금은 `_functionBuilder` 을 사용하면 `resultBuilder`를 사용하라고 renamed warning을 띄워줍니다. [Code - ParseDecl.cpp](https://github.com/apple/swift/blob/d52dddc7c8448fc9529463bdeb32fbf6b221b5a6/lib/Parse/ParseDecl.cpp#L3249)

### Result Builder Type

Result Builder Type은 함수의 표현식-문에서 부분 결과를 수집하여 반환 값(return value)로 결합하기 위한 임베디드 DSL(Domain Specific Language) 입니다. 즉, 각 함수의 표현식-문의 결과를 모으고 조립하여 전체 결과를 반환합니다.

Property Wrapper인 `@resultBuilder` 를 추가하고 build 함수들을 구현하면 됩니다.

### Result Builder Attribute

* var 및 subscript의 경우 선언으로 getter를 정의
  * attribute는 해당 getter의 속성인 것처럼 처리
* attribute는 result builder transform 함수의 본문에 적용
* 프로토콜 요구사항의 매개변수를 포함하여 함수 타입의 매개변수의 속성으로 사용될 수 있음

### Result Builder Methods

* Result Build Type에서 호출할 수 있는 `static` 메소드
  * `BuilderType.<methodName>(<arguments>)`

* `Expression`은 표현식-문(expression-statement)가 가질 수 있는 모든 타입(즉, 원시 부분 결과)
* `Component`는 부분 또는 결합된 결과가 가질 수 있는 타입
* `FinalResult`을 변환된 함수에서 최종 반환된 타입

```swift
@resultBuilder
struct ExampleResultBuilder {
  /// 변환된 함수의 개별 명령문 표현식 타입, buildExpression()이 제공되지 않으면 기본값은 Component
  typealias Expression = ...

  /// 모든 빌드 메소드를 통해 전달되는 부분 결과 타입
  typealias Component = ...

  /// 최종 반환되는 결과의 타입, buildFinalResult()를 제공되지 않으면 기본값은 Component
  typealias FinalResult = ...

  /// 모든 result builder가 명령문 block에 결합된 결과를 빌드하는데 필요합니다.
  static func buildBlock(_ components: Component...) -> Component { ... }

  /// 선언되면, 명령문 표현식에 컨텍스트 타입 정보를 제공하여 부분 결과로 변환합니다.
  static func buildExpression(_ expression: Expression) -> Component { ... }

  /// `else`가 없는 `if`문 사용 가능합니다.
  static func buildOptional(_ component: Component?) -> Component { ... }

  /// With buildEither(second:), enables support for 'if-else' and 'switch'
  /// statements by folding conditional results into a single result.
  /// buildEither(second:)를 사용하여 folding conditional results의 'if-else'와 'switch' 문을 single result로 지원 가능합니다.
  static func buildEither(first component: Component) -> Component { ... }

  /// With buildEither(first:), enables support for 'if-else' and 'switch'
  /// statements by folding conditional results into a single result.
  /// buildEither(first:)를 사용하여 folding conditional results의 'if-else'와 'switch' 문을 single result로 지원 가능합니다.
  static func buildEither(second component: Component) -> Component { ... }

  /// 모든 반복 결과를 단일 결과로 결합하는 'for..in' 루프 지원 가능합니다
  static func buildArray(_ components: [Component]) -> Component { ... }

  /// 선언되면 result builder가 타입 정보를 지울 수 있도록 'if #available' 블록의 부분 결과에서 호출됩니다.
  static func buildLimitedAvailability(_ component: Component) -> Component { ... }

  /// 선언되면 최종 반환 결과를 생성하도록 가장 바깥쪽 블록문의 부분 결과에서 호출됩니다.
  static func buildFinalResult(_ component: Component) -> FinalResult { ... }
}
```

### Example

resultBuilder를 이용하여 NSAttributedString을 만들어봅시다.

NSAttributedString에 사용하는 속성들을 우리가 쉽게 사용하기 위해 enum으로 만들 수 있습니다. [예전 글 - StringInterpolation, StringInterpolationProtocol, 그리고 NSAttributedString]({{ site.production_url }}/programming/swift-stringinterpolation)

```swift
public struct Style {
    public enum Attribute {
        case font(UIFont)
        case color(UIColor)
        case backColor(UIColor)
        
        var key: NSAttributedString.Key {
            switch self {
            case .font: return .font
            case .color: return .foregroundColor
            case .backColor: return .backgroundColor
            }
        }
        
        var value: Any {
            switch self {
            case let .font(font): return font
            case let .color(color): return color
            case let .backColor(color): return color
            }
        }
    }
    
    var attrs: [Attribute] = []
    
    public func font(_ font: UIFont) -> Style {
        return set(.font(font))
    }
    
    public func color(_ fgColor: UIColor) -> Style {
        return set(.color(fgColor))
    }
    
    public func backColor(_ bgColor: UIColor) -> Style {
        return set(.backColor(bgColor))
    }
    
    private func set(_ attr: Attribute) -> Style {
        var new = self
        new.attrs.append(attr)
        return new
    }
    
    func apply(to text: String) -> NSAttributedString {
        let attributes = attrs.reduce([NSAttributedString.Key : Any]()) { (result, attr) in
            var result = result
            result.updateValue(attr.value, forKey: attr.key)
            return result
        }
        return NSAttributedString(string: text, attributes: attributes)
    }
}
```

그리고 Component를 NSAttributedString로 속성을 가지는 타입을 가지며, FinalResult를 NSAttributedString인 `resultBuilder`를 만들어봅시다.

```swift
public protocol RichTextComponent {
    var attributedString: NSAttributedString { get }
}

@resultBuilder
public struct AttributedStringBuilder {
    public typealias Component = RichTextComponent
    public typealias FinalResult = NSAttributedString
    
    private struct RText: RichTextComponent {
        let attributedString: NSAttributedString
    }
    private struct REmpty: RichTextComponent {
        let attributedString: NSAttributedString = .init(string: "")
    }

    public static func buildBlock() -> [Component] {
        return []
    }

    public static func buildBlock(_ components: Component...) -> Component {
        let attr = NSMutableAttributedString(string: "")
        components.forEach { attr.append($0.attributedString) }
        return RText(attributedString: attr)
    }
    
    public static func buildEither(first component: Component) -> Component {
        component
    }
    
    public static func buildEither(second component: Component) -> Component {
        component
    }
    
    public static func buildArray(_ components: [Component]) -> Component {
        let attr = NSMutableAttributedString(string: "")
        components.forEach { attr.append($0.attributedString) }
        return RText.init(attributedString: attr)
    }
    
    public static func buildOptional(_ component: Component?) -> Component {
        return component ?? REmpty()
    }
    
    public static func buildFinalResult(_ component: Component) -> FinalResult {
        return component.attributedString
    }
}

public extension NSAttributedString {
    convenience init(@AttributedStringBuilder content: () -> NSAttributedString) {
        self.init(attributedString: content())
    }
}
```

우리는 Style을 이용하여 String에 Style를 적용하여 NSAttributedString를 만들도록 해야하며, RichTextComponent 프로토콜을 따르도록 하는 타입을 만들어야 합니다.

```swift
public struct RichText: RichTextComponent {
    public let text: String
    public let style: Style
    public var attributedString: NSAttributedString { style.apply(to: text) }
    public init(text: String, style: Style) {
        self.text = text
        self.style = style
    }
}
```

이제 AttributedStringBuilder를 이용하여 NSAttributedString를 만들어봅시다.

```swift
let attr = NSAttributedString(content: {
    RichText(text: "Hello ", style: Style().font(.systemFont(ofSize: 14)).color(.systemCyan))
    switch true {
    case true:
        RichText(text: "True", style: Style().font(.systemFont(ofSize: 14)).color(.systemBlue))
    case false:
        RichText(text: "False", style: Style().font(.systemFont(ofSize: 14)).color(.systemBlue))
    }
    if let value = Int?(2022) {
        RichText(text: ", \(value) World", style: Style().font(.systemFont(ofSize: 14)).color(.systemRed))
    }
})

print(attr)
/**
Hello {
    NSColor = "<UIDynamicSystemColor: 0x600002dac800; name = systemCyanColor>";
    NSFont = "<UICTFont: 0x14b1078a0> font-family: \".SFUI-Regular\"; font-weight: normal; font-style: normal; font-size: 14.00pt";
}True{
    NSColor = "<UIDynamicSystemColor: 0x600002de8980; name = systemBlueColor>";
    NSFont = "<UICTFont: 0x14b1078a0> font-family: \".SFUI-Regular\"; font-weight: normal; font-style: normal; font-size: 14.00pt";
}, 2022 World{
    NSColor = "<UIDynamicSystemColor: 0x600002dae240; name = systemRedColor>";
    NSFont = "<UICTFont: 0x14b1078a0> font-family: \".SFUI-Regular\"; font-weight: normal; font-style: normal; font-size: 14.00pt";
}
 */
```

그리고 다음과 같이 NSAttributedString가 보여지게 됩니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2022/04/20220424_01.png"/></p>

## 참고자료

* [Apple - SE-0289 ResultBuilder](https://github.com/apple/swift-evolution/blob/main/proposals/0289-result-builders.md)
* [StringInterpolation, StringInterpolationProtocol, 그리고 NSAttributedString]({{ site.production_url }}/programming/swift-stringinterpolation)
* [Github - muukii/MondrianLayout](https://github.com/muukii/MondrianLayout)
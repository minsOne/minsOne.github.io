---
layout: post
title: "[Swift5] StringInterpolation, StringInterpolationProtocol, 그리고 NSAttributedString"
description: ""
category: "Programming"
tags: [Swift, NSAttributedString, StringInterpolation, StringInterpolationProtocol]
---
{% include JB/setup %}

## StringInterpolation

Swift 5에서는 [SE-0228](https://github.com/apple/swift-evolution/blob/master/proposals/0228-fix-expressiblebystringinterpolation.md)의 StringInterpolation 확장이 추가되었습니다.

Swift 5 이전에는 `"\("Hello world")"` 와 같이 값을 넣는 방법만 되었지만 Swift 5 이후에는 `"\(10000, style: .won)"` 같이 확장이 가능합니다. 다음과 같이 코드를 작성하면 말이죠.

```
enum Style {
    case won
}
extension String.StringInterpolation {
    mutating func appendInterpolation(_ amount: Int, style: Style) {
        switch style {
            case .won: appendLiteral("\(amount)원")
        }
    }
}

print("\(10000, style: .won)")
/// Output: 10000원
```

값을 미리 가공해서 넣는 것이 아니라 StringInterpolation를 이용해서 쉽게 값 표시를 변경할 수 있습니다. 하지만 자동완성이 되질 않아 사용하기 위해서는 외워야하는 문제가 있습니다.

StringInterpolation을 이용하여 위와 같은 방법도 있지만 `StringInterpolationProtocol`를 이용해서 우리가 원하는 타입도 만들 수 있습니다.

## StringInterpolationProtocol, ExpressibleByStringInterpolation

String의 StringInterpolation 타입을 StringInterpolationProtocol를 이용하여 직접 구현이 가능합니다.

```
struct StringInterpolation: StringInterpolationProtocol {
    enum Style {
        case won
    }
    var str: String
    
    /// 초기화
    ///
    /// - Parameters:
    ///   - literalCapacity: 문자열 용량/길이
    ///   - interpolationCount: 문자열 보간 개수
    init(literalCapacity: Int, interpolationCount: Int) {
        self.str = ""
    }
    
    mutating func appendLiteral(_ literal: String) {
        str += literal
    }
    
    mutating func appendInterpolation(_ amount: Int, style: Style) {
        switch style {
            case .won: appendLiteral("\(amount)원")
        }
    }
}
```

직접 구현한 `StringInterpolation` 타입은 `ExpressibleByStringInterpolation`을 따르는 타입에서 사용할 수 있습니다.

```
struct WonStyleString {
    var str = ""
}

extension WonStyleString: ExpressibleByStringInterpolation {
    init(stringLiteral: String) {
        self.str = stringLiteral
    }

    init(stringInterpolation: StringInterpolation) {
        self.str = stringInterpolation.str
    }
}

let styleStr: WonStyleString = """
\(10000, style: .won)
\(20000, style: .won)
"""
print(styleStr.str)
/// Output: 10000원\n20000원
```

문자열 보간을 이용하여 임의로 만든 타입으로 값을 만드는 것을 확인했습니다. 그러면 이것을 좀 더 이용하여 iOS에서 귀찮은 작업 중 하나인 `NSAttributedString`을 `StringInterpolation`으로 좀 더 쉽게 만드는 것을 해봅시다.

## NSAttributedString

`StringInterpolation`을 만들고, 속성으로 `NSMutableAttributedString`를 가지도록 합니다. 그리고 문자열이 들어올때마다 `NSMutableAttributedString`를 만들어서 추가하도록 합니다.

```
public struct StringInterpolation: StringInterpolationProtocol {
    public var attributedString: NSMutableAttributedString

    public init(literalCapacity: Int, interpolationCount: Int) {
        self.attributedString = NSMutableAttributedString()
    }

    public mutating func appendLiteral(_ literal: String) {
        attributedString.append(NSAttributedString(string: literal))
    }

    public func appendInterpolation(_ string: String, attributes: [NSAttributedString.Key: Any]) {
        let attr = NSAttributedString(string: string, attributes: attributes)
        self.attributedString.append(attr)
    }
}
```

`ExpressibleByStringInterpolation` 프로토콜을 따르는 타입이 `StringInterpolation`을 통해 최종적으로 `NSMutableAttributedString`타입인 값을 얻을 수 있습니다.

```
public struct AttrString {
    let attributedString: NSAttributedString
}

extension AttrString: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        self.attributedString = NSAttributedString(string: stringLiteral)
    }
}

extension AttrString: ExpressibleByStringInterpolation {
    public init(stringInterpolation: StringInterpolation) {
        self.attributedString = NSAttributedString(attributedString: stringInterpolation.attributedString)
    }
}
```

이제 AttrString을 이용하여 쉽게 NSAttributedString을 얻을 수 있습니다.

```
let attr: AttrString = """
\("Hello", attributes: [.foregroundColor: UIColor.blue]))
"""
let attrString = attr.attributedString
```

## Style을 이용한 NSAttributedString 만들기

NSAttributedString에 사용하는 속성들을 우리가 쉽게 사용하기 위해 enum으로 만들 수 있습니다.

```
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
        return set(.color(bgColor))
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

이제 이전에 작성했던 StringInterpolation의 `func appendInterpolation(_ string: String, attributes: [NSAttributedString.Key: Any])` 함수의 attributed를 Style로 대체할 수 있습니다.

```
public struct StringInterpolation: StringInterpolationProtocol {
    ...

    public func appendInterpolation(_ string: String, style: Style) {
        let attr = style.apply(to: string)
        self.attributedString.append(attr)
    }

    ...
}
```

그러면 AttrString은 다음과 같이 사용할 수 있습니다.

```
let richText: AttrString = """
\("Hello world", style: Style().font(.systemFont(ofSize: 15)).color(.red).backColor(.blue))
\("Good Bye", style: Style().font(.systemFont(ofSize: 20)).color(.green).backColor(.gray))
"""

label.attributedText = richText.attributedString
```

## 참고자료

* [MSDN - 문자열보간](https://docs.microsoft.com/ko-kr/dotnet/csharp/language-reference/tokens/interpolated)
* [Wikipedia - 문자열보간](https://en.wikipedia.org/wiki/String_interpolation)
* [HackingWithSwift - 문자열보간](https://www.hackingwithswift.com/articles/178/super-powered-string-interpolation-in-swift-5-0)
* [HackingWithSwift - Swift 5.0 변경사항](https://www.hackingwithswift.com/articles/126/whats-new-in-swift-5-0)
* [alisoftware - 문자열보간](http://alisoftware.github.io/swift/2018/12/16/swift5-stringinterpolation-part2/)
* [Apple - Swift SE-0228 문자열보간 제안서](https://github.com/apple/swift-evolution/blob/master/proposals/0228-fix-expressiblebystringinterpolation.md)
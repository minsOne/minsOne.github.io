---
layout: post
title: "[Swift 5] StringInterpolation, StringInterpolationProtocol, 그리고 NSAttributedString"
description: ""
category: ""
tags: []
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


## 참고자료

https://docs.microsoft.com/ko-kr/dotnet/csharp/language-reference/tokens/interpolated
https://en.wikipedia.org/wiki/String_interpolation
https://www.hackingwithswift.com/articles/178/super-powered-string-interpolation-in-swift-5-0
http://alisoftware.github.io/swift/2018/12/16/swift5-stringinterpolation-part2/
https://www.hackingwithswift.com/articles/126/whats-new-in-swift-5-0
https://github.com/apple/swift-evolution/blob/master/proposals/0228-fix-expressiblebystringinterpolation.md
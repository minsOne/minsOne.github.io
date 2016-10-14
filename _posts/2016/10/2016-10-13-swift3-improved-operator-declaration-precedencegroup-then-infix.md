---
layout: post
title: "[Swift3]향상된 연산자 선언 - precedencegroup"
description: ""
category: "programming"
tags: [swift, precedence, precedencegroup, precedence group, associativity]
---
{% include JB/setup %}

Xcode 8로 Swift 자료를 만들다가 연산자 선언 관련해 기존 방법을 사용하지 말고 `precedence group`을 사용하여 선언하라고 경고 메시지를 보고 Swift 3 제안서를 살펴보았습니다. 그리고 연산자 선언 관련한 제안서 [SE-0077: Improved operator declarations](https://github.com/apple/swift-evolution/blob/master/proposals/0077-operator-precedence.md)를 찾았습니다.

Swift 2까지 사용하던 연산자 선언 방법은 다음과 같습니다.

```Swift
infix operator <> { precedence 100 associativity left }
```

Swift 3에서는 `precedencegroup`를 사용하여 어떤 속성을 가질 것인지 정의합니다.

```Swift
precedencegroup ComparisonPrecedence {
  associativity: left
  higherThan: LogicalConjunctionPrecedence
}
infix operator <> : ComparisonPrecedence
```

이렇게 변경된 이유는 `precedence` 값이 100, 110, 120, 130으로 지정하는데 명확하지 않기 때문입니다. 새로운 연산자를 선언할 때, 값 132로 지정할 수 있습니다. 다른 새로운 연산자를 선언할 때 값 131로 지정할 수 있는데, 식을 어떻게 사용하느냐에 따라 값이 예상치 못한 값을 얻을 수 있습니다.

다음 예제에서 임의의 연산자를 선언하는 방법을 확인할 수 있습니다.

```Swift
precedencegroup Multiplicative {
    associativity: left
    higherThan: AdditionPrecedence
}

precedencegroup Exponentiative {
    associativity: left
    higherThan: Multiplicative
}

infix operator ** : Exponentiative

func **(lhs: Int, rhs: Int) -> Int {
    return Int(pow(Double(lhs), Double(rhs)))
}

// Output : 9
print(1 + 2 ** 3)
```

위의 코드에서 `higherThan`와 `lowerThan`는 지정한 Precedence group 보다 우선순위가 높거나 낮다고 설정합니다. 

`+` 연산자는 AdditionPrecedence 그룹이며, 새로운 Precedence 그룹인 Multiplicative보다 우선순위가 낮다고 지정합니다. `**` 연산자는 Exponentiative 그룹이며, Exponentiative 그룹은 Multiplicative 그룹보다 우선순위가 높습니다. 따라서 `1 + 2 ** 3`은 `1 + (2 ** 3)`과 같이 식이 성립합니다.

<br/>
더 자세히 살펴보려면 제안서 [SE-0077: Improved operator declarations](https://github.com/apple/swift-evolution/blob/master/proposals/0077-operator-precedence.md)와 [Swift Documentation](https://developer.apple.com/library/prerelease/content/documentation/Swift/Conceptual/Swift_Programming_Language/Declarations.html#//apple_ref/doc/uid/TP40014097-CH34-ID550)을 참고하시기 바랍니다.
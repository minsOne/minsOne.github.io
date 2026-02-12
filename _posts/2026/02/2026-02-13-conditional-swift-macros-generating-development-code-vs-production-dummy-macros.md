---
layout: post
title: "[Swift][Macro] 환경별 Swift 매크로 분기 처리: 환경에 따라 다른 매크로 호출"
tags: [Swift, Macro, Conditional Compilation, Build Configuration]
---
{% include JB/setup %}

Swift 매크로를 사용하다보면 개발 환경에서 생성된 코드가 운영 환경에서는 불필요한 경우가 발생할 수 있습니다. 특정 Protocol을 구현한 Mock 객체를 생성하는 매크로를 사용한다고 가정해봅시다. [swift-spyable](https://github.com/Matejkob/swift-spyable), [Mockable](https://github.com/Kolos65/Mockable) 등의 매크로를 이용해서 Mock 객체를 쉽게 생성할 수 있습니다.

이들 매크로의 코드는 전처리기를 이용해서 `#if DEBUG ... #endif` 구문을 사용해서 개발 환경에서만 생성되도록 할 수 있습니다.

```swift
@Mockable
protocol MyService {
    func doSomething()
}

#if DEBUG
final class MyServiceMock: MyService {
    var doSomethingCallCount = 0
    func doSomething() {
        doSomethingCallCount += 1
    }
}
#endif
```

하지만 이러한 방식은 생성된 매크로 코드를 다른 모듈에서 인식을 할 수 없는 단점이 있습니다.(예: Mock 객체를 다른 모듈에서 사용해야 하는 경우, 인식이 되지 않음. 단순 코드 작성하면 동작하나, 자동완성이 되지 않음.)

개발 환경에서는 생성된 코드를 통해 테스트를 진행하고, 운영 환경에서는 코드가 생성되지 않도록 하는 방법은 없을까요?

## 매크로 인터페이스 분기 처리

매크로 템플릿을 통해 생성하면 기본 매크로인 `stringify` 를 만들 수 있습니다.

```swift
@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) =
    #externalMacro(module: "MyMacroMacros", type: "StringifyMacro")
```

외부에서는 매크로를 호출하지만, 실제로는 매크로 모듈의 매크로를 호출하는 방식입니다. 즉, 여기서는 매크로 모듈에 전처리기를 이용해서 분기 처리를 할 수 있습니다.

```swift
#if DEBUG

@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = 
    #externalMacro(module: "MyMacroMacros", type: "StringifyMacro")

#else

@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = 
    #externalMacro(module: "MyMacroMacros", type: "DummyMacro")

#endif
```

이와 같이 매크로 인터페이스를 분기 처리하면, 환경에 관계없이 동일하게 매크로를 호출할 수 있습니다.

### DummyMacro의 역할

여기서 `DummyMacro`는 운영 환경에서 매크로가 불필요한 작업을 수행하지 않도록 설계합니다. 예를 들어, `stringify` 매크로의 경우 `DummyMacro`는 단순히 입력받은 값을 그대로 반환하기만 하도록 구현할 수 있습니다.

```swift
// MyMacroMacros/DummyMacro.swift
public struct DummyMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        // 단순히 입력 인자를 그대로 반환하거나 결과값만 전달
        return "\(node.argumentList.first!.expression)"
    }
}
```

이렇게 하면 운영 환경의 바이너리에는 복잡한 Mock 생성 로직이나 디버깅용 코드가 포함되지 않으며, 매크로 확장으로 인한 빌드 시간 오버헤드도 최소화할 수 있습니다.

## 결론: 관심사의 분리와 깔끔한 코드

이 방식의 핵심 이점은 다음과 같습니다.

1. **관심사의 분리**: 매크로를 사용하는 쪽에서 `#if DEBUG`를 일일이 관리할 필요가 없습니다. 환경에 따른 동작 결정은 매크로 인터페이스 정의 단계에서 한 번만 처리됩니다.
2. **깨끗한 코드**: 호출부 코드가 복잡해지지 않아 가독성이 높아지고 유지보수가 쉬워집니다.
3. **DX(개발 경험) 향상**: 모듈 간 참조 시 발생하는 인식 문제나 자동완성 누락 문제를 매크로 수준에서 해결하여 더 쾌적한 개발 환경을 제공합니다.


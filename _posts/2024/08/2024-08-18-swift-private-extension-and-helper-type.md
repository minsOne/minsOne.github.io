---
layout: post
title: "[Swift] Private Extension과 Helper 타입"
tags: [Swift, Extension, Helper]
---
{% include JB/setup %}

우리는 코드를 작성할 때, 전달받은 Parameter를 이용하거나 변수의 값을 조합하는 등을 통해 새로운 값을 만들어 전달합니다.

<div class="mermaid" style="display:flex;justify-content:center;"> 
graph LR;
    A-->Business_Logic-->B;
</div>

다음과 같이 문자열이 들어왔을 때, 소수점 둘째자리까지 표시하는 문자열을 반환한다고 가정해봅시다.

```swift
struct Service {
    // 소수점 둘째자리까지 표시
    func displayAmount(_ amount: String) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = .down
        formatter.groupingSeparator = ","
        return formatter
            .number(from: amount)
            .flatMap { formatter.string(from: $0) }
    }
}

service.displayAmount("123.456") // "123.45"
```

위와 같은 코드는 Interactor, Service, Model 등과 같은 코드에서 많이 사용하며, 이를 Extension으로 코드를 분리할 수 있습니다.

```swift
struct Service {
    func displayAmount(_ amount: String) -> String? {
        amount.roundDownTwoDecimalPlaces
    }
}

private extension String {
    var roundDownTwoDecimalPlaces: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = .down
        formatter.groupingSeparator = ","
        return formatter
            .number(from: self)
            .flatMap { formatter.string(from: $0) }
    }
}
```

Extension 코드에 접근제어자를 `Private`를 사용한 것은 해당 파일에서만 사용하고, 다른 곳에서는 사용하질 않도록 하기 위함입니다. 또한, 일정 수준 이상 코드를 작성하게 되면 Extension에 작성된 코드를 볼 일이 거의 없습니다. 

그러나 Extension으로 코드 분리하였지만 그건 위치만 변경되었을 뿐, 기존 코드와는 큰 차이가 없습니다. 또한, 해당 파일의 대부분은 Extension 코드가 많이 차지할 수 있습니다. Swift는 특정 폴더 내에서만 사용 가능한 접근제어자 같은 기능을 제공하지 않습니다. Extension의 접근제어자를 Private 말고는 다른 것을 사용하기도 애매합니다.

그러면 어떻게 하는 것이 좋을까요?

## Helper 타입

Swift는 타입 내에서 타입을 정의할 수 있는 기능을 제공합니다.

```swift
struct A {
    struct B {}
}

// or

extension A {
    struct B {}
}
```

B 타입은 A 타입 내에 정의되었기 때문에, 외부에서 `A.B`로 직접 접근하지 않는 이상, B 타입을 접근할 일이 거의 없다고 볼 수 있습니다. 그러면 이를 조금 응용하면 Helper 타입을 만들고, 별도의 파일로 분리한다면, 어떨까요?

```swift
/// FileName : Service.swift
struct Service {
    private let helper = Helper()

    func displayAmount(_ amount: String) -> String? {
        helper.roundDownTwoDecimalPlaces(from: amount)
    }
}

/// FileName : Service+Helper.swift
extension Service {
    struct Helper {}
}

extension Service.Helper {
    func roundDownTwoDecimalPlaces(from value: String) -> String? {
        let formatter = NumberFormatter().roundDownTwoDecimalPlaces
        return formatter
            .number(from: value)
            .flatMap { formatter.string(from: $0) }
    }
}

private extension NumberFormatter {
    var roundDownTwoDecimalPlaces: NumberFormatter {
        locale = .init(languageCode: .korean)
        numberStyle = .decimal
        maximumFractionDigits = 2
        roundingMode = .down
        groupingSeparator = ","
        return self
    }
}
```

Service는 Helper에 선언된 roundDownTwoDecimalPlaces 함수를 호출하여 결과를 얻을 수 있습니다. 또한, Service 파일은 Extension 코드가 없기 때문에 코드량이 적어집니다. 이는 유지보수할 때, 파일 단위로 코드를 파악하기 쉬워집니다. 

다른 언어에서 Helper 타입과 유사한 것을 정의하고 사용하고 있어, 새로운 개념은 아니지만, Swift와 Objc에서는 Extension을 통해 코드를 사용하는 관습이 많이 있어 생각을 조금만 전환해보면 코드를 분리하여 사용할 수 있습니다.
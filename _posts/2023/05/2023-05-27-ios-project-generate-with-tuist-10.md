---
layout: post
title: "[iOS][Tuist] 프로젝트 생성/관리 도구 Tuist(10) - System Programming Interfaces (SPI)를 이용하여 모듈 의존성 접근을 제어하기"
tags: [Tuist, SPI, spi]
---
{% include JB/setup %}

프로젝트를 Tuist로 구축하여 작업하고 있지만, 동일한 수준의 이해도를 가진 작업자들이 모두 참여하는 것은 아닙니다.

[[iOS][Tuist 1.7.1] 프로젝트 생성/관리 도구 Tuist(3) - Extension]({{BASE_PATH}}/mac/ios/ios-project-generate-with-tuist-3) 글에서는 모듈을 별도의 변수로 관리하여 사용하는 방법을 설명했습니다. 이를 통해 모듈 사용이 간편해졌습니다.

Tuist를 사용하여 프로젝트 환경을 구축한 사람들은 깊은 이해를 갖고 있지만, 함께 작업하는 사람들은 그렇지 않을 수 있습니다. 그 결과, 다른 모듈을 사용할 때 어떤 의존 관계가 형성되는지 또는 해당 모듈을 사용할 때 어떤 사항을 이해해야 하는지 알기 어려울 수 있습니다.

예를 들어, 동적 프레임워크에서 정적 라이브러리로 만든 라이브러리에 의존하는 경우, 해당 라이브러리가 여러 프레임워크에 중복 복사될 수 있으며 중복 복사를 피하기 위해 제어해야 합니다. 예전에는 Xcode에서 의존성을 관리하는 것이 어려웠지만, Tuist 기반 환경에서는 의존성을 쉽게 추가할 수 있습니다. 다수의 개발자가 동시에 작업하는 환경에서 문제가 발생할 수 있는 가능성이 있습니다.

따라서, 특정 기능의 모듈에 접근할 때 제약을 설정할 수 있다면 문제가 발생할 가능성이 줄어들지 않을까요?

다음과 같이 모듈 간의 의존성이 형성되어 있다고 가정해 봅시다. 적금 모듈은 적금의 추가 납입 기능을 제공합니다.

<div class="mermaid" style="display:flex;justify-content:center;"> 
graph TD;
    id1([Featur적금]);
    id2([Featur적금_추가납입]);
    id1-->id2;

    style id1 fill:#ffba0c
    style id2 fill:#ff7357
</div>

위의 모듈은 다음과 같이 변수로 관리할 수 있습니다.

```swift
// MARK: 적금
public extension TargetDependency {
  static let Feature적금: TargetDependency = .project(target: "FeatureSavings",
                                                     path: "//FeatureSavings")
  static let Feature적금_추가납입: TargetDependency = .project(target: "FeatureSavingsAdditionalPayment",
                                                            path: "//FeatureSavingsAdditionalPayment")
}

...

let project = Project(
  ...
  targets: [
    Target(name: "FeatureSavings",
           ...
           dependencies: [
            .Feature적금_추가납입
           ]
)

```

대출 기능을 만들었는데, 실수로 적금의 추가납입 기능을 추가할 수 있습니다.

<div class="mermaid" style="display:flex;justify-content:center;"> 
graph TD;
    id1([Featur적금]);
    id2([Featur적금_추가납입]);
    id3([Featur대출]);
    id1-->id2;
    id3-->id2

    style id1 fill:#ffba0c
    style id2 fill:#ff7357
    style id3 fill:#ffba0c
</div>

```swift
let project = Project(
  ...
  targets: [
    Target(name: "FeatureLoan",
           ...
           dependencies: [
            .Feature적금_추가납입
           ]
)
```

대출이 적금의 추가 납입 기능 모듈에 의존하는 것은 이상합니다. 하지만, 모듈을 쉽게 만들고 연결할 수 있다면 이와 같은 작업이 가능해집니다.

그렇다면 이러한 문제가 발생할 가능성을 어떻게 줄일 수 있을까요?

Tuist의 Project.swift 파일은 실제로 운영에 사용되지 않는 소스이므로, Swift 언어에서 비공식적으로 지원하는 기능을 사용할 수 있습니다.

비공식으로 지원되는 기능 중 하나인 [System Programming Interfaces (SPI)](https://github.com/apple/swift/blob/main/docs/ReferenceGuides/UnderscoredAttributes.md#_spispiname)를 사용하려고 합니다.

SPI를 자세히 알아보기 위해, [System Programming Interfaces (SPI) in Swift Explained](https://blog.eidinger.info/system-programming-interfaces-spi-in-swift-explained)라는 글을 참고할 수 있습니다.

그럼 이제, 적금 모듈을 사용하기 위해 SPI Name을 `Savings`로 지정합니다.

```swift
// MARK: 적금
public extension TargetDependency {
  static let Feature적금: TargetDependency = .project(target: "FeatureSavings",
                                                     path: "//FeatureSavings")
  @_spi(Savings)
  static let Feature적금_추가납입: TargetDependency = .project(target: "FeatureSavingsAdditionalPayment",
                                                            path: "//FeatureSavingsAdditionalPayment")
}
```

따라서, 적금_추가납입 모듈을 접근할 때는 `@_spi(Savings) import ProjectDescriptionHelpers`를 사용해야 합니다.

```swift
import ProjectDescription
@_spi(Savings) import ProjectDescriptionHelpers

let project = Project(
  ...
  targets: [
    Target(name: "FeatureSavings",
           ...
           dependencies: [
            .Feature적금_추가납입
           ]
)
```

만약 대출 프로젝트에서 실수로 `.Feature적금_추가납입`에 접근한다면, `@_spi(Savings)`를 추가하지 않을 것입니다. 그러면 `.Feature적금_추가납입`를 접근할 수 없으며, generate 단계에서 해당 `Project.swift` 파일에서 빌드 에러가 발생합니다. 

```swift
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  ...
  targets: [
    Target(name: "FeatureLoan",
           ...
           dependencies: [
            .Feature적금_추가납입 // Cannot find 'Feature적금_추가납입' in scope
           ]
)
```

## 정리

Swift의 비공식 기능인 `System Programming Interfaces (SPI)`를 사용하여 모듈 의존성 추가를 적절하게 제어할 수 있습니다.

## 참고자료

* [System Programming Interfaces (SPI) in Swift Explained](https://blog.eidinger.info/system-programming-interfaces-spi-in-swift-explained)
* [GitHub - apple/swift](https://github.com/apple/swift/blob/main/docs/ReferenceGuides/UnderscoredAttributes.md#_spispiname)

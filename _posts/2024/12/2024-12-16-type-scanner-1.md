---
layout: post
title: "[Type Scanner] Type Scanner (1) - Swift Testing의 Expand Macro가 생성하는 코드 분석"
tags: [type scanner, swift, testing, Swift Testing]
---
{% include JB/setup %}

Xcode 16이 출시되면서 새로운 테스트 패키지인 [Swift Testing](https://github.com/swiftlang/swift-testing)이 추가되었습니다. 기존 XCTest를 이용하여 테스트를 작성했다면, 이제는 Swift Testing을 활용하여 현대적인 테스트 케이스를 작성할 수 있게 되었습니다.

```swift
import Testing

struct SampleTest {
    init() {}
    
    @Test("Hello 테스트")
    func hello() {
        #expect(true)
    }
    
    @Test("World 테스트")
    func world() {
        #expect(false != true)
    }
}
```

XCTest를 사용할 때는 함수명이 곧 테스트 케이스 이름이었지만, 이제는 Test 매크로에 표시할 이름을 넣을 수 있게 되었습니다.

현대적인 방식으로 테스트 케이스를 작성할 수 있게 되었지만, Xcode는 어떻게 `@Test` 매크로가 붙어 있는 함수를 찾아서 수행하는 것일까요?

`@Test`에서 Expand Macro를 실행하여 어떻게 코드가 생성되는지 확인할 수 있습니다.

<br/>
<p style="text-align:center;">
<img src="{{ site.prod_url }}/image/2024/12/01.png"/>
</p><br/>

```swift
@available(*, deprecated, message: "This function is an implementation detail of the testing library. Do not use it directly.")
@Sendable private static func $s18SampleLibraryTests0A4TestV5hello0D0fMp_11funchello__fMu0_() async throws -> Void {
  try await Testing.__ifMainActorIsolationEnforced { [] in
    let $s18SampleLibraryTests0A4TestV5hello0D0fMp_11funchello__fMu_ = try await (SampleTest(), Testing.__requiringTry, Testing.__requiringAwait).0
    _ = try await ($s18SampleLibraryTests0A4TestV5hello0D0fMp_11funchello__fMu_.hello(), Testing.__requiringTry, Testing.__requiringAwait).0
  } else: { [] in
    let $s18SampleLibraryTests0A4TestV5hello0D0fMp_11funchello__fMu_ = try await (SampleTest(), Testing.__requiringTry, Testing.__requiringAwait).0
    _ = try await ($s18SampleLibraryTests0A4TestV5hello0D0fMp_11funchello__fMu_.hello(), Testing.__requiringTry, Testing.__requiringAwait).0
  }
}

@available(*, deprecated, message: "This type is an implementation detail of the testing library. Do not use it directly.")
enum $s18SampleLibraryTests0A4TestV5hello0D0fMp_41__🟠$test_container__function__funchello__fMu_: Testing.__TestContainer {
  static var __tests: [Testing.Test] {
    get async {
      return [
  .__function(
    named: "hello()",
    in: SampleTest.self,
    xcTestCompatibleSelector: nil,
    displayName: "Hello 테스트", traits: [], sourceLocation: Testing.SourceLocation(fileID: "SampleLibraryTests/SampleLibraryTests.swift", filePath: "/Users/minsone/tmp/20241216/SampleLibrary/Tests/SampleLibraryTests/SampleLibraryTests.swift", line: 9, column: 6),
    parameters: [],
    testFunction: $s18SampleLibraryTests0A4TestV5hello0D0fMp_11funchello__fMu0_
  )
      ]
    }
  }
}
```

`$s18SampleLibraryTests0A4TestV5hello0D0fMp_11funchello__fMu0_` 함수와 `$s18SampleLibraryTests0A4TestV5hello0D0fMp_41__🟠$test_container__function__funchello__fMu_` enum이 만들어졌습니다.<br/>

여기에서 우리는 함수 이름이 Mangling 되어 있다는 것을 알 수 있습니다. [Wikipedia - Name mangling](https://en.wikipedia.org/wiki/Name_mangling#Swift), [Swift - Mangling](https://github.com/swiftlang/swift/blob/main/docs/ABI/Mangling.rst), [Name Mangling](https://minsone.github.io/programming/swift-name-mangling)

이 함수 이름을 Demangle 해봅시다.

```shell
$ xcrun swift-demangle s18SampleLibraryTests0A4TestV5hello0D0fMp_11funchello__fMu0_
$s18SampleLibraryTests0A4TestV5hello0D0fMp_11funchello__fMu0_ ---> unique name #2 of funchello__ in peer macro @Test expansion #1 of hello in SampleLibraryTests.SampleTest
```

`s` 는 Swift 심볼을 의미, `18SampleLibraryTests` 는 `SampleLibraryTests` 모듈 이름 및 모듈 이름 글자수인 18자, `0A4TestV`는 Test 라는 Value 타입인 구조체, `5hello0D0`는 메서드나 속성 이름을 나타냅니다.  

<br/>

다음으로 enum 코드를 살펴보면, 특이하게 `🟠` 이모지가 들어있는 것을 확인할 수 있습니다. 왜 이런 이모지가 들어있는 것일까요? 알아보기 위해 [Swift Testing](https://github.com/swiftlang/swift-testing) 라이브러리를 살펴봅시다.

<br/>
<p style="text-align:center;">
<img src="{{ site.prod_url }}/image/2024/12/02.png"/>
</p>

[GitHub 검색 결과](https://github.com/search?q=repo%3Aswiftlang%2Fswift-testing%20%F0%9F%9F%A0&type=code)

<br/>

검색을 통해 [TestDeclarationMacro](https://github.com/swiftlang/swift-testing/blob/e2ec0411e5f7407fc2d325c9feea8f0ac10a60e2/Sources/TestingMacros/TestDeclarationMacro.swift#L467) 매크로가 `__🟠$test_container__function__` 문자열을 붙여준다는 것을 확인할 수 있으며, [Test+Discovery.swift](https://github.com/swiftlang/swift-testing/blob/e2ec0411e5f7407fc2d325c9feea8f0ac10a60e2/Sources/Testing/Test%2BDiscovery.swift#L26) 에서 `__🟠$test_container__` 문자열로 무엇인가 발견하려는 것을 알 수 있습니다.

<br/>

다음 편에서 `Test+Discovery.swift` 코드부터 살펴보면서 어떻게 테스트 케이스를 찾아서 실행하는지 살펴보겠습니다.

<br/>

## 참고자료

* [Swift Testing](https://github.com/swiftlang/swift-testing)
* [Displaying all SwiftUI Previews in a Storybook app](https://medium.com/eureka-engineering/displaying-all-swiftui-previews-in-a-storybook-app-1dd8e925d777)
  * [eure/Storybook-ios](https://github.com/eure/Storybook-ios)
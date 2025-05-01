---
layout: post
title: "[Swift] Type Scanner (2) - Swift Testing을 분석하여 Test 타입 찾기"
tags: [type scanner, swift, testing, Swift Testing]
---
{% include JB/setup %}

[Test+Discovery.swift#L26](https://github.com/swiftlang/swift-testing/blob/e2ec0411e5f7407fc2d325c9feea8f0ac10a60e2/Sources/Testing/Test%2BDiscovery.swift#L26)를 보면, `__🟠$test_container__` 문자열이 포함된 타입 이름을 찾을려는 것을 `_testContainerTypeNameMagic` 속성 이름을 통해 알 수 있습니다.

<br/>
<p style="text-align:center;">
<img src="{{ site.product_url }}/image/2025/05/01.png"/>
</p><br/>

또한, 아래 all 속성에서 `enumerateTypes(withNamesContaining:)` 를 이용하여 `__🟠$test_container__` 문자열이 포함된 타입을 추출하여, 해당 타입이 `__TestContainer.Type` 타입인지 체크를 한 뒤, `__tests` 를 꺼내어 `Sequence`에 넣어, 테스트를 수행할려는 것을 확인할 수 있습니다.

`enumerateTypes(withNamesContaining:)` 함수는 [Test+Discovery.swift#L69](https://github.com/swiftlang/swift-testing/blob/e2ec0411e5f7407fc2d325c9feea8f0ac10a60e2/Sources/Testing/Test%2BDiscovery.swift#L69)에서 찾을 수 있습니다.

<br/>
<p style="text-align:center;">
<img src="{{ site.product_url }}/image/2025/05/02.png"/>
</p><br/>

이 함수에서 실질적인 동작을 수행하는 함수인 `swt_enumerateTypes(withNamesContaining:_:_:)`를 찾아야 합니다.

이 함수는 [Discovery.h#L40](https://github.com/swiftlang/swift-testing/blob/5b4d6d6f7d4e0dbca4dd6593e0c8862022388d7c/Sources/_TestingInternals/include/Discovery.h#L40)에서 찾을 수 있습니다. `swt_enumerateTypesWithNamesContaining` 함수로, Swift에서 이름을 축약해서 사용할 수 있도록 `SWT_SWIFT_NAME(swt_enumerateTypes(withNamesContaining:_:_:))` 코드를 작성한 것을 확인할 수 있습니다.

<br/>
<p style="text-align:center;">
<img src="{{ site.dev_url }}/image/2025/05/03.png"/>
</p><br/>

이제 `swt_enumerateTypesWithNamesContaining` 함수가 구현된 [Discovery.cpp](https://github.com/swiftlang/swift-testing/blob/5b4d6d6f7d4e0dbca4dd6593e0c8862022388d7c/Sources/_TestingInternals/Discovery.cpp#L509)를 확인해봅시다.

```cpp
void swt_enumerateTypesWithNamesContaining(const char *nameSubstring, void *context, SWTTypeEnumerator body) {
  enumerateTypeMetadataSections([=] (const SWTSectionBounds<SWTTypeMetadataRecord>& sectionBounds, bool *stop) {
    for (const auto& record : sectionBounds) {
      auto contextDescriptor = record.getContextDescriptor();
      if (!contextDescriptor) {
        // This type metadata record is invalid (or we don't understand how to
        // get its context descriptor), so skip it.
        continue;
      } else if (contextDescriptor->isGeneric()) {
        // Generic types cannot be fully instantiated without generic
        // parameters, which is not something we can know abstractly.
        continue;
      }

      // Check that the type's name passes. This will be more expensive than the
      // checks above, but should be cheaper than realizing the metadata.
      const char *typeName = contextDescriptor->getName();
      bool nameOK = typeName && nullptr != std::strstr(typeName, nameSubstring);
      if (!nameOK) {
        continue;
      }

      if (void *typeMetadata = contextDescriptor->getMetadata()) {
        body(sectionBounds.imageAddress, typeMetadata, stop, context);
      }
    }
  });
}
```

`enumerateTypeMetadataSections` 함수를 통해 현재 프로세스에 로드된 Swift 타입 메타데이터 섹션을 열거하고, 각 섹션 내의 모든 타입 메타데이터 레코드를 반복 처리합니다.

메타데이터 레코드가 유효하지 않거나, 제네릭이면 건너뜁니다.

`const char *typeName = contextDescriptor->getName();` 에서 타입 이름을 가져와서, 해당 이름에 `__🟠$test_container__` 문자열이 포함되어 있는지 검사하고, 일치하면 타입 메타데이터를 가져와 이미지 주소, 타입 메타데이터, 중지 플래그, 컨텍스트 정보를 전달합니다.

즉, 타입 이름에 주어진 문자열이 포함되는 Swift 타입들을 찾아 넘겨주는 역할을 합니다. 이 방식은 enum, struct, class 등의 모든 타입을 찾아내기 위에 사용할 수 있습니다.

이를 이용하면, 타입 메타데이터를 스캔하는 기능을 만들어낼 수 있습니다.

<br/>

## 참고자료

* [Swift Testing](https://github.com/swiftlang/swift-testing)
* [Displaying all SwiftUI Previews in a Storybook app](https://medium.com/eureka-engineering/displaying-all-swiftui-previews-in-a-storybook-app-1dd8e925d777)
  * [eure/Storybook-ios](https://github.com/eure/Storybook-ios)
* GitHub
  * [minsone/DIContainer](https://github.com/minsOne/DIContainer/blob/d331a2c64ceefef5ea67bb0e46d0d0ae71aac750/Sources/DIContainer/Scanner/MachOLoader/MachOLoader.swift)
  * [p-x9/MachOKit](https://github.com/p-x9/MachOKit)
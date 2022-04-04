---
layout: post
title: "[iOS][Swift] 배포시 사용하지 않는/전달되면 안되는 라이브러리를 컴파일 타임에 검증하기 - canImport, 전처리기, 컴파일러 지시자 활용"
description: ""
category: ""
tags: [Swift, iOS, canImport, error, warning, Preprocessor]
---
{% include JB/setup %}

배포 환경에 따라 애플리케이션에 들어가는 라이브러리가 각각 다를 수 있습니다. 

![image]({{site.production_url}}/image/2020/05/12.png)

위와 같은 그림에서 Flex는 DevModule에만 있지만, Production 애플리케이션 타겟에서 DevModule을 실수로 링크를 하는 경우, Flex 라이브러리는 고객에게 전달되는 애플리케이션에 실려서 나가게 됩니다.

이를 빌드 단계에서 에러가 발생하도록 막는다면 Production 애플리케이션이 빌드 중에 에러가 발생하고, 고객에게 Flex 라이브러리가 포함된 애플리케이션은 전달되지 않을 것입니다.

Swift 4.1 [SE-0075](https://github.com/apple/swift-evolution/blob/master/proposals/0075-import-test.md)에서 추가된 `canImport`, Swift 4.2 [SE-0196](https://github.com/apple/swift-evolution/blob/master/proposals/0196-diagnostic-directives.md)에서 추가된 컴파일러 지시자 `#warning`, `#error`를 이용하여 해당 라이브러리가 포함되는지 검증할 것입니다.

해당 코드는 다음과 같습니다.

```swift
/// FileName : ValidateImportModule.swift

#if PRODUCTION

#if canImport(DevModule)
#error("Production 타겟에 DevModule이 import가 가능합니다.")
#endif

#if canImport(Flex)
#error("Production 타겟에 Flex이 import가 가능합니다.")
#endif

#endif
```

전처리문 PRODUCTION 에서 canImport로 DevModule, Flex가 가능하면 컴파일러 지시자 error를 이용하여 빌드시 에러가 발생하도록 처리하는 것입니다.

개발자의 실수를 위와 같이 빌드 중에 검증할 수 있습니다.
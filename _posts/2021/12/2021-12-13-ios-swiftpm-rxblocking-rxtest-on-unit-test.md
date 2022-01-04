---
layout: post
title: "[iOS][SwiftPM][Xcode 13.0] SwiftPM로 RxSwift 사용할 때 RxBlocking, RxTest를 유닛테스트에서 사용하기 - 절반해결(코드복사)"
description: ""
category: "iOS/Mac"
tags: [Swift, SwiftPM, SPM, Package, Framework, Library, Dynamic Framework, Static Library]
---
{% include JB/setup %}

## SwiftPM을 이용하여 RxBlocking, RxTest를 유닛 테스트에서 사용하기

RxSwift를 SwiftPM을 이용하여 쉽게 사용할 수 있습니다. 서드파티 라이브러리를 관리하는 모듈인 ThirdPartyLibraryManager 프레임워크를 만들고, 이 모듈에서 RxSwift, RxCocoa, RxRelay를 의존성 가집니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/12/20211213_01.png"/></p>

그리고 유닛 테스트 타겟에서 RxBlocking, RxTest를 의존성 추가해서 RxSwift를 사용한 코드를 테스트하려고 합니다.

SampleAppTests에 RxTest, RxBlocking 의존성 가지도록 하였습니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/12/20211213_02.png"/></p>

다음으로 유닛 테스트코드에서 RxBlocking, RxTest를 import 하는 코드를 추가하였습니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/12/20211213_03.png"/></p>

이제 유닛 테스트를 실행하면 다음과 같이 RxSwift의 클래스가 ThirdPartyLibraryManager 프레임워크의 ThirdPartyLibraryManager와 SampleAppTests XCTest의 SampleAppTests에 코드가 중복되어있다고 콘솔에 출력되었습니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/12/20211213_04.png"/></p>

분명 유닛 테스트 타겟에 RxBlocking, RxTest를 의존성만 가지도록 했는데, RxSwift 코드가 왜 중복되었을까요?

이는 SwiftPM로 추가한 라이브러리의 의존성이 있을 때, SwiftPM이 알아서 의존성을 추가해줍니다. 즉, RxBlocking, RxTest는 RxSwift를 의존성 가지며, SwiftPM이 유닛 테스트 타겟에 RxSwift 라이브러리를 알아서 추가한 것입니다. 그래서 ThirdPartyLibraryManager 프레임워크에도 RxSwift가 있고, 유닛 테스트 타겟에도 RxSwift가 존재하는 것입니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/12/20211213_05.png"/></p>

SwiftPM이 RxSwift을 추가해주는 것을 막을 방법은 없습니다. 그렇다고 RxSwift, RxCocoa, RxRelay, RxBlocking, RxTest를 Dynamic Framework로 만들면 되지만, 저는 최대한 Static Library 형태를 취하려고 합니다.

그러면 RxBlocking, RxTest `소스를 복사`해서 `별도의 프레임워크 RxTestPacakge`를 만들고, ThirdPartyLibraryManager 프레임워크를 의존성 가진다면 ThirdPartyLibraryManager 프레임워크에 적재된 RxSwift 코드를 RxTestPacakge 에서 사용할 수 있습니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/12/20211213_06.png"/></p>

그러면 RxTestPackage를 만들어봅시다.

RxTestPackage는 Dynamic Framework로 만들며, ThirdPartyLibraryManager, XCTest 프레임워크를 의존성 가지게 합니다. 그리고 RxSwift 저장소에 있는 RxBlocking, RxTest 소스를 그대로 추가합니다. (컴파일 오류 부분은 적당히 수정하시면 됩니다.)

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/12/20211213_07.png"/></p>

다음으로 유닛 테스트 타겟이 ThirdPartyLibraryManager와 RxTestPackage를 의존성 가지도록 합니다. 

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/12/20211213_08.png"/></p>

다음으로 유닛 테스트를 실행하면 이전에는 RxSwift 코드가 중복되었다고 했지만, 이제는 유닛 테스트 관련 로그만 출력됨을 확인할 수 있습니다. 그리고 RxBlocking 라이브러리에서 제공하던 toBlocking 유닛 테스트 코드에서 사용 가능함을 확인할 수 있습니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/12/20211213_09.png"/></p>

SwiftPM이 서드파티 라이브러리를 쉽게 추가할 수 있게 해주지만, 어떻게 동작하는지 잘 알고, 유연하게 대응하는 것이 중요하다고 생각합니다.

## SwiftPM을 이용하여 Nimble, Quick, RxNimble를 유닛 테스트에서 사용하기

유닛 테스트 코드 작성시 Nimble, Quick을 많이 사용합니다. 그리고 RxSwift를 사용시 RxNimble도 많이 사용합니다. RxNimble은 [Package.swift](https://github.com/RxSwiftCommunity/RxNimble/blob/master/Package.swift#L23)을 살펴보면 RxSwift, Nimble, RxTest, RxBlocking를 의존성 가지고 있습니다. 

Package.swift를 통해 SwiftPM으로 RxNimble만 추가하게 되면 앞에서 RxBlocking, RxTest를 추가했던 것과 같이 RxSwift, RxTest, RxBlocking 코드가 중복되어 적재됨을 알 수 있습니다.

위에서 RxTestPackage는 RxBlocking, RxTest 소스를 가지고 있으므로, Nimble만 의존성 가지도록 하면 됩니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/12/20211213_10.png"></p>

먼저 RxTestPackage에 Quick, Nimble을 SwiftPM으로 추가합시다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/12/20211213_11.png"/></p>

다음으로 RxNimble은 소스를 복사해 RxTestPackage에 추가합니다. (컴파일 오류 부분은 적당히 수정하시면 됩니다.)

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/12/20211213_12.png"/></p>

유닛 테스트 코드에서 Nimble, Quick을 import 할 수 있고, RxNimble에서 Observable expect 코드가 사용 가능한 것을 확인할 수 있습니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/12/20211213_13.png"/></p>

<br/>위의 결과물은 [여기](https://github.com/minsOne/Experiment-Repo/tree/master/20211213-SampleApp)에서 확인하실 수 있습니다.

## 정리

* RxSwift을 SwiftPM으로 사용하여 추가할 경우, RxSwift를 의존하는 라이브러리는 소스복사를 통해 해결

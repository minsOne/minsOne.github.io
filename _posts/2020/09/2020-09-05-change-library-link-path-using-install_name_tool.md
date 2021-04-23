---
layout: post
title: "[SwiftPM][Carthage] 라이브러리 Link 경로를 install_name_tool 을 이용하여 변경하기"
description: ""
category: "programming"
tags: [SwiftPM, SPM, Carthage, XCode, install_name_tool, RxSwift, RxTest]
---
{% include JB/setup %}

동적 라이브러리가 의존하고 있는 다른 동적 라이브러리의 경로는 otool을 이용해서 정보를 얻을 수 있습니다. 예를 들어, RxTest는 RxSwift를 의존하고 있습니다. 그래서 otool을 이용하면 RxSwift를 링크하고 있다는 것을 알 수 있습니다.

```
$ otool -L RxTest.framework/RxTest
RxTest.framework/RxTest:
	@rpath/RxTest.framework/RxTest (compatibility version 1.0.0, current version 1.0.0)
	/usr/lib/swift/libswiftXCTest.dylib (compatibility version 1.0.0, current version 0.0.0, weak)
	/System/Library/Frameworks/Foundation.framework/Foundation (compatibility version 300.0.0, current version 1677.104.0)
	/usr/lib/libobjc.A.dylib (compatibility version 1.0.0, current version 228.0.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1281.100.1)
	/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation (compatibility version 150.0.0, current version 1677.104.0)
	@rpath/RxSwift.framework/RxSwift (compatibility version 1.0.0, current version 1.0.0)
	@rpath/libswiftCore.dylib (compatibility version 1.0.0, current version 1103.2.25)
	@rpath/libswiftFoundation.dylib (compatibility version 1.0.0, current version 0.0.0)
```

만약에 RxSwift가 **`정적 라이브러리(Static Library)`**가 된다면 어떻게 될까요? 정적 라이브러리가 된다는 이야기는 RxTest가 RxSwift의 경로인 `@rpath/RxSwift.framework/RxSwift`를 찾을 수 없습니다. RxSwift를 링크하는 곳에서 코드가 복사가 되었기 때문입니다. 

RxTest를 사용하기 위해서는 RxTest에 RxSwift가 있는 경로를 알려줘야 합니다. 다른 동적 라이브러리에 RxSwift가 된 경우, 어플리케이션 실행 바이너리에 복사가 된 경우가 있습니다. 두 경우에 어떻게 풀어볼지 살펴봅시다.

**(정적 라이브러리 추가 방식은 SwiftPM을 이용하고 있습니다.)**

### RxSwift가 다른 라이브러리에 복사 된 경우

Modular라는 새로운 프레임워크 프로젝트를 만듭니다. 이 프레임워크는 Dynamic으로, SwiftPM으로 RxSwift 라이브러리를 추가합니다.

<p style="text-align:center;">
    <img src="{{ site.production_url }}/image/2020/09/20200905_01.png" style="width: 600px"/>
</p><br/>

RxTest는 테스트 할때 쓰이기 때문에 테스트 타겟에 추가합니다. 

<p style="text-align:center;">
    <img src="{{ site.production_url }}/image/2020/09/20200905_02.png" style="width: 600px"/>
</p><br/>

하지만 RxTest는 실행 과정에 `@rpath/RxSwift.framework/RxSwift` 경로의 RxSwift를 찾을 수 없어 `image not found` 에러가 발생합니다.

<p style="text-align:center;">
    <img src="{{ site.production_url }}/image/2020/09/20200905_03.png" style="width: 600px"/>
</p><br/>

RxTest는 RxSwift 코드가 복사된 Modular 라이브러리 경로로 설정해줘야 합니다.

`install_name_tool`를 이용하여 RxTest에 있는 RxSwift 경로를 Modular로 변경할 수 있습니다.

```
$ install_name_tool -change @rpath/RxSwift.framework/RxSwift @rpath/Modular.framework/Modular RxTest.framework/RxTest
$ otool -L RxTest.framework/RxTest
RxTest.framework/RxTest:
	@rpath/RxTest.framework/RxTest (compatibility version 1.0.0, current version 1.0.0)
	/usr/lib/swift/libswiftXCTest.dylib (compatibility version 1.0.0, current version 0.0.0, weak)
	/System/Library/Frameworks/Foundation.framework/Foundation (compatibility version 300.0.0, current version 1677.104.0)
	/usr/lib/libobjc.A.dylib (compatibility version 1.0.0, current version 228.0.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1281.100.1)
	/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation (compatibility version 150.0.0, current version 1677.104.0)
	@rpath/Modular.framework/Modular (compatibility version 1.0.0, current version 1.0.0)
	@rpath/libswiftCore.dylib (compatibility version 1.0.0, current version 1103.2.25)
	@rpath/libswiftFoundation.dylib (compatibility version 1.0.0, current version 0.0.0)
```

다시 빌드 후 실행하면 테스트코드가 실행되는 것을 확인할 수 있습니다.

### RxSwift가 어플리케이션 실행 바이너리에 복사 된 경우

앱 타겟에 SwiftPM으로 RxSwift를 추가하였습니다.

<p style="text-align:center;">
    <img src="{{ site.production_url }}/image/2020/09/20200905_04.png" style="width: 600px"/>
</p><br/>

RxSwift는 어플리케이션 실행 바이너리에 복사가 되었습니다. 라이브러리는 실행 바이너리를 링킹할 수 없습니다. 따라서 RxTest는 install_name_tool로 RxSwift 경로를 설정해주는 것이 불가능합니다.

그러면 테스트 타겟에 RxTest를 정적 라이브러리로 추가하면 어떨까요?

<p style="text-align:center;">
    <img src="{{ site.production_url }}/image/2020/09/20200905_05.png" style="width: 600px"/>
</p><br/>

RxTest는 RxSwift에 의존성을 가지므로, 테스트 타겟에는 RxSwift, RxTest 코드가 모두 들어가게 됩니다. 앱, 테스트 모두 RxSwift가 존재하는 상황이 됩니다. 

테스트를 실행하면 앱과 테스트에 RxSwift 클래스가 있다고 출력됩니다.

<p style="text-align:center;">
    <img src="{{ site.production_url }}/image/2020/09/20200905_06.png" style="width: 600px"/>
</p><br/>

현재로선 별도의 방법이 없습니다. [Github Issue](https://github.com/ReactiveX/RxSwift/issues/2057) 

따라서 RxSwift는 동적 라이브러리로 만들어 사용하거나 첫번째 경우 처럼 작업이 필요합니다.

## 정리

* RxSwift, RxTest는 동적 라이브러리로 사용하는 것을 추천함. 또는 RxSwift는 정적 라이브러리, RxTest는 동적 라이브러리로 관리.

## 출처

* 회사 동료인 이기대님이 해결한 방법을 바탕으로 정리하였습니다.


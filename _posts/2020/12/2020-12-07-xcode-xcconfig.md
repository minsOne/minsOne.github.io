---
layout: post
title: "[Xcode] Xcode Build Configuration Files - XCConfig"
description: ""
category: "iOS/Mac"
tags: [Xcode, XCConfig, Configuration, Workspace]
---
{% include JB/setup %}

워크스페이스에 여러 프로젝트가 있는 경우, 모두 동일한 설정값을 필요로 하기도 합니다.

예를 들어, 네트워크 호스트 주소가 메인 앱에 있지 않고 다른 프로젝트로 분리되어 있다고 해봅시다. 이 경우 메인 앱에 설정되어 있는 값들은 모릅니다. 그렇기 때문에 앱이 Develop, Test, Inhouse-AppStore, Appstore 등으로 배포될 때 네트워크 호스트 주소를 코드로 분기하고 주입하는 방식 말고는 없습니다. 

이와 같이 메인 앱에 설정한 환경설정을 모든 프로젝트에서 동일하게 가져가고 싶을 때, XCConfig를 이용하면 훨씬 쉽고 간편하게 반영할 수 있습니다. 

[hackernoon - 
Guide To Organizing Your iOS Debug, Development, and Release States With .xcconfig Files](https://hackernoon.com/a-cleaner-way-to-organize-your-ios-debug-development-and-release-distributions-6b5eb6a48356), [NSHipster - Xcode Build Configuration Files](https://nshipster.com/xcconfig/), [The Unofficial Guide to xcconfig files](https://pewpewthespells.com/blog/xcconfig_guide.html)와 같이 잘 설명되어 있는 곳들이 많기 때문에 자세한 설명은 하지 않고 어떤 방법으로 구성할 것인가를 이야기 해보려고 합니다.

## Configurations와 XCConfig

프로젝트가 커지다보면 워크스페이스로 전환 및 여러 프로젝트를 만들어 관리하도록 하는 편입니다. 그래서 다음과 같이 이 글에서 설명할 프로젝트 구조를 설명하는 워크스페이스를 만들었습니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2020/12/20201207_01.png" style="width: 600px"/>
</p><br/>

APIHost, APIKit, APIs 같은 프로젝트를 단순히 계속 추가한다면, 상위에 있는 폴더들이 늘어나며, 깔끔하지 않습니다. 개인적으로는 상위는 앱 폴더와 환경 설정 등 프로젝트 전체적인 설정을 담당하는 폴더들이 있어야 하며, 각 라이브러리 프로젝트들은 그룹화하여 정리하는 것이 좋다고 생각합니다.

그래서 APIHost 등의 프로젝트를 Network 그룹으로 묶었으므로, Network 폴더를 만들고 거기에 APIHost, APIKit, APIs 프로젝트를 이전합니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2020/12/20201207_02.png" style="width: 600px"/>
</p><br/>

다음으로 앱은 여러 개의 스킴을 이용하여 DEV, TEST, QA, PROD 세 단계를 나눌려고 합니다. App은 각각의 환경에 맞도록 타겟(예. DEV_App, TEST_App, QA_App PROD_App) 와 같이 하는 것이 아니라 XCConfig를 이용하여 할 것입니다.

App 프로젝트의 Configurations에 DEV, TEST, QA, PROD를 만듭니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2020/12/20201207_03.png" style="width: 600px"/>
</p><br/>

그리고 각 환경에 맞는 스킴인 App-Dev, App-Test, App-QA, App-PROD 를 만듭니다.


<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2020/12/20201207_04.png" style="width: 600px"/>
</p><br/>

각 스킴의 설정에서 Build Configuration을 맞춰줍니다. 다음은 App-Test 스킴에서 Build Configuration 값을 TEST로 맞추는 방법입니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2020/12/20201207_05.gif" style="width: 600px"/>
</p><br/>

이 상태에서 빌드를 하면 컴파일 에러가 발생합니다. 그 이유는 APIHost, APIKit, APIs 프로젝트에도 마찬가지로 Configurations에 DEV, TEST, QA, PROD를 만들어야 하기 때문입니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2020/12/20201207_06.gif" style="width: 600px"/>
</p><br/>

이제 XCConfig 파일을 만들어봅시다. XCConfig는 include를 통해 다른 XCConfig 파일의 설정 값을 가져올 수 있기 때문에 최대한 모아두는 것이 좋습니다.

XCConfig 폴더를 만들고 공용으로 사용할 XCConfig를 만듭니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2020/12/20201207_07.png" style="width: 600px"/>
</p><br/>

```
// shared.xcconfig

OTHER_SWIFT_FLAGS[config=DEV][sdk=*] = $(inherited) -DDEV
OTHER_SWIFT_FLAGS[config=TEST][sdk=*] = $(inherited) -DTEST
OTHER_SWIFT_FLAGS[config=QA][sdk=*] = $(inherited) -DTEST -DQA
OTHER_SWIFT_FLAGS[config=PROD][sdk=*] = $(inherited) -DPROD
```

각 환경에 맞게 OTHER_SWIFT_FLAGS 값을 추가하여 MACRO로 분기할 수 있도록 합니다.

다음으로 App에서 사용할 XCConfig 파일을 생성합니다. App 폴더 밑에 각 Config에 해당하는 파일들을 만듭니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2020/12/20201207_08.png" style="width: 600px"/>
</p><br/>

shared.xcconfig의 OTHER_SWIFT_FLAGS 설정값이 있으므로 앱 Config는 그 설정을 그대로 받도록 shared.xcconfig를 include 합니다. 각각의 파일로 만들면 추후 설정이 섞이지 않아도 되며, 공통으로 만들어지는 속성은 별도의 XCConfig 파일로 만들어서 include 하면 됩니다.

```
// FileName : app-dev.xcconfig
#include "../shared.xcconfig"


// FileName : app-test.xcconfig
#include "../shared.xcconfig"


// FileName : app-qa.xcconfig
#include "../shared.xcconfig"


// FileName : app-prod.xcconfig
#include "../shared.xcconfig"
```

이제 App 프로젝트에서 XCConfig 폴더를 만들고, `app-dev.xcconfig`, `app-test.xcconfig`, `app-qa.xcconfig`, `app-prod.xcconfig` 파일을 레퍼런스로 추가합니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2020/12/20201207_09.png" style="width: 600px"/>
</p><br/>

아까 만들었던 Configurations에 있는 DEV, TEST, QA, PROD에 만든 XCConfig 파일을 설정합니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2020/12/20201207_10.png" style="width: 600px"/>
</p><br/>

테스트를 위해 `@main` 이 있는 코드에서 MACRO로 DEV, TEST, QA, PROD를 분기하여 해당 스킴으로 출력했을 때 원하는 결과가 잘 나오는지 확인해봅시다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2020/12/20201207_11.gif" style="width: 600px"/>
</p><br/>

다음으로 APIHost, APIKit, APIs에도 XCConfig를 설정하도록 합시다. 앞에서 했던 것과 마찬가지로 shared.xcconfig 파일을 include하며, XCConfig 폴더 내에 Network 폴더로 그룹화해서 관리하려고 합니다.

APIHost, APIKit, APIs 폴더를 만든 후, `apihost-dev.xcconfig`, `apihost-test.xcconfig`, `apihost-qa.xcconfig`, `apihost-prod.xcconfig`, `apikit-dev.xcconfig`, `apikit-test.xcconfig`, `apikit-qa.xcconfig`, `apikit-prod.xcconfig`, `apis-dev.xcconfig`, `apis-test.xcconfig`, `apis-qa.xcconfig`, `apis-prod.xcconfig` 와 같은 파일을 생성합니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2020/12/20201207_12.gif" style="width: 600px"/>
</p><br/>

각 XCConfig 파일은 shared.xccconfig를 include하므로, App에서 만든 XCConfig 파일보다 깊이가 하나 더 들어가있어 다음과 같이 include 합니다.

```
// FileName : apihost-dev.xcconfig
#include "../../shared.xcconfig"


// FileName : apihost-test.xcconfig
#include "../../shared.xcconfig"


// FileName : apihost-qa.xcconfig
#include "../../shared.xcconfig"


// FileName : apihost-prod.xcconfig
#include "../../shared.xcconfig"
```

그리고 APIHost, APIKit, APIs에 만들었던 XCConfig를 레퍼런스로 추가한 뒤, Configurations에 설정합니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2020/12/20201207_13.gif" style="width: 600px"/>
</p><br/>

다음으로 정상적으로 적용이 되는지 확인하기 위해 App에서 테스트했던 것 처럼 APIHost, APIKit, APIs 프로젝트에 소스 파일을 추가하고 MACRO로 분기하여 맞게 출력하게 합니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2020/12/20201207_14.gif" style="width: 600px"/>
</p><br/>

앞에서 만들었던 callAPIHost, callAPIKit, callAPIs 함수를 App에서 호출하였을 때, MACRO로 분기되어 출력이 되는지 확인하도록 합시다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2020/12/20201207_15.gif" style="width: 600px"/>
</p><br/>

이제 Configurations와 XCConfig를 이용하여 타겟을 여러개 만들지 않고도 목적에 맞게 코드를 작성할 수 있도록 되었습니다.

위에서 작업했던 내용은 [Github](https://github.com/minsOne/XCConfigSample)에서 확인할 수 있습니다.

## 정리

* Configuration을 이용하여 여러가지 환경을 만들 수 있음.
* XCConfig를 이용하여 동일한 환경으로 만들 수 있음.
* 환경에 따라 타겟을 여러 개를 만들지 않고, 단일 타겟으로 여러 환경을 구성하는 것이 가능.

## 참고자료

* [hackernoon - 
Guide To Organizing Your iOS Debug, Development, and Release States With .xcconfig Files](https://hackernoon.com/a-cleaner-way-to-organize-your-ios-debug-development-and-release-distributions-6b5eb6a48356)
* [NSHipster - Xcode Build Configuration Files](https://nshipster.com/xcconfig/)
* [The Unofficial Guide to xcconfig files](https://pewpewthespells.com/blog/xcconfig_guide.html)
* [LetSwift 2017 - 토스 iOS 앱의 개발/배포 환경](https://www2.slideshare.net/MintakSon/ios-80115427)
* [Medium - 당근마켓 iOS 프로젝트에 XcodeGen 도입하기](https://okanghoon.medium.com/%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8%EC%97%90-xcodegen-%EB%8F%84%EC%9E%85%ED%95%98%EA%B8%B0-d0fd54691aad)
* [Medium - Working With Xcode Configuration Files](https://medium.com/better-programming/working-with-xcode-configuration-files-398cfbe02b64)
* [WWDC 2014 - Sharing code between iOS and OS X, PDF]({{ site.production_url }}/image/2020/12/233_sharing_code_between_ios_and_os_x.pdf)

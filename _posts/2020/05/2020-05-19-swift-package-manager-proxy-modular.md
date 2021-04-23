---
layout: post
title: "[Swift 5.2][SwiftPM] Swift Package Manager를 이용하여 패키지를 통합 관리하기 - Proxy Module"
description: ""
category: "iOS/Mac"
tags: [Swift, SPM, SwiftPM, Swift Package Manager, Module, Carthage, Cocoapods, Local Swift Package]
---
{% include JB/setup %}

# Swift Package Manager

Swift Package Manager (이하 SwiftPM)은 Xcode 11의 기능으로 추가되었습니다. 이에 따라 많은 오픈소스들이 SwiftPM을 지원합니다. 대표적으로 Alamofire, SDWebImage, RxSwift, ReactorKit 등의 오픈소스가 있습니다.

## 현실적인 프로젝트 구조와 어려움

보통 Workspace 내에 메인 앱 프로젝트가 있고, 여러 개의 타겟을 가지는 형태로 되어 있습니다.

![1]({{site.production_url}}/image/2020/05/1.png)

타겟에는 거의 대부분 같은 라이브러리들이 추가됩니다. Alamofire, SDWebImage, RxSwift, ReactorKit 등이 추가될 것이고, 개발 타겟에는 Flex 같은 디버깅 라이브러리가 추가될 것입니다.

그러면 다음과 같은 타겟과 라이브러리 연결 구조가 형성됩니다.

![2]({{site.production_url}}/image/2020/05/2.png)

타겟이 많아질수록, 라이브러리가 많아질수록 **n * m** 의 연결을 가집니다. 라이브러리를 업데이트하거나 추가하는데 어려움을 겪게 됩니다.

이런 문제를 어떻게 해결해야 할까요? Cocoapods이 해결해줄까요? 아니면 Carthage가 해결해줄까요? 

Cocoapods은 어느정도 해결해주기는 하지만, Podfile에 추가를 하고 update를 해야하는 등의 작업이 필요합니다. 그리고 매끄럽게 동작하지 않을때도 많습니다. Carthage는 편법이 있지만 손이 많이 가기때문에 어렵습니다.

그러면 어떻게 해야 타겟과 라이브러리 간의 **n * m** 의 연결수를 줄일 수 있을까요?

우리는 이 문제를 접근하기 전에 Static Library, Static Framework, Dynamic Framework의 차이를 알고 접근하는 것이 좋습니다.

이 차이점은 [Framework Part 1 : Static Framework와 Dynamic Framework]({{site.production_url}}/ios/mac/ios-framework-part-1-static-framework-dynamic-framework) 에서 자세하게 확인하실 수 있습니다.

## Swift Package Manager

Static Library, Static Framework, Dynamic Framework의 차이를 알아봤으니, 이제 Swift Package Manager(이하 SwiftPM)을 한번 살펴봅시다.

SwiftPM은 종속성 관리를 위한 공식 도구입니다. Cocoapods, Carthage인 3rd Party 툴이 아닌 1st Party 입니다. 그래서 앞으로는 SwiftPM을 적용하는 것이 장기적으로 좋을 것입니다.

그러면 외부 저장소에 있는 라이브러리를 SwiftPM으로 추가해봅시다.

1.General > Framework > **+** 버튼을 누릅니다.
![3]({{site.production_url}}/image/2020/05/3.png)

2.Add Package Dependency를 선택합니다.
![4]({{site.production_url}}/image/2020/05/4.png)

3.사용할 라이브러리 주소 `https://github.com/ReactiveX/RxSwift.git` 를 입력합니다.
![5]({{site.production_url}}/image/2020/05/5.png)

4.라이브러리의 사용할 버전, 브랜치 또는 커밋을 선택합니다.
![6]({{site.production_url}}/image/2020/05/6.png)

5.라이브러리의 사용할 모듈을 선택합니다.
![7]({{site.production_url}}/image/2020/05/7.png)

6.General > Framework 에 RxSwift, RxCocoa, RxRelay, RxBlocking이 추가된 것을 확인할 수 있습니다.
![8]({{site.production_url}}/image/2020/05/8.png)

7.소스에서 라이브러리를 import 하여 잘 사용할 수 있는지 확인합니다.
![9]({{site.production_url}}/image/2020/05/9.png)

<br/>

위에서 SwiftPM을 이용하여 프로젝트에 적용해보았습니다. 다음으로 SwiftPM을 분석해봅시다.

우리가 추가한 라이브러리는 빌드가 되고 앱에 들어가게 됩니다. 그렇다면 빌드한 결과물은 어디에 있을까요? 결과물은 라이브러리와 연결된 타겟의 Products 폴더 내에 있습니다.

![10]({{site.production_url}}/image/2020/05/10.png)

여기에 만들어진 Object 파일이 앱 바이너리에 들어갑니다. 앱 파일을 열어보면 Framework 폴더가 없습니다. 

![11]({{site.production_url}}/image/2020/05/11.png)

이는 SwiftPM으로 빌드된 결과물이 앱 바이너리에 들어갔음을 추정할 수 있는데, 실제로 nm 명령어로 앱 바이너리를 살펴보면 RxSwift Symbol이 있는 것을 확인할 수 있습니다.

```
$ nm Production.app/Production | grep RxSwift
000000010027862c S _$s10DisposeKey7RxSwift27SynchronizedUnsubscribeTypePTl
0000000100076410 T _$s10Foundation4DateV7RxSwiftE22addingDispatchIntervalyAC0F00f4TimeG0OF
0000000100084fb0 t _$s10Foundation4DateV9eventTime_7RxSwift5EventOy7ElementAE12ObserverTypePQzG0C0tAeIRzlWOh
00000001000850c0 t _$s10Foundation4DateV9eventTime_7RxSwift5EventOy7ElementAE12ObserverTypePQzG0C0tSgAeIRzlWOh
0000000100221410 t _$s10Foundation9IndexPathV7RxSwift10ObservableCyqd__Gs5Error_pIegnozo_AcGsAH_pIegnrzo_So11UITableViewCRbzr__lTR
00000001002214b0 t _$s10Foundation9IndexPathV7RxSwift10ObservableCyqd__Gs5Error_pIegnozo_AcGsAH_pIegnrzo_So11UITableViewCRbzr__lTRTA
0000000100221b30 t _$s10Foundation9IndexPathV7RxSwift10ObservableCyqd__Gs5Error_pIegnozo_AcGsAH_pIegnrzo_So11UITableViewCRbzr__lTRTA.59
00000001002221b0 t _$s10Foundation9IndexPathV7RxSwift10ObservableCyqd__Gs5Error_pIegnozo_AcGsAH_pIegnrzo_So11UITableViewCRbzr__lTRTA.67
00000001002088b0 t _$s10Foundation9IndexPathV7RxSwift10ObservableCyqd__Gs5Error_pIegnozo_AcGsAH_pIegnrzo_So16UICollectionViewCRbzr__lTR
0000000100208950 t _$s10Foundation9IndexPathV7RxSwift10ObservableCyqd__Gs5Error_pIegnozo_AcGsAH_pIegnrzo_So16UICollectionViewCRbzr__lTRTA
00000001002090d0 t _$s10Foundation9IndexPaV7RxSwift10ObservableCyqd__Gs5Error_pIegnozo_AcGsAH_pIegnrzo_So16UICollectionViewCRbzr__lTRTA.52
0000000100274058 S _$s12ReactiveBase7RxSwift0A10CompatiblePTl
000000010027a290 S _$s15VirtualTimeUnit7RxSwift0aB13ConverterTypePTl
000000010027a298 S _$s23VirtualTimeIntervalUnit7RxSwift0aB13ConverterTypePTl
00000001002738ac S _$s5Trait7RxSwift21PrimitiveSequenceTypePTl
0000000100270a88 S _$s5Value7RxSwift013InvocableWithA4TypePTl
0000000100065e10 t _$s7Element7RxSwift12ObserverTypePQy_SgAbCR_r0_lWOh
0000000100123b20 t _$s7Element7RxSwift12ObserverTypePQzSbs5Error_pIegndzo_SgAbCRzlWOy
0000000100079b00 t _$s7Element7RxSwift12ObserverTypePQzSgAbCRzlWOb

...
```

## Advanced Swift Package Manager - Framework와 SwiftPM

그렇다면 우리는 SwiftPM과 Framework의 특성을 이용하여 타겟과 라이브러리 간의 연결 수를 줄일 수 있습니다.

타겟과 라이브러리 사이에 Proxy 역할을 하는 Framework를 추가하여 다음과 같은 구조로 만들 수 있습니다.

![12]({{site.production_url}}/image/2020/05/12.png)

위와 같은 구조로 라이브러리를 관리하게 되면 여러가지 이점이 있습니다.

**첫번째로**, 디버깅에 필요한 라이브러리와 기능 개발에 필요한 라이브러리 등, 목적에 맞게 라이브러리를 관리할 수 있습니다. 

기능 개발에 필요한 라이브러리가 제거되거나 추가되더라도 쉽게 작업이 가능합니다. 마찬가지로 디버깅시 필요한 라이브러리도 쉽게 추가하거나 제거할 수 있습니다.

**두번째로**, Swift 5.3 부터 SwiftPM에 리소스를 넣거나 외부 라이브러리 바이너리를 패키징할 수 있도록 한다고 합니다. 그렇다면 미리 대응해놓으면 좋지 않을까요? 관련 제안 : [SE-0271(Resources)](https://github.com/apple/swift-evolution/blob/master/proposals/0271-package-manager-resources.md), [SE-0272(Binary Dependencies)](https://github.com/apple/swift-evolution/blob/master/proposals/0272-swiftpm-binary-dependencies.md), [SE-0278(Localized Resources)](https://github.com/apple/swift-evolution/blob/master/proposals/0278-package-manager-localized-resources.md)

이제 위 구조로 프로젝트를 한번 만들어봅시다.

### Framework Project 기반

1.워크스페이스에 ProxyModular라는 이름을 가진 Framework 프로젝트를 만듭니다.

![13]({{site.production_url}}/image/2020/05/13.png)

2.앞에서 Package를 추가했던 방식을 사용하여 [RxSwift](https://github.com/ReactiveX/RxSwift.git), [RIBs](https://github.com/uber/RIBs.git), [RxSwiftExt](https://github.com/RxSwiftCommunity/RxSwiftExt.git)을 추가하여 다음과 같이 추가되도록 합니다. 단, RIBs는 현재(2020.05.18) 기준 0.9.2 버전 릴리즈 노트에 SwiftPM이 없기 때문에 master 브랜치를 바라보도록 합니다.

![14]({{site.production_url}}/image/2020/05/14.png)

3.App 프로젝트에 있는 타겟과 ProxyModular 프레임워크를 연결합니다.

![15]({{site.production_url}}/image/2020/05/15.png)

4.이제 ProxyModular 프레임워크를 연결하여 RxSwift, RIBs, RxSwiftExt 패키지도 import 하여 사용할 수 있습니다.

![16]({{site.production_url}}/image/2020/05/16.png)

### Local Swift Package Manager

Xcode는 Local Swift Package도 지원합니다. Local Package를 이용하여 ProxyModular라는 Package를 만들고 사용할 Package를 추가하면, ProxyModular 패키지를 가져다 사용하는 곳에서는 RxSwift, RIBs, RxSwiftExt 같은 패키지도 사용할 수 있습니다.

1.File > New > Swift Package 메뉴를 통해 ProxyModular라는 Package를 만듭니다.

![17]({{site.production_url}}/image/2020/05/17.jpg)

2.ProxyModular의 Package.swift 파일을 엽니다.

![18]({{site.production_url}}/image/2020/05/18.png)

3.Package의 dependencies에 아까 추가했던 [RxSwift](https://github.com/ReactiveX/RxSwift.git), [RIBs](https://github.com/uber/RIBs.git), [RxSwiftExt](https://github.com/RxSwiftCommunity/RxSwiftExt.git)을 추가하고, ProxyModular 타겟의 dependencies에도 추가합니다.

```
// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ProxyModular",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "ProxyModular",
            targets: ["ProxyModular"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(url: "https://github.com/ReactiveX/RxSwift", from: "5.1.0"),
         .package(url: "https://github.com/RxSwiftCommunity/RxSwiftExt", from: "5.1.0"),
         .package(url: "https://github.com/uber/RIBs", .branch("master"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ProxyModular",
            dependencies: ["RxSwift", "RIBs", "RxSwiftExt"]),
        .testTarget(
            name: "ProxyModularTests",
            dependencies: ["ProxyModular"]),
    ]
)
```

3.App 프로젝트에 있는 타겟과 ProxyModular Swift Package를 연결합니다.

<p style="text-align:center;">
  <img src="{{site.production_url}}/image/2020/05/19.png" style="width: 390px"/>
  <img src="{{site.production_url}}/image/2020/05/20.png" style="width: 390px"/>
  <img src="{{site.production_url}}/image/2020/05/21.png" style="width: 400px"/>
</p><br/>

4.이제 ProxyModular 프레임워크를 연결하여 RxSwift, RIBs, RxSwiftExt 패키지도 import 하여 사용할 수 있습니다.

![16]({{site.production_url}}/image/2020/05/16.png)

<div class="alert warning"><strong>주의 : </strong>Local Swift Package를 이용하면, Object 파일이 생성되고 바이너리에 추가됩니다. 따라서 이 과정을 잘 알고 사용해야하며, <a href="{{site.production_url}}/ios/mac/ios-framework-part-1-static-framework-dynamic-framework">Framework Part 1 : Static Framework와 Dynamic Framework</a>에서 자세하게 확인할 수 있습니다.</div>

예를 들어, A와 B 프레임워크가 **Mach-O가 Dynamic Library인 Framework**이고, ProxyModular Package를 사용하면, A와 B 프레임워크의 바이너리에 ProxyModular과 ProxyModular의 의존 Package가 복사되어 들어갈려고 하므로, A와 B 프레임워크의 바이너리 내에 중복해서 있습니다. 따라서 이 경우, 컴파일러가 중복된다고 판단하고 **컴파일 에러**를 발생시킵니다.

![22]({{site.production_url}}/image/2020/05/22.png)

이 경우는 Package의 라이브러리 타입을 dynamic으로 변경해줘야 합니다. library에 type 항목에 dynamic을 추가합니다.

```
// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ProxyModular",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "ProxyModular",
            type: .dynamic,
            targets: ["ProxyModular"]),
    ],
    ...
```

이제 A 프로젝트의 프레임워크인 A 타겟에서 Framework, Libraries, and Embedded Content 항목에 있던 ProxyModular에 Embed 메뉴를 선택할 수 있습니다.

![23]({{site.production_url}}/image/2020/05/23.png)

ProxyModular는 Shared Library로, A와 B 프레임워크에서 ProxyModular의 Embed 설정을 Do Not Embed로 하고, App 프로젝트의 각 타겟에서는 ProxyModular의 Embed 상태를 Embed & Sign 로 설정합니다.

![24]({{site.production_url}}/image/2020/05/24.png)

이제 위에서 컴파일러가 에러를 발생하지 않고 컴파일이 성공합니다.

## 정리

* Swift Package Manager를 이용하여 Swift Package를 쉽게 추가 및 제거가 가능.
* 빌드시 Object 파일을 만들어, Static Library 형태로 연결됨. Static과 Dynamic 의 차이를 잘 알고 사용해야 함.

## 참고

* [Libraries, frameworks, swift packages… What’s the difference?](https://medium.com/@zippicoder/libraries-frameworks-swift-packages-whats-the-difference-764f371444cd)
* [stackoverflow - Add dependency on a local swift package in Xcode 11](https://stackoverflow.com/questions/59121844/add-dependency-on-a-local-swift-package-in-xcode-11)
* [SwiftbySundell - Managing dependencies using the Swift Package Manager](https://www.swiftbysundell.com/articles/managing-dependencies-using-the-swift-package-manager/)
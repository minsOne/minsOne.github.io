---
layout: post
title: "[iOS][Swift] Pure Dependency Injection - 레거시와 신규 모듈"
description: ""
tags: [RIBs, Builder, Dependency, module, legacy]
---
{% include JB/setup %}

<div class="alert warning"><strong>경고</strong>:본 내용은 이해하면서 작성하는 글이기 때문에 잘못된 내용이 포함될 수 있습니다. 따라서 언제든지 내용이 수정되거나 삭제될 수 있습니다. 잘못된 내용이 있는 부분이 있어 의견 주시면 공부하여 올바른 내용으로 반영하도록 하겠습니다.</div><br/>

모듈 간의 의존관계가 형성되었을 때, Container를 이용한 Service Locator 패턴을 이용하여 해결할 수 있습니다. 하지만 이 방법은 Container에 구현 타입이나 객체를 등록해야 하며, 실수로 등록하지 않으면 런타임 에러 - 크래시가 발생할 여지가 있습니다. 에러가 발생하면 특정 기능이 실행되지 않거나, 앱이 죽어버리기도 합니다.

유저에게 좋지 않은 경험을 선사하기 때문에 해당 문제를 잘 해결해야 합니다.

[예전 글]({{ site.production_url/programming/swift-solved-circular-dependency-from-dependency-injection-container }})에서 Container를 이용하여 모듈의 순환관계를 푸는 글을 올렸었습니다.

이번에는 Pure DI 관점으로 푼다면 정적 언어의 특성을 이용하기 때문에 안정적으로 순환관계를 풀 수 있지 않을까 싶습니다.

아래의 예제를 살펴보면서 어떻게 풀어야할지 고민해봅시다.

<div class="mermaid" style="display:flex;justify-content:center;"> 
graph TD;
    subgraph AppGroup
    App-->전자서명
    end

    App-->Feature

    subgraph FeatureGroup
    Feature-->예금
    Feature-->적금
    end
</div>

위와 같이 예금, 적금 모듈을 분리하였고, 앱 모듈 내에서는 전자서명이라는 기능을 가지고 있습니다. 

예금, 적금은 전자서명 기능을 이용해서 서명을 해야 상품을 만들 수 있습니다. 하지만, 전자서명 기능이 모듈로 분리되지 않았기 때문에 예금, 적금 모듈 단독으로 작업이 어렵습니다.

따라서 예금, 적금 상품은 전자서명하기 위한 Protocol을 정의하고, App에서 예금, 적금 상품을 호출할때 해당 코드를 주입해줘야 합니다.

```swift
/// ModuleName: DepositOpenPackage

public protocol DepositSigningService {
    func signing(dict: [String:String]) -> [String:String]
}

public protocol DepositBuildable {
    init(service: DepositSigningService)
    func build()
}

public protocol DepositBuilder: DepositBuildable {
    let service: DepositSigningService
    public init(service: DepositSigningService) {
        self.service = service
    }
    public func build() {
        let interactor = Interactor(signingService: service)
        ...
    }
}

...

/// ModuleName : Application
import DepositOpenPackage

struct DepositSigningServiceImpl: DepositSigningService {
    func signing(dict: [String:String]) -> [String:String] {
        ...
    }
}

func openDeposit() {
    let service = DepositSigningServiceImpl()
    let builder = DepositBuilder(service: service)
    builder.build()
    ...
}
```

위와 같이 코드를 작성하게 됩니다. Pure DI 형태를 취할 수 있습니다. Service Locator를 이용하여 Container에 저장하고, 예금, 적금 모듈은 Container에서 꺼내어 사용할 수 있지만 위와 같ㅇ Pure DI 형태로 취하면 별도의 작업이 필요없습니다. 단, 귀찮긴 합니다.

이러한 Protocol을 예금, 적금 모듈에서 정의하는 것이 아니라, 더 아래 계층에서 정의를 하고, 해당 코드 구현은 Application에서 하는 것도 방법입니다.

<div class="mermaid" style="display:flex;justify-content:center;"> 
graph TD;
    subgraph AppGroup
    App-->전자서명
    end

    subgraph FeatureGroup
    Feature-->예금
    Feature-->적금
    end

    subgraph FeatureCoreGroup
    FeatureDependencies
    end

    App-->Feature
    예금-->FeatureDependencies
    적금-->FeatureDependencies
</div>

FeatureDependencies에서 전자서명 Protocol을 정의하고, 예금, 적금은 그 Protocol를 DI 하도록 요구하면 됩니다. 그러면 구현은 App 에서 하게 됩니다.

```swift
/// ModuleName : FeatureDependencies
protocol SigningService {
    func signing(dict: [String:String]) -> [String:String]
}


/// ModuleName: DepositOpenPackage
import FeatureDependencies

public protocol DepositDependency {
    var signingService: SigningService { get }
}

public protocol DepositBuildable {
    init(dependency: DepositDependency)
    func build()
}

public protocol DepositBuilder: DepositBuildable {
    private let dependency: DepositDependency
    init(dependency: DepositDependency) {
        self.dependency = dependency
    }
    public func build() {
        let interactor = Interactor(signingService: dependency.signingService)
        ...
    }
}

/// ModuleName : Application
import DepositOpenPackage
import FeatureDependencies

struct SigningServiceImpl: SigningService {
    func signing(dict: [String:String]) -> [String:String] {
        ...
    }
}

struct DepositComponent: DepositDependency {
    let signingService: SigningService = SigningServiceImpl()
}

func openDeposit() {
    let component = DepositComponent()
    let builder = DepositBuilder(dependency: component)
    builder.build()
    ...
}
```

예금 모듈은 FeatureDependencies 모듈의 SigningService 프로토콜을 누군가에게 주입해달라고 요청하게 됩니다. Application은 전자서명 코드를 SigningService 프로토콜을 준수하는 구현체를 만들고 넣어줄 수 있습니다.

따라서 Service Locator 패턴을 이용하여 Container에 주입하는 것 보다는 손이 많이 가지만 최상위 레이어에서 요구하는 protocol을 준수하는 구현체를 만들어 주입할 수 있어 런타임시 발생할 수 있는 문제가 없어집니다.


## 참고자료
- Mobile Act ONLINE #6 | uber/needleを用いたモジュール間の画面遷移とDI
  - https://www.youtube.com/watch?v=6vUpxUW_PGI
  - https://scrapbox.io/ikesyo/Mobile_Act_ONLINE_%236_%7C_uber%2Fneedle%E3%82%92%E7%94%A8%E3%81%84%E3%81%9F%E3%83%A2%E3%82%B8%E3%83%A5%E3%83%BC%E3%83%AB%E9%96%93%E3%81%AE%E7%94%BB%E9%9D%A2%E9%81%B7%E7%A7%BB%E3%81%A8DI
- [【Swift】Bastard Injection の問題点、あるいは依存性逆転の原則について。または needle というDIコンテナの紹介。](https://qiita.com/YusukeHosonuma/items/77bbb962e8ec4d36cbea)
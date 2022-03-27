---
layout: post
title: "[iOS] 준 Clean Architecture With RIBs, ReactorKit 그리고 Tuist를 이용한 프로젝트 모듈화 설계(5) - Repository, Dependency Injection, Service Locator"
description: ""
category: "Mac/iOS"
tags: [Swift, Xcode, Clean Architecture, RIBs, ReactorKit, Tuist]
---
{% include JB/setup %}

* [1편 - 설계편]({{BASE_PATH}}/mac/ios/ios-clean-architecture-with-ribs-reactorkit-and-modularization-using-tuist-1)
* [2편 - Tuist]({{BASE_PATH}}/mac/ios/ios-clean-architecture-with-ribs-reactorkit-and-modularization-using-tuist-2)
* [3편 - UserInterface]({{BASE_PATH}}/mac/ios/ios-clean-architecture-with-ribs-reactorkit-and-modularization-using-tuist-3)
* [4편 - Presentation, Domain]({{BASE_PATH}}/mac/ios/ios-clean-architecture-with-ribs-reactorkit-and-modularization-using-tuist-4)
* [5편 - Repository, Data, DI Container]({{BASE_PATH}}/mac/ios/ios-clean-architecture-with-ribs-reactorkit-and-modularization-using-tuist-5)

## Repository

Repository 레이어는 Domain에서 의존하지 않는 외부 모듈을 의존하고, Domain 모듈에서 정의한 Repository Protocol을 구현해야 합니다. 

즉, 외부 모듈의 코드를 사용하여 Repository Protocol을 구현합니다.

<div class="mermaid" style="display:flex;justify-content:center;"> 
graph LR;
    id1(Repository)-->Domain;
    id2(Repository)-->DB;
    id2-->API;
</div>

위와 같은 의존관계가 형성됩니다. 위와 같은 의존관계가 형성되면 Domain은 직접적으로 API, DB를 모르지만, Domain으로 외부 모듈 코드를 DI로 넣어줄 수 있으므로, 비즈니스 관련 로직을 더 집중할 수 있게 됩니다.

```swift
/// Module: FeatureRepository
/// FileName: Repository.swift

import API
import DB
import FeatureDomain

public struct FeatureRepositoryImpl: FeatureRepository {
    public func requestSettings() -> Single<FeatureUseCaseModel> {
        API.Model().request().map { convertModel($0) }
    }

    func convertModel(response: API.Model.Response) -> FeatureUseCaseModel {
        ...
    }
}
```

그러면, Domain에서 Repository 모듈을 모르는데, UseCase에 FeatureRepositoryImpl를 어떻게 넣어줄 수 있을까요?

## Dependency Injection

여기에서 여러가지 방법이 존재합니다. DI를 이용해서 넣는 방법, Service Locator를 이용하는 방법 등이 있습니다.

첫번째로, Domain, Repository를 의존성 가지는 모듈을 만들고, 조립하는 방법입니다.

<div class="mermaid" style="display:flex;justify-content:center;"> 
graph TD;
    id1(Builder)-->id2(Domain);
    id1-->id3(Repository);
    id3-->id2;
    id3-->DB;
    id3-->API;
</div>

Builder라는 모듈이 Domain, Repository를 알고 있으므로, 기존 RIB의 Builder가 하던 역할이 고스란히 모듈로 분리가 되는 것입니다.

```swift
/// Module: FeatureBuilder
/// FileName: Builder.swift

import RIBs
import FeatureDomain
import FeatureRepository

public protocol FeatureBuildable: Buildable {
    func build(withListener listener: FeatureListener) -> FeatureRouting
}

public class FeatureBuilder: FeatureBuildable {
    public func build(withListener listener: FeatureListener) -> FeatureRouting {
        typealias Component = FeatureComponent
        typealias Presenter = FeaturePresenter
        typealias Interactor = FeatureInteractor
        typealias Router = FeatureRouter
        typealias UseCase = FeatureUseCaseImpl
        typealias Repository = FeatureRepositoryImpl
        
        let component = Component(dependency: dependency)
        let presenter = Presenter()
        let useCase = UseCase(repository: Repository())
        let interactor = Interactor(presenter: viewController, useCase: useCase)
        interactor.listener = listener
        
        return Router(interactor: interactor, viewController: viewController)
    }
}
```

이렇게 Builder가 각 모듈을 잘 조립하여 만들 수 있다면, Domain은 Repositoy 객체가 확실히 있다는 것을 알고 있어, 안심하고 Repository를 사용할 수 있습니다. 그러면 Mock Repository를 쉽게 넣을 수 있어, 테스트도 쉽게 할 수 있습니다.

## Service Locator

두번째 방법으로 Service Locator를 이용하여 Container에 Repository를 등록한 뒤, 꺼내어 사용하는 방식이 있습니다.

Domain 모듈은 Repository Protocol을 키로 Container에서 Repository Implement를 꺼내어 사용하는 형태입니다.

<div class="mermaid" style="display:flex;justify-content:center;"> 
graph TD;
    App-->Repository;
    App-->Container;
    Repository-->Domain;
    App-->Domain;
    Domain-->Container;
    Repository-->DB;
    Repository-->API;
</div>

 Application은 모든 모듈을 다 알고 있습니다. 그래서 Repository Protocol을 키로, Repository Implement를 Container에 등록할 수 있습니다. 그리고 Domain 모듈에서는 Repository Protocol을 알고 있어, Container에서 Repository Protocol를 키로 하여 Repository Implement를 꺼내와 사용할 수 있습니다.

 [DIKit](https://github.com/Liftric/DIKit), [Swinject](https://github.com/Swinject/Swinject) 등을 이용하여 구현할 수 있습니다.

하지만 이 방식은 Container에 Repository Implement가 등록되어 있다는 것을 가정하고 작업하는 것입니다. 즉, 런타임에 일어나는 일어나는 행위로, 실수로 Application에서 Repository Implement를 등록하지 않았다면 앱이 죽어버리거나 동작하지 않는 문제가 발생합니다.

혹은 각 피처의 데모앱을 만들었을 때, 등록하는 코드도 새로 만들어줘야 하는 문제도 있기도 합니다. 

이는 컴파일 단계에서 검증할 수 있는 방법이 아니기 때문입니다.

그래서 위와 같은 방식은 [Needle](https://github.com/uber/needle)과 같은 라이브러리를 이용하여 코드를 생성하고 사용할 수 있습니다.

## 정리

역할별로 모듈을 어떻게 나누고, 어떻게 의존관계를 맺게 하느냐에 따라 여러가지 방법들이 존재를 합니다. 단순히 기능 동작을 위한 코드 작성이 아니라, 응집도를 높이고 결합도를 낮추면서 지속가능한 개발 및 유지보수 비용을 낮게 가져갈 수 있는 개발방법을 찾는 것이 중요합니다.

이 내용이 맞다 틀리다가 아닌, 더 좋은 개발 방법을 찾기 위한 연구과정으로 봐주시면 감사하겠습니다.
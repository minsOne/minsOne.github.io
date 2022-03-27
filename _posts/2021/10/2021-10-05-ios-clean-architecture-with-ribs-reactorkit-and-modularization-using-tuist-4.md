---
layout: post
title: "[iOS] 준 Clean Architecture With RIBs, ReactorKit 그리고 Tuist를 이용한 프로젝트 모듈화 설계(4) - Presentation, Domain"
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

## Presentation

UI에서 입력받은 값을 넘겨받고, 상태를 만들어 UI에 전달하는 모듈로, UI에 강하게 의존관계가 형성됩니다.

따라서 어떻게 작성하느냐에 따라 강한 의존관계 또는 약한 의존관계가 형성될 수 있으므로, 추후 테스트하는데 문제가 발생할 수 있는 여지가 있습니다.

여기에서는 Presentation의 ViewModel 같은 역할은 Uber의 [RIBs](https://github.com/uber/RIBs)를 이용하여 작업합니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/10/20211005_01.png"/></p>

위의 의존성 그림을 자세히 살펴봅시다.

### State, Action

State와 Action은 사실상 UI 모듈에서 입력하는 Action, 받아서 처리하는 State를 1:1 대응한 타입입니다. 이는 Interactor가 UI 모듈에 의존하지 않도록 하기 위함입니다. Interactor가 UI 모듈의 State, Action을 가져다 사용하게 되면, 당장은 괜찮지만, UI 모듈의 변경 등에 의해 영향이 생기므로 간접적으로 하기 위함입니다.

```
/// Module: FeaturePresentation
/// FileName: StateAction.swift

public enum PresentationAction {
    case viewDidLoad
    case applyCheckCard
    case finish
    case moveToMain
}

public struct PresentationState {
    var text: String
    var 계좌종류: String

    init(text: String,
         계좌종류: String) {
        self.text = text
        self.계좌종류 = 계좌종류
    }
}

public protocol FeaturePresentableListener: AnyObject {
    var action: ActionSubject<PresentationAction> { get }
    var state: Observable<PresentationState> { get }
}
```

### Mapper

UserInterface 모듈과 Presentation 모듈은 (사실상)1:1 관계인 타입인 State, Action이 정의되어 있습니다.

따라서 이를 중간에서 변환해주는 역할이 필요합니다.

```
/// Module: FeaturePresentation
/// FileName: Mapper.swift

import FeatureUserInterface

extension FeatureUserInterface.FeaturePresentableAction {
    var toMapper: PresentationAction {
        switch self {
        case .viewDidLoad: return .viewDidLoad
        case .applyCheckCard: return .applyCheckCard
        case .finish: return .finish
        case .moveToMain: return .moveToMain
        }
    }
}

extension PresentationState {
    var toMapper: FeatureUserInterface.FeaturePresentableState {
        return .init(text: text,
                     계좌종류: 계좌종류)
    }
}
```

### Presenter

기존 RIBs의 Builder에서 Interactor, Builder의 presenter에 Presentable, ViewControllable를 따르는 객체인 UIViewController를 주입하도록 하였지만, 그렇게 하면 UI 모듈의 UIViewController 클래스를 오염시키게 됩니다. 따라서 Presentable, ViewControllable를 따르는 Mapper 역할하는 Presenter 클래스를 만들어 이용합니다.

```
/// Module: FeaturePresentation
/// FileName: Presenter.swift

public final class FeaturePresenter:
    FeaturePresentable,
    FeatureViewControllable {

    public weak var listener: FeaturePresentableListener? {
        didSet {
            listenerMapper = listener.map(FeaturePresentableListenerMapper.init(interactor:))
            viewController.listener = listenerMapper
        }
    }

    public var uiviewController: UIViewController { viewController }
    private let viewController = FeatureViewController()

    private var listenerMapper: FeaturePresentableListenerMapper?

    init() {}

    func present() {

    }
}

private final class FeaturePresentableListenerMapper:
    FeatureUserInterface.FeaturePresentableListener,
    FeaturePresentableListener {

    var userState: Observable<FeatureUserInterface.FeaturePresentableState>

    var action: ActionSubject<PresentationAction>
    var state: Observable<PresentationState>

    init(interactor: FeaturePresentableListener) {
        self.action = interactor.action
        self.state = interactor.state
        self.userState = interactor.state.map(\.toMapper)
    }

    func action(_ userAction: FeatureUserInterface.FeaturePresentableAction) {
        self.action.onNext(userAction.toMapper)
    }
}
```


### Interactor

Interactor는 UI 모듈의 State, Action을 직접적으로 다루지 않습니다. Presentation 모듈에 정의된 State와 Action을 사용합니다. ReactorKit을 이용하여 Interactor 내부를 단방향으로 만들고, Reactor의 State와 Action은 Presentation 모듈의 State, Action으로 사용합니다. 

따라서 Interactor는 UI 모듈에 의존하지 않도록 구현이 됩니다.

```
/// Module: FeaturePresentation
/// FileName: Interactor.swift

import RIBs
import RxSwift
import ReactorKit

public protocol FeatureRouting: ViewableRouting {
    func routeToApplyCard()
}

public protocol FeaturePresentable: Presentable {
    var listener: FeaturePresentableListener? { get set }
}

public protocol FeatureListener: AnyObject {
    func finish()
    func moveToMain()
}

final class FeatureInteractor:
    PresentableInteractor<FeaturePresentable>,
    FeatureInteractable,
    FeaturePresentableListener,
    Reactor {

    enum Mutation {
        case viewDidLoad
        case 체크카드신청할까말까
        case 메인으로갈까말까
    }

    typealias Action = PresentationAction
    typealias State = PresentationState

    var initialState: State = .init(text: "Hello", 계좌종류: "입출금(한도계좌)")

    weak var router: FeatureRouting?
    weak var listener: FeatureListener?
    
    private let useCase: FeatureUseCase

    init(presenter: FeaturePresentable,
         useCase: FeatureUseCase) {
        self.useCase = useCase

        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        
        useCase.requestSettings()
            .subscribe(onSuccess: { model in
                print(model)
            })
            .disposeOnDeactivate(interactor: self)
    }

    override func willResignActive() {
        super.willResignActive()
    }


    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .just(.viewDidLoad)
        case .applyCheckCard:
            return .just(.체크카드신청할까말까)
        case .finish:
            listener?.finish()
            return .empty()
        case .moveToMain:
            return .just(.메인으로갈까말까)
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .viewDidLoad:
            newState.text = "Hello World"
        case .체크카드신청할까말까:
            newState.text = "체크카드 신청하러 갈까 말까"
            newState.계좌종류 = "입출금(미니계좌)"
        case .메인으로갈까말까:
            newState.text = "메인화면으로 갈까 말까"
            newState.계좌종류 = "입출금(일반계좌)"
        }

        return newState
    }
}
```

### Router

Router는 기존 RIBs에서 하던 방식대로 그대로 사용합니다. FeatureViewControllable 프로토콜에 정의를 하면, Presenter에서 구현을 하면 됩니다. Presenter는 UI 모듈에 상태를 넘겨줄 수 있기 때문입니다.

```swift
/// Module: FeaturePresentation
/// FileName: Router.swift

import RIBs

public protocol FeatureInteractable: Interactable {
    var router: FeatureRouting? { get set }
    var listener: FeatureListener? { get set }
}

public protocol FeatureViewControllable: ViewControllable {
    func present()
}

final class FeatureRouter:
    ViewableRouter<FeatureInteractable, FeatureViewControllable>,
    FeatureRouting {
    override init(interactor: FeatureInteractable,
                  viewController: FeatureViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    func routeToApplyCard() {
        viewController.present()
    }
}
```

### Builder

Builder는 Interactor, Router의 presenter를 주입할 때, UI 모듈의 ViewController가 아닌 Presentation 모듈에 작성한 Presenter를 넣어주면 됩니다.

```swift
/// Module: FeaturePresentation
/// FileName: Builder.swift

import RIBs

public protocol FeatureDependency: Dependency {}

final class FeatureComponent: Component<FeatureDependency> {}

// MARK: - Builder

public protocol FeatureBuildable: Buildable {
    func build(withListener listener: FeatureListener) -> FeatureRouting
}

public final class FeatureBuilder: Builder<FeatureDependency>, FeatureBuildable {

    public func build(withListener listener: FeatureListener) -> FeatureRouting {
        typealias Component = FeatureComponent
        typealias Presenter = FeaturePresenter
        typealias Interactor = FeatureInteractor
        typealias Router = FeatureRouter
        
        let component = Component(dependency: dependency)
        let presenter = Presenter()
        let interactor = Interactor(presenter: viewController,
                                    useCase: FeatureUseCaseImpl())
        interactor.listener = listener
        
        return Router(interactor: interactor,
                      viewController: viewController)
    }
}
```

## Domain

Domain 모듈은 Presentation의 Interactor가 필요한 서비스들을 정의하고 구현하여 Interactor가 호출할 수 있도록 합니다. Interactor 내부의 복잡도가 줄어들도록 하는 것입니다.

그리고 Network, Security 등등의 모듈이 필요한 경우는 Domain에서 직접 알도록 하지 않고, Repository 모듈에서 구현하도록 합니다. 이는 Domain 모듈까지는 비지니스 로직을 잘 처리할 수 있도록 격리화하며, 다른 모듈의 의존성을 최소화 적은 수의 모듈을 빌드하므로 빌드 시간이 빠르게 단축됩니다.

### UseCase

UseCase는 Interactor에서 처리하기 복잡한 로직들을 빼내어 처리합니다. UseCase 프로토콜을 정의하고, 이 프로토콜을 따르는 구현체를 만들어, 프로토콜은 Interactor 내에서 사용하고, 구현체는 Builder에서 Interactor를 생성할 때 주입합니다. 

```
/// Module: FeatureDomain
/// FileName: UseCase.swift

import Foundation
import RxSwift
import Swinject

public struct FeatureUseCaseModel {
    public let id: Int
    
    public init(id: Int) {
        self.id = id
    }
}

protocol FeatureUseCase {
    func requestSettings() -> Single<FeatureUseCaseModel>
}

struct FeatureUseCaseImpl: FeatureUseCase {
    @Inject private var repository: FeatureRepository

    func requestSettings() -> Single<FeatureUseCaseModel> {
        return repository.requestSettings()
    }
}
```

### Repository Interface

 Network, Security 등등의 모듈이 필요한 것은 Repository로부터 가져와서 사용하도록 합니다. 하지만, Domain 모듈은 Network, Security 같은 모듈을 알지 못하도록 하므로, Repository 프로토콜만 정의합니다.

Repository 모듈에서 Repository 프로토콜을 따르는 구현체를 만들고, DI Container에 등록합니다. 그러면 Domain 모듈의 UseCase 구현체는 Repository 프로토콜을 알고 있으므로, DI Container에서 Repository 구현체를 꺼내어 사용할 수 있게 됩니다. 

여기에서 사용하는 DI Container는 Swinject를 이용합니다. `@Inject` 를 붙이면 쉽게 사용할 수 있기 때문입니다.

Domain 모듈에서는 Repository 프로토콜은 정의만 하면 됩니다.

```
/// Module: FeatureDomain
/// FileName: Repository.swift

public protocol FeatureRepository {
    func requestSettings() -> Single<FeatureUseCaseModel>
}
```

<br/><br/>ps. Tuist로 프로젝트 구조 생성한 프로젝트는 [Github 저장소](https://github.com/minsOne/iOSApplicationTemplate)에 공개되어 있습니다. 모든 코드를 여기 글에 적지 못한 점 양해바랍니다.
---
layout: post
title: "[Swift5][RIBs] Uber의 RIBs 프로젝트에서 얻은 경험 (1) - 프로토콜 지향 프로그래밍"
description: ""
category: "programming"
tags: [iOS, Swift, Uber, RIBs, Protocol, DIP, POP, Protocol Oriented Programming]
---
{% include JB/setup %}

기존의 아키텍처인 MVC, MVVM, ReactorKit 등은 한 화면 내 역할을 나누고 수행합니다. 하지만 어플리케이션이 커질수록 상태가 바뀌면 모든 곳에서 상태가 변경되고, 부분 로직이 재사용되는 경우가 많아집니다. 그리고 화면들도 재사용되는 경우도 많아지며, Deep Link도 대응해야하고 프로젝트가 무거워지며 복잡해집니다.

위와 같은 경험을 할 정도의 프로젝트가 아니라면 이 글을 안읽으셔도 됩니다.

## 프로토콜 선언과 구현 

RIBs에서는 파일을 만들면 다음과 같이 코드가 생성됩니다.

```
/// FileName : RootInteractor.swift

import RIBs
import RxSwift

protocol RootRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol RootPresentable: Presentable {
    var listener: RootPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol RootListener: class {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

final class RootInteractor: PresentableInteractor<RootPresentable>, RootInteractable, RootPresentableListener {

    weak var router: RootRouting?
    weak var listener: RootListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: RootPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
}
```

RIBs에서는 Interactor를 통해 모든 행동을 제어합니다. 여기서 봐야 할 점은 Interactor 파일에 Listener, Presentable, ViewableRouting 프로토콜이 정의되어 있음을 확인할 수 있습니다. 

Interactor에서 필요한 기능이 있다면 각 프로토콜에 추가합니다. 그러면 Listener, Presentable, ViewableRouting 프로토콜을 따르는 타입들은 미 구현으로 인한 컴파일 에러가 발생하므로, 찾아서 구현해주면 됩니다.

즉, Interactor는 각 객체의 내부 구현은 알 필요가 없이 프로토콜에 정의하고 사용하면 됩니다. 


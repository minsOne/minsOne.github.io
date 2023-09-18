---
layout: post
title: "[Swift][SwiftUI] RIBs + SwiftUI"
tags: [RIBs, SwiftUI]
---
{% include JB/setup %}

기존 프로젝트에는 `UIKit` 기반으로 구성되어있다고 가정해봅시다. 이 경우, SwiftUI는 해당 프로젝트에 부분적으로 밖에 적용할 수 없습니다. 적용되어 있는 아키텍처에는 SwiftUI를 넣기 어렵기 때문입니다.

만약 SwiftUI를 UIViewController의 View 역할만 담당한다면, View는 SwiftUI로 작성하고, Life Cycle은 기존 UIKit을 유지할 수 있지 않을까요?

그렇다면 MVVM, Viper, RIBs 등의 아키텍처와 SwiftUI는 공존할 수 있어 보입니다.

SwiftUI의 View는 ObservableObject를 채택한 클래스로부터 발행된 값을 전달받아 화면을 그리고, View에서 발생된 이벤트를 ObservableObject를 채택한 클래스에 전달해주면 되지 않을까요?

그러면 View와 Interactor 간의 데이터 전달이 가능해집니다.

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2023/07/10.png" style="border: 1px solid #555;"/></p><br/>

Interactor에서는 기존 Presenter에 상태값을 전달하면, Presenter에서 SwiftUI의 ViewModel에 상태값을 다시 전달하고, ViewModel에서 상태값을 SwiftUI의 View에 전달하여 화면을 그립니다.

즉, Interactor -> Presenter -> ViewModel -> View 순으로 상태값이 전달됩니다.

SwiftUI의 View에서 발생된 이벤트를 ViewModel에 전달하면 ViewModel은 Interactor에 전달합니다.

View -> ViewModel -> Interactor 순으로 이벤트가 전달됩니다.

Presenter는 View에 상태값을 전달하는 역할에만 충실히 하도록 설계한다면, 코드의 복잡도가 낮아질 수 있습니다.

앞에서 이야기한 구조를 작성해봅시다.

## RIBs + SwiftUI

`Interactor`, `Presenter`, `ViewModel`와 `View` 간의 전달되는 `State`와 `Action`을 정의합니다.

```swift
/// FileName : HomeViewStateAction.swift

struct HomeViewState {
    var title: String
    var desc: String
}

enum HomeViewAction {
    case viewDidLoad
    case tap1
    case tap2
}
```

다음으로, `PresentableListener`, `Presenter(ViewController)`를 정의합니다.

```swift
/// FileName : HomeViewController.swift

import SwiftUI
import UIKit

protocol HomePresentableListener: AnyObject {
    func request(action: HomeViewAction)
}

final class HomeViewController: UIViewController, HomePresentable, HomeViewControllable {
    weak var listener: HomePresentableListener?
}
```

여기까지는 일반적인 RIBs에서 사용하는 방식과 비슷합니다.

다음으로, `ViewModel`, `View`를 정의합니다.

```swift
/// FileName : HomeView.swift

import SwiftUI

class HomeViewModel: ObservableObject {
    typealias State = HomeViewState
    typealias Action = HomeViewAction

    weak var listener: HomePresentableListener?

    @Published var state: State

    init(listener: HomePresentableListener? = nil,
         state: State) {
        self.listener = listener
        self.state = state
    }

    func update(state: State) {
        self.state = state
    }
    
    func request(action: Action) {
        listener?.request(action: action)
    }
}

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .center) {
                Spacer()

                Button("Tap1 Action Button") {
                    viewModel.request(action: .tap1)
                }
                
                Button("Tap2 Action Button") {
                    viewModel.request(action: .tap2)
                }

                Spacer()
                    .frame(height: 10)

                Text(viewModel.state.title)
                    .font(.title)
                    .border(.gray)

                Spacer()
                    .frame(height: 10)

                Text(viewModel.state.desc)
                    .font(.title)
                    .border(.gray)

                Spacer()
            }
            Spacer()
        }
        .border(Color.blue)
        .padding()
    }
}

```
`ViewModel`은 `PresentableListener`를 weak 변수로 가지고 있습니다. `PresentableListener` 는 `Interactor`로 weak를 통해 순환참조를 하지 않도록 주의합니다. 또한, `ViewModel`은 `PresentableListener`를 통해 `Interactor`에 View에서 발생한 액션을 전달할 수 있습니다.

다시 `Presenter(ViewController)`로 돌아가서, `View`를 `rootView`로 가지는 `UIHostingController`를 `ViewController`에 추가합니다.

```swift
/// FileName : HomeViewController.swift

import SwiftUI
import UIKit

protocol HomePresentableListener: AnyObject {
    func request(action: HomeViewAction)
}

final class HomeViewController: UIViewController, HomePresentable, HomeViewControllable {
    weak var listener: HomePresentableListener?

    private lazy var viewModel = HomeViewModel(listener: listener, state: .init(title: "Hello", desc: "World"))

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Hello World"

        let rootView = HomeView(viewModel: viewModel)
        let contentVC = UIHostingController(rootView: rootView)
        addChild(contentVC)
        contentVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentVC.view)
        contentVC.didMove(toParent: self)

        NSLayoutConstraint.activate([
            contentVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            contentVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        listener?.request(action: .viewDidLoad)
    }

    func update(state: HomeViewState) {
        viewModel.update(state: state)
    }
}
```

ViewController에서는 `ViewModel`을 가지고 있어 상태값을 `ViewModel`에 전달하여 View를 갱신하도록 할 수 있습니다. 또한, listener에 값이 할당되면, `ViewModel`의 `PresentableListener`에도 할당을 하여 ViewModel에서 `Interactor`를 호출할 수 있도록 합니다.

위 ViewController의 viewDidLoad 함수 내부를 정리하도록 합시다.

```swift
/// FileName : HomeViewController.swift

final class HomeViewController: UIViewController, HomePresentable, HomeViewControllable {
    ...
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Hello World"

        HomeView(viewModel: viewModel)
            .attach(to: self)

        listener?.request(action: .viewDidLoad)
    }
}

extension View {
    func attach(to parentViewController: UIViewController) {
        let contentVC = UIHostingController(rootView: self)
        let parentVC = parentViewController

        parentVC.addChild(contentVC)
        contentVC.view.translatesAutoresizingMaskIntoConstraints = false
        parentVC.view.addSubview(contentVC.view)
        contentVC.didMove(toParent: parentVC)
        
        NSLayoutConstraint.activate([
            contentVC.view.topAnchor.constraint(equalTo: parentVC.view.topAnchor),
            contentVC.view.bottomAnchor.constraint(equalTo: parentVC.view.bottomAnchor),
            contentVC.view.leadingAnchor.constraint(equalTo: parentVC.view.leadingAnchor),
            contentVC.view.trailingAnchor.constraint(equalTo: parentVC.view.trailingAnchor),
        ])
    }
}
```

다음으로, Interactor에서 HomePresentableListener를 채택한 코드를 구현해봅시다.

```swift
/// FileName : HomeInteractor.swift
import RIBs
import RxSwift

protocol HomeRouting: ViewableRouting {}

protocol HomePresentable: Presentable {
    var listener: HomePresentableListener? { get set }
    func update(state: HomeViewState)
}

protocol HomeListener: AnyObject {}

final class HomeInteractor: PresentableInteractor<HomePresentable>, HomeInteractable, HomePresentableListener {
    weak var router: HomeRouting?
    weak var listener: HomeListener?

    override init(presenter: HomePresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    func request(action: HomeViewAction) {
        let state: HomeViewState
        switch action {
        case .viewDidLoad:
            state = .init(title: "ViewDidLoad Action",
                          desc: "Number \(Int.random(in: 0 ... 5))")
        case .tap1:
            state = .init(title: "Tap1 Action",
                          desc: "Tap1 Number \(Int.random(in: 0 ... 5))")
        case .tap2:
            state = .init(title: "Tap2 Action",
                          desc: "Tap2 Number \(Int.random(in: 0 ... 5))")
        }
        presenter.update(state: state)
    }
}
```

`Interactor`에서 상태값을 만들어 `Presentable` 프로토콜에서 정의한 `update(state:)` 함수를 호출하여 `Presentable`를 채택한 ViewController에 전달합니다. 그러면 ViewController에서는 ViewModel에 다시 전달하여 View를 갱신하게 합니다.

<br/><video src="{{ site.prod_url }}/image/2023/07/11.mp4" width="400" controls autoplay loop></video><br/>

ViewModel은 상태값을 전달받아 View에 전달하여 화면을 갱신하고, View의 이벤트를 받아 다시 PresentableListener에 전달하므로, Preview 작성시 해당 작업을 쉽게 구현할 수 있습니다.

```swift
/// FileName : HomeView.swift

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    typealias State = HomeViewState
    typealias Action = HomeViewAction
    typealias ViewModel = HomeViewModel

    class Listener: HomePresentableListener {
        var viewModel: ViewModel?

        func request(action: Action) {
            let state: State
            switch action {
            case .viewDidLoad:
                state = .init(title: "Preview ViewDidLoad Action",
                              desc: "Number \(Int.random(in: 0 ... 5))")
            case .tap1:
                state = .init(title: "Preview Tap1 Action",
                              desc: "Tap1 Number \(Int.random(in: 0 ... 5))")
            case .tap2:
                state = .init(title: "Preview Tap2 Action",
                              desc: "Tap2 Number \(Int.random(in: 0 ... 5))")
            }
            viewModel?.update(state: state)
        }
    }
    
    static let listener = Listener()
    
    static var previews: some View {
        let state = State(title: "Hello", desc: "World")
        let vm = HomeViewModel(listener: listener, state: state)
        let view = HomeView(viewModel: vm)
        listener.viewModel = vm
        
        return view
    }
}
#endif
```

<br/><video src="{{ site.prod_url }}/image/2023/07/12.mov" width="800px" controls autoplay loop></video>

## 정리

* UIViewController의 View 역할을 SwiftUI의 View로 대신하면 기존 아키텍처에 SwiftUI와 공존이 가능

## 참고자료

* [SwiftbySundell - SwiftUI and UIKit interoperability - Part 2](https://www.swiftbysundell.com/articles/swiftui-and-uikit-interoperability-part-2/)
* LINE LIVE iOS의 SwiftUI - 기술 선택과 구현[YouTube](https://www.youtube.com/watch?v=HZtH67dBp4Y)
* iOSDC
  * 2022
    * [SwiftUI in UIKit으로 개발하는 세상](https://speakerdeck.com/hcrane/iosdc2022-swiftui-in-uikit-dekai-fa-surushi-jie)
      * [YouTube](https://www.youtube.com/watch?v=6nWnQVRVcs0)
    * [UIKit 기반의 대규모 프로젝트에 SwiftUI 도입](https://speakerdeck.com/kuritatu18/uikit-besunoda-gui-mo-napuroziekutoheno-swiftui-dao-ru)
      * [YouTube](https://www.youtube.com/watch?v=KJ7zzk9fj8E)
    * [SwiftUI와 UIKit을 친해지게 한다](https://speakerdeck.com/auramagi/iosdc-2022-swiftui-uikit)
      * [YouTube](https://www.youtube.com/watch?v=5C7cryhPhvk)
  * 2023
    * [SwiftUI 등장 전의 VIPER 앱에서도 SwiftUI를 원활하게 도입 할 수 있었던 이야기](https://speakerdeck.com/shincarpediem/swiftuideng-chang-qian-noviperapuridemoswiftuiwosumuzunidao-ru-dekitahua)
* [Clean Architecture for SwiftUI](https://nalexn.github.io/clean-architecture-swiftui/)
* [The Strategic SwiftUI Data Flow Guide](https://matteomanferdini.com/swiftui-data-flow/)
* [I was wrong! MVVM is NOT a good choice for building SwiftUI applications](https://azamsharp.com/2022/07/17/2022-swiftui-and-mvvm.html)
* Mobility Technologies
  * [첫 RIBs](https://speakerdeck.com/imairi/chu-metefalse-ribs)
  * [JapanTaxi iOS 앱에 RIBs 아키텍처를 도입하여 얻은 것](https://lab.mo-t.com/blog/andonlabo-4-ribs-ios-app)
  * [RIBs 아키텍처를 사용하는 기존 앱에 SwiftUI 도입](https://lab.mo-t.com/blog/ios-ribs-swiftui)
* [Cookpad - SwiftUI를 활용한 「레시피」×「쇼핑」의 신기능 개발](https://techlife.cookpad.com/entry/2021/01/18/kaimono-swift-ui)

## 전체코드

* [Gist](https://gist.github.com/minsOne/256bbe28c54ff3a67fbeb14953b71711)
* [GitHub](https://github.com/minsOne/Experiment-Repo/tree/master/20230720/SampleApp)

#### HomeViewStateAction.swift

```swift
/// FileName : HomeViewStateAction.swift
import Foundation

struct HomeViewState {
    var title: String
    var desc: String
}

enum HomeViewAction {
    case viewDidLoad
    case tap1
    case tap2
}
```

#### HomeInteractor.swift

```swift
/// FileName : HomeInteractor.swift
import RIBs
import RxSwift

protocol HomeRouting: ViewableRouting {}

protocol HomePresentable: Presentable {
    var listener: HomePresentableListener? { get set }
    func update(state: HomeViewState)
}

protocol HomeListener: AnyObject {}

final class HomeInteractor: PresentableInteractor<HomePresentable>, HomeInteractable, HomePresentableListener {
    weak var router: HomeRouting?
    weak var listener: HomeListener?

    override init(presenter: HomePresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    func request(action: HomeViewAction) {
        let state: HomeViewState
        switch action {
        case .viewDidLoad:
            state = .init(title: "ViewDidLoad Action",
                          desc: "Number \(Int.random(in: 0 ... 5))")
        case .tap1:
            state = .init(title: "Tap1 Action",
                          desc: "Tap1 Number \(Int.random(in: 0 ... 5))")
        case .tap2:
            state = .init(title: "Tap2 Action",
                          desc: "Tap2 Number \(Int.random(in: 0 ... 5))")
        }
        presenter.update(state: state)
    }
}
```

#### HomeViewController.swift

```swift
/// FileName : HomeViewController.swift
import UIKit
import SwiftUI

protocol HomePresentableListener: AnyObject {
    func request(action: HomeViewAction)
}

final class HomeViewController: UIViewController, HomePresentable, HomeViewControllable {
    weak var listener: HomePresentableListener?
    
    lazy var viewModel = HomeViewModel(listener: listener, state: .init(title: "Hello", desc: "World"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Hello World"
        
        HomeView(viewModel: viewModel)
            .attachTo(ViewController: self)
        
        listener?.request(action: .viewDidLoad)
    }
    
    func update(state: HomeViewState) {
        viewModel.update(state: state)
    }
}

extension View {
    func attachTo(ViewController parentViewController: UIViewController) {
        let contentVC = UIHostingController(rootView: self)
        let parentVC = parentViewController

        parentVC.addChild(contentVC)
        contentVC.view.translatesAutoresizingMaskIntoConstraints = false
        parentVC.view.addSubview(contentVC.view)
        contentVC.didMove(toParent: parentVC)
        
        NSLayoutConstraint.activate([
            contentVC.view.topAnchor.constraint(equalTo: parentVC.view.topAnchor),
            contentVC.view.bottomAnchor.constraint(equalTo: parentVC.view.bottomAnchor),
            contentVC.view.leadingAnchor.constraint(equalTo: parentVC.view.leadingAnchor),
            contentVC.view.trailingAnchor.constraint(equalTo: parentVC.view.trailingAnchor),
        ])
    }
}
```

#### HomeView.swift

```swift
/// FileName: HomeView.swift
import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    typealias State = HomeViewState
    typealias Action = HomeViewAction

    weak var listener: HomePresentableListener?

    @Published var state: State

    init(listener: HomePresentableListener? = nil,
         state: State)
    {
        self.listener = listener
        self.state = state
    }

    func update(state: State) {
        self.state = state
    }

    func request(action: Action) {
        listener?.request(action: action)
    }
}

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .center) {
                Spacer()

                Button("Tap1 Action Button") {
                    viewModel.request(action: .tap1)
                }
                
                Button("Tap2 Action Button") {
                    viewModel.request(action: .tap2)
                }

                Spacer()
                    .frame(height: 10)

                Text(viewModel.state.title)
                    .onChange(of: viewModel.state.title) { _ in
                        print("title changed to \(viewModel.state.desc)!")
                    }
                    .font(.title)
                    .border(.gray)

                Spacer()
                    .frame(height: 10)

                Text(viewModel.state.desc)
                    .onChange(of: viewModel.state.desc) { _ in
                        print("desc changed to \(viewModel.state.desc)!")
                    }
                    .font(.title)
                    .border(.gray)

                Spacer()
            }
            Spacer()
        }
        .border(Color.blue)
        .padding()
    }
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    typealias State = HomeViewState
    typealias Action = HomeViewAction
    typealias ViewModel = HomeViewModel

    class Listener: HomePresentableListener {
        var viewModel: ViewModel? {
            didSet { viewModel?.listener = self }
        }

        func request(action: Action) {
            let state: State
            switch action {
            case .viewDidLoad:
                state = .init(title: "Preview ViewDidLoad Action",
                              desc: "Number \(Int.random(in: 0 ... 5))")
            case .tap1:
                state = .init(title: "Preview Tap1 Action",
                              desc: "Tap1 Number \(Int.random(in: 0 ... 5))")
            case .tap2:
                state = .init(title: "Preview Tap2 Action",
                              desc: "Tap2 Number \(Int.random(in: 0 ... 5))")
            }
            viewModel?.update(state: state)
        }
    }
    
    static let listener = Listener()
    
    static var previews: some View {
        let state = State(title: "Hello", desc: "World")
        let view = HomeView(viewModel: .init(state: state))
        listener.viewModel = view.viewModel
        
        return view
    }
}
#endif
```


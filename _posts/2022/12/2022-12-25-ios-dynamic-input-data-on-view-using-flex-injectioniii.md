---
layout: post
title: "[iOS] FLEX, InjectionIII를 활용하여 View에 동적으로 데이터를 전달하기"
tags: [iOS, Hot Reload, Preview, Inject, InjectionIII, FLEX, Debug, Tool]
---
{% include JB/setup %}

일반적으로 View를 확인하기 위해서는 Preview를 활용한다던가, 또는 데모앱을 띄워서 확인해야 합니다. Preview는 특정 상태인 경우들만 확인이 가능합니다. 데모앱을 띄우더라도, 동적으로 데이터 변경이 일어나는 것을 확인하기 위해 디버깅 전용 버튼을 만드는 등 많은 작업이 필요합니다. 

즉, 정적인 화면들은 확인할 수 있지만, 다양한 데이터가 동적으로 반영되는 것을 확인하기는 쉽지 않습니다.

만약에 디버깅때 필요한 버튼을 만들고, 누르는 것이 아니라, iOS 시뮬레이터에서 하드웨어 키보드의 입력을 받아 View에 데이터를 전달할 수 있다면 어떨까요?

View에는 Delegate 등의 방법으로 데이터 전달받도록 한 상태에서, 여러가지 경우의 데이터를 준비하고, 하드웨어 키보드 입력을 통해 데이터를 전달하면 별도의 비즈니스 로직을 가진 구현체가 없더라도 View에 잘 반영되는지 확인할 수 있습니다.

디버깅시 유용한 라이브러리 중 하나인 **[FLEX](https://github.com/FLEXTool/FLEX)**는 여러가지 기능을 제공합니다.

그 중에 **[Simulator Keyboard Shortcuts](https://github.com/FLEXTool/FLEX#simulator-keyboard-shortcuts)** 기능을 제공하는데, iOS 시뮬레이터에서 특정 키를 입력했을 때, 후킹하여 FLEX에 등록된 기존 명령을 호출한다던가 혹은 커스텀으로 등록할 수 있습니다.

FLEX를 이용하여 동적으로 데이터를 전달하는 예제를 작성해봅시다.

## FLEX를 이용한 예제

먼저 View의 코드를 작성해봅시다.

ViewController에서는 viewDidLoad시 Listener에 ViewDidLoad 됬음을 알리고, 배경색 변경 요청을 받아 수행하는 코드를 작성합니다.

```swift
/// FileName : ViewController.swift

import Combine
import UIKit

enum ViewState {
  case backgroundColor(UIColor)
}

enum ViewAction {
  case viewDidLoad
}

protocol ViewControllerListener: AnyObject {
  func request(action: ViewAction)
  
  var uiState: PassthroughSubject<ViewState, Error> { get }
}

class ViewController: UIViewController {
  
  weak var listener: ViewControllerListener?
  
  var bag = Set<AnyCancellable>()
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    bind()
    
    listener?.request(action: .viewDidLoad)
  }
}

private extension ViewController {
  func bind() {
    listener?.uiState.sink(
      receiveCompletion: { _ in },
      receiveValue: { [weak self] state in
        self?.update(state)
      }).store(in: &bag)
  }
}

private extension ViewController {
  func update(_ state: ViewState) {
    switch state {
    case .backgroundColor(let color):
      change(backgroundColor: color)
    }
  }
  
  func change(backgroundColor color: UIColor) {
    view.backgroundColor = color
  }
}
```

여기에 비동기로 backgroundColor State를 ViewController에 전달하기 위해서는 별도의 버튼을 만들어 데이터를 넘겨줘야 했습니다. 혹은 LLDB를 이용하여 ViewController의 객체에 접근하여 호출하는 방식이거나요.

하지만 그런 방법들은 명확하지 않거나, 기존의 코드에 영향을 미치게 됩니다.

대신 ViewControllerListener Protocol을 만족하는 Mock 객체를 만들고, 해당 객체에서 FLEX 라이브러리를 이용해 키보드 입력시 등록된 데이터를 넘겨준다면 어떨까요? 

```swift
/// FileName : ViewControllerListenerMock.swift

import Combine
import Foundation
import FLEX
import UIKit

class ViewControllerListenerMock: ViewControllerListener {
  let uiState: PassthroughSubject<ViewState, Error> = .init()
  
  init() {
    self.register()
  }
  
  func request(action: ViewAction) {
    print(#function, action)
  }
  
  func register() {
    FLEXManager.shared.registerSimulatorShortcut(
      withKey: "1",
      modifiers: .init(rawValue: 0),
      action: { [weak self] in 
        self?.uiState.send(.backgroundColor(.systemRed))
      },
      description: "")
    
    FLEXManager.shared.registerSimulatorShortcut(
      withKey: "2",
      modifiers: .init(rawValue: 0),
      action: { [weak self] in
        self?.uiState.send(.backgroundColor(.systemBlue))
      },
      description: "")
    
    FLEXManager.shared.registerSimulatorShortcut(
      withKey: "3",
      modifiers: .init(rawValue: 0),
      action: { [weak self] in
        self?.uiState.send(.backgroundColor(.systemGreen))
      },
      description: "")
  }
}
```

위의 Mock 객체를 ViewController에 할당하고, iOS 시뮬레이터에서 데모앱을 실행하여 다음과 같이 잘 동작을 하는 것을 확인할 수 있었습니다.

<br/><video src="{{ site.production_url }}/image/2022/12/20221225_01.mp4" width="400" controls autoplay></video><br/>

## InjectionIII와 FLEX를 이용한 예제
이전에 [InjectionIII](https://github.com/johnno1962/InjectionIII)를 활용하여 코드를 실시간으로 변경할 수 있는 글을 작성한 바가 있습니다. [링크 - DemoApp과 Inject의 Hot Reload를 이용해서 빠른 개발하기](../ios-project-generate-with-tuist-7)

InjectionIII와 FLEX를 활용하면, 하드웨어 키보드로 선택적으로 값을 넘길 수 있고, 값을 실시간으로 수정하고, 수정된 값을 전달하는 것이 가능합니다.

InjectionIII 사용하기 쉽게 래핑한 [Inject](https://github.com/krzysztofzablocki/Inject)를 추가하고, Mock에서 코드가 변경되었을때, 다시 하드웨어 키보드 단축어를 등록할 수 있도록 하였습니다.

```swift
/// FileName : ViewControllerListenerMock.swift

import Combine
import Foundation
import FLEX
import UIKit
import Inject

class ViewControllerListenerMock: ViewControllerListener {
  let uiState: PassthroughSubject<ViewState, Error> = .init()
  
  init() {
    _ = Inject.load

    self.register()

    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(register),
                   name: Notification.Name("INJECTION_BUNDLE_NOTIFICATION"), object: nil)
  }
  
  func request(action: ViewAction) {
    print(#function, action)
  }
  
  @objc func register() {
    FLEXManager.shared.registerSimulatorShortcut(
      withKey: "1",
      modifiers: .init(rawValue: 0),
      action: { [weak self] in 
        self?.uiState.send(.backgroundColor(.systemRed))
        // self?.uiState.send(.backgroundColor(.black))
      },
      description: "")
    
    FLEXManager.shared.registerSimulatorShortcut(
      withKey: "2",
      modifiers: .init(rawValue: 0),
      action: { [weak self] in
        self?.uiState.send(.backgroundColor(.systemBlue))
        // self?.uiState.send(.backgroundColor(.gray))
      },
      description: "")
    
    FLEXManager.shared.registerSimulatorShortcut(
      withKey: "3",
      modifiers: .init(rawValue: 0),
      action: { [weak self] in
        self?.uiState.send(.backgroundColor(.systemGreen))
        // self?.uiState.send(.backgroundColor(.orange))
      },
      description: "")
  }
}
```

데모앱을 실행 한 후, 색상 값을 변경, 소스를 저장한 뒤, InjectionIII를 활용하여 수정된 코드가 반영되었는지 확인할 수 있었습니다.

<br/><video src="{{ site.production_url }}/image/2022/12/20221225_02.mp4" width="800" controls autoplay></video><br/>

FLEX의 registerSimulatorShortcut 함수를 래핑한 코드입니다.

```swift
import Foundation
import FLEX

public struct SimulatorShortcut {

    /// 시뮬레이터에서 키보드 입력을 받아 block을 수행하는 기능
    ///
    /// FLEX의 registerSimulatorShortcut 함수를 조금 더 쉽게 사용하기 위해 래핑함
    ///
    /// - Parameters:
    ///   - key: 키보드에서 입력받을 키
    ///   - modifiers: shift, command, alt/option 등의 Modifier 키
    ///   - action: 키와 Modifier 키 조합을 눌렀을 때, 메인스레드에서 실행하는 block
    ///   - description: '?' 키를 눌렀을 때 help 메뉴에서 표시하는 설명
    public static func register(with key: String,
                                modifiers: UIKeyModifierFlags? = nil,
                                action: @escaping () -> Void,
                                description: String = "") {
        let modifiers: UIKeyModifierFlags = modifiers ?? .init(rawValue: 0)

        FLEXManager.shared
            .registerSimulatorShortcut(withKey: key,
                                       modifiers: modifiers,
                                       action: action,
                                       description: description)
    }
}
```

## 참고자료

* Github
  * [FLEXTool/FLEX](https://github.com/FLEXTool/FLEX)
  * [krzysztofzablocki/Inject](https://github.com/krzysztofzablocki/Inject)
  * [johnno1962/InjectionIII](https://github.com/johnno1962/InjectionIII)
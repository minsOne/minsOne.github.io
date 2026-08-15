---
layout: post
title: "[Swift] UI 모듈의 공개 인터페이스와 내부 구현 분리하기"
tags: [Swift, UIKit, Modularization, Access Control]
---
{% include JB/setup %}

우리는 화면을 독립적으로 개발하고 테스트하기 위해 UI를 별도 모듈로 분리합니다. UI 모듈만 빌드하거나 테스트할 수 있어 다른 기능과 분리된 상태로 작업하기 쉽습니다.

하지만 모듈을 나눠도 UI 구현 타입을 모두 공개하면 외부 모듈과의 의존성은 그대로 남습니다. 외부에서 필요한 타입만 공개하고, 화면 구현에 사용하는 타입은 UI 모듈 안에 남겨야 합니다.

UI 모듈에서는 ViewController 구현체를 외부에 공개하기 쉽습니다. 외부 모듈이 화면을 생성하고 화면 계층에 연결해야 하기 때문입니다.

```swift
public final class FundViewController: UIViewController {
  public override func viewDidLoad() {
    super.viewDidLoad()
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
}
```

ViewController 구현체를 공개하면 외부 모듈에서 화면을 쉽게 생성할 수 있습니다. 대신 `FundViewController`의 이름과 생성 방식도 공개 인터페이스에 포함됩니다. `viewDidLoad()`와 같은 UIKit 메서드에도 공개 접근 제어자가 필요합니다.

`FundViewController`의 타입 이름이나 생성 방식을 바꾸면 이를 사용하는 외부 모듈도 함께 수정해야 합니다.

## UI 모듈의 공개 인터페이스

ViewController 구현체를 숨기려면 외부 모듈이 UI를 사용할 방법을 별도의 인터페이스로 정의해야 합니다. 외부에서 UI로 전달하는 값은 State로 표현하고, UI에서 발생한 이벤트는 Action으로 만들어 Listener를 통해 전달할 수 있습니다.

State, Action, Protocol, 화면 생성 함수는 `FundPresenter.swift`에 모아 UI 모듈의 공개 인터페이스를 한곳에서 관리합니다.

```swift
public enum FundPresenterAction {
  case initialLoadRequested
  case tappedCTA
}

public enum FundPresentableState {
  case loading
  case content(info: UserInfo)
  case error(message: String)
}

@MainActor
public protocol FundPresentable: AnyObject {
  var listener: (any FundPresentableListener)? { get set }

  func render(_ state: FundPresentableState)
}

@MainActor
public protocol FundPresentableListener: AnyObject {
  func uiAction(_ action: FundPresenterAction)
}
```

화면 생성은 `FundPresenter.build()`로 제공합니다.

```swift
public enum FundPresenter {
  @MainActor
  public static func build() -> any FundPresentable & UIViewController {
    FundViewController()
  }
}
```

`build()`는 `FundViewController`를 직접 공개하지 않고 `any FundPresentable & UIViewController`를 반환합니다. 외부 모듈은 `FundViewController`라는 구현체를 알 필요 없이 화면을 생성할 수 있습니다.

## 구체 타입을 내부 구현으로 남기기

구체적인 UI 구현은 `FundViewController.swift`에 작성합니다.

```swift
final class FundViewController: UIViewController, FundPresentable {

  weak var listener: (any FundPresentableListener)?

  override func viewDidLoad() {
    super.viewDidLoad()

    configureUI()
    listener?.uiAction(.initialLoadRequested)
  }

  func render(_ state: FundPresentableState) {
    switch state {
    case .loading:
      showLoading()

    case let .content(info):
      showContent(info)

    case let .error(message):
      showError(message)
    }
  }

  private func ctaDidTap() {
    listener?.uiAction(.tappedCTA)
  }
}
```

`FundViewController`는 모듈 내부 타입이므로 `public`이나 `package`를 붙일 필요가 없습니다. UIKit 메서드에도 별도의 접근 제어자를 붙일 필요가 없습니다. 이는 자연스러운 결과입니다. 외부 모듈은 `FundViewController`를 알 필요가 없고, UI 구현이 바뀌더라도 외부 모듈에는 영향을 주지 않습니다.

## 파일 단위로 역할 나누기

`FundPresenter.swift`에는 State, Action, Listener, 화면 생성 함수처럼 외부 모듈에서 사용하는 코드를 작성합니다.

`FundViewController.swift`에는 State를 화면에 반영하고, 사용자 입력을 Action으로 바꾸어 전달하는 코드를 작성합니다.

외부와 주고받는 내용이 바뀌면 `FundPresenter.swift`를 수정하고, 화면 표현이나 사용자 입력 처리가 바뀌면 `FundViewController.swift`를 수정합니다.

## 정리

외부 모듈이 ViewController 대신 State, Action, Protocol에 의존합니다. 공개 인터페이스가 유지되는 동안 내부 ViewController의 코드는 외부에 영향을 주지 않고 변경할 수 있습니다.

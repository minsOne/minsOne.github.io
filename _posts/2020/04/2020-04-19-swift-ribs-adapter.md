---
layout: post
title: "[Swift5][RIBs] Uber의 RIBs 프로젝트에서 얻은 경험 (5) - Adapter"
description: ""
category: "programming"
tags: [iOS, Swift, Uber, RIBs, Adapter, Dependency]
---
{% include JB/setup %}

## Dynamic dependencies vs Static dependencies

RIBs에서는 의존성을 Static과 Dynamic 두 방식으로 주입할 수 있습니다. Static Dependency는 Dependency에 선언을 해놓고, 부모 RIB 또는 더 상위의 RIB의 Component에서 구현하는 방식입니다.

```swift
//MARK: - Static Dependency

//MARK: - Child RIB
protocol ChildDependency: Dependency {
  var name: String { get }
}

final class ChildComponent: Component<ChildDependency> {
  fileprivate var name: String { dependency.name }
}

protocol ChildBuildable: Buildable {
  func build(withListener listener: ChildListener) -> ChildRouting
}

final class ChildBuilder: Builder<ChildDependency>, ChildBuildable {
  override init(dependency: ChildDependency) {
    super.init(dependency: dependency)
  }

  func build(withListener listener: ChildListener) -> ChildRouting {
    let component = ChildComponent(dependency: dependency)
    let viewController = ChildViewController()
    let interactor = ChildInteractor(presenter: viewController, name: component.name)
    interactor.listener = listener
    return ChildRouter(interactor: interactor, viewController: viewController)
  }
}

//MARK: - Parent RIB
protocol ParentDependency: Dependency {

}

final class ParentComponent: Component<ParentDependency>, ChildDependency {
  let name: String

  init(dependency: ParentDependency, name: String) {
    self.name = name
    super.init(dependency: dependency)
  }
}

protocol ParentBuildable: Buildable {
  func build(withListener listener: ParentListener, name: String) -> ParentRouting
}

final class ParentBuilder: Builder<ParentDependency>, ParentBuildable {
  override init(dependency: ParentDependency) {
    super.init(dependency: dependency)
  }

  func build(withListener listener: ParentListener, name: String) -> ChildRouting {
    let component = ParentComponent(dependency: dependency, name: name)
    let viewController = ParentViewController()
    let interactor = ParentInteractor(presenter: viewController, name: component.name)
    interactor.listener = listener
    let childBuilder = ChildBuilder(dependency: component)
    return ParentRouter(interactor: interactor, viewController: viewController, childBuilder: childBuilder)
  }
}
```

Child RIB이 요구한 Static Dependency인 name을 Parent RIB의 Component가 가지고 있어야 하는데, Parent Builder가 build시 name을 받아와 Component에 넣어줍니다. Parent RIB이 Child RIB의 Dependency를 맞추기 위해 build 함수를 확장한 Dynamic Dependency 방식을 사용하였습니다. 하지만 위와 같이 코드를 작성하게 되면 Parent의 부모 RIB이 name을 가지고 있다가 Parent RIB에 넘겨줘야 한다는 의미입니다. 

하지만 이렇게 작성하면 중간 Layer를 담당하는 RIB이 많아지므로, RIB 추가가 아닌 Adapter 방식을 이용하여 중간 Layer를 쉽게 만들 것입니다.

## Adapter

Child에서 요구하는 Static Dependency는 Parent가 Dynamic Dependency로 처리하던 방식으로 Adapter가 사용합니다. Adapter 내부에는 ChildDependency를 따르는 Component를 만들어 사용합니다. 그리고 ChildListener는 Adapter가 상속받아 구현합니다. Adapter는 부모 RIB에게 두 가지 방식으로 Child RIB에서 호출한 결과를 던져줄 수 있습니다.

첫번째는 Adapter의 Listener를 만들어 Child RIB에서 Listener로 호출한 값은 AdapterListener로 감싸 부모 RIB에 넘깁니다. 두번째는 ChildListener를 그대로 부모 RIB에서 넘겨주도록 할 수 있습니다.

먼저 첫번째 버전을 만들어보도록 합시다.

```swift
// MARK: - AdapterListener 버전

protocol ChildAdapterListener: class {
  func request()
}

protocol ChildAdapterBuildable: Buildable {
  func build(withListener listener: ChildAdapterListener, name: String) -> ViewableRouting
}

final class ChildAdapter: ChildListener, ChildAdapterBuildable {
  final class Component: ChildDependency {
    let name: String
    init(name: String) {
      self.name = name
    }
  }

  private weak var listener: ChildAdapterListener?

  init() {}

  func build(withListener listener: ChildAdapterListener, name: String) -> ViewableRouting {
    let component = Component(name: name)
    let childBuilder = ChildBuilder(dependency: component)
    self.listener = listener
    return childBuilder.build(withListener: self)
  }

  func requestFromChildRIB() {
    listener?.request()
  }
}
```

위의 코드를 하나씩 분석해봅시다.

```swift
protocol ChildAdapterListener: class {
  func request()
}
```

ChildAdapterListener를 선언하고 Child RIB에서 오는 호출을 꺽어 부모 RIB에 ChildAdapterListener에 선언된 함수로 호출하도록 합니다.

```swift
protocol ChildAdapterBuildable: Buildable {
  func build(withListener listener: ChildAdapterListener, name: String) -> ViewableRouting
}
```

그리고 ChildAdapterBuildable을 선언하고, ChildAdapterListener와 name을 인자로 받는 build 함수를 선언합니다. 

```swift
final class ChildAdapter: ChildListener, ChildAdapterBuildable {
  final class Component: ChildDependency {
    let name: String
    init(name: String) { self.name = name }
  }
}
```

Adapter는 ChildListener를 상속받아 Child RIB에서 호출을 받을 수 있도록 합니다. 그리고 Component가 ChildDependency를 상속받아 Static Dependency를 만족하도록 합니다.

```swift
final class ChildAdapter: ChildListener, ChildAdapterBuildable {
  ...

  init() {}

  func build(withListener listener: ChildAdapterListener, name: String) -> ViewableRouting {
    let component = Component(name: name)
    let childBuilder = ChildBuilder(dependency: component)
    self.listener = listener
    return childBuilder.build(withListener: self)
  }
}
```

Adapter는 아무런 값을 가지거나 하지 않기 때문에 init 함수는 한줄로 끝납니다.

build 함수에서는 Component를 생성하고, Child Builder의 Dependency를 만족시킵니다. 그리고 Child Router를 반환하도록 합니다.

```swift
final class ChildAdapter: ChildListener, ChildAdapterBuildable {
  ...

  func requestFromChildRIB() {
    listener?.request()
  }
}
```

Child Listener를 따르기 때문에 해당 함수를 구현하여 만족시키고, 다시 부모 RIB에 호출하도록 합니다.

이렇게 AdapterListener를 가지는 Adapter를 만들어보았습니다.

---

이제 AdapterListenr를 가지지 않고, 단순 전달만 하는 두번째 Adapter를 만들어봅시다.


```swift
// MARK: - 단순 전달만 하는 Adapter 버전

protocol ChildAdapterBuildable: Buildable {
  func build(withListener listener: ChildListener, name: String) -> ViewableRouting
}

final class ChildAdapter: ChildListener, ChildAdapterBuildable {
  final class Component: ChildDependency {
    let name: String
    init(name: String) {
      self.name = name
    }
  }

  private weak var listener: ChildListener?

  init() {}

  func build(withListener listener: ChildListener, name: String) -> ViewableRouting {
    let component = Component(name: name)
    let childBuilder = ChildBuilder(dependency: component)
    self.listener = listener
    return childBuilder.build(withListener: self)
  }

  func requestFromChildRIB() {
    listener?.requestFromChildRIB()
  }
}
```

첫번째 버전과는 다르게 부모 RIB이 ChildAdapter를 사용할 때 ChildAdapterListener 대신 ChildListener를 따르도록 해야합니다. 그렇기 때문에 더 단순하게 만들 수 있습니다. 만약 Child Listener에 선언된 것이 작다면 두번째 방식을 택하는 것도 좋습니다.

<br/>

이렇게 특정 RIB을 Adapter로 감싸 Dependency를 build 함수의 확장하는 Dynamic Dependency 방식으로 처리할 수 있으며, Adapter를 더 다양한 방법으로도 이용할 수 있습니다. RIBs 튜토리얼4에 Adapter가 구현된 코드가 있으니 확인할 수 있습니다. [튜토리얼 Adapter 코드](https://github.com/uber/RIBs/blob/master/ios/tutorials/tutorial4-completed/TicTacToe/LoggedIn/RandomWinAdapter.swift)

## 참고자료

* [Uber/RIBs - Wiki/Tutorial3 - RIBs Dependency Injection and Communication](https://github.com/uber/RIBs/wiki/iOS-Tutorial-3)

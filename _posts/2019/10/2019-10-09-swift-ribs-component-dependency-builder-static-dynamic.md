---
layout: post
title: "[Swift5][RIBs] Uber의 RIBs 프로젝트에서 얻은 경험 (3) - Dependency와 Component 그리고 Builder"
description: ""
category: "programming"
tags: [iOS, Swift, Uber, RIBs]
---
{% include JB/setup %}

## Dependency와 Component 그리고 Builder

일반적으로 RIB에서는 Dependency에 필요한 데이터를 정의를 하고, 해당 Dependency를 따르는 부모 Component는 이를 구현해야 합니다.

```
/// MARK: Child RIB

protocol ChildDependency: Dependency {
	var name: String { get }
}

final class ChildComponent: Component<ChildDependency> {
	fileprivate var name: String {
		return dependency.name
	}
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
    	...
    }
}


/// MARK: Parent RIB

protocol ParentDependency: Dependency {}

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

    func build(withListener listener: ParentListener, name: String) -> ParentRouting {
    	let component = ParentComponent(dependency: dependency, name: name)
    	...
    }
}
```

위와 같은 코드가 됩니다. `부모 Component`가 생성될 때 값을 만들어 넣어야 하며, 이는 `ParentBuildable`의 build 함수에 name을 받아야 하는 추가사항이 되어 버립니다. 즉, build 함수에 name을 받는 다는 이야기는 `조부모 router`가 name을 알고 넣어줘야 한다는 이야기입니다. 만약에 `ChildDependency`를 따르지 않았다면 build 함수에 name을 확장하지 않아도 되었을 것입니다. 

항상 정적인 데이터인 경우는 문제가 없지만, 때에 따라 변경되는 값인 경우는 문제가 됩니다. 조부모 Router에서는 자식 RIB에서 쓰일 name을 알 수도 있지만 모를 수도 있기 때문이죠.

그렇다면 이런 동적인 데이터들은 어떻게 해야 할까요? 스펙이 확장될때마다 ParentBuilder의 build에 추가적으로 값을 더 받아야할까요?

기존 스펙을 유지하면서 Business Logic만을 담당하는 RIB을 앞에 두는 방법과 새로운 Builder를 만드는 방법 두 가지를 사용할 수 있습니다.

## Business Logic RIB 만들기

말 그대로 Business Logic RIB을 만드는 것입니다. Child RIB의 Dependency를 건드릴 수 없기 때문에 Parent RIB과 Child RIB 사이에 RIB을 넣고, 해당 RIB에서 build 함수에 값을 받고, Component를 Child RIB의 Dependency를 만족시킵니다. 그러면 기존의 Parent RIB과 Child RIB을 수정하지 않아도 되므로 깔끔하게 문제가 해결됩니다.

## 새로운 Builder를 만들기

다시 한번 RIB의 B에 해당하는 Builder를 살펴봅시다.

Builder는 Interactor, Router를 만드는 역할을 합니다. 다른 역할을 하는 Interactor, Router가 있다면 `Builder`가 적합한 Interactor와 Router를 선택하여 RIB을 만듭니다. 이 의미를 좀 더 확장하면, Builder도 여러가지 Builder가 있고 적합한 Builder를 선택할 수 있다는 의미입니다.

그러면 적합한 Builder를 선택한다는 말을 좀 더 풀어보면, Builder에는 Dependency와 Component가 속해있으므로, Dependency와 Component 그리고 Builder를 하나 더 만든다는 의미입니다.

```
protocol ChildDynamicNameDependency: Dependency {}

final class ChildDynamicNameComponent: Component<ChildDynamicNameDependency> {
	fileprivate let name: String

	init(dependency: ChildDynamicNameDependency, name: String) {
		self.name = name
		super.init(dependency: dependency)
	}
}

protocol ChildDynamicNameBuildable: Buildable {
    func build(withListener listener: ChildListener, name: String) -> ChildRouting
}

final class ChildDynamicNameBuilder: Builder<ChildDynamicNameDependency>, ChildDynamicNameBuildable {
	override init(dependency: ChildDynamicNameDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: ChildListener, name: String) -> ChildRouting {
    	let component = ChildDynamicNameComponent(dependency: dependency, name: name)
    	...
    }
}
```

위 코드와 같이 Child의 Builder를 새로 만들면 되는 것이죠. Interactor, Router는 그대로 사용하기 때문에 로직은 Build 로직은 그대로 가져오면 됩니다.

하지만 이렇게 작성하게 되면 Dependency를 사용하는 의미가 퇴색되는 것이 아니냐라고 이야기 할 수도 있을 것 같습니다. 하지만 Builder는 외부와 많은 접점을 가질 수 밖에 없기 때문에 필요에 따라 여러 개의 Builder가 만들어질 수 밖에 없다고 생각됩니다.


## 정리

* Builder도 경우에 따라 여러 개의 Builder를 구현하여 선택 사용할 수 있다.
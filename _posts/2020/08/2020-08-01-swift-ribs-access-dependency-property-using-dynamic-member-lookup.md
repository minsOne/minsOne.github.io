---
layout: post
title: "[Swift5.1+][RIBs] dynamicMemberLookup의 KeyPath를 이용하여 Component의 Dependency 속성을 접근하기"
description: ""
category: "programming"
tags: [iOS, Swift, Uber, RIBs, dynamicMemberLookup, KeyPath]
---
{% include JB/setup %}

RIBs에서 Dependency에 정의된 속성을 접근할때는 Component를 이용하여 대부분 fileprivate으로 선언한 속성으로 래핑해서 사용합니다.

```
public protocol UserProfileDependency: Dependency {
  var name: String { get }
  var age: UInt { get }
  var address: String { get }
}

final class UserProfileComponent: Component<UserProfileDependency> {
  fileprivate let name: String
  fileprivate let age: UInt
  fileprivate let address: String

  override init(dependency: UserProfileDependency) {
  	self.name = dependency.name
  	self.age = dependency.age
  	self.address = dependency.address
  	super.init(dependency: dependency)
  }
}
```

Dependency에 정의된 속성이 많을수록 Component의 init에서 일일히 코드를 넣어줘야하는 수고로움이 생깁니다. 또는 let이 아닌 Computed Property로도 만들어 사용하기도 합니다.

```
final class UserProfileComponent: Component<UserProfileDependency> {
  fileprivate var name: String {
  	dependency.name
  }
  fileprivate var age: UInt {
    dependency.age	
  }
  fileprivate var address: String {
  	dependency.address
  }

  override init(dependency: UserProfileDependency) {
  	super.init(dependency: dependency)
  }
}
```

Computed Property로 만들어도 `dependency.~~` 와 같은 코드를 넣어줘야 합니다. 

Swift 5.1 미만 버전까지 위와 같은 코드를 만들어서 사용해야만 했습니다.

Swift 5.1에서 dynamicMemberLookup에 keyPath 기능이 추가되었습니다. [SE-0252](https://github.com/apple/swift-evolution/blob/master/proposals/0252-keypath-dynamic-member-lookup.md)

그러면 dynamicMemberLookup를 이용하여 Component의 Dependency를 접근해봅시다.

```
public protocol UserProfileDependency: Dependency {
  var name: String { get }
  var age: UInt { get }
  var address: String { get }
}

@dynamicMemberLookup
final class UserProfileComponent: Component<UserProfileDependency> {
  override init(dependency: UserProfileDependency) {
  	super.init(dependency: dependency)
  }
  subscript<U>(dynamicMember keyPath: KeyPath<UserProfileDependency, U>) -> U {
    dependency[keyPath: keyPath]
  }
}

public protocol UserProfileBuildable: Buildable {
  func build() -> UserProfileRouting
}

public final class UserProfileBuilder: Builder<UserProfileDependency>, UserProfileBuildable {
  public override init(dependency: UserProfileDependency) {
    super.init(dependency: dependency)
  }
  
  public func build() -> UserProfileRouting {
    let component = UserProfileComponent(dependency: dependency)
    let viewController = UserProfileViewController(name: component.name)
    
    ...

  }
}
```

Component의 코드가 많이 줄어든 것을 확인할 수 있습니다.

만약에 Component에 Dependency와 같은 이름을 가진 속성이 있다면 어떻게 될까요? 그 속성은 Dependency에 있는 속성의 타입과 같을 수도 있고, 다를 수도 있습니다.

```
public protocol UserProfileDependency: Dependency {
  var name: String { get }
  var age: UInt { get }
  var address: String { get }
}

@dynamicMemberLookup
final class UserProfileComponent: Component<UserProfileDependency> {
  let name: [String] = ["Hello world"]
  let address: String = "Korea"

  override init(dependency: UserProfileDependency) {
  	super.init(dependency: dependency)
  }
  subscript<U>(dynamicMember keyPath: KeyPath<UserProfileDependency, U>) -> U {
    dependency[keyPath: keyPath]
  }
}

public protocol UserProfileBuildable: Buildable {
  func build() -> UserProfileRouting
}

public final class UserProfileBuilder: Builder<UserProfileDependency>, UserProfileBuildable {
  public override init(dependency: UserProfileDependency) {
    super.init(dependency: dependency)
  }
  
  public func build() -> UserProfileRouting {
    let component = UserProfileComponent(dependency: dependency)
    _ = component.name
    _ = component.age
    _ = component.address

    ...
    
  }
}
```

Component의 name, age, address를 접근하면 다음과 같이 인식합니다.

<br/><video src="{{ site.production_url }}/image/2020/08/20200801_1.mp4" width="640" controls autoplay></video><br/>

Component에 접근할 때, Component에 해당 이름이 같은 속성이 있으면 우선 접근하고, 없다면 Dependency에 있는 속성을 가져옴을 알 수 있습니다.

## dynamicMemberLookup 다양한 활용 방법

* Github
  * [DuctTape](https://github.com/marty-suzuki/DuctTape)
  * [Compose](https://github.com/acecilia/Compose)
  * [SwiftyUserDefaults](https://github.com/sunshinejr/SwiftyUserDefaults)

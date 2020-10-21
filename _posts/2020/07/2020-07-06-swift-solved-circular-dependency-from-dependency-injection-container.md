---
layout: post
title: "[iOS][Swift] 모듈간의 관계를 Dependency Injection Container으로 풀어보자"
description: ""
category: "programming"
tags: [Swift, DI, Dependency Injection, IoC, Container, Circular Dependency, Protocol]
---
{% include JB/setup %}

<div class="alert warning"><strong>경고</strong>:본 내용은 이해하면서 작성하는 글이기 때문에 잘못된 내용이 포함될 수 있습니다. 따라서 언제든지 내용이 수정되거나 삭제될 수 있습니다. 잘못된 내용이 있는 부분이 있어 의견 주시면 공부하여 올바른 내용으로 반영하도록 하겠습니다.</div><br/>

## 모듈화 진행 과정 중 어려운 점

프로젝트가 커지면 전체적인 생산성이 감소합니다. 감소하는 이유로는 빠른 개발로 프로젝트 정리의 미진함, 레거시 코드의 발목 잡기, 방대한 양의 코드로 빌드 시간 증가, 테스트 코드 작성 시간 증가 등등이 있습니다.

이런 문제는 모듈화 작업으로 레거시 코드 정리 작업, 도메인별 코드 분리, 도메인별 테스트 코드 분리, 레거시 코드 정리을 할 수 있어 낮은 생산성을 끌어올릴 수 있습니다. 

하지만 운영중인 서비스에서는 이 작업이 쉽지는 않습니다. 그리고 기존 프로젝트는 분리하기 어렵지만 새로운 기능, 도메인에서는 모듈화를 하고 싶기도 합니다.

다양한 요구사항을 만족시킬 수 있는 방법은 있을까요?

사실 쉽지 않습니다. 

첫번째 예로, 카카오뱅크의 세이프박스라는 서비스를 만든다고 가정해봅시다. 세이프박스는 1천만원까지 금액을 별도의 계좌에 보관하고, 매일 이자가 붙는 상품입니다. 세이프박스에서 **금액을 입력**하고, **인증 비밀번호를 입력**하여 거래가 완료 됩니다.

<p style="text-align:center;">
  <img src="{{ site.production_url }}/image/2020/07/20200706_1.png" style="width: 300px"/>
  <img src="{{ site.production_url }}/image/2020/07/20200706_2.png" style="width: 300px"/>
</p><br/>

이 서비스에서 금액 입력 등의 기본적인 기능까지는 새로운 모듈에서 작업을 하였습니다. 그러나 마지막 인증 비밀번호를 입력하는 기능은 아직 모듈화가 되지 않았습니다. 가장 핵심이 되는 기능을 붙이지 못해 서비스가 만들어지지 않습니다.

이런 경우는 어떻게 해야 할까요? 메인 프로젝트에서 세이프박스를 호출하니, 인증 기능을 Closure로 받아서 저장 후, 세이브 박스가 인증 Closure를 계속 가져다니다가 마지막에 처리하는 방식이 있습니다. 또는 세이프박스가 Delegate 방식을 이용해서 인증 기능을 세이프박스 호출한 객체에서 인증 기능을 구현하여 해결할 수 있습니다.

여러모로 인증이라는 기능이 모듈로 분리되지 않아 어렵고 귀찮은 작업이 예상됩니다.

두번째 예로, 카카오뱅크의 카드 서비스에서는 **카드 관리**라는 화면이 있습니다. 여기에는 연결된 **입출금 통장의 관리 화면**으로 진입을 할 수 있습니다. 그리고 입출금 통장 관리에서는 **연결된 카드의 관리 화면**으로 진입할 수 있습니다.

<p style="text-align:center;">
  <img src="{{ site.production_url }}/image/2020/07/20200706_3.png" style="width: 300px"/>
  <img src="{{ site.production_url }}/image/2020/07/20200706_4.png" style="width: 300px"/>
</p><br/>

즉, **카드 관리 -> 입출금 통장 관리 -> 카드 관리 -> 입출금 통장 관리 -> 카드 관리 -> ...** 와 같은 과정으로 진행됩니다. 각 서비스들을 아직 모듈로 분리하지 않았다면 이런 과정이 가능합니다. 하지만, 카드 관리와 입출금 통장 관리 서비스가 모듈로 분리되면 어떨까요?

<p style="text-align:center;">
    <img src="{{ site.production_url }}/image/2020/07/20200706_5.png" style="width: 400px"/>
</p><br/>

위와 같은 다이어그램이 그려집니다. 이는 카드 관리와 입출금 통장 관리간의 **순환 종속성 관계(Circular Dependency)**를 가지며 컴파일 에러가 발생합니다. 적절한 모듈화도 좋지만, 순환 종속성이 생기면 모듈화를 섣불리 하기 어렵습니다.

이런 문제는 어떻게 해결해야 할까요?

## IoC Container와 Dependency Injection

이미 이러한 문제들은 다른 분야(특히 서버)에서 해결책을 많이 내놓았습니다. 마틴 파울러가 [**Inversion of Control Containers and the Dependency Injection pattern**](https://www.martinfowler.com/articles/injection.html)로 우리가 고민하고 있는 것을 잘 정리해놓았습니다.

**Dependency Injection 패턴** 중 **Interface Injection** 방식으로 첫번째 경우를 풀어보려고 합니다.

### Interface Injection: 세이프박스 → 인증비밀번호

먼저 의존성을 담당할 별도의 프레임워크 - **DependencyContainer** 를 만듭니다.

<p style="text-align:center;">
    <img src="{{ site.production_url }}/image/2020/07/20200706_6.png" style="width: 400px"/>
</p><br/>

그리고 DependencyContainer 프로젝트에서 의존성 주입할 프로토콜을 만듭니다.

```
/// Module: DependencyContainer
/// File: SigningInject.swift

public let signingInjectId = "SigningInjectId"

public protocol SigningInject {
  func request(withSign parameter: [String:String], completion: (([String:String]) -> Void), failure: ((Error) -> Void))
}
```

인증 비밀번호를 사용하고자 하는 클래스들은 `SigningInject` 프로토콜을 구현하기만 하면 됩니다. 첫번째 경우에서 인증 비밀번호가 모듈로 분리되어 있지 않아, 메인 프로젝트에서 구현해야 합니다.

```
/// Module: Application
/// File: SigningImplement.swift

import DependencyContainer

public class SigningImplement: SigningInject {
  public func request(withSign parameter: [String:String], completion: (([String:String]) -> Void), failure: ((Error) -> Void)) {
    completion(parameter)
  }  
}
```

DependencyContainer 프로젝트에 **Container**를 만들어 의존성 주입 프로토콜을 구현한 구현체를 **등록**할 준비를 합니다. 

첫번째로, Injectable 프로토콜을 만들고 이 프로토콜을 등록시킬 Container를 만듭니다.

```
/// Module: DependencyContainer
/// File: Injectable.swift

public protocol Injectable {
  init()
  var id: String { get }
  func resolve() -> AnyObject
}


/// File: Container.swift

public protocol ContainerAPI {
  func regist(injectType: Injectable.Type)
  func load(for injectId: String) -> Injectable?
}

public class Container: ContainerAPI {
  private var injections: [String: Injectable] = [:]
  public static let shared: Container = Container()

  public func regist(injectType: Injectable.Type) {
    let injection = injectType.init()
    injections[injection.id] = injection
  }

  public func load(for injectId: String) -> Injectable? {
    return injections[injectId]
  }
}
```

두번째로, 메인 프로젝트에서는 인증 비밀번호 Inject 아이템을 만들고, 구현체를 세이프박스에서 사용하도록 Container에 등록합니다.

```
/// Module: Application
/// File: SigningImplement.swift

import DependencyContainer

class SigningInjectItem: Injectable {
  required init() {}
  var id: String = signingInjectId
  func resolve() -> AnyObject {
    SigningImplement()
  }
}

public class SigningImplement: SigningInject {
  public func request(withSign parameter: [String:String], completion: (([String:String]) -> Void), failure: ((Error) -> Void)) {
    completion(parameter)
  }  
}


/// File: AppDelegate.swift

import DependencyContainer

class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    ...

    Container.shared.regist(injectType: SigningInjectItem.self)

    ...

    return true
  }
}
```

인증기능이 Container에 등록되어, 이제 세이프박스에서 인증 기능을 꺼내어 사용할 수 있습니다.

먼저 세이프박스에서 DependencyContainer를 연결합니다.

<p style="text-align:center;">
    <img src="{{ site.production_url }}/image/2020/07/20200706_7.png" style="width: 400px"/>
</p><br/>

이제 세이프박스에서 인증이 필요한 곳에서 Container에 등록된 SigningInjectItem을 꺼내어 resolve를 호출하여 인증 인터페이스인 SigningInject 타입 객체를 얻어 사용할 수 있습니다.

```
/// Module: SafeBox
/// File: SafeBoxVerifyService.swift

import DependencyContainer

protocol SafeBoxVerifyServicable {
  var signingService: SigningInject { get }
  func signing(parameter: [String:String], completion: (([String:String]) -> Void), failure: ((Error) -> Void))
}

struct SafeBoxVerifyService: SafeBoxVerifyServicable {

  let signingService: SigningInject

  init(signingService: SigningInject) {
    self.signingService = signingService
  }

  func signing(parameter: [String:String], completion: (([String:String]) -> Void), failure: ((Error) -> Void)) {
    signingService.request(withSign: parameter, completion: completion, failure: failure)
  }
}


/// File: SafeBoxVerifyBuilder.swift

class SafeBoxVerifyBuilder {
  func build() -> SafeBoxVerifyServicable? {
    guard let inject = Container.shared.load(for: signingInjectId)?.resolve() as? SigningInject else { 
      return nil
    }
    return SafeBoxVerifyService(signingService: inject)
  }
}
```

<br/>

### 순환 종속성 관계(Circular Dependency): 카드 관리 ⇄ 입출금통장 관리

순환 종속성 관계도 마찬가지로 Dependency Injection Container를 이용하여 풀 수 있습니다. DependencyContainer에서 카드 관리, 입출금통장 관리의  의존성 주입 프로토콜을 정의하고, 각 모듈에서는 구현하고, 메인 프로젝트는 카드 관리, 입출금통장 관리 모듈을 알고 있으므로, 인증 기능을 Container에 등록하듯 카드 관리와 입출금통장 관리도 Container에 등록이 가능합니다.

즉, 카드 관리와 입출금통장 관리가 서로 종속성을 가지는 것이 아니라, DependencyContainer에 종속성을 가지도록 변경됩니다.

<p style="text-align:center;">
    <img src="{{ site.production_url }}/image/2020/07/20200706_8.png" style="width: 400px"/>
</p><br/>

그러면 카드 관리와 입출금통장 관리가 서로 종속성을 가지지 않도록 만들어봅시다.

첫번째로 DependencyContainer 프로젝트에 카드 관리 의존성 프로토콜과 입출금통장 관리 의존성 프로토콜을 선언합니다.

```
/// Module: DependencyContainer
/// File: ManagementCardInject.swift

public let managementCardInjectId = "ManagementCardInjectId"

public protocol ManagementCardInject {
  func viewController(with cardNumber: String) -> UIViewController
}

/// File: ManagementDemandDepositInject.swift

public let managementDemandDepositInjectId = "managementDemandDepositInjectId"

public protocol ManagementDemandDepositInject {
  func viewController(with accountNumber: String) -> UIViewController
}
```

두번째로 카드 관리와 입출금통장 관리 모듈에서 Inject 프로토콜을 구현합니다.

```
/// Module: Card
/// File: ManagementCardInjectImplement.swift

import DependencyContainer

public class ManagementCardInjectImplement: ManagementCardInject {
  public func viewController(with cardNumber: String) -> UIViewController {
    ...

    let vc = ManagementCardViewController(cardNumber: cardNumber) 
    return vc
  }
}


/// Module: DemandDeposit
/// File: ManagementDemandDepositInjectImplement.swift

public class ManagementDemandDepositInjectImplement: ManagementDemandDepositInject {
  public func viewController(with accountNumber: String) -> UIViewController {
    ...

    let vc = ManagementDemandDepositViewController(accountNumber: accountNumber)
    return vc
  }
}
```

세번째로 메인 프로젝트에서 카드 관리 Inject 아이템, 입출금통장 관리 Inject 아이템을 만들고, 구현체를 카드 관리, 입출금통장 관리에서 사용하도록 Container에 등록합니다.

```
/// Module: Application
/// File: ManagementCardInjectItem.swift

import DependencyContainer
import Card

class ManagementCardInjectItem: Injectable {
  init() {}
  var id: String = managementCardInjectId
  func resolve() -> AnyObject {
    ManagementCardInjectImplement()
  }
}


/// File: ManagementDemandDepositInjectItem.swift

import DependencyContainer
import DemandDeposit

class ManagementDemandDepositInjectItem: Injectable {
  init() {}
  var id: String = managementDemandDepositInjectId
  func resolve() -> AnyObject {
    ManagementDemandDepositInjectImplement()
  }
}


/// File: AppDelegate.swift

import DependencyContainer

class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    ...

    Container.shared.regist(injectType: SigningInjectItem.self)
    Container.shared.regist(injectType: ManagementCardInjectItem.self)
    Container.shared.regist(injectType: ManagementDemandDepositInjectItem.self)

    ...

    return true
  }
}
```

마지막으로 카드 관리, 입출금통장 관리에서 DependencyContainer의 Container에 등록되어 있는 ManagementCardInject, ManagementDemandDepositInject 프로토콜을 구현한 구현체를 꺼내어 각 화면으로 이동할 수 있습니다.

```
/// Module: Card
/// File: ManagementCardRouter.swift

import DependencyContainer

protocol ManagementCardRouting {
  var managementDemandDepositInject: ManagementDemandDepositInject { get }
  func routeToManagementDemandDeposit(accountNumber: String) -> UIViewController
}

class ManagementCardRouter: ManagementCardRouting {

  let managementDemandDepositInject: ManagementDemandDepositInject

  init(managementDemandDepositInject: ManagementDemandDepositInject) {
    self.managementDemandDepositInject = managementDemandDepositInject
  }

  func routeToManagementDemandDeposit(accountNumber: String) -> UIViewController {
    return managementDemandDepositInject.viewController(with: accountNumber)
  }
}

/// File: ManagementCardBuilder.swift

class ManagementCardBuilder {
  func build() -> ManagementCardRouting? {
    guard let inject = Container.shared.load(for: managementDemandDepositInjectId)?.resolve() as? ManagementDemandDepositInject else {
      return nil
    }
    return ManagementCardRouter(managementDemandDepositInject: inject)
  }
}



/// Module: DemandDeposit
/// File: ManagementDemandDepositRouter.swift

import DependencyContainer

protocol ManagementDemandDepositRouting {
  var managementCardInject: ManagementCardInject { get }
  func routeToManagementCard(cardNumber: String) -> UIViewController
}

class ManagementDemandDepositRouter: ManagementDemandDepositRouting {

  let managementCardInject: ManagementCardInject

  init(managementCardInject: ManagementCardInject) {
    self.managementCardInject = managementCardInject
  }

  func routeToManagementCard(cardNumber: String) -> UIViewController {
    return managementCardInject.viewController(with: cardNumber)
  }
} 

/// File: ManagementDemandDepositBuilder.swift

class ManagementDemandDepositBuilder {
  func build() -> ManagementDemandDepositRouting? {
    guard let inject = Container.shared.load(for: managementCardInjectId)?.resolve() as? ManagementCardInject else {
      return nil
    }
    return ManagementDemandDepositRouter(managementCardInject: inject)
  }
}
```

이렇게 카드 관리와 입출금 통장 관리 간의 순환 종속 관계를 Dependency Injection Container를 이용하여 끊을 수 있습니다.

## 오픈소스 - [Dip](https://github.com/AliSoftware/Dip), [SwInject](https://github.com/Swinject/Swinject)

위의 코드처럼 작성할 수도 있지만, Dependency Injection Container를 지원하는 오픈소스를 이용하여 위의 코드처럼 작성 또는 군더더기 없이 작성 가능합니다.

**[AliSoftware/Dip](https://github.com/AliSoftware/Dip)**와 **[Swinject](https://github.com/Swinject/Swinject)** 오픈소스를 이용하여 훨씬 더 풍부한 기능으로 코드 작성이 가능합니다.

개인적으로 Dip를 추천하며, Scope이나 Auto-wiring 등 기능이 더 풍부하기 때문입니다.



# 참고자료 

* GitHub
  * [Vinodh-G/NewsApp](https://github.com/Vinodh-G/NewsApp)
  * [AliSoftware/Dip](https://github.com/AliSoftware/Dip)
  * [RIBs - Plugin](https://gist.github.com/dehrom/ac1a50cfbee3b573fd590150e652f914)
  * [DITranquillity](https://github.com/ivlevAstef/DITranquillity)
  * [example-buck-ribs-needle](https://github.com/Angel-Cortez/example-buck-ribs-needle)

* Post
  * [Extending your modules using a plugin architecture](https://blog.usejournal.com/extending-your-modules-using-a-plugin-architecture-c1972735d728)
  * [유연한 확장과 변경 영향의 분리 패턴 지향 플러그인 소프트웨어 설계](https://kdata.or.kr/info/info_04_view.html?field=&keyword=&type=techreport&page=223&dbnum=127607&mode=detail&type=techreport )
  * [Wikipedia - Plug-in (computing)](https://en.wikipedia.org/wiki/Plug-in_(computing))
  * [번역 - IoC 콘테이너와 디펜던시 인젝션 패턴](https://javacan.tistory.com/entry/120)
  * [토비의 스프링 - IoC 컨테이너와 DI](https://gunju-ko.github.io/toby-spring/2019/03/25/IoC-%EC%BB%A8%ED%85%8C%EC%9D%B4%EB%84%88%EC%99%80-DI.html)
  * [iOS Clean Architecture with Swift - IoC Container](https://develogs.tistory.com/7)
  * [IoC container in Swift](https://ilya.puchka.me/ioc-container-in-swift/)
  * [Swift Dependency Injection via Property Wrapper](https://basememara.com/swift-dependency-injection-via-property-wrapper/)
  * [Swift dependency injection design pattern](https://theswiftdev.com/swift-dependency-injection-design-pattern/)
  * [Spring - What's a plugin-oriented architecture?](https://spring.io/blog/2010/06/01/what-s-a-plugin-oriented-architecture)
  * [Inversion of Control Containers and the Dependency Injection pattern](https://greatshin.tistory.com/8)
  * [Martin Fowler - Plugin](https://martinfowler.com/eaaCatalog/plugin.html)
  * [IoC, DI, DIP 용어 정리](https://black-jin0427.tistory.com/194)
  * [객체 종속성이란? what is object dependency?](https://wiserloner.tistory.com/115)
  * [Unity Container: Constructor Injection](https://www.tutorialsteacher.com/ioc/constructor-injection-using-unity-container)
  * [Dependency를 관리하는 방법](https://architecture101.blog/2008/12/07/dependency_managment/)
  * [Dependency Analyzer를 이용한 순환적 의존관계 검출](https://blog.naver.com/suresofttech/220729875733)

* Youtube
  * [Swinject to handle dependency injection](https://www.youtube.com/watch?v=8a_oL8-ioqA)

* Wikipedia
  * [Circular dependency](https://en.wikipedia.org/wiki/Circular_dependency)
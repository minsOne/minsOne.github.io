---
layout: post
title: "[Swift][RIBs] Child Router 변수 할당 및 attachChild 순서"
description: ""
category: "programming"
tags: [iOS, Swift, Uber, RIBs, Router, Listener, Interactor]
---
{% include JB/setup %}

Child Router를 attachChild 하고, currentRouter 변수 할당하는 순서를 이야기 해보려고 합니다.

## Child Router Attach, Detach 순서 

보통 Child Router를 attach, detach 하는 코드는 이렇습니다.

```
final class ParentRouter: Router<ParentInteractable>, ParentRouting {
  ...

  private let childBuilder: ChildBuildable
  private var currentChild: Routing?

  func attachToChild() {
    guard currentRouter == nil else { return }
    let router = childBuilder.build(withListener: interactor)
    self.currentChild = router
    attachChild(router)
  }

  func detachToChild() {
    guard let router = currentRouter else { return }
    detachChild(router)
    self.currentChild = nil
  }
}
```

위 코드에서 attach, detach시 순서가 애매한 코드가 있습니다.

```
/// Attach
self.currentChild = router
attachChild(router)

/// Detach
detachChild(router)
self.currentChild = nil
```

만약 위 코드의 attach 순서를 다음과 같이 바꾸면 어떻게 될까요?

```
func attachToChild() {
  guard currentRouter == nil else { return }
  let router = childBuilder.build(withListener: interactor)
  attachChild(router)
  self.currentChild = router
}
```

순서를 바꾼다고 일반적인 상황에서는 문제가 발생하지 않습니다. 문제가 일어날 것 같아 보이지 않고요. 과연 어떤 경우에 문제가 발생할까요?

## Child RIB의 빠른 종료로 발생하는 오류

Child RIB은 비즈니스 로직만 담당하고, 처리한 결과를 Listener에 전달하여 Parent가 다루도록 하는 경우를 생각해봅시다.

Interactor는 `didBecomeActive` 함수에서 비즈니스 로직을 처리하도록 합니다. didBecomeActive는 Parent Router에서 Child Router를 attach 하면서 호출이 됩니다.

만약 Child Interactor에서 비즈니스 로직이 동기 또는 빠르게 결과를 반환하도록 되어 Listener에 결과를 전달하면 어떻게 될까요?

1) `attachChild(router)` 코드 호출  
2) Child Interactor에서 비즈니스 처리 후, Listener에 결과 전달  
3) Parent Interactor가 결과를 받고, Child Router 종료 하도록 Parent Router에 `detachToChild` 함수 실행  
4) currentRouter에 값이 있는지 확인하지만, 아직 `self.currentChild = router` 코드가 호출되기 전이라 `currentChild`에 값이 없어 detach 하지 못함.  
5) `self.currentChild = router` 코드 실행하여 `currentChild`에 router 할당  
6) 다시 비즈니스 로직을 처리하도록 Child Router를 attach 요청 -> `attachToChild` 함수 실행  
7) `currentChild` 에 값이 있기 때문에 attach 할 수 없음.  

이렇게 currentChild에 할당을 뒤에 하게 되면 위와 같이 타이밍으로 문제가 발생합니다.<br/><br/>

그럼 currentChild에 먼저 할당하면 문제가 발생하지 않을까요?

1) `self.currentChild = router` 코드 실행하여 `currentChild`에 router 할당  
2) `attachChild(router)` 코드 실행  
3) Child Interactor에서 비즈니스 처리 후, Listener에 결과 전달  
4) Parent Interactor가 결과를 받고, Child Router 종료 하도록 Parent Router에 `detachToChild` 함수 실행  
5) `currentChild`는 값이 있기 때문에 detach를 정상 실행함.  
6) 다시 비즈니스 로직을 처리하도록 Child Router를 attach 요청 -> `attachToChild` 함수 실행  
7) `currentChild`에 값이 없기 때문에 ChildRouter를 만들어 attach를 정상 실행함.  

문제가 발생하지 않고 Child Router를 여러번 attach, detach 할 수 있습니다.

위와 같은 문제는 detach에서도 가능하기 때문에, 먼저 currentChild의 값을 제거하고, detachChild를 호출하는 것이 좋습니다.


## 정리

Child Router를 attach, detach 할 때는 변수에 할당한 후, attach, detach 하도록 순서에 유의해야 합니다.

```
func attachToChild() {
  guard currentRouter == nil else { return }
  let router = childBuilder.build(withListener: interactor)
  self.currentChild = router
  attachChild(router)
}

func detachToChild() {
  guard let router = currentRouter else { return }
  self.currentChild = nil
  detachChild(router)
}
```


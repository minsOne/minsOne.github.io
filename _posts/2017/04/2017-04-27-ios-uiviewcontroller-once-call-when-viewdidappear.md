---
layout: post
title: "[iOS]UIViewController가 진입시 viewDidAppear에서 한번만 필요한 기능 호출하기"
description: ""
category: "Mac/iOS"
tags: [swift, viewDidAppear, viewDidDisappear, viewWillAppear, viewWillDisappear, isBeingPresented, isBeingDismissed, isMovingToParentViewController, isMovingFromParentViewController]
---
{% include JB/setup %}

`viewDidAppear`는 화면이 완전히 나타났을 때, 호출됩니다. 하지만 처음으로 호출되었는지를 알기 위해 일반적으로 변수를 통해 상태를 관리합니다. 

하지만 iOS 5.0 이후 버전부터는 `isBeingPresented`, `isBeingDismissed`, `isMovingToParentViewController`, `isMovingFromParentViewController`를 사용할 수 있습니다.

viewDidAppear가 처음 호출된 조건에 특정 기능을 실행한다며 다음과 같이 조건을 추가할 수 있습니다.

```
override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isBeingPresented || isMovingToParentViewController {
            // Something
        }
    }
```

viewDidDisappear도 마찬가지로 조건을 추가하여 특정 기능을 수행할 수 있습니다.

```
override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed || isMovingFromParentViewController {
            // Something
        }
    }
```

viewDidAppear, viewDidDisappear 뿐만 아니라 viewWillAppear, viewWillDisappear에서도 같은 방식으로 사용할 수 있습니다.

### 출처

* [Apple Document](https://developer.apple.com/reference/uikit/uiviewcontroller)

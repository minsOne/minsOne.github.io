---
layout: post
title: "[iOS]추상 프레임워크 - 오픈소스"
description: ""
category: ""
tags: []
---
{% include JB/setup %}

우리는 개발하는 과정에 오픈소스를 많이 가져다 사용합니다. Alamofire, Moya, SDWebImage, KingFisher, RxSwift, Google Analytics 등을 사용합니다. 어떤 오픈소스들은 대체가 될 수도 있고, 안될 수도 있습니다. 과거에는 AFNetworking를 많이 사용했지만, 지금은 Alamofire, Moya 등을 많이 사용합니다. SDWebImage도 과거에는 필수였지만, 지금은 KingFisher, Nuke 등 다양한 오픈소스들이 존재합니다.

하지만 우리 프로젝트에 사용된 오픈소스는 쉽게 대체될 수 없습니다. 대체로 코드에서 라이브러리를 직접 사용하는 경우가 많기 때문입니다. 그렇게 되면 어떤 문제가 생길까요?

프로젝트에서 AFNetworking를 직접 사용했다고 가정을 해 봅시다.

```
import AFNetworking

func request() {
  let manager = AFHTTPSessionManager()
  manager.get(url, parameters: nil, success: { (operation, responseObject) in
    if let dic = responseObject as? [String: Any], let matches = dic["matches"] as? [[String: Any]] {
      print(matches)
    }
  }, failure: { (operation, error) in
       print("Error: " + error.localizedDescription)
  })
}
```

위와 같이 AFHTTPSessionManager를 이용하여 Network 요청하게 됩니다. 만약 AFNetworking을 교체해야한다면 어떻게 해야할까요? 코드를 재작성해야하는데, success 안에 있는 비지니스 로직도 건드려야하는 문제가 생깁니다.


---
layout: post
title: "[iOS]No such module - Modulemap"
description: ""
category: "iOS/Mac"
tags: [iOS, XCode, Project, CocoaPods, Carthage, Framework]
---
{% include JB/setup %}

특정 업체들의 솔루션을 이용하기 위해 해당 업체의 framework를 가져다 사용해야하는 경우가 있습니다. 

우리는 Adapter framework로 만들어 업체의 framework를 사용하는 경우, 대부분은 잘 되지만, 안될때가 있습니다. 업체들 중 일부는 원소스 멀티 프레임워크로 만들어서 제공하기 때문에 Adapter framework에서 업체의 framework를 link 하여 사용할때, 안될 수도 있습니다.

그럴때는 업체의 framework 내의 `Module 폴더`와, `module.modulemap`이 있는지 살펴보시면 좋습니다. 

만약 없다면, 업체에 요청하시고, 그전까지는 modulemap을 만들어 넣어놓으시면 됩니다.

```
Path : Module/module.modulemap

framework module [framework 이름] {
  umbrella header "[framework 이름].h"

  export *
  module * { export * }
}


example)

framework module helloframework {
  umbrella header "helloframework.h"

  export *
  module * { export * }
}

```

위 파일은 framework 프로젝트를 만든 후, `⁨DerivedData⁩ ▸ [프로젝트 명] ▸ ⁨Build⁩ ▸ ⁨Products⁩`에 framework 파일을 찾으실 수 있습니다.
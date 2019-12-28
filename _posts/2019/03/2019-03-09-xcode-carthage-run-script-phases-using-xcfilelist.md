---
layout: post
title: "[Xcode 10][Carthage] Run Script phases의 Input File List에 xcfilelist를 추가하여 쉽게 라이브러리를 넣기"
description: ""
category: "iOS/Mac"
tags: [Xcode, Carthage, xcfilelist]
---
{% include JB/setup %}

Carthage를 사용하면 `Input Files`에 추가되어야 할 라이브러리들 목록을 하나하나 추가해줬어야 합니다.

Xcode 10부터는 Run Script phases에 `Input File Lists` 라는 기능이 생겼습니다.([참고](https://developer.apple.com/documentation/xcode_release_notes/xcode_10_release_notes/build_system_release_notes_for_xcode_10))

기존에 `Input Files`에 한땀 한땀 라이브러리 경로를 추가하던 방식에서 `xcfilelist` 파일을 넣으면 끝납니다. 즉, 쉽게 타겟별로 추가할 라이브러리 목록을 관리할 수 있습니다.

<br/>

#### 기존 방식
<p style="text-align:center;"><img src="{{ site.production_url }}/image/2019/03/003.png" style="width: 700px"/></p>

#### **xcfilelist**를 이용한 방식

프로젝트 경로 내에 xcfilelist을 만듭니다.

```
# Main Target의 File List

# Frameworks

$(SRCROOT)/Carthage/Build/iOS/Hue.framework
$(SRCROOT)/Carthage/Build/iOS/SwiftyJSON.framework
```

<p style="text-align:center;"><img src="{{ site.production_url }}/image/2019/03/004.png" style="width: 700px"/></p><br/>

## 참고 자료

* [Carthage 0.31.1 Release Notes](https://github.com/Carthage/Carthage/releases/tag/0.31.1)
* [Carthage Pull Request](https://github.com/Carthage/Carthage/pull/2591)
* [Xcode 10 Release Notes](https://developer.apple.com/documentation/xcode_release_notes/xcode_10_release_notes/build_system_release_notes_for_xcode_10)
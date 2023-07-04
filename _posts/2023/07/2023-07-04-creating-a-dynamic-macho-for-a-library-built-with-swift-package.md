---
layout: post
title: "[Swift][SwiftPM] Swift Package로 만든 라이브러리의 Mach-O를 Dynamic으로 만들기"
tags: []
published: false
---
{% include JB/setup %}

일반적으로 Swift Package로 만든 라이브러리의 `Mach-O`의 기본값은 `Static` 입니다. `Dynamic` 으로 변경하려면 type을 `.dynamic` 으로 변경해야합니다.

```swift
// FileName : Package.swift
let package = Package(
    name: "MyLibrary",
    products: [
        .library(name: "MyLibrary", type: .dynamic, targets: ["MyLibrary"]),
    ],
    ...
)
```

위와 같이 type에 `dynamic`으로 값을 지정해야하는 경우는 `Mach-O`가 `Static`, `Dynamic`인 라이브러리를 각각 만들어야 합니다.

```swift
// FileName : Package.swift
let package = Package(
    name: "MyLibrary",
    products: [
        .library(name: "MyLibrary", targets: ["MyLibrary"]),
        .library(name: "MyLibrary-Dynamic", type: .dynamic, targets: ["MyLibrary"]),
    ],
    ...
)
```

`Mach-O`를 Dynamic으로 설정해야하는 이유는, 여러 Dynamic Framework에서 해당 라이브러리를 사용해야하기 때문입니다. 만약 `Mach-O`를 Static인 라이브러리를 의존하게 되면, 복사가 일어나기 때문입니다.

그래서 별도의 `Mach-O`가 `Dynamic` 인 라이브러리를 만들게 되었습니다.

---

Xcode 12.5에서는 라이브러리 코드 중복이 발생하는 경우, 패키지의 라이브러리를 Dynamic Framework로 만들어준다고 합니다. [Xcode 12.5 Release Note](https://developer.apple.com/documentation/xcode-release-notes/xcode-12_5-release-notes#Swift-Packages)

```
The Swift Package Manager now builds package products and targets as dynamic frameworks automatically, if doing so avoids duplication of library code at runtime. (59931771) (FB7608638)
```

즉, 여러 Dynamic 라이브러리가 패키지의 `type`이 `static`으로 설정된 라이브러리를 의존한다면, Dynamic Framework로 빌드한다는 의미입니다.

<div class="mermaid" style="display:flex;justify-content:center;"> 
graph TD;
    id1[Application]-->id2[AFramework]
    id1[Application]-->id3[BFramework]
    id2-->id4(MyLibrary)
    id3-->id4(MyLibrary)
    style id1 fill:#03bfff
    style id2 fill:#ffba0c
    style id3 fill:#ffba0c
    style id4 fill:#ff5116
</div>

위의 의존관계에서 `AFramework`, `BFramework`는 `MyLibrary`를 의존하고 있어, `MyLibrary`는 Static Library로 빌드하지 않고, **Dynamic Framework**로 빌드합니다.

**[RxSwift](https://github.com/reactiveX/RxSwift)**는 별도의 Dynamic 라이브러리르 만든 대표적인 오픈소스입니다. RxSwift를 통해 정말로 Dynamic Framework로 빌드하는지 알아봅시다.

## Swift Package의 라이브러리를 Dynamic Framework로 만들기


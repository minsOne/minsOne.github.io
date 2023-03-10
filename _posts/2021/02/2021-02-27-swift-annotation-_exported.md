---
layout: post
title: "[Swift 5.3] @_exported 속성 정리"

description: ""
category: "programming"
tags: [Swift, Module]
---
{% include JB/setup %}

<div class="alert warning"><strong>주의</strong> : 이 글은 비공식 속성을 다루므로 사용 시 유의하시기 바랍니다.</div>

`@_exported`는 비공식 속성으로 \_가 붙어 있습니다. (비슷하게 현재 Async/Await가 비공식으로 쓰이기 위해서는 `import _Concurrency`를 사용해야 합니다.)

하위모듈을 import할 때, `@_exported`를 붙여서 사용하면 현재 모듈의 코드에서 별도로 import하지 않아도 전역에서 사용할 수 있으며, 상위 모듈에서 현재 모듈을 import할 때 하위 모듈까지 접근할 수 있습니다. [비공식 문서 - The-Swift-Programming-Language](https://the-swift-programming-language.readthedocs.io/en/latest/md/Attributes/)

```
@_exported import ModuleA
```

## @\_exported 속성 사용 코드


다음과 같이 의존성 관계를 만들 것입니다.

<img src="{{ site.production_url }}/image/2021/02/20210228_1.png" style="width: 400px"/>

각 모듈에서 하위 모듈을 사용할때 `@_exported` 속성을 붙여 import 할 것입니다.

해당 의존성 관계를 가진 프로젝트들을 만들어 봅시다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/02/20210228_2.png" style="width: 600px"/>
</p><br/>

ModuleD에서 다음 코드를 작성합니다.

```swift
/// ModuleD
/// FileName : ModuleDClass.swift

public final class ModuleDClass {
    public init() {
        print("=============== ModuleD Call Stack - Start ===============")

        print("ModuleD Class initialize")
        
        print("=============== ModuleD Call Stack - End ===============\n")
    }
}
```

ModuleC에서 ModuleD를 `@_exported`를 사용하여 import 하는 파일을 별도로 만듭니다.

```swift
/// ModuleC
/// FileName : ImportModule.swift

@_exported import ModuleD
```

또한, 다른 파일에서 ModuleCClass 클래스를 생성하고, ModuleD의 ModuleDClass 객체를 생성하는 코드를 작성합니다.

```swift
/// ModuleC
/// FileName : ModuleCClass.swift

public final class ModuleCClass {
    public init() {
        print("=============== ModuleC Call Stack - Start ===============")
        print("ModuleC Class initialize")
        
        _ = ModuleDClass()
        
        print("=============== ModuleC Call Stack - End ===============\n")
    }
}
```

`import ModuleD` 코드를 사용하지 않아도 ModuleDClass 클래스를 사용할 수 있습니다.

다음으로 ModuleB에서 ModuleD를 `@_exported`를 사용하여 import 하는 파일을 별도로 만듭니다.

```swift
/// ModuleB
/// FileName : ImportModule.swift

@_exported import ModuleD
```

그리고 다른 파일에서 ModuleBClass 클래스를 생성하고, ModuleD의 ModuleDClass 객체를 생성하는 코드를 작성합니다.

```swift
/// ModuleB
/// FileName : ModuleBClass.swift

public final class ModuleBClass {
    public init() {
        print("=============== ModuleC Call Stack - Start ===============")
        print("ModuleC Class initialize")
        
        _ = ModuleDClass()
        
        print("=============== ModuleC Call Stack - End ===============\n")
    }
}
```

그 다음으로, ModuleA에서 ModuleB, ModuleC, ModuleD 모듈을 별도의 파일에서 import하는 파일을 생성합니다.

```swift
/// ModuleA
/// FileName : ImportModule.swift

@_exported import ModuleB
@_exported import ModuleC
@_exported import ModuleD
```

그리고 다른 파일에서 ModuleBClass 클래스를 만들고, ModuleB의 ModuleBClass, ModuleC의 ModuleCClass, ModuleD의 ModuleDClass 객체를 생성하는 코드를 작성합니다.

```swift
/// ModuleA
/// FileName : ModuleAClass.swift

public final class ModuleAClass {
    public init() {
        print("\n=============== ModuleA Call Stack - Start ===============")
        print("ModuleA Class initialize")
        
        _ = ModuleBClass()
        _ = ModuleCClass()
        _ = ModuleDClass()
        print("=============== ModuleA Call Stack - End ===============\n")
    }
}
```

다음으로 App에서 ModuleA의 코드를 사용하는 코드를 작성합니다.

```swift
/// App
/// FileName : ImportModuleA.swift

import ModuleA

func call() {
    _ = ModuleA.ModuleAClass()
    _ = ModuleA.ModuleBClass()
    _ = ModuleA.ModuleCClass()
    _ = ModuleA.ModuleCClass()
    
    _ = ModuleB.ModuleBClass()
    _ = ModuleB.ModuleDClass()
    
    _ = ModuleC.ModuleCClass()
    _ = ModuleC.ModuleDClass()
    
    _ = ModuleD.ModuleDClass()
    
    _ = ModuleAClass()
    _ = ModuleBClass()
    _ = ModuleCClass()
    _ = ModuleDClass()
}
```

위 코드에서 ModuleA만 import 하였지만, ModuleB, ModuleC, ModuleD를 접근할 수 있습니다. 이는 하위 모듈에서 `@_exported` 속성을 붙인 import를 사용했기 때문에 상위 모듈에서도 접근이 가능하다는 것을 의미합니다.

## 참고

* [The-Swift-Programming-Language - Attributes](https://the-swift-programming-language.readthedocs.io/en/latest/md/Attributes/)
* [Swift] @\_exportedの挙動調査](https://qiita.com/shtnkgm/items/0e2c6ecb0af97800e778)

* [Swift Forum - @\_exported and fixing import visibility](https://forums.swift.org/t/exported-and-fixing-import-visibility/9415)

* [Swift Imports](https://thoughtbot.com/blog/swift-imports)
* [Stackoverflow - What is the “@exported” attribute in Swift](https://stackoverflow.com/questions/33558995/what-is-the-exported-attribute-in-swift)
* [Simplifying Swift framework development](https://davedelong.com/blog/2018/01/19/simplifying-swift-framework-development/)
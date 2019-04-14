---
layout: post
title: "[Swift5] Import 사용 방법"
description: ""
category: "Programming"
tags: [Swift, Import]
---
{% include JB/setup %}

Swift의 Import는 기본적으로 다른 프레임워크를 현재 코드에서 사용할 수 있도록 해줍니다. 예를 들어, UIViewController를 사용하려면 `import UIKit` 을 작성해야만 사용 가능합니다.

하지만 해당 코드에서는 `UIViewController` 외 다른 타입을 알고 싶지 않을 수도 있습니다.

다른 프레임워크의 특정 타입 또는 특정 함수만을 가져다 사용 수 있습니다. Swift 프로젝트의 [Import](https://github.com/apple/swift/blob/master/docs/Import.rst) 문서를 보면 다음 항목들을 import 할 수 있습니다.

```
import-kind ::= 'module'
import-kind ::= 'class'
import-kind ::= 'enum'
import-kind ::= 'func'
import-kind ::= 'protocol'
import-kind ::= 'struct'
import-kind ::= 'typealias'
import-kind ::= 'var'
```

그러면 위의 항목들을 살펴봅시다.

### Module

Module은 UIKit 또는 UIKit의 Submodule인 UIViewController과 같은 모듈를 이야기합니다. 그래서 특정 Module만 지정하여 import 사용이 가능합니다.

```
import UIKit
/// or
import UIKit.UIViewController

let a = UIViewController()
```

### class, enum, func, protocol, struct, typealias, var

`class`, `enum`, `func`, `protocol`, `struct`, `typealias`, `var` 는 특정 모듈의 전부가 아닌 해당 부분만 사용할 수 있습니다.

A라는 프레임워크에는 다음과 같이 정의되어 있다고 가정합시다.

```
/// A.framework
public protocol AProtocol {}
public class AClass: AProtocol {}
public enum AEnum: String { case a = "aa" }
public struct AStruct {}
public typealias BStruct = AStruct
public var a: Int = 0
public func aFunction() {}
```

A 프레임워크를 사용하는 곳에서는 다음과 같이 부분 import하여 사용할 수 있습니다.

```
import protocol A.AProtocol
import class A.AClass
import enum A.AEnum
import struct A.AStruct
import typealias A.BStruct
import var A.a
import func A.aFunction

...

let aClass: AClass = AClass()
let aProtocol: AProtocol = aClass
let aEnum: AEnum = .a
let aStruct = AStruct()
let bStruct = BStruct()
a = 10
aFunction()
```

만약 여러 모듈을 import 할 때, 각 모듈의 타입 이름이 같은 경우 또는 로컬 타입과 이름이 같을 수가 있습니다. 이런 경우는 모듈과 타입을 다 작성 해야 컴파일 에러가 발생하지 않습니다.

```
/// A.Framework
class Alpha {}

/// B.Framework
class Alpha {}

...

import A
import B

let a = A.Alpha()
let b = B.Alpha()
```

## 참고자료

* [Apple - Swift의 import 문서](https://github.com/apple/swift/blob/master/docs/Import.rst)
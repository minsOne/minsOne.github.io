---
layout: post
title: "[Swift4]옵셔널 비교문 사용시 guard let, if let 대신 if case나 Switch를 사용하자"
description: ""
category: "Programming"
tags: [Swift, guard, if, case, switch, Optional]
---
{% include JB/setup %}

Swift에서는 옵셔널의 값을 사용하기 위해 `guard let` 과 `if let` 사용을 권장합니다.

```
let a: Int? = 1

if let _a = a {
	print(_a) // Output: 1
}

guard let _a = a else { return }
print(_a) // Output: 1
```

Optional은 enum으로 `none`과 `some(Wrapped)` 을 가지며 if case 문, Switch 문으로 옵셔널 비교를 할 수 있는데, 다음과 같이 Optional을 쉽게 사용할 수 있습니다.

```
let a: Bool? = true
let b: Int? = 1

if case true? = a { 
	print("true")
}

switch b {
	case 1?: print("1")
	default: print("default")
}
```

`값` 뒤에 `?`를 붙여 옵셔널 값으로 쉽게 만들기 때문에 비교문에서는 `?`를 사용하는 것이 훨씬 좋습니다.

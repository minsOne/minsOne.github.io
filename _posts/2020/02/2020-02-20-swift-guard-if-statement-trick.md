---
layout: post
title: "[Swift][Trick] 값이 옵셔널이 아닌데, guard 또는 if let 문에 사용"
description: ""
category: "programming"
tags: [Swift, guard, if, case, Optional]
---
{% include JB/setup %}

값이 옵셔널이 아닌데, guard 또는 if let 문에 사용하고 싶을 경우가 있습니다. 그럴 경우, case를 이용하여 사용할 수 있습니다.

```
let tmp1: Int = 0
let tmp2: Int? = 1

/// 컴파일 X
guard let value = tmp else { return }
if let value = tmp {
  ...
}

/// 컴파일 O
guard case let value = tmp else { return }
if case let value = tmp {
	...
}

// 또는 Optional로 Wrapping하기
guard let value = Optional(tmp) else { return }
```

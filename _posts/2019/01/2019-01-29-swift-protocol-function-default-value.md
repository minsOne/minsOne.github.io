---
layout: post
title: "[Swift][Trick] Protocol에 정의된 함수에 기본값 사용하기"
description: ""
category: "programming"
tags: [Swift, default argument, Protocol]
---
{% include JB/setup %}

Protocol에 함수를 정의할 때, 기본값을 인자로 사용할 수 없습니다.

다음과 같이 코드를 작성하면 컴파일 에러가 발생합니다.

```
protocol P {
    func a(count: Int = 1)
}
```

`default argument not permitted in a protocol method` 라고 안되니깐 하지마라고 에러를 친절히 알려줍니다.

하지만 일반 함수들은 기본값을 인자로 잘 넣어서 사용하고 있어, 더더욱 사용하고 싶습니다.

이럴때 해결해주는 것은 `extension` 입니다. 여기에서 기본값을 인자로 가진 함수를 만들면 됩니다.

```
protocol P {
    func a(c: Int)
}

extension P {
    func a(c: Int = 1) {
        a(c: c)
    }
}
```

그러면 우리는 다음과 같이 사용할 수 있습니다.

```
class A: P {
    func a(c: Int) {
        print(c)
    }
}

let a = A()
a.a() // Output: 1
a.a(c: 10) // Output: 10
```
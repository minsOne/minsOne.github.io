---
layout: post
title: "[Swift]Name Mangling"
description: ""
category: "Programming"
tags: [swift]
---
{% include JB/setup %}

Name Mangling은 단어 그대로 이름을 조각조각냄으로써 고유한 이름을 가짐 여부 문제를 해결합니다. 컴파일러로부터 만들어진 코드는 링커를 통해 다른 부분과 연결되는데, 링커는 각 프로그램 개체의 많은 정보가 필요합니다. 이는 정확하게 함수를 연결하기 위함입니다.

Test라는 모듈에 MyClass 클래스의 `func calculate(x: Int) -> Int` 함수를 Mangling하면 다음 결과 `_TFC4test7MyClass9calculatefS0_FT1xSi_Si`를 얻을 수 있습니다. 

해당 결과는 다음 의미를 따릅니다.

_T: 모든 Swift 심볼의 접두사.

F: 비 커링 함수.

C: 클래스의 함수(메소드).

4test: 모듈 이름이며, 숫자는 모듈 이름 길이.

7MyClass: 함수가 속한 클래스 이름이며, 숫자는 클래스 이름 길이.

9calculate: 함수 이름이며, 숫자는 함수 이름.

f: 함수 속성.

S0: 첫 번째 파라미터의 타입을 타입 스택의 첫 번째 타입으로 지정.

_FT: 함수의 파라미터 튜플을 위한 타입 목록이 시작함.

1x: 함수의 첫 번째 파라미터의 외부 이름.

Si: 첫 번째 파라미터가 Swift.Int 타입을 나타냄.

_Si: 반환 타입, Swift.Int 타입을 나타냄.

## Mangling

```
$ echo 'class MyClass {
	func calculate(x: Int) -> Int {
		return 10
	}
}' > myclass.swift
$ cat myclass.swift | xcrun swiftc - -emit-library -o test


$ xcrun nm -g test
...
0000000000001340 t __TFC4test7MyClass9calculatefT1xSi_Si
...
```

## Demangle

Mangling된 것을 알아볼 수 있도록 만들어줍니다.

```
$ xcrun swift-demangle __TFC4test7MyClass9calculatefT1xSi_Si
_TFC4test7MyClass9calculatefT1xSi_Si ---> test.MyClass.calculate (x : Swift.Int) -> Swift.Int

$ xcrun swift-demangle _TFCCC4test1a1b1c1dfS2_FT1zS0_1xS1_1vFT1xSi_Si_OVS_1e1f
_TFCCC4test1a1b1c1dfS2_FT1zS0_1xS1_1vFT1xSi_Si_OVS_1e1f ---> test.a.b.c.d (test.a.b.c) -> (z : test.a, x : test.a.b, v : (x : Swift.Int) -> Swift.Int) -> test.e.f
```

### 참고 자료

* [Wikipedia](https://en.wikipedia.org/wiki/Name_mangling#Swift)
* [mikeash.com](https://mikeash.com/pyblog/friday-qa-2014-08-15-swift-name-mangling.html)
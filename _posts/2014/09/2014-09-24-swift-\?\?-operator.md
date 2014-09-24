---
layout: post
title: "swift ?? 중위 연산자"
description: ""
category: "mac/ios"
tags: [swift, operator, infix]
---
{% include JB/setup %}

Swift의 연산자 중에 `??` 라는 중위 연산자가 있습니다.

`??` 중위 연산자는 두 값을 비교하여 왼쪽의 값이 nil이라면, 오른쪽 값을 반환하는 동작을 합니다.

우선 기본적인 예제로, i값이 nil이고 j이 값이 있으면, 일반적으로 다음과 같이 코드를 작성합니다.

	let i: Int? = nil
	let j: Int? = 5

	let result = i != nil ? i! : j
	// {Some 5}

위의 조건을 검사하는 코드는 `??` 중위 연산자를 통해 다음과 같이 변경할 수 있습니다.

	let result = i ?? j
	// {Some 5} 

참고 : [https://github.com/ksm/SwiftInFlux#refinements-to-nil-coalescing-operator](https://github.com/ksm/SwiftInFlux#refinements-to-nil-coalescing-operator)
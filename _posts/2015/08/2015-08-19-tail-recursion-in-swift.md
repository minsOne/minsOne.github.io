---
layout: post
title: "[Swift][Algorithm]꼬리 재귀"
description: ""
category: "programming"
tags: [recursion, tail, swift]
---
{% include JB/setup %}

### 꼬리 재귀(Tail Recursion)

꼬리 재귀는 함수를 호출하면서 스택을 재사용합니다. 일반적인 재귀는 스택이 쌓이고, 호출되지 않으면 스택을 하나씩 정리합니다. 하지만 꼬리 재귀는 스택이 쌓이지 않기 때문에 메모리를 아낄 수 있습니다. 

꼬리 재귀는 컴파일 때 보다 런타임 때에 이득을 얻습니다. 재귀를 사용할 것인지, 꼬리 재귀를 사용할 것인지는 문제에 따라 또는 넘겨주는 인자의 관계에 따라 적절하게 판단하여 사용하면 됩니다.

	// 꼬리 재귀
	func tailfactorial(x: Int, fac: Int) -> Int {
		if x == 1 {
			return fac
		}
		return tailfactorial(x-1, x * fac)
	}

	// 일반적인 재귀
	func recfactorial(x: Int) -> Int {
		if x == 1 {
			return 1
		}
		return x * recfactorial(x-1)
	}

	tailfactorial(10, 1) == recfactorial(10)	// true

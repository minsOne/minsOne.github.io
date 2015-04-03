---
layout: post
title: "쉽게 값을 교환하기 in swift"
description: ""
category: "Mac/iOS"
tags: [ios, swift, swap]
---
{% include JB/setup %}

일반적으로 값을 Swap 하기 위해서는 임시로 값을 저장하고 꺼내어 쓰게 됩니다.

	var tmp = str1
	str1 = str2
	str2 = tmp


<del>Swift에서는 다음과 같이 한줄로 처리할 수 있습니다.</del>

	(str1, str2) = (str2, str1)

Swift 기본 라이브러리 함수 swap을 지원합니다.

	func swap<T>(inout a: T, inout b: T)

	swap(&str1, &str2)
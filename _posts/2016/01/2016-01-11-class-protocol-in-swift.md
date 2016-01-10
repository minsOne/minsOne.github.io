---
layout: post
title: "[Swift]클래스만 사용 가능한 프로토콜 선언하기"
description: ""
category: "Mac/iOS"
tags: [swift, class, struct, protocol]
---
{% include JB/setup %}

프로토콜은 클래스나 구조체에서 사용 가능합니다. 또한, 프로토콜을 클래스에서만 사용 가능하도록 선언할 수 있습니다.

	protocol TTTProtocol: class {
		func hello(greeting: String)
	}

	class TTT: TTTProtocol {
		func hello(greeting: String) {
			print("Hello \(greeting)")
		}
	}

프로토콜 선언할 때 class를 붙여 선언하면 클래스에서만 사용 가능한 프로토콜이 됩니다.

만약 클래스가 아닌 구조체로 사용할 경우 프로토콜이 적합하지 않다고 에러가 발생합니다.

	// error: non-class type 'TTT' cannot conform to class protocol 'TTTProtocol'
	struct TTT: TTTProtocol {
		func hello(greeting: String) {
			print("Hello \(greeting)")
		}
	}

<br/><br/>
---
layout: post
title: "Singleton 패턴 사용 방법 3가지 in swift"
description: ""
category: "Mac/iOS"
tags: [swift, singleton, objectivec, objc, class constant, constant, nested struct, dispatch_once]
---
{% include JB/setup %}

Swift에서 Singleton 패턴을 사용하는 방법은 대표적으로 3가지 방법이 있습니다.

### 클래스 상수(Class constant)

	class SingletonA {

		static let sharedInstance = SingletonA()

		init() {
			println("AAA");
		}
	}

Lazy 방법을 통한 클래스 상수 초기화와 `let` 정의로 스레드에 안전하게 Singleton 패턴을 사용할 수 있습니다. 단, 이 방법은 Swift 1.2에서 지원하며, Xcode가 최신버전이 아닐 경우 사용할 수 없습니다.

### 중첩 구조체(Nested struct)

	class SingletonB {
		class var sharedInstance: SingletonB {
			struct Static {
				static let instance: SingletonB = SingletonB()
			}
			return Static.instance
		}
	}

클래스 상수로서 중첩 구조체의 정적 상수로 사용하여 Singleton 패턴을 사용하였습니다. 단, 정적 클래스 상수의 단점을 위한 차선책이며, Swift 1.1 이하 버전에서 지원합니다.

### dispatch_once

	class SingletonC {

		class var sharedInstance: SingletonC {
			struct Static {
				static var onceToken: dispatch_once_t = 0
				static var instance: SingletonC? = nil
			}
			dispatch_once(&Static.onceToken) {
				Static.instance = SingletonC()
			}
			return Static.instance!
		}
	}

기존 Objective-C 방법을 Swift로 포팅한 것입니다.

### 결론

대부분 Swift로 개발하시는 분들은 Swift 1.2 버전을 사용하기 때문에, 클래스 상수를 이용하여 Singleton을 구현하는 것을 추천드립니다.

### 참고 자료

* [SwiftSingleton](https://github.com/hpique/SwiftSingleton)
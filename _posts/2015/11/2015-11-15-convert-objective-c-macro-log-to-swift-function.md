---
layout: post
title: "[Swift]Swift 로그 매크로(?) 만들기"
description: ""
category: "Mac/iOS"
tags: [swift, function, log, trace, print]
---
{% include JB/setup %}

이전에 작성한 [상세 로그 만들기](../easy-write-nslog-on-xcode/)에서 DFT_TRACE 매크로를 만들어 잘 사용했었습니다. 

Swift에서는 매크로를 사용할 수 없어, 전역으로 사용할 함수를 만들어 호출하도록 만들었습니다.

	func DFT_TRACE(filename: String = __FILE__, line: Int = __LINE__, funcname: String = __FUNCTION__) {
		print("\(filename)[\(funcname)][Line \(line)]")
	}

	func DFT_TRACE_PRINT(filename: String = __FILE__, line: Int = __LINE__, funcname: String = __FUNCTION__, output:Any...) {
		#if DEBUG
		let now = NSDate()
		print("[\(now.description)][\(filename)][\(funcname)][Line \(line)] \(output)")
		#endif
	}

	// Using
	DFT_TRACE()
	DFT_TRACE_PRINT(output: "Hello world")
	DFT_TRACE_PRINT(output: "Hello world", "Hello Swift")

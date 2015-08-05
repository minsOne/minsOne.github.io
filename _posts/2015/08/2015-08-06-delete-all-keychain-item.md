---
layout: post
title: "[Objective-C]모든 KeyChain 제거하기"
description: ""
category: "mac/ios"
tags: [keychain, objc, delete, SecItemDelete, kSecClass]
---
{% include JB/setup %}

키체인에 정보를 저장하고나서 테스트를 위해 기기를 클린 상태로 돌려야 할 때 사용하는 Code Snippet 입니다.

	NSArray *secItemClasses = @[(__bridge id)kSecClassGenericPassword,
								(__bridge id)kSecClassInternetPassword,
								(__bridge id)kSecClassCertificate,
								(__bridge id)kSecClassKey,
								(__bridge id)kSecClassIdentity];
	for (id secItemClass in secItemClasses) {
		NSDictionary *spec = @{(__bridge id)kSecClass: secItemClass};
		SecItemDelete((__bridge CFDictionaryRef)spec);
	}

### 참고자료

* [Stackoverflow](http://stackoverflow.com/a/14086320)
---
layout: post
title: "[Xcode][iOS]App Transport Security"
description: ""
category: "Mac/iOS"
tags: [ios, xcode, http, https, ats, NSAppTransportSecurity]
---
{% include JB/setup %}

### App Transport Security

애플이 iOS9부터는 http를 https로 해야지만 네트워크 연결할 수 있도록 하였습니다. 하지만 예외는 항상 존재하는 법. 특정 도메인에 대해서 http를 허용하거나 아예 http를 허용하도록 해주었습니다.

#### 특정 도메인 HTTP 허용

다음은 페이스북에서 다음과 같이 info.plist에 추가하라고 한 설정입니다.

	<key>NSAppTransportSecurity</key>
	<dict>
	    <key>NSExceptionDomains</key>
	    <dict>
	        <key>facebook.com</key>
	        <dict>
	            <key>NSIncludesSubdomains</key>
	            <true/>                
	            <key>NSThirdPartyExceptionRequiresForwardSecrecy</key>
	            <false/>
	        </dict>
	        <key>fbcdn.net</key>
	        <dict>
	            <key>NSIncludesSubdomains</key>
	            <true/>
	            <key>NSThirdPartyExceptionRequiresForwardSecrecy</key>
	            <false/>
	        </dict>
	        <key>akamaihd.net</key>
	        <dict>
	            <key>NSIncludesSubdomains</key>
	            <true/>
	            <key>NSThirdPartyExceptionRequiresForwardSecrecy</key>
	            <false/>
	        </dict>
	    </dict>
	</dict>

#### HTTP 허용

다음은 http를 허용하는 설정입니다.

	<key>NSAppTransportSecurity</key>
	<dict>
	  <key>NSAllowsArbitraryLoads</key>
	      <true/>
	</dict>
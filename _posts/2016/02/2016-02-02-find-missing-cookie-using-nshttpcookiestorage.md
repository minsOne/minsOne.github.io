---
layout: post
title: "[iOS][Swift]NSHTTPCookieStorage를 이용하여 사라진 Cookie 찾기"
description: ""
category: "Mac/iOS"
tags: [swift, ios, NSHTTPCookieStorage, Alamofire, NSURLSession, header, request, cookie]
---
{% include JB/setup %}

사내에서 돌아가고 있는 서비스를 웹페이지를 파싱해서 앱으로 만들고 있습니다. 사내 서비스가 토이 프로젝트였기 때문에 앱 형태의 서비스는 고려되지 않지만 대부분 작업을 수월하게 진행하였습니다. 그러나 마지막 작업을 진행하던 도중 Cookie에 두 개의 값이 들어와야 하는데 하나만 들어와서 이를 찾고자 하였는데 못 찾았습니다.

웹에서는 정상적으로 Cookie에 두 개의 값이 들어오는데 앱이 요청했을 때는 Cookie에 값 하나만 내려와서 도저히 찾지 못했습니다.

	// 웹에서 받은 Cookie
	Set-Cookie:csrftoken=e4MxEh5RR7h73nQitsMg7qhatFRKjj6Z; expires=Tue, 31-Jan-2017 06:53:34 GMT; Max-Age=31449600; Path=/
	Set-Cookie:sessionid=3kxp2bq1fvxsa99pa7wt50hnwpr0xtl0; expires=Tue, 16-Feb-2016 06:53:34 GMT; httponly; Max-Age=1209600; Path=/

	// 앱에서 받은 Cookie
	Set-Cookie:csrftoken=e4MxEh5RR7h73nQitsMg7qhatFRKjj6Z; expires=Tue, 31-Jan-2017 06:53:34 GMT; Max-Age=31449600; Path=/

앱에서 받은 Response는 딕셔너리 형태로 내려오기 때문에 Set-Cookie라는 키가 중복되어 하나는 사라지는 것으로 추정되었습니다.
	
	response.allHeaderFields["Set-Cookie"]

사라진 Cookie인 sessionid를 어떻게 얻어야 할지 찾아보다 `NSHTTPCookieStorage`를 알게 되었습니다. 네트워크 작업을 하기 위해 `NSURLSessionConfiguration`를 생성할 때 HTTPCookieStorage 속성에 NSHTTPCookieStorage를 할당합니다.

	let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
	configuration.HTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()

Swift에서 가장 많이 쓰이는 라이브러리인 Alamofire를 통해서 다음과 같이 적용합니다.

	let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    configuration.HTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
	
	let manager = Manager(configuration: configuration)

이제 Cookie가 사라지는 주소로 요청한 후 해당 주소로 저장된 Cookie를 찾습니다.

	manager.request(.GET, "http://example.com").response { x in
		print(NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(NSURL(string: "http://example.com")!))
	}

	// Output
	[<NSHTTPCookie version:0 name:"csrftoken" value:"e4MxEh5RR7h73nQitsMg7qhatFRKjj6Z" expiresDate:2017-01-31 10:20:36 +0000 created:2016-02-02 10:20:36 +0000 sessionOnly:FALSE domain:"example.com" path:"/" isSecure:FALSE>,
	<NSHTTPCookie version:0 name:"sessionid" value:"3kxp2bq1fvxsa99pa7wt50hnwpr0xtl0" expiresDate:2016-02-16 10:20:35 +0000 created:2016-02-02 10:20:35 +0000 sessionOnly:FALSE domain:"example.com" path:"/" isSecure:FALSE>])

이제 사라졌던 sessionid 값을 얻을 수 있게 되었습니다.

	let sessionid = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(NSURL(string: "example.com")!)?[1]?.value
	print(sessionid)

	// Output
	3kxp2bq1fvxsa99pa7wt50hnwpr0xtl0

<br/><br/>
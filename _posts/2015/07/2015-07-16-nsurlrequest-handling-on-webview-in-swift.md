---
layout: post
title: "UIWebView에서 Request 제어 in Swift"
description: ""
category: "Mac/iOS"
tags: [swift, UIWebView, NSURLRequest, Bool, return]
---
{% include JB/setup %}

### UIWebView

UIWebView에서 특정 Request가 호출될 때, 호출할 것인지 아니면 중단할 것인지 제어를 할 수 있습니다. 이러한 기능이 필요한 경우는, 광고 페이지를 보고싶지 않거나, 특정 페이지까지만 호출되고 그 결과만 받고자 할 때, NSURLSession 또는 NSURLConnection을 통해서 요청하는 것 보다 UIWebView를 통해 결과를 받고자 할 때 등이 있습니다.

UIWebViewDelegate 프로토콜에서 `webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType)` 함수를 통해 요청을 보내기 전에 제어가 가능합니다.

	func webView(webView: UIWebView,
	    shouldStartLoadWithRequest request: NSURLRequest,
	    navigationType: UIWebViewNavigationType) -> Bool 
	{
		 if request.URL?.host == "m.naver.com" {
			return false;
        }
        return true
    }

위의 코드에서 `true` 를 반환하면 그대로 요청을 보내고, `false`를 반환하면 더이상 진행하지 않습니다. 이를 적절히 이용하여 특정 페이지 또는 특정 URL만을 요청할 수 있도록 만드는 것도 가능합니다.

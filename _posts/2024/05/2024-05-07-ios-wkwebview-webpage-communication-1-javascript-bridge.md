---
layout: post
title: "[iOS] WKWebView을 이용한 iOS 앱과 웹페이지 간의 통신 (1) - WKWebView과 Javasciprt Bridge"
tags: [iOS, WKWebView, Javascript]
---
{% include JB/setup %}

iOS 앱과 웹페이지 간의 통신은 WKWebView을 이용하여 쉽게 구현할 수 있습니다. 웹페이지는 iOS 앱으로 데이터를 전달하면, iOS 앱은 웹페이지의 JavaScript 함수를 호출할 수 있습니다.

### 웹페이지 -> iOS

웹에서 iOS 앱으로 데이터를 전달하는 방법은 서로 약속한 이름을 가진 `window.webkit.messageHandlers`의 객체를 이용하는 방법이 있습니다.

```js
window.webkit.messageHandlers.actionHandler.postMessage({
    "action": "hello",
    "message": "Hello from JavaScript!"
});
```

<details><summary>Html Source Code</summary>

<script src="https://gist.github.com/minsOne/c45f71e1ae8076a9f85325d7dd0f1e07.js"></script>

</details>

<br/>앱과 웹페이지 간의 약속한 이름인 `actionHandler` 객체를 `postMessage` 함수를 이용하여 iOS 앱으로 데이터를 전달합니다.

iOS 앱은 `WKUserContentController`에 `actionHandler` 메시지 핸들러를 등록하고, `WKScriptMessageHandler` 프로토콜 메소드인 `func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage)`를 구현합니다.<br/>

```swift
class ViewController: UIViewController, WKScriptMessageHandler {
  var webView: WKWebView?

  override func viewDidLoad() {
    super.viewDidLoad()

    // WKUserContentController 인스턴스 생성
    let userContentController = WKUserContentController()
    userContentController.add(self, name: "actionHandler") // 메시지 핸들러 등록
      
    // WKWebView에 WKUserContentController 설정
    let configuration = WKWebViewConfiguration()
    configuration.userContentController = userContentController
      
      
    // WKWebView 인스턴스 생성
    let webView = WKWebView(frame: view.bounds, configuration: configuration)
    self.webView = webView

    view.addSubview(webView)
  }

  // WKScriptMessageHandler 프로토콜 메서드 구현
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    print(message.name, message.body)

    guard
      message.name == "actionHandler",
      let messageBody = message.body as? [String: Any]
    else { return }  

    print("Received message from JavaScript: \(messageBody)") // 웹으로부터 받은 메시지를 파싱하여 print를 호출하는 코드.
  }
}
```

웹페이지에서 actionHandler 객체를 이용하여 전달한 데이터를 iOS 앱에서 수신하는 것을 아래 영상에서 확인할 수 있습니다.

<br/><video src="{{ site.production_url }}/image/2024/05/01.mov" width="800px" controls autoplay loop></video><br/><br/><br/>

### iOS -> 웹페이지

WKWebView에서는 `evaluateJavaScript` 메서드를 이용하여 웹페이지의 JavaScript 함수를 호출할 수 있습니다.

위의 코드에서 action이 `hello` 인 경우, 웹페이지의 `javaScriptFunction` 함수를 호출하도록 코드를 수정해봅시다.

```swift
// WKScriptMessageHandler 프로토콜 메서드 구현
func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
  guard
    message.name == "actionHandler",
    let messageBody = message.body as? [String: Any],
    let action = messageBody["action"] as? String
  else { return }
  
  print("Received message from JavaScript: \(messageBody)") // 웹으로부터 받은 메시지를 파싱하여 print를 호출하는 코드.
  
  if action == "hello" {
    let jsFunctionCall = "javaScriptFunction();"
    webView?.evaluateJavaScript(jsFunctionCall, completionHandler: nil) // WKWebView에서 JavaScript 코드 실행
  } else if action == "log" {
    print("Called javascript function")
  }
}
```

웹페이지에서 `javaScriptFunction` 함수를 호출되고 다시 action에 `log`로 앱으로 호출하는 코드를 아래 영상에서 확인할 수 있습니다.

<br/><video src="{{ site.production_url }}/image/2024/05/02.mov" width="800px" controls autoplay loop></video><br/>

### 정리

* 앱과 웹은 약속한 이름을 가진 객체와 함수의 이름을 사용하여 통신합니다.

[예제 코드](https://github.com/minsOne/Experiment-Repo/tree/master/20240507)

## 참고자료

* [아리의 iOS 탐구생활 - [iOS] 웹뷰를 사용할 때 자바스크립트로 양방향 통신하기](https://leeari95.tistory.com/82)
* [모비두 - Web + Mobile 통신 구현 (Bridge)](https://docs.sauce.im/docs/web-mobile-%ED%86%B5%EC%8B%A0-%EA%B0%80%EC%9D%B4%EB%93%9C-bridge)
* GitHub
  * [ClintJang/sample-swift-wkwebview-javascript-bridge-and-scheme](https://github.com/ClintJang/sample-swift-wkwebview-javascript-bridge-and-scheme)
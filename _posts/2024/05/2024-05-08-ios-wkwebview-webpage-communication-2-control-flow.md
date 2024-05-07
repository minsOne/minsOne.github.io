---
layout: post
title: "[iOS] WKWebView을 이용한 iOS 앱과 웹페이지 간의 통신 (2) - Control Flow"
tags: [iOS, WKWebView, Javascript, if, switch, statement]
---
{% include JB/setup %}

이전 글에서 `WKScriptMessageHandler` 프로토콜의 메소드인 `func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage)`를 구현하여 웹 페이지에서 iOS 앱으로 데이터를 전달하는 방법을 살펴보았습니다.

이번 글에서는 `userContentController` 메소드에서 구현되는 if 문과 switch 문과 같은 흐름제어(Control Flow) 코드로 인해 `WKWebView`와 다른 도메인과의 강한 결합 관계가 형성되는 것을 살펴보려고 합니다.

### Control Flow

Swift는 if, switch 문과 같이 제어문을 제공합니다. 이는 프로그램의 흐름을 제어하는데 사용됩니다. 웹에서 전달받은 데이터를 검증하고, 유효한 데이터가 아닐 경우 다시 웹으로 데이터를 전달하는 등의 흐름을 제어할 수 있습니다. 

제어한다는 의미는 어떤 조건에 따라 코드의 실행을 중단하거나, 코드의 실행을 계속할지 결정하는 것을 의미합니다. 여기에서 각 도메인에서 필요한 Action을 처리하고 전달해야한다면 `userContentController` 는 많은 도메인과 강한 결합 관계를 형성합니다.

다음 코드는 웹페이지에서 전달받은 message의 action을 구분하여 처리하는 코드입니다:

```swift
// WKScriptMessageHandler 프로토콜 메서드 구현
func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
  // 메시지의 이름과 body 추출
  guard
    message.name == "actionHandler",
    let messageBody = message.body as? [String: Any],
    let action = messageBody["action"] as? String
  else { return }
  
  // Action에 따라 처리하는 switch 문
  switch action {
    case "loading": loading(body: messageBody)
    case "openCard": openCard(body: messageBody)
    case "payment": payment(body: messageBody)
    case "log": log(body: messageBody)
    default: break
  }

  // loading Action을 처리하는 함수
  func loading(body: [String: Any]) {
    guard
      let value = body["show"] as? Bool
    else { return }

    switch value {
      case true: ShowLoading()
      case false: HideLoading()
    }
  }

  // payment Action을 처리하는 함수
  func payment(body: [String: Any]) {
    guard
      let id = body["paymentId"] as? String
      let info = body["paymentInfo"] as? [String: String]
    else { return }

    cardPayment(paymentId: id, paymentInfo: info)
  }
}
```

위 코드의 switch 문에서 loading, openCard, payment, log Action을 구분하여 처리하고 있습니다. 각 action은 서로 다른 역할을 수행하도록 구현되어 있습니다. 

즉, switch 문은 다양한 비즈니스 로직을 처리할 수 있는 장점이 있지만, 웹페이지에서 전달받은 action이 많아질 경우, 비즈니스 로직을 처리하는 코드가 복잡해지고, 코드의 가독성이 떨어져, 유지보수가 어려워지는 단점이 있습니다.

그렇다면, 다양한 Action을 처리하는 코드를 주입받아 처리할 수 있도록 하면 어떨까요?

### Inject Action Handler

`Action`을 Key로 사용하고, `messageBody`를 받아 수행하는 `Closure`를 가지는 Dictionary를 만들 수 있습니다.

```swift
struct WKScriptMessageActionHandler {
  let closure: (_ body: [String: Any], _ webView: WKWebView?) -> Void
}

class ViewController: UIViewController, WKScriptMessageHandler {
  let actionHandlers: [String: WKScriptMessageActionHandler]
  var webView: WKWebView?
    
  init(actionHandlers: [String : WKScriptMessageActionHandler] = [:]) {
    self.actionHandlers = actionHandlers

    super.init(nibName: nil, bundle: nil)
  }
  ...

  // WKScriptMessageHandler 프로토콜 메서드 구현
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    guard
      message.name == "actionHandler",
      let messageBody = message.body as? [String: Any],
      let action = messageBody["action"] as? String
    else { return }

    actionHandlers[action]?.closure(messageBody, webView)
  }
}
```

`userContentController` 메소드에서 `actionHandlers` Dictionary에 등록되어 있는 `WKScriptMessageActionHandler`를 찾아 `closure`를 호출합니다. 이전과 같이 switch 문을 통해 action을 구분하여 처리하지 않기 때문에, 웹페이지에서 전달받은 action이 많아지더라도, 비즈니스 로직을 처리하는 코드가 없기 때문에 유지보수가 쉬워집니다.

`WKScriptMessageActioHandler`는 Closure만 가지고 있어, 각 ActionHandler가 messageBody의 값을 검증하여 유효한 값인 경우에만 Closure를 호출할 수 있도록 코드를 좀 더 구조화할 수 있지 않을까요?

그 내용은 다음편에서 다루겠습니다.

---
layout: post
title: "[iOS] WKWebView을 이용한 iOS 앱과 웹페이지 간의 통신 (3) - Plugin을 이용하여 기능 확장하기"
tags: [iOS, WKWebView, Javascript, if, switch, statement, Plugin]
---
{% include JB/setup %}

이전 글에서 웹페이지에서 전달한 Action을 처리하는 조건문의 구현이 계속 늘어나, 모든 기능을 포함하도록 된다는 것을 알 수 있었습니다. 

이번 글에서는 `WKWebView`와 다른 도메인과의 강한 결합 관계를 피하기 위해 Plugin을 이용하여 기능을 확장하는 방법을 알아보려고 합니다.

## Plugin

Plugin이란, 특정 기능을 수행하는 코드를 따로 분리하는 것을 의미합니다. Plugin을 이용하면 기능을 확장하거나, 기능을 수정할 때 기존 코드를 수정하지 않고도 기능을 추가할 수 있습니다. 

웹페이지에서 전달하는 Action을 처리하는 조건문의 코드를 Plugin으로 분리하여, 기존 코드를 수정하지 않도고 새로운 Plugin을 추가함으로써 기능을 추가할 수 있습니다.

### Plugin 구현

Plugin을 구현하기 전에, 웹페이지에서 iOS 앱으로 전달하는 전달하는 JSON 구조는 다음과 같습니다.

```json
{
  "action": "action",
  "uuid": "uuid",
  "body": "body"
}
```

body는 String, Int, Bool, Array, Dictionary 등의 타입을 가지는 값으로 구성됩니다. Action에 따라 body의 구조가 달라지므로 Plugin에서 body를 파싱하는 방법을 구현해야 합니다.

Plugin은 Action을 Key로 사용하고, message를 넘겨받을 수 있도록 하는 `callAsAction` 메소드를 가지는 `JSInterfacePluggable` 프로토콜을 구현합니다.

```swift
// FileName : JSInterfacePluggable.swift

import WebKit

protocol JSInterfacePluggable {
  var action: String { get }
  func callAsAction(_ message: [String: Any], with: WKWebView)
} 
```

다음으로, Plugin을 관리하는 Supervisor를 만들고, 웹뷰로부터 특정 Action을 수행 요청을 받으면 Plugin의 callAsAction을 호출하도록 하는 기능을 구현합니다.

```swift
// FileName : JSInterfaceSupervisor.swift

import Foundation
import WebKit

/// Supervisor class responsible for loading and managing JS plugins.
class JSInterfaceSupervisor {
  var loadedPlugins = [String: JSInterfacePluggable]()

  init() {}
}

extension JSInterfaceSupervisor {
  /// Loads a single plugin into the supervisor.
  func loadPlugin(_ plugin: JSInterfacePluggable) {
    let action = plugin.action

    guard loadedPlugins[action] == nil else {
      assertionFailure("\(action) action already exists. Please check the plugin.")
      return
    }

    loadedPlugins[action] = plugin
  }

  /// Loads multiple plugins into the supervisor.
  func loadPlugin(contentsOf newElements: [JSInterfacePluggable]) {
    newElements.forEach { loadPlugin($0) }
  }
}

extension JSInterfaceSupervisor {
  /// Resolves an action and calls the corresponding plugin with a message and web view.
  func resolve(_ action: String, message: [String: Any], with webView: WKWebView) {
    guard
      let plugin = loadedPlugins[action],
      plugin.action == action
    else {
      assertionFailure("Failed to resolve \(action): Action is not loaded. Please ensure the plugin is correctly loaded.")
      return
    }

    plugin.callAsAction(message, with: webView)
  }
}
```

`JSInterfaceSupervisor`는 `JSInterfacePluggable` 프로토콜을 준수하는 Plugin을 관리하는 역할을 수행합니다. `JSInterfacePluggable` 프로토콜을 준수하는 Plugin을 `loadPlugin` 메소드를 이용하여 로드하고, `WKWebView`로부터 Action을 수행 요청을 받으면, `resolve` 메소드를 호출하여 Plugin을 호출합니다.

이제 웹페이지에서 전달받은 Action을 처리하는 조건문의 코드를 Plugin으로 분리합니다.

```swift
// Before

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
  ...
}

// After

private let supervisor = JSInterfaceSupervisor()

func set(plugins: [JSInterfacePluggable]) {
  supervisor.loadPlugin(contentsOf: plugins)
}

...

func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
  // 메시지의 이름과 body 추출
  guard
    message.name == "actionHandler",
    let messageBody = message.body as? [String: Any],
    let action = messageBody["action"] as? String
  else { return }

  // Supervisor에게 Action을 수행 요청
  supervisor.resolve(action, message: messageBody, with: webView)
}
```

다음으로, 각 Action에 해당하는 Plugin을 만들어봅시다.

```swift
// MARK: - LoadingJSPlugin
class LoadingJSPlugin: JSInterfacePluggable {
  struct Info {
    let uuid: String
    let isShow: Bool
  }

  let action = "loading"

  func callAsAction(_ message: [String: Any], with webView: WKWebView) {
    guard
      let result = Parser(message)
    else { return }

    closure?(result.info, webView)
  }

  func set(_ closure: @escaping (Info, WKWebView) -> Void) {
    self.closure = closure
  }

  private var closure: ((Info, WKWebView) -> Void)?
}

private extension LoadingJSPlugin {
  struct Parser {
    let info: Info

    init?(_ dictonary: [String: Any]) {
      guard
        let uuid = dictonary["uuid"] as? String,
        let body = dictonary["body"] as? [String: Any],
        let isShow = body["isShow"] as? Bool
      else { return nil }

      info = .init(uuid: uuid, isShow: isShow)
    }
  }
}

// MARK: - PaymentJSPlugin
class PaymentJSPlugin: JSInterfacePluggable {
  struct Info {
    let uuid: String
    let paymentAmount: Int
    let paymentTransactionId: String
    let paymentId: String
    let paymentGoodsName: String
  }

  let action = "payment"

  func callAsAction(_ message: [String: Any], with webView: WKWebView) {
    guard
      let result = Parser(message)
    else { return }

    closure?(result.info, webView)
  }

  func set(_ closure: @escaping (Info, WKWebView) -> Void) {
    self.closure = closure
  }

  private var closure: ((Info, WKWebView) -> Void)?
}

private extension PaymentJSPlugin {
  struct Parser {
    let info: Info

    init?(_ dictonary: [String: Any]) {
      guard
        let uuid = dictonary["uuid"] as? String,
        let body = dictonary["body"] as? [String: Any],
        let paymentAmount = body["paymentAmount"] as? Int,
        let paymentTransactionId = body["paymentTransactionId"] as? String,
        let paymentId = body["paymentId"] as? String,
        let paymentGoodsName = body["paymentGoodsName"] as? String
      else { return nil }

      info = .init(
        uuid: uuid,
        paymentAmount: paymentAmount,
        paymentTransactionId: paymentTransactionId,
        paymentId: paymentId,
        paymentGoodsName: paymentGoodsName
      )
    }
  }
}
```

위와 같이 `JSInterfacePluggable` 프로토콜을 준수하는 Plugin을 만들고, Plugin를 생성하고, Closure를 주입한 뒤, `JSInterfaceSupervisor`에 Plugin을 등록하면 됩니다.

```swift
let loadingPlugin = LoadingJSPlugin()
let paymentPlugin = PaymentJSPlugin()
loadingPlugin.set { info, webView in 
  // Loading Action일 때 수행할 코드
}
paymentPlugin.set { info, webView in 
  // Payment Action일 때 수행할 코드
}

webViewManager.set(plugins: [loadingPlugin, paymentPlugin])
```

이제 웹페이지에서 Action을 수행하는 코드를 Plugin으로 분리했습니다. 추가되는 Action에 맞춰 Plugin을 만들고, 필요한 Plugin을 등록하는 방식으로 진행하면 됩니다.

이와 같은 방식은 웹페이지에서 전달하는 Action 뿐만 아니라, AppScheme, 채팅 등의 다른 방식에서도 Plugin 방식을 적용하여 코드를 더욱 쉽게 유지하고 관리할 수 있습니다.

## 정리

이번 포스팅에서는 웹페이지에서 Action을 수행하는 코드를 Plugin으로 분리하는 방법에 대해서 알아보았습니다. 

웹페이지에서 전달받은 Action을 수행하는 코드를 Plugin으로 분리하는 방식은 코드를 더욱 쉽게 유지하고 관리할 수 있게 해주며, Action을 처리하는 코드를 더욱 간결하게 작성할 수 있습니다.

[예제 코드](https://github.com/minsOne/Experiment-Repo/tree/master/20240511)

## 참고자료

* Post
  * [분리 인터페이스 패턴, 플러그인 패턴](https://harrislee.tistory.com/62)
  * [Using the plugin pattern in a modularized codebase](https://proandroiddev.com/using-the-plugin-pattern-in-a-modularized-codebase-af8d4905404f)
  * [Introduction to Plugin Architecture in C#](https://www.youtube.com/watch?v=g4idDjBICO8)
  * [Plug-in Architecture](https://medium.com/omarelgabrys-blog/plug-in-architecture-dec207291800)
  * [Extending modules using a plugin architecture](https://medium.com/@tyronemichael/extending-your-modules-using-a-plugin-architecture-c1972735d728)
  * [Plugin-Based Architecture and Scaling iOS Development at Capital One](https://medium.com/capital-one-tech/plugin-based-architecture-and-scaling-ios-development-at-capital-one-fb67561c7df6)
  * [Swift By Sundell - Making Swift code extensible through plugins](https://www.swiftbysundell.com/articles/making-swift-code-extensible-through-plugins/)
* GitHub
  * [ionic-team/capacitor](https://github.com/ionic-team/capacitor/blob/main/ios/Capacitor/Capacitor/CAPBridgeProtocol.swift)
  * [capacitor-community/generic-oauth2](https://github.com/capacitor-community/generic-oauth2/blob/276f01d4883748a776e86d80ad9b0b547309561f/ios/Plugin/GenericOAuth2Plugin.swift#L82)
  * [TYRONEMICHAEL/plugin-architecture-swift](https://github.com/TYRONEMICHAEL/plugin-architecture-swift)
  * [Electrode-iOS/ELMaestro](https://github.com/Electrode-iOS/ELMaestro/blob/master/ELMaestro/Pluggable.swift)


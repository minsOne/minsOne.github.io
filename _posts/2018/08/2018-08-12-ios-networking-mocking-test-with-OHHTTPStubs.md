---
layout: post
title: "[iOS][Network]Mock 데이터로 서비스 개발하기 - OHHTTPStubs"
description: ""
category: "iOS/Mac"
tags: [Xcode, LLDB, lldb, debug, swift, OHHTTPStubs, stub, test, API, URLSession]
---
{% include JB/setup %}

iOS 개발 중에 가장 번거로운 부분이 있는데 바로 서버와의 통신입니다. 서버에 요청하고 비동기로 응답값을 받아 처리해야하는데, 문제는 서버와 실제 통신을 해야 한다는 점입니다.

클라이언트는 다양한 경우를 만들어 서버에 던지고 받고 반복하는데, 그러다 디비에 기록된 상태가 변경되어 더이상 테스트를 할 수 없게 된다던지 등의 문제가 있기 때문에 테스트 하는데 항상 신중하게 하게 됩니다.

이를 위해 Mock 객체를 만들어서 하거나 하기도 하는데, 아직 그렇게 테스트를 잘 하지 못해 다른 방법이 없을까 하고 뒤적뒤적 하다보니 [OHHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs)라는 프로젝트를 알게 되었습니다.

NSURLSessionConfiguration를 swizzling을 하여 테스트할 API를 호출하면 미리 설정한 응답값으로 내려오도록 해줍니다.

본격적으로 OHHTTPStubs 사용 방법에 대해 알아봅시다.

## **OHHTTPStubs**

예를 들어, `https://google.com/helloworld` 라는 임의의 주소를 요청하면, `HelloWorld` 라는 문자열을 받고 싶다고 해봅시다.

그러면 OHHTTPStubs를 이용하여 URLSession으로 요청을 보내기 전에 어떤 응답값을 내려보낼지 작업을 먼저 합니다.

```
stub(condition: { (request) -> Bool in
    return (request.url?.absoluteString == "https://google.com/helloworld")
}) { request -> OHHTTPStubsResponse in
    let stubData = "Hello World!".data(using: String.Encoding.utf8)
    return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
}
```

URLRequest의 주소가 `https://google.com/helloworld` 이면 가짜 Response를 내려주도록 합니다.

이제 URLSession으로 `https://google.com/helloworld` 주소를 요청해봅시다.

```
let url: URL = URL(string: "https://google.com/helloworld")!
URLSession.shared.dataTask(with: url) { (data, response, error) in
    if let data = data {
        print("data: \(String(data: data, encoding: .utf8) ?? "")")
    }
    if let response = response {
        print("response : \(response)")
    }
    if let error = error {
        print("error : \(error)")
    }
}.resume()

/// Print
data: Hello World!
response : <NSHTTPURLResponse: 0x600002e9eac0> { URL: https://google.com/helloworld } { Status Code: 200, Headers {
    "Content-Length" =     (
        12
    );
} }
```

위 코드의 호출 결과로 가짜 Response 결과를 내려오는 것을 확인 할 수 있습니다.

이를 이용하여, 서비스 개발 중일 때 API가 나오지 않거나 아직 Response를 받을 수 없는 상태라고 한다면, OHHTTPStubs를 이용하여 가짜 Response를 받아 선행해서 개발이 가능합니다.

상세한 설명은 OHHTTPStubs의 [Wiki](https://github.com/AliSoftware/OHHTTPStubs/wiki)에서 확인할 수 있습니다.

## **OHHTTPStubs와 LLDB**

그러면 실행하고 있는 도중에 특정 데이터를 테스트해야 할 경우가 있으면 어떻게 해야할까요? LLDB를 이용하여 런타임시에 우리가 응답받을 데이터를 밀어넣도록 할 수 있습니다.

우선 간편하게 `stub`을 사용할 수 있도록 `stub` 함수를 가공합니다.

```
/// 1. URL와 Response에 특정 문자열만 String을 내려주는 Stub
func stub(url: String, data str: String) {
    stub(condition: { (request) -> Bool in
        return (request.url?.absoluteString == url)
    }) { (request) -> OHHTTPStubsResponse in
        let stubData = str.data(using: .utf8)
        return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
    }
}

/// 2. URL과 Bundle에 있는 파일 내용을 Response로 내려주는 Stub
func stub(url: String, bundle: (name: String, extension: String)) {
    guard
        let filePath = Bundle.main.url(forResource: bundle.name, withExtension: bundle.extension),
        let stubData = try? Data(contentsOf: filePath)
        else { return }
    stub(condition: { (request) -> Bool in
        return (request.url?.absoluteString == url)
    }) { (request) -> OHHTTPStubsResponse in
        return OHHTTPStubsResponse(data: stubData, statusCode:200, headers:nil)
    }
}

/// 3. URL와 임의의 경로에 있는 파일 내용을 Response로 내려주는 Stub
func stub(url: String, path: String) {
    let filePath = URL(fileURLWithPath: path)
    guard let stubData = try? Data(contentsOf: filePath)
        else { return }
    stub(condition: { (request) -> Bool in
        return (request.url?.absoluteString == url)
    }) { (request) -> OHHTTPStubsResponse in
        return OHHTTPStubsResponse(data: stubData, statusCode:200, headers:nil)
    }
}
```

이제 LLDB를 이용하여 런타임시 가짜 Response를 내릴 수 있도록 할 수 있습니다.

```
/// Pause를 이용하여 디버깅을 하는 경우
(lldb) settings set target.language swift
(lldb) po import SampleProject
(lldb) po stub(url: "https://google.com/helloworld1", data: "hell world")
(lldb) po stub(url: "https://google.com/helloworld2", bundle: (name: "sample", extension: "json"))
(lldb) po stub(url: "https://google.com/helloworld3", path: "/Users/Workspace/SampleProject/sample.json")

/// Break Point를 이용하여 디버깅을 하는 경우
(lldb) po stub(url: "https://google.com/helloworld1", data: "hell world")
(lldb) po stub(url: "https://google.com/helloworld2", bundle: (name: "sample", extension: "json"))
(lldb) po stub(url: "https://google.com/helloworld3", path: "/Users/Workspace/SampleProject/sample.json")
```

## 요약

* 서비스 개발시 서버가 아직 API가 나오지 않았다고 하면, OHHTTPStubs를 이용하여 약속한 Response 구조에 맞춰 가짜 Response를 등록하여 선 작업이 가능함.

## 관련 라이브러리

* [Mockingjay](https://github.com/kylef/Mockingjay)
* [Nocilla](https://github.com/luisobo/Nocilla)
* [Kakapo](https://github.com/devlucky/Kakapo)


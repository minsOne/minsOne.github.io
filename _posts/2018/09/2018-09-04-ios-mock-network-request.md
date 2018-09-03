---
layout: post
title: "[iOS] Custom Mock Network Request"
description: ""
category: ""
tags: [URLProtocol, APIRequest, WWDC, OHHTTPStubs]
---
{% include JB/setup %}

Unit Test를 할 때, 네트워크는 어떻게 테스트해야 하나 문제에 봉착합니다. 진짜 네트워크 요청을 해야하는건가 아니면 데이터만 테스트 해야하는가 이렇게 말이죠.

둘 다 테스트를 할 수 있다면 어떨까요? 네트워크 요청도 하고, 데이터도 테스트하고요.

URLProtocol를 이용하여 네트워크 요청의 결과를 여러가지 경우의 데이터로 내려줄 수 있습니다.

## Custom Mock Network Request

우선 APIRequest를 한번 정의해 봅시다.


```
protocol APIRequest {
    associatedtype RequestDataType
    associatedtype ResponseDataType
    func makeRequest(from data: RequestDataType) throws -> URLRequest
    func parseResponse(data: Data) throws -> ResponseDataType
}

class APIRequestLoader<T: APIRequest> {
    let apiRequest: T
    let urlSession: URLSession
    init(apiRequest: T, urlSession: URLSession = .shared) {
        self.apiRequest = apiRequest
        self.urlSession = urlSession
    }
}
```

위와 같이 APIRequest 프로토콜을 정의하고, APIRequestLoader가 요청하도록 APIRequest를 가집니다. 여기서 중요한 것은 URLSession을 주입받도록 했다는 점입니다.


이제 URLProtocol을 살펴봅시다. URLProtocol은 URL 데이터 로딩을 다루는 추상클래스로, 우리가 로직을 넣을 MockURLProtocol을 만들어봅시다.

```
class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
}
```

위와 같이 `startLoading` 함수 내에서 외부에서 주입한 Block을 통해 원하는 응답값을 내려받을 수 있도록 만들었습니다.

이제 `MockURLProtocol`을 `URLSessionConfiguration`의 `protocolClasses`에 넣고, 이 Configuration을 가지는 URLSession을 만듭니다.

```
let configuration = URLSessionConfiguration.ephemeral
configuration.protocolClasses = [MockURLProtocol.self]
let urlSession = URLSession(configuration: configuration)
```

위에서 만든 urlSession을 이용하여 테스트 코드를 작성해봅시다.

```
class APILoaderTests: XCTestCase {
    var loader: APIRequestLoader<PointsOfInterestRequest>!

	override func setUp() {
	    let request = PointsOfInterestRequest()
	    let configuration = URLSessionConfiguration.ephemeral
	    configuration.protocolClasses = [MockURLProtocol.self]
	    let urlSession = URLSession(configuration: configuration)
	    loader = APIRequestLoader(apiRequest: request, urlSession: urlSession)
    }
}

class APILoaderTests: XCTestCase {
    func testLoaderSuccess() {
        let inputCoordinate = CLLocationCoordinate2D(latitude: 37.3293, longitude: -121.8893)
        let mockJSONData = "[{\"name\":\"MyPointOfInterest\"}]".data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.query?.contains("lat=37.3293"), true)
            return (HTTPURLResponse(), mockJSONData)
        }

        let expectation = XCTestExpectation(description: "response")
        loader.loadAPIRequest(requestData: inputCoordinate) { pointsOfInterest, error in
            XCTAssertEqual(pointsOfInterest, [PointOfInterest(name: "MyPointOfInterest")])
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
}
```

APIRequestLoader에 우리가 만든 urlSession이 주입되었습니다. 이 urlSession로 네트워크 요청시 우리가 의도한 데이터를 반환하도록 하여 해당 테스트가 정상적으로 통과됨을 알 수 있습니다.

## 정리

직접 URLProtocol을 상속받아 구현할 수 있었지만, 다양한 경우를 다 대응하도록 만들기 위해서는 시간이 많이 걸릴 것으로 보여집니다. 따라서 개인적으로 추천하는 오픈소스인 `OHHTTPStubs`를 사용하여 쉽게 테스트를 통과시키도록 하는 것이 좋을 것 같습니다.

## 참고자료

* [WWDC 2018 - Testing Tips & Tricks](https://developer.apple.com/videos/play/wwdc2018/417/)
---
layout: post
title: "[iOS] 의존성 분리하기(외부 라이브러리, iOS의 클래스) - Unit Test"
description: ""
category: "iOS/Mac"
tags: [iOS, XCode, Project, Library, Dependency, Injection, Dependency Injection, DI]
---
{% include JB/setup %}

얼마 전에 전수열 님의 [Let's TDD 세미나](https://www.youtube.com/watch?v=meTnd09Pf_M)를 듣고, 의존성을 깨는 것부터 시작해야겠다고 생각을 했습니다. 외부 라이브러리를 추가해야 하는 경우, 일반적(?)으로 메인 프로젝트에 바로 넣고 그 라이브러리의 헬퍼 클래스나 함수를 사용을 해왔습니다. 

만약에 기존에 사용하고 있는 라이브러리가 [Firebase 용 Google Analytics](https://firebase.google.com/docs/ios/setup) 라고 했을 때, 이 것을 다른 라이브러리로 교체한다고 한다면 어떨까요? 헬퍼 클래스나 함수를 테스트해야하는데, 메인 프로젝트에 들어가 있으니 테스트 하기도 쉽지 않은 문제가 있습니다. 테스트를 하려고 무거운 메인 프로젝트를 매번 테스트해야하니까요. 그리고 메인 프로젝트의 테스트 목적에도 맞지 않습니다. 라이브러리 테스트를 메인 프로젝트를 하는 것이니까요.

그러면 어떻게 해야 할까요?

답은 외부 라이브러리를 가지고, 외부에서 호출할 수 있게 인터페이스를 제공해주는 프로젝트를 만드는 것입니다. 그리고 외부에서 호출했을 때, 의도한 대로 잘 동작하는지 유닛 테스트를 합니다.

## 의존성 분리 테스트하기 - 외부 라이브러리

별도의 프로젝트를 만들어 외부 라이브러리를 가지는 프로젝트를 만드는 것은 환경에 따라 다르므로(?), 여기에서는 생략합니다.

그러면 외부 라이브러리가 Firebase 용 Google Analytics라고 했을 때, Analytics의 인터페이스는 다음과 같습니다.

```
open class FirebaseApp : NSObject {
    open class func configure()
}
open class Analytics : NSObject {
    open class func logEvent(_ name: String, parameters: [String : Any]?)
    open class func setUserProperty(_ value: String?, forName name: String)
    open class func setUserID(_ userID: String?)
    open class func setScreenName(_ screenName: String?, screenClass screenClassOverride: String?)
    open class func appInstanceID() -> String
    open class func resetAnalyticsData()
}
```

<br/>우선 FirebaseApp과 Analytics 클래스에 함수들이 잘 동작하는지 확인해야 하므로, 이름이 같은 함수들을 Protocol에 정의합니다.

```
protocol AnalyticsConfigureServiceProtocol: class {
    static func configure()
}

protocol AnalyticsServiceProtocol: class {
    static func logEvent(_ name: String, parameters: [String : Any]?)
    static func setUserProperty(_ value: String?, forName name: String)
    static func setUserID(_ userID: String?)
    static func setScreenName(_ screenName: String?, screenClass screenClassOverride: String?)
    static func appInstanceID() -> String
    static func resetAnalyticsData()
}
```

그리고 이 프로토콜을 FirebaseApp과 Analytics이 따르게 합니다.

```
extension FirebaseApp: AnalyticsConfigureServiceProtocol {}
extension Analytics: AnalyticsServiceProtocol {}
```

이제 FirebaseApp과 Analytics를 사용하는 곳에서는 `AnalyticsConfigureServiceProtocol`과 `AnalyticsServiceProtocol`을 가지는 변수를 선언하여 외부에서 주입하면 됩니다.

```
class ViewController: UIViewController {
    var applogServive: AnalyticsServiceProtocol.Type!

    override func viewDidLoad() {
        ...
        applogServive.logEvent("viewdidload", parameters: nil)
        ...
    }
}

let vc = ViewController()
vc.applogServive = Analytics.self
```

이제 `AnalyticsServiceProtocol` 프로토콜을 따르는 클래스를 주입하여 호출할 수 있습니다.

하지만 이런 경우, 메인 프로젝트에서 외부 라이브러리를 알아야 한다는 문제가 있습니다. 따라서 `AnalyticsConfigureServiceProtocol`와 `AnalyticsServiceProtocol`를 가지는 클래스를 만들어 주입받도록 하는 클래스를 사용하도록 합니다.

```
public class AppLog {
    static var analyticsService: AnalyticsServiceProtocol.Type = Analytics.self
    static var configureService: AnalyticsConfigureServiceProtocol.Type = FirebaseApp.self
    
    public static func configure() {
        configureService.configure()
    }
    
    public static func logEvent(_ name: String, parameters: [String : Any]? = nil) {
        analyticsService.logEvent(name, parameters: parameters)
    }
    public static func setUserProperty(_ value: String?, forName name: String) {
        analyticsService.setUserProperty(value, forName: name)
    }
    public static func setUserID(_ userID: String?) {
        analyticsService.setUserID(userID)
    }
    public static func setScreenName(_ screenName: String?, screenClass screenClassOverride: String?) {
        analyticsService.setScreenName(screenName, screenClass: screenClassOverride)
    }
    public static func appInstanceID() -> String {
        return analyticsService.appInstanceID()
    }
    public static func resetAnalyticsData() {
        analyticsService.resetAnalyticsData()
    }
}
```

이제 테스트 타켓에서 `AnalyticsServiceProtocol`를 따르는 클래스와 `AnalyticsConfigureServiceProtocol`를 따르는 클래스 Stub을 만듭니다. 이때, Stub은 넘어온 argument와 혹은 함수 호출됐는지 여부인 속성을 가집니다.

```
class AnalyticsServiceStub: AnalyticsServiceProtocol {
    static var eventName: String?
    static var eventParameter: [String : Any]?
    static var userPropertyValue: String?
    static var userPropertyName: String?
    static var userID: String?
    static var screenName: String?
    static var screenClass: String?
    static var calledResetAnalyticsData: Bool = false
    
    static func logEvent(_ name: String, parameters: [String : Any]?) {
        eventName = name
        eventParameter = parameters
    }
    static func setUserProperty(_ value: String?, forName name: String) {
        userPropertyValue = value
        userPropertyName = name
    }
    static func setUserID(_ userID: String?) {
        self.userID = userID
    }
    static func setScreenName(_ screenName: String?, screenClass screenClassOverride: String?) {
        self.screenName = screenName
        self.screenClass = screenClassOverride
    }
    static func appInstanceID() -> String {
        return ""
    }
    static func resetAnalyticsData() {
        calledResetAnalyticsData = true
    }
}

class AnalyticsConfigureServiceStub: AnalyticsConfigureServiceProtocol {
    static var calledConfigure: Bool = false
    static func configure() {
        calledConfigure = true
    }
}
```

이제 Stub을 이용하여 AppLog 클래스를 테스트할 수 있습니다.

```
class AppLogTest: XCTestCase {
    var applog: AppLog = AppLog.self
    var configureStub = AnalyticsConfigureServiceStub.self
    var analyticsStub = AnalyticsServiceStub.self

    override func setUp() {
        super.setUp()
        configureStub = AnalyticsConfigureServiceStub.self
        analyticsStub = AnalyticsServiceStub.self
        applog.analyticsService = analyticsStub
        applog.configureService = configureStub
    }

    func test_Configure() {
        // given

        // when
        applog.configure()

        // then
        XCTAssertTrue(configureStub.calledConfigure)
    }

    func test_logevent() {
        // given
        let eventName = "LogEvent"
        
        // when
        applog.logEvent(eventName, parameters: nil)

        // then
        XCTAssertEqual(analyticsStub.eventName, eventName)
    }
}
```

## 의존성 분리 테스트하기 - iOS의 클래스

위와 같은 방법으로 iOS에서 지원하는 클래스 및 함수들은 위와 같이 작업이 가능합니다. 대표적으로 URLSession을 들 수 있습니다.

URLSession에서 사용하는 함수는 다음과 같습니다.

```
class URLSession {
    ...
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
    ...
}
```

`dataTask` 함수가 정의된 Protocol을 정의합니다.

```
protocol NetworkServiceProtocol {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: NetworkServiceProtocol {}
```

하지만 우리는 URLSessionDataTask에서 사용하는 함수인 resume과 cancel 함수만 사용한다고 한다면, 이 함수들이 정의된 protocol을 URLSessionDataTask가 따르도록 합니다.

```
protocol NetworkingDataTaskServiceProtocol {
    func cancel()
    func resume()
}

extension URLSessionDataTask: NetworkingDataTaskServiceProtocol {}
```

그러면 `NetworkServiceProtocol`의 dataTask 함수의 반환 타입인 `URLSessionDataTask`는 `NetworkingDataTaskServiceProtocol`로 변경할 수 있습니다.

```
protocol NetworkServiceProtocol {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> NetworkingDataTaskServiceProtocol
}
```

이제 NetworkServiceProtocol를 변수로 가지고, Request 함수를 가지는 API 클래스를 만듭니다.

```
class API {
    let service: NetworkServiceProtocol
    init(service: NetworkServiceProtocol = URLSession.shared) {
        self.service = service
    }
    
    func request(url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let task = service.dataTask(with: url, completionHandler: completionHandler)
        task.resume()
    }
}

API().request(url: url) { _ in print("Completion Handler")}
```

API객체를 만들 때 기본값으로 URLSession 싱글턴 객체를 가지고, 필요하면 NetworkServiceProtocol를 따르는 객체를 주입할 수 있도록 하였습니다.

이후 테스트는 위에서 작성했던 Stub을 만들어 진행하면 됩니다.

## 정리

* 라이브러리를 항상 메인 프로젝트에 넣는 것이 아니라 라이브러리를 가진 프로젝트를 만들고, 그 프로젝트를 메인 프로젝트에 넣는 것이 좋음.
* 의존성 주입을 생각하며 설계해야 하며, 커플링을 방지하는 것을 목표로 해야 함.
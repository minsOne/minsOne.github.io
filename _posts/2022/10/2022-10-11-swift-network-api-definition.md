---
layout: post
title: "[Swift] Network API 명세서"
tags: [Swift, Protocol, Codable, Encodable, Decodable, associatedtype]
---
{% include JB/setup %}

네트워크 관련 코드는 처음에는 쉽게 작성할 수 있지만, API가 늘어날 수록 관리해야할 일이 필요합니다. 그래서 어느정도 체계적인 구조를 갖춰야 합니다.

관련해서 [ishkawa/APIKit](https://github.com/ishkawa/APIKit)에서 API 코드를 추상 레이어를 만들고 구현하도록 합니다.

해당 라이브러리를 영감을 받아 만들면서, 좀 더 유연하게 대응할 수 있도록 하는 코드를 설계하려고 합니다.

네트워크를 추상화한 모듈과, 그 모듈을 통해 구현 타입을 작성하는 모듈 구조로 설계합니다.

<div class="mermaid" style="display:flex;justify-content:center;"> 
graph TD;
    id1[Application]-->id2([NetworkAPIs])-->id3([NetworkAPIKit]);
    style id1 fill:#03bfff
    style id2 fill:#ffba0c
    style id3 fill:#ff7357
</div><br/>

## NetworkAPIKit

네트워크 관련 코드를 추상화하는 모듈입니다.

먼저 NetworkAPIDefinition 프로토콜을 정의합니다.

```swift
/// ModuleName : NetworkAPIKit
/// FileName : NetworkAPIDefinition.swift

public protocol NetworkAPIDefinition {}
```

NetworkAPI 타입을 정의하고, 해당 타입에서 Nested 구조로 관리하도록 합니다.

```swift
/// ModuleName : NetworkAPIKit
/// FileName : NetworkAPI.swift

public enum NetworkAPI {}
```

그리고 사용할 URL을 정의할 구조체를 정의합니다.

```swift
/// ModuleName : NetworkAPIKit
/// FileName : NetworkAPI+URLInfo.swift

import Foundation

public extension NetworkAPI {
    struct URLInfo {
        let scheme: String
        let host: String
        let port: Int?
        let path: String
        let query: [String:String]?
        
        public init(scheme: String = "https",
                    host: String,
                    port: Int? = nil,
                    path: String,
                    query: [String : String]? = nil) {
            self.scheme = scheme
            self.host = host
            self.port = port
            self.path = path
            self.query = query
        }
    }
}

extension NetworkAPI.URLInfo {
    var url: URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.port = port
        components.path = path
        components.queryItems = query?.compactMap { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let url = components.url else {
            assertionFailure("URL 정보를 확인해주세요.")
            return .init(string: "https://\(host)")!
        }
        return url
    }
}
```

그리고 URLRequest에서 사용할 Method를 정의합니다.

```swift
/// ModuleName : NetworkAPIKit
/// FileName : NetworkAPI+Method.swift

public extension NetworkAPI {
    enum Method: String {
        case get = "GET"
        case post = "POST"
    }
}
```

그러면 네트워크를 요청할 추가정보인, Method, Header, Parameter를 추가하여, `NetworkAPIDefinition`를 다시 정의합니다.

```swift
/// ModuleName : NetworkAPIKit
/// FileName : NetworkAPIDefinition.swift

public protocol NetworkAPIDefinition {
    associatedtype Parameter: Encodable
    associatedtype Response: Decodable

    var urlInfo: NetworkAPI.URLInfo { get }
    var method: NetworkAPI.Method { get }
    var headers: [String: String]? { get }
    var parameters: Parameter? { get }
}
```

`Method`, `Headers`, `Parameter`  정보는 URLRequest에서 사용할 정보이므로, URLRequest를 위한 자료구조를 만들어 다루도록 합니다.

```swift
/// ModuleName : NetworkAPIKit
/// FileName : NetworkAPI+RequestInfo.swift

public extension NetworkAPI {
    struct RequestInfo<T: Encodable> {
        var method: Method
        var headers: [String: String]?
        var parameters: T?

        public init(method: NetworkAPI.Method,
                    headers: [String : String]? = nil,
                    parameters: T? = nil) {
            self.method = method
            self.headers = headers
            self.parameters = parameters
        }
    }
}

extension NetworkAPI.RequestInfo {
    func requests(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = parameters.flatMap { try? JSONEncoder().encode($0) }
        headers.map {
            request.allHTTPHeaderFields?.merge($0) { lhs, rhs in lhs }
        }
        return request
    }
}
```

그러면 이제 NetworkAPIDefinition는 다음과 같이 코드가 정리됩니다.

```swift
/// ModuleName : NetworkAPIKit
/// FileName : NetworkAPIDefinition.swift

public protocol NetworkAPIDefinition {
    typealias URLInfo = NetworkAPI.URLInfo
    typealias RequestInfo = NetworkAPI.RequestInfo

    associatedtype Parameter: Encodable
    associatedtype Response: Decodable

    var urlInfo: URLInfo { get }
    var requestInfo: RequestInfo<Parameter> { get }
}
```

그러면 우리는 NetworkAPIDefinition를 통해서 URLSession으로 요청할 수 있는 코드를 만들 수 있습니다.

```swift
/// ModuleName : NetworkAPIKit
/// FileName : NetworkAPIDefinition+Request.swift

public extension NetworkAPIDefinition {
    func request(completion: @escaping ((Result<Response, Error>) -> Void)) {
        let url = urlInfo.url
        let request = requestInfo.requests(url: url)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        let dataTask = session.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            do {
                let response = try JSONDecoder().decode(Response.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
        dataTask.resume()
    }
}
```

명세를 기반으로 네트워크 요청을 추상화 하였습니다.

## NetworkAPIs

이제 NetworkAPIs 모듈에서는 NetworkAPIKit 모듈의 NetworkAPIDefinition를 준수하는 타입을 구현합니다.

```swift
/// ModuleName : NetworkAPIs
/// FileName : GitHubAPI.swift

public enum GitHubAPI {}


/// ModuleName : NetworkAPIs
/// FileName : GitHubAPI+Users.swift

public extension GitHubAPI {
    struct Users: NetworkAPIDefinition {
        public let urlInfo: URLInfo
        public let requestInfo: RequestInfo<EmptyParameter> = .init(method: .get)
        
        public init(userName: String) {
            self.urlInfo = .GitHubAPI(path: "/users/\(userName)") 
        }
        
        public struct Response: Decodable {
            let login: String
            let id: Int
            let node_id: String
            let avatar_url: String
        }
    }
}


/// ModuleName : NetworkAPIKit
/// FileName : EmptyParameter.swift

public struct EmptyParameter: Encodable {}


/// ModuleName : NetworkAPIKit
/// FileName : URLInfo+GitHubAPI.swift

public extension NetworkAPI.URLInfo {
    static func GitHubAPI(path: String) -> Self {
        Self.init(host: "api.github.com", path: path)
    }
}
```

작성한 GitHubAPI를 실제로 호출하여 값을 확인해봅니다.

```swift
/// ModuleName : App
/// FileName : AppDelegate.swift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ...
        GitHubAPI.Users(userName: "minsone").request(completion: { result in
            print(result)
            /// output : success(NetworkAPIs.GitHubAPI.Users.Response(login: "minsOne", id: 4429361, node_id: "MDQ6VXNlcjQ0MjkzNjE=", avatar_url: "https://avatars.githubusercontent.com/u/4429361?v=4"))
        })
    }
}
```

정상적으로 GitHub의 네트워크 API를 요청하고 받았음을 확인할 수 있습니다.

## 정리

`NetworkAPIs` 모듈의 `GitHubAPI+Users.swift` 파일에 작성된 코드는 네트워크 API 명세를 나타내며, 해당 API를 확인할 때, 이 파일만 보면 어떤 정보를 보내고, 받는지 확인을 할 수 있습니다.

## 코드

```swift
/// ModuleName : NetworkAPIKit
/// FileName : NetworkAPI.swift

public enum NetworkAPI {}

/// ModuleName : NetworkAPIKit
/// FileName : NetworkAPI+URLInfo.swift

import Foundation

public extension NetworkAPI {
    struct URLInfo {
        let scheme: String
        let host: String
        let port: Int?
        let path: String
        let query: [String:String]?
        
        public init(scheme: String = "https",
                    host: String,
                    port: Int? = nil,
                    path: String,
                    query: [String : String]? = nil) {
            self.scheme = scheme
            self.host = host
            self.port = port
            self.path = path
            self.query = query
        }
    }
}

extension NetworkAPI.URLInfo {
    var url: URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.port = port
        components.path = path
        components.queryItems = query?.compactMap { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let url = components.url else {
            assertionFailure("URL 정보를 확인해주세요.")
            return .init(string: "https://\(host)")!
        }
        return url
    }
}

/// ModuleName : NetworkAPIKit
/// FileName : URLInfo+GitHubAPI.swift

public extension NetworkAPI.URLInfo {
    static func GitHubAPI(path: String) -> Self {
        Self.init(host: "api.github.com", path: path)
    }
}

/// ModuleName : NetworkAPIKit
/// FileName : NetworkAPI+Method.swift

public extension NetworkAPI {
    enum Method: String {
        case get = "GET"
        case post = "POST"
    }
}

/// ModuleName : NetworkAPIKit
/// FileName : NetworkAPI+RequestInfo.swift

public extension NetworkAPI {
    struct RequestInfo<T: Encodable> {
        var method: Method
        var headers: [String: String]?
        var parameters: T?

        public init(method: NetworkAPI.Method,
                    headers: [String : String]? = nil,
                    parameters: T? = nil) {
            self.method = method
            self.headers = headers
            self.parameters = parameters
        }
    }
}

extension NetworkAPI.RequestInfo {
    func requests(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = parameters.flatMap { try? JSONEncoder().encode($0) }
        headers.map {
            request.allHTTPHeaderFields?.merge($0) { lhs, rhs in lhs }
        }
        return request
    }
}

/// ModuleName : NetworkAPIKit
/// FileName : NetworkAPIDefinition.swift

public protocol NetworkAPIDefinition {
    typealias URLInfo = NetworkAPI.URLInfo
    typealias RequestInfo = NetworkAPI.RequestInfo

    associatedtype Parameter: Encodable
    associatedtype Response: Decodable

    var urlInfo: URLInfo { get }
    var requestInfo: RequestInfo<Parameter> { get }
}

/// ModuleName : NetworkAPIKit
/// FileName : NetworkAPIDefinition+Request.swift

public extension NetworkAPIDefinition {
    func request(completion: @escaping ((Result<Response, Error>) -> Void)) {
        let url = urlInfo.url
        let request = requestInfo.requests(url: url)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        let dataTask = session.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            do {
                let response = try JSONDecoder().decode(Response.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
        dataTask.resume()
    }
}

/// ModuleName : NetworkAPIKit
/// FileName : EmptyParameter.swift

public struct EmptyParameter: Codable {}

/// ModuleName : NetworkAPIKit
/// FileName : EmptyResponse.swift

public struct EmptyResponse: Codable {}
```

```swift
/// ModuleName : NetworkAPIs
/// FileName : GitHubAPI.swift

public enum GitHubAPI {}

/// ModuleName : NetworkAPIs
/// FileName : GitHubAPI+Users.swift

public extension GitHubAPI {
    struct Users: NetworkAPIDefinition {
        public let urlInfo: URLInfo
        public let requestInfo: RequestInfo<EmptyParameter> = .init(method: .get)
        
        public init(userName: String) {
            self.urlInfo = .GitHubAPI(path: "/users/\(userName)") 
        }
        
        public struct Response: Decodable {
            let login: String
            let id: Int
            let node_id: String
            let avatar_url: String
        }
    }
}
```

### [Gist](https://gist.github.com/minsOne/4d60f94224010d701f6d8d9e49c684b4)

## 참고자료

- GitHub
  - [ishkawa/APIKit](https://github.com/ishkawa/APIKit)
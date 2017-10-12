---
layout: post
title: "[Swift4]Codable, 현실의 Codable 그리고 Extension"
description: ""
category: "Programming"
tags: [Swift, Codable, Encodable, Decodable, CodingKeys, try]
---
{% include JB/setup %}

## Codable

Swift4에서 [Codable](https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types)이라는 프로토콜이 추가되면서 JSON 처리를 손쉽게 해줍니다.

```
{
	"a": "aa",
	"b": "bb"
}
```

위와 같이 정의된 데이터인 경우, 다음과 같이 타입을 정의할 수 있습니다.

```
struct Sample1: Codable {
    var a: String
    var b: String
}
```

따라서 JSON 데이터로부터 Sample1 타입인 값을 얻을 수 있습니다.

```
let sample1Data = """
{
	"a": "aa",
	"b": "bb"
}
""".data(using: .utf8)!

let sample1 = try! JSONDecoder().decode(Sample1.self, from: sample1Data)
print(sample1) // Sample1(a: "aa", b: "bb")
```

JSON의 키가 Codable을 따르는 타입에 키와 1:1 매칭된다면 문제없이 사용할 수 있습니다.

하지만 JSON의 키 이름과 타입의 이름을 다르게 하고자 한다면 `CodingKeys`를 정의해줘야합니다.

```
struct Sample1: Codable {
    var a: String
    var y: String
    
    enum CodingKeys: String, CodingKey {
        case a, y = "b"
    }
}
```

JSON 데이터 구조는 중첩 Object도 가능합니다.

```
let sample1Data = """
{
    "a": "aa",
    "b": "bb",
    "list": [{"a": "aa"}]
}
""".data(using: .utf8)!
```

위와 같이 데이터가 내려오는 경우, Codable을 따르는 list의 타입을 정의하면 쉽게 적용할 수 있습니다.

```
struct Sample1: Codable {
    var a: String
    var b: String
    var list: [Sample2]
}

struct Sample2: Codable {
    var a: String
}
```

---

## 현실에서 사용하는 Codable

### 특정 Key, Value가 없는 경우

Object는 키, 값이 존재하거나 존재하지 않을 수 있기 때문에 특정 키가 없이 데이터가 내려올 수 있습니다.

```
* before
{
	"a": "aa",
	"b": "bb"
}

* after
{
	"a": "aa"
}
```


위와 같이 이전에 잘 내려오고 있던 데이터가 갑자기 특정 키이 안내려온다면 Codable을 썼을 때 어떤 문제가 생길까요?

```
fatal error: 'try!' expression unexpectedly raised an error: Swift.DecodingError.keyNotFound(SampleProject.Sample1.CodingKeys.y, Swift.DecodingError.Context(codingPath: [], debugDescription: "No value associated with key y (\"b\").", underlyingError: nil)): file /Library/Caches/com.apple.xbs/Sources/swiftlang/swiftlang-900.0.65/src/swift/stdlib/public/core/ErrorType.swift, line 181
```

`keyNotFound` 에러가 발생합니다. 이는 서비스 운영시 문제가 생길 수 있는 여지가 다분히 존재합니다.

그렇다면 어떻게 하는 것이 좋을까요? JSON을 직접 decode 할 수 있습니다.

```
struct Sample1: Codable {
    var a: String
    var y: String
    
    enum CodingKeys: String, CodingKey {
        case a, y = "b"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        a = try values.decode(String.self, forKey: .a)
        y = try values.decode(String.self, forKey: .y)
    }
}
```

JSON을 decoding 할 때 init(from decoder: Decoder)를 호출하며, 해당 부분에 직접 코드를 작성할 수 있습니다.

앞에서 문제였던 keyNotFound 문제는 기본 값을 넣어주는 방식으로 해결할 수 있습니다.

```
struct Sample1: Codable {
    var a: String
    var y: String
    
    enum CodingKeys: String, CodingKey {
        case a, y = "b"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        a = (try? values.decode(String.self, forKey: .a)) ?? ""
        y = (try? values.decode(String.self, forKey: .y)) ?? ""
    }
}
```

JSON에 특정 키가 없는 경우는 항상 빈 문자열을 넣어주도록 코드를 수정했습니다.

혹은 타입의 모든 변수가 옵셔널 타입으로 처리할 수 있습니다.

```
struct Sample1: Codable {
	var a: String?
	var b: String?
}

or

struct Sample1: Codable {
    var a: String?
    var y: String?
    
    enum CodingKeys: String, CodingKey {
        case a, y = "b"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        a = try values.decodeIfPresent(String.self, forKey: .a)
        y = try values.decodeIfPresent(String.self, forKey: .y)
    }
}
```

### 값이 null인 경우

JSON의 값은 null을 제공합니다. 그렇다면 null인 경우 어떤 문제가 생길까요?

```
let sample1Data = """
{
    "a": null
}
""".data(using: .utf8)!


fatal error: 'try!' expression unexpectedly raised an error: Swift.DecodingError.valueNotFound(Swift.String, Swift.DecodingError.Context(codingPath: [SampleProject.Sample1.CodingKeys.a], debugDescription: "Expected String value but found null instead.", underlyingError: nil)): file /Library/Caches/com.apple.xbs/Sources/swiftlang/swiftlang-900.0.65/src/swift/stdlib/public/core/ErrorType.swift, line 181
```

따라서 JSON의 값이 null인 경우 변수를 옵셔널로 선언해야 합니다.

```
struct Sample1: Codable {
    var a: String?
    var y: String?
    
    enum CodingKeys: String, CodingKey {
        case a, y = "b"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        a = try values.decodeIfPresent(String.self, forKey: .a)
        y = try values.decodeIfPresent(String.self, forKey: .y)
    }
}
```

### JSON이 같은 타입의 값을 가진 배열인 경우

JSON은 같은 타입의 값을 가진 배열이 될 수 있습니다.

```
["a", "b", "c"]
```

decoder의 `singleValueContainer`를 통해 처리하며, 반드시 `init(from decoder: Decoder)`를 구현해야 합니다.

```
struct Sample1: Codable {
    var list: [String]
    
    init(from decoder: Decoder) throws {
        list = try decoder.singleValueContainer().decode([String].self)
    }
}
```

### JSON이 지정되지 않은 타입인 경우

JSON은 여러 타입으로 된 배열을 내려줄 수 있습니다.
```
["a", 1, 10.0, true, "b"]
```

키가 없기 때문에 decoder의 `unkeyedContainer`를 통해 처리하며, 반드시 `init(from decoder: Decoder)`를 구현해야 합니다.

```
struct Sample1: Codable {
    var str: String
    var int: Int
    var float: Float
    var bool: Bool
    
    init(from decoder: Decoder) throws {
        var unkeyedContainer = try decoder.unkeyedContainer()
        str = try unkeyedContainer.decode(String.self)
        int = try unkeyedContainer.decode(Int.self)
        float = try unkeyedContainer.decode(Float.self)
        bool = try unkeyedContainer.decode(Bool.self)
    }
}

// Output: Sample1(str: "a", int: 1, float: 10.0, bool: true)
```

키가 존재하지 않기 때문에 같은 타입인 값이 여러개 있다면 계속 찾으면서 반환합니다.

## Extension

### KeyedDecodingContainer

```
extension KeyedDecodingContainer {
    func decode<T>(_ key: KeyedDecodingContainer.Key) throws -> T where T: Decodable {
        return try decode(T.self, forKey: key)
    }
    func decodeArray<T>(_ key: KeyedDecodingContainer.Key) throws -> [T] where T: Decodable {
        return try decode([T].self, forKey: key)
    }
    
    func decodeIfPresent<T>(_ key: KeyedDecodingContainer.Key) throws -> T? where T: Decodable {
        return try decodeIfPresent(T.self, forKey: key)
    }

    subscript<T>(key: Key) -> T where T: Decodable {
        return try! decode(T.self, forKey: key)
    }
}
```

### UnkeyedDecodingContainer

```
extension UnkeyedDecodingContainer {
    mutating func decode<T>() throws -> T where T: Decodable {
        return try decode(T.self)
    }
    
    mutating func decodeArray<T>() throws -> [T] where T: Decodable {
        var list: [T] = []
        while !isAtEnd {
            list.append(try decode(T.self))
        }
        return list
    }
}
```

### SingleValueDecodingContainer

```
extension SingleValueDecodingContainer {
    mutating func decode<T>() throws -> [T] where T: Decodable {
        return try decode([T].self)
    }
}
```


## 참고 자료

* [Apple JSONEncoder](https://github.com/apple/swift/blob/master/stdlib/public/SDK/Foundation/JSONEncoder.swift)
---
layout: post
title: "[Swift 5.2][BetterCodable] JSON 데이터를 Decode할 때, 키가 없는 경우 PropertyWrapper를 이용하여 빈 값을 채우기"
description: ""
category: "programming"
tags: [JSONDecoder, PropertyWrapper, KeyedDecodingContainer, Codable, Decodable, Encodable]
---
{% include JB/setup %}

Swift4에서 **Codable(Encodable & Decodable)**을 지원하였습니다. 그래서 각종 JSON Decode를 지원하는 오픈소스를 사용할 일이 줄었습니다. 

하지만 데이터를 Decoding 하는 과정에서 데이터의 키와 변수의 이름이 다른, 즉 CodingKey가 다르거나 등등의 경우에는 코드가 지저분해집니다. 때론 SwiftyJSON이나 기존 오픈소스를 사용함이 좋은 경우도 있습니다.

코드가 지저분하거나 이런 경우는 그래도 괜찮습니다. 하지만 데이터에서 매핑해야할 키와 데이터가 없는 경우는 순수 JSONDecoder를 이용하면 Decode가 되지 않고 valueNotFound 에러가 발생합니다.

```
// MARK: 정상 경우
let resp = """
{"a": "b"}
"""
struct A: Codable {
  var a: String
}


// MARK: 실패 경우
let resp = """
{"a": "b"}
"""
struct A: Codable {
  var b: String
}
```

그러면 CodingKey를 설정하여 바꾸어 주거나 해야하지만, 미리 정해진 스펙과 틀어지므로 에러를 던지거나 `A.b`의 타입을 옵셔널로 하거나 또는 `A.b`에 공백이 들어가도록 해야 합니다.

저는 틀어진 경우는 에러, 옵셔널보다는 공백으로 처리하고, 후에 검증 과정에서 처리하는 것이 낫다고 생각합니다.

하지만 이런 처리를 `init(from decoder: Decoder) throws` 내에서 다 작업해줘야 하는데 다음 코드를 보면 지저분합니다.

```
struct A: Codable {
  var b: String
    
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    b = (try? values.decode(String.self, forKey: .b)) ?? ""
  }
}
```

여기에서 우리는 **[BetterCodable](https://github.com/marksands/BetterCodable)**을 이용하여 이런 수고를 덜 할 수 있습니다.

`KeyedDecodingContainer` 에서 decode가 호출될 때, 키가 있으면 키에 해당하는 값을 할당하고, 그렇지 않으면 DefaultCodable의 타입에 해당하는 기본 값을 할당하도록 합니다.

```
/// Provides a default value for missing `Decodable` data.
///
/// `DefaultCodableStrategy` provides a generic strategy type that the `DefaultCodable` property wrapper can use to provide a reasonable default value for missing Decodable data.
public protocol DefaultCodableStrategy {
    associatedtype RawValue: Codable
    
    static var defaultValue: RawValue { get }
}

/// Decodes values with a reasonable default value
///
/// `@Defaultable` attempts to decode a value and falls back to a default type provided by the generic `DefaultCodableStrategy`.
@propertyWrapper
public struct DefaultCodable<Default: DefaultCodableStrategy>: Codable {
    public var wrappedValue: Default.RawValue
    
    public init(wrappedValue: Default.RawValue) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.wrappedValue = (try? container.decode(Default.RawValue.self)) ?? Default.defaultValue
    }
    
    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}

extension DefaultCodable: Equatable where Default.RawValue: Equatable { }
extension DefaultCodable: Hashable where Default.RawValue: Hashable { }

// MARK: - KeyedDecodingContainer
public extension KeyedDecodingContainer {

    /// Default implementation of decoding a DefaultCodable
    ///
    /// Decodes successfully if key is available if not fallsback to the default value provided.
    func decode<P>(_: DefaultCodable<P>.Type, forKey key: Key) throws -> DefaultCodable<P> {
        if let value = try decodeIfPresent(DefaultCodable<P>.self, forKey: key) {
            return value
        } else {
            return DefaultCodable(wrappedValue: P.defaultValue)
        }
    }
}
```

우리는 키가 일치하지 않아 없는 경우 기본값에 해당하는 공백을 넣어야 합니다. `BetterCodable`은 Bool의 기본 값 false를 제공해주는 DefaultFalse라는 타입이 있습니다.

```
public struct DefaultFalseStrategy: DefaultCodableStrategy {
    public static var defaultValue: Bool { return false }
}

/// Decodes Bools defaulting to `false` if applicable
///
/// `@DefaultFalse` decodes Bools and defaults the value to false if the Decoder is unable to decode the value.
public typealias DefaultFalse = DefaultCodable<DefaultFalseStrategy>
```

`DefaultFalse`를 살짝 틀어 `DefaultEmptyString` 을 만들어봅시다.

```
public struct DefaultEmptyStringStrategy: DefaultCodableStrategy {
    public static var defaultValue: String { return "" }
}

/// Decodes Bools defaulting to `Empty String` if applicable
///
/// `@DefaultEmptyString` decodes Strings and defaults the value to false if the Decoder is unable to decode the value.
public typealias DefaultEmptyString = DefaultCodable<DefaultEmptyStringStrategy>
```

`DefaultEmptyString`를 이용하여 A 타입에 적용해봅시다.

```
struct A: Codable {
  @DefaultEmptyString var b: String
}
```

위에서 `init(from decoder: Decoder) throws`를 구현했지만 이제는 PropertyWrapper로 만든 `DefaultEmptyString` 를 이용하면 구현하지 않아도 됩니다.

```
let resp = """
{"a": "b"}
""".data(using: .utf8)!

if let data = try? JSONDecoder().decode(A.self, from: resp) {
  print(data.b)
}
```
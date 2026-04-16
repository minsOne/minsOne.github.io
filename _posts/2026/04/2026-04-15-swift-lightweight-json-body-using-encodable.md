---
layout: post
title: "[Swift][Network] 경량화된 Encodable 기반 파라미터 타입"
tags: [Swift, Networking, Encodable, API]
---
{% include JB/setup %}

## 배경

Swift에서 네트워크 요청의 body를 만들 때는 보통 `Encodable`을 채택한 타입을 정의해서 전달합니다.

```swift
struct UserInfoParameter: Encodable {
    let name: String
    let age: Int
    let isActive: Bool
}
```

이 방식은 구조화된 접근입니다. 요청 스펙이 타입으로 드러나고, 컴파일 타임에 실수를 줄일 수 있고, 요청이 커질수록 읽기 쉽기 때문입니다.

그런데 모든 요청이 구조화된 타입을 필요로 하지는 않습니다.

body에 들어가는 값이 정말 몇 개 안 되는 경우가 있습니다. 예를 들어 `page`, `size`, `lastTxId` 정도만 보내면 되는 작은 요청인데, 이런 요청마다 별도의 DTO를 만드는 것이 무겁게 느껴질 때가 있습니다.

물론 DTO 하나 만드는 비용이 아주 큰 것은 아닙니다. 하지만 요청이 단순하고 일회성에 가까울수록, 타입을 따로 선언하는 것이 맞는가 하는 생각이 들 때가 있습니다. 특히 요청 타입을 네트워크 모듈에 두는 구조라면, 작은 요청 하나 때문에 네트워크와 직접적인 의존성이 없는 모듈에서 해당 타입을 사용하여, 네트워크 모듈을 의존하게 되는 점도 부담스럽습니다. 다만 중간 DTO를 만들면 되지만 이 또한 비용으로 발생합니다.

이런 상황에서 가장 먼저 떠오르는 건 `Dictionary<String, Any>` 같은 형태입니다.

```swift
let body: [String: Any] = [
    "name": "minsone",
    "age": 100,
    "isActive": true
]
```

간단하긴 하지만, 이 방식은 아쉬움이 있습니다.

첫째, 타입이 너무 느슨합니다. `Any`를 받기 시작하면 body에 어떤 값이 들어갈 수 있는지 코드만 보고는 알기 어렵습니다.

둘째, JSON 인코딩 경계가 불분명해집니다. 일단 넣고 나중에 어떻게든 인코딩하는 형태가 되기 쉽습니다.

셋째, 이 타입이 정말 JSON body를 위한 것인지, 아니면 임시 데이터를 담기 위한 것인지 확실하지 않습니다. 이는 Dictonary 타입이라는 것 때문에 의도를 명확하게 드러내지 못합니다.

그래서 `Encodable`의 장점은 유지하면서도, 필드가 적은 요청에서는 DTO를 만들지 않고도 body를 구성할 수 있는 타입이 있으면 좋겠습니다.

* key는 문자열로 받는다.
* value는 `Encodable`을 따르는 타입만 받는다.
* 목적은 오직 JSON body 생성이다.

## 사용 방식

원하는 사용 방식은 다음과 같습니다.

```swift
let body = JSONBody()
    .with("key1", value: "value1")
    .with("key2", value: 3)
    .with("key3", value: true)
    .with("key4", value: [1, 2, 3, 4, 5])
```

이 방식의 목표는 단순한 JSON body를 만들 수 있도록 합니다.

핵심은 두 가지입니다.

* 필드가 적은 요청에서는 DTO를 만들지 않고도 body를 구성할 수 있습니다.
* 값은 `Encodable`만 받을 수 있도록 해서 최소한의 타입 제약은 유지합니다.

## 구현

```swift
struct JSONBody: Encodable {
    private var storage: [String: any Encodable] = [:]

    func with<T: Encodable>(_ key: String, value: T) -> Self {
        var copy = self
        copy.storage[key] = value
        return copy
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKey.self)

        for (key, value) in storage {
            let codingKey = DynamicCodingKey(stringValue: key)
            guard let codingKey else { continue }
            try value.encode(to: container.superEncoder(forKey: codingKey))
        }
    }
}

private struct DynamicCodingKey: CodingKey {
    let stringValue: String
    let intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
}
```

이 구현에서 중요한 점은 `JSONBody`가 `Encodable` 프로토콜을 따릅니다. 따라서 네트워크에서는 기존의 `Encodable` 요청 모델과 같은 방식으로 다룰 수 있습니다.

```swift
func request<T: Encodable>(body: T) throws -> Data {
    try JSONEncoder().encode(body)
}

let body = JSONBody()
    .with("name", value: "minsone")
    .with("age", value: 100)
    .with("isActive", value: true)
let data = try request(body: body)
```

즉, 네트워크 레이어를 새로 설계할 필요 없이 body를 만드는 쪽에만 선택지를 추가하는 방식입니다.

## 구현 범위

이 타입을 만들다 보면 기능을 더 넣을 수 있습니다. 예를 들어 다른 `Encodable` 타입 값 받기,, `nil` 처리, 중첩 body 조합 같은 기능들입니다.

그런데 기능이 늘어나기 시작하면, 이 타입의 역할이 금방 커집니다. 그러면 "body를 가볍게 만들기 위한 타입"이라는 처음 의도가 흐려질 수 있습니다.

그래서 역할을 최소한으로 기능을 제한하였습니다.

* 단일 key/value를 추가하는 `with`
* `Encodable` body로 인코딩 가능할 것
* JSON body 용도로만 사용할 것

## DTO와의 관계

이 방식은 DTO를 대체하려는 것이 아닙니다. 오히려 DTO가 더 적합한 경우가 여전히 많습니다.

예를 들어 아래와 같은 요청은 구조화된 DTO로 두는 편이 더 낫습니다.

```swift
struct SignupParameter: Encodable {
    let email: String
    let password: String
    let nickname: String
    let marketingConsent: Bool
}
```

필드가 많고, 요청의 의미가 분명하고, 다른 곳에서도 재사용될 가능성이 있다면 DTO가 더 읽기 쉽고 안전합니다.

반면 필드가 적고 단순한 body는 `JSONBody` 같은 작은 타입으로 다루는 것도 충분히 괜찮다고 생각합니다.

* 구조가 분명하고 중요한 요청은 `Encodable` DTO를 사용합니다.
* 필드가 적고 단순한 body는 `JSONBody` 같은 작은 타입으로 다룹니다.

즉, 요청의 복잡도에 따라 선택지를 다르게 가져가자는 쪽에 가깝습니다.

## 정리

Swift에서 네트워크 요청 body를 만들 때 `Encodable` DTO를 사용하는 방식은 여전히 좋은 기본값입니다.

하지만 모든 요청에 매번 타입을 만들 필요는 없다고 생각합니다. 필드가 적고 단순한 body라면, key는 문자열로 받고 value는 `Encodable`만 허용하는 작은 body 타입을 두는 것도 충분히 실용적인 선택지가 될 수 있습니다.


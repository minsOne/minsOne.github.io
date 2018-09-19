---
layout: post
title: "[Swift4.1] JSONDecoder의 KeyDecodingStrategy"
description: ""
category: "Programming"
tags: [Swift, JSONDecoder, KeyDecodingStrategy]
---
{% include JB/setup %}

Swift 4.1에서 JSONDecoder에 keyDecodingStrategy 이 추가되었습니다. 이 속성은 JSONDecoder가 어떤 키 전략을 따를지에 따라 Data로부터 Decoding을 가능하도록 해줍니다.

`KeyDecodingStrategy`은 세가지 case가 있는데, `useDefaultKeys`, `convertFromSnakeCase` 그리고 `custom(@escaping ([CodingKey]) -> CodingKey)`이 있습니다.

`useDefaultKeys`는 key값을 그대로 사용하며, `convertFromSnakeCase`는 CodingKey가 Snake Case를 써야 할 것을 자동으로 Camel Case로 대응해주도록 합니다.

`custom`는 JSONDecoder에 임의의 키 전략을 만들 수 있습니다. `convertFromSnakeCase`도 마찬가지로 내부에서 키 전략을 만든 것으로, [키 파싱 로직](https://github.com/apple/swift/blob/5dace224a0a3c676124546162b6e206ea8e43cec/stdlib/public/SDK/Foundation/JSONEncoder.swift#L1076)과 [JSONDecoder 내부](https://github.com/apple/swift/blob/5dace224a0a3c676124546162b6e206ea8e43cec/stdlib/public/SDK/Foundation/JSONEncoder.swift#L1305)를 살펴볼 수 있습니다.

다음과 같이 키 값에 `-`이 들어가 있는 경우, `custom`을 사용해야 합니다.

```
let json = """
{
"first-name": "Taylor",
"last-name": "swift"
}
"""

struct Person: Codable {
	var firstname: String
	var lastname: String
}
```

위의 json을 디코딩하여 Person 구조체에 넣도록 하기 위해, JSONDecoder의 keyDecodingStrategy를 `custom`으로 설정해줘야 합니다.

```
struct AnyKey: CodingKey {
	var stringValue: String
	var intValue: Int?

	init?(stringValue: String) {
		self.stringValue = stringValue
		self.intValue = nil
	}

	init?(intValue: Int) {
		self.stringValue = String(intValue)
		self.intValue = intValue
	}
}

let jsonDecoder = JSONDecoder()
jsonDecoder.keyDecodingStrategy = .custom { keys -> CodingKey in
	let key = keys.last!.stringValue.split(separator: "-").joined()
	return AnyKey(stringValue: String(key))!
}

do {
	let person = try jsonDecoder.decode(Person.self, from: Data(json.utf8))
	print(person)
} catch {
	print(error.localizedDescription)
}

```

위와 같이 작성하여 json 문자열로부터 Person을 만들 수 있습니다.

## 참고자료

* [Swift/JSONEncoder](https://github.com/apple/swift/blob/5dace224a0a3c676124546162b6e206ea8e43cec/stdlib/public/SDK/Foundation/JSONEncoder.swift)
---
layout: post
title: "[Swift]런타임시 Mirror를 사용하여 JSON 데이터 만들기"
description: ""
category: "Mac/iOS"
tags: [swift, mirror, swift2, json, runtime, ErrorType, extension, protocol, reflecting]
---
{% include JB/setup %}

<div class="alert warning"><strong>주의</strong> : 본 글은 Swift 2.0으로 작성되었기 때문에 Swift 1.x 코드와 호환되지 않습니다.</div>

### Mirror를 사용하여 JSON 데이터 만들기

Swift에서 Reflection을 이용하여 타입의 서브셋 메타데이터를 제한적으로 읽을 수 있습니다. 이를 사용하여 커스텀 구조체의 데이터를 JSON 형태의 데이터로 만들도록 확장해봅시다.

<div class="alert-info">MirrorType에 대해 좀 더 자세히 알고싶으시면, <a href="http://nshipster.com/mirrortype/">NSHipster</a>에서 확인하시기 바랍니다.</div>

우리가 사용할 구조체는 다음과 같습니다.

	struct PostCode {
		var code: Int
	}

	struct Address {
		var street: String
		var post: PostCode
	}

	struct Man {
		var name: String = "John"
		var age: Int = 50
		var dutch: Bool = false
		var address: Address? = Address(street: "Market St.", post: PostCode(code: 111))
	}

	let john = Man()

사용할 구조체를 선언하였으므로, Mirror를 확장하여 john의 속성을 읽을 수 있도록 합시다.

	extension Mirror {
		var properties: [(String, Child)] {
			return self.children.reduce([(String, Child)]()) {
				guard let propertyName = $1.label else { return $0 }
				return $0 + [(propertyName, $1)]
			}
		}
	}

Mirror는 children이라는 속성을 가지는데, children은 AnyForwardCollection<Child>로 각 속성의 이름, 값을 Child 라는 타입으로 가지고 있습니다. 깊은 탐색을 하기 위해서 속성의 이름과 속성을 Array Tuple로 만듭니다.

다음으로 JSON 프로토콜과 직렬화 에러 코드 Enum을 선언합니다.

	protocol JSON {
	    func toJSON() throws -> AnyObject?
	}

	enum CouldNotSerializeError {
	    case NoImplementation(source: Any, type: Mirror)
	}

CouldNotSerializeError는 ErrorType을 가지도록 합니다.

	extension CouldNotSerializeError: ErrorType { }

이제 JSON의 toJSON을 구현합니다.

	extension JSON {
	    func toJSON() throws -> AnyObject? {
	        let mirror = Mirror(reflecting: self)
	        if !mirror.properties.isEmpty {
	            var result = [String:AnyObject]()
	            for (key, child) in mirror.properties {
	                guard let value = child.value as? JSON else {
	                    throw CouldNotSerializeError.NoImplementation(source: self, type: mirror)
	                }
	                result[key] = try value.toJSON()
	            }
	            return result
	        }
	        return self as? AnyObject
	    }
	}

Mirror을 통해 객체에 속성이 몇개인지를 읽고, 값이 JSON 프로토콜을 가진다면 딕셔너리에 저장하고, 그렇지 않으면 직렬화 에러를 던집니다.

이제 Man, Address, PostCode를 JSON으로 확장하고, String, Int, Bool도 확장합니다.

	extension Man: JSON { }
	extension String: JSON { }
	extension Int: JSON { }
	extension Bool: JSON { }
	extension Address: JSON { }
	extension PostCode: JSON { }

그리고 옵셔널도 확장합니다.

	extension Optional: JSON {
	    func toJSON() throws -> AnyObject? {
	        guard let x = self else { return nil }
	        if let value = x as? JSON {
	            return try value.toJSON()
	        }
	        throw CouldNotSerializeError.NoImplementation(source: x, type: Mirror(reflecting: x))
	    }
	}

이제 john 객체를 json 형태로 런타임시 출력할 수 있습니다.

	do {
	    if let johnDescrip = try john.toJSON() {
	        print(johnDescrip)
	    }
	} catch {
	    print(error)
	}

	// Output
	{
	    address =     {
	        post =         {
	            code = 111;
	        };
	        street = "Market St.";
	    };
	    age = 50;
	    dutch = 0;
	    name = John;
	}

만약에 확장하지 않은 타입인 Double을 가지는 속성을 가진다면, toJSON 호출시 다음과 같은 에러를 던집니다.

	NoImplementation(Man(name: "John", age: 50, dutch: false, address: Optional(Address(street: "Market St.", post: PostCode(code: 111))), d: 0.0), Mirror for Man)

전체 코드는 [여기](https://gist.github.com/minsOne/765aaffe565e688dd790)에서 확인하실 수 있습니다.

<div class="alert-info">위의 코드는 <a href="https://gist.github.com/chriseidhof/48243eb549481bc38d58">Gist</a>를 참고하였습니다.</div>

### 결론

런타임시 특정 객체들에 대해 데이터를 직렬화해서 볼 수 있습니다. 또한, Mirror을 이용하여 좀 더 다양한 기능을 만들 수 있을 것으로 보입니다.

### 참고 자료

* [Reflection Gist](https://gist.github.com/chriseidhof/48243eb549481bc38d58)
* [NSHipster](http://nshipster.com/mirrortype)
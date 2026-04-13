---
layout: post
title: "[Swift] private protocol로 파일 내부 공통 구현 숨기기"
tags: [Swift, Protocol, Access Control, Refactoring]
---
{% include JB/setup %}

코드를 정리하다 보면, 같은 프로토콜을 채택한 타입이 여러 개 있는데 실제 구현을 열어보면 거의 똑같은 경우가 있습니다. 차이라고는 `type` 같은 값 하나뿐이고, 메서드 구현은 전부 복붙인 상태입니다.

예를 들어 Processor Plugin 코드가 아래처럼 생겼다고 해봅시다.

```swift
// File: InvestPlugin.swift

enum InvestPlugin {
    static let list: [ProcessorPlugin] = [
        Home(),
        BondList(),
        ProductDetail()
    ]
}

extension InvestPlugin {
    struct Home: ProcessorPlugin {
        var type: PluginType { .채권_홈 }

        func run(info: PluginInfo) -> Result<Void, PluginRunError> {
            guard let runner = Runner(plugin: type, info: info) else {
                return .failure(.invalidURL(info.definition))
            }
            runner.run()
            return .success(())
        }
    }
}

extension InvestPlugin {
    struct BondList: ProcessorPlugin {
        var type: PluginType { .채권_목록 }

        func run(info: PluginInfo) -> Result<Void, PluginRunError> {
            guard let runner = Runner(plugin: type, info: info) else {
                return .failure(.invalidURL(info.definition))
            }
            runner.run()
            return .success(())
        }
    }
}

extension InvestPlugin {
    struct ProductDetail: ProcessorPlugin {
        var type: PluginType { .채권_상세 }

        func run(info: PluginInfo) -> Result<Void, PluginRunError> {
            guard let runner = Runner(plugin: type, info: info) else {
                return .failure(.invalidURL(info.definition))
            }
            runner.run()
            return .success(())
        }
    }
}
```

이런 코드는 처음에는 그냥 넘어가기 쉽습니다. 어차피 짧으니까요. 그런데 타입이 하나 둘 늘어나기 시작하면 얘기가 달라집니다. 새 타입을 추가할 때마다 `run(info:)`를 또 복사해야 하고, 나중에 에러 처리나 실행 흐름을 바꾸려면 같은 코드를 여러 군데에서 같이 수정해야 합니다.

이럴 때 파일 안에서만 쓰는 `private protocol` 하나를 두고, extension으로 공통 구현을 빼두면 깔끔하게 정리됩니다.

## 왜 `private protocol`인가

프로토콜도 `private` 접근 제어를 가질 수 있습니다.

```swift
private protocol MyProtocol {}
```

이렇게 선언하면 이 프로토콜은 해당 파일 안에서만 쓸 수 있습니다. 다른 파일에서는 참조도 못 하고 채택도 못 합니다.

여기서 중요한 건 이 프로토콜이 "공개 API"가 아니라 "파일 내부 구현"이라는 점을 코드로 드러낼 수 있습니다. 

중요한 건 세부 접근 제어 비교가 아니라, "이 프로토콜은 파일 밖으로 나갈 이유가 없다"는 판단입니다. 재사용하려고 만든 프로토콜이 아니라, 그냥 이 파일 안에서 중복을 줄이기 위한 보조 도구라면 `private`으로 두는 쪽이 자연스럽습니다.

### `extension ProcessorPlugin`의 기본 구현

처음에는 아래처럼 공개 프로토콜 extension에 기본 구현을 넣는 방법이 더 단순해 보일 수 있습니다.

```swift
extension ProcessorPlugin {
    func run(info: PluginInfo) -> Result<Void, PluginRunError> {
        guard let runner = Runner(plugin: type, info: info) else {
            return .failure(.invalidURL(info.definition))
        }
        runner.run()
        return .success(())
    }
}
```

`ProcessorPlugin` 프로토콜이 특정 도메인에 특화된 타입이면 괜찮을 수도 있습니다. 하지만 `ProcessorPlugin`이 여러 도메인에서 쓰이는 프로토콜이므로 모든 구현이 해당 구현을 따라야하므로 적절하지 않습니다. 

그래서 공개 프로토콜은 그대로 두고, 파일 안에서만 쓰는 별도 프로토콜에만 기본 구현을 넣는 방식을 통해 영향 범위를 좁히는 게 좋습니다.

## 어떻게 정리할 수 있나

공개 프로토콜은 그대로 두고, 파일 안에서만 쓰는 보조 프로토콜에 공통 구현을 넣으면 됩니다. 예를 들면 아래처럼 정리할 수 있습니다.

```swift
// File: InvestPlugin.swift

private protocol InvestProcessPlugin: ProcessorPlugin {}

extension InvestProcessPlugin {
    func run(info: PluginInfo) -> Result<Void, PluginRunError> {
        guard let runner = Runner(plugin: type, info: info) else {
            return .failure(.invalidURL(info.definition))
        }
        runner.run()
        return .success(())
    }
}

enum InvestPlugin {
    static let list: [ProcessorPlugin] = [
        Home(),
        BondList(),
        ProductDetail()
    ]
}

extension InvestPlugin {
    struct Home: InvestProcessPlugin {
        var type: PluginType { .채권_홈 }
    }

    struct BondList: InvestProcessPlugin {
        var type: PluginType { .채권_목록 }
    }

    struct ProductDetail: InvestProcessPlugin {
        var type: PluginType { .채권_상세 }
    }
}
```

이렇게 바꾸면 `run(info:)` 구현은 한 군데만 남습니다. `Home`, `BondList`, `ProductDetail`은 각자 `type`만 정의하면 됩니다.

이 방식의 좋은 점은 범위를 파일 하나로 묶을 수 있다는 점입니다. 공개 프로토콜 전체에 기본 구현을 얹는 대신, 필요한 타입 묶음에만 공통 동작을 줄 수 있습니다. 외부에서는 여전히 `ProcessorPlugin`만 보면 되고, 내부 중복 제거를 위해 만든 `InvestProcessPlugin` 프로토콜은 밖으로 드러나지 않습니다.

또 `InvestProcessPlugin` 프로토콜은 파일 밖에서 참조할 수 없기 때문에, 나중에 이름을 바꾸거나 기본 구현을 손봐도 영향 범위를 작게 유지할 수 있습니다. 이름 충돌 걱정할 필요가 없습니다.


## Before / After

한 파일에 3개의 타입만 있어도 차이는 바로 보입니다.

| 항목 | Before | After |
|------|--------|-------|
| `run(info:)` 구현 수 | 3개 | 1개 |
| 중복 로직 수정 지점 | 3곳 | 1곳 |
| 새 Plugin 추가 시 | `run()` 복사 필요 | `type`만 선언 |

핵심은 코드 줄 수보다 수정 지점이 하나로 모인다는 점입니다. 공통 로직을 바꿀 때 한 군데만 보면 되고, 새 타입을 추가할 때도 `type`만 구현하면 됩니다.

## 다른 방법과 비교해보면

이 문제를 푸는 방법은 클래스 상속, Closure를 통한 방법 등이 있습니다. 하지만 각각의 단점이 있어서 결국 `private protocol`이 가장 부담이 적은 선택이 되었습니다.

### Base Class

```swift
class PluginBase: ProcessorPlugin {
    var type: PluginType { fatalError("override required") }

    func run(info: PluginInfo) -> Result<Void, PluginRunError> {
        guard let runner = Runner(plugin: type, info: info) else {
            return .failure(.invalidURL(info.definition))
        }
        runner.run()
        return .success(())
    }
}
```

클래스 베이스로 빼는 방식은 익숙하긴 합니다. 하지만 `struct`를 `class`로 바꿔야 하고, 상속 제약도 따라옵니다. `type`을 override 안 하면 `fatalError`가 터지는 구조가 깔끔하진 않습니다.

### Closure 기반 래퍼

```swift
struct GenericPlugin: ProcessorPlugin {
    let type: PluginType
    let action: (PluginInfo) -> Result<Void, PluginRunError>

    func run(info: PluginInfo) -> Result<Void, PluginRunError> {
        action(info)
    }
}
```

별도 래퍼 타입이 필요하고, 실제 도메인 타입 이름을 알기 어렵습니다. 디버깅시에 코드를 따라가기가 어려워지는 단점이 있습니다.

## 사용할 때 주의할 점

### 공개 인터페이스를 기준으로 테스트 진행

`private protocol` 자체는 테스트에서 직접 접근할 수 없습니다. 하지만 해당 타입이 공개 프로토콜을 통해 기대한 동작을 하는지만 테스트하면 됩니다.

```swift
func testOpenPlugin_run_returnsSuccess() {
    let plugin: ProcessorPlugin = InvestPlugin.Home()
    let result = plugin.run(info: mockInfo)
    XCTAssertEqual(result, .success(()))
}
```

### 특정 타입만 예외 처리가 필요한 경우

기본 구현이 생기면 모든 타입이 같은 방식으로 동작한다는 전제가 깔립니다. 만약 특정 타입만 예외 처리가 필요하다면 해당 타입에서 직접 `run(info:)`를 구현하면 됩니다.

```swift
struct SpecialCase: InvestProcessPlugin {
    var type: PluginType { .채권_특수케이스 }

    func run(info: PluginInfo) -> Result<Void, PluginRunError> {
        // 이 타입만 필요한 별도 로직
    }
}
```

다만 예외가 계속 늘어나면 다시 구조 설계를 진행해야 합니다.

## 언제 쓰면 좋은가

아래 조건이면 유용하게 사용할 수 있습니다.

1. 같은 파일 안에 비슷한 타입이 두 개 이상 있다.
2. 공개 프로토콜 메서드 구현이 사실상 동일하다.
3. 외부 API는 바꾸지 않고 내부 중복만 제거하고 싶다.

반대로 타입이 하나뿐이거나, 각 타입 구현이 실제로 많이 다르면 굳이 만들 필요는 없습니다. 여러 파일에서 같이 써야 한다면 `private`보다는 `internal` 공통 타입이나 별도 모듈로 빼는 쪽이 맞습니다.

## 정리

`private protocol`은 거창한 설계 패턴이라기보다, 파일 안에서만 쓰는 공통 구현을 정리하는 실용적인 방법입니다.

공개 인터페이스는 그대로 두고, 파일 내부에서만 필요한 공통 구현만 따로 묶고 싶을 때 해당 방법을 이용한다면, 영향 범위도 좁고, 새 타입을 추가할 때도 편리하게 관리할 수 있습니다.

같은 코드를 여러 타입에서 반복하고 있고, 그 구현이 파일 밖으로 드러날 이유도 없다면 이 방법을 사용하여 처리하는 것을 고려해보세요. 코드가 더 깔끔해지고, 유지보수도 쉬워질 겁니다.

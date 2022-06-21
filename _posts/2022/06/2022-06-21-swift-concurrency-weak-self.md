---
layout: post
title: "[Swift 5.7+][Concurrency] Task 사용시 weak self를 사용하자"
tags: [Swift, Concurrency, Task, weak, self, ARC, Closures, Capture list, reference count]
---
{% include JB/setup %}

Swift의 Task 사용시 Closure를 이용하여 비동기 작업을 구현합니다.

```swift
class Alpha {
    init() {
        print("\(Date()) init")
        Task {
            print("\(Date()) Before Hello Alpha")
            try await Task.sleep(nanoseconds: 10 * 1_000_000_000)
            print("\(Date()) After Hello Alpha")
        }
    }
    
    deinit {
        print("\(Date()) deinit")
    }
}

func run() {
    _ = Alpha()
}

/** Output
2022-06-21 13:30:33 +0000 init
2022-06-21 13:30:33 +0000 deinit
2022-06-21 13:30:33 +0000 Before Hello Alpha v1
2022-06-21 13:30:44 +0000 After Hello Alpha v1
*/
```

Task 내에서 self를 사용하지 않고도 내부의 변수나 함수 등 접근이 가능합니다. 

```swift
class Alpha {
    let version = "v1"

    init() {
        print("\(Date()) init")
        Task {
            print("\(Date()) Before Hello Alpha \(version)")
            try await Task.sleep(nanoseconds: 10 * 1_000_000_000)
            print("\(Date()) After Hello Alpha \(version)")
        }
    }
    
    deinit {
        print("\(Date()) deinit")
    }
}

/** Output
2022-06-21 13:30:33 +0000 init
2022-06-21 13:30:33 +0000 Before Hello Alpha v1
2022-06-21 13:30:44 +0000 After Hello Alpha v1
2022-06-21 13:30:44 +0000 deinit
*/
```

위와 같이 version이라는 변수를 쉽게 접근하여 사용할 수 있습니다. 하지만, 객체의 deinit은 After Hello Alpha 문자열이 출력된 뒤에 deinit 문자열이 출력되었습니다.

즉, Capture List를 통해 self의 레퍼런스 카운트가 증가되었음을 확인할 수 있습니다. 따라서 version을 사용하려면 기존 클로저에서 작업하던 방식인 weak self를 이용하여 레퍼런스 카운트를 증가시키지 못하도록 해야합니다.

```swift
class Alpha {
    let version = "v1"

    init() {
        print("\(Date()) init")
        Task { [weak self] in
            guard let version = self?.version else { return }
            print("\(Date()) Before Hello Alpha \(version)")
            try await Task.sleep(nanoseconds: 10 * 1_000_000_000)
            print("\(Date()) After Hello Alpha \(version)")
        }
    }
    
    deinit {
        print("\(Date()) deinit")
    }
}
/** Output
2022-06-21 13:37:28 +0000 init
2022-06-21 13:37:28 +0000 deinit
*/
```

guard 문으로 처리했더니, self가 nil이라 before Hello Alpha가 출력되지 않고 종료되었습니다.

따라서 Task 사용시 짧게 비동기 작업이 끝난다면 Task에 weak self를 사용하지 않아도 되지만(의도적 메모리 릭), 오래 걸리는 작업이라면, 반드시 weak self를 사용해서 Task를 더이상 진행하지 않도록 처리하는 것이 좋을 것 같습니다.
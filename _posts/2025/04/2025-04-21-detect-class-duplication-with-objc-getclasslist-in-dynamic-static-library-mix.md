---
layout: post
title: "[iOS][Objective-C] 동적·정적 라이브러리 혼용 시 발생하는 클래스 중복을 테스트로 검출하기 - objc_getClassList"
tags: [iOS, Swift, XCTest, objc, objc_getClassList]
---
{% include JB/setup %}

라이브러리는 정적 라이브러리와 동적 라이브러리로 나뉘며, 정적 라이브러리는 컴파일 시에 링크되고, 동적 라이브러리는 런타임 시에 링크됩니다.

여러 동적 라이브러리가 정적 라이브러리를 참조할 때, 정적 라이브러리의 코드는 각 동적 라이브러리에 포함되며, 이는 정적 라이브러리의 코드가 중복 포함되는 것을 의미합니다. 

하지만 이 중복 포함은 컴파일 시에 문제가 일어나지 않습니다. 그러나 애플리케이션이 실행 될 때, 여러 동적 라이브러리에 있는 정적 라이브러리 코드가 로드 될 때, 중복으로 로드가 되면서 특정 코드의 실행이 예기치 못한 동작이나 크래시를 초래할 수 있습니다.

이는 애플리케이션을 실행하고, 중복된 코드를 호출하면서 발생하는 문제로, 검증하기 쉽지 않습니다. 그래서 콘솔 로그를 통해 확인하는 방법 외에는 다른 방법이 없습니다.

<br/>
<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2025/04/01.png"/>
</p><br/>

위 경고는 정적 라이브러리의 코드가 중복으로 로드되었음을 나타내며, 이를 해결하기 위해서는 정적 라이브러리를 동적 라이브러리로 변경하거나, 정적 라이브러리의 코드를 중복으로 포함하지 않도록 해야 합니다. 

하지만 이는 후속 조치일 뿐, 정적 라이브러리의 코드가 중복으로 포함되었는지 확인하는 방법은 아닙니다. 필요시 이를 선제적으로 확인할 수 있는 방법이 필요합니다.

## **objc_getClassList**를 활용하여 클래스 중복을 검출하기

Objective-C의 Run `objc_getClassList` 함수를 사용하여 모든 클래스 목록을 얻고, 이를 Swift의 XCTest를 사용하여 테스트하는 방법을 소개합니다. 이 방법은 동적 라이브러리와 정적 라이브러리를 혼용하여 사용할 때, 클래스 중복을 검출하는데 유용합니다.

다음은 `objc_getClassList` 함수를 이용하여 등록된 클래스 목록을 추출하는 코드입니다.

```swift
// FileName : ClassScanner.swift

import Foundation
import ObjectiveC.runtime

struct ClassScanner {
  private var classPtrInfo: (classesPtr: UnsafeMutablePointer<AnyClass>,
                             numberOfClasses: Int)?
  {
    let numberOfClasses = Int(objc_getClassList(nil, 0))
    guard numberOfClasses > 0 else { return nil }

    let classesPtr = UnsafeMutablePointer<AnyClass>.allocate(capacity: numberOfClasses)
    let autoreleasingClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(classesPtr)
    let count = objc_getClassList(autoreleasingClasses, Int32(numberOfClasses))
    assert(numberOfClasses == count)

    return (classesPtr, numberOfClasses)
  }

  func searchClassList() -> [String: UInt] {
    guard
      let (classesPtr, numberOfClasses) = classPtrInfo
    else { return [:] }

    defer { classesPtr.deallocate() }

    var list = [String: UInt]()

    for i in 0 ..< numberOfClasses {
      let cls: AnyClass = classesPtr[i]
      let clsName = NSStringFromClass(cls)
      if let count = list[clsName] {
        list[clsName] = count + 1
      } else {
        list[clsName] = 1
      }
    }

    return list
  }
}
```

위 코드에서 동일한 클래스 이름이 나오는 경우, Count를 증가시켜, 중복된 클래스가 존재하는지 검출할 수 있습니다.

## 예제를 통해 클래스 중복을 검출 확인하기

<!--
의존성 그래프 예제 이미지
Application -> FeatureA
Application -> FeatureB
FeatureA -> FeatureC
FeatureB -> FeatureC
-->

위의 의존성 그래프에서 FeatureA, B는 동적 라이브러리, FeatureC는 정적 라이브러리로, FeatureA, B에서 FeatureC를 합니다. FeatureA, B에는 FeatureC 라이브러리 코드가 복사될 것입니다.

FeatureA, B는 FeatureC의 코드를 호출하도록 코드를 작성합니다.

```swift
/// Module : FeatureA
/// FileName : Alpha.swift
import FeatureC

public class Alpha {
  public init() {
    print(#fileID, Self.self, #function)      
    _ = Charlie()
    _ = Charles()
  }
}

/// Module : FeatureB
/// FileName : Beta.swift
import FeatureC

public class Beta {
  public init() {
    print(#fileID, Self.self, #function)      
    _ = Charlie()
    _ = Charles()
  }
}

/// Module : FeatureC
/// FileName : Charlie.swift
public class Charlie {
  public init() {
    print(#fileID, Self.self, #function)
  }
}

/// Module : FeatureC
/// FileName : Charles.swift
public class Charles {
  public init() {
    print(#fileID, Self.self, #function)
  }
}
```

다음으로, Application 타겟을 기반으로 하는 유닛 테스트에서 이전에 작성한 `ClassScanner`를 사용하여 클래스 중복이 있는지 확인합니다.

```swift
import Testing

struct ClassScan {
  @Test func searchDuplicateClasses() {
    let scanner = ClassScanner()
    let allClasses = scanner.searchClassList()
    let duplicatedClasses = allClasses
      .filter { $0.value > 1 }

    #expect(duplicatedClasses.isEmpty)

    print("print Duplicated classes")
    for (k, v) in duplicatedClasses {
      print("\(k): \(v)")
    }
  }
}
```

해당 테스트는 중복이 없어야 성공하며, 클래스 중복이 발생하는 경우가 테스트가 실패되어 문제를 확인할 수 있도록 하였습니다.

하지만, 해당 테스트를 수행하면 다음과 같이 실패가 발생하는 것을 확인할 수 있습니다.

<br/>
<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2025/04/02.png"/>
</p><br/>

FeatureA, B 에서 FeatureC 코드가 복사되어 문제가 발생했으므로, FeatureC를 동적 라이브러리로 변경하거나, FeatureA, B를 FeatureC와 같은 정적 라이브러리로 변경하면 문제를 해결할 수 있습니다.

## 정리

정적 라이브러리와 동적 라이브러리를 혼용하여 사용할 때, 정적 라이브러리의 코드가 중복으로 포함되는 경우가 발생할 수 있습니다.
이 경우, 런타임에서 중복된 코드가 로드되면서 예기치 못한 동작이나 크래시를 초래할 수 있습니다.

## [예제 코드](https://github.com/minsOne/Experiment-Repo/tree/master/20250413)
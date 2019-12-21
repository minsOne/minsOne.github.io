---
layout: post
title: "[Swift3]The Swift Array Design 요약"
description: ""
category: "programming"
tags: [swift, Array, ContiguousArray, ArraySlice, NSArray, Cocoa]
---
{% include JB/setup %}

다음은 Swift의 [The Swift Array Design](https://github.com/apple/swift/blob/master/docs/Arrays.rst)를 요약 정리하였습니다.

### 목표

Swift에서 Array는 다음 목표를 가집니다.

1. C 배열과 같은 성능

2. Cocoa에 NSArray로 전달시 O(1)이어야 하며, 별도의 메모리 할당이 없어야 함.

3. 배열을 스택처럼 사용해야 함.

### 구성 요소

Swift에서 Array는 클래스 타입과 클래스가 아닌 타입을 지원합니다. 

Swift는 `ContiguousArray`를 가지는데 C 배열 성능이 필요할 때 사용합니다. `ContiguousArray`는 요소가 항상 연속으로 저장되며, Array가 클래스가 아닌 타입을 사용할 때 ContiguousArray와 성능이 동일합니다.

<img src="/../../../../image/flickr/30342109715_b41cd03129_z.jpg" width="565" height="128" alt="ContiguousArray"><br/><br/>

Array는 Cocoa를 오가는 효율적인 전환을 위해 최적화 되었습니다. 클래스 타입일 때 완전히 연속적으로 요소를 저장하지는 않고, `NSArray`에 저장합니다.

<img src="/../../../../image/flickr/30045612340_273ae1f3b2_z.jpg" width="570" height="588" alt="ArrayImplementation"><br/><br/>

`ArraySlice`는 `Array` 또는 `ContiguousArray`의 일부분이며, 배열 a에서의 a[10...20]과 같습니다. ArraySlice는 항상 연속적인 저장 공간과 C 배열과 같은 성능을 가집니다. ArraySlice는 일시적인 계산에 사용하는데 추천하며, ArraySlice 수명을 길게 늘이는 것을 권장하지 않습니다. 이는 공유 백업 버퍼의 일부분을 참조하고 있기 때문입니다.

<img src="/../../../../image/flickr/30256377571_a780a20c50_z.jpg" width="578" height="426" alt="Slice">

### Array 타입 변환

* 클래스 타입이거나 `@objc` 타입의 Array는 NSArray로 변환시 O(1)
* NSArray에서 Array로 변환시 NSArray에서 O(1)과 `copy()` 호출 비용
* [T]에서 [U]로 타입 전환시 O(1)
* [T]에서 [U]?로 전환 확인시 O(N)

<br/>ps. bridged, bridged back, bridged verbatim는 명료하게 번역할 수 없어 건너뛰었습니다.
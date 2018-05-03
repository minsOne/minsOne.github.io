---
layout: post
title: "[Swift4] LazySequence"
description: ""
category: "Programming"
tags: [Swift, Lazy, LazySequence, lazy, LazyCollection, LazySequenceProtocol]
---
{% include JB/setup %}

Swift에서 시퀀스를 다룰 때, lazy를 어떻게 써야하는지 몰라 사용을 거의 안했습니다. 하지만 적절한 곳에서 lazy를 사용한다면 연산을 덜 하면서 원하는 결과를 얻을 수 있습니다.

## LazySequence

lazy는 다음과 같이 Lazy 시퀀스를 만들 수 있습니다.

```
(1...1000).lazy
```

lazy를 사용했을 때, 어떻게 동작할까요? 다음 예제 코드를 살펴봅시다.

```
(1...1000).lazy
    .filter { $0 % 2 == 0 }
    .map { $0 * 2 }
    .prefix(2)
```

1에서 1000까지 숫자 중에 짝수 인 숫자들을 걸러 2를 곱하고, 그중 앞에서 3번째인 요소를 얻는 예제입니다.

lazy를 사용하지 않았다면, filter 함수에서 1000번 연산, map 함수에서 500번 연산이, prefix 에서 1번 연산이 일어나 1501번 연산을 통해 원하는 결과를 얻습니다.

lazy를 사용하게 되면 다음과 같은 연산 과정을 통해 결과를 얻습니다.

```
element 1
filter

element 2
filter
map
prefix

element 3
filter

element 4
filter
map
prefix
```

위의 8번 연산 과정을 통해 값을 얻게 됩니다. 따라서 연산 횟수가 1501 vs 8으로 크게 차이납니다.

위의 예제는 lazy를 사용했을 때, 얻는 효과가 극단적으로 큽니다. 하지만 전체 요소들을 다 살펴봐야 하는 속성이나 함수라면 이야기는 조금 달라집니다.

```
(1...1000).lazy
    .filter { $0 % 2 == 0 }
    .map { $0 * 2 }
    .count
```

위의 예제에서 lazy를 사용하지 않는다면, 총 1500번 연산이 일어납니다. 하지만 lazy를 사용한다면 모든 요소를 살펴봐야하기 때문에 1000번 연산이 일어납니다.

```
element 1
filter

element 2
filter

...

element 1000
filter
```

### 정리

* 어떤 값을 얻어야할 지 목적에 따라 lazy를 쓸지 여부를 파악
* 연산 횟수를 정확히 파악해야함.

### 참고자료

* [Lightning Read #1: Lazy Collections in Swift](https://medium.com/developermind/lightning-read-1-lazy-collections-in-swift-fa997564c1a3)
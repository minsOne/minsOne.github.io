---
layout: post
title: "[ReactiveX][RxSwift]핫 옵저버블과 콜드 옵저버블"
description: ""
category: "programming"
tags: [swift, ReactiveX, RxSwift, Observable, Observer, hot, cold]
---
{% include JB/setup %}

다음은 ReactiveX에서 정의한 [Hot and Cold Observables](http://reactivex.io/documentation/observable.html)과 [RxSwift](https://github.com/ReactiveX/RxSwift/blob/master/Documentation/HotAndColdObservables.md)에서 특정을 정리한 글을 번역한 자료입니다.

### 핫 옵저버블과 콜드 옵저버블

핫 옵저버블은 만들어지는 즉시 아이템을 발행하기 시작합니다. 그리고 Observable을 구독하는 Observer는 중간 어딘가에서 시퀀스를 관찰합니다.

콜드 옵저버블은 아이템을 발행하기 전에 Observer가 구독할 때 까지 기다립니다. 따라서 Observer는 시작부터 시퀀스 전체를 관찰하는 것을 보장받습니다.

### 핫 옵저버블과 콜드 옵저버블 특징 정리

|Hot Observables|Cold observables|
|---|---|
|시퀀스|시퀀스|
|Observer가 구독하든 말든 상관없이 아이템을 발행|Observer가 구독해야지 아이템을 발행|
|Variables / properties / constants<br/>tap coordinates<br/>mouse coordinates<br/>UI control values<br/>current time|Async operations<br/>HTTP Connections<br/>TCP connections<br/>streams|
|N개|1개|
|시퀀스 계산 리소스는 구독하고 있는 모든 Observer 사이에 공유됨|시퀀스 계산 리소스는 구독하고 있는 Observer마다 할당됨|
|상태 유지|무상태|

### 참고 자료

* [RxSwift](https://github.com/ReactiveX/RxSwift/blob/master/Documentation/HotAndColdObservables.md)
* [ReactiveX](http://reactivex.io/documentation/observable.html)
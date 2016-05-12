---
layout: post
title: "[ReactiveX][RxSwift]Combining Operator - startWith, CombineLatest, Merge, Zip, switchLatest"
description: ""
category: "programming"
tags: [swift, ReactiveX, RxSwift, startWith, combineLatest, merge, zip, switchLatest, Variable, Observable]
---
{% include JB/setup %}

여러 Observable을 묶어 사용하는 연산자를 살펴보려고 합니다.

### startWith

Obsevable이 아이템을 발행하기 전에 특정 아이템을 먼저 발행합니다.

```swift
	_ = Observable.of(1,2,3)
		.startWith(4,5,6)
		.startWith(7)
		.subscribe {
			print($0)
		}

	// Output
	Next(7)
	Next(4)
	Next(5)
	Next(6)
	Next(1)
	Next(2)
	Next(3)
	Completed
```

<br/>위 코드 실행 결과로 아래 스트림으로 나타낼 수 있습니다.

```swift
	s0   : ---------1-2-3x
	s1   : ---4-5-6x
	s2   : -7x
	subs : -7-4-5-6-1-2-3x
```

### CombineLatest

여러 Observable이 아이템을 발행할 때, 가장 최신의 아이템을 결합하고, 결합된 아이템을 발행합니다.

```swift
	let strOb = PublishSubject<String>()
	let intOb = PublishSubject<Int>()

	_ = Observable.combineLatest(strOb, intOb) {
		"\($0) \($1)"
		}
		.subscribe {
			print($0)
		}

	strOb.on(.Next("A"))
	intOb.on(.Next(1))
	strOb.on(.Next("B"))
	intOb.on(.Next(2))

	// Output
	Next(A 1)
	Next(B 1)
	Next(B 2)
```

strOb가 아이템 A를 발행하더라도 intOb이 아이템 1을 발행해야 combineLatest 연산자를 통해 결합된 아이템이 발행됩니다. strOb가 아이템 B를 발행하면, intOb가 발행한 아이템 1이 있기 때문에 B와 1이 결합되어 아이템이 발행됩니다.

<br/>위 코드 실행 결과로 아래 스트림으로 나타낼 수 있습니다.

```swift
	str  : -A----B------
	int  : ----1-----2--
	subs : ---A1-B1--B2-
```

시퀀스 Observable 두 개를 combineLatest로 묶으면 어떻게 될까요?

```swift
	let strOb = Observable.of("A", "B", "C")
	let intOb = Observable.of(0, 1, 2, 3)

	_ = Observable.combineLatest(strOb, intOb) {
			"\($0) \($1)"
		}
		.subscribe {
			print($0)
		}
	// Output
	Next(C 0)
	Next(C 1)
	Next(C 2)
	Next(C 3)
	Completed
```

strOb의 마지막 아이템을 발행하고, intOb의 개별 아이템 발행한 아이템과 결합하여 발행됩니다.

시퀀스 Observable 3개 이상을 combineLatest로 묶으면 어떻게 될까요?

```swift
	let strOb = Observable.of("A", "B", "C")
	let intOb = Observable.of(0, 1, 2, 3)
	let flOb = Observable.of(0.0, 0.1, 0.2)

	_ = Observable.combineLatest(strOb, intOb, flOb) {
			"\($0) \($1) \($2)"
		}
		.subscribe {
			print($0)
		}

	// Output
	Next(C 3 0.0)
	Next(C 3 0.1)
	Next(C 3 0.2)
	Completed
```

strOb, intOb의 마지막 아이템을 발행하고, flOb의 개별 아이템 발행한 아이템과 결합하여 발행됩니다.

<br/><br/>만약 여러 Observable이 같은 타입인 경우 combineLatest는 다음과 같이 사용할 수 있습니다.

```swift
	let intOb1 = Observable.of(1, 10, 20, 30, 40)
	let intOb2 = Observable.of(0, 1, 2, 3)
	let intOb3 = Observable.of(0, 2, 4, 6, 8)

	_ = [intOb1, intOb2, intOb3].combineLatest { list in
			list.reduce(0, combine: +)
		}
		.subscribe { (event: Event<Int>) -> Void in
			print(event)
	}
```

### Merge

여러 Observable을 하나로 합쳐서 아이템을 발행합니다.

```swift
	let sub1 = PublishSubject<Int>()
	let sub2 = PublishSubject<Int>()

	_ = Observable.of(sub1, sub2)
		.merge()
		.subscribeNext { int in
			print(int)
		}

	sub1.on(.Next(20))
	sub1.on(.Next(40))
	sub2.on(.Next(1))
	sub1.on(.Next(100))
	sub2.on(.Next(10))

	// Output
	20
	40
	1
	100
	10
```

<br/>위 코드 실행 결과로 아래 스트림으로 나타낼 수 있습니다.

```swift
	sub1 : -20--40----100----
	sub2 : ---------1-----10-
	subs : -20--40--1-100-10-
```

### Zip

두 개 이상의 Observable에서 발행 순서가 같은 아이템을 묶어 발행합니다. 즉, Observable1에서 A, B, C를 발행하고, Observable2에서 1, 2, 3을 발행하면 Zip 연산자로 (A, 1), (B, 2), (C, 3)이 발행됩니다.

```swift
	let strOb1 = PublishSubject<String>()
	let intOb1 = PublishSubject<Int>()

	_ = Observable
		.zip(strOb1, intOb1) { ($0, $1) }
		.subscribe { print($0) }

	strOb1.on(.Next("A"))
	strOb1.on(.Next("B"))
	intOb1.on(.Next(1))
	intOb1.on(.Next(2))
	intOb1.on(.Next(3))
	intOb1.on(.Next(4))
	strOb1.on(.Next("C"))
	strOb1.on(.Next("D"))

	// Output
	Next(("A", 1))
	Next(("B", 2))
	Next(("C", 3))
	Next(("D", 4))
```

위 코드에서 strOb1, intOb1의 아이템 발행 순서가 같은 아이템이 묶여 발행됨을 확인할 수 있습니다.

<br/>따라서 위 코드 실행 결과로 아래 스트림으로 나타낼 수 있습니다.

```swift
	str1 : -A---B-------------------C---D--
	int1 : ---------1---2---3---4----------
	subs : ---------A1--B2----------C3--D4-
```

### switchLatest

Observable에서 발행하는 Observable을 다른 Observable로 변경하여 아이템을 발행하도록 하며, 가장 최신의 아이템으로 발행됩니다.

```swift
	let var1 = Variable(0)
	let var2 = Variable(200)
	let var3 = Variable(var1.asObservable())

	_ = var3
		.asObservable()
		.switchLatest()
		.subscribe { print($0) }

	var1.value = 1
	var1.value = 2
	var1.value = 3
	var3.value = var2.asObservable()
	var2.value = 201
	var1.value = 5
	var1.value = 6

	// Output
	Next(0)
	Next(1)
	Next(2)
	Next(3)
	Next(200)
	Next(201)
	Completed
```

위 코드에서 var3의 value값을 var2 Observable로 변경하였기 때문에, var1의 value 값을 변경하더라도 무시됩니다.

<br/>따라서 위 코드 실행 결과로 아래 스트림으로 나타낼 수 있습니다.

```swift
	var1 : -0---1---2---3-------5---6---
	var2 : ---------------200-201-------
	var3 : -var1----------var2----------
	subs : -0---1---2---3-200-201-------
```
---
layout: post
title: "PerformSelector를 사용하는 것 대신 Block을 사용하는 GCD를 호출하는 방법"
description: ""
category: "iOS"
tags: [performSelector, method, gcd, timer, arc, selector, dispatch_after, dispatch_async]
---
{% include JB/setup %}

NSObject의 Method 중에서 가장 기본적인 메소드는 `performSelector`가 있으며 다음과 같이 선언되어 있습니다.

	 - (id)performSelector:(SEL)selector

performSelector로 호출하는 것과 클래스에 메소드를 직접 호출하는 것 `[foo selectorName]`과 결과로는 같습니다.

하지만 performSelector는 동적 메소드 바인딩을 통해서 실행할 수 있습니다.

	SEL selector;
    selector = @selector(foo);
    [self performSelector:selector];

    selector = @selector(bar);
    [self performSelector:selector];

조건에 따라 selector를 변경하여 사용할 수 있습니다라고 하지만 ARC를 사용한다면 Xcode의 컴파일러가 `메모리 누수`가 일어날 수 있다라고 알려줍니다.

컴파일러는 어떤 메소드를 호출하려고하는지 알수가 없어서 ARC를 적용할 수 없기 때문입니다.

또한, performSelector는 파라미터로 넘겨줄 수 있는 값은 최대 두 개의 파라미터를 받을 수 있습니다. 최대 두 개의 파라미터이므로 쓸 수 있는 부분이 한정적이게 됩니다.

performSelector에서는 또 다른 기능 중 하나는 선택자를 지연해서 실행하거나 다른 스레드에서 실행할 수 있습니다.

	 - (void)performSelector:(SEL)aSelector withObject:(id)anArgument afterDelay:(NSTimeInterval)delay;
	 - (void)performSelector:(SEL)aSelector onThread:(NSThread *)thr withObject:(id)arg waitUntilDone:(BOOL)wait

이러한 메소드는 추가적인 파라미터들에 대해 실행할 수 있는 방법이 없습니다. 이러한 제약 조건들을 해결할 수 있는 방법으로는 `Block`을 사용합니다. 게다가 GCD와 함께 Block을 사용하면 performSelector 메소드를 사용할 때 스레드 관련된 버그들을 해결할 수 있습니다.

메소드를 지연하여 실행할 수 있도록 `dispatch_after`를 이용하고 다른 스레드에서 메소드가 수행하도록 dispatch_sync, dispatch_async를 이용하여 수행합니다.

	// 기존 performSelector를 사용하는 경우
	[self performSelector:@selector(foo)
	           withObject:nil
	           afterDelay:5.0f];

	// dispatch_after를 이용하는 경우
	dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0f * NSEC_PER_SEC));
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [self foo];
    });

    // 메인 스레드에서 performSelector를 사용하는 경우
    [self performSelectorOnMainThread:@selector(foo)
                           withObject:nil
                        waitUntilDone:NO];

    // dispatch_async를 사용하는 경우
    dispatch_async(dispatch_get_main_queue(), ^{
        [self foo];
    });

다른 스레드에서 실행하기 위해서 Block을 사용하는 GCD를 호출하면 인자에 대한 제한이 없이 사용이 가능합니다.
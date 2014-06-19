---
layout: post
title: "how to using gcd group and notification"
description: ""
category: ""
tags: []
---
{% include JB/setup %}

GCD는 Fire and Forget의 기반을 두지만 작업이 끝난 후 처리해야할 비즈니스 로직이 있다면 어떻게 해야 할까요? 작업이 끝났다는 통지를 받고 수행해야 하는데 NSNotification을 사용해야 하나요?

이런 점에서 GCD는 dispatch group이라는 것을 다중의 비동기 작업이 동작하더라도 모니터링 할 수 있습니다. Dispatch group은 작업이 끝났을 때 그룹에 속해있다면 알려줍니다. 동기와 비동기 작업을 별도로 관리하고 서로 다른 큐에서 작업하므로 이러한 작업이 가능합니다.

dispatch group은 dispatch_group_create 메소드로 생성합니다.

	dispatch_group_t loopForGroup = dispatch_group_create();

<br/>
dispatch group의 작업이 끝난 후 비즈니스 로직을 수행하도록 하는 현재 쓰레드가 중단되었다가 실행하는 dispatch_group_wait와 특정 큐에서 실행될 블록을 작성하여 현재 쓰레드가 중단되지 않고 하는 dispatch_group_notify가 있습니다.

우선 dispatch_group_wait를 살펴봅시다.

	 - (void)loop1000 {
		for (int i = 0; i < 1000; i++){}
		NSLog(@"Loop 1000 Function ");
	 }

	 - (void)makeDispatchGroupWait {
	 	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
 	    dispatch_group_t loopForGroup = dispatch_group_create();

 	    for (int i = 0; i < 50; i++) {
 	        dispatch_group_async(loopForGroup, queue, ^{
 	            [self loop1000];
 	        });
 	    }

 	    dispatch_group_wait(loopForGroup, DISPATCH_TIME_FOREVER);

 	    NSLog(@"Wait is End");
	 }

makeDispatchGroupWait 메소드에서 dispatch_get_global_queue를 통해 dispatch_queue를 생성합니다. 그리고 dispatch_group_create 메소드를 통해 dispatch_group를 생성합니다.

dispatch_group_async에 dispatch_queue와, dispatch_group 그리고 실행할 메소드 loop1000 block을 넣습니다.

dispatch_group_wait는 기다리다가 dispatch_group의 작업이 끝나면 'Wait is End'를 출력하고 끝납니다. 이렇게 사용하게 되면 좀 더 빠른 수행이 가능하지만 메인 쓰레드가 중지되고 UI 블럭이 발생하게 됩니다.

<br/>그렇다면 dispatch_group_notify를 살펴봅시다.



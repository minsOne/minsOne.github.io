---
layout: post
title: "[Objective-C]GCD의 dispatch group과 notify를 사용하여 작업을 위임하기"
description: ""
category: "Mac/iOS"
tags: [objc, dispatch, dispatch_group, dispatch_queue, dispatch_group_wait, dispatch_group_notify, dispatch_group_async, async, notify, wait, concurrent, nsnotification]
---
{% include JB/setup %}

GCD는 Fire and Forget의 기반을 두지만 작업이 끝난 후 처리해야할 비즈니스 로직이 있다면 어떻게 해야 할까요? 작업이 끝났다는 통지를 받고 수행해야 하는데 NSNotification을 사용해야 하나요?

이런 점에서 GCD는 dispatch group이라는 것을 다중의 비동기 작업이 동작하더라도 모니터링 할 수 있습니다. Dispatch group은 작업이 끝났을 때 그룹에 속해있다면 알려줍니다. 동기와 비동기 작업을 별도로 관리하고 서로 다른 큐에서 작업하므로 이러한 작업이 가능합니다.

dispatch group은 dispatch_group_create 메소드로 생성합니다.

	dispatch_group_t loopForGroup = dispatch_group_create();

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

dispatch_group_wait는 기다리다가 dispatch_group의 작업이 끝나면 'Wait is End'를 출력하고 끝납니다. GCD를 사용해서 좀 더 빠른 수행이 가능하지만 현재 쓰레드가 중지됩니다.

그렇다면 dispatch_group_notify를 살펴봅시다.

	- (void)loop1000Low {
			for (int i = 0; i < 1000; i++) {}
			NSLog(@"Loop 1000 Low Function ");
	}

	- (void)loop10000High {
			for (int i = 0; i < 10000; i++) {}
			NSLog(@"Loop 10000 High Function ");
	}

	- (void) makeDispatchGroupNotify {

		NSLog(@"dispatch Run!!");

		dispatch_queue_t lowPriorityQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
		dispatch_queue_t highPriorityQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
		dispatch_group_t dispatchGroup = dispatch_group_create();

		for (int i = 0; i < 100; i++) {
			dispatch_group_async(dispatchGroup, lowPriorityQueue, ^{
					[self loop1000Low:i];
			});
		}

		for (int i = 0; i < 100; i++) {
			dispatch_group_async(dispatchGroup, highPriorityQueue, ^{
					[self loop10000High:i];
			});
		}

		dispatch_queue_t notifyQueue = dispatch_get_main_queue();
			dispatch_group_notify(dispatchGroup, notifyQueue, ^{
					NSLog(@"Really GCD End?!");
			});
			NSLog(@"End????????");
	}

우선순위가 LOW, HIGH인 dispatch_queue와 dispatch_group을 생성합니다. 100번씩 반복문을 돌리고 dispatch_group_async에 loop메소드를 넣습니다. notifyQueue를 dispatch_get_main_queue로 생성하여 notifyQueue에서 notify를 받도록 dispatch_group_notify 메소드를 사용합니다. notifyQueue에서 mainQueue를 꼭 사용할 필요 없이 큐를 별도로 생성하여 알림을 받을 수도 있습니다.

앞에서 설명한 dispatch_group_wait는 현재 쓰래드가 블럭이 되지만 dispatch_group_notify는 현재 쓰래드가 블럭이 되지 않기 때문에 그 다음에 있는 NSLog를 실행하고 dispatch_group의 작업이 끝나면 'NSLog(@"Really GCD End?!")'가 실행이 됩니다.

다음은 위의 코드를 실행한 결과입니다.

	2014-06-19 16:45:01.760 dispatchqueue[31995:60b] Run!!!!
	2014-06-19 16:45:01.761 dispatchqueue[31995:60b] End????????
	2014-06-19 16:45:01.761 dispatchqueue[31995:3507] Loop 10000 High Function 0
	2014-06-19 16:45:01.761 dispatchqueue[31995:3803] Loop 10000 High Function 1
	2014-06-19 16:45:01.761 dispatchqueue[31995:3903] Loop 10000 High Function 2
	2014-06-19 16:45:01.763 dispatchqueue[31995:3507] Loop 10000 High Function 4
	2014-06-19 16:45:01.762 dispatchqueue[31995:3a03] Loop 10000 High Function 3
	.
	.
	2014-06-19 16:45:01.917 dispatchqueue[31995:4b03] Loop 1000 Low Function 99
	2014-06-19 16:45:01.916 dispatchqueue[31995:4303] Loop 1000 Low Function 96
	2014-06-19 16:45:01.916 dispatchqueue[31995:4003] Loop 1000 Low Function 95
	2014-06-19 16:45:01.878 dispatchqueue[31995:4d03] Loop 1000 Low Function 65
	2014-06-19 16:45:01.928 dispatchqueue[31995:60b] Really GCD End?!

쓰래드가 블럭되지 않고 정상적으로 진행된 것을 확인할 수 있습니다.

<br/>
만약 작업을 분리하여 별도의 큐에 넣어서 처리한다고 한다면 굳이 dispatch_group을 사용할 필요가 없습니다. dispatch_async만을 사용하여 알림을 사용할 수 있습니다.

	dispatch_queue_t queue = dispatch_queue_create("kr.minsOne.queue", NULL);
	for (int i = 0; i < 100; i++) {
			dispatch_async(queue, ^{
					[self loop10000High:i];
			});
	}
	dispatch_async(queue, ^{
					NSLog(@"Replace Notification!!!");
			});

dispatch_queue_create 메소드로 큐를 생성할 때 `dispatch_queue_attr`를 `NULL`로 해주어야 합니다.

기본값일 경우 dispatch_queue는 순차적으로 동작을 하며 queue의 작업이 끝난 후에 별도의 로직을 수행할 수 있습니다.

하지만 `DISPATCH_QUEUE_CONCURRENT`로 해준다면 비동기적으로 동작하기 때문에 알림을 사용할 수 없습니다.

이러한 점을 유의한다면 부분적으로 필요한 곳에서 dispatch_group_notify를 대신하여 사용할 수 있습니다.
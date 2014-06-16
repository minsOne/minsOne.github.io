---
layout: post
title: "GCD를 통해서 데이터를 동기화 하기"
description: ""
category: "iOS"
tags: [ios, gcd, lock, queue, async, sync, barrier, synchronized]
---
{% include JB/setup %}

다수의 쓰레드를 통해 데이터를 동시에 접근하는 경우 동기화 관련되서 문제가 발생합니다. @synchronized(self)나 NSLock을 사용하여 해결할 수도 있습니다. 하지만 코드가 비효율이 되며 불필요하게 다른 쓰레드에서 기다리는 상태가 발생할 수 있으며 데드락이 발생할 수 있는 가능성이 농후합니다.

애플에서 제공해주는 GCD를 이용하면 OS에서 관리를 하기 때문에 간단하면서도 효율적인 코드를 작성할 수 있습니다.

순차적 동기화 큐(serial synchronization queue)를 사용하면 동일한 큐에서 읽기, 쓰기에 대한 동기화가 보장됩니다.

<pre><code class="objectivec">
dispatch_queue_t syncQueue = dispatch_queue_create("kr.minsOne.syncQueue", NULL);

__block NSString *localString;

dispatch_sync(syncQueue, ^{
   localString = @"minsOne";
});
</code></pre><br/>

모든 리소스에 대한 Lock을 GCD가 관리하므로 코드가 매우 깔끔하게 작성이 됩니다. GCD가 관리하는 것에 대해서는 신경쓸 필요가 없이 코드를 작성할 수 있습니다.

이제 비동기에 대해서 작업하고자 한다면 dispatch_async를 이용해서 작업이 가능합니다.

<pre><code class="objectivec">
dispatch_async(syncQueue, ^{
   localString = @"minsOne";
});
</code></pre><br/>

일반적으로 동기 dispatch보다 비동기 dispatch가 작업 시간이 조금 더 오래 걸립니다. 하지만 오래걸리는 작업을 하고자 한다면 비동기 dispatch를 통해서 UI를 블럭시키지 않고 작업이 가능합니다.

조금 더 빠르게 작업하고자 한다면 dispatch_get_global_queue를 사용하면 됩니다.

<pre><code class="objectivec">
dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

dispatch_async(globalQueue, ^{
   localString = @"minsOne";
});
</code></pre><br/>

하지만 여러 쓰레드에서 동시에 값을 읽고 쓰는 것이 가능하기 때문에 동기화에 대해 문제가 발생합니다. 동기화 관련되어서는 dispatch_barrier_async를 이용하여 해결할 수 있습니다. dispatch barrier는 다른 GCD 처럼 사용하지만 값을 쓰는 setter에 대해서는 베타적으로 실행하여 다른 작업들이 대기하도록 합니다.

<pre><code class="objectivec">
dispatch_barrier_async(globalQueue, ^{
   localString = @"minsOne";
});
</code></pre><br/>

따라서 GCD를 이용하더라도 목적에 따라 사용하는 GCD 메소드를 다르게 사용하도록 합니다.







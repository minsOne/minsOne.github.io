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

<pre><code class="objectivec">
	
</code></pre><br/>
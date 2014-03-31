---
layout: post
title: "Google Analytics 세션 유지"
description: ""
category: "iOS"
tags: [Google Analytics, iOS, Heartbeat]
---
{% include JB/setup %}

Google Analytics는 기본 세션 유지시간이 30분정도입니다. 그리하여 꾸준히 클라이언트에서 살아있음을 알려줘야 합니다. 이것을 HeartBeat라고 합니다.

NSTimer에서 지원하는 scheduledTimerWithTimeInterval를 통해 일정시간마다 데이터을 보내도록 합니다.

	NSTimer *keepAliveTimer = [NSTimer scheduledTimerWithTimeInterval:KeepAliveTime
                                                      target:self
                                                    selector:@selector(heartBeat)
                                                    userInfo:nil
                                                     repeats:YES];


Google Analytics에 HeartBeat 데이터를 보냅니다.

	id<GAITracker> tracker= [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"app"
                                                          action:@"HeartBeat"
                                                           label:nil
                                                           value:nil]
                   build]];

위와 같이 수행을 하면 이제부터는 세션이 끊겨 현재 사용자수가 줄어들 일은 발생하지 않게 됩니다.
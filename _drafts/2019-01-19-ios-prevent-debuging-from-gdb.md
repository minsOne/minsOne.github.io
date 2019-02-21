---
layout: post
title: "ios prevent debuging from gdb"
description: ""
category: ""
tags: []
---
{% include JB/setup %}

http://goodyoda.tistory.com/283
https://www.theiphonewiki.com/wiki/Bugging_Debuggers
https://github.com/Apress/ios-penetration-testing/blob/master/ch7_preventing_GDB.m

http://www.apress.com/9781484223543

void noDebug() {
 void* handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
 ptrace_ptr_t ptrace_ptr = dlsym(handle, “ptrace”);
 ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
 dlclose(handle);
}
---
layout: post
title: "Xcode에서 iOS 로그 편하게 사용하기"
description: ""
category: "iOS"
tags: [ios,log,xcode]
---
{% include JB/setup %}

### Xcode에서 로그 편하게 사용하기

Xcode에서 디버깅할 때 NSLog함수는 불가분 관계에 있습니다. 따라서 얼마나 편하게 사용하느냐에 따라 달라집니다.

모든 파일에서 로그 함수를 재정의해서 작성하는 그러한 노가다를 하는 것보다 Prefix.pch에 정의를 해놓고 사용을 하도록 합니다.

    #ifdef DEBUG
        #define DFT_TRACE   NSLog(@"%s[Line %d]", __PRETTY_FUNCTION__, __LINE__);
        #define NSLog(fmt, ...) NSLog((@"%s[Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
    #else
        #define DFT_TRACE
        #define NSLog(...)
    #endif

프로젝트의 Scheme에 있는 Info 항목에서 Build Configuration 값이 Debug인 경우 로그가 출력되지만 Release인 경우에는 로그가 출력되지 않습니다.<br/>
![Build Configuration](/../../../../image/2014/build_configuration.png)

NSLog는 기본적으로 사용하기에설명은 제외합니다.

DFT_TRACE는 다음과 같이 사용하면 됩니다.

    - (NSString *)calculateSecondResult:(NSString *)data
    {    
        DFT_TRACE;
    }

함수를 만들고 DFT_TRACE를 추가하면 해당 함수가 수행될때 Console에 로그가 출력되도록 합니다.

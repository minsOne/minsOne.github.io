---
layout: post
title: "[GCC] 정적 라이브러리(Static Library), 동적 라이브러리(Shared Library) 만들기"
description: ""
category: "programming"
tags: [gcc]
---
{% include JB/setup %}

우리가 소스 파일을 컴파일하고, 그 결과물을 실행시킵니다. 하지만 코드가 많아지면 파일 하나에서 여러 파일로 나누어 격리하고, 목적에 맞는 코드들을 모아 라이브러리를 만들어 각각 컴파일 후, 생성된 오브젝트 코드은 링커를 이용하여 실행파일에 라이브러리를 연결합니다.

이 과정은 다음 그림에서 쉽게 이해할 수 있습니다.

![1]({{site.development_url}}/image/2020/06/1.gif)

출처 : [ODU - CS333 Lecture - The Structure of a C++ Program](https://www.cs.odu.edu/~zeil/cs333/website-s12/Lectures/cppProgramStructure/pages/ar01s01s03.html)

컴파일된 실행파일은 메모리의 텍스트 영역(Text Segment)에 적재됩니다.

<!-- 이미지 출처 : https://gabrieletolomei.wordpress.com/miscellanea/operating-systems/in-memory-layout/ -->

기능이 많이 추가되면 라이브러리에 있는 코드도 많아지고, 각 역할에 맞는 라이브러리도 많아져 바이너리 크기는 점점 증가합니다. 

한번만 실행하면 괜찮지만 여러번 실행되면 메모리에 많은 영역을 차지하고, 그러면 더 많은 메모리가 필요하게 됩니다.

여기에서 라이브러리를 다루는 방식이 단일 실행에 적합한 정적 라이브러리, 다중 실행에 적합한 동적 라이브러리 형태로 나눠집니다.

실행 파일은 가볍게 만들어 다중 실행하고, 메모리에 적재된 라이브러리를 이용해 결과를 얻는 방식이 동적 라이브러리 입니다.

동적 라이브러리는 힙 영역과 스택 영역 사이에 적재됩니다.

그러면 정적 라이브러리와 동적 라이브러리를 만들어봅시다.

## 라이브러리 작성

덧셈과 곱셈 기능을 하는 라이브러리를 작성합니다.

### 정적 라이브러리 - Static Library

먼저 `math.h` 라는 헤더 파일과 `math.c` 소스 파일에 덧셈과 곱셈 기능을 작성합니다.

```
/// FileName: math.h
int sum(int, int);
int multi(int, int);

/// FileName: math.c
#include "math.h"
 
int sum(int a, int b) {
    return a + b;
}
 
int multi(int a, int b) {
    return a * b;
}
```

이제 GCC를 이용하여 Object 파일을 생성합니다.

```
$ gcc -c math.c
$ file math.o
math.o: Mach-O 64-bit object x86_64
$ nm math.o
0000000000000020 T _multi
0000000000000000 T _sum
```

math.o 파일이 생성되고, Object 파일을 확인할 수 있습니다. 그리고 sum, multi 함수가 있음을 알 수 있습니다.

이제 ar 명령어를 이용하여 라이브러리 파일을 생성합니다.

```
$ ar crv libmath.a math.o
```


## 참고

https://jihadw.tistory.com/134
https://jhnyang.tistory.com/42
https://www.cs.odu.edu/~zeil/cs333/website-s12/Lectures/cppProgramStructure/pages/ar01s01s03.html
https://www.kdata.or.kr/info/info_04_view.html?field=&keyword=&type=techreport&page=168&dbnum=128161&mode=detail&type=techreport
http://blog.naver.com/PostView.nhn?blogId=parkjy76&logNo=220925369874&parentCategoryNo=&categoryNo=23&viewDate=&isShowPopularPosts=true&from=search
https://nicewoong.github.io/development/2018/02/24/c-library-gcc-compile/
https://m.blog.naver.com/muyong1/40056025174
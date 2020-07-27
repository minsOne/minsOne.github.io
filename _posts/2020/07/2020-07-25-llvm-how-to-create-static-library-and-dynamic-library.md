---
layout: post
title: "[LLVM] 정적 라이브러리(Static Library), 동적 라이브러리(Shared Library) 만들기"
description: ""
category: "programming"
tags: [gcc, LLVM, nm, ar, libtool, Static Library, Dynamic Library, objdump, otool, memory segments, linking, object file]
alias: /programming/gcc-static-library-and-dynamic-library
---
{% include JB/setup %}

우리가 소스 파일을 컴파일하고, 그 결과물을 실행시킵니다. 하지만 코드가 많아지면 파일 하나에서 여러 파일로 나누어 격리하고, 목적에 맞는 코드들을 모아 라이브러리를 만들어 각각 컴파일 후, 생성된 오브젝트 코드는 링커를 이용하여 실행파일에 라이브러리를 연결합니다.

이 과정은 다음 그림에서 쉽게 이해할 수 있습니다.

![1]({{site.production_url}}/image/2020/07/20200725_1.gif)

출처 : [ODU - CS333 Lecture - The Structure of a C++ Program](https://www.cs.odu.edu/~zeil/cs333/website-s12/Lectures/cppProgramStructure/pages/ar01s01s03.html)

컴파일된 실행파일은 메모리의 Text Segment에 적재됩니다.

![3]({{site.production_url}}/image/2020/07/20200725_3.png)

출처 : [Post - Anatomy of a Program in Memory](https://manybutfinite.com/post/anatomy-of-a-program-in-memory/)

기능이 많이 추가되면 라이브러리에 있는 코드도 많아지고, 각 역할에 맞는 라이브러리도 많아져 바이너리 크기는 점점 증가합니다. 

한번만 실행하면 괜찮지만 여러번 실행되면 메모리에 많은 영역을 차지하고, 그러면 더 많은 메모리가 필요하게 됩니다.

여기에서 라이브러리를 다루는 방식이 단일 실행에 적합한 정적 라이브러리, 다중 실행에 적합한 동적 라이브러리 형태로 나눠집니다.

정적 라이브러리는 실행 파일에 포함되므로 Text Segment에, 동적 라이브러리는 공유하므로 Memory Mapping Segment에 적재됩니다.

그러면 정적 라이브러리와 동적 라이브러리를 만들어봅시다.

## 라이브러리 작성

주의 : OSX 환경에서 라이브러리를 만드는 방법을 설명하며, 최신 OSX에서는 GCC가 LLVM으로 대신 사용되고 있습니다. [참고](https://ji007.tistory.com/m/entry/LLVM-Low-Level-Virtual-Machine)

여기에 작성된 예제에서 사용한 GCC 버전은 다음과 같습니다.

```
$ gcc --version
Configured with: --prefix=/Applications/Xcode.app/Contents/Developer/usr --with-gxx-include-dir=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/c++/4.2.1
Apple clang version 11.0.3 (clang-1103.0.32.62)
Target: x86_64-apple-darwin19.5.0
Thread model: posix
InstalledDir: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin
```

덧셈과 곱셈 기능을 하는 라이브러리를 작성해봅시다.

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
$ gcc -c math.c -o math.o

$ file math.o
math.o: Mach-O 64-bit object x86_64

$ nm math.o
0000000000000020 T _multi
0000000000000000 T _sum
```

math.o 파일이 생성되고, Object 파일을 확인할 수 있습니다. 그리고 sum, multi 함수가 있음을 알 수 있습니다.

이제 libtool, ar 명령어를 이용하여 정적 라이브러리 파일을 생성합니다.

```
# libtool로 정적 라이브러리 만들기
$ libtool -static -o libmath.a math.o

# ar로 정적 라이브러리 만들기
$ ar rcs libmath.a math.o

$ file libmath.a
libmath.a: current ar archive random library

$ nm libmath.a

libmath.a(math.o):
0000000000000020 T _multi
0000000000000000 T _sum
```

라이브러리의 sum, multi 함수를 호출할 실행 파일을 만들고, 정적 라이브러리 libmath.a와 연결하여 정상 출력되는지 확인합니다.

```
/// FileName: main.c
#include "math.h"
 
int main()
{
    int a = 10;
    int b = 40;
    
    printf("sum : %d\n", sum(a,b));
    printf("multi : %d\n", multi(a,b));
    
    return 0;
}
```

```
$ gcc main.c -lmath -o main -L.
$ ./main

sum : 50
multi : 400
```

이제 정적 라이브러리 libmath.a 코드가 main 파일에 포함되어 있는지 확인합니다.

먼저 nm 명령어로 multi, sum 함수가 있는지 확인합니다.

```
$ nm main
0000000100002008 d __dyld_private
0000000100000000 T __mh_execute_header
0000000100000ed0 T _main
0000000100000f60 T _multi
                 U _printf
0000000100000f40 T _sum
                 U dyld_stub_binder
```

다음으로, 정적 라이브러리 소스가 Text Segment 영역에 있는지 objdump 명령어로 확인합니다.

```
$ objdump -d main

main:	file format Mach-O 64-bit x86-64


Disassembly of section __TEXT,__text:

0000000100000ed0 _main:
100000ed0: 55                          	pushq	%rbp
100000ed1: 48 89 e5                    	movq	%rsp, %rbp
100000ed4: 48 83 ec 20                 	subq	$32, %rsp
100000ed8: c7 45 fc 00 00 00 00        	movl	$0, -4(%rbp)
100000edf: 89 7d f8                    	movl	%edi, -8(%rbp)
100000ee2: 48 89 75 f0                 	movq	%rsi, -16(%rbp)
100000ee6: c7 45 ec 0a 00 00 00        	movl	$10, -20(%rbp)
100000eed: c7 45 e8 28 00 00 00        	movl	$40, -24(%rbp)
100000ef4: 8b 7d ec                    	movl	-20(%rbp), %edi
100000ef7: 8b 75 e8                    	movl	-24(%rbp), %esi
100000efa: e8 41 00 00 00              	callq	65 <_sum>
100000eff: 48 8d 3d 90 00 00 00        	leaq	144(%rip), %rdi
100000f06: 89 c6                       	movl	%eax, %esi
100000f08: b0 00                       	movb	$0, %al
100000f0a: e8 65 00 00 00              	callq	101 <dyld_stub_binder+0x100000f74>
100000f0f: 8b 7d ec                    	movl	-20(%rbp), %edi
100000f12: 8b 75 e8                    	movl	-24(%rbp), %esi
100000f15: 89 45 e4                    	movl	%eax, -28(%rbp)
100000f18: e8 43 00 00 00              	callq	67 <_multi>
100000f1d: 48 8d 3d 7c 00 00 00        	leaq	124(%rip), %rdi
100000f24: 89 c6                       	movl	%eax, %esi
100000f26: b0 00                       	movb	$0, %al
100000f28: e8 47 00 00 00              	callq	71 <dyld_stub_binder+0x100000f74>
100000f2d: 31 c9                       	xorl	%ecx, %ecx
100000f2f: 89 45 e0                    	movl	%eax, -32(%rbp)
100000f32: 89 c8                       	movl	%ecx, %eax
100000f34: 48 83 c4 20                 	addq	$32, %rsp
100000f38: 5d                          	popq	%rbp
100000f39: c3                          	retq
100000f3a: 90                          	nop
100000f3b: 90                          	nop
100000f3c: 90                          	nop
100000f3d: 90                          	nop
100000f3e: 90                          	nop
100000f3f: 90                          	nop

0000000100000f40 _sum:
100000f40: 55                          	pushq	%rbp
100000f41: 48 89 e5                    	movq	%rsp, %rbp
100000f44: 89 7d fc                    	movl	%edi, -4(%rbp)
100000f47: 89 75 f8                    	movl	%esi, -8(%rbp)
100000f4a: 8b 45 fc                    	movl	-4(%rbp), %eax
100000f4d: 03 45 f8                    	addl	-8(%rbp), %eax
100000f50: 5d                          	popq	%rbp
100000f51: c3                          	retq
100000f52: 66 2e 0f 1f 84 00 00 00 00 00       	nopw	%cs:(%rax,%rax)
100000f5c: 0f 1f 40 00                 	nopl	(%rax)

0000000100000f60 _multi:
100000f60: 55                          	pushq	%rbp
100000f61: 48 89 e5                    	movq	%rsp, %rbp
100000f64: 89 7d fc                    	movl	%edi, -4(%rbp)
100000f67: 89 75 f8                    	movl	%esi, -8(%rbp)
100000f6a: 8b 45 fc                    	movl	-4(%rbp), %eax
100000f6d: 0f af 45 f8                 	imull	-8(%rbp), %eax
100000f71: 5d                          	popq	%rbp
100000f72: c3                          	retq

Disassembly of section __TEXT,__stubs:

0000000100000f74 __stubs:
100000f74: ff 25 86 10 00 00           	jmpq	*4230(%rip)

Disassembly of section __TEXT,__stub_helper:

0000000100000f7c __stub_helper:
100000f7c: 4c 8d 1d 85 10 00 00        	leaq	4229(%rip), %r11
100000f83: 41 53                       	pushq	%r11
100000f85: ff 25 75 00 00 00           	jmpq	*117(%rip)
100000f8b: 90                          	nop
100000f8c: 68 00 00 00 00              	pushq	$0
100000f91: e9 e6 ff ff ff              	jmp	-26 <__stub_helper>

$ objdump -d libmath.a

libmath.a(math.o):	file format Mach-O 64-bit x86-64


Disassembly of section __TEXT,__text:

0000000000000000 _sum:
       0: 55                           	pushq	%rbp
       1: 48 89 e5                     	movq	%rsp, %rbp
       4: 89 7d fc                     	movl	%edi, -4(%rbp)
       7: 89 75 f8                     	movl	%esi, -8(%rbp)
       a: 8b 45 fc                     	movl	-4(%rbp), %eax
       d: 03 45 f8                     	addl	-8(%rbp), %eax
      10: 5d                           	popq	%rbp
      11: c3                           	retq
      12: 66 2e 0f 1f 84 00 00 00 00 00	nopw	%cs:(%rax,%rax)
      1c: 0f 1f 40 00                  	nopl	(%rax)

0000000000000020 _multi:
      20: 55                           	pushq	%rbp
      21: 48 89 e5                     	movq	%rsp, %rbp
      24: 89 7d fc                     	movl	%edi, -4(%rbp)
      27: 89 75 f8                     	movl	%esi, -8(%rbp)
      2a: 8b 45 fc                     	movl	-4(%rbp), %eax
      2d: 0f af 45 f8                  	imull	-8(%rbp), %eax
      31: 5d                           	popq	%rbp
      32: c3
```

실행 파일인 main 에 있는 sum, multi 함수의 어셈블리 코드와 정적 라이브러리인 libmath.a에 있는 sum, multi 함수의 어셈블리 코드가 같은 것을 확인할 수 있습니다.

### 동적 라이브러리 - Shared Library

앞에서 만들었던 코드를 계속 이어서 사용합니다.

math.c 라이브러리를 동적 라이브러리 파일로 만듭니다. 

첫번째 방법은 libtool을 이용하여 동적 라이브러리를 만드는 방법입니다.

```
$ gcc -c math.c -o math.o

$ libtool -dynamic -o libmath.so math.o

$ file libmath.so
libmath.so: Mach-O 64-bit dynamically linked shared library x86_64
```

두번째 방법은 gcc의 shared 옵션을 이용하여 동적 라이브러리를 만드는 방법입니다.

```
# 소스 파일에서 만들기
$ gcc -shared -o libmath.so math.c

# Object 파일 만든 후, 동적 라이브러리 만들기
$ gcc -c math.c -o math.o
$ gcc -shared -o libmath.so math.o

$ file libmath.so
libmath.so: Mach-O 64-bit dynamically linked shared library x86_64
```

라이브러리의 sum, multi 함수를 호출할 실행 파일에 동적 라이브러리 libmath.so를 연결하여 정상 출력되는지 확인합니다.

```
# 직접 so 파일을 지정하는 경우
$ gcc -Wall main.c -o main libmath.so

# 라이브러리 경로만 지정하는 경우
$ gcc -Wall main.c -o main -L. -lmath # -L 뒤에는 libmath.so가 있는 폴더를 지정 "."은 현재 경로

$ ./main
sum : 50
multi : 400
```

otool을 이용하여 main에서 동적 라이브러리 libmath.so가 있는지 확인합니다.

```
$ otool -L main
main:
	libmath.so (compatibility version 0.0.0, current version 0.0.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1281.100.1)
```

만약 동적라이브러리 libmath.so를 지우면 어떻게 될까요?

```
$ rm libmath.so
$ ./main
dyld: Library not loaded: libmath.so
  Referenced from: /Users/username/example/./main
  Reason: image not found
[1]    96020 abort      ./main
```

동적 라이브러리 libmath.so를 로드하는데 실패하여 종료됩니다. 하지만 다시 math.c를 다시 동적 라이브러리로 만들어 실행하면 정상적으로 동작합니다.

```
$ gcc -shared -o libmath.so math.c
$ ./main
sum : 50
multi : 400
```

다음으로 main에 sum, multi 함수가 포함되지 않았는지 확인합니다.

```
$ nm main
0000000100002018 d __dyld_private
0000000100000000 T __mh_execute_header
0000000100000ef0 T _main
                 U _multi
                 U _printf
                 U _sum
                 U dyld_stub_binder
```

sum, multi 함수가 U(Undefined) 로 표기되어 있어, main에 코드가 없음을 알 수 있습니다.

다음으로 동적 라이브러리 소스가 포함되지 않았는지 objdump 명령어로 확인합니다.

```
$ objdump -d main

main:	file format Mach-O 64-bit x86-64


Disassembly of section __TEXT,__text:

0000000100000ef0 _main:
100000ef0: 55                          	pushq	%rbp
100000ef1: 48 89 e5                    	movq	%rsp, %rbp
100000ef4: 48 83 ec 20                 	subq	$32, %rsp
100000ef8: c7 45 fc 00 00 00 00        	movl	$0, -4(%rbp)
100000eff: 89 7d f8                    	movl	%edi, -8(%rbp)
100000f02: 48 89 75 f0                 	movq	%rsi, -16(%rbp)
100000f06: c7 45 ec 0a 00 00 00        	movl	$10, -20(%rbp)
100000f0d: c7 45 e8 28 00 00 00        	movl	$40, -24(%rbp)
100000f14: 8b 7d ec                    	movl	-20(%rbp), %edi
100000f17: 8b 75 e8                    	movl	-24(%rbp), %esi
100000f1a: e8 47 00 00 00              	callq	71 <dyld_stub_binder+0x100000f66>
100000f1f: 48 8d 3d 74 00 00 00        	leaq	116(%rip), %rdi
100000f26: 89 c6                       	movl	%eax, %esi
100000f28: b0 00                       	movb	$0, %al
100000f2a: e8 31 00 00 00              	callq	49 <dyld_stub_binder+0x100000f60>
100000f2f: 8b 7d ec                    	movl	-20(%rbp), %edi
100000f32: 8b 75 e8                    	movl	-24(%rbp), %esi
100000f35: 89 45 e4                    	movl	%eax, -28(%rbp)
100000f38: e8 1d 00 00 00              	callq	29 <dyld_stub_binder+0x100000f5a>
100000f3d: 48 8d 3d 60 00 00 00        	leaq	96(%rip), %rdi
100000f44: 89 c6                       	movl	%eax, %esi
100000f46: b0 00                       	movb	$0, %al
100000f48: e8 13 00 00 00              	callq	19 <dyld_stub_binder+0x100000f60>
100000f4d: 31 c9                       	xorl	%ecx, %ecx
100000f4f: 89 45 e0                    	movl	%eax, -32(%rbp)
100000f52: 89 c8                       	movl	%ecx, %eax
100000f54: 48 83 c4 20                 	addq	$32, %rsp
100000f58: 5d                          	popq	%rbp
100000f59: c3                          	retq

Disassembly of section __TEXT,__stubs:

0000000100000f5a __stubs:
100000f5a: ff 25 a0 10 00 00           	jmpq	*4256(%rip)
100000f60: ff 25 a2 10 00 00           	jmpq	*4258(%rip)
100000f66: ff 25 a4 10 00 00           	jmpq	*4260(%rip)

Disassembly of section __TEXT,__stub_helper:

0000000100000f6c __stub_helper:
100000f6c: 4c 8d 1d a5 10 00 00        	leaq	4261(%rip), %r11
100000f73: 41 53                       	pushq	%r11
100000f75: ff 25 85 00 00 00           	jmpq	*133(%rip)
100000f7b: 90                          	nop
100000f7c: 68 00 00 00 00              	pushq	$0
100000f81: e9 e6 ff ff ff              	jmp	-26 <__stub_helper>
100000f86: 68 1b 00 00 00              	pushq	$27
100000f8b: e9 dc ff ff ff              	jmp	-36 <__stub_helper>
100000f90: 68 0d 00 00 00              	pushq	$13
100000f95: e9 d2 ff ff ff              	jmp	-46 <__stub_helper>


$ objdump -d libmath.so

libmath.so:	file format Mach-O 64-bit x86-64


Disassembly of section __TEXT,__text:

0000000000000f80 _sum:
     f80: 55                           	pushq	%rbp
     f81: 48 89 e5                     	movq	%rsp, %rbp
     f84: 89 7d fc                     	movl	%edi, -4(%rbp)
     f87: 89 75 f8                     	movl	%esi, -8(%rbp)
     f8a: 8b 45 fc                     	movl	-4(%rbp), %eax
     f8d: 03 45 f8                     	addl	-8(%rbp), %eax
     f90: 5d                           	popq	%rbp
     f91: c3                           	retq
     f92: 66 2e 0f 1f 84 00 00 00 00 00	nopw	%cs:(%rax,%rax)
     f9c: 0f 1f 40 00                  	nopl	(%rax)

0000000000000fa0 _multi:
     fa0: 55                           	pushq	%rbp
     fa1: 48 89 e5                     	movq	%rsp, %rbp
     fa4: 89 7d fc                     	movl	%edi, -4(%rbp)
     fa7: 89 75 f8                     	movl	%esi, -8(%rbp)
     faa: 8b 45 fc                     	movl	-4(%rbp), %eax
     fad: 0f af 45 f8                  	imull	-8(%rbp), %eax
     fb1: 5d                           	popq	%rbp
     fb2: c3                           	retq
```

## 정리

정적 라이브러리의 정적 링킹, 동적 라이브러리의 동적 링킹을 통해서 실행 파일에 어떻게 영향이 미치는지 확인해보았습니다.

정적 라이브러리의 정적 링킹으로 실행 파일에 포함이 됩니다.

동적 라이브러리의 동적 링킹으로 실행 파일에는 포함이 되지 않지만, 라이브러리 파일이 없으면 실행이 종료됩니다.

어떤 서비스 방향이냐에 따라 라이브러리의 방향을 결정하는 것이 좋을 것 같습니다.

![2]({{site.production_url}}/image/2020/07/20200725_2.gif)


## 참고

* Post
  * [GCC로 Dynamic Library 만들기](https://jihadw.tistory.com/134), [GCC로 Static Library 만들기](https://jihadw.tistory.com/133)
  * [[운영체제]Static Linking vs Dynamic Linking(shared Library) 정적링킹 vs 동적링킹](https://jhnyang.tistory.com/42)
  * [리눅스 동적 라이브러리 분석](https://www.kdata.or.kr/info/info_04_view.html?field=&keyword=&type=techreport&page=168&dbnum=128161&mode=detail&type=techreport)
  * [메모리 영역, 정적 메모리 할당, 동적 메모리 할당](http://blog.naver.com/PostView.nhn?blogId=parkjy76&logNo=220925369874)
  * [c 라이브러리 파일, gcc 컴파일](https://nicewoong.github.io/development/2018/02/24/c-library-gcc-compile/)
  * [GNU 바이너리 유틸리티 - GNU Binutils](https://techlog.gurucat.net/263)
  * [ELF format Object File에 관한 진실. -c option (기계어 세상)](http://recipes.egloos.com/5010841)

* Lecture
  * [The Structure of a C++ Program - Separate Compilation](https://www.cs.odu.edu/~zeil/cs333/website-s12/Lectures/cppProgramStructure/pages/ar01s01s03.html)

ps. OSX에서 기본 GCC가 LLVM이라고 알려주신 김정님꼐 감사드립니다.
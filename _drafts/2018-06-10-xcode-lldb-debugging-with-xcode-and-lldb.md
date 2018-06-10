---
layout: post
title: "[Xcode][LLDB]Debugging With Xcode and LLDB"
description: ""
category: ""
tags: []
---
{% include JB/setup %}

iOS 개발을 좀 더 잘하기 위해, 편하게 버그를 추적하기 위해 LLDB를 이용한 디버깅 방법을 기록합니다.

## **Execution Commands**

* **Continue** - 정지된 프로그램 실행을 재개함.

```
(lldb) continue
(lldb) c
```

* **Step Over** - 현재 선택된 스레드에서 소스 수준의 한 단계를 진행.

```
(lldb) thread step-over
(lldb) next
(lldb) n
```

* **Step Into** - 현재 선택된 스레드에서 소스 수준의 한 단계 안으로 들어감.

```
(lldb) thread step-in
(lldb) step
(lldb) s
```

* **Step Out** - 현재 선택된 Frame에서 벗어남.

```
(lldb) thread step-out
(lldb) finish
```

* **Instruction Level Step Into** - 현재 선택된 스레드에서 명령어 수준의 한 단계 안으로 들어감.

```
(lldb) thread step-inst
(lldb) si
```

* **Instruction Level Step Over** - 현재 선택된 스레드에서 명령어 수준의 한 단계를 진행.

```
(lldb) thread step-inst-over
(lldb) ni
```

## **Examining Variables** - 변수 검사

* **Frame Variable** - frame에 있는 변수를 출력함.

```
/// 현재 frame에 argument와 local 변수 출력하기.
(lldb) frame variable
(lldb) fr v

/// 현재 frame에 local 변수 출력하기
(lldb) frame variable --no-args
(lldb) fr v -a

/// local 변수 `bar` 내용 출력하기
(lldb) frame variable bar
(lldb) fr v bar
(lldb) p bar

/// local 변수 `bar`을 hex로 내용 출력하기
(lldb) frame variable --format x bar
(lldb) fr v -f x bar
```

* **Target Variable** - global/static 변수를 출력함.

```
/// global 변수 `baz` 내용 출력하기
(lldb) target variable baz
(lldb) ta v baz

/// 현재 소스 파일에서 정의된 global/static 변수 출력하기
(lldb) target variable
(lldb) ta v
```

* **Target Stop-hook / Display** - 매번 멈출 때 마다 지정된 명령 실행 / 멈출 때 마다 지정한 변수 내용을 출력

```
/// `frame variable argc argv` stop hook을 등록하기
(lldb) target stop-hook add --one-liner "frame variable argc argv"
(lldb) ta st a -o "fr v argc argv"

/// 멈출 때 마다 argc, argv 내용을 출력하기
(lldb) display argc
(lldb) display argv

/// `main` 함수 안에서 멈추면 argc, argv 내용을 출력하기
(lldb) target stop-hook add --name main --one-liner "frame variable argc argv"
(lldb) ta st a -n main -o "fr v argc argv"

/// C 클래스 이름인 MyClass 안에서 멈추면 *this 변수 내용을 출력하기
(lldb) target stop-hook add --classname MyClass --one-liner "frame variable *this"
(lldb) ta st a -c MyClass -o "fr v *this"

/// Multiple Line Hook 
(lldb) target stop-hook add
> bt
> disassemble --pc
> DONE
```

## **Examining Thread State** - 스레드 상태 검사

* **Thread List/Change** - 현재 스레드 목록을 보여줌 / 다른 스레드로 이동하기

```
/// 현재 스레드 목록을 보여주기
(lldb) thread list

/// Thread 2로 이동하기
(lldb) thread select 2
```

* **Until/Jump/Return** - 특정 줄까지 수행 후 멈춤 / 특정 주소/줄로 이동 / 현재 stack frame에서 특정 값을 반환(note: Swift에서는 거의 안됨)

```
/// 특정 줄까지 step over 수행함.(ex: 현재 줄이 10줄이고, 20줄 이전 까지 step over를 수행함.)
(lldb) thread until 20 // 19줄까지 step over, 20줄에서 멈춤

/// 특정 frame의 특정 소스 라인까지 수행함.(frame 2에서 10번째 줄 전 까지 수행)
(lldb) thread until --frame 2 10

/// 
```

* **Backtrace** - 스레드의 stack backtrace를 보여줌.

```
/// 현재 스레드의 stack backtrace를 보여주기
(lldb) thread backtrace
(lldb) bt

/// 모든 스레드의 stack backtrace를 보여주기
(lldb) thread backtrace all
(lldb) bt all

/// 현재 스레드의 frame에서 1~5번 backtrace를 보여주기
(lldb) thread backtrace -c 5
(lldb) bt 5

/// 현재 스레드에서 특정 stack frame index를 선택하기
(lldb) frame select 12
(lldb) fr s 12
(lldb) f 12

/// 현재 스레드에서 현재 선택된 frame의 정보 출력하기
(lldb) frame info
(lldb) fr info

/// 현재 선택된 stack frame에서 위 아래로 이동
(lldb) up
(lldb) up 3
(lldb) down
(lldb) down 5
```

## Expression

## 참고자료

* [Apple - LLDB Quick Start Guide](https://developer.apple.com/library/archive/documentation/IDEs/Conceptual/gdb_to_lldb_transition_guide/document/Introduction.html#//apple_ref/doc/uid/TP40012917-CH1-SW1)
* [UIKonf18 – Day 1 – Carola Nitz – Advanced Debugging Techniques](https://www.youtube.com/watch?v=578YdS2sNqk)
* [Advanced Debugging with Xcode and LLDB](https://developer.apple.com/videos/play/wwdc2018/412)
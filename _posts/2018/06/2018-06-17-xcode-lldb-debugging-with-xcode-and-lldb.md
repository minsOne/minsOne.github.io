---
layout: post
title: "[Xcode][LLDB]Debugging With Xcode and LLDB"
description: ""
category: "iOS/Mac"
tags: [Xcode, LLDB, lldb, debug, python]
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

* **Frame Variable** - 메모리에서 변수를 읽어 lldb 형태의 description을 출력함.

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

/// local 변수 `bar`을 hex로 내용 출력하기
(lldb) frame variable --format x bar
(lldb) fr v -f x bar

/// Object의 Description 출력하기
(lldb) frame variable -O self
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

* **Thread Until/Jump/Return** - 특정 줄 전까지 실행 후 멈춤 / 특정 주소/줄로 이동 / 현재 stack frame에서 특정 값을 반환(note: Swift에서는 거의 안됨)

```
/// 특정 줄까지 step over 수행함.(ex: 현재 줄이 10줄이고, 20줄 이전 까지 step over를 수행함.)
(lldb) thread until 20 // 19줄까지 step over, 20줄에서 멈춤

/// 특정 frame의 특정 소스 줄까지 수행함.(frame 2에서 10번째 줄 전 까지 수행)
(lldb) thread until --frame 2 10

/// 명령어 수준의 특정 주소까지 수행함
(lldb) disassemble --frame
(lldb) thread until --address 0x1023653a0

/// 특정 소스라인까지 이동함.
(lldb) thread jump --line 10 // 10번째 줄으로 이동
(lldb) thread jump --by 5 // 현재 줄에서 +5번째 줄로 이동
(lldb) thread jump --by -5 // 현재 줄에서 -5번째 줄로 이동

/// 현재 frame에서 Void를 반환하거나 특정 값을 반환(note: Swift에서는 거의 안됨)
(lldb) thread return 
(lldb) thread return 0
(lldb) thread return "aa"
error: Error returning from frame 0 of thread 1: We only support setting simple integer and float return types at present..
```

* **Disassemble**

```
/// 현재 frame의 현재 함수를 disassemble하여 보여줌.
(lldb) disassemble --frame
(lldb) di -f

/// main 이라는 함수를 disassemble하여 보여줌.
(lldb) disassemble --name main
(lldb) di -n main

/// 지정된 주소범위의 명령어 코드를 출력함.
(lldb) disassemble --start-address 0x1eb8 --end-address 0x1ec3
(lldb) di -s 0x1eb8 -e 0x1ec3

/// 시작 주소부터 20개의 명령어를 출력함.
(lldb) disassemble --start-address 0x1eb8 --count 20
(lldb) di -s 0x1eb8 -c 20

/// 현재 frame의 코드에 해당하는 명령어를 코드와 같이 출력함.
(lldb) disassemble --frame --mixed
(lldb) di -f -m

/// 현재 frame에 현재 소스 코드 라인을 disassemble하여 보여줌.
(lldb) disassemble --line
(lldb) di -l
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

## Evaluatiing Expression - 표현식 계산하기

* 현재 frame에서 표현식 계산하기

```
(lldb) expression print(1 + 2)
(lldb) expr print(1 + 2)
(lldb) e print(1 + 2)

(lldb) expression -- print(1 + 2)
(lldb) print print(1 + 2)
(lldb) p print(1 + 2)
```

* LLDB에서 변수를 선언하기

```
(lldb) expr var $foo = 10
(lldb) expr print($foo) // Output: 10
(lldb) expr $foo += 1
(lldb) expr print($foo) // Output: 11
```

* Objc 객체의 description 보여주기

```
(lldb) expr --object-description -- object
(lldb) expr -o -- object
(lldb) po object
```

* 특정 메모리 주소의 값을 출력하기

```
/// Swift
(lldb) expr -l swift -- import UIKit
(lldb) expr -l swift -- let $vc = unsafeBitCast(0x7fe75a70bb40, to: ViewController.self)
(lldb) po $vc

/// Objc
(lldb) expr -l objc -- @import UIKit
(lldb) expr -l objc -- ViewController *$vc = (ViewController *)0x7fe75a70bb40
(lldb) po $vc

/// 실행 중에 Pause를 한 후, 특정 메모리 주소의 값을 확인하는 경우
(lldb) expr -l Swift --
Enter expressions, then terminate with an empty line to evaluate:
1 let $vc = unsafeBitCast(0x7fe75a70bb40, to: ViewController.self)
2 print($vc)
3

/// 위 명령들을 축약
(lldb) expr import UIKit 
(lldb) p import UIKit 
(lldb) expr let $vc = unsafeBitCast(0x7fe75a70bb40, to: ViewController.self)
(lldb) po $vc
<SomeProject.ViewController: 0x7fe75a70bb40>
```

* 임의의 UIViewController 생성하여 NavigationViewController에 Push하기

```
(lldb) expr var $vc = UIViewController()
(lldb) expr $vc.view.backgroundColor = UIColor.red
(lldb) expr self.navigationController?.pushViewController($vc, animated: true)
```

* Printing Modes

  * `frame variable (f v)` - Code를 실행하지 않으며, LLDB formatter를 사용
  * `expression -- (p)` - Code를 실행하며, LLDB formatter를 사용
  * `expression -O -- (po)` - Code를 실행하며, `debugDescription`와 같이 개발자가 만든 출력 형태를 사용

## BreakPoint - BreakPoint 설정하기

```
/// viewDidLoad 이름인 모든 함수에 breakpoint를 설정하기 - Swift
(lldb) breakpoint set --name viewDidLoad
(lldb) br s -n viewDidLoad
(lldb) b viewDidLoad

/// viewDidLoad 이름인 모든 함수에 breakpoint를 설정하기 - Objc
(lldb) breakpoint set --name "-[UIViewController viewDidLoad]"

/// 특정 파일 특정 줄에 breakpoint 설정하기
(lldb) breakpoint set --file test.c --line 12
(lldb) br s -f test.c -l 12
(lldb) b test.c:12

/// 현재 파일의 특정 줄에 breakpoint 설정하기
(lldb) breakpoint set --line 12
(lldb) br s -l 12
(lldb) b 12

/// 특정 이름을 가진 Select에 breakpoint 설정하기
(lldb) breakpoint set --selector dealloc

/// breakpoint에 global이 5이면 중단되도록 조건 설정
(lldb) b 12
(lldb) breakpoint modify -c "global == 5"

/// breakpoint 목록 보기
(lldb) breakpoint list
(lldb) br l

/// breakpoint 지우기
(lldb) breakpoint delete 1
(lldb) br del 1
```

## Watchpoint - 변수에 값이 기록될 때마다 중단되도록 설정

```
/// 전역 변수에 watchpoint 설정
(lldb) watchpoint set variable global_var
(lldb) wa s v global_var

/// 메모리 주소에 watchpoint 설정
(lldb) watchpoint set expression -- my_ptr
(lldb) wa s e -- my_ptr

/// watchpoint에 global이 5이면 중단되도록 조건 설정
(lldb) watch set var global
(lldb) watchpoint modify -c "global == 5"

/// watchpoint 목록 보기
(lldb) watchpoint list
(lldb) watch l

/// watchpoint 지우기
(lldb) watchpoint delete 1
(lldb) watch del 1
```

## Script - Python REPL

* Python을 LLDB Script로 사용할 수 있음.

```
(lldb) script print 1 + 2 // Output: 3
(lldb) script import os
(lldb) script print os.getcwd()
```

* import - 필요한 script 소스를 import하여 사용함.

```
(lldb) command script import ~/myCommands.py
```

또는 /.lldbinit 파일 내에 `command script import ~/myCommands.py` 를 추가함.

## 기타

```
/// 특정 키워드의 상세한 설명을 보여줌
(lldb) apropos keyword

/// 기본 언어 설정을 바꿈
(lldb) settings set target.language swift

/// Alias 설정
(lldb) command alias es expression -l swift --
```

## LLDB 확장 툴

* [Chisel](https://github.com/facebook/chisel) - python으로 대부분 작성되어 있으며, View Debugging 관련하여 손쉽게 사용할 수 있도록 도와주며, [여기](https://kapeli.com/cheat_sheets/LLDB_Chisel_Commands.docset/Contents/Resources/Documents/index)에서 많은 명령을 살펴볼 수 있음.
* [DerekSelander - LLDB](https://github.com/DerekSelander/LLDB) - A collection of LLDB aliases/regexes and Python scripts to aid in your debugging sessions


## 참고자료

* [Apple - LLDB Quick Start Guide](https://developer.apple.com/library/archive/documentation/IDEs/Conceptual/gdb_to_lldb_transition_guide/document/Introduction.html#//apple_ref/doc/uid/TP40012917-CH1-SW1)
* [UIKonf18 – Day 1 – Carola Nitz – Advanced Debugging Techniques](https://www.youtube.com/watch?v=578YdS2sNqk)
* [Advanced Debugging with Xcode and LLDB](https://developer.apple.com/videos/play/wwdc2018/412)
* [Chisel](https://github.com/facebook/chisel)
* [LLDB Chisel Commands](https://kapeli.com/cheat_sheets/LLDB_Chisel_Commands.docset/Contents/Resources/Documents/index)
* [More than `po`: Debugging in lldb](https://www.slideshare.net/micheletitolo/more-than-po-debugging-in-lldb)
* [Debugging RubyMotion applications](http://ruby-korea.github.io/RubyMotionDocumentation/articles/debugging/)
* [Xcode LLDB 디버깅 테크닉](https://www.letmecompile.com/xcode-lldb-%EB%94%94%EB%B2%84%EA%B9%85-%ED%85%8C%ED%81%AC%EB%8B%89/)
* [LLDB Debugging Cheat Sheet](https://gist.github.com/alanzeino/82713016fd6229ea43a8)
* [Debugging a Debugger](http://idrisr.com/2015/10/12/debugging-a-debugger.html)
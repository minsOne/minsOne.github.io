---
layout: post
title: "[Swift] Defer를 이용하여 Closure 실행 보장하기"
tags: [Swift, defer, closure]
---
{% include JB/setup %}

Swift의 Closure는 함수의 매개변수로 전달하고 받을 수 있습니다. Closure를 전달하는 곳에서는 받는 곳에서 Closure를 수행할 것으로 예상합니다.

```swift
func sampleFunc(closure: (String) -> Void) {
    closure("Hello World")
}

sampleFunc { print($0) } // Print: Hello World
```

하지만, 개발자의 실수로 Closure가 수행되지 않을 수 있습니다.

```swift
func sampleFunc(closure: (String) -> Void) {}

sampleFunc { print($0) } // Nothing
```

특히, 비지니스 로직이 복잡한 경우(ex. 네트워크 처리 등), 작업을 하다가 예외 경우에서 종종 Closure를 호출하는 것을 깜빡하기도 합니다.

## Defer

다음과 같이 네트워크 상태에 따른 Closure 호출하는 코드를 작성할 수 있습니다.

```swift
func result(status: Int, completion: (Int) -> Void) {
    if status == 200 {
        completion(0)
        return
    }
    
    if status == 400 {
        completion(1)
        return
    }
    
    completion(-1)
}
```

위의 코드에서 마지막 `completion` Closure는 개발자의 실수로 호출되지 않을 수 있습니다. 특히, 리팩토링 작업을 진행할 때, `completion` Closure를 누락할 수 있습니다.

이런 경우, `completion` Closure를 호출하는 코드를 `defer` 키워드를 이용해 보장할 수 있습니다.

```swift
func result(status: Int, completion: (Int) -> Void) {
    let value: Int
    defer { completion(value) }
    
    if status == 200 {
        value = 0
        return
    }
    
    if status == 400 {
        value = 1
        return
    }
    
    value = -1
}
```

`let`을 통해 값을 항상 초기화하고, `defer` 키워드를 통해 `completion` Closure를 호출합니다. 만약, value에 값을 할당하지 않는다면, 컴파일러가 에러를 발생시키고, 개발자는 빌드할 수 없습니다. value에 값을 반드시 할당해야 하며, 따라서 `completion` Closure를 호출을 보장할 수 있습니다.

이와 같은 방식은 복잡한 것처럼 보이기 때문에, 컴파일시 코드가 많을 것으로 생각되지만, 실제로는 그렇게까지 코드가 늘어나지 않습니다.

앞의 두 코드를 `godbolt`를 통해 컴파일한 결과를 비교해봅시다. - [링크](https://godbolt.org/z/dEhrs1Gne)

첫번째 코드의 어셈블리 코드입니다. - x86-64 Swiftc 5.10

```asm
output.result(status: Swift.Int, completion: (Swift.Int) -> ()) -> ():
        push    rbp
        mov     rbp, rsp
        push    r13
        sub     rsp, 56
        mov     qword ptr [rbp - 48], rdx
        mov     qword ptr [rbp - 56], rsi
        mov     qword ptr [rbp - 40], rdi
        lea     rdi, [rbp - 16]
        xor     esi, esi
        mov     edx, 8
        call    memset@PLT
        lea     rdi, [rbp - 32]
        xor     esi, esi
        mov     edx, 16
        call    memset@PLT
        mov     rsi, qword ptr [rbp - 56]
        mov     rdx, qword ptr [rbp - 48]
        mov     rdi, qword ptr [rbp - 40]
        mov     qword ptr [rbp - 16], rdi
        mov     qword ptr [rbp - 32], rsi
        mov     qword ptr [rbp - 24], rdx
        cmp     rdi, 200
        jne     .LBB1_2
        mov     rax, qword ptr [rbp - 56]
        mov     r13, qword ptr [rbp - 48]
        xor     ecx, ecx
        mov     edi, ecx
        call    rax
        jmp     .LBB1_5
.LBB1_2:
        mov     rax, qword ptr [rbp - 40]
        cmp     rax, 400
        jne     .LBB1_4
        mov     rax, qword ptr [rbp - 56]
        mov     r13, qword ptr [rbp - 48]
        mov     edi, 1
        call    rax
        jmp     .LBB1_5
.LBB1_4:
        mov     rax, qword ptr [rbp - 56]
        mov     r13, qword ptr [rbp - 48]
        mov     rdi, -1
        call    rax
.LBB1_5:
        add     rsp, 56
        pop     r13
        pop     rbp
        ret
```

defer를 사용한 두 번째 코드의 어셈블리 코드입니다. - x86-64 Swiftc 5.10

```asm
output.result(status: Swift.Int, completion: (Swift.Int) -> ()) -> ():
        push    rbp
        mov     rbp, rsp
        sub     rsp, 64
        mov     qword ptr [rbp - 48], rdx
        mov     qword ptr [rbp - 56], rsi
        mov     qword ptr [rbp - 40], rdi
        lea     rdi, [rbp - 8]
        xor     esi, esi
        mov     edx, 8
        call    memset@PLT
        lea     rdi, [rbp - 24]
        xor     esi, esi
        mov     edx, 16
        call    memset@PLT
        lea     rdi, [rbp - 32]
        xor     esi, esi
        mov     edx, 8
        call    memset@PLT
        mov     rsi, qword ptr [rbp - 56]
        mov     rdx, qword ptr [rbp - 48]
        mov     rdi, qword ptr [rbp - 40]
        mov     qword ptr [rbp - 8], rdi
        mov     qword ptr [rbp - 24], rsi
        mov     qword ptr [rbp - 16], rdx
        cmp     rdi, 200
        jne     .LBB1_2
        mov     rsi, qword ptr [rbp - 48]
        mov     rdi, qword ptr [rbp - 56]
        mov     qword ptr [rbp - 32], 0
        xor     eax, eax
        mov     edx, eax
        call    ($defer #1 () -> () in output.result(status: Swift.Int, completion: (Swift.Int) -> ()) -> ())
        jmp     .LBB1_5
.LBB1_2:
        mov     rax, qword ptr [rbp - 40]
        cmp     rax, 400
        jne     .LBB1_4
        mov     rsi, qword ptr [rbp - 48]
        mov     rdi, qword ptr [rbp - 56]
        mov     qword ptr [rbp - 32], 1
        mov     edx, 1
        call    ($defer #1 () -> () in output.result(status: Swift.Int, completion: (Swift.Int) -> ()) -> ())
        jmp     .LBB1_5
.LBB1_4:
        mov     rsi, qword ptr [rbp - 48]
        mov     rdi, qword ptr [rbp - 56]
        mov     qword ptr [rbp - 32], -1
        mov     rdx, -1
        call    ($defer #1 () -> () in output.result(status: Swift.Int, completion: (Swift.Int) -> ()) -> ())
.LBB1_5:
        add     rsp, 64
        pop     rbp
        ret

$defer #1 () -> () in output.result(status: Swift.Int, completion: (Swift.Int) -> ()) -> ():
        push    rbp
        mov     rbp, rsp
        push    r13
        sub     rsp, 40
        mov     qword ptr [rbp - 48], rdx
        mov     r13, rsi
        mov     rax, rdi
        mov     rdi, qword ptr [rbp - 48]
        xorps   xmm0, xmm0
        movaps  xmmword ptr [rbp - 32], xmm0
        mov     qword ptr [rbp - 40], 0
        mov     qword ptr [rbp - 32], rax
        mov     qword ptr [rbp - 24], r13
        mov     qword ptr [rbp - 40], rdi
        call    rax
        add     rsp, 40
        pop     r13
        pop     rbp
        ret
```

두 번째 코드에서는 함수가 종료되기 전에 모두 defer를 호출한다는 것을 확인할 수 있으며, defer에 있는 closure를 호출한다는 것을 알 수 있습니다.
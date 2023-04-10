---
layout: post
title: "[Swift][Objective-C] 클래스 메서드 load()를 활용하여 반복하는 초기화 작업을 줄이기"
tags: [Swift, NSObject, load, Objective-C, AppDelegate, Objc, objc4, dyld]
---
{% include JB/setup %}

일반적으로 개발자는 특정 객체나 값을 초기화하는 코드를 `AppDelegate` 클래스의 `UIApplicationDelegate`의 `application(_:didFinishLaunchingWithOptions:)` [함수](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622921-application)에서 작성합니다.

그 이유는 애플리케이션의 시작 지점이기 때문입니다. 물론, main 함수에서 제어도 가능하지만, 대개 `application(_:didFinishLaunchingWithOptions:)` 함수가 시작 지점으로 사용합니다.

그렇다보니, 초기화 작업이 많은 코드가 들어가면서 복잡도가 증가하는 문제가 있습니다. 또한, 앱이 하나인 경우는 괜찮지만, 각 기능별이나 상품별 데모 앱이 존재하는 경우에는 무수히 많은 `AppDelegate` 클래스가 추가될 수 있고, 각 클래스에서 `application(_:didFinishLaunchingWithOptions:)` 함수에서 초기화 작업을 하는 코드가 중복되며 계속 늘어날 것입니다.

하지만, 각 기능별, 상품별 데모앱들이 개발 및 내부 배포에만 사용된다면, 초기화 작업을 런타임에서 자동으로 호출할 수 있는 (비)공식적인 방법을 사용하여 `application(_:didFinishLaunchingWithOptions:)` 함수에서 작성하는 초기화 코드의 양을 줄일 수 있습니다. 이렇게 하면 각 데모앱마다 작성해야 하는 초기화 코드가 줄어들게 됩니다.

Swift 언어에서는 런타임 활용에 제한이 있지만, Objective-C 언어는 더 다양한 기능을 Runtime을 이용해 구현할 수 있습니다.

## NSObject의 클래스 메서드 load 

`NSObject` 클래스의 클래스 메서드인 [`load()`](https://developer.apple.com/documentation/objectivec/nsobject/1418815-load)는 해당 클래스가 메모리에 로드될 때 호출됩니다.  이러한 동작 방식으로, 클래스 메서드 `load()`가 `AppDelegate` 의 `application(_:didFinishLaunchingWithOptions:)` 함수보다 먼저 호출된다는 의미입니다.

그러면 클래스 메서드 `load`를 구현해봅시다.

```objc
/// FileName : AutoLoadClass.m

#import <Foundation/Foundation.h>

@interface AutoLoadClass : NSObject
@end

@implementation AutoLoadClass : NSObject

+ (void)load {
    NSLog(@"Hello AutoLoadClass Loaded");
}
@end
```

해당 코드의 목적은 문서에서 설명한 것과 같이 클래스 메서드 `load`가 동작하는지 확인하는 것입니다. 따라서 별도의 헤더 파일을 추가하지 않았습니다. 

코드를 실행하면 출력 결과는 다음과 같습니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2023/04/01.png" style="width: 600px; border: 1px solid #555;"/></p><br/>

클래스 메서드 `load`에 중단점을 설정하였을 때, 보여지는 Call Stack입니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2023/04/02.png" style="width: 600px; border: 1px solid #555;"/></p><br/>

`AppDelegate`의 `application(_:didFinishLaunchingWithOptions:)` 함수보다 먼저 호출된 것을 확인할 수 있습니다.

그리고 Call Stack에서 `load_images`, `dyld4` 관련 코드들이 보입니다.

클레스 메서드 `load`가 호출된 정확한 부분을 찾도록 Call Stack에서 load_images를 눌러봅니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2023/04/03.png" style="width: 600px; border: 1px solid #555;"/></p><br/>

어셈블리어 코드를 확인할 수 있습니다.

가장 위의 어셈블리어 코드를 보면 "LOAD: +[%s load]\n" 이라는 문자열을 확인할 수 있습니다.

`load_images`는 objc 관련 코드이므로, 해당 코드는 애플에서 공개한 [apple-oss-distributions/objc4](https://github.com/apple-oss-distributions/objc4) 저장소에서 확인할 수 있습니다.

objc4 저장소에서 "LOAD: +[%s load]\n" 문자열을 검색하여 다음과 같은 코드를 찾아낼 수 있었습니다. [코드](https://github.com/apple-oss-distributions/objc4/blob/689525d556eb3dee1ffb700423bccf5ecc501dbf/runtime/objc-loadmethod.mm#L202)

```objc
// FileName : runtime/objc-loadmethod.mm

static void call_class_loads(void)
{
    int i;
    
    // Detach current loadable list.
    struct loadable_class *classes = loadable_classes;
    int used = loadable_classes_used;
    loadable_classes = nil;
    loadable_classes_allocated = 0;
    loadable_classes_used = 0;
    
    // Call all +loads for the detached list.
    for (i = 0; i < used; i++) {
        Class cls = classes[i].cls;
        load_method_t load_method = (load_method_t)classes[i].method;
        if (!cls) continue; 

        if (PrintLoading) {
            _objc_inform("LOAD: +[%s load]\n", cls->nameForLogging());
        }
        (*load_method)(cls, @selector(load));
    }
    
    // Destroy the detached list.
    if (classes) free(classes);
}
```

여기에서 클래스 메서드인 `load`가 호출된다는 것을 확인할 수 있었습니다.

그리고 `call_class_loads` 함수는 `call_load_methods` 함수에서 호출하고 있습니다. [코드](https://github.com/apple-oss-distributions/objc4/blob/689525d556eb3dee1ffb700423bccf5ecc501dbf/runtime/objc-loadmethod.mm#L337)

```objc
// FileName : runtime/objc-loadmethod.mm
void call_load_methods(void)
{
    static bool loading = NO;
    bool more_categories;

    lockdebug::assert_locked(&loadMethodLock);

    // Re-entrant calls do nothing; the outermost call will finish the job.
    if (loading) return;
    loading = YES;

    void *pool = objc_autoreleasePoolPush();

    do {
        // 1. Repeatedly call class +loads until there aren't any more
        while (loadable_classes_used > 0) {
            call_class_loads();
        }

        // 2. Call category +loads ONCE
        more_categories = call_category_loads();

        // 3. Run more +loads if there are classes OR more untried categories
    } while (loadable_classes_used > 0  ||  more_categories);

    objc_autoreleasePoolPop(pool);

    loading = NO;
}
```

`call_load_methods` 함수는 `objc-runtime-new.mm` 의 `load_images` 함수에서 호출하는 것을 확인할 수 있습니다. [코드](https://github.com/apple-oss-distributions/objc4/blob/689525d556eb3dee1ffb700423bccf5ecc501dbf/runtime/objc-runtime-new.mm#L3270)

```objc
void
load_images(const char *path __unused, const struct mach_header *mh)
{
    if (!didInitialAttachCategories && didCallDyldNotifyRegister) {
        didInitialAttachCategories = true;
        loadAllCategories();
    }

    // Return without taking locks if there are no +load methods here.
    if (!hasLoadMethods((const headerType *)mh)) return;

    recursive_mutex_locker_t lock(loadMethodLock);

    // Discover load methods
    {
        mutex_locker_t lock2(runtimeLock);
        prepare_load_methods((const headerType *)mh);
    }

    // Call +load methods (without runtimeLock - re-entrant)
    call_load_methods();
}
```

클래스 메서드 `load`가 호출될 때 Call Stack에 보여진 load_images 함수가 어떤 것인지, 어떻게 호출되는지 알게 되었습니다.

그리고 dyld4 관련 코드는 [apple-oss-distributions/dyld](https://github.com/apple-oss-distributions/dyld) 저장소에서 찾을 수 있습니다.

## 클래스 메서드 load 확장

클래스 메서드 `load`가 언제 어떻게 호출되는지 알게 되었습니다. 클래스 메서드 `load`에서는 간단한 작업을 수행하는 것이 좋습니다. 그렇지 않으면 `AppDelegate`의 `application(_:didFinishLaunchingWithOptions:)` 함수가 늦게 호출됩니다.

만약 개발 및 내부에서만 사용하는 앱이라면, 클래스 메서드 `load`에서 초기화 작업을 수행한다면, 기능 개발시 만드는 `데모앱`의 `AppDelegate` 클래스의 `application(_:didFinishLaunchingWithOptions:)` 함수에서 초기화 작업을 수행하지 않아도 됩니다. 이러면 반복해서 작성하던 보일러 플레이트 코드를 더 이상 작성하지 않아도 됩니다.

<div class="mermaid" style="display:flex;justify-content:center;">
graph TD;
    id1[(Application)]-->id2[AFramework]
    id1[(Application)]-->id3[BFramework]
    id1[(Application)]-->id4[CFramework]
    id20[(ADemoApp)]-->id2[AFramework]
    id30[(BDemoApp)]-->id3[BFramework]
    id40[(CDemoApp)]-->id4[CFramework]
    style id1 fill:#03bfff
    style id2 fill:#ffba0c
    style id3 fill:#ff7357
    style id4 fill:#64ff55
    style id20 fill:#44ffa6
    style id30 fill:#44ffa6
    style id40 fill:#44ffa6
</div><br/>

위와 같은 상황에서는 4개의 `AppDelegate` 클래스의 `application(_:didFinishLaunchingWithOptions:)` 함수에서 초기화 작업을 수행해야합니다.

각 프레임워크에서 `AutoLoadClass` 클래스를 추가하고, 클래스 메서드 `load`에서 Swift 코드의 초기화 작업을 수행합니다. 이렇게 하면 각 데모앱에서 보일러 플레이트 코드를 반복해서 작성할 필요 없이 초기화 작업을 런타임에서 자동으로 수행할 수 있습니다.

```swift
/// ModuleName : AFramework
/// FileName : Hello.swift

import Foundation

@objc
public class Hello: NSObject {
    @objc
    public static func world() {
        print("Hello world")
    }
}
```

```objc
/// ModuleName : AFramework
/// FileName : AutoLoadClass.m

#import <Foundation/Foundation.h>
#import <AFramework/AFramework-Swift.h>

@interface AutoLoadClass : NSObject
@end

@implementation AutoLoadClass : NSObject

+ (void)load {
    [Hello world];
    NSLog(@"Hello AutoLoadClass Loaded");
}
```

위 코드를 실행하면 `Objective-C`에서 작성된 코드에서 `Swift` 클래스의 메서드를 호출하는 것을 확인할 수 있었습니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2023/04/04.png" style="width: 600px; border: 1px solid #555;"/></p><br/>

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2023/04/05.png" style="width: 600px; border: 1px solid #555;"/></p><br/>

## 정리

* `NSObject`의 클래스 메서드 `load`를 적절히 활용하면 반복되는 코드를 줄이고, 초기화 작업 등을 효율적으로 처리할 수 있습니다.

## 참고자료

* Apple Document
  * [Type Method - load()](https://developer.apple.com/documentation/objectivec/nsobject/1418815-load)

* GitHub
  * [apple-oss-distributions/dyld](https://github.com/apple-oss-distributions/dyld)
  * [apple-oss-distributions/objc4](https://github.com/apple-oss-distributions/objc4)
  * [firebase/firebase-ios-sdk](https://github.com/firebase/firebase-ios-sdk/blob/8badb28bf2727941c3e4b41fab87905de8595ca4/FirebaseAuth/Sources/Auth/FIRAuth.m#L435)

* [mikeash.com - Friday Q&A 2009-05-22: Objective-C Class Loading and Initialization](https://www.mikeash.com/pyblog/friday-qa-2009-05-22-objective-c-class-loading-and-initialization.html)
* [+load VS +initialize](https://medium.com/@kostiakoval/load-vs-initialize-a1b3dc7ad6eb)
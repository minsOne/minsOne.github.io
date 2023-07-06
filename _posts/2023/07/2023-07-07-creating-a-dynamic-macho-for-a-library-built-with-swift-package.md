---
layout: post
title: "[Swift][SwiftPM] Swift Package의 라이브러리를 Dynamic Framework로 만들기"
tags: [Swift, SwiftPM, SPM, Package, Framework, Library, Dynamic Framework, Static Library]
---
{% include JB/setup %}

일반적으로 Swift Package로 만든 라이브러리의 `Mach-O`의 기본값은 `Static` 입니다. `Dynamic` 으로 변경하려면 type을 `.dynamic` 으로 변경해야합니다.

```swift
// FileName : Package.swift
let package = Package(
    name: "MyLibrary",
    products: [
        .library(name: "MyLibrary", type: .dynamic, targets: ["MyLibrary"]),
    ],
    ...
)
```

위와 같이 type에 `dynamic`으로 값을 지정해야하는 경우는 `Mach-O`가 `Static`, `Dynamic`인 라이브러리를 각각 만들어야 합니다.

```swift
// FileName : Package.swift
let package = Package(
    name: "MyLibrary",
    products: [
        .library(name: "MyLibrary", targets: ["MyLibrary"]),
        .library(name: "MyLibrary-Dynamic", type: .dynamic, targets: ["MyLibrary"]),
    ],
    ...
)
```

`Mach-O`를 Dynamic으로 설정해야하는 이유는, 여러 Dynamic Framework에서 해당 라이브러리를 사용해야하기 때문입니다. 만약 `Mach-O`를 Static인 라이브러리를 의존하게 되면, 복사가 일어나기 때문입니다.

그래서 별도의 `Mach-O`가 `Dynamic` 인 라이브러리를 만들게 되었습니다.

---

Xcode 12.5에서는 라이브러리 코드 중복이 발생하는 경우, 패키지의 라이브러리를 Dynamic Framework로 만들어준다고 합니다. [Xcode 12.5 Release Note](https://developer.apple.com/documentation/xcode-release-notes/xcode-12_5-release-notes#Swift-Packages)

```
The Swift Package Manager now builds package products and targets as dynamic frameworks automatically, if doing so avoids duplication of library code at runtime. (59931771) (FB7608638)
```

즉, 여러 Dynamic 라이브러리가 패키지의 `type`이 `static`으로 설정된 라이브러리를 의존한다면, Dynamic Framework로 빌드한다는 의미입니다.

<div class="mermaid" style="display:flex;justify-content:center;"> 
graph TD;
    id1[Application]-->id2[AFramework]
    id1[Application]-->id3[BFramework]
    id2-->id4(MyLibrary)
    id3-->id4(MyLibrary)
    style id1 fill:#03bfff
    style id2 fill:#ffba0c
    style id3 fill:#ffba0c
    style id4 fill:#ff5116
</div>

위의 의존관계에서 `AFramework`, `BFramework`는 `MyLibrary`를 의존하고 있어, `MyLibrary`는 Static Library로 빌드하지 않고, **Dynamic Framework**를 만들 것입니다.

정말로 그렇게 되는지는 널리 사용하는 오픈소스를 사용하여 그렇게 동작하는지 확인해보려고 합니다.<br/><br/>

## Swift Package의 라이브러리를 Dynamic Framework로 만들기

**[RxSwift](https://github.com/reactiveX/RxSwift)**는 별도의 Dynamic 라이브러리를 추가해놓은 대표적인 오픈소스입니다. 

RxSwift의 [Package.swift](https://github.com/ReactiveX/RxSwift/blob/main/Package.swift) 파일을 살펴봅시다.

```swift
let package = Package(
  name: "RxSwift",
  platforms: [.iOS(.v9), .macOS(.v10_10), .watchOS(.v3), .tvOS(.v9)],
  products: ([
    [
      .library(name: "RxSwift", targets: ["RxSwift"]),
      .library(name: "RxCocoa", targets: ["RxCocoa"]),
      .library(name: "RxRelay", targets: ["RxRelay"]),
      .library(name: "RxBlocking", targets: ["RxBlocking"]),
      .library(name: "RxTest", targets: ["RxTest"]),
      .library(name: "RxSwift-Dynamic", type: .dynamic, targets: ["RxSwift"]),
      .library(name: "RxCocoa-Dynamic", type: .dynamic, targets: ["RxCocoa"]),
      .library(name: "RxRelay-Dynamic", type: .dynamic, targets: ["RxRelay"]),
      .library(name: "RxBlocking-Dynamic", type: .dynamic, targets: ["RxBlocking"]),
      .library(name: "RxTest-Dynamic", type: .dynamic, targets: ["RxTest"]),
    ],
...
```

RxSwift는 Dynamic 라이브러리를 별도로 구현하고 있는 것을 확인할 수 있습니다.

하지만, 우리는 Dynamic 라이브러리를 사용하지 않고, Static 라이브러리만 사용하여 동적 프레임워크를 만드는지 검증할 것입니다.<br/><br/>

예제 프로젝트를 통해서 검증해보도록 합시다.

첫 번째로, AFramework에서만 `RxSwift`, `RxCocoa`, `RxRelay` 라이브러리를 의존하도록 추가합니다.

<p style="text-align:left;"><img src="{{ site.dev_url }}/image/2023/07/01.png" style="width: 600px; border: 1px solid #555;"/></p><br/>


그러면 AFramework에 라이브러리 코드가 복사됩니다. `nm` 을 이용하여 `RxSwift`, `RxCocoa`, `RxRelay` 라이브러리가 AFramework.framework/AFramework에 복사된 것을 확인합니다.

```shell
$ nm ~/Library/Developer/Xcode/DerivedData/SampleApp-adywyzvbmjimpfcinuscwqubgslf/Build/Products/Debug-iphonesimulator/SampleApp.app/Frameworks/AFramework.framework/AFramework
00000000001eba98 t +[RXObjCRuntime initialize]
00000000001eba7c t +[RXObjCRuntime instance]
00000000001ebdf0 t +[RXObjCRuntime registerOptimizedObserver:encodedAs:]
00000000001d6ae4 t +[RXObjCRuntime(swizzle) example_void]
00000000001deecc t +[RXObjCRuntime(swizzle) example_void_SEL:]
00000000001d7ecc t +[RXObjCRuntime(swizzle) example_void_char:]
00000000001de4d0 t +[RXObjCRuntime(swizzle) example_void_double:]
00000000001ddad4 t +[RXObjCRuntime(swizzle) example_void_float:]
00000000001d72d4 t +[RXObjCRuntime(swizzle) example_void_id:]
00000000001e9970 t +[RXObjCRuntime(swizzle) example_void_id:_SEL:]
00000000001e07b4 t +[RXObjCRuntime(swizzle) example_void_id:_char:]
...
```

AFramework, BFramework 둘다 `RxSwift`, `RxCocoa`, `RxRelay`를 의존한다면 어떻게 될까요? 

BFramework에서도 `RxSwift`, `RxCocoa`, `RxRelay` 라이브러리를 의존하도록 추가합니다.

<p style="text-align:left;"><img src="{{ site.dev_url }}/image/2023/07/02.png" style="width: 600px; border: 1px solid #555;"/></p><br/>

빌드된 결과물인 SampleApp.app의 Frameworks에 있는 AFramework, BFramework을 분석해봅시다.

<p style="text-align:left;"><img src="{{ site.dev_url }}/image/2023/07/03.png" style="width: 600px; border: 1px solid #555;"/></p><br/>

AFramework를 `nm`으로 분석했을 때, `RxSwift`, `RxCocoa`, `RxRelay` 라이브러리 코드가 복사되지 않았음을 확인할 수 있습니다.

```shell
$ nm ~/Library/Developer/Xcode/DerivedData/SampleApp-adywyzvbmjimpfcinuscwqubgslf/Build/Products/Debug-iphonesimulator/SampleApp.app/Frameworks/AFramework.framework/AFramework
0000000000002f10 T _$s10AFramework8AServiceVACycfC
0000000000003e08 s _$s10AFramework8AServiceVMF
0000000000002f14 T _$s10AFramework8AServiceVMa
0000000000004008 s _$s10AFramework8AServiceVMf
0000000000003de4 S _$s10AFramework8AServiceVMn
0000000000004018 S _$s10AFramework8AServiceVN
0000000000003dd8 s _$s10AFrameworkMXM
                 U _$sytWV
0000000000003db8 S _AFrameworkVersionNumber
0000000000003d88 S _AFrameworkVersionString
...
```

마찬가지로, BFramework도 `nm`으로 분석했을 때, `RxSwift`, `RxCocoa`, `RxRelay` 라이브러리 코드가 복사되지 않았음을 확인할 수 있습니다.

```shell
$ nm ~/Library/Developer/Xcode/DerivedData/SampleApp-adywyzvbmjimpfcinuscwqubgslf/Build/Products/Debug-iphonesimulator/SampleApp.app/Frameworks/AFramework.framework/AFramework
0000000000002f10 T _$s10BFramework8BServiceVACycfC
0000000000003e08 s _$s10BFramework8BServiceVMF
0000000000002f14 T _$s10BFramework8BServiceVMa
0000000000004008 s _$s10BFramework8BServiceVMf
0000000000003de4 S _$s10BFramework8BServiceVMn
0000000000004018 S _$s10BFramework8BServiceVN
0000000000003dd8 s _$s10BFrameworkMXM
                 U _$sytWV
0000000000003db8 S _BFrameworkVersionNumber
0000000000003d88 S _BFrameworkVersionString
...
```
<br/>

그렇다면 `RxSwift`, `RxCocoa`, `RxRelay` 라이브러리의 정보는 어디에 있을까요? 

`RxSwift`, `RxCocoa`, `RxRelay` 라이브러리가 중복 복사될 수 있어, Xcode가 **동적 프레임워크**로 만들었을 것입니다. 

동적 프레임워크로 생성했다면 AFramework, BFramework가 어떤 동적 라이브러리를 의존하고 있는지를 분석해보면 확인할 수 있을 것입니다.

```shell
$ otool -L ~/Library/Developer/Xcode/DerivedData/SampleApp-adywyzvbmjimpfcinuscwqubgslf/Build/Products/Debug-iphonesimulator/SampleApp.app/Frameworks/AFramework.framework/AFramework
/Users/minsone/Library/Developer/Xcode/DerivedData/SampleApp-adywyzvbmjimpfcinuscwqubgslf/Build/Products/Debug-iphonesimulator/SampleApp.app/Frameworks/AFramework.framework/AFramework:
	@rpath/AFramework.framework/AFramework (compatibility version 1.0.0, current version 1.0.0)
	@rpath/RxSwift.framework/RxSwift (compatibility version 0.0.0, current version 0.0.0)
	@rpath/RxRelay.framework/RxRelay (compatibility version 0.0.0, current version 0.0.0)
	@rpath/RxCocoa_38E61CAF42DDE0B6_PackageProduct.framework/RxCocoa_38E61CAF42DDE0B6_PackageProduct (compatibility version 0.0.0, current version 0.0.0)
	/usr/lib/libobjc.A.dylib (compatibility version 1.0.0, current version 228.0.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1336.0.0)
	/usr/lib/libc++.1.dylib (compatibility version 1.0.0, current version 1600.135.0)
	/usr/lib/swift/libswiftCore.dylib (compatibility version 1.0.0, current version 5.9.0)
    ...

$ otool -L ~/Library/Developer/Xcode/DerivedData/SampleApp-adywyzvbmjimpfcinuscwqubgslf/Build/Products/Debug-iphonesimulator/SampleApp.app/Frameworks/BFramework.framework/BFramework
/Users/minsone/Library/Developer/Xcode/DerivedData/SampleApp-adywyzvbmjimpfcinuscwqubgslf/Build/Products/Debug-iphonesimulator/SampleApp.app/Frameworks/BFramework.framework/BFramework:
	@rpath/BFramework.framework/BFramework (compatibility version 1.0.0, current version 1.0.0)
	@rpath/RxSwift.framework/RxSwift (compatibility version 0.0.0, current version 0.0.0)
	@rpath/RxRelay.framework/RxRelay (compatibility version 0.0.0, current version 0.0.0)
	@rpath/RxCocoa_38E61CAF42DDE0B6_PackageProduct.framework/RxCocoa_38E61CAF42DDE0B6_PackageProduct (compatibility version 0.0.0, current version 0.0.0)
	/usr/lib/libobjc.A.dylib (compatibility version 1.0.0, current version 228.0.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1336.0.0)
	/usr/lib/libc++.1.dylib (compatibility version 1.0.0, current version 1600.135.0)
	/usr/lib/swift/libswiftCore.dylib (compatibility version 1.0.0, current version 5.9.0)
```

AFramework, BFramework에는 `RxSwift`, `RxCocoa`, `RxRelay` 동적 프레임워크를 의존하고 있는 것을 확인할 수 있습니다. 

하지만, SampleApp.app의 Frameworks 폴더에는 `RxSwift`, `RxCocoa`, `RxRelay` 동적 프레임워크가 없습니다.

그러면 해당 프레임워크들은 어디에 있을까요? 

`@rpath`의 경로를 확인하면 해당 프레임워크를 찾을 수 있을 것입니다.

```shell
$ otool -l ~/Library/Developer/Xcode/DerivedData/SampleApp-adywyzvbmjimpfcinuscwqubgslf/Build/Products/Debug-iphonesimulator/SampleApp.app/Frameworks/AFramework.framework/AFramework | grep -A2 LC_RPATH
          cmd LC_RPATH
      cmdsize 32
         path /usr/lib/swift (offset 12)
--
          cmd LC_RPATH
      cmdsize 40
         path @executable_path/Frameworks (offset 12)
--
          cmd LC_RPATH
      cmdsize 40
         path @loader_path/Frameworks (offset 12)
--
          cmd LC_RPATH
      cmdsize 160
         path /Users/minsone/Library/Developer/Xcode/DerivedData/SampleApp-adywyzvbmjimpfcinuscwqubgslf/Build/Products/Debug-iphonesimulator/PackageFrameworks (offset 12)
--
          cmd LC_RPATH
      cmdsize 160
         path /Users/minsone/Library/Developer/Xcode/DerivedData/SampleApp-adywyzvbmjimpfcinuscwqubgslf/Build/Products/Debug-iphonesimulator/PackageFrameworks (offset 12)
--
          cmd LC_RPATH
      cmdsize 160
         path /Users/minsone/Library/Developer/Xcode/DerivedData/SampleApp-adywyzvbmjimpfcinuscwqubgslf/Build/Products/Debug-iphonesimulator/PackageFrameworks (offset 12)
--
          cmd LC_RPATH
      cmdsize 160
         path /Users/minsone/Library/Developer/Xcode/DerivedData/SampleApp-adywyzvbmjimpfcinuscwqubgslf/Build/Products/Debug-iphonesimulator/PackageFrameworks (offset 12)
```

`@rpath`에 추가된 경로중에 `PackageFrameworks`가 있는 것을 확인할 수 있습니다. 해당 경로의 폴더를 확인해봅시다.

<p style="text-align:left;"><img src="{{ site.dev_url }}/image/2023/07/04.png" style="width: 600px; border: 1px solid #555;"/></p><br/>

`PackageFrameworks` 폴더에 `RxSwift`, `RxCocoa`, `RxRelay` 동적 프레임워크가 있는 것을 확인하였습니다. 

**Xcode 12.5 Release Note**에 코드 중복이 발생하는 경우 동적 프레임워크를 생성한다는 의미를 확인할 수 있었습니다.

하지만, `SampleApp.app`의 Frameworks 경로에 `PackageFrameworks`에 있는 동적 프레임워크들이 없었습니다. 

이는 실 기기로 실행할 때는 해당 동적 프레임워크가 복사되지 않아 찾을 수 없어 `dyld: Library not loaded` 에러가 발생하면서 실행되지 않습니다.

해당 동적 프레임워크가 복사되게 하려면, `Application` 타겟에도 `RxSwift`, `RxCocoa`, `RxRelay` 라이브러리를 추가해야합니다.

<p style="text-align:left;"><img src="{{ site.dev_url }}/image/2023/07/05.png" style="width: 600px; border: 1px solid #555;"/></p><br/>

다시 SampleApp을 빌드하여 `SampleApp.app`의 Frameworks 폴더 내에 `RxSwift`, `RxCocoa`, `RxRelay` 동적 프레임워크가 있는지 확인해봅시다.

<p style="text-align:left;"><img src="{{ site.dev_url }}/image/2023/07/06.png" style="width: 600px; border: 1px solid #555;"/></p><br/>

빌드 로그에서도 `PackageFrameworks`에 있는 `RxSwift`, `RxCocoa`, `RxRelay` 동적 프레임워크를 SampleApp.app의 Frameworks에 복사하는 것을 확인할 수 있습니다.

<p style="text-align:left;"><img src="{{ site.dev_url }}/image/2023/07/07.png" style="width: 600px; border: 1px solid #555;"/></p><br/>

```shell
Copy /Users/minsone/Library/Developer/Xcode/DerivedData/SampleApp-adywyzvbmjimpfcinuscwqubgslf/Build/Products/Debug-iphonesimulator/SampleApp.app/Frameworks/RxSwift.framework /Users/minsone/Library/Developer/Xcode/DerivedData/SampleApp-adywyzvbmjimpfcinuscwqubgslf/Build/Products/Debug-iphonesimulator/PackageFrameworks/RxSwift.framework (in target 'SampleApp' from project 'SampleApp')
    cd /Users/minsone/Experiment-Repo/20230707/SampleApp
    builtin-copy -exclude .DS_Store -exclude CVS -exclude .svn -exclude .git -exclude .hg -resolve-src-symlinks -remove-static-executable /Users/minsone/Library/Developer/Xcode/DerivedData/SampleApp-adywyzvbmjimpfcinuscwqubgslf/Build/Products/Debug-iphonesimulator/PackageFrameworks/RxSwift.framework /Users/minsone/Library/Developer/Xcode/DerivedData/SampleApp-adywyzvbmjimpfcinuscwqubgslf/Build/Products/Debug-iphonesimulator/SampleApp.app/Frameworks
```

## 정리

* Swift Package에서 만든 라이브러리는 코드 복사가 발생할 수 있으면, 동적 프레임워크로 만들며, 동적 프레임워크를 복사되도록 Application에서도 의존성을 추가해야 합니다.

해당 예제는 [여기](https://github.com/minsOne/Experiment-Repo/tree/master/20230707)에서 확인할 수 있습니다.
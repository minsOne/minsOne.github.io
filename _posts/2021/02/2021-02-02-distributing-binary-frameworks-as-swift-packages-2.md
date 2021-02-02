---
layout: post
title: "[Swift 5.3+] Binary Framework(XCFramework)를 Swift Package로 배포하기(2) - iOS 프로젝트에 사용하기"
description: ""
category: "programming"
tags: [Swift, SwiftPM, SPM, Package, XCFramework, Binary Framework, xcodebuild, archive]
---
{% include JB/setup %}

기존 오픈소스를 XCFramework로 만든 후, iOS 프로젝트에서 사용하는 방법을 풀어보려고 합니다.

프로젝트는 다음과 같은 구조를 가집니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/02/20210201_1.png" style="width: 600px"/>
</p>

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/02/20210201_2.png" style="width: 800px"/>
</p><br/>

ModuleA, ModuleB의 Mach-O는 Static Library로 설정합니다.

다음으로 예제로 할 오픈소스인 Alamofire를 XCFramework로 만듭니다.

```
$ git clone https://github.com/Alamofire/Alamofire
$ cd Alamofire
$ xcodebuild archive -scheme "Alamofire iOS" -archivePath "./build/ios.xcarchive" -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
$ xcodebuild archive -scheme "Alamofire iOS" -archivePath "./build/ios_sim.xcarchive" -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
$ xcodebuild -create-xcframework -framework ./build/ios.xcarchive/Products/Library/Frameworks/Alamofire.framework -framework ./build/ios_sim.xcarchive/Products/Library/Frameworks/Alamofire.framework -output ./build/Alamofire.xcframework
```

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/02/20210201_3.png" style="width: 800px"/>
</p><br/>

만들어진 Alamofire.xcframework 파일을 Swift Package에 추가합니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/02/20210201_4.png" style="width: 800px"/>
</p><br/>

Package.swift 파일에 Alamofire를 BinaryTarget로 추가하고, PackageWrapper 타겟의 Dependency에 Alamofire BinaryTarget를 지정합니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/02/20210201_5.png" style="width: 800px"/>
</p><br/>

그러면 이제 ModuleB에서는 Alamofire를 사용할 수 있습니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/02/20210201_6.png" style="width: 800px"/>
</p><br/>

ModuleA에서도 Alamofire를 사용할 수 있습니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/02/20210201_7.png" style="width: 800px"/>
</p><br/>

App에서도 Alamofire를 사용할 수 있습니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/02/20210201_8.png" style="width: 800px"/>
</p><br/>

App에서 ModuleA의 A 클래스, ModuleB의 B 클래스를 생성하여 정상적으로 출력되는지 확인합니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/02/20210201_9.png" style="width: 800px"/>
</p><br/>

이제 App 프로젝트의 결과물을 한번 살펴봅시다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/02/20210201_10.png" style="width: 800px"/>
</p><br/>

Frameworks 폴더도 없고, 깨끗합니다. 즉, 우리가 만든 XCFramework가 App 패키지 내에 복사되지 않았다는 의미입니다. 하지만 실행한 환경은 시뮬레이터이므로, 만약 디바이스로 실행했다면 Alamofire.framework를 찾지 못하고 종료됩니다.

ModuleA, ModuleB를 Static Library로 설정했기 때문에 App 바이너리에 모든 코드가 복사됩니다. 그렇다면 App 프로젝트에 스위프트 패키지인 PackageWrapper를 연결하면 어떨까요? 

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/02/20210201_11.png" style="width: 800px"/>
</p><br/>

빌드 과정을 살펴보면 Alamofire를 복사하고 서명한 것을 확인할 수 있습니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/02/20210201_12.png" style="width: 800px"/>
</p><br/>

그리고 App 프로젝트의 결과물을 살펴봅시다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/02/20210201_13.png" style="width: 800px"/>
</p><br/>

아까와 달리 Frameworks 폴더가 생겼고, Alamofire.framework 가 있는 것을 확인할 수 있습니다. 즉, 해당 결과물은 정상적으로 실행이 된다는 의미입니다.<br/><br/>

#### 주의사항

ModuleB를 Dynamic Framework로 만들면 어떻게 될까요? App 프로젝트는 ModuleB를 Embed를 해야합니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/02/20210201_14.png" style="width: 800px"/>
</p><br/>

그리고 App 프로젝트 결과물을 살펴봅시다.

Frameworks 폴더 내에 ModuleB.framework가 있고, ModuleB.framework 폴더 내 Frameworks에 Alamofire.framework가 있음을 확인할 수 있습니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2021/02/20210201_15.png" style="width: 800px"/>
</p><br/>

즉, Nested Framework이므로, App 결과물을 앱스토어에 올릴때 리젝을 얻게 됩니다.

## 정리

* Sub 프로젝트에서 Swift Package를 사용할때, App 프로젝트도 Swift Package를 Linking하여 Framework를 Copy 하도록 해줘야합니다.
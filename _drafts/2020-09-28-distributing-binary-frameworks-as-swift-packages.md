
## App 프로젝트에 Swift Package를 연결하여 사용하기

App 프로젝트 내에 위에서 만든 SamplePackage 폴더를 드래그 해서 넣습니다.

<p style="text-align:center;">
<img src="{{ site.development_url }}/image/2020/10/20201004_12.png" style="width: 600px"/>
</p><br/>

### Binary Framework를 직접 사용하는 경우 - XCFramework가 Dynamic Library 인 경우

Binary Taget은 SampleFramework 라는 이름으로 지정했으므로, SampleFramework를 추가합니다.

<p style="text-align:center;">
<img src="{{ site.development_url }}/image/2020/10/20201004_13.png" style="width: 600px"/>
</p><br/>

그리고 SampleFramework 라는 이름을 지정하였지만, 실제로는 모듈 이름이 sample 이므로, `import sample` 코드를 사용하여 sample 코드를 사용합니다.

```
/// FileName: AppDelegate.swift

import UIKit
import sample

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
  	print(sample.helloworld())
  	return true
  }
}
```

정상적으로 출력됨을 확인할 수 있습니다.

<p style="text-align:center;">
<img src="{{ site.development_url }}/image/2020/10/20201004_14.png" style="width: 600px"/>
</p><br/>

다음으로 App을 Archive하여 나온 결과물 구조 확인해봅시다.

<p style="text-align:center;">
<img src="{{ site.development_url }}/image/2020/10/20201004_15.png" style="width: 600px"/>
</p><br/>

Frameworks 폴더 내에 sample 프레임워크가 있는 것을 확인할 수 있습니다. 그리고 여러 아키텍처 중에 arm64만 포함되어 있는 것을 확인할 수 있습니다.

```
$ file 'SampleApp1.xcarchive/Products/Applications/SampleApp1.app/Frameworks/sample.framework/sample'
SampleApp1.xcarchive/Products/Applications/SampleApp1.app/Frameworks/sample.framework/sample: Mach-O 64-bit dynamically linked shared library arm64
```

### Binary Framework를 직접 사용하는 경우 - XCFramework가 Static Library 인 경우

XCFramework를 Static Library로 만들어봅시다. 앞에서 만들었던 스크립트 중, MACH_O_TYPE을 `staticlib` 으로 값을 변경하여 실행합니다.

```
# Archive 하기
$ xcodebuild archive -scheme sample -archivePath "./build/ios.xcarchive" -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES MACH_O_TYPE=staticlib
xcodebuild archive -scheme sample -archivePath "./build/ios_sim.xcarchive" -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES MACH_O_TYPE=staticlib
xcodebuild archive -scheme sample -archivePath "./build/mac.xcarchive" -sdk macosx10.15 SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES MACH_O_TYPE=staticlib

# XCFramework 생성
$ xcodebuild -create-xcframework \
-framework "./build/ios.xcarchive/Products/Library/Frameworks/sample.framework" \
-framework "./build/ios_sim.xcarchive/Products/Library/Frameworks/sample.framework" \
-framework "./build/mac.xcarchive/Products/Library/Frameworks/sample.framework" \
-output "./build/sample.xcframework"
```

생성된 `sample.xcframework` 파일을 SamplePackage의 binaryTarget으로 이동합니다.

XCFramework 파일만 교체했으므로, 다시 App 프로젝트를 빌드 및 실행하면 위에서 했던 결과와 동일하게 출력합니다. 

다음으로 App을 Archive하여 나온 결과물은 위의 결과물과 동일한 구조를 가집니다. 그리고 XCFramework가 Static Library이지만 App 바이너리에는 코드가 복사되지 않았습니다. 다만 sample 프레임워크의 파일이 Static Library 임을 확인할 수 있습니다.

```
$ file 'SampleApp1.xcarchive/Products/Applications/SampleApp1.app/Frameworks/sample.framework/sample'
SampleApp1.xcarchive/Products/Applications/SampleApp1.app/Frameworks/sample.framework/sample: current ar archive random library
```

### Binary Framework를 의존성을 가진 Library를 사용하는 경우 - XCFramework가 Dynamic Library

위에서 SamplePackage 라는 라이브러리가 Binary Framework를 의존성 가지도록 했었습니다. sample XCFramework를 Dynamic Library로 다시 만듭니다. 그리고 App은 SamplePackage를 의존성 가지도록 합니다.


<p style="text-align:center;">
<img src="{{ site.development_url }}/image/2020/10/20201004_17.png" style="width: 600px"/>
</p><br/>

App에서는 SamplePackage를 통해 sample 모듈을 알게 되므로 SamplePackage의 helloworld, sample의 helloworld 함수를 다 사용할 수 있습니다.

```
/// FileName: AppDelegate.swift

import UIKit
import sample
import SamplePackage

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
  	print(sample.helloworld())
    print(SamplePackage.helloworld())
  	return true
  }
}
```

실행하면 두 함수가 다 호출되는 것을 확인할 수 있습니다.

다음으로 App을 Archive하여 나온 결과물 구조 확인해봅시다.




### Binary Target을 의존성을 가진 Library를 사용하는 경우 - XCFramework가 Static Library

## 프레임워크 프로젝트에서 Swift Package를 연결하여 사용하기

### Binary Target을 직접 사용하는 경우 - XCFramework가 Dynamic Library

### Binary Target을 직접 사용하는 경우 - XCFramework가 Static Library

### Binary Target을 의존성을 가진 Library를 사용하는 경우 - XCFramework가 Dynamic Library

### Binary Target을 의존성을 가진 Library를 사용하는 경우 - XCFramework가 Static Library



### XCFramework가 Dynamic Library인 겨


### XCFramework가 Dynamic Library인 경우

위에서 만든 XCFramework는 Dynamic Library이며, SamplePackage를 다른 Dynamic Library에다 연결해보도록 합시다.

#### SamplePackage를 Dynamic Library인 Framework에 연결

다음과 같이 App 프로젝트를 만들고, Lib1 이라는 Dynamic Library인 Framework 서브 프로젝트를 만들었습니다.

<p style="text-align:center;">
<img src="{{ site.development_url }}/image/2020/10/20201004_08.png" style="width: 600px"/>
</p><br/>

App -> Lib1 -> SamplePackage 와 같이 의존성을 가지려고 합니다.

먼저 App에서 Lib1을 연결합니다.

<p style="text-align:center;">
<img src="{{ site.development_url }}/image/2020/10/20201004_10.png" style="width: 600px"/>
</p><br/>

그리고 Lib1에 SamplePackage 폴더를 드래그 해서 넣고, Lib1에 SamplePackage를 연결합니다.

<p style="text-align:center;">
<img src="{{ site.development_url }}/image/2020/10/20201004_09.png" style="width: 600px"/>
</p><br/>

그리고 Lib1에서 SamplePackage의 helloworld 함수를 호출하는 코드를 작성합니다.

```
/// FileName: HelloWorld.swift

import SamplePackage

public func helloworld() -> String {
  SamplePackage.helloworld()
}
```

다음으로 테스트 코드에서 우리가 작성한 helloworld 함수에 출력 결과가 `"Hello World on Sample Framework"`를 출력하는지 확인합니다.

```
/// FileName: Lib1Tests.swift

import XCTest
@testable import Lib1

class Lib1Tests: XCTestCase {
  func test_HelloWorld() throws {
    XCTAssertEqual(Lib1.helloworld(), "Hello World on Sample Framework")
  }
}
```

여기까지는 잘 동작할 것입니다.

이제 App을 빌드하여 결과물을 살펴봅시다.

<p style="text-align:center;">
<img src="{{ site.development_url }}/image/2020/10/20201004_11.png" style="width: 600px"/>
</p><br/>

`Lib1.framework` 폴더 내에 Frameworks 폴더가 있고, 그 안에 `sample.framework`가 있는 것을 확인할 수 있습니다. 이런 구조는 개발은 가능하지만, 앱스토어에 제출할 때, `ITMS-90205` 에러를 유발합니다. 이 에러는 프레임워크 내에 또 다른 프레임워크가 있는 구조인 Nested Bundles를 허용하지 않음을 이야기 합니다.

### XCFramework를 Static Library인 경우

위에서 XCFramework를 만들었던 명령어에 `MACH_O_TYPE` 옵션 값을 `staticlib`으로 변경하여 Static Library로 XCFramework를 만듭니다.

```
# Archive 하기
$ xcodebuild archive -scheme sample -archivePath "./build/ios.xcarchive" -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES MACH_O_TYPE=staticlib
$ xcodebuild archive -scheme sample -archivePath "./build/ios_sim.xcarchive" -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES MACH_O_TYPE=staticlib
$ xcodebuild archive -scheme sample -archivePath "./build/mac.xcarchive" -sdk macosx10.15 SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES MACH_O_TYPE=staticlib

# XCFramework 생성
$ xcodebuild -create-xcframework \
-framework "./build/ios.xcarchive/Products/Library/Frameworks/sample.framework" \
-framework "./build/ios_sim.xcarchive/Products/Library/Frameworks/sample.framework" \
-framework "./build/mac.xcarchive/Products/Library/Frameworks/sample.framework" \
-output "./build/sample.xcframework"
```

그리고 만든 `sample.xcframework` 를 SamplePackage의 BinaryFramework 폴더로 복사한 후, 
















## Static Framework를 XCFramework에 연결 후, Swift Package에서 사용하기

Firebase SDK가 Mach-O가 Static이므로 해당 SDK를 예로 들어서 설명하겠습니다.

### XCFramework에 Static Framework 연결하기

FirebaseKit 이라는 Framework 프로젝트를 생성합니다.

<p style="text-align:center;">
<img src="{{ site.development_url }}/image/2020/10/20201004_08.png" style="width: 600px"/>
</p><br/>

그리고 `https://dl.google.com/dl/firebase/ios/carthage/FirebaseAnalyticsBinary.json` 의 JSON 파일을 내려받아, 사용할 버전의 Firebase를 내려받습니다.

저는 6.33.0 버전을 내려받아 FirebaseKit 내 SDK 폴더를 만들어 넣었습니다.

<p style="text-align:center;">
<img src="{{ site.development_url }}/image/2020/10/20201004_09.png" style="width: 600px"/>
</p><br/>


### Package로
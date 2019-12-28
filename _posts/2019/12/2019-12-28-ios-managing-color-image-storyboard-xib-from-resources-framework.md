---
layout: post
title: "[iOS][Xcode] Framework Part 3 : Storyboard, Xib, Color, Image를 리소스 프레임워크에서 관리"
description: ""
category: "iOS/Mac"
tags: [iOS, Xcode, UIColor, UIImage, Color, Image, Assets, Storyboard, Xib, Framework]
---
{% include JB/setup %}

# 서론

각각의 기능으로 분리되어 있는 프로젝트들은 공통의 리소스를 가질 수 있습니다. 색상, 이미지, Lottie의 JSON 등을 말이죠. 각각의 프로젝트들은 공통의 리소스를 사용하여 개발해야 하기 때문에 리소스 프레임워크를 만들어 관리할 수 있습니다. 그러면 중복되는 이미지도 없고, 리소스 프레임워크를 `import` 만 하면 되기 때문이죠.

## Color, Image를 리소스 프레임워크에서 관리

먼저 리소스 프레임워크를 만듭니다. 그리고 이미지를 `Images.assets`를 만들어 추가합니다.

<p style="text-align:center;"><img src="{{ site.production_url }}/image/2019/12/1.png" style="width: 600px"/></p><br/> 

해당 이미지들은 외부에서 코드로 불러와 사용하는 경우가 있기 때문에 이미지를 외부에서 접근할 수 있는 코드를 만듭니다. 

Resource 프레임워크는 `R` 이라는 타입으로 접근하여 사용할 것입니다.

먼저 R 타입을 만들어봅시다.

```
/// R.swift
import Foundation

public class R {
    static let bundle = Bundle.current
}

/// Extension.swift
import Foundation

extension Bundle {
    static var current: Bundle {
        return Bundle(for: CurrentBundle.self)
    }
}
```

프레임워크로 만들었기 때문에 이미지를 불러올 때 Resource 프레임워크의 Bundle 위치를 알기 위해 내부에서 사용할 bundle을 만들었습니다.

이제 이미지를 외부에서 접근할 수 있는 코드를 `R.Image.[이미지이름]` 형태를 따르도록 만듭니다.

```
/// R+Image.swift
import UIKit

public extension R {
    enum Image {}
}

public extension R.Image {
    static var theme1: UIImage { UIImage.load(name: "theme1") }
    static var theme2: UIImage { UIImage.load(name: "theme2") }
    static var theme3: UIImage { UIImage.load(name: "theme3") }
    static var theme4: UIImage { UIImage.load(name: "theme4") }
    static var theme5: UIImage { UIImage.load(name: "theme5") }
    static var theme6: UIImage { UIImage.load(name: "theme6") }
    static var theme7: UIImage { UIImage.load(name: "theme7") }
    static var theme8: UIImage { UIImage.load(name: "theme8") }
    static var digits: UIImage { UIImage.load(name: "Digits") }
    static var rotationLock: UIImage { UIImage.load(name: "rotation_lock") }
    static var rotationUnLock: UIImage { UIImage.load(name: "rotation_unlock") }
}

/// Extension.swift
extension UIImage {
    static func load(name: String) -> UIImage {
        if let image = UIImage(named: name, in: R.bundle, compatibleWith: nil) {
            return image
        } else {
            assert(false, "이미지 로드 실패")
            return UIImage()
        }
    }
}
```

이제 외부에서는 다음과 같이 이미지를 불러 올 수 있습니다.

```
import Resources

let view = UIImageView(image: R.Image.theme1)
```

이와 같은 방식으로 동일하게 Color도 만들수 있습니다.

먼저 Images.assets에 Color를 만듭니다.

<p style="text-align:center;"><img src="{{ site.production_url }}/image/2019/12/3.png" style="width: 600px"/></p><br/> 

그리고 이미지와 마찬가지로 외부에서 색상을 접근할 수 있는 코드를 `R.Color.[색상이름]` 형태를 따르도록 만듭니다.

```
/// R+Color.swift
public extension R {
    enum Color {}
}

public extension R.Color {
    static var color1: UIColor {
        UIColor.load(name: "Color1")
    }
}

/// Extension.swift
extension UIColor {
    static func load(name: String) -> UIColor {
        guard let color = UIColor(named: name, in: R.bundle, compatibleWith: nil) else {
            assert(false, "Color 로드 실패")
            return UIColor()
        }
        return color
    }
}
```

이제 외부에서는 다음과 같이 색상을 불러 올 수 있습니다.

```
import Resources

let color = R.Color.color1
```

## Storyboard, Xib를 리소스 프레임워크에서 관리

iOS 개발시 항상 논쟁이 되는 주제가 있습니다. 뷰를 그릴때 코드로 작성할 것이냐 Storyboard 또는 Xib로 할 것이냐라고 입니다. 둘다 맞는 말이기 때문에 논쟁이 끝이 없다고 생각합니다. 저는 Storyboard로 뷰를 많이 그리기 때문에 ViewController 클래스 파일과 Storyboard 파일이 항상 쌍으로 있습니다. 그리고 Storyboard 파일 관리를 별도로 생각하지 않았습니다. 하지만 프로젝트가 커짐에 따라 각 기능을 프레임워크로 분리해야할 필요가 있었고, ViewController의 Storyboard 파일도 이전 검토해야하는 문제가 생겼습니다. Storyboard 파일은 Bundle로 관리해야하기 때문이죠.

Storyboard 파일을 가지기 위해서는 Dynamic 프레임워크를 만들어야하는데, 각 기능마다 프레임워크로 만들게 되면 프레임워크 개수가 빠른 속도로 늘어날 뿐만 아니라, 기능을 더 작게 나누어 한 화면을 프레임워크로 만들게 되면 기하급수적으로 프레임워크가 늘어납니다. 어떻게 이 문제를 해결해야 할까요?

**리소스 프레임워크에서 Storyboard와 Xib를 관리하면 됩니다.** 리소스 프레임워크에 관리하면 기능 단위의 프레임워크를 Static으로 만들어도 Bundle의 위치는 리소스 프레임워크이기 때문에 전혀 문제되지 않습니다. 그리고 Storyboard나 Xib에서 이미지와 색상을 지정하더라도 리소스 프레임워크의 Images.assets에서 이미지와 색상을 가져오기 때문에 문제가 없습니다.

<p style="text-align:center;"><img src="{{ site.production_url }}/image/2019/12/2.png" style="width: 600px"/></p><br/> 

그러면 리소스 프레임워크에서 Storyboard를 가져오는 코드를 만들어봅시다.

Storyboard의 변수 이름은 각 화면을 지정하여 `R.Storyboard.[화면 이름]` 과 같은 형태로 만듭니다.

```
/// R+Storyboard.swift
extension R.Storyboard {
    public typealias Storyboard = R.Storyboard

    public static var clock: Storyboard { Storyboard(name: "ClockViewController") }
    public static var settings: Storyboard { Storyboard(name: "SettingsViewController") }
}

extension R {
    public class Storyboard {
        let identifier: String
        public let storyboard: UIStoryboard
        public init(name: String, identifier: String) {
            self.identifier = identifier
            self.storyboard = UIStoryboard(name: name, bundle: R.bundle)
        }
        public convenience init(name: String) {
            self.init(name: name, identifier: name)
        }
        public func instance<T: UIViewController>() -> T {
            storyboard.instantiateViewController(withIdentifier: identifier) as! T
        }
    }
}
```

이제 우리는 다음과 같이 리소스 프레임워크에서 Storyboard를 가져올 수 있습니다.

```
import Resources

let clockViewController: ClockViewController = R.Storyboard.clock.instance
```

# 참조
* [Apple Document - Framework Programming Guide / What is Frameworks?](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFrameworks/Concepts/WhatAreFrameworks.html#//apple_ref/doc/uid/20002303-BBCEIJFI)
* [Apple Document - Framework Programming Guide
/ Guidelines for Creating Frameworks](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFrameworks/Concepts/CreationGuidelines.html#//apple_ref/doc/uid/20002254-BAJHGGGA)
* [Apple Document - Framework Programming Guide / Frameworks and Binding](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFrameworks/Concepts/FrameworkBinding.html)
* [Apple Document - Mach-O Programming Topics / Building Mach-O Files](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/MachOTopics/1-Articles/building_files.html)
* [Apple Document - Dynamic Library Programming Topics / Overview of Dynamic Libraries](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/DynamicLibraries/100-Articles/OverviewOfDynamicLibraries.html)
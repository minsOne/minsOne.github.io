---
layout: post
title: "[Xcode][iOS] 프레임워크를 이용하여 한 프레임워크가 리소스를 관리하고, 여러 프레임워크가 리소스 사용하기"
description: ""
category: "iOS/Mac"
tags: [Framework, UIImage, XCAssets, Bundle]
---
{% include JB/setup %}

프로젝트를 커지다보면 코드를 조금씩 나눕니다. 일반적인 유틸성 코드는 나눌 수 있지만, 이미지 같은 리소스는 어떻게 해야할지 고민이 됩니다.

각 도메인 서비스 프로젝트들로 나누기 시작하면 리소스가 중복되는 문제가 생기기도 하고요. 그러면 리소스를 관리하는 프레임워크를 만들고, 이 프로젝트를 사용하는 방식으로 해야합니다.

하지만 프레임워크에서 이미지 로드시 일반적인 방식인 `UIImage(named: "abc")` 방식이 되지 않습니다. Bundle이 메인이 아니기 때문이죠. 

그래서 다음과 같은 방식을 사용합니다.

```
class FakeBundle {}

let image = UIImage(named: "abc", in: Bundle(for: FakeBundle.self), compatibleWith: nil)
```

이미지를 불러올때마다 위와 같은 긴 코드를 작성해야하므로, Extension을 이용하여 코드를 줄여봅시다.

```
extension Bundle {
    private class FakeBundle {}
    
    static var frameworkBundle: Bundle {
        return Bundle(for: FakeBundle.self)
    }
}

extension UIImage {
    static func load(name: String) -> UIImage {
        if let image = UIImage(named: name, in: Bundle.frameworkBundle, compatibleWith: nil) {
            return image
        } else {
            assert(false, "이미지 로드 실패")
        }
    }
}
```

이제 외부에서 사용할 이미지를 위한 변수를 만들어봅시다.

```
public enum R {
    public enum Image {
        public static let abc: UIImage = .load(name: "abc")
    }
}
```

이제 이 프레임워크를 사용하는 곳에서는 다음과 같이 사용하면 됩니다.

```
import Resource

...
let image = R.Image.abc
...
```

이제 이미지를 한 프레임워크에서 쉽게 관리할 수 있습니다.<br/>

## 주의사항

Xcode 주석에서 이미지를 보여줄 수 있는 기능이 있다고 되어 있습니다. [링크](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/Images.html)

```
/**
 
 An example of using *images* to display a web image
 
 ![Xcode icon](http://devimages.apple.com.edgekey.net/assets/elements/icons/128x128/xcode.png "Some hover text")
 
 */
```

하지만 위와 같이 주석을 작성하여도 동작을 하지 않기 때문에, 이미지가 어떤 것인지 프레임워크의 Assets을 뒤져야하는 문제가 있습니다. 언제 이 문제가 해결될지는 모르겠으나, 해당 버그를 감수하고 사용할 것인지 고민해볼 필요가 있어 보입니다.

## 참고
* [R.swift](https://github.com/mac-cain13/R.swift)
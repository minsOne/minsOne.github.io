---
layout: post
title: "[iOS][Swift] Framework에 있는 이미지를 Imageliteral 사용하여 불러오기"
description: ""
category: "programming"
tags: [iOS, UIImage, Swift, imageLiteral, _ExpressibleByImageLiteral, Bundle, Framework]
---
{% include JB/setup %}

Swift 3에서 이미지를 코드 상에서 볼 수 있는 문법이 추가되었습니다.

```
let image = #imageLiteral(resourceName: "imageName")
```

위 코드는 `libswiftUIKit.dylib`에서 `UIImage.init(named:)` 를 쉽게 사용할 수 있는 코드입니다. 

```
libswiftUIKit.dylib`(extension in UIKit):__C.UIImage.init(imageLiteralResourceName: Swift.String) -> __C.UIImage:
  0x7fff517c6a60 <+0>:   pushq  %rbp
  0x7fff517c6a61 <+1>:   movq   %rsp, %rbp
  0x7fff517c6a64 <+4>:   pushq  %r15
  0x7fff517c6a66 <+6>:   pushq  %r14
  0x7fff517c6a68 <+8>:   pushq  %r12
  0x7fff517c6a6a <+10>:  pushq  %rbx
  0x7fff517c6a6b <+11>:  movq   %rsi, %r14
  0x7fff517c6a6e <+14>:  movq   %rdi, %rbx
  0x7fff517c6a71 <+17>:  movq   %r13, %rdi
  0x7fff517c6a74 <+20>:  callq  0x7fff517cff1a      ; symbol stub for: swift_getObjCClassFromMetadata
  0x7fff517c6a79 <+25>:  movq   %rax, %r15
  0x7fff517c6a7c <+28>:  movq   %rbx, %rdi
  0x7fff517c6a7f <+31>:  movq   %r14, %rsi
  0x7fff517c6a82 <+34>:  callq  0x7fff517cfd3a      ; symbol stub for: (extension in Foundation):Swift.String._bridgeToObjectiveC() -> __C.NSString
  0x7fff517c6a87 <+39>:  movq   %rax, %r12
  0x7fff517c6a8a <+42>:  movq   0x3857a70f(%rip), %rsi  ; "imageNamed:"
  0x7fff517c6a91 <+49>:  movq   %r15, %rdi
  0x7fff517c6a94 <+52>:  movq   %rax, %rdx
  0x7fff517c6a97 <+55>:  callq  0x7fff517cfe96      ; symbol stub for: objc_msgSend
  0x7fff517c6a9c <+60>:  movq   %rax, %rdi
  0x7fff517c6a9f <+63>:  callq  0x7fff517cfeae      ; symbol stub for: objc_retainAutoreleasedReturnValue
  0x7fff517c6aa4 <+68>:  movq   %rax, %rbx
  0x7fff517c6aa7 <+71>:  movq   %r12, %rdi
  0x7fff517c6aaa <+74>:  callq  *0x3622b350(%rip)     ; (void *)0x00007fff50bad000: objc_release
  0x7fff517c6ab0 <+80>:  testq  %rbx, %rbx
  0x7fff517c6ab3 <+83>:  je   0x7fff517c6ac9      ; <+105>
  0x7fff517c6ab5 <+85>:  movq   %r14, %rdi
  0x7fff517c6ab8 <+88>:  callq  0x7fff517cfecc      ; symbol stub for: swift_bridgeObjectRelease
  0x7fff517c6abd <+93>:  movq   %rbx, %rax
  0x7fff517c6ac0 <+96>:  popq   %rbx
  0x7fff517c6ac1 <+97>:  popq   %r12
  0x7fff517c6ac3 <+99>:  popq   %r14
  0x7fff517c6ac5 <+101>: popq   %r15
  0x7fff517c6ac7 <+103>: popq   %rbp
  0x7fff517c6ac8 <+104>: retq   
  0x7fff517c6ac9 <+105>: ud2  
  0x7fff517c6acb <+107>: nopl   (%rax,%rax)
```

그렇기 때문에 `imageLiteral`로 이미지를 가져오는 곳은 `Main Bundle`이 됩니다. 즉, `imageLiteral`는 Main Bundle 이미지 리소스만 사용가능하고, 각 Framework에서 가지고 있는 이미지 리소스는 `imageLiteral`를 이용하여 이미지를 가져올 수 없습니다.

하지만 그래도 Main Bundle이 아닌 다른 Bundle의 이미지 리소스를 `imageLiteral`로 접근하여 사용하고 싶습니다. 왜냐하면 해당 이미지가 어떤 그림인지 보여주는 것은 좋다고 생각됩니다.

[이전 글 - Storyboard, Xib, Color, Image를 리소스 프레임워크에서 관리]({{ site.production_url }}/ios/mac/ios-managing-color-image-storyboard-xib-from-resources-framework)에서 사용한 `R.swift`를 이어서 사용합니다.

```
/// R.swift
import Foundation

public class R {
  static let bundle = Bundle(for: R.self)
}
```

`imageLiteral` 문법은 Swift의 [**CompilerProtocols.swift**](https://github.com/apple/swift/blob/master/stdlib/public/core/CompilerProtocols.swift)의 [**_ExpressibleByImageLiteral**](https://github.com/apple/swift/blob/master/stdlib/public/core/CompilerProtocols.swift#L939) 프로토콜을 UIImage가 따라서 사용할 수 있었습니다.

그러면 Resource 프레임워크에 있는 이미지를 불러오는 Custom Imageliteral를 만들어봅시다.

```
/// R+Image.swift
import UIKit

extension R {
    public struct Image: _ExpressibleByImageLiteral {
        public let image: UIImage

        public init(imageLiteralResourceName path: String) {
            if let image = UIImage(named: path, in: R.bundle, compatibleWith: nil) {
                self.image = image
            } else {
                assert(false, "해당 이미지가 없습니다.")
                self.image = UIImage()
            }
        }

        public static func name(_ image: Image) -> UIImage {
            return image.image
        }
    }
}

extension UIImage {
  public static func rImage(_ r: R.Image) -> Self {
    return r.image
  }
}
```

이제 우리는 다음과 같이 imageLiteral을 이용하여 이미지를 불러올 수 있습니다.

```
let screenshot1: R.Image = #imageLiteral(resourceName: "imageName")
UIImageView(image: screenshot.image)


UIImageView(image: R.Image.name(#imageLiteral(resourceName: "imageName")))

var aImage: UIImage { 
  return .rImage(#imageLiteral(resourceName: "imageName")) 
}

UIImageView(image: .rImage(#imageLiteral(resourceName: "imageName")))
```

# 참고자료
* [Stackoverflow - Xcode8: Usage of image literals in frameworks](https://stackoverflow.com/a/46292441/2749449)
* [Swift - CompilerProtocols](https://github.com/apple/swift/blob/master/stdlib/public/core/CompilerProtocols.swift#L939)
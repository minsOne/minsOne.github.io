---
layout: post
title: "[iOS][Xcode] Application에 있는 Storyboard, Xib 등을 리소스 프레임워크로 이전해서 관리하기"
tags: [iOS, Xcode, Storyboard, Xib, Framework, PRODUCT_MODULE_NAME]
---
{% include JB/setup %}

iOS 애플리케이션 개발을 진행하다보면, 생각보다 많은 파일(Storyboard, Xib 파일 등)이 많이 추가됩니다.

하지만, 하지만 기존 코드를 모듈로 분리하는 것은 쉽지 않습니다. UI 관련된 코드들은 많은 의존성을 가지고, 결합도가 높은 상태일 확률이 높습니다. 또한, Storyboard, Xib 같은 파일은 파일 이름, 클래스 이름 설정, IBOutlet 연결 등의 관리 이슈가 많이 발생합니다. UIViewController, UIView 클래스 파일들과 같은 위치에 있어야 확인하기 편하면서도 순수 Swift 파일이 아니다 보니 애매하게 불편하기도 합니다. 

그렇다고, UIViewController, UIView 클래스 파일들이 모듈로 분리되지 않았는데, 해당 Storyboard, Xib 파일들도 별도의 리소스 모듈로 이동하기 어렵다고 생각할 수 있습니다. 

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2023/04/06.png" style="width: 300px; border: 1px solid #555;"/></p><br/>

위 그림처럼 `Inherit Module For Target`이 체크가 되어 있다면, 해당 모듈 항목에 들어가는 값은 빌드시 해당 파일이 포함되어진 타겟의 `PRODUCT_MODULE_NAME` 값이 들어갑니다.

즉, 모듈 항목에 들어가는 값은 어떤 빌드 과정을 진행하느냐에 따라 달라진다는 것입니다.

만약, 애플리케이션의 Product Name이 타겟, 스킴에 따라 변경되지 않는다면, 해당 Product Name을 모듈 항목에 넣어도 되지 않을까요?

`Build Settings`에서 `PRODUCT_MODULE_NAME`은 모듈 이름으로, 애플리케이션의 이름을 나타냅니다. 

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2023/04/07.png" style="width: 800px; border: 1px solid #555;"/></p><br/>

AppResources라는 Dynamic Framework를 만들고, 해당 Storyboard, Xib 등을 이전합니다.

그리고 Storyboard, Xib에 `Inherit Module For Target` 체크를 풀고, 모듈 이름을 `PRODUCT_MODULE_NAME` 값으로 설정합니다.

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2023/04/08.png" style="width: 800px; border: 1px solid #555;"/></p><br/>

```swift
/// ModuleName : AppResources
/// FileName : R.swift

import Foundation
import UIKit

public class R {
    public enum Storyboard {}
}

public extension R.Storyboard {
    static var BViewController: UIStoryboard {
        UIStoryboard(name: "BViewController", bundle: Bundle(for: R.self))
    }
}
```

그러면 이제 Application에 있는 `BViewController` 클래스의 Storyboard인 AppResources 모듈의 `BViewController.storyboard`를 연결하여 `BViewController`를 생성할 수 있습니다.

```swift
/// ModuleName : Application
/// FileName : BViewController.swift
import Foundation
import UIKit

class BViewController: UIViewController {
    @IBOutlet var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.addAction(.init(handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
    }
}

/// ModuleName : Application
/// FileName : ViewController.swift

import AppResources
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        ...

        button.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            let vc = R.Storyboard.BViewController.instantiateViewController(withIdentifier: "BViewController") as? BViewController
            vc.map { self.present($0, animated: true) }
        }), for: .touchUpInside)
    }
}
```

<br/><video src="{{ site.prod_url }}/image/2023/04/09.mp4" width="300" controls autoplay></video><br/>

위에서 작업한 코드는 [여기](https://github.com/minsOne/Experiment-Repo/tree/0a6be5b36265690e285ba6d11f829cf7c6de5423/20230417-DemoApp/Application)에서 확인하실 수 있습니다.

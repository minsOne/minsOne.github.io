---
layout: post
title: "[iOS] 준 Clean Architecture With RIBs, ReactorKit 그리고 Tuist를 이용한 프로젝트 모듈화 설계(3) - UserInterface"
description: ""
category: "Mac/iOS"
tags: [Swift, Xcode, Clean Architecture, RIBs, ReactorKit, Tuist]
---
{% include JB/setup %}

## 들어가기 전

iOS 개발은 프론트 개발입니다. 즉, 화면을 만들고 이를 사용자에게 보여주는 것이 중요합니다. 따라서 화면을 빠르게 개발하여 확인할 수 있어야 합니다. 

모든 화면에서 공통으로 사용해야할 리소스, 리소스를 사용하면서 공통적인 화면을 만들 디자인 시스템, 리소스와 디자인 시스템을 이용하여 화면 개발, 그리고 개발한 화면을 가지고 데모앱을 만들어져야 합니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/09/20210922_01.png" style="width: 200px"/></p>

위의 의존성 그림을 자세히 살펴봅시다.

## Resources

리소스는 화면을 개발하는 데 필요한 자원이라고 생각하시면 됩니다. 예를 들어, 리소스는 Image, WebP, Lottie, Color 등이 있습니다. 이 리소스는 모든 화면에서 동일하게 사용해야하므로, 리소스만 전담으로 다루는 프로젝트를 만들어 관리합니다.

리소스 프로젝트 타입을 두가지로 정의해서 할 수 있습니다. 첫번째는, Dynamic Framework로 프로젝트 타입을 설정합니다. 이렇게 하면 리소스는 리소스 프레임워크에서 관리하게 되므로 번들 위치가 리소스 프레임워크가 됩니다. 

두번째로는 Swift Package로 만들어 관리하는 것입니다. Swift Package로 리소스를 관리하게 되면, 앱이 빌드할 때, 번들을 만들어 메인번들에 복사를 해줍니다. Dynamic Framework를 만들게 되면, 리소스 프로젝트를 임베딩 설정을 해야하는 작업이 들어가지만, Swift Package로 만들면 번들을 만들고 복사까지 해주기 때문에, 저는 Swift Package로 관리하는 것이 더 좋다고 생각됩니다.

여기에서는 Swift Package로 관리하는 방법을 이야기하려고 합니다.

### ResourcePackage

ResourcePackage라는 폴더를 만든 후, `swift package init --type library` 명령으로 Swift Package를 초기화합니다.

```
$ mkdir ResourcePackage && cd ResourcePackage
$ swift package init --type library
$ mkdir -p Sources/ResourcePackage/Resources
```

다음으로, `Package.swift` 파일에서 Target에 Resources 경로를 추가합니다.

```
...
targets: [
    .target(
        name: "ResourcePackage",
        dependencies: [],
        resources: [.process("Resources")]),
...
```

다음으로, 리소스를 정적으로 다루기 위해서 [R.swift](https://github.com/mac-cain13/R.swift)와 같은 오픈소스 방식을 차용하려고 합니다.

```
/// FileName : R.swift
import Foundation
import UIKit

public struct R {}

extension R {
    public struct Image {}
}

/// FileName : RImage.swift
import Foundation
import UIKit

struct RImage: _ExpressibleByImageLiteral {
    let image: UIImage
    
    init(imageLiteralResourceName path: String) {
        if let image = UIImage(named: path, in: .module, compatibleWith: nil) {
            self.image = image
        } else {
            assert(false, "해당 이미지가 없습니다.")
            self.image = UIImage()
        }
    }
}

/// FileName : ImageAsset.swift
import Foundation
import UIKit

extension R.Image {
    public struct Arrow {
        public static var arrow20LGrey_Normal: UIImage { .R(#imageLiteral (resourceName: "arrow20LGrey_Normal")) }
        public static var arrow20L_Normal: UIImage { .R(#imageLiteral (resourceName: "arrow20L_Normal")) }
        public static var arrow20_Normal: UIImage { .R(#imageLiteral (resourceName: "arrow20_Normal")) }
    }
}
```

위와 같이 컴파일 기반으로 이미지를 불러올 수 있도록 합니다. `R.Image.Arrow.arrow20LGrey_Normal`를 접근하면 리소스를 의존하는 모든 모듈에서는 동일한 이미지를 얻을 수 있습니다.

## Design System

디자인 시스템은 리소스 프로젝트와 레이아웃 관련 라이브러리를 의존합니다. 뷰에서 사용하는 리소스는 리소스 프로젝트에서 가져와 사용하며, 뷰 컴포넌트들은 레이아웃 라이브러리 또는 직접 뷰를 구성하여 만듭니다.

따라서 여기에서 정의된 뷰 컴포넌트들은 기능 화면 모듈의 View와, ViewController의 기반이 됩니다.

예를 들어, 다음과 같이 Leading, Trailing 양 끝으로 Label이 배치되는 뷰를 컴포넌트로 만들 수 있습니다.<br/><br/>

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/09/20210922_02.png" style="width: 400px;border-width: 1px;border-style: solid;"/></p>

<br/>[FlexLayout](https://github.com/layoutBox/FlexLayout)을 사용해서 위와 같은 뷰를 만들어봅시다.

```
import FlexLayout

public class BothSideLabelView {
    private let leadingLabel = UILabel()
    private let trailingLabel = UILabel()

    public var container = UIView()

    init(title: String, detail: String) {
        leadingLabel.text = title
        trailingLabel.text = detail
        trailingLabel.textAlignment = .right
        container.flex.direction(.row).alignContent(.spaceBetween)
        container.flex.addItem(leadingLabel)
        container.flex.addItem(trailingLabel).grow(1)
    }

    public func update(detail: String) {
        trailingLabel.text = detail
        trailingLabel.flex.markDirty()
        container.flex.layout()
    }
}
```

Flexlayout을 사용하면 쉽게 위의 그림과 같이 뷰를 작성할 수 있습니다.

따라서 이와 같은 컴포넌트를 만들고 잘 조립할 수 있게 도와주도록 하는 모듈이 디자인 시스템입니다.

## Feature UserInterface

피처 유저인터페이스는 디자인 시스템, 리소스 등을 이용해서 정보를 화면에 그리는 모듈입니다. 이 모듈은 API, 비지니스 로직 등에 연관되지 않고, 정보가 들어왔을 때, 어떻게 화면에 그려줄 것인지만 처리하도록 합니다. 

그래서 어떤 정보를 받을 것인지 State 타입과, 어떤 행위가 발생했는지 Action 타입을 정의하고, 이 모듈을 의존하게 되는 도메인 모듈이 State를 구현하고 전달하고, Action을 받아 처리하게 됩니다.

```
import Foundation
import RxSwift
import UIKit
import DesignSystem
import PinLayout
import FlexLayout

public enum FeaturePresentableAction {
    case viewDidLoad
    case applyCheckCard
    case finish
    case moveToMain
}

public struct FeaturePresentableState {
    var text: String
    var 계좌종류: String

    public init(text: String, 계좌종류: String) {
        self.text = text
        self.계좌종류 = 계좌종류
    }
}

public protocol FeaturePresentableListener: AnyObject {
    func action(_ action: FeaturePresentableAction)
    var presentableState: Observable<FeaturePresentableState> { get }
}

public final class FeatureViewController: UIViewController {
    public weak var listener: FeaturePresentableListener?

    ...

    public override func viewDidLoad() {
        super.viewDidLoad()

        bindState()
        listener?.action(.viewDidLoad)
    }

    func bindState() {
        listener?.presentableState
            .map(\.text)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] value in print(value) }
            .disposed(by: disposeBag)
        
        ...
    }
```

## DemoApp

Feature UserInterface 모듈은 다른 비지니스 로직이나 API 의존하지 않기 때문에 상태를 넘기면 화면에 반영되는 데모앱을 작성할 수 있게 됩니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2021/09/20210922_03.png" style="width: 400px"/></p>

기존에 의존성이 많아 화면 단위의 데모앱을 구성할 수 없었지만, 상태만 의존하기 때문에 데모앱에서 적절하게 상태를 넘겨주도록 하여 빠른 화면 개발이 가능해집니다.

<br/><br/>ps. Tuist로 프로젝트 구조 생성한 프로젝트는 [Github 저장소](https://github.com/minsOne/iOSApplicationTemplate)에 공개되어 있습니다. 모든 코드를 여기 글에 적지 못한 점 양해바랍니다.
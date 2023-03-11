---
layout: post
title: "[iOS][UIKit][SwiftUI] UIKit 기반 CustomView를 Preview에서 확인할 때 sizeThatFits로 설정하여 정확한 크기로 확인하기"
tags: [iOS, UIKit, UIView, Preview, SwiftUI, PreviewProvider, intrinsicContentSize, previewLayout, sizeThatFits]
---
{% include JB/setup %}

SwiftUI에서 Preview로 확인할 때, `previewLayout`에서 `sizeThatFits`로 값을 설정하면 뷰가 정확한 크기에 맞춰 나타납니다.

```swift
import SwiftUI

struct Preview: PreviewProvider {
    static var previews: some View {
        Text("Hello World")
            .previewLayout(.sizeThatFits)
    }
}
```

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2023/03/01.png" style="width: 300px"/></p><br/>

UIKit 기반의 CustomView를 Preview로 볼 때 단점 중 하나는 항상 올바른 크기로 나타나지 않는다는 것입니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2023/03/02.png" style="width: 300px"/></p><br/>

생각해보면, UIKit 기반의 CustomView의 크기를 계산할 수 없어서 발생하는 문제인 것 같습니다.

만약 그렇다면, UILabel, UIButton 등은 기본 크기를 가지고 있으며, 뷰가 자동으로 크기를 계산합니다.

간단한 UILabel, UIButton의 경우 Preview에서 잘 작동하는지 확인해볼 수 있습니다.

먼저 UIView를 SwiftUI에서 사용할 수 있도록 변환해야 하므로, 다음 코드를 사용하여 View로 변환시킵니다.

```swift
import SwiftUI

struct UIViewPreview<View: UIView>: UIViewRepresentable {
    let view: View

    init(_ builder: @escaping () -> View) {
        view = builder()
    }

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> UIView { view }

    func updateUIView(_ view: UIView, context: Context) {
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}
```

위 코드를 사용하여 Preview에서 UILabel을 확인해보겠습니다.

```swift
struct Preview: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            let label = UILabel()
            label.text = "UILabel -> Hello World"
            return label
        }
        .previewLayout(.sizeThatFits)
    }
}
```

Preview에서 위의 코드를 다음과 같이 확인할 수 있습니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2023/03/03.png"/></p><br/>

UIButton을 Preview로 확인해보겠습니다.

```swift
struct Preview: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            let button = UIButton()
            button.setTitle("UIButton -> Hello World", for: .normal)
            button.setTitleColor(.systemBlue, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
            return button
        }
        .previewLayout(.sizeThatFits)
    }
}
```

Preview에서 위의 코드를 다음과 같이 확인할 수 있습니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2023/03/04.png"/></p><br/>

UILabel과 UIButton 모두 Preview에서 스스로의 크기를 계산하여 적절하게 보여준 것을 확인할 수 있습니다.

UIView에서는 뷰의 내용에 따른 크기를 반환해주는 `intrinsicContentSize` 속성을 사용하여 이를 가능케 합니다.

CustomView에서도 `intrinsicContentSize` 속성을 상속받아 직접 계산한 값을 반환하면 Preview에서 크기에 딱 맞게 출력 될 것입니다.

다음 코드는 UIButton이 포함된 CustomView입니다.

```swift
final class ButtonView: UIView {
    struct State {
        var buttonName: String
    }
    
    lazy var button = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .systemBlue
        
        button.setTitle("Hello World", for: .normal)
        button.sizeToFit()
        button.backgroundColor = .systemRed
        button.frame.origin.x = 50
        button.frame.origin.y = 50
        
        addSubview(button)
    }

    func set(state: State) {
        button.setTitle(state.buttonName, for: .normal)
        button.sizeToFit()
    }
}
```

위 코드를 사용하여 Preview에서 확인해보겠습니다.

```swift
struct Preview: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            let view = ButtonView()
            return view
        }
        .previewLayout(.sizeThatFits)
    }
}
```

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2023/03/05.png" style="width: 300px"/></p><br/>

Preview로 출력된 CustomView는 크기를 계산할 수 없으므로 CustomView를 전체 크기로 보여줍니다.

그러므로, 앞서 추측한 대로 `intrinsicContentSize` 속성을 계산하여 반환해보겠습니다.


```swift
final class ButtonView: UIView {
    ...

    override var intrinsicContentSize: CGSize {
        var size = button.bounds.size
        size.width += 100
        size.height += 100
        return size
    }

    ...
}
```

위 코드를 사용하여 다시 Preview에서 확인해보겠습니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2023/03/06.png" style="width: 300px"/></p><br/>

이제 Preview에서 뷰가 정확한 크기로 출력되는 것을 확인할 수 있습니다.

## 참고자료

* [마기의 개발 블로그 - intrinsicContentSize에 대해서 알아보기](https://magi82.github.io/ios-intrinsicContentSize/)
* [Apple Document - intrinsicContentSize](https://developer.apple.com/documentation/uikit/uiview/1622600-intrinsiccontentsize)
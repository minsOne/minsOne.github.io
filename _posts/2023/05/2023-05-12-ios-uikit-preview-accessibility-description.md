---
layout: post
title: "[iOS][Xcode 14.3+][UIKit][Accessibility] Preview에서 UIKit 기반 View 접근성 요소을 출력하여 확인하기"
tags: []
---
{% include JB/setup %}

애플리케이션의 접근성 대응에 대해 이야기하려고 합니다.

우리는 많은 시간을 쏟아 서비스를 개발하고 출시합니다. 그렇게 출시한 서비스를 많은 사람들이 사용했으면 합니다. 하지만 우리가 열심히 만든 서비스가 정작 필요한 사람들에게는 여러가지 환경에 의해 사용하기 어려운 서비스가 될 수 있습니다. 

모든 사용자에게 동일한 서비스를 제공하는 것이 우리의 의무입니다만, 추가 기능을 구현하기도 시간이 촉박한 상태에서 접근성을 대응하기란 쉽지 않습니다. 우리는 눈으로 화면을 보고, 손가락으로 터치를 하면서 기능을 이용하지만, 어떤 사람들은 그렇지 않기 때문입니다.

그렇다면 왜 이런 어려움을 감수하고 접근성을 대응해야 할까요?

첫 번째로, 다양한 사용자를 대상으로 서비스를 제공함으로써, 사용자의 범위를 확대하고, 서비스의 품질을 향상시키는 결과를 가져옵니다.

두 번쨰로, 접근성 대응은 법적인 요구사항이 될 수 있습니다.

세 번째로, 접근성을 고려한 화면 설계 및 구현은 앱의 사용성을 향상시키는 데에도 도움이 됩니다. 그래서 모든 사용자에게 좋은 경험을 제공할 수 있도록 도울 수 있습니다.

마지막으로, 접근성 대응으로 앱의 품질을 향상시킵니다. 보이스오버를 사용하려면, UI 요소가 올바르게 구조화되고 라벨링이 되어 있어야 합니다. 이는 앱의 구조와 흐름을 개선하여, 결국 앱의 품질을 높이는 결과를 가져옵니다.

위와 같은 이유로 접근성 대응을 진행하지만, Accessibility Inspector 등의 이용하여 확인해야 합니다. 이는 애플리케이션을 빌드하고 실행한 상태에서 확인이 가능하다는 의미로, 접근성 요소를 확인하고 수정하고 확인하는데 시간이 오래 걸릴 수 있다는 이야기입니다.

그러면 접근성을 대응하기 위해 더욱 빠른 방법으로 접근성 요소를 확인할 수 있는 방법을 찾아야 합니다.

## Preview 상에서 UIKit 기반 뷰를 접근성 요소을 출력하여 확인하기

UIKit 기반 뷰의 접근성을 확인하려면 애플리케이션으로 빌드하고 실행해야 하며, 이는 시간이 많이 걸릴 수 있습니다.

SwiftUI가 나오면서, `Preview` 기능이 지원되었습니다. UIKit 기반 뷰도 Preview를 통해 확인할 수 있습니다.

`Xcode 14.3` 이전 버전까지는 Preview에서 print 같은 로그를 출력하면 Xcode의 콘솔창에 출력이 되지 않았습니다. Xcode 14.3의 [Release Notes](https://developer.apple.com/documentation/xcode-release-notes/xcode-14_3-release-notes#New-Features)에서 드디어 Preview에서 Swift의 print 함수를 호출하여 콘솔에 출력되는 기능이 지원되었습니다.

```
print output now appears in the console for SwiftUI Previews by selecting “Preview” tab in the console. Currently output is limited to Swift’s print function. (96569171)
```

뷰의 접근성 요소를 찾고, 해당 뷰에 순번 뱃지를 붙이고, 해당 순번의 접근성 요소를 콘솔에 출력하면 접근성 대응을 좀 더 쉽고 빠르게 대응할 수 있을 것입니다.

### 접근성 요소 찾기

접근성 요소를 찾는 것은 꽤나 귀찮은 일입니다. 하지만 뱅크샐러드에서 접근성 대응하기 위해 만든 [banksalad/AXSnapshot](https://github.com/banksalad/AXSnapshot) 라이브러리를 이용하여 접근성 요소를 찾을 것입니다.

첫 번쨰로, `AXSnapshot` 패키지를 추가합니다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2023/05/01.png" style="width: 600px; border: 1px solid #555;"/></p><br/>

다음으로, `VoiceOver`로 접근할 수 있는 `모든 서브 뷰`를 `exposedAccessibleViews`를 통해 얻은 다음, 뱃지를 붙이려고 합니다.

```swift
import AXSnapshot
import UIKit

extension UIView {
    func printA11y() {
        exposedAccessibleViews()
            .enumerated()
            .forEach { index, view in
                let label = BadgeLabelBuilder().build(index: index+1)
                view.addSubview(label)
            }
    }
}

struct BadgeLabelBuilder {
    init() {}
    func build(index: Int) -> UILabel {
        let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen]
        let label = UILabel()
        label.text = "\(index)"
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .white
        label.backgroundColor = colors[index%colors.count].withAlphaComponent(0.5)
        label.isUserInteractionEnabled = false
        label.accessibilityTraits = .none
        label.isAccessibilityElement = false
        label.textAlignment = .center
        label.sizeToFit()

        let size = label.bounds.size
        let max = max(size.width, size.height)
        label.frame.size = .init(width: max, height: max)
        label.frame.origin = .init(x: -max/2, y: -max/2)

        label.layer.cornerRadius = max / 2
        label.layer.masksToBounds = true
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = 1
        
        return label
    }
}
```

위의 코드를 통해 뱃지를 붙일 준비는 끝났습니다. 그러면 `ViewController`를 만들고, `ViewController`의 `view`에 `printA11y` 함수가 잘 동작하는지 확인해 봅시다.

```swift
import AXSnapshot
import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            let label = UILabel(frame: .init(x: 80, y: 100, width: 200, height: 50))
            label.text = "Hello"
            label.backgroundColor = .systemBlue.withAlphaComponent(0.2)
            view.addSubview(label)
        }
        
        do {
            let label = UILabel(frame: .init(x: 80, y: 200, width: 200, height: 50))
            label.text = "World"
            label.backgroundColor = .systemBlue.withAlphaComponent(0.2)
            
            view.addSubview(label)
        }
        
        do {
            let button = UIButton(frame: .init(x: 80, y: 300, width: 200, height: 100))
            button.backgroundColor = .systemTeal
            button.setTitle("Button", for: .normal)
            view.addSubview(button)
        }

        do {
            let view = UIView(frame: .init(x: 80, y: 450, width: 200, height: 100))
            view.backgroundColor = .systemBlue
            view.isAccessibilityElement = true
            view.accessibilityLabel = "Empty View"
            self.view.addSubview(view)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self else { return }
            view.exposedAccessibleViews()
                .enumerated()
                .forEach { index, view in
                    let label = BadgeLabelBuilder().build(index: index+1)
                    view.addSubview(label)
                }
        }
    }
}
```

1초 후 `printA11y` 함수를 호출한 이유는 뷰의 배치가 완료되고 뱃지가 붙을 수 있도록 하기 위함입니다. 가볍게 확인하기 위해 `UIView`의 `Life Cycle`과 `UIViewController`의 `Life Cycle`을  무시해도 된다고 가정합니다.

이제 ViewController를 확인해 봅시다.

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2023/05/02.png" style="width: 400px;"/></p><br/>

뱃지 뷰가 잘 붙어 있는 것을 볼 수 있습니다.

다음으로, 앞에서 만들었던 `printA11y` 함수에 `AXSnapshot` 라이브러리의 `axSnapshot` 함수를 이용하여 접근성 요소를 출력하도록 합니다.

```swift
extension UIView {
    func printA11y() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self else { return }
            exposedAccessibleViews()
                .enumerated()
                .forEach { index, view in
                    let label = BadgeLabelBuilder().build(index: index+1)
                    view.addSubview(label)
                }
            print(axSnapshot())
        }
    }
}
```

이제 접근성 요소가 다음과 같이 출력됩니다.

```text
------------------------------------------------------------
Hello
staticText
------------------------------------------------------------
World
staticText
------------------------------------------------------------
Button
button
------------------------------------------------------------
Empty View
------------------------------------------------------------
```

이제 Preview에서 접근성 요소를 출력하는 기능을 테스트해 보겠습니다. 

UIKit 기반의 뷰를 Preview로 볼 수 있는 방법은 몇 가지가 있습니다. 

```swift
import SwiftUI

struct UIViewPreview<View: UIView>: UIViewRepresentable {
    let view: View
    
    init(_ builder: @escaping () -> View) {
        view = builder()
    }
    
    // MARK: - UIViewRepresentable
    
    func makeUIView(context: Context) -> UIView {
        return view
    }
    
    func updateUIView(_ view: UIView, context: Context) {
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}

struct UIViewControllerPreview: UIViewControllerRepresentable {
    let viewController: UIViewController
    
    func makeUIViewController(context: Context) -> UIViewController {
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}

extension UIViewController {
    var preview: UIViewControllerPreview {
        UIViewControllerPreview(viewController: self)
    }
}
```

`UIViewPreview`와 `UIViewControllerPreview`에서 `View`를 얻어, 아까 작성했던 `printA11y` 함수를 통해 접근성 요소를 출력하도록 합니다.

```swift
extension UIViewPreview {
    func printA11y() -> Self {
        view.printA11y()
        return self
    }
}

extension UIViewControllerPreview {
    func printA11y() -> Self {
        viewController.view.printA11y()
        return self
    }
}

struct ViewController_Preview: PreviewProvider {
    static var previews: some View {
        ViewController()
            .preview
            .printA11y()
            .previewLayout(.sizeThatFits)
    }
}
```

<p style="text-align:left;"><img src="{{ site.production_url }}/image/2023/05/03.png" style="width: 800px; border: 1px solid #555;"/></p><br/>

AXSnapshot 라이브러리를 사용하여 접근성 요소를 가져와 뷰에 뱃지를 붙였습니다. 이렇게 하면 접근성 요소를 식별하고 콘솔에서 빠르고 쉽게 확인할 수 있습니다.

## 참고자료

* GitHub
  * [banksalad/AXSnapshot](https://github.com/banksalad/AXSnapshot)
  * [cashapp/AccessibilitySnapshot](https://github.com/cashapp/AccessibilitySnapshot)
  * [playbook-ui/accessibility-snapshot-ios](https://github.com/playbook-ui/accessibility-snapshot-ios)
  * [Sherlouk/AccessibilityPreview.swift](https://gist.github.com/Sherlouk/f3956b440333084ef9ea1e505856500c)
  * [google/GTXiLib](https://github.com/google/GTXiLib)
  * [rwapp/A11yUITests](https://github.com/rwapp/A11yUITests)
* Twitter
  * https://twitter.com/JamesSherlouk/status/1534607524862865411
* [Reveal](https://revealapp.com/)
  * Twitter - https://twitter.com/reveal_app/status/1529212001771483137
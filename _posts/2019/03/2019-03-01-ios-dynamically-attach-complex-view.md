---
layout: post
title: "[iOS] 스토리보드에서 특정 화면에서만 사용하는 복잡한 뷰를 분리하여 동적으로 붙이기"
description: ""
category: "iOS/Mac"
tags: [iOS, XCode, Storyboard, Autolayout]
---
{% include JB/setup %}

XCode에서 제공하는 스토리보드는 애증의 기능입니다. 좋긴 하지만 한편으로는 불편한 것도 많기 때문이죠. 그러한 스토리보드의 장점 중 하나를 이야기 해보려합니다.

스토리보드에서는 특정 화면에서만 사용하는 일회성 뷰를 만들어 사용할 수 있습니다. 이렇게 말이죠.

<p style="text-align:center;"><img src="{{ site.production_url }}/image/2019/03/001.png" style="width: 700px"/></p><br/>

일회성 뷰는 필요한 경우 다음과 같이 코드로 뷰를 붙여넣습니다.

```
class ViewController: UIViewController {

  @IBOutlet weak var sampleView: UIView!

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(sampleView)
    view.leadingAnchor.constraint(equalTo: sampleView.leadingAnchor, constant: 0).isActive = true
    view.trailingAnchor.constraint(equalTo: sampleView.trailingAnchor, constant: 0).isActive = true
    view.centerYAnchor.constraint(equalTo: sampleView.centerYAnchor, constant: 0).isActive = true
    sampleView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    sampleView.translatesAutoresizingMaskIntoConstraints = false
  }
}
```

이와 같이 동적으로 뷰를 추가하여 결과를 확인할 수 있습니다.

<p style="text-align:center;"><img src="{{ site.production_url }}/image/2019/03/002.png" style="width: 300px"/></p><br/>

따라서 스토리보드의 작은 화면에 많은 UI 요소를 넣는 것 보단, 위와 같이 일회성 뷰를 만들어 정리하고, 코드로 넣는 방식이 더 나을 수도 있습니다.
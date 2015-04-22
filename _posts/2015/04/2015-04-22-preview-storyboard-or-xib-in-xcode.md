---
layout: post
title: "Xcode에서 Storyboard 또는 Xib 미리보기"
description: ""
category: "Mac/iOS"
tags: [xcode, storyboard, xib, adaptive layout, preview, autolayout]
---
{% include JB/setup %}

어제 Adaptive Layout을 보면서 3.5-inch, 4-inch, 4.7-inch, 5.5-inch를 대응하는 부분을 설명해주는데 Xcode에서 각각의 단말마다의 크기에 따른 화면을 preview로 보여주는 것을 보고 이런 것이 있었구나라고 알았습니다.

딱히 현업분들은 놀랄 것은 아니긴 하지만 저에겐 공백기 동안에 못해봤던 것을 이제 해보고 있으니까요.

### Preview

Xcode에서 Storyboard나 Xib 화면에서 각기 다른 화면 크기에 맞는 Preview를 볼 수 있습니다.

일반적으로 Xcode는 Standard Editor 형태로 구성되어 있는데 Assistant Editor 모드로 변경합니다.

상단 메뉴에서 Assistant Editor로 변경하거나 우측 상단 메뉴 버튼에서도 변경할 수 있습니다.

<img src="/../../../../image/2015/preview_assistent_editor_1.png" alt="" style="width: 600px;"/><br/><br/>
<br/><img src="/../../../../image/2015/preview_assistent_editor_2.png" alt="" style="width: 150px;"/><br/><br/>

이제 Storyboard 또는 Xib 파일을 선택하고 Assistant Editor창에서 다음과 같이 Storyboard 또는 Xib 파일을 선택합니다.

<br/><img src="/../../../../image/2015/preview_assistent_editor_3.png" alt="" style="width: 600px;"/><br/><br/>

마지막으로 동일한 과정으로 Preview를 선택합니다.

<br/><img src="/../../../../image/2015/preview_assistent_editor_4.png" alt="" style="width: 600px;"/><br/><br/>

Assistant Editor에는 IPhone 4-inch Portrait이 보여집니다.

<br/><img src="/../../../../image/2015/preview_assistent_editor_5.png" alt="" style="width: 800px;"/><br/><br/>

여러 화면을 추가한다면 Assistant Editor 좌측 하단의 + 버튼을 통해 3.5-inch, 4-inch, 4.7-inch, 5.5-inch, iPad를 추가할 수 있고, 화면을 회전시켜 Portrait 또는 Landscape를 볼 수 있습니다. 그리고 같은 크기의 Preview를 추가한다면 Portrait와 Landscape 화면을 동시에 볼 수 있습니다.preview

또한, 화면의 크기를 Compact, Any, Regular로 변경하여 화면 구성을 각기 달리하여 적용되는 모습을 바로 볼 수 있습니다.

### Tip

Label, Button 등에서 사용하는 Font를 화면 크기에 맞게 변경할 수 있습니다.

Attributes Inspector 창에서 Font 속성 왼쪽에 + 버튼을 통해 Compact, Any, Regular 크기에 맞게 설정할 수 있습니다.

<br/><img src="/../../../../image/2015/preview_assistent_editor_6.png" alt="" style="width: 300px;"/><br/><br/>
<br/><img src="/../../../../image/2015/preview_assistent_editor_7.png" alt="" style="width: 300px;"/><br/><br/>

### 마무리

Adaptive Layout을 이제서야 살펴보면서 CSS의 Media Query를 보는 것 같은 느낌을 받았습니다. 6월이면 WWDC가 열리는데 이제 AutoLayout을 쓰지 않는다면 사실상 화면을 구성하는데 어려움이 상당하지 않을까 합니다. 

### 참고 자료

* [Size Classes in iOS 8 (Jack)][Size_Classes_Youtube]

<br/>

[Size_Classes_Youtube]: https://www.youtube.com/watch?v=2cz9VnXAKUo
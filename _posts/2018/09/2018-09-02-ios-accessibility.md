---
layout: post
title: "[iOS] 접근성 정리"
description: ""
category: "iOS/Mac"
tags: [Accessibility, iOS, VoiceOver, Accessibility]
---
{% include JB/setup %}

비장애인에게는 화면이 보이므로 원하는 정보를 받을 수 있지만, 장애인에게는 정보를 제공하기가 어렵습니다. 이를 VoiceOver Screen을 이용하여 접근성을 제공합니다.

## iOS 접근성 정리 

주로 사용하거나 사용할 것들을 우선 정리하였습니다.

### Accessibility Attributes

* isAccessibilityElement
: 접근성 요소 여부이며, UIKit Control은 기본 값이 true입니다. 값을 true로 설정하면 해당 요소에 초점이 이동 가능합니다.

* accessibilityLabel
: 레이블을 설정하면 설정한 텍스트를 읽어줍니다. 만약 해당 요소가 버튼인 경우, 설정한 이름 뒤에 `버튼` 이라고 읽어줍니다.

* accessibilityHint
: 요소를 동작시키기 위한 방법을 안내합니다.

* accessibilityValue
: 값이 달라지는 경우에 사용하며, 슬라이더의 값이나 텍스트 필드의 값에 사용할 수 있습니다. 예를 들어, Label은 "볼륨"으로 설정하고, "60%"로 value를 설정합니다.

* accessibilityTraits
: 모든 접근성 특성의 조합을 반환합니다. 아무런 특성을 가지지 않는 `UIAccessibilityTraitNone`을 설정하거나 버튼으로 다루는 요소라면 `UIAccessibilityTraitButton`로 설정할 수 있습니다.
: 해당 속성은 `UIAccessibilityConstants.h` 에서 확인할 수 있습니다.

* accessibilityFrame
: 스크린 내의 초점의 frame을 설정할 수 있습니다.

* shouldGroupAccessibilityChildren
: 그룹화된 뷰의 요소에 초점을 먼저 초점을 이동하도록 합니다.
: 이 속성은 초점이 왼쪽 상단에서 오른쪽 하단으로 이동하므로, 정보가 수직으로 나열되어 있을 때 유용합니다.
: 디자인에 따라 `shouldGroupAccessibilityChildren` 을 설정하여 접근성을 좀 더 쉽게 설정할 수 있습니다.

```
| Group A | Group B | Group C | 
| LabelA1 | LabelB1 | LabelC1 |
| LabelA2 | LabelB2 | LabelC2 |
| LabelA3 | LabelB3 | LabelC3 |

위와 같이 화면이 구성되어 진 경우, shouldGroupAccessibilityChildren 값에 따라 읽는 방식이 달라집니다.

/// shouldGroupAccessibilityChildren가 false인 경우
읽는 순서 : Group A -> Group B -> Group C -> LabelA1 -> LabelB1 -> LabelC1 -> LabelA2 -> LabelB2 ...

/// shouldGroupAccessibilityChildren가 true인 경우
groupAStack.shouldGroupAccessibilityChildren = true
groupBStack.shouldGroupAccessibilityChildren = true
groupCStack.shouldGroupAccessibilityChildren = true
읽는 순서 : Group A -> LabelA1 -> LabelA2 -> LabelA3 -> Group B -> LabelB1 -> LabelB2 -> LabelB3 -> Group C ...
```

* accessibilityElementsHidden
: 모든 접근성 요소를 숨겨 초점이 해당 요소로 이동하지 못하게 합니다.

* accessibilityViewIsModal
: 해당 접근성 요소가 Modal 뷰인지 설정하여, 해당 요소로 초점이 이동되면 해당 뷰 내에 접근성 요소로만 이동이 가능하며, 다른 요소로 이동할 수 없습니다.

### UIAccessibility Focus

* accessibilityElementDidBecomeFocused()
: 해당 접근성 요소에 초점을 설정하도록 합니다.

* accessibilityElementDidLoseFocus()
: 해당 접근성 요소에서 가상의 초점을 제거하도록 합니다.

* accessibilityElementIsFocused()
: 해당 접근성 요소에 초점이 걸려있는지 반환합니다.

### UIAccessibility Action - NSObject Extension

* accessibilityActivate
: 해당 접근성 요소가 활성화 되었었는지 반환합니다.

### UIAccessibilityPostNotification

변경사항 등이 있을 때, Notification을 통해 알립니다.

### Assistive Technology

* isVoiceOverRunning
: VoiceOver가 켜져있는지 여부를 반환합니다.

## 접근성 확인 Tip

* Chisel - LLDB
: FaceBook에서 만든 [Chisel](https://github.com/facebook/chisel) 툴의 `pa11y` 과 `pa11yi` 등 명령어를 이용하여 접근성 관련 정보를 쉽게 확인할 수 있습니다.

* Accessibility Inspector
: Apple에서 기본적으로 제공하는 Inspector으로 접근성이 잘 적용되어있는지 확인할 수 있습니다.


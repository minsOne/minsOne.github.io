---
layout: post
title: "iOS Accessibility"
description: ""
category: ""
tags: []
---
{% include JB/setup %}

비장애인에게는 화면이 보이므로 원하는 정보를 받을 수 있지만, 장애인에게는 정보를 제공하기가 어렵습니다. 이를 VoiceOver Screen을 이용하여 접근성을 제공합니다.

iOS에서는 Accessibility 속성들을 제공합니다.

## Accessibility Attributes

### isAccessibilityElement

접근성 요소 여부이며, UIKit Control은 기본 값이 true입니다. 값을 true로 설정하면 해당 요소에 초점이 이동 가능합니다.

### accessibilityLabel

레이블을 설정하면 설정한 텍스트를 읽어줍니다. 만약 해당 요소가 버튼인 경우, 설정한 이름 뒤에 `버튼` 이라고 읽어줍니다.

### accessibilityHint

요소를 동작시키기 위한 방법을 안내합니다.

### accessibilityValue

값이 달라지는 경우에 사용하며, 슬라이더의 값이나 텍스트 필드의 값에 사용할 수 있습니다. 예를 들어, Label은 "볼륨"으로 설정하고, "60%"로 value를 설정합니다.

### accessibilityTraits

모든 접근성 특성의 조합을 반환합니다. 아무런 특성을 가지지 않는 `UIAccessibilityTraitNone`을 설정하거나 버튼으로 다루는 요소라면 `UIAccessibilityTraitButton`로 설정할 수 있습니다.

해당 속성은 `UIAccessibilityConstants.h` 에서 확인할 수 있습니다.

### accessibilityFrame

스크린 내의 초점의 frame을 설정할 수 있습니다.

### shouldGroupAccessibilityChildren

그룹화된 뷰의 요소에 초점을 먼저 초점을 이동하도록 합니다.

### accessibilityElementsHidden

모든 접근성 요소를 숨겨 초점이 이동하지 못하게 합니다.

## UIAccessibility Focus - NSObject Extension

### accessibilityElementDidBecomeFocused()

해당 접근성 요소에 가상의 포커스를 설정하도록 합니다.

### accessibilityElementDidLoseFocus()

해당 접근성 요소로 부터 가상의 포커스를 제거하도록 합니다.

### accessibilityElementIsFocused()

해당 접근성 요소에 초점이 걸려있는지 반환합니다.

## UIAccessibility Action - NSObject Extension

### accessibilityActivate

해당 접근성 요소가 활성화 되었었는지 반환합니다.

### WIP: accessibilityIncrement
### WIP: accessibilityDecrement
### WIP: accessibilityPerformEscape
### WIP: accessibilityPerformMagicTap

## WIP: UIAccessibilityPostNotification

## WIP: Assistive Technology
### WIP: UIAccessibilityIsVoiceOverRunning

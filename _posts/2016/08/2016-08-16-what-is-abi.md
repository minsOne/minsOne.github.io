---
layout: post
title: "ABI - Application Binary Interface"
description: ""
category: "programming"
tags: [abi, swift]
---
{% include JB/setup %}

[Swift 4를 시작했음](https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20160725/025676.html)을 보고 관련된 내용을 살펴보는데 ABI라는 처음보는 단어가 나와 찾아보았습니다.

ABI는 Application Binary Interface(응용 프로그램 이진 인터페이스)의 줄임말로 응용 프로그램과 운영체제 또는 응용 프로그램과 라이브러리, 응용프로그램의 구성 요소간에 사용되는 저수준 인터페이스이며 바이너리에서 호환이 가능합니다. 그래서 Swift가 버전이 올라가더라도 CPU가 다르더라도, iOS 버전이 다르더라도 호환 가능합니다. 

따라서 ABI를 변경하는 것은 호환성과 안정성을 고려해야되므로 쉽지 않지만, 새로운 기능을 추가하는 것은 문제가 되지 않습니다.

Swift의 ABI 문서는 [Swift - ABI](https://github.com/apple/swift/blob/master/docs/ABI.rst)에서 확인하실 수 있습니다.

ps. rst 파일이 [reStructuredText](https://en.wikipedia.org/wiki/ReStructuredText)포맷이라는 것을 처음 알았습니다. -_-
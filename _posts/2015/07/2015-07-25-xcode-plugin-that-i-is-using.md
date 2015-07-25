---
layout: post
title: "[Xcode]사용하고 있는 플러그인 리스트"
description: ""
categories: [tool]
tags: [xcode, ios, mac, plugin, tool]
---
{% include JB/setup %}

### Xcode Plugin

회사를 그만두어 10개월을 쉬고 본격적으로 일한지 2달이 지난 시점에서 어느정도 일도 알겠고, 코드도 거의 다 본 상태가 되었습니다. 그래서 코드 리팩토링 및 신규 기능을 위한 코드 작성을 하기 위해서 미뤄두었던 플러그인을 설치하였습니다.

**1.[XCActionBar](https://github.com/pdcgomes/XCActionBar)**

Alfred, LaunchBar 같은 형태로 명령을 내릴 수 있는 플러그인으로, 잘 다루면 막강하게 사용할 수 있습니다.

![](https://raw.githubusercontent.com/pdcgomes/XCActionBar/master/demo.gif)

![](https://raw.githubusercontent.com/pdcgomes/XCActionBar/master/demo2.gif)

![](https://raw.githubusercontent.com/pdcgomes/XCActionBar/master/demo3.gif)

<br/>
**2.[XAlign](https://github.com/qfish/XAlign)**

XCActionBar에서도 같은 기능을 지원하지만 변수들을 깔끔하게 볼 수 있게 해줍니다.

![](https://camo.githubusercontent.com/f61bfc31e144ad6a9d7ca26fa19547a3af5da8c6/687474703a2f2f7166692e73682f58416c69676e2f696d616765732f646566696e652e676966)

<br/>
**3.[SCXcodeSwitchExpander](https://github.com/stefanceriu/SCXcodeSwitchExpander)**

Switch문에서 모든 case를 추가하여 개발자가 빼먹어 실수하지 않도록 해줍니다.

![](https://camo.githubusercontent.com/d4ab3ba45af70951557adbf17a9d0deab47e519f/68747470733a2f2f646c2e64726f70626f7875736572636f6e74656e742e636f6d2f752f31323734383230312f534358636f6465537769746368457870616e6465722f534358636f6465537769746368457870616e646572312e676966)

<br/>
**4.[BBUFullIssueNavigator](https://github.com/neonichu/BBUFullIssueNavigator)**

issue navigator에서 항상 아쉬웠던 것은 내용이 길면 축약해서 보여준다는 점입니다. BBUFullIssueNavigator 플러그인은 내용을 더 볼 수 있게 해줍니다.

![](https://raw.githubusercontent.com/neonichu/BBUFullIssueNavigator/master/screenshot.png)

<br/>
**5.[VVDocumenter-Xcode](https://github.com/onevcat/VVDocumenter-Xcode)**

이전에도 소개했었던 javadoc 스타일로 주석을 만들어주는 플러그인입니다. [이전 글](../vvdocumenter-xcode-plugin-for-writing-javadoc-style-document/)

<br/>
**6.[KSImageNamed-Xcode](https://github.com/ksuther/KSImageNamed-Xcode)**

이미지 이름을 찾기 위해서 찾아서 검색해야 했는데, 미리 보기를 통해 원하는 이미지를 빠르게 찾을 수 있습니다.

![](https://camo.githubusercontent.com/c354bf04524df86daeabe7a6d2b9926fac790f85/68747470733a2f2f7261772e6769746875622e636f6d2f6b7375746865722f4b53496d6167654e616d65642d58636f64652f6d61737465722f73637265656e73686f742e676966)

<br/>
**7.[XcodeBoost](https://github.com/fortinmike/XcodeBoost)**

복사, 단어 강조 등의 기능이 있는데 저는 메소드 선언부만을 복사하여 붙여넣을 수 있는 기능을 주로 사용하고 있습니다.

![](https://raw.githubusercontent.com/fortinmike/XcodeBoost/master/Images/copy-method-declarations.gif)

<br/>더 많은 플러그인을 찾고 싶으시면 [cocoanaut](http://cocoanaut.com/tools/xcode-plugins) 또는 Github에서 검색하여 찾으시면 됩니다.

<br/>ps. 자잘한 부분들은 손으로 하기 귀찮아져서 점점 능력자분들이 만들어 놓은 툴을 쓰게 되네요.

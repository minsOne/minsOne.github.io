---
layout: post
title: "[Xcode11 Beta1] Chisel 동작하지 않는 문제 - 해결"
description: ""
category: "iOS/Mac"
tags: [Chisel, Xcode, python2, python3, python, Chisel]
---
{% include JB/setup %}

Xcode 11 베타 버전에서는 Chisel이 동작하지 않습니다. LLDB의 Python 을 Python 3를 기본으로 채택하고 있어, Python 2으로 작성되어 있는 Chisel이 동작하지 않기 때문입니다. [링크](https://developer.apple.com/documentation/xcode_release_notes/xcode_11_beta_release_notes#3319453)

따라서 다음과 같이 LLDB의 Python 버전을 Python 2로 설정하면 Chisel을 사용할 수 있습니다.

```
$ defaults write com.apple.dt.lldb DefaultPythonVersion 2
```

## 참고자료
* [Chisel - Issue](https://github.com/facebook/chisel/issues/262)
* [Xcode 11 Release Notes](https://developer.apple.com/documentation/xcode_release_notes/xcode_11_beta_release_notes#3319453)
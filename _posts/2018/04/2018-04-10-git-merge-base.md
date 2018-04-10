---
layout: post
title: "[Git]현재 Branch의 변경사항 파악하기 - merge-base"
description: ""
category: Git
tags: [git, merge-base, diff, SwiftLint]
---
{% include JB/setup %}

이번에 Pull Request를 올리면서 Gitlab Trigger를 통해 Lint를 돌리는 스크립트를 만들었습니다. 

현재 Lint를 돌렸을 때, 변경사항들이 너무 많아 한번에 일괄 수정하는 것은 무리가 있는 것으로 판단하여 현재 Branch의 수정 파일만 Lint를 돌리는 것으로 고려하였습니다. 

```
A : D-E-F-G
    |
B : Y-X-Z
```

Branch A와 B가 있고 B는 Branch A에 merge 되는 구조일때, Branch B가 Branch A로부터 나온 지점을 `merge-base`를 통해 찾을 수 있습니다.

```
$ git merge-base --fork-point A B
```

따라서 Branch B는 diff 범위를 `merge-base`를 통해 얻을 수 있습니다.

```
$ git diff $(git merge-base --fork-point A)
```

## 출처

* [stackoverflow](https://stackoverflow.com/a/29813554/2749449)

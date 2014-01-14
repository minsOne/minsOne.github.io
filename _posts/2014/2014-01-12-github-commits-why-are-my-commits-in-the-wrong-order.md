---
layout: post
title: "[번역]GitHub / Commits / 왜 커밋 순서가 잘못되었나요?"
description: ""
categories: [translate, Commits]
tags: [git, GitHub, rebase, commit]
---
{% include JB/setup %}

다음의 [Why are my commits in the wrong order?](https://help.github.com/articles/why-are-my-commits-in-the-wrong-order) 번역하였습니다.

---

## 왜 커밋 순서가 잘못되었나요?

`git rebase`나 강제 Push를 통해 커밋 히스토리를 재작성했다면 Pull 요청을 열었을 때 커밋 순서가 잘못되었다고 알 수 있습니다.

GitHub은 토론을 위한 공간으로 Pull 요청을 강조합니다. 모든 형태(주석, 참조, 커밋)는 시간순서대로 표시됩니다. Git 커밋 히스토리를 재작성하는 것은 GitHub 인터페이스에서 예상대로 표시되지 않을 수 있다는 시공간 연속성 변경을 의미합니다.

이를 방지하려면 `git rebase`를 사용하지 않는 것이 좋습니다.
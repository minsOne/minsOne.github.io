---
layout: post
title: "[번역]GitHub / Commits / 왜 커밋 순서가 잘못되었나요?"
description: ""
categories: [Git]
tags: [git, github, rebase, commit]
---
{% include JB/setup %}

이 문서는 [Why are my commits in the wrong order?](https://help.github.com/articles/why-are-my-commits-in-the-wrong-order)의 비공식 번역글이며 GitHub에서 보증, 유지 또는 감독하지 않습니다. 공식 도움글을 보시려면 [help.github.com](https://help.github.com)을 방문하세요.

---

## 왜 커밋 순서가 잘못되었나요?

커밋 히스토리를 재작성할 때 `git rebase`을 이용하거나 강제로 Push한다면 Pull 요청을 열었을 때 커밋이 시간 순으로 보이지 않습니다.

GitHub은 Pull 요청을 토론 장소로써 중요하게 여기기에 주석, 참조, 커밋 등 모든 요소는 시간순으로 정렬됩니다. Git 커밋 히스토리를 재작성한다는 건 시공간 연속성을 변경을 의미합니다. 즉, 해당 커밋은 GitHub 인터페이스에서 당신이 원하는 대로 보이지 않습니다.

이런 일을 방지하는 차원에서 `git rebase` 사용을 권장하지 않습니다.
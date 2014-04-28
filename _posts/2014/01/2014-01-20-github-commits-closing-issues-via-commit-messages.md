---
layout: post
title: "[번역]GitHub / Commits / 커밋 메시지로 이슈 닫기"
description: ""
categories: [git]
tags: [git, github, commit, message, issue]
---
{% include JB/setup %}

이 문서는 [Closing issues via commit messages](https://help.github.com/articles/closing-issues-via-commit-messages)의 비공식 번역글이며 GitHub에서 보증, 유지 또는 감독하지 않습니다. 공식 도움글을 보시려면 [help.github.com](https://help.github.com)을 방문하세요.

---

## 커밋 메시지로 이슈 닫기

커밋 메시지는 강력한 기능입니다. 커밋 메시지는 당신이 생각한 것을 공동 제작자에게 설명할 수 있으며 [`git blame`을 하는 동안 정보를 제공하고](https://help.github.com/articles/using-git-blame-to-trace-changes-in-a-file) Github에 커밋 메시지로 이슈를 닫을 수 있습니다.

커밋 메시지에 "Fixed #45"를 입력하면 이슈 45번은 기본 브랜치에 커밋이 합쳐질 때 닫힙니다. 기본 브랜치에 버그가 수정되지 않으면 이슈는 열린 상태로 남습니다. 커밋과 수정사항이 기본 브랜치에 합쳐지면 이슈는 자동으로 닫힙니다.

"Fixes #33" 문장이 있는 커밋이 기본 브랜치가 아니라면 이슈는 도구상자(Tooltip)과 참조됩니다.

커밋 메시지로 이슈를 닫을 수 있는 다음 키워드를 사용할 수 있습니다:

- close
- closes
- closed
- fix
- fixes
- fixed
- resolve
- resolves
- resolved

### 저장소를 거쳐 이슈 닫기

[GFM 표기한 저장소](https://help.github.com/articles/github-flavored-markdown#references)를 참조하면 마찬가지로 저장소를 거쳐 이슈를 닫을 수 있습니다. 예를 들어 커밋 메시지에 "fixes user/repo#45"를 넣으면 참조된 이슈를 닫고 저장소에 Push할 수 있는 권한을 얻습니다.

### Pull 요청과 이슈 닫기

Pull 요청 설명에 "closed" 키워드가 포함되면 이슈를 닫을 수 있습니다. 다만 커밋 메시지와 같이 기본 브랜치에 버그가 수정되지 않았다면 이슈는 열린 상태로 남습니다. 이슈는 Pull 요청이 기본 브랜치에 합쳐질 때만 자동으로 닫힙니다.

<div class="alert-info"><strong>팁</strong>: 참조하는 이슈 번호가 있는 Pull 요청 제목으로 이슈를 닫을 수 없습니다. 참조 번호가 커밋 메시지에 있거나 Pull 요청 내용(Body)에 있어야 합니다.</div>

### 여러 이슈 닫기

여러 이슈를 닫으려면 간단히 각각의 이슈에 같은 문장을 여러번 사용하면 됩니다.

예를 들어 "This fixes #34 and also resolves #23, closes user/repo#42"는 이슈 34번과 23번을 닫고, 마찬가지로 user/repo에 이슈 42번을 닫습니다.
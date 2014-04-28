---
layout: post
title: "[번역]GitHub / Collaborating / Pull 요청 정리하기"
description: ""
categories: [Git]
tags: [git, github, translate, collaborating, pull]
---
{% include JB/setup %}

이 문서는 [Tidying up Pull Requests](https://help.github.com/articles/tidying-up-pull-requests)의 비공식 번역글이며 GitHub에서 보증, 유지 또는 감독하지 않습니다. 공식 도움글을 보시려면 [help.github.com](https://help.github.com)을 방문하세요.

---

### Pull 요청 정리하기

Pull 요청을 닫거나 합친 후에는 많은 양의 소멸된 브랜치들을 결국 가지게 됩니다. 그래서 정규 작업 절차의 부분으로 소멸된 브랜치들을 지우는 방법을 제공합니다.

### Pull 요청 삭제하기

Pull 요청을 합친 후에 오래 끄는 브랜치를 삭제할 수 있는 버튼을 볼 수 있을 것입니다.
![Delete Branch button](/../../../../image/2013/delete_branch_button.png)

<div class="alert-info"><strong>팁</strong>Push 접근 권한이 있는 저장소의 브랜치들만 삭제할 수 있습니다.</div>

### 삭제된 Pull 요청 복구하기

계속 필요한 브랜치를 실수로 삭제하였다면 닫힌 Pull 요청의 어떤 head 브랜치를 복구할 수 있습니다.

![Restore Branch link](/../../../../image/2013/delete_restore_branch_animation.gif)

<br/><br/>
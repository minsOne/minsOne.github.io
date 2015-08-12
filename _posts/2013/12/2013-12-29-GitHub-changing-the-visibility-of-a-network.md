---
layout: post
title: "[번역]GitHub / Collaborating / 네트워크의 가시성 변경하기"
description: ""
category: "Git"
tags: [git, github, translate, collaborating, network]
---
{% include JB/setup %}

이 문서는 [Changing the Visibility of a Network](https://help.github.com/articles/changing-the-visibility-of-a-network)의 비공식 번역글이며 GitHub에서 보증, 유지 또는 감독하지 않습니다. 공식 도움글을 보시려면 [help.github.com](https://help.github.com)을 방문하세요.

---

## 네트워크의 가시성 변경하기

이 기사는 저장소의 가시성을 변경하거나 저장소를 삭제할 때 발생하고 저장소에서 만들어진 fork에 영향을 미치는 데에 초점에 맞춰져 있습니다.

### 비공개 저장소 삭제하기

비공개 저장소를 삭제하면 모든 비공개 fork는 삭제가 됩니다.

### 공개 저장소 삭제하기

공개 저장소를 삭제하면 fork 중 하나가 새로운 부모 저장소로 선택됩니다. 다른 저장소들은 새로운 부모 밑으로 들어갑니다.

### 공개 저장소를 비공개 저장소로 변경하기

공개 저장소를 비공개 저장소로 변경하면 모든 fork는 공개 상태로 남습니다.

#### 비공개 저장소 삭제하기

만약 새로운 비공개 저장소가 삭제되면 공개 fork는 삭제되지 않습니다.

### 비공개 저장소를 공개 저장소로 변경하기

비공개 저장소를 공개 저장소로 변경하면 fork는 그대로 비공개 상태로 남습니다.

#### 공개 저장소 삭제하기

만약 새로운 공개 저장소가 삭제되면 비공개 fork는 공개 저장소 소유자에게 비용 청구 됩니다. 만약 이 경우를 고려하지 않다면, 지원 요청하시길 바랍니다.
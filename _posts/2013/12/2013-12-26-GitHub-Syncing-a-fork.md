---
layout: post
title: "[번역]GitHub / Collaborating / Fork 동기화"
description: "Fork 동기화"
categories: [Git]
tags: [git, github, translate, collaborating, fork]
---
{% include JB/setup %}

이 문서는 [Syncing a fork](https://help.github.com/articles/syncing-a-fork)의 비공식 번역글이며 GitHub에서 보증, 유지 또는 감독하지 않습니다. 공식 도움글을 보시려면 [help.github.com](https://help.github.com)을 방문하세요.

---

## Fork 동기화

### 설정

동기화하기 전에 upstream 저장소가 가르키는 원격 저장소 주소를 추가 할 필요가 있습니다. 처음에 fork 했을 때 이 작업을 했을 수도 있습니다.


<div class="alert-info"><strong>팁</strong> : fork를 동기화 하는 것은 저장소의 로컬 복사본에만 최신으로 갱신 합니다. 이것은 GitHub에 있는 저장소에는 갱신하는 것이 아닙니다.</div>

    $ git remote -v
    # List the current remotes
    # origin  https://github.com/user/repo.git (fetch)
    # origin  https://github.com/user/repo.git (push)
    
    $ git remote add upstream https://github.com/otheruser/repo.git
    # Set a new remote
    
    $ git remote -v
    # Verify new remote
    # origin    https://github.com/user/repo.git (fetch)
    # origin    https://github.com/user/repo.git (push)
    # upstream  https://github.com/otheruser/repo.git (fetch)
    # upstream  https://github.com/otheruser/repo.git (push)

### 동기화

저장소와 upstream과의 동기화 하기 위해선 두 단계가 필요합니다. 첫번째는 원격 저장소에서 내려받아야 하고, 그리고 로컬 브랜치에 바라던 브랜치를 합칠 수 있습니다.

### 패치

원격저장소에서 패치는 브랜치들과 각각의 커밋들을 가져올 것입니다. 로컬 저장소 아래 특정 브랜치에 저장됩니다.

    $ git fetch upstream
    # Grab the upstream remote's branches
    # remote: Counting objects: 75, done.
    # remote: Compressing objects: 100% (53/53), done.
    # remote: Total 62 (delta 27), reused 44 (delta 9)
    # Unpacking objects: 100% (62/62), done.
    # From https://github.com/otheruser/repo
    #  * [new branch]      master     -> upstream/master

이제 로컬 브랜치 `upstream/master` 안에 저장된 upstream의 master 브랜치를 가지게 됩니다.

    $ git branch -va
    # List all local and remote-tracking branches
    # * master                  a422352 My local commit
    #   remotes/origin/HEAD     -> origin/master
    #   remotes/origin/master   a422352 My local commit
    #   remotes/upstream/master 5fdff0f Some upstream commit

#### 합치기

upstream 저장소를 가져온 지금, 로컬 저장소에 upstream 저장소의 변경사항을 합치길 원합니다. 로컬 변경사항을 잃지 않고 upstream과 동기한 브랜치를 가져올 것입니다.

    $ git checkout master
    # Check out our local master branch
    # Switched to branch 'master'
    
    $ git merge upstream/master
    # Merge upstream's master into our own
    # Updating a422352..5fdff0f
    # Fast-forward
    #  README                    |    9 -------
    #  README.md                 |    7 ++++++
    #  2 files changed, 7 insertions(+), 9 deletions(-)
    #  delete mode 100644 README
    #  create mode 100644 README.md

만약 로컬 브랜치가 유일한 커밋을 가지고 있지 않다면, git은 대신 fast-forwad로 수행할 것입니다.

<div class="alert-info"><strong>팁</strong> : 만약 GitHub에 당신의 저장소를 업데이트 하길 원한다면 [다음 과정](https://help.github.com/articles/pushing-to-a-remote#pushing-a-branch)을 따르면 됩니다.</div>
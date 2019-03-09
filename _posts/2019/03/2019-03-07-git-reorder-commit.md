---
layout: post
title: "[Git] Commit 순서를 섞기"
description: ""
category: "Git"
tags: [git, rebase]
---
{% include JB/setup %}

가끔씩 커밋의 순서를 바꿔야 할 때가 있습니다. 브랜치를 새로 만들고 cherry-pick 명령어를 이용해 순서를 바꿀 수도 있지만, `rebase` 명령어를 이용해서 순서 변경이 가능합니다.

```
AAAAAA CommitA
BBBBBB CommitB
CCCCCC CommitC
DDDDDD CommitD
```

다음과 같이 커밋이 있을 때, `rebase` 명령어를 입력합니다.

```
$ git rebase -i HEAD~4

pick AAAAAA CommitA
pick BBBBBB CommitB
pick CCCCCC CommitC
pick DDDDDD CommitD

# Rebase 000000..DDDDDD onto 000000 (4 commands)
#
# Commands:
# p, pick = use commit
# r, reword = use commit, but edit the commit message
# e, edit = use commit, but stop for amending
# s, squash = use commit, but meld into previous commit
# f, fixup = like "squash", but discard this commit's log message
# x, exec = run command (the rest of the line) using shell
# d, drop = remove commit
#
# These lines can be re-ordered; they are executed from top to bottom.
#
# If you remove a line here THAT COMMIT WILL BE LOST.
#
# However, if you remove everything, the rebase will be aborted.
#
# Note that empty commits are commented out
```

`interactive 옵션`을 이용하면 위와 같이 출력이 됩니다.

여기에서 커밋의 순서를 원하는 변경해주면 순서가 변경됩니다.

```
pick DDDDDD CommitD
pick CCCCCC CommitC
pick BBBBBB CommitB
pick AAAAAA CommitA

# Rebase 000000..DDDDDD onto 000000 (4 commands)
#
# Commands:
# p, pick = use commit
# r, reword = use commit, but edit the commit message
# e, edit = use commit, but stop for amending
# s, squash = use commit, but meld into previous commit
# f, fixup = like "squash", but discard this commit's log message
# x, exec = run command (the rest of the line) using shell
# d, drop = remove commit
#
# These lines can be re-ordered; they are executed from top to bottom.
#
# If you remove a line here THAT COMMIT WILL BE LOST.
#
# However, if you remove everything, the rebase will be aborted.
#
# Note that empty commits are commented out
```

<div class="alert warning"><strong>주의</strong> : 만약에 수정사항이 겹치는 파일이 있는 경우, 충돌이 발생하기 때문에 잘 살펴보고 해야 합니다.</div>
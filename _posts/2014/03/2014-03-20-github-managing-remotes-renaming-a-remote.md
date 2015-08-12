---
layout: post
title: "[번역]GitHub / Managing Remotes / 원격 저장소 이름 변경하기"
description: ""
category: "Git"
tags: [git, github, remote, origin, name, rename]
---
{% include JB/setup %}

이 문서는 [Renaming a remote](https://help.github.com/articles/renaming-a-remote)의 비공식 번역글이며 GitHub에서 보증, 유지 또는 감독하지 않습니다. 공식 도움글을 보시려면 [help.github.com](https://help.github.com)을 방문하세요.

---

## 원격 저장소 이름 변경하기

기존 원격 저장소 이름을 변경하기 위해 `git remote rename` 명령어를 사용합니다:

	$ git remote -v
	# View existing remotes
	origin  git@github.com:user/repo.git (fetch)
	origin  git@github.com:user/repo.git (push)

	$ git remote rename origin destination
	# Change remote name from 'origin' to 'destination'

	$ git remote -v
	# Verify remote's new name
	destination  git@github.com:user/repo.git (fetch)
	destination  git@github.com:user/repo.git (push)

<br/>두 개의 인자를 가집니다:
- 기존 원격 저장소 이름: `origin`
- 기존 원격 저장소의 새로운 이름 : `destination`

### Troubleshooting 문제 해결

#### 'remote.\[old name\]'을 'remote.\[new name\]'로 이름을 바꿀 수 없는 설정 부분

약간 애매한 이 에러는 입력된 기존 이름이 존재하지 않음을 의미합니다. `git remote -v` 명령어로 현재 원격 저장소를 확인할 수 있습니다:

	$ git remote -v
	# View existing remotes
	origin  git@github.com:user/repo.git (fetch)
	origin  git@github.com:user/repo.git (push)

#### 원격 저장소에 \[새로운 이름 \]이 존재합니다.

입력한 새로운 이름이 이미 같은 이름의 저장소가 있습니다. 다음 해결방안:

- 다른 새 이름을 사용하거나
- 기존 원격 저장소 이름을 변경합니다.

### Related documentation 관련 문서

- [Git remote man page](http://git-scm.com/docs/git-remote)
- [Pro Git - Working with Remotes](http://git-scm.com/book/ko/Git의-기초-리모트-저장소)
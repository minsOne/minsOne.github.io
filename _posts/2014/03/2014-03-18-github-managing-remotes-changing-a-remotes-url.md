---
layout: post
title: "[번역]GitHub / Managing Remotes / 원격 저장소 URL 변경하기"
description: ""
categories: [translate, GitHub]
tags: [git, GitHub, remote, origin, name]
---
{% include JB/setup %}

이 문서는 [Changing a remote's URL](https://help.github.com/articles/changing-a-remote-s-url)의 비공식 번역글이며 GitHub에서 보증, 유지 또는 감독하지 않습니다. 공식 도움글을 보시려면 [help.github.com](https://help.github.com)을 방문하세요.

---

## 원격 저장소 URL 변경하기

기존 원격 저장소 URL을 변경하기 위해 `git remote set-url` 명령어를 사용합니다:

	$ git remote -v
 	# View existing remotes
	origin  https://github.com/user/repo.git (fetch)
	origin  https://github.com/user/repo.git (push)

	$ git remote set-url origin https://github.com/user/repo2.git
	# Change the 'origin' remote's URL

 	$ git remote -v
	# Verify new remote URL
	origin  https://github.com/user/repo2.git (fetch)
	origin  https://github.com/user/repo2.git (push)

<br/>두개의 인자를 가집니다:
- 기존 원격 저장소 이름: `origin`
- 새로운 원격 저장소 URL : `https://github.com/user/repo2.git`

### Troubleshooting 문제 해결

#### No such remote '\[name\]'

이 에러는 이름을 변경할 원격 저장소가 없음을 의미합니다.

### 관련 문서

- [Git remote man page](http://git-scm.com/docs/git-remote)
- [Pro Git - Working with Remotes](http://git-scm.com/book/ko/Git의-기초-리모트-저장소)
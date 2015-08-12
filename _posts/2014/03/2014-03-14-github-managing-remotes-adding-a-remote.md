---
layout: post
title: "[번역]GitHub / Managing Remotes / 원격 저장소 추가하기"
description: ""
category: "Git"
tags: [git, git, remote, add, master, origin, track, name]
---
{% include JB/setup %}

이 문서는 [Adding a remote](https://help.github.com/articles/adding-a-remote)의 비공식 번역글이며 GitHub에서 보증, 유지 또는 감독하지 않습니다. 공식 도움글을 보시려면 [help.github.com](https://help.github.com)을 방문하세요.

---

## 원격 저장소 추가하기

새로운 원격 저장소를 추가해야 한다면 git remote add 명령어를 사용하세요:

	 $ git remote add origin https://github.com/user/repo.git
	 # Set a new remote
	 
	 $ git remote -v
	 # Verify new remote
	 # origin  https://github.com/user/repo.git (fetch)
	 # origin  https://github.com/user/repo.git (push)

이 명령어는 두개의 인자를 가집니다:

- remote name: `origin`
- repository URL: `https://github.com/user/repo.git`

URL을 사용하는게 확실치 않나요? [이 가이드](https://help.github.com/articles/which-remote-url-should-i-use)를 확인하세요.

### 추적 브랜치

You can also create a tracking branch as you create the remote:

원격 저장소를 생성한다면 추적 브랜치을 생성할 수 있습니다:

	 $ git remote add --track master origin  https://github.com/user/repo.git

마스터 브랜치를 확인할 때 git pull origin master를 할 필요 없이 git pull 작업을 하는데 유용합니다.

원격 저장소 브랜치에서 로컬 브랜치를 선택하면 자동으로 추적 브랜치라는 것을 생성하므로 유의하세요. 또한 저장소를 Clone 할 때 자동으로 origin/master를 추적하는 마스터 브랜치가 생성됩니다.

### 문제 해결

#### 원격 저장소 \[이름\]이 이미 존재하는 경우

이 에러는 추가하려는 원격 저장소 이름이 이미 로컬 저장소에 있음을 의미합니다. 이 문제를 해결하는 방법 : 

- 새로운 원격 저장소 이름을 다른 이름으로 사용하거나
- 기존 원격 저장소 이름을 바꾸거나
- 기존 원격 저장소를 삭제합니다.

### 관련된 문서

- [Git remote man page](http://git-scm.com/docs/git-remote)
- [Pro Git - 리모트 저장소](http://git-scm.com/book/ko/Git%EC%9D%98-%EA%B8%B0%EC%B4%88-%EB%A6%AC%EB%AA%A8%ED%8A%B8-%EC%A0%80%EC%9E%A5%EC%86%8C)
---
layout: post
title: "[번역]GitHub / Collaborating / Pull 요청을 로컬에서 확인하기"
description: ""
category: "Git"
tags: [git, github, translate, collaborating, pull]
---
{% include JB/setup %}

이 문서는 [Checking out Pull Requests locally](https://help.github.com/articles/checking-out-pull-requests-locally)의 비공식 번역글이며 GitHub에서 보증, 유지 또는 감독하지 않습니다. 공식 도움글을 보시려면 [help.github.com](https://help.github.com)을 방문하세요.

---

## Pull 요청을 로컬에서 확인하기

저장소에 누군가 fork에 pull 요청을 만들었다고 가정합시다. 여기에 컴퓨터에서 변경사항을 확인하는 것과 다 괜찮은지 검증하는 방법이 있습니다.

### Git 환경설정을 수정하기

`.git/config`파일에 GitHub 원격 저장소을 위한 구역이 있습니다. 다음을 보세요.

	[remote "origin"]
	  fetch = +refs/heads/*:refs/remotes/origin/*
	  url = git@github.com:<USERNAME>/<REPO_NAME>.git

이제 이 구역에 `fetch = +refs/pull/*/head:refs/remotes/origin/pr/*`를 추가합니다.

	[remote "origin"]
	  fetch = +refs/heads/*:refs/remotes/origin/*
	  url = git@github.com:<USERNAME>/<REPO_NAME>.git
	  fetch = +refs/pull/*/head:refs/remotes/origin/pr/*

이제 모든 Pull 요청을 가지고 옵니다.

	$git fetch origin
	From github.com:joyent/node
	 * [new ref]         refs/pull/1000/head -> origin/pr/1000
	 * [new ref]         refs/pull/1002/head -> origin/pr/1002
	 * [new ref]         refs/pull/1004/head -> origin/pr/1004
	 * [new ref]         refs/pull/1009/head -> origin/pr/1009

### 부분 Pull 요청을 확인하기

저장소에 특정 `pr/<:id>` 구문이 있는 Pull 요청을 확인할 수 있고, 여기에서 `<:id>`는 관심이 있는 Pull 요청 번호입니다. 예를 들면 Pull 요청 999번을 확인하려고 합니다.

	$ git checkout pr/999
	Branch pr/999 set up to track remote branch pr/999 from origin.
	Switched to a new branch 'pr/999'

[@piscisaureus](https://gist.github.com/piscisaureus/3342247)에 특별한 감사를 보냅니다.	
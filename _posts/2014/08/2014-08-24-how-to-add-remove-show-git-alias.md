---
layout: post
title: "Git Alias 추가 / 삭제 / 목록 보기"
description: ""
category: "git"
tags: [git,alias,config,shell,command]
---
{% include JB/setup %}

Git의 유용한 방법 중 하나인 Alias의 추가, 삭제 및 목록 명령어를 다음과 같이 사용할 수 있습니다.

#### Alias 추가

Alias 추가하는 명령어는 다음과 같습니다.

	//전역에 Alias 추가
	$ git config --global alias.ci commit

	//지역에 Alias 추가
	$ git config alias.ci commit


#### Alias 삭제

Alias 삭제하는 명령어는 다음과 같습니다.

	//전역 Alias 삭제
	$ git config --global --unset alias.ci

	//지역 Alias 삭제
	$ git config --unset alias.ci


#### Alias 목록 보기

Alias 목록을 보는 명령어는 다음과 같습니다.

	//전역 Alias 목록 보기
	$ git config --global --get-regexp alias

	//지역 Alias 목록 보기
	$ git config --local --get-regexp alias

	//전역 및 지역 Alias 목록 보기
	$ git config --get-regexp alias	
---
layout: post
title: "유용한 Git alias"
description: ""
category: "Git"
tags: [git, alias, command, shell, gitconfig]
---
{% include JB/setup %}

alias는 두가지 방법으로 사용할 수 있는데 .gitconfig 파일을 이용하는 방법과 git config 명령의 alias를 이용하는 방법이 있습니다.

전자는 .gitconfig 파일에 다음과 같이 작성합니다.

	[alias]
        ci = commit

후자는 다음과 같이 명령어를 작성합니다.
	
	$ git config --global alias.ci commit

Git 사용 시 기본적으로 사용하는 alias를 정리해봅니다.

	co = checkout
	br = branch
	ci = commit
	st = status
	cp = cherry-pick
	cl = clone

log 관련된 alias입니다.

	// 커밋에 어떤 내용이 변경되었는지를 보여주는 alias
	fl = log -u

	// 커밋 로그를 상대적인 시간으로 이쁘게 라인으로 보여주는 alias
	lrd = log --pretty=format:"%C(yellow)%h\\ %ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=relative

	// 커밋 로그에서 어떤 파일들이 추가되거나 삭제, 변경되었는지를 상세하게 보여주는 alias
	ll = log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --numstat

	// 커밋 히스토리를 그래프로 보여주는 alias
	tree = log --graph --oneline --decorate --all

파일 변경 관련한 alias입니다.

	// 변경 내역에 제외하고자 하는 alias
	assume = update-index --assume-unchanged

	// 변경 내역에 다시 추가하고자 하는 alias
	unassume = update-index --no-assume-unchanged

	// 변경 내역에서 제외된 파일을 보고자 하는 alias
	assumels = git ls-files -v | grep '^[[:lower:]]'
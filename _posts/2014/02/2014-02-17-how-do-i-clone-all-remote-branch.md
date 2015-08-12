---
layout: post
title: "[Git]Clone으로 받은 저장소에 브랜치로 이동하기"
description: ""
category: "Git"
tags: [git, clone, branch]
---
{% include JB/setup %}

Git에서 Clone으로 저장소를 내려받으면 저장소에 저장된 브랜치들을 사용할 수 있습니다. 그러나 처음에 `git branch`로 확인하였을 때 브랜치들이 보이지 않습니다.

	$ git branch
	 * master

`-a` 옵션을 사용하면 브랜치들을 볼 수 있습니다.

	$ git branch -a 
	remotes/origin/HEAD -> origin/master
	remotes/origin/draft
	remotes/origin/master

만약 원하는 upstream 브랜치로 이동하고자 한다면 직접 Checkout 할 수 있습니다.

	$ git checkout origin/draft

	Note: checking out 'origin/draft'.

	You are in 'detached HEAD' state. You can look around, make experimental
	changes and commit them, and you can discard any commits you make in this
	state without impacting any branches by performing another checkout.

	If you want to create a new branch to retain commits you create, you may
	do so (now or later) by using -b with the checkout command again. Example:

	  git checkout -b new_branch_name

	HEAD is now at cff5802... 임시 저장

그러나 이 경우에서는 임시로 해당 브랜치로 이동하는 것이기 때문에 로컬 브랜치가 만들어지지 않습니다. 다음과 같이 사용하면 로컬 브랜치를 만들 수 있습니다.

	$ git checkout -b draft origin/draft 
	Branch draft set up to track remote branch draft from origin.
	Switched to a new branch 'draft'

	$ git branch
	 * draft
	   maste

브랜치 이름을 짓지 않고 remote 저장소에 브랜치 이름을 그대로 로컬 브랜치로 생성하고자 한다면 `git checkout` 명령어에 `-t` 또는 `--track` 옵션을 사용합니다.

	$ git checkout --track origin/draft
	Branch draft set up to track remote branch draft from origin.
	Switched to a new branch 'draft'

	$ git branch
	 * draft
	   master

---
layout: post
title: "[번역]GitHub / Advanced Git / Subtree 병합 작업"
description: ""
categories: [translate, Advanced Git]
tags: [git, GitHub, merge, read-tree, subtree]
---
{% include JB/setup %}

다음의 [Working with subtree merge](https://help.github.com/articles/working-with-subtree-merge) 번역하였습니다.

---

## Subtree 병합 작업

submodule로 작업하기에 적합하지 않을 때가 있습니다. 예를 들면 다중 저장소를 단일 저장소로 각 저장소의 히스토리를 유지한 채로 합치는 경우가 있습니다. 이 작업을 하기 위해서는 subtree 병합 전략이 더 나은 해결책입니다.


### 설정과 첫번째 병합 작업

이 예제에서 빈 "부모" 저장소를 만들고 하위경로에 다른 저장소를 합칠 것입니다.

첫번째, 예제에서 빈 저장소를 설정합니다.

	$ mkdir test
	$ cd test
	$ git init
	# Initialized empty Git repository in /Users/tekkub/tmp/test/.git/
	$ touch .gitignore
	$ git add .gitignore
	$ git commit -m "initial commit"
	# [master (root-commit) 3146c2a] initial commit
	#  0 files changed, 0 insertions(+), 0 deletions(-)
	#  create mode 100644 .gitignore

이제 저장소에 [teknologic/Cork](https://github.com/teknologic/Cork)저장소를 `cork/`로 subtree-merge합니다.

	$ git remote add -f cork git://github.com/TekNoLogic/Cork.git
	# Updating cork
	# warning: no common commits
	# remote: Counting objects: 1732, done.
	# remote: Compressing objects: 100% (750/750), done.
	# remote: Total 1732 (delta 1086), reused 1558 (delta 967)
	# Receiving objects: 100% (1732/1732), 528.19 KiB | 621 KiB/s, done.
	# Resolving deltas: 100% (1086/1086), done.
	# From git://github.com/tekkub/cork
	#  * [new branch]      lastbuffed -> cork/lastbuffed
	#  * [new branch]      lock_n_mount -> cork/lock_n_mount
	#  * [new branch]      master     -> cork/master
	#  * [new branch]      nothing_to_see_here -> cork/nothing_to_see_here

	$ git merge -s ours --no-commit cork/master
	# Automatic merge went well; stopped before committing as requested

	$ git read-tree --prefix=cork/ -u cork/master
	$ git commit -m "Subtree merged in cork"
	# [master fe0ca25] Subtree merged in cork

다음으로 `panda/`경로에 [teknologic/Panda](https://github.com/teknologic/Panda)를 합칩니다.

	$ git remote add -f panda git://github.com/TekNoLogic/Panda.git
	# Updating panda
	# warning: no common commits
	# remote: Counting objects: 974, done.
	# remote: Compressing objects: 100% (722/722), done.
	# remote: Total 974 (delta 616), reused 399 (delta 251)
	# Receiving objects: 100% (974/974), 189.56 KiB, done.
	# Resolving deltas: 100% (616/616), done.
	# From git://github.com/tekkub/panda
	#  * [new branch]      master     -> panda/master
	#  * [new branch]      transmute  -> panda/transmute

	$ git merge -s ours --no-commit panda/master
	# Automatic merge went well; stopped before committing as requested

	$ git read-tree --prefix=panda/ -u panda/master
	$ git commit -m "Subtree merged in panda"
	# [master 726a2cd] Subtree merged in panda

마지막으로 `cork2/`에 tekkub/cork부터 하위경로 `modules/`를 합칠 것입니다.

	$ git merge -s ours --no-commit cork/master
	# Automatic merge went well; stopped before committing as requested

	$ git read-tree --prefix=cork2/ -u cork/master:modules
	$ git commit -m "Subtree merged in cork/modules"
	# [master f240057] Subtree merged in cork/modules


### 변경사항을 Pull하기

합쳐진 저장소가 나중에 변경된다면 `-s subtree` 옵션을 사용하여 간단히 변경사항을 Pull 할 수 있습니다:

	$ git pull -s subtree panda master

<div class="alert-info">팁 : If you create a fresh clone of the repository in the future, the remotes you have added (cork, panda, etc) will not be created for you. You will have to add them again using the `git remote add` command described earlier.</div>

나중에 새로운 저장소 복제본을 만든다면 이미 추가된 원격 저장소(cork, panda 등)를 생성하지 않습니다. 이전에 설명한 `git remote add` 명령어를 사용하여 다시 원격 저장소를 추가해야합니다.


### 자료

- [How to use the subtree merge strategy](http://www.kernel.org/pub/software/scm/git/docs/howto/using-merge-subtree.html)

---
layout: post
title: "[번역]GitHub / Advanced Git / 대화형 Rebase"
description: ""
categories: [translate, Advanced Git]
tags: [git, GitHub, rebase]
---
{% include JB/setup %}

다음의 [Interactive rebase](https://help.github.com/articles/interactive-rebase) 번역하였습니다.

## 대화형 Rebase

One often overlooked feature of git is the `git rebase` command. Rebase allows you to easily change a series of commits, reordering, editing, or squashing commits together into a single commit.

git 특징인 `git rebase` 명령어를 자주 눈 감고 넘어가버리곤 합니다. Rebase는 일련의 커밋을 쉽게 변경, 재정렬, 수정, 여러 커밋을 하나의 커밋으로 만들도록 합니다. 

**Warning**: It is considered bad practice to rebase commits which you have already pushed to a remote repository. Doing so may invoke the wrath of the git gods.	

**경고**:원격 저장소에 이미 Push한 커밋을 rebase하는 것은 좋지 못한 사례로 간주됩니다. 이렇게하면 Git 신들의 분노를 살 수 있습니다.



<h3>Rebase 사용하기 --interactive</h3>

#### Invocation 호출

To rebase all the commits between master and the current branch's head, back on to master:

마스터 브랜치와 현재 브랜치의 head 간 모든 커밋을 Rebase하기 위해 master로 돌아갑니다:

	git rebase --interactive master

Another common practice is to rebase the last few commits in your current branch:

또 다른 일반적인 사례는 현재 브랜치에 마지막 몇개 커밋만 rebase하는겁니다:

	git rebase --interactive HEAD~5

Running the command with the `--interactive` flag will launch your text editor with a file detailing the commits that will be rebased. This will also list the commands available:

`--interactive` 옵션으로 실행하는 명령어는 rebase될 상세한 커밋 파일과 텍스트 에디터를 실행합니다. 또한 사용가능한 명령어를 나열합니다.

	pick 1fc6c95 Patch A
	pick 6b2481b Patch B
	pick dd1475d something I want to split
	pick c619268 A fix for Patch B
	pick fa39187 something to add to patch A
	pick 4ca2acc i cant' typ goods
	pick 7b36971 something to move before patch B

	# Rebase 41a72e6..7b36971 onto 41a72e6
	#
	# Commands:
	#  p, pick = use commit
	#  r, reword = use commit, but edit the commit message
	#  e, edit = use commit, but stop for amending
	#  s, squash = use commit, but meld into previous commit
	#  f, fixup = like "squash", but discard this commit's log message
	#  x, exec = run command (the rest of the line) using shell
	#
	# If you remove a line here THAT COMMIT WILL BE LOST.
	# However, if you remove everything, the rebase will be aborted.
	#

At this point you can edit the file to change the order of the commits. There are six commands available:

이 시점에서 파일을 편집하여 커밋의 순서를 변경할 수 있음을 가르킵니다. 가능한 명령어가 6개 있습니다.


#### Pick

Pick is used to include a commit. By default you will be given a list of the commits you chose to rebase, in order of oldest (top) to newest (bottom). Rearranging the order of the pick commands will change the order of the commits when you begin the rebase.

Pick은 커밋을 포함하는데 사용됩니다. 일반적으로 rebase하기 위해 선택하는 커밋들의 날짜순으로 오름차순된 목록이 주어집니다. pick 명령어의 순서를 재배열 하는 것은 rebasse를 시작할 때 커밋의 순서를 변경합니다.


#### Reword

This is similar to pick, but the rebase process will pause and give you a chance to change the commit message. The contents of the commit are not modified.

pick과 유사하지만 rebase 과정에서 일시 정지하고 커밋 메시지를 변경할 기회가 주어집니다. 커밋 내용은 변경하지 않습니다.


#### Edit

This will pick the commit and then pause the rebase. During this pause you can amend the commit, adding to or removing from it. You can also make more commits before you continue the rebase, this allows you to split a large commit into smaller ones. You should always ensure that your working tree and index are clean before you resume the rebase.

Edit은 commit을 pick하고 rebase를 일시 정지합니다. 일시정지하여 커밋을 수정하는 동안 Edit에서 추가하거나 삭제합니다. 또한 rebase를 계속하기전에 많은 커밋을 만들 수 있으며 작은 커밋에서 많은 커밋으로 나눌 수 있습니다. rebase를 재개하기전에 항상 working tree와 index를 깨끗하게 해야 합니다.


#### Squash

This command lets you combine two or more commits into a single commit. When used the commit will be picked and then amended into the commit before it. Git will then pause the rebase and open your text editor with the commit messages from both commits. After you have edited the message to your satisfaction save the file and close the editor. Git will resume the rebase.

이 명령어는 두개 또는 그 이상 커밋을 한개의 커밋으로 합칠 수 있습니다. 커밋을 고른다음 사용하면 이전 커밋으로 수정됩니다. Git은 rebase를 일시 정지하고 두개 커밋으로 부터 커밋 메시지와 함께 텍스트 에디터를 엽니다. 만족하게 메시지를 수정한 후에 파일을 저장하고 에디터를 닫습니다. Git은 rebase를 재개합니다.


#### Fixup

This is similar to squash, but the commit's message is discarded. The commit is simply merged into the commit before it and the first commit's message is used.

squash와 비슷하지만 커밋의 메시지는 버려집니다. 커밋은 간단히 이전 커밋에 병합되고 첫번째 커밋 메시지가 사용됩니다.


#### Exec

This allows you to run arbitrary shell commands automatically against a commit.

커밋에 대해 임의의 쉘 명령어를 자동으로 실행할 수 있습니다.


#### Example 예

In this rebase we will cover all the commands except exec. We start our rebase with `git rebase --interactive HEAD~7` and are presented with this file in our editor:

exec를 제외한 모든 명령어를 다루는 Rebase입니다. `git rebase --interactive HEAD~7`인 rebase를 시작하고 에디터에  이 파일을 받습니다.

	pick 1fc6c95 Patch A
	pick 6b2481b Patch B
	pick dd1475d something I want to split
	pick c619268 A fix for Patch B
	pick fa39187 something to add to patch A
	pick 4ca2acc i cant' typ goods
	pick 7b36971 something to move before patch B

	# Rebase 41a72e6..7b36971 onto 41a72e6
	#
	# Commands:
	#  p, pick = use commit
	#  r, reword = use commit, but edit the commit message
	#  e, edit = use commit, but stop for amending
	#  s, squash = use commit, but meld into previous commit
	#  f, fixup = like "squash", but discard this commit's log message
	#  x, exec = run command (the rest of the line) using shell
	#
	# If you remove a line here THAT COMMIT WILL BE LOST.
	# However, if you remove everything, the rebase will be aborted.
	#

There are a few things we want to do here, we want to move the fifth and last commits up before the "Patch B" commit. One of those commits will be squashed into the "Patch A" commit. We also want to squash the "fix for Patch B" commit into Patch B and discard its commit message (a fixup). We want to edit the third commit to split it into two commits. Finally we need to reword the sixth commit and fix our wonderful typing.

여기에 하고 싶은 몇가지 것들이 있습니다. 다섯번째 커밋을 마지막 커밋들 위에, "Patch B"커밋 앞으로 옮기고 싶습니다. 커밋 중 하나는 "Patch A" 커밋에 squash됩니다. 또한 "fix for Path B" 커밋을 Patch B에 squash하고 커밋 메시지를 버리고 싶습니다. 세번째 커밋을 두개 커밋으로 나누기 위해 edit을 하고 싶습니다. 마지막엔 여섯번째 커밋에 멋진 입력으로 수정하기 위해 reword를 해야 합니다.


We'll change the file as such:

다음과 같이 파일을 변경합니다:

	pick 1fc6c95 Patch A
	squash fa39187 something to add to patch A
	pick 7b36971 something to move before patch B
	pick 6b2481b Patch B
	fixup c619268 A fix for Patch B
	edit dd1475d something I want to split
	reword 4ca2acc i cant' typ goods

Now we save and close the editor to begin the rebase. Since the first operation is a squash our editor opens:

이제 rebase를 시작하기 위해 에디터를 저장하고 닫습니다. 이후 첫번째 작업은 에디터를 여는 squash입니다.

	# This is a combination of two commits.
	# The first commit's message is:

	Patch A

	# This is the 2nd commit message:

	something to add to patch A

	# Please enter the commit message for your changes. Lines starting
	# with '#' will be ignored, and an empty message aborts the commit.
	# Not currently on any branch.
	# Changes to be committed:
	#   (use "git reset HEAD <file>..." to unstage)
	#
	# modified:   a
	#

As usual, edit the file as we wish, save, and close the editor. The rebase will proceed until it gets to the edit operation, where it tells us:

일반적으로 원하는데로 파일을 수정하고 저장하고 에디터를 닫습니다. rebase는 edit 작업에 도달할때까지 rebase가 진행됩니다. 말해줍니다.


	You can amend the commit now, with

	        git commit --amend

	Once you are satisfied with your changes, run

	        git rebase --continue

At this point we would edit the files we need, do a `git commit --amend`, make our second commit, and ensure that our working tree and index are clean. On to the next one! `git rebase --continue`

이 시점에서 `git commit --amend`를 하고 두번째 커밋을 만들고 working tree와 인덱스를 깨끗히 해서 파일을 수정합니다. 다음! `git rebase --continue`

Finally, git hits our `reword` commit. It opens up the text editor one last time:

마지막으로 git은 `reword` 커밋을 날립니다. 마지막으로 텍스트 에디터를 엽니다.

	i cant' typ goods

	# Please enter the commit message for your changes. Lines starting
	# with '#' will be ignored, and an empty message aborts the commit.
	# Not currently on any branch.
	# Changes to be committed:
	#   (use "git reset HEAD^1 <file>..." to unstage)
	#
	# modified:   a
	#

Fix, save, and close the editor. Git finishes the rebase and returns us to our command prompt.

고치고 저장하고 에디터를 닫습니다. Git은 rebase를 마무리하고 command prompt를 반환합니다.


<h3>Using --autosquash</h3>

<h3>--autosquash 사용하기</h3>

In git 1.7 the `--autosquash` flag was added to `git rebase --interactive`. This option allows you to craft commit messages that tell rebase what you want to do. This is great if you're committing something that you know you want to squash or fixup against an earlier commit.

git 1.7에서 `--autosquash` 옵션이 `git rebase --interactive`에 추가되었습니다. 이 옵션은 원하는 작업을 rebase한다는 커밋 메시지를 만들 수 있습니다. squash나 이전 커밋을 수정할 것을 알고 커밋한다면 좋은 방법입니다.

The basic syntax is to use "squash!" or "fixup!" followed by the first part of the commit message. For example, if we used these commit messages:

기본 문법은 커밋 메시지의 첫부분에 "squash!"나 "fixup!"를 따라 사용하는 것입니다. 예를 들면 이러한 커밋 메시지를 사용하는 경우입니다:

	Patch A
	Patch B
	fixup! Patch B
	squash! Patch A

When we run `git rebase --interactive --autosquash` It opens with our commits already where we want them:

`git rebase --interactive --autosquash`를 실행하면 이미 원하는 커밋들로 열립니다.

	pick 1fc6c95 Patch A
	squash fa39187 squash! Patch A
	pick 6b2481b Patch B
	fixup c619268 fixup! Patch B

If you use autosquash often (who wouldn't?), you can save yourself some typing by telling git to use it by default:

autosquash를 자주 사용한다면(누가 안해?) 기본으로 사용하기 위해 입력을 저장해서 Git에 말할 수 있습니다.

	git config --global rebase.autosquash true



### References

- [Git rebase man page](http://git-scm.com/docs/git-rebase)
- [Progit: Git Branching - Rebasing](http://git-scm.com/book/en/Git-Branching-Rebasing)
- [Progit: Interactive Rebasing](http://git-scm.com/book/en/Git-Tools-Rewriting-History#Changing-Multiple-Commit-Messages)
- [Git ready: squashing commits with rebase](http://gitready.com/advanced/2009/02/10/squashing-commits-with-rebase.html)
- [Fun with git rebase --interactive --autosquash](http://technosorcery.net/blog/2010/02/07/fun-with-the-upcoming-1-7-release-of-git-rebase---interactive---autosquash/)
---
layout: post
title: "[번역]GitHub / Advanced Git / 대화형 Rebase"
description: ""
category: "Git"
tags: [git, github, rebase, interactive]
---
{% include JB/setup %}

이 문서는 [Interactive rebase](https://help.github.com/articles/interactive-rebase)의 비공식 번역글이며 GitHub에서 보증, 유지 또는 감독하지 않습니다. 공식 도움글을 보시려면 [help.github.com](https://help.github.com)을 방문하세요.

---

## 대화형 Rebase

git 특징인 `git rebase` 명령어를 종종 넘겨버리곤 합니다. Rebase는 일련의 커밋을 쉽게 변경, 재정렬, 수정, 여러 커밋을 하나의 커밋으로 만들 수 있습니다.

<div class="alert warning"><strong>경고</strong>:원격 저장소에 이미 Push한 커밋을 rebase하는 것은 나쁜 사례로 생각됩니다. 이렇게하면 Git 신들의 격노를 살 수 있습니다.</div>


<h3>Rebase 사용하기 --interactive</h3>

#### 호출하기

마스터 브랜치와 현재 브랜치의 head사이에 있는 모든 커밋을 Rebase하기 위해 master로 돌아갑니다:

	git rebase --interactive master

또 다른 일반적인 사례는 현재 브랜치에 마지막 몇개 커밋만 rebase합니다.

	git rebase --interactive HEAD~5

`--interactive` 옵션으로 실행하는 명령어는 rebase하는 커밋의 상세 파일을 포함하여 텍스트 에디터를 실행합니다. 또한 사용가능한 명령어를 나열합니다:

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

이 시점에서 커밋 순서를 변경할 수 있는 파일을 수정할 수 있습니다. 가능한 명령어가 6개 있습니다:


#### Pick

Pick은 커밋을 포함하기 위해 사용됩니다. 기본으로 rebase하기 위해 선택한 커밋의 목차가 주어집니다. 목차는 날짜순으로 오름차순되어 있습니다. pick 명령어의 순서를 재배열 하는 것은 rebase를 시작할 때 커밋의 순서를 변경합니다.


#### Reword

pick과 유사하지만 rebase 진행을 일시 정지하고 커밋 메시지를 변경할 기회가 주어집니다. 커밋 내용은 변경되지 않습니다.


#### Edit

Commit을 Pick한 뒤에 rebase를 일시정지 합니다. 일시정지하고 커밋을 수정하는 동안 Edit에서 추가하거나 삭제할 수 있습니다. 또한 rebase를 재개하기 전에 더 많은 커밋을 만들 수 있고, 큰 커밋을 작은 커밋들로 나눌 수 있습니다. rebase를 재개하기 전에 항상 working tree와 index를 깨끗하게 해야 합니다.


#### Squash

이 명령어는 두개 또는 그 이상 커밋을 단일 커밋으로 합칠 수 있습니다. 사용할 커밋을 선택한 뒤에 이전 커밋으로 수정됩니다. Git은 rebase를 일시 정지하고 다중 커밋으로부터 커밋 메시지를 포함하여 텍스트 에디터를 엽니다. 만족스럽게 메시지를 수정하고 파일에 저장한 후에 에디터를 닫습니다. Git은 rebase를 재개합니다.


#### Fixup

squash와 비슷하지만 커밋 메시지는 버려집니다. 커밋은 간단히 이전 커밋에 병합되고 첫번째 커밋 메시지가 사용됩니다.


#### Exec

커밋에 대해 임의의 쉘 명령어를 자동으로 실행할 수 있습니다.


#### 예제

exec를 제외한 모든 명령어를 다루는 Rebase입니다. `git rebase --interactive HEAD~7`인 rebase를 시작하고 에디터에 이 파일이 표시됩니다:

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

여기에 하고 싶은 것이 몇가지 있습니다. 다섯번째 커밋을 "Patch B" 커밋 앞으로 옮기고 싶습니다. 커밋 중 하나는 "Patch A" 커밋에 squash됩니다. 또한 "fix for Path B" 커밋을 Patch B에 squash하고 커밋 메시지는 버립니다.(fixup) 세개 커밋을 두개 커밋으로 나누어 수정하고 싶습니다. 마지막엔 여섯번째 커밋에 멋진 입력으로 수정하기 위해 reword를 해야 합니다.

다음과 같이 파일을 변경합니다:

	pick 1fc6c95 Patch A
	squash fa39187 something to add to patch A
	pick 7b36971 something to move before patch B
	pick 6b2481b Patch B
	fixup c619268 A fix for Patch B
	edit dd1475d something I want to split
	reword 4ca2acc i cant' typ goods

이제 rebase를 시작하기 위해 에디터를 저장하고 닫습니다. 이후 첫번째 동작은 에디터를 여는 squash입니다:

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

일반적으로 하고 싶은 대로 파일을 수정하고 저장하고 에디터를 닫습니다. rebase는 edit 작업을 받을 때까지 진행되고 어디인지 말해줍니다:

	You can amend the commit now, with

	        git commit --amend

	Once you are satisfied with your changes, run

	        git rebase --continue

이 시점에서 필요한 파일을 수정하고 `git commit --amend`를 하여 두번째 커밋을 만듭니다. 그리고 working tree와 index를 깨끗하게 합니다. 다음으로! `git rebase --continue`

마지막엔 git은 `reword` 커밋을 날립니다. 마지막으로 한번 텍스트 에디터를 엽니다:

	i cant' typ goods

	# Please enter the commit message for your changes. Lines starting
	# with '#' will be ignored, and an empty message aborts the commit.
	# Not currently on any branch.
	# Changes to be committed:
	#   (use "git reset HEAD^1 <file>..." to unstage)
	#
	# modified:   a
	#

수정하고 저장하고 에디터를 닫습니다. Git은 rebase를 마무리하고 command prompt를 반환합니다.


<h3>--autosquash 사용하기</h3>

git 1.7에서 `--autosquash` 옵션이 `git rebase --interactive`에 추가되었습니다. 이 옵션은 원하는 작업을 rebase한다는 커밋 메시지를 만들 수 있습니다. squash나 이전 커밋을 수정할 것을 알고 커밋한다면 좋은 방법입니다.

기본 문법은 커밋 메시지의 첫부분에 "squash!"나 "fixup!"를 따라 사용하는 것입니다. 예를 들면 이러한 커밋 메시지를 사용하는 경우입니다:

	Patch A
	Patch B
	fixup! Patch B
	squash! Patch A

`git rebase --interactive --autosquash`를 실행하면 원하는 형태로 만들어진 커밋 파일을 엽니다.

	pick 1fc6c95 Patch A
	squash fa39187 squash! Patch A
	pick 6b2481b Patch B
	fixup c619268 fixup! Patch B

autosquash를 자주 사용한다면 입력을 하여 Git이 기본설정으로 사용하도록 합니다:

	git config --global rebase.autosquash true



### 참고

- [Git rebase man page](http://git-scm.com/docs/git-rebase)
- [Progit: Git Branching - Rebasing](http://git-scm.com/book/en/Git-Branching-Rebasing)
- [Progit: Interactive Rebasing](http://git-scm.com/book/en/Git-Tools-Rewriting-History#Changing-Multiple-Commit-Messages)
- [Git ready: squashing commits with rebase](http://gitready.com/advanced/2009/02/10/squashing-commits-with-rebase.html)
- [Fun with git rebase --interactive --autosquash](http://technosorcery.net/blog/2010/02/07/fun-with-the-upcoming-1-7-release-of-git-rebase---interactive---autosquash/)
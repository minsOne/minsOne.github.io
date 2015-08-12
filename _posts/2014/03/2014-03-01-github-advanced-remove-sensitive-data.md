---
layout: post
title: "[번역]GitHub / Advanced Git / 민감한 데이터 제거하기"
description: ""
category: "Git"
tags: [git, github, sensitive data, remove]
---
{% include JB/setup %}

이 문서는 [Remove sensitive data](https://help.github.com/articles/remove-sensitive-data)의 비공식 번역글이며 GitHub에서 보증, 유지 또는 감독하지 않습니다. 공식 도움글을 보시려면 [help.github.com](https://help.github.com)을 방문하세요.

---

## 민감한 데이터 제거하기

유저가 시간이 지남에 따라 비밀번호나 키 같은 데이터를 실수로 git 저장소에 커밋합니다. `git rm`을 사용해서 파일을 삭제할순 있지만 저장소 히스토리에는 여전히 남아있습니다. 다행히도 저장소 히스토리 전체에서 원치않는 파일을 삭제 가능합니다. Git에 내장된 `filter-branch`툴을 사용하거나 더 쉽고 빠른 BFG Repo-Cleaner을 사용합니다.

<div class="alert-danger"><strong>위험 : 커밋이 진행된 후에 데이터가 손상되는 것을 고려해야 합니다.</strong> 비밀번호가 커밋이 되었다면 변경하세요! 키가 커밋되었다면 새로 생성하세요.</div>

### 저장소에서 파일을 제거하기

이제 패스워드는 변경되었고 히스토리에서 파일을 제거되었습니다. 그리고 `.gitignore`을 추가하여 확실하게 사고없이 다시 커밋하길 원합니다. 예를 들어 [GitHub gem](https://github.com/defunkt/github-gem) 저장소에서 `Rakefile`을 제거하려고 합니다.

	$ git clone https://github.com/defunkt/github-gem.git
	# Initialized empty Git repository in /Users/tekkub/tmp/github-gem/.git/
	# remote: Counting objects: 1301, done.
	# remote: Compressing objects: 100% (769/769), done.
	# remote: Total 1301 (delta 724), reused 910 (delta 522)
	# Receiving objects: 100% (1301/1301), 164.39 KiB, done.
	# Resolving deltas: 100% (724/724), done.

	$ cd github-gem

	$ git filter-branch --force --index-filter \
	  'git rm --cached --ignore-unmatch Rakefile' \
	  --prune-empty --tag-name-filter cat -- --all
	# Rewrite 48dc599c80e20527ed902928085e7861e6b3cbe6 (266/266)
	# Ref 'refs/heads/master' was rewritten

이 명령어는 모든 브랜치와 태그, `Rakefile` 파일이 포함된 커밋 변경과 이후 커밋의 전체 히스토리를 실행합니다. 나중에 빈 커밋(Rakefile만 변경되었기때문입니다)은 완전히 제거됩니다. 제거할 파일의 경로를 지정해야 합니다. 파일 이름만으로는 안됩니다.

이제 히스토리에서 파일을 지웠습니다. 다시는 패스워드나 키를 커밋하는 실수를 하지 않도록 합시다.

*기존의 태그를 덮어씌우므로* 유의하시기 바랍니다.

	$ echo "Rakefile" >> .gitignore

	$ git add .gitignore

	$ git commit -m "Add Rakefile to .gitignore"
	# [master 051452f] Add Rakefile to .gitignore
	#  1 files changed, 1 insertions(+), 0 deletions(-)

히스토리에서 지우고 싶은 모든 것이 삭제되었는지 다시 한번 확인하는 좋은 시간이 될 것입니다. 그리고 모든 브랜치는 체크아웃됩니다. 저장소 상태가 만족스럽다면 원격 저장소에 변경 사항을 덮어씌우기위해 강제 Push가 필요합니다. 이 과정은 전체 원격 저장소에 덮어씌우며 커밋은 온라인에서 더이상 존재하지 않습니다.

	$ git push origin master --force
	# Counting objects: 1074, done.
	# Delta compression using 2 threads.
	# Compressing objects: 100% (677/677), done.
	# Writing objects: 100% (1058/1058), 148.85 KiB, done.
	# Total 1058 (delta 590), reused 602 (delta 378)
	# To https://github.com/defunkt/github-gem.git
	#  + 48dc599...051452f master -> master (forced update)	

변경된 모든 브랜치와 태그에 대해 이 작업을 수행해야합니다. `--all`과 `--tags` 옵션은 더 쉽게 도움을 줄 수 있습니다.

#### 이동된 파일을 제거하기

특별주의 : 생성된 후에 이동된 파일을 제거해야한다면, 파일이 거쳐간 모든 경로에 `filter-branch` 단계를 실행해야합니다.

### git-filter-branch를 대신하여 BFG 사용하기

[The BFG](http://rtyley.github.io/bfg-repo-cleaner/)는 `git-filter-branch`에 비해 빠르고 간단하며 원치 않는 데이터 제거 전용입니다. - 예를 들면:

	$ bfg --delete-file Rakefile
	# Remove any file named 'Rakefile' (leaves your latest commit untouched)

또는 

	$ bfg --replace-text passwords.txt
	# Search-and-replace text (in this case, passwords) in all files in repo history	

[The BFG's documentation](http://rtyley.github.io/bfg-repo-cleaner/)는 다운로드와 모든 사용 방법을 볼 수 있습니다.

### 공간 정리 및 회수하기

`git filter-branch`는 히스토리를 재작성하는 동안 객체는 카비지 컬렉션과 참조를 없어질때까지 로컬 저장소에 남아있습니다. 주 저장소에 작업한다면 이들 객체를 강제로 제거하길 원할 것입니다.

	$ rm -rf .git/refs/original/

	$ git reflog expire --expire=now --all

	$ git gc --prune=now
	# Counting objects: 2437, done.
	# Delta compression using up to 4 threads.
	# Compressing objects: 100% (1378/1378), done.
	# Writing objects: 100% (2437/2437), done.
	# Total 2437 (delta 1461), reused 1802 (delta 1048)

	$ git gc --aggressive --prune=now
	# Counting objects: 2437, done.
	# Delta compression using up to 4 threads.
	# Compressing objects: 100% (2426/2426), done.
	# Writing objects: 100% (2437/2437), done.
	# Total 2437 (delta 1483), reused 0 (delta 0)

새로 만들거나 빈 GitHub 저장소에 브랜치를 push하고 같은 효과를 가진 GitHub에서 새로운 복제 저장소를 만드는 것을 유의하세요.


### 공동 제작자에 대처하기

오염된 브랜치를 Pull하여 따로 자신의 브랜치를 만드는 공동 제작자가 있을 것입니다. 공동 제작자는 새로운 브랜치를 가져온 후에 `git rebase`를 이용하여 자신의 브랜치에 새로운 커밋을 최상위로 rebase합니다. 공동 제작자는 또한 자신의 브랜치가 덮어씌운 `.gitignore` 파일을 재도입할 순 없습니다. 공동 제작자는 rebase를 사용하지만 merge는 사용할 수 없음을 확인해야합니다. 반면에 당신은 단지 파일과 전체 오염된 히스토리를 재도입하고 몇개의 병합 충돌이 발생할 수 있습니다.

### GitHub에 캐시된 데이터

강제 Push는 원격 저장소에 커밋을 못 지우는 것을 경고합니다. 단순히 새로운 커밋을 소개하고 브랜치 포인터를 가르키도록 옮깁니다. 유저가 SHA1을 통해 잘못된 커밋을 직접적으로 접근하는 것이 걱정된다면 저장소를 삭제하고 다시 생성하세요. 또한 커밋이 온라인 페이지에 캐시된 것이 보여진다면 저장소를 재생성한 후에 캐시된 페이지를 확인하세요. [GitHub Support](https://github.com/contact)에 링크를 제공하여 스태프가 캐시된 데이터를 제거할 수 있도록 합니다.


### 나중에 실수할 커밋을 방지하기

원치않는 커밋하는 것을 막을 수 있는 몇가지 간단한 요령이 있습니다. 첫번째, 가장 간단하게 [GitHub for Mac](https://mac.github.com/)이나 [gitx](http://rowanj.github.io/gitx/) 같은 시각적인 프로그램을 사용하세요. 커밋하는 것을 정확하게 보여주며 저장소에 원하는 파일만 추가할 수 있도록 해줍니다. 커맨드라인에서 작업을 한다면 `git add .`과 `git commit -a` 같이 all을 포함하는 명령어는 피하고 독립적인 stage 파일을 위해 `git add filename`과 `git rm filename`을 사용하세요. 또한 각각 변경된 파일과 stage 파일 또는 부분적으로 커밋을 위해 `git add --interactive`를 사용하여 검토할 수 있습니다. 커맨드라인에서 작업을 한다면 커밋을 위해 stage된 변경사항을 확인하는 `git diff --cached`를 사용할 수 있습니다. 커밋에 `-a` 옵션이 있고 없고의 차이점입니다.


### Other reading 다른 읽을거리

- [Git-filter-branch man page](http://git-scm.com/docs/git-filter-branch)
- [Pro Git: Git 도구 - 히스토리 단장하기](http://git-scm.com/book/ko/Git-%EB%8F%84%EA%B5%AC-%ED%9E%88%EC%8A%A4%ED%86%A0%EB%A6%AC-%EB%8B%A8%EC%9E%A5%ED%95%98%EA%B8%B0)
- [The BFG Repo-Cleaner](http://rtyley.github.io/bfg-repo-cleaner/) - removes large or troublesome blobs like git-filter-branch does, but faster
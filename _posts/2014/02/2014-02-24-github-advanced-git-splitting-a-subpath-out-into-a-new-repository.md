---
layout: post
title: "[번역]GitHub / Advanced Git / 하위 경로를 새로운 저장소로 분할"
description: ""
categories: [translate, Advanced Git]
tags: [git, GitHub, filter-branch, prune-empty, subdirectory-filter]
---
{% include JB/setup %}

다음의 [Splitting a subpath out into a new repository](https://help.github.com/articles/splitting-a-subpath-out-into-a-new-repository) 번역하였습니다.

---

## 하위 경로를 새로운 저장소로 분할

시간이 지남에 따라 저장소의 하위 경로를 새로운 저장소를 만들고 싶어합니다. 아마 라이브러리로 코드를 빼거나 그냥 프로젝트에 submodule로 가지고 싶어합니다. 고맙게도 Git은 처리과정에서 하위 경로의 히스토리를 잃어버릴 필요 없이 쉽게 작업할 수 있습니다.


### 좋은 자료

하위 경로를 저장소로 분할하는 것은 명령어가 기억하기 어려움에도 불구하고 매우 간단한 과정입니다. 이 예제는 [GitHub gem](https://github.com/defunkt/github-gem) 저장소에서 `lib/`를 분리하고 빈 커밋을 삭제하지만 경로 히스토리는 남깁니다.

	$ git clone git://github.com/defunkt/github-gem.git
	# Clone the repository we're going to work with
	# Initialized empty Git repository in /Users/tekkub/tmp/github-gem/.git/
	# remote: Counting objects: 1301, done.
	# remote: Compressing objects: 100% (769/769), done.
	# remote: Total 1301 (delta 724), reused 910 (delta 522)
	# Receiving objects: 100% (1301/1301), 164.39 KiB | 274 KiB/s, done.
	# Resolving deltas: 100% (724/724), done.

	$ cd github-gem/
	# Change directory into the repository

	$ git filter-branch --prune-empty --subdirectory-filter lib master
	# Filter the master branch to the lib path and remove empty commits
	# Rewrite 48dc599c80e20527ed902928085e7861e6b3cbe6 (89/89)
	# Ref 'refs/heads/master' was rewritten

이제 `lib/`에 있던 파일이 포함되어 재작성된 마스터 브랜치를 얻습니다. 새로운 저장소에 원격 저장소를 추가하고 Push하거나 저장소에 원하는 대로 작업을 할 수 있습니다.
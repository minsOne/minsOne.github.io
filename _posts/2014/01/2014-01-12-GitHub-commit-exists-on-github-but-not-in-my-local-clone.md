---
layout: post
title: "[번역]GitHub / Commits / GitHub에는 커밋이 있는데 로컬 Clone에는 없어요"
description: ""
categories: [translate, Commits]
tags: [git, GitHub, Commits, Fetch]
---
{% include JB/setup %}

다음의 [Commit exists on GitHub but not in my local clone](https://help.github.com/articles/commit-exists-on-github-but-not-in-my-local-clone) 번역하였습니다.

---

## GitHub에는 커밋이 있는데 로컬 Clone에는 없어요

때때로 GitHub에 커밋이 보이지만 로컬 Clone 저장소에는 없을 수도 있습니다.

예:

	$ git show 1095ff3d0153115e75b7bca2c09e5136845b5592
	# fatal: bad object 1095ff3d0153115e75b7bca2c09e5136845b5592

아직은 아무런 문제 없는 `github.com/$account/$repository/commit/1095ff3d0153115e75b7bca2c09e5136845b5592` 커밋을 방문합니다.

가능한 몇가지 설명입니다:

1. 오래된 로컬 저장소
2. 삭제되고 더이상 참조하지 않는 커밋을 포함하고 있는 브랜치
3. 누군가 커밋을 강제로 Push

### 오래된 로컬 저장소

간단하고 가능한 설명 중 하나는 로컬 저장소가 아직 커밋을 하지 않았습니다. `git fetch <remote>`를 사용해 파일이 변경되었는지 확인할 필요 없이 로컬저장소에 원격 저장소 데이터를 안전하게 가져올 수 있습니다. 일반적으로 fork되었거나 단지 단순히 복제하여 가지고 올 수 있는 데이터에서 `get fetch origin` 저장소에서 데이타를 얻기 위해 `get fetch upstream`을 작성합니다.

<div class="alert-info"><strong>팁</strong>: 정보가 더 필요하면 <a href="http://git-scm.com/book/ko/">Pro Git</a> 책에 있는 <a href="http://git-scm.com/book/ko/Git%EC%9D%98-%EA%B8%B0%EC%B4%88-%EB%A6%AC%EB%AA%A8%ED%8A%B8-%EC%A0%80%EC%9E%A5%EC%86%8C">원격 저장소 관리 및 데이터 가져오기</a>를 읽어보세요.</div>

### 브랜치 삭제 또는 강제 Push로부터 복구하기

저장소에서 공동 제작자가 커밋을 포함하고 있는 브랜치를 삭제하거나 브랜치 위로 강제 Push를 했다면 커밋은 분리가 되어 잃어버렸고(즉, 참조가 될 수 없습니다.) 로컬 Clone에 fetch를 할 수 없습니다.

운좋게도 공동 제작자가 잃어버린 커밋을 로컬 저장소 Clone을 가지고 있다면 GitHub에 되돌리게 Push할 수 있습니다. 로컬 브랜치는 반드시 필요한 커밋을 참조하고 GitHub에 새로운 브랜치를 Push합니다.

잃어버린 커밋을 포함하는 로컬 브랜치(`B`라고 부릅시다)를 가지고 있다고 말해봅시다. 강제 Push나 삭제말고도 단순히 아직 업데이트 하지 않은 브랜치를 추적할 수 있습니다. 커밋을 유지하기 위해선 GitHub에 로컬 브랜치를 새로운 브랜치(`recover-B`라고 부릅시다)로 Push할 수 있습니다. 예를 들면 `github.com/$account/$repository`에 push 권한을 통해 원격 저장소 이름인 `upstream` 을 가진다고 가정합시다. 유저는 다음을 실행합니다:

	$ git push upstream B:recover-B
	# Push local B to new upstream branch, creating new reference to commit

이제 실행할 수 있습니다:

	$ git fetch upstream recover-B
	# Fetch commit into your local repository.

<div class="alert-info"><strong>팁</strong>: 이 상황이 일어난다면 로컬 저장소에 처음 `git branch recover-B B`를 실행(즉, 커밋을 참조하는 새로운 로컬 브랜치를 생성)하여 안전하게 할 수 있습니다. 이 단계는 필요하지 않지만 분리된 원격 저장소에서 커밋을 포함하는 로컬 브랜치를 분리하기 좋습니다.</div>

### 강제 Push 피하기

일반적으로 여러사람이 저장소에 Push할 수 있으면 확실히 필요하지 않는 이상 더욱 저장소에 강제 Push를 방지하는 것이 좋습니다. 

### 관련 문서
- [Pro Git의 원격 저장소 챕터](http://git-scm.com/book/ko/Git%EC%9D%98-%EA%B8%B0%EC%B4%88-%EB%A6%AC%EB%AA%A8%ED%8A%B8-%EC%A0%80%EC%9E%A5%EC%86%8C)
- [Pro Git의 Git 내부 챕터 : 데이터복구 Data Recovery](http://git-scm.com/book/ko/Git%EC%9D%98-%EB%82%B4%EB%B6%80-%EC%9A%B4%EC%98%81-%EB%B0%8F-%EB%8D%B0%EC%9D%B4%ED%84%B0-%EB%B3%B5%EA%B5%AC)
- [Git 브랜치 설명 페이지](http://git-scm.com/docs/git-branch)
- [Git fetch 설명 페이지](http://git-scm.com/docs/git-fetch)
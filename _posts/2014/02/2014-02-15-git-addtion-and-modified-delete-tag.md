---
layout: post
title: "[Git]Tag 추가, 변경 및 삭제하기"
description: ""
category: "Git"
tags: [git, tag, push]
---
{% include JB/setup %}

저장소의 소스 버전을 간간히 표시하기 위해서는 커밋 메시지 또는 브랜치로 해서 표시하는 것 보단 태그로 깔끔하게 하는 것이 좋습니다.


#### 태그 조회하기

태그를 전체를 조회할 때는 `git tag`를 사용하여 조회합니다.

	# git tag
	v1.0.0
	v1.0.1
	v1.1.0

만약 원하는 태그명을 조건으로 검색하고자 한다면 `git tag -l v1.1.*`과 같이 사용합니다.

	# git tag -l v1.1.*
	v1.1.0




#### 태그 붙이기

태그는 Lightweight와 Annotated 두 종류가 있습니다. Lightweight 태그는 특정 커밋을 가르키는 역할만 합니다. 한편 Annotated 태그는 태그를 만든 사람, 이메일, 날짜, 메시지를 저장합니다. 그리고 [GPG(GNU Privacy Guard)](http://ko.wikipedia.org/wiki/GNU_프라이버시_가드)로 서명할 수도 있습니다.

Lightweight 태그는 `git tag [Tag Name]`으로 붙일 수 있습니다.

	# git tag v1.0.2
	# git tag
	v1.0.2

Annotated 태그는 `-a` 옵션을 사용합니다.

	# git tag -a v1.0.3 -m"Release version 1.0.3"

`git show v1.0.3`을 통해 태그 메시지와 커밋을 확인할 수 있습니다.

	# git show v1.0.3

	tag v1.0.3
	Tagger: minsOne <cancoffee7+github@gmail.com>
	Date:   Sat Feb 15 17:53:49 2014 +0900

	Release version 1.0.3

	commit 4bb37290cb55490a9829b4ff015b340d513f132a
	Merge: e0d819c 12aa1b0
	Author: Markus Olsson <j.markus.olsson@gmail.com>
	Date:   Thu Feb 13 15:26:47 2014 +0100

	    Merge pull request #947 from IonicaBizau/patch-1
	    
	    Updated the year :-)

태그를 이전 커밋에 붙여야 한다면 커밋 해쉬를 추가하여 사용할수 있습니다.

	# git tag v1.0.5 03c0beb080

	# git tag -a v1.0.4 -m"Release version 1.0.4" 432f6ed

	# git tag
	v1.0.4
	v1.0.5

	# git show v1.0.4

	tag v1.0.4
	Tagger: minsOne <cancoffee7+github@gmail.com>
	Date:   Sat Feb 15 18:02:02 2014 +0900

	Release version 1.0.4

	commit 432f6edf3876a5e2aa8ea545fd15f99953339aba
	Author: Denis Grinyuk <denis.grinyuk@gmail.com>
	Date:   Mon Feb 3 14:52:36 2014 +0400

	    Additional comments

만약 GPG 서명이 있다면 `-s` 옵션을 사용하여 태그에 서명할 수 있습니다.

	# git tag -s v1.0.3 -m"Release version 1.0.3"




#### 태그 원격 저장소에 올리기

태그를 만들고 원격 저장소에 올려야할 필요가 있다면 브랜치를 올리는 방법과 같이 사용할 수 있습니다.

	# git push origin v1.0.3

모든 태그를 올리려면 `--tags`를 사용합니다.

	# git push origin --tags



#### 태그 삭제하기

필요없거나 잘못 만든 태그를 삭제하기 위해선 `-d`옵션을 사용하여 삭제할 수 있습니다.

	# git tag -d v1.0.0

원격 저장소에 올라간 태그를 삭제하기 위해선 `:`를 사용하여 삭제할 수 있습니다.

	# git push origin :v1.0.0

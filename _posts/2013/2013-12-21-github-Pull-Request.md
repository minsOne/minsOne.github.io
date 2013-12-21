---
layout: post
title: "GitHub / Pull 요청하는 방법[번역]"
description: ""
category: "lesson"
tags: [git, github]
---
{% include JB/setup %}

다음의 [Using Pull Requests](https://help.github.com/articles/using-pull-requests) 번역하였습니다.

### Pull 요청 사용하기

Pull 요청은 당신이 GitHub 저장소에 Push한 변경사항들에 대해서 다른 사람들에게 말하는 것입니다. 이전에 Pull 요청을 보내었으면 흥미가 있는 참여자들은 변경사항에 대해 리뷰를 할 수 있고 잠재적인 수정들에 대해 토론하고 심지어 만약 필요하다면 후속 커밋도 Push합니다.

이 설명서는 가상의 Pull 요청을 보내는 과정과 다양한 코드 리뷰와 완료로 변경하는 관리 도구들들에 대해 안내합니다.

### 협업 개발 모델상의 즉석 노트

GitHub에는 두가지 인기있는 협업 개발 모델이 있습니다.

##### Fork & Pull

Fork와 Pull 모듈은 누군가가 존재하는 저장소를 Fork 하는 것과 소스 저장소에 접근요청 할 필요가 없는 개인적인 fork에 변경사항을 Push하도록 합니다. 프로젝트 메인테이너는 변경사항을 소스 저장소에 반영해야 합니다. 이 모델은 새로운 공헌자들을 위해 충돌을 감소시키며 사람들이 앞선 작업없이 자유롭게 작업할 수 있기 때문에 오픈소스 프로젝트에 인기있습니다.

##### 공유 저장소 모델
공유 저장소 모델은 사적인 프로젝트 상에서 소규모 팀과 협업 단체들에게 널리 퍼져있습니다. 모든 사람들이 단일 공유 저장소에 접근해도 되며 화제 브랜치들은 변경사항을 분리하는데 사용됩니다.

Pull 요청은 특히 Fork와 Pull 모델에 유용한데 이는 당신의 fork에 있는 변경사항들에 대해 프로젝트 메인테이너에게 알리는 방식을 제공합니다. 그러나 해당 모델은 코드 리뷰와 주 브랜치에 합치기 전에 변경사항들에 대한 토론을 시작하는 공유 저장소 모델에도 또한 유용합니다.

### 시작하기 전

이 설명서는 당신이 [GitHub 계정을 가지고 있고](https://github.com/signup) 존재하는 저장소를 fork했었고 변경사항을 Push하였음을 가정합니다. 변경사항을 Fork와 Push하는 것에 대한 도움말이며, [저장소 Fork하기 기사](https://help.github.com/articles/fork-a-repo)를 참조합니다.

### Pull 요청 시작하기

예제에 따르면, **codercat**은 Octocat의 Spoon-Knife 저장소의 fork에서 일부 작업을 완료하였고, fork에 있는 화재 브랜치에 커밋을 Push하였고, 누군가가 리뷰 및 합치는 것을 하길 원합니다.

누군가가 변경사항을 Pull 하길 원하는 저장소로 이동하여 Pull 요청 버튼을 누릅니다.

> 브랜치를 전환한다.
> ![브랜치 전환 이미지](https://github-images.s3.amazonaws.com/help/pick-your-branch.png)

> Compare & review버튼을 클릭한다.
> ![Compare & review버튼을 클릭한다](https://github-images.s3.amazonaws.com/help/pull-request-start-review-button.png)

Pull 요청은 아무 브랜치나 커밋을 보낼 수 있지만 화재 브랜치는 후속 커밋이 필요한 경우 Pull 요청을 업데이트하도록 Push할 수 있게 사용하는 것이 좋습니다.

### Pull 요청 리뷰하기

리뷰를 시작한 후에는 정확하게 당신의 브랜치와 저장소의 마스터 브랜치간 변경사항을 고수준의 개요로 얻을 수 있는 리뷰 페이지를 보여줘야 합니다. 커밋에 작성된 모든 의견을 리뷰할 수 있으며 파일 변경한 것을 확인할 수 있고, 당신의 브랜치에 공헌자들 목록을 얻을 수 있습니다.

![Pull 요청 리뷰](https://github-images.s3.amazonaws.com/help/pull-request-review-page.png)

### 브랜치 범위와 대상 저장소 변경하기

기본적으로 Pull 요청들은 부모 저장소의 [기본 브랜치](https://help.github.com/articles/setting-the-default-branch)를 기준으로 가정합니다. 이 경우에 `octocat/Spoon-Knife`로부터 fork된 `hubot/Spoon-Knife` 저장소에 Pull 요청은 `octocat/Spoon-Knife` 저장소의 마스터 브랜치를 기준으로 가정합니다.

대다수의 경우에 기본 값들은 잘 될 것입니다. 그러나 만약 이 정보의 어떤 것이 부정확하다면 drop-down 목록으로부터 부모 저장소와 브랜치를 변경할 수 있습니다. 위쪽에 위치한 Edit 버튼을 클릭하여 head와 base를 바꾸도록 하고, 뿐만 아니라 다양한 참조 포인터들 차이들을 설정합니다. 여기에 참조들을 포함합니다.

- Tagged releases
- Commit SHAs
- Branch names
- Git history markers (like `HEAD^1`)
- Valid time references (like `master@{1day}`)

![브랜치 범위와 대상 저장소 변경하기](https://github-images.s3.amazonaws.com/help/pull-request-review-edit-branch.png)

브랜치 범위에 대한 생각하기 가장 쉬운 방법은 base 브랜치가 당신이 생각하기에 적용되어 변경되어야 하는 곳(**Where**)이고 head 브랜치는 당신이 이미 적용해놓은 것(**What**)입니다.






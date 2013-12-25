---
layout: post
title: "[번역]GitHub / Collaborating / Pull 요청하는 방법"
description: ""
category: "translate"
tags: [git, GitHub]
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

변경되는 기본 저장소는 Pull 요청을 받은 사람으로 변경합니다. 모든 사람은 이메일 알림을 받을 기본 저장소에 Push 할 수 있고 다음번에 로그인하면 대시보드에 새로운 Pull 요청을 볼 수 있습니다.

브랜치 범위 안에 어떤 정보를 변경하였을 때는 커밋과 파일들은 새로운 범위로 업데이트 될 미리보기 영역이 변경됩니다.

### Pull 요청 보내기

Pull 요청을 제출할 준비가 되었다면 상단에 start a discussion을 클릭한다.

![Pull 요청 보내기](https://github-images.s3.amazonaws.com/help/pull-request-review-create.png)

제목과 임의의 설명을 입력할 수 있는 토론 페이지로 이동할 것입니다. 커밋이 Pull 요청을 보냈을 때 포함되는 것을 정확하게 볼 수 있습니다.

한번 제목과 설명을 입력했으면 커밋 범위를 어떤 필요한 사용자 정의를 만들었고 커밋과 파일 변경사항을 보내기 위해 리뷰했었고, Send pull request 버튼을 클릭합니다.

![Pull 요청 보내기 버튼 클릭](https://github-images.s3.amazonaws.com/help/send-pull-request.png)

Pull 요청을 보낸 후에 어떤 Push들은 당신의 브랜치에 자동적으로 그 커밋들이 업데이트 되도록 만들어집니다. 이것은 만약 당신이 더 많은 변경사항을 만드는 것이 필요할 때 특히 유용합니다.

### Pull 요청 관리하기

Pull 요청 대시보드에서 보내거나 받은 모든 Pull 요청들을 찾아볼 수 있습니다. 특정 저장소에 Pull 요청들도 또한 Pull 요청 페이지에 방문하여 접속한 사람이면 찾아볼 수 있습니다.

![Pull 요청 관리하기](https://github-images.s3.amazonaws.com/help/repo-pull-requests.png)

Pull 요청 대쉬보드와 저장소 Pull 요청 목록은 필터링과 정렬를 넓은 범위로 제공합니다. 관심있는 Pull 요청들의 목록 범위를 줄이기 위해 사용합니다.

### 변경사항 제안 검토하기

Pull 요청을 받았을 때 처음 해야 할 일은 제안받은 변경사항 제안 묶음을 검토하는 것입니다. Pull 요청은 밀접하게 기본적인 git 저장소와 통합되어 있어 요청 수락을 하면 커밋이 합쳐지는 것을 정확하게 볼 수 있습니다.

![Pull 요청 커밋](https://github-images.s3.amazonaws.com/help/review-commits.png)

또한 모든 커밋을 통해 모든 파일의 누적된 변경 내역을 리뷰 할 수 있습니다.

![Pull 요청 파일변경](https://github-images.s3.amazonaws.com/help/review-changes.png)

### Pull 요청 토론하기

기초적인 설명, 커밋, 누적된 변경을 리뷰 한 후에 변경 사항을 적용하려고 질문이나 의견을 낼 수도 있습니다. 아마 코딩 스타일이 프로젝트 가이드라인과 맞지 않거나 유닛 테스트에서 안되거나 또는 아마도 모든 것이 훌륭하고 순서대로 표시된 어떤 기능들이 순서대로 된 것으로 보입니다. 이 토론 화면은 자신감을 돋구기 위해 디자인되었으며 이 토론의 유형을 캡쳐했습니다..

![Pull 요청 토론하기](https://github-images.s3.amazonaws.com/help/conversation.png)

토론 화면은 원래의 제목과 설명 그리고 시간순으로 표시되는 추가적인 활동의 Pull 요청과 함께 시작됩니다. 어떤 활동 유형들은 다음 것들이 일어납니다.

- Pull 요청에 의견을 남깁니다.
- Pull 요청의 브랜치에 추가의 커밋을 Push 합니다.
- 파일과 라인 기록은 Pull 요청 범위가 포함되는 어떤 커밋에 남깁니다.

Pull 요청 의견은 Markdown과 호환이 되며 이미지를 넣을 수 있고 서식이 지정된 문장을 사용하고 다른 마크다운 형식도 지원이 됩니다.

### 오랫동안 진행되고 있는 Pull 요청 보기

기능이나 버그 수정을 몇달동안 진행하지만 추가되지 않거나 버그가 죽지 않을 때, 해결책 Pull 요청들을 막고 더 자세히 보길 원합니다. 가능하면 오래된 것을 찾지만 여전히 활성화된 Pull 요청들이 더 쉽게 만듭니다.

저장소에 Pull 요청 페이지로부터 오랫동안 진행되고 있는 Pull 요청을 보고 정렬할 수 있습니다.

![Pull 요청 정렬](https://github-images.s3.amazonaws.com/help/pull-request-longest-running.png)

오랫동안 진행되고 있는 Pull 요청은 한달 이상 존재하고 있는 것과 지난 달에 활동한 것들입니다. 오랫동안 진행되고 있는 Pull 요청의 필터 화면은 수명에 의해 정렬됩니다.(생성되어 최근까지 활동한 시간)

### 관련 주제

- [Pull 요청 합치기](http://minsone.github.io/lesson/2013/12/23/github-Merging-a-Pull-Request/)
- [Pull 요청 닫기](http://minsone.github.io/lesson/2013/12/25/GitHub-Closing-a-Pull-Request/)
- [Pull 요청 정리하기](http://minsone.github.io/lesson/2013/12/25/GitHub-Tidying-up-pull-requests/)

---



















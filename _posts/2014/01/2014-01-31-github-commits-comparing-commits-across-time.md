---
layout: post
title: "[번역]GitHub / Commits / 시간으로 커밋 비교"
description: ""
categories: [git]
tags: [git, github, commit, compare, time, fork, branch, tag, commit]
---
{% include JB/setup %}

이 문서는 [Comparing commits across time](https://help.github.com/articles/comparing-commits-across-time)의 비공식 번역글이며 GitHub에서 보증, 유지 또는 감독하지 않습니다. 공식 도움글을 보시려면 [help.github.com](https://help.github.com)을 방문하세요.

---

## 시간으로 커밋 비교

모든 저장소는 브랜치, 태그, 커밋, 시간 간격 등으로 저장소 상태를 비교할 수 있는 화면이 있습니다. 비교 화면은 Pull 요청 화면과 동일한 비교 도구를 제공합니다.

비교 화면을 얻으려면 `/compare`를 저장소 경로에 추가하세요.

[https://github.com/github/linguist/compare](https://github.com/github/linguist/compare/)인 Linguist가 비교 페이지를 보고 비교 능력을 발휘합니다.

모든 저장소 비교 화면은 두개 드랍 다운 메뉴(`base`와 `compare`)이 있습니다.

![comparing branches](/../../../../image/2014/comparing_branches.png)

`base`는 비교 시작 시점과 `compare` 끝 지점을 잘 고려해야 합니다. 비교하면서 **Edit**를 클릭하여 `base`와 `compare` 지점을 언제든지 변경할 수 있습니다.


## 브랜치 비교

일반적인 비교 방법 중 하나는 새로운 Pull 요청을 시작할 때, 브랜치를 비교하는 것입니다. [새로운 Pull 요청](https://help.github.com/articles/creating-a-pull-request)을 시작할 때 브랜치 비교 화면에서 가져올 수 있습니다.

브랜치를 비교하려면 페이지 상단에 `compare` 드랍 다운 메뉴에서 브랜치 이름을 선택할 수 있습니다.

[두 브랜치간 비교](https://github.com/github/linguist/compare/jenkins-pluginspec)하는 예제가 있습니다.


## 태그 비교

비슷하게 [프로젝트 배포](https://help.github.com/articles/creating-releases)를 위해 만든 태그로 비교할 수 있습니다. 태그 비교는 프로젝트에 다른 버전 간에 배포 기록을 모으는 훌륭한 방법입니다.

브랜치 이름을 입력 하는 대신 `compare` 드랍 다운 메뉴에 태그 이름을 입력합니다.

[두 태그간 비교](https://github.com/github/linguist/compare/v2.2.0...v2.3.3)하는 예제가 있습니다.


## 커밋 비교

마찬가지로 저장소에 있는 임의의 두개 커밋을 비교할 수 있습니다. 전체 SHA 해쉬 또는 짧은 8자 코드 중 하나를 받아 커밋간 비교를 만듭니다. 

[두 커밋간 비교](https://github.com/github/linguist/compare/96d29b7662f148842486d46117786ccb7fcc8018...a20631af040b4901b7341839d9e76e31994adda3)하는 예제가 있습니다.


## fork로 비교

기본 저장소와 fork된 저장소를 비교할 수 있습니다. 이 화면은 프로젝트에 Pull 요청을 수행할 때 보여줍니다.

각기 다른 저장소에 브랜치를 비교하려면 브랜치 이름과 사용자 이름을 붙입니다. 예를 들어 `base`에 `github:master`를 `compare`에 `gjtorikian:master`를 지정하여 각각 `github`과 `gjtorikian`가 있는 저장소에 `master` 브랜치를 비교할 수 있습니다. 

[두 저장소간 비교](https://github.com/gjtorikian/linguist/compare/github:master...gjtorikian:master)하는 예제가 있습니다.


## 시간으로 비교

1달 또는 2주와 같은 임의 시간 간격으로 비교를 만듭니다. 시간 간격을 정의하려면 날짜를 `{@ }`표시로 감싸며 브랜치 이름앞에 붙입니다. 예를 들어 `compare`드랍다운 메뉴에 `{@2weeks}master` 입력하여 `master`브랜치와 2주전의 브랜치를 비교합니다.

[두개의 시간 간격 비교](https://github.com/github/linguist/compare/master@%7B1month%7D...master)하는 예제가 있습니다.


## 커밋으로 비교

간단한 방법으로 Git은 "한 커밋 이전"을 의미하는 `^` 표시를 사용합니다.

바로 전 작업에 대한 단일 커밋 또는 브랜치를 비교하기 위해 이 표시를 사용할 수 있습니다. 예를 들어 `96d29b7^^^^^`는 `96d29b7` 이전 다섯번째 커밋을 가르킵니다. 왜냐하면 `^` 표시가 5개 있기 때문이죠.

[`^`표시를 이용한 변경](https://github.com/github/linguist/compare/96d29b7662f148842486d46117786ccb7fcc8018%5E%5E%5E%5E%5E...96d29b7662f148842486d46117786ccb7fcc8018) 예제가 있습니다.
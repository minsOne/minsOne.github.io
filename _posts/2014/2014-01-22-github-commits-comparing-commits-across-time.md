---
layout: post
title: "[번역]GitHub / Commits / Comparing commits across time 시간으로 커밋 비교"
description: ""
categories: [translate, Commits, Commit Message, Issue]
tags: [git, GitHub, Commits]
---
{% include JB/setup %}

## Comparing commits across time 시간으로 커밋 비교

Every repository contains a Compare view, which allows you to compare the state of your repository across branches, tags, commits, time periods, and more. The compare view provides you with the same diff tooling that the Pull Request view does.

모든 저장소는 브랜치, 태그, 커밋, 시간 구간 등으로 저장소 상태를 비교할 수 있는 화면을 가집니다. 비교 화면은 Pull 요청 화면과 동일한 비교 도구를 제공합니다.

To get to the compare view, append `/compare` to your repository's path.

비교 화면을 얻으려면 `/compare`를 저장소 경로에 추가하세요.

We'll demonstrate the power of Compare by looking at the compare page for Linguist, which is at [https://github.com/github/linguist/compare/](https://github.com/github/linguist/compare/).

<!-- TODO:좀 더 다듬기 -->
[https://github.com/github/linguist/compare](https://github.com/github/linguist/compare/)인 Linguist가 비교 페이지를 보고 비교 능력을 발휘합니다.

Every repository's Compare view contains two drop down menus: `base` and `compare`.

모든 저장소 비교 화면은 두개 드랍 다운 메뉴를 가집니다:`base`와 `compare`.

`base` should be considered the starting point of your comparison, and `compare` is the endpoint. During a comparison, you can always change your `base` and `compare` points by clicking on **Edit**.

`base`는 비교 시작 시점과 `compare` 끝 지점을 잘 고려해야 합니다. 비교하면서 **Edit**를 클릭하여 `base`와 `compare` 지점을 언제나 변경할 수 있습니다.


## Comparing branches 브랜치 비교

The most common use of Compare is to compare branches, such as when you're starting a new Pull Request. You'll always be taken to the branch comparison view when starting [a new Pull Request](https://help.github.com/articles/creating-a-pull-request).

일반적인 비교 방법 중 하나는 새로운 Pull 요청을 시작할 때와 같이 브랜치를 비교하는 것입니다. 

To compare branches, you can select a branch name from the `compare` drop down menu at the top of the page.

브랜치를 비교한다면 페이지 상단에 `compare` 드랍 다운 메뉴에서 브랜치 이름을 선택할 수 있습니다.

Here's an example of a [comparison between two branches](https://github.com/github/linguist/compare/jenkins-pluginspec).

여기에 [두개 브랜치간의 비교](https://github.com/github/linguist/compare/jenkins-pluginspec)예제가 있습니다.


## Comparing tags 태그 비교

Similarly, you can compare across tags made for [project releases](https://help.github.com/articles/creating-releases). Comparing against tags is a great way to assemble release notes between different versions of your project.

비슷하게 [프로젝트 배포](https://help.github.com/articles/creating-releases) 위해 만든 태그로 비교할 수 있습니다. 태그에 대한 비교는 프로젝트에 다른 버전 간에 배포 기록을 모으는 훌륭한 방법입니다.

Instead of typing a branch name, type the name of your tag in the `compare` drop down menu.

브랜치 이름을 입력 하는 대신 `compare` 드랍 다운 메뉴에 태그 이름을 입력합니다.

Here's an example of a [comparison between two tags](https://github.com/github/linguist/compare/v2.2.0...v2.3.3).

여기에 [두개 태그간의 비교](https://github.com/github/linguist/compare/v2.2.0...v2.3.3) 예제가 있습니다.


## Comparing commits

You can also compare two arbitrary commits in your repository. Comparisons between commits are made by providing either the full SHA hash or the short eight-character code.

Here's an example of a [comparison between two commits](https://github.com/github/linguist/compare/96d29b7662f148842486d46117786ccb7fcc8018...a20631af040b4901b7341839d9e76e31994adda3).



## Comparing across forks

You can compare your base repository and any forked repository. This is the view that's presented when a user performs a Pull Request to a project.

To compare branches on different repositories, preface the branch names with user names. For example, by specifying `github:master` for `base` and `gjtorikian:master` for `compare`, you can compare the `master` branch of the repositories respectively owned by `github` and `gjtorikian`.

Here's an example of a [comparison between two repositories](https://github.com/gjtorikian/linguist/compare/github:master...gjtorikian:master).



## Comparisons across time

Comparisons can be created for arbitrary time periods, like one month or two weeks. To define a time period, wrap the date between a `{@ }` notation, followed by the branch name. For example, typing `{@2weeks}master` into the `compare` dropdown menu compares a branch against the `master` branch as it was two weeks prior.

Here's an example of a [comparison between two time periods](https://github.com/github/linguist/compare/master@%7B1month%7D...master).



## Comparisons across commits

As a shortcut, Git uses the `^` notation to mean "one commit prior."

You can use this notation to compare a single commit or branch against its immediate predecessors. For example, `96d29b7^^^^^` indicates five commits prior to `96d29b7`, because there are five `^` marks.

Here's an example of a [comparison using the `^` notation](https://github.com/github/linguist/compare/96d29b7662f148842486d46117786ccb7fcc8018%5E%5E%5E%5E%5E...96d29b7662f148842486d46117786ccb7fcc8018).


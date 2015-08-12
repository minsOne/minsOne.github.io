---
layout: post
title: "[Git]일시적으로 파일 변경 무시하기"
description: ""
category: "git"
tags: [git, update-index, ignore, gitignore]
---
{% include JB/setup %}

가끔씩 특정 파일을 변경하지만 변경 상태를 무시하고자 할 때가 있습니다.

다음은 파일의 변경 상태를 무시하는 명령어입니다.

`git update-index --assume-unchanged <file>`

<br/>무시한 파일을 다시 돌리는 명령어입니다.

`git update-index --no-assume-unchanged <file>`

<br/>무시한 파일들의 목록을 나타내는 명령어입니다.

`git ls-files -v | grep "^[[:lower:]]"`
---
layout: post
title: "[Shell]터미널에서 SourceTree 실행하기"
description: ""
category: "Shell"
tags: [shell, terminal, sourcetree]
---
{% include JB/setup %}

터미널에서 open 명령어를 통해 SourceTree를 실행할 수 있습니다.

	open -a SourceTree [Repository Path]

또는 .bashrc 또는 .zshrc에 등록하여 사용할 수 있습니다.

	echo "alias sourcetree='open -a SourceTree'" >> ~/.zshrc
	source ~/.zshrc
	sourcetree [Repository Path]
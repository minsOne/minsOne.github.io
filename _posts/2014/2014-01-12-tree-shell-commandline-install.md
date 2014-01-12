---
layout: post
title: "Tree Shell 명령어"
description: ""
category: ""
tags: [shell, tree, os x]
---
{% include JB/setup %}

### Tree Shell 명령어 설치하기

- tree 소스를 다운받고 압축을 해제한다.
> curl -O ftp://mama.indstate.edu/linux/tree/tree-1.5.3.tgz<br />
> tar xzvf tree-1.5.3.tgz<br />
> cd tree-1.5.3/ <br />

- Makefile을 열고 OS X부분에 주석을 해제한다.
> vi Makefile<br />
> \# Uncomment for OS X:<br />
> CC=cc<br />
> CFLAGS=-O2 -Wall -fomit-frame-pointer -no-cpp-precomp<br />
> LDFLAGS=<br />
> XOBJS=strverscmp.o<br />

- `sudo make install`을 실행한다.

- tree 명령어를 실행하여 정상적으로 실행되는지 확인한다.




### 정규식을 통한 Tree Shell 명령어 만들기(폴더만)

`ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'`
---
layout: post
title: "[Tool]마크다운 파일의 목차를 만들어주는 doctoc"
description: ""
category: "Tool"
tags: [markdown, npm, node]
---
{% include JB/setup %}

마크다운 형태의 파일을 작성하다보면 목차를 만들어야 하는 경우가 있습니다. 그런데 내용이 점점 많아지면 목차를 만들기 귀찮아지기도하고 변경한 것들을 다시 정리를 해야하는데 일일이 찾아서 변경하기엔 시간이 많이 듭니다.

thlorenz가 만든 [doctoc](https://github.com/thlorenz/doctoc)이 이러한 목차들을 만들어주는 tool입니다.


### 설치

	npm install -g doctoc


### 사용방법

폴더에 있는 마크다운 파일을 모두 목차를 만들고자 하면 다음과 같이 실행합니다.
	
	doctoc [filePath]

단일 파일만 목차를 만들고자 한다면 다음과 같이 실행합니다.

	doctoc [fileName]


### 생성 결과

목차를 생성하면 다음과 같이 생성됩니다.

	$ doctoc README.md

	**Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*

	 - [DocToc [![build status](https://secure.travis-ci.org/thlorenz/doctoc.png)](http://travis-ci.org/thlorenz/doctoc)](#doctoc-!build-statushttpssecuretravis-ciorgthlorenzdoctocpnghttptravis-ciorgthlorenzdoctoc)
	    - [Installation](#installation)
	    - [Usage](#usage)
	        - [Adding toc to all files in a directory and sub directories](#adding-toc-to-all-files-in-a-directory-and-sub-directories)
	        - [Adding toc to a single file](#adding-toc-to-a-single-file)
	            - [Example](#example)
	        - [Using doctoc to generate bitbucket compatible links](#using-doctoc-to-generate-bitbucket-compatible-links)


<div class="alert alert-danger" role="alert">경고 : jekyll에서는 아직 마크다운 파일을 html형태로 만들어주었을 때 태그의 id값이 한글이면 나타나지 않습니다. 그러나 영어 문서에서는 해당 오류는 나타나지 않습니다.( doctoc과는 무관합니다. )</div>
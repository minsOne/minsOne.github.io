---
layout: post
title: "[Shell][ImageMagick]홀수 크기의 이미지에 패딩 추가하기"
description: ""
category: "programming"
tags: [ImageMagick, shell, find, identify, convert, padding]
---
{% include JB/setup %}

iOS 개발을 하다보면, 2x 사이즈로 이미지를 받곤 하는데 이들 이미지에서 간혹 폭, 높이가 홀수 크기로 받는 경우가 있습니다. 이를 다시 1x 사이즈로 줄여야 해야하는데, 홀수라면 난감한 경우가 있습니다. 따라서 이미지 캔버스 크기를 늘려 짝수로 만들어야 1x 사이즈로 줄일 수 있습니다.

이를 위해 [ImageMagick](http://www.imagemagick.org/)을 사용합니다.

이미지 정보를 얻기 위해 ImageMagick 툴 중에서 [identify](http://www.imagemagick.org/script/identify.php)를 사용하며, 이미지 캔버스를 늘리기 위해 [convert](http://www.imagemagick.org/script/convert.php)를 사용합니다.

	#!/bin/bash

	WIDTH=$(identify -format "%w" $1)
	HEIGHT=$(identify -format "%h" $1)

	PADDING_WIDTH=0
	PADDING_HEIGHT=0

	if [ $((WIDTH % 2)) -eq 1 ]
	then
	    PADDING_WIDTH=1
	fi

	if [ $((HEIGHT % 2)) -eq 1 ]
	then
	    PADDING_HEIGHT=1
	fi

	if [ $PADDING_WIDTH -eq 1 ]||[ $PADDING_HEIGHT -eq 1 ]
	then
	    convert $1 -background transparent -extent $((WIDTH + PADDING_WIDTH))x$((HEIGHT + PADDING_HEIGHT)) $1
	    echo $1 ": " $WIDTH $HEIGHT " -> " $(identify -format "%w %h" $1)
	fi

이 스크립트를 `/usr/local/bin/` 경로에 padding으로 저장합니다.

모든 이미지 중 홀수 폭, 높이 크기를 가진 이미지를 `find`를 이용하여 일괄 적용합니다.

	find . -type f -name "*.png" -exec padding {} \;

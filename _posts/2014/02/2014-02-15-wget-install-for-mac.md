---
layout: post
title: "[Shell]Mac에서 wget 설치하기"
description: ""
category: "Shell"
tags: [mac, shell, wget]
---
{% include JB/setup %}

기본적으로 Mac에서는 wget이 설치되어 있지 않습니다. 따라서 wget을 다운받고 설치를 해야합니다.

1. 최신 wget 소스를 다운받습니다.

	curl -O http://ftp.gnu.org/gnu/wget/wget-1.15.tar.gz

2. wget 소스 압축을 풉니다.

	tar -xzf wget-1.15.tar.gz

3. 디렉토리를 이동합니다.

	cd wget-1.15

4. Configure하며 "GNUTLS not available" 에러를 방지하기 위해 –with-ssl을 적용시킵니다.

	./configure --with-ssl=openssl

5. 소스를 빌드하고 /usr/local/bin/ 경로에 설치합니다.
	
	make && make install

6. wget 명령어가 정상적으로 되는지 help 옵션으로 실행합니다.

	wget --help
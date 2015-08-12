---
layout: post
title: "[Tool]gsutil을 사용하여 구글 판매 통계 가져오기"
description: ""
category: "Tool"
tags: [gsutil, python, google, sale, report]
---
{% include JB/setup %}

구글 플레이 스토어에 판매된 과금들에 대해 구글 클라우드 스토리지에서 통계 자료를 가지고 올 수 있습니다.

따라서 자동화툴로 매일 구글에서 얼마나 수익이 나는지 프로그래밍을 통해 통계 자료를 가공하는 것이 가능합니다.

그러면 gsutil을 이용하여 판매 통계 자료를 가져오는 방법에 대해 설명합니다.

1.우선 http://storage.googleapis.com/pub/gsutil.tar.gz에서 gsutil을 다운을 받습니다.
	
	$ curl -O http://storage.googleapis.com/pub/gsutil.tar.gz

2.gsutil을 압축을 풉니다.

	$ tar xvf gsutil.tar.gz 

3.gsutil을 실행할 수 있도록 profile에 설정합니다. window의 cygwin인 경우 ~/.bashrc, Mac OSX, Linux 등 unix계열인 경우 ~/.bash_profile에 다음을 기록합니다.

	export PATH=${PATH}:$HOME/gsutilPath

4.gcc openssl-devel python-devel python-setuptools라이브러리가 설치되어 있지 않다면 설치합니다.
	
	CentOS인 경우
	$ sudo yum install gcc openssl-devel python-devel python-setuptools

5.gsutil config 실행, URL이 나와있는 곳으로 브라우저 이동합니다.

6.구글 클라우드 스토리지 권한 허용 후 코드 복사합니다.

7.gsutil config상태에서 코드 복사, 프로젝트 이름 입력합니다.(ex. corpProject)

8.판매통계자료 다운로드합니다.(판매통계는 매월 자료로 나옴)
	
	gsutil cp -r gs://pubsite_prod_rev_[판매자ID]/sales/salesreport_201308.zip .

<div class="alert-info">팁 : Python은 2.7이상이어야 가능합니다.</div>

#### 참고자료

- [gsutil_install](https://developers.google.com/storage/docs/gsutil_install)


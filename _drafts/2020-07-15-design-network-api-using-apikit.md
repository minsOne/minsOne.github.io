---
layout: post
title: "[Swift] APIKit을 이용하여 Network API 디자인하기"
description: ""
category: ""
tags: []
---
{% include JB/setup %}

네트워크 API는 Base URL, Header Field, MIME Type 등의 공통 환경 설정이 있습니다. 이런 설정은 공통으로 상속받는 타입에서만 구현하고, 나머지 
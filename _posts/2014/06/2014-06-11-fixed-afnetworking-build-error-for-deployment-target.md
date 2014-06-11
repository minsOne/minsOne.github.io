---
layout: post
title: "[iOS]AFNetworking에서 afnetworking property with 'retain (or strong)' attribute must be of object type 에러 처리하기"
description: ""
category: "ios"
tags: [ios, afnetworking, retain, strong, property]
---
{% include JB/setup %}

프로젝트를 생성 후 네트워크 부분을 추가하기 위해서 AFNetworking을 사용하는 경우 `afnetworking property with 'retain (or strong)' attribute must be of object type` 에러가 발생하면서 빌드가 되지 않는 상황이 발생합니다.

이때 Target의 General -> Deployment Info에 있는 Deployment Target 버전이 6.0미만인 경우 위에서 나타난 에러가 나타납니다.

따라서 Deployment Target 버전을 6.0이상으로 올려서 작업하시면 됩니다. 만약 5.x미만을 지원해야 한다면 다른 라이브러리를 찾아보시는게 빠를 것 같습니다.. 쿨럭..


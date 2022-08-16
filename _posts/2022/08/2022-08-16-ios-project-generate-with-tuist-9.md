---
layout: post
title: "[iOS][Tuist] 프로젝트 생성/관리 도구 Tuist(9) - Tuist 버전 고정하고 사용하기 .tuist-version"
tags: [Tuist]
---
{% include JB/setup %}

Tuist는 버전 올라가는 주기가 빠르기 때문에, 버전을 고정하지 않으면, 개발자마다 각기 다른 Tuist 버전을 사용하게 됩니다.

[Managing Tuist versions](https://docs.tuist.io/guides/version-management/#local)문서에서 Tuist의 버전을 동일한 버전으로 맞춰 사용하도록 `.tuist-version` 파일을 만들고, 해당 파일에 고정할 Tuist 버전을 작성하는 것을 알려줍니다.

```shell
$ echo "3.9.0" > .tuist-version
$ cat .tuist-version
3.9.0
```

이제 이 파일을 기준으로 모든 작업자, 빌드 머신 등이 같은 버전을 바라봅니다. 만약 `.tuist-version` 파일에서 버전이 변경되면 모든 작업자와 빌드 머신 등도 변경된 버전을 바라보고, 해당 버전 바이너리가 없다면, 설치하고 tuist 명령어가 실행됩니다.

## 참고자료

* [Tuist Document - Managing Tuist versions](https://docs.tuist.io/guides/version-management)
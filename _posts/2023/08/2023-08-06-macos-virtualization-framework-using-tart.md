---
layout: post
title: "[macOS] Tart를 이용하여 Virtualization Framework 사용해보기"
tags: [macOS, Virtualization, Tart]
---
{% include JB/setup %}

macOS 11.0에서는 Virtualization 프레임워크를 도입하여, 이를 활용해 macOS와 Linux 기반 운영체제를 가상 머신으로 실행할 수 있게 되었습니다. [Document](https://developer.apple.com/documentation/virtualization)

Virtualization 프레임워크를 사용하면, VM에서 빌드를 수행하므로 일관된 환경에서 작업이 가능합니다. 그 결과 각 빌드 머신마다 Xcode 설치, OS 업데이트, 라이브러리 추가 등의 작업을 수행할 필요가 없어집니다.

macOS 이미지를 관리하고 다양한 편의 기능을 제공하는 도구를 활용하면 초기 작업시간을 크게 줄일 수 있습니다.

그 중 Virtualization 프레임워크를 활용하는 라이브러리 Tart([Link](https://tart.run/), [GitHub](https://github.com/cirruslabs/tart/))를 이용하여 MacOS의 VM을 생성해보겠습니다.


## Tart

1.HomeBrew를 이용하여 Tart를 설치합니다:

```shell
$ brew install cirruslabs/cli/tart
```

2.`tart clone`를 이용하여 이미지를 내려받습니다:

```shell
$ tart clone ghcr.io/cirruslabs/macos-ventura-base:latest ventura-base
```

해당 이미지는 [orgs/cirruslabs](https://github.com/orgs/cirruslabs)의 Packages에서 필요한 macOS 이미지를 선택해 다운로드하면 됩니다. 순수한 macOS가 필요하면 'vanilla', brew가 설치된 버전이 필요하면 'base', Xcode가 설치된 버전이 필요하면 'xcode'를 선택합니다.

<p style="text-align:center;"><img src="{{ site.prod_url }}/image/2023/08/01.png" style="border: 1px solid #555; width:500px;"/></p><br/>

[링크](https://github.com/orgs/cirruslabs/packages?tab=packages&q=macos-)

<div class="alert warning"><strong>주의</strong> : 이미지 용량이 크므로 미리 충분한 저장 공간을 확보해두세요.</div>

이후 .tart 폴더 내에 VM 이미지가 생성된 것을 확인할 수 있습니다.

```shell
$ tree .tart
.tart
├── cache
│   ├── IPSWs
│   └── OCIs
│       └── ghcr.io
│           └── cirruslabs
│               └── macos-ventura-base
│                   └── latest -> /Users/minsone/.tart/cache/OCIs/ghcr.io/cirruslabs/macos-ventura-base/sha256:d67230f3e3f0e52bae4e0923aa7d7ebaa5e799df9b812eab18557675d1480c84
├── tmp
└── vms
    └── ventura-base
        ├── config.json
        ├── disk.img
        └── nvram.bin

9 directories, 4 files
```

이미지의 용량과 실제 이미지는 차이가 있으므로 이를 확인하는 것이 중요합니다.

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2023/08/02.png" style="border: 1px solid #555; width:300px;"/></p><br/>

3.이제 생성한 VM 이미지를 Tart로 실행합니다:

```shell
$ tart run ventura-base
```

<p style="text-align:center;"><img src="{{ site.prod_url }}/image/2023/08/03.png" style="width:600px;"/><img src="{{ site.prod_url }}/image/2023/08/04.png" style="width:600px;"/></p>


4.해당 이미지의 계정은 `admin/admin`으로 설정되어 있습니다. 이를 통해 ssh를 사용하여 해당 VM에 로그인할 수 있습니다:

```shell
$ ssh admin@$(tart ip ventura-base)
```

매번 비밀번호를 입력하는 것이 번거롭다면, `ssh-copy-id`를 사용하여 비밀번호 입력을 생략할 수 있습니다:

```shell
$ ssh-copy-id admin@$(tart ip ventura-base)
```

원격으로 명령을 실행할 수 있습니다:

```shell
$ ssh admin@$(tart ip ventura-base) ls -al
$ ssh admin@$(tart ip ventura-base) 'ls -a; df'
```

## 정리

* Tart를 사용하여 macOS를 가상 머신으로 실행할 수 있습니다.
* 이미지의 용량이 커, 이미지 관리를 어떻게 해야할지 판단이 필요할 것 같습니다.

## 참고자료

* [Apple Document - Virtualization](https://developer.apple.com/documentation/virtualization)
* [Tart](https://tart.run/)
* [Cilicon](https://github.com/traderepublic/Cilicon)
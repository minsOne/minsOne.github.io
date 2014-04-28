---
layout: post
title: "[번역]GitHub / Release / Releases 만들기"
description: ""
categories: [git]
tags: [git, github, release, tag]
---
{% include JB/setup %}

이 문서는 [Creating Releases](https://help.github.com/articles/creating-releases)의 비공식 번역글이며 GitHub에서 보증, 유지 또는 감독하지 않습니다. 공식 도움글을 보시려면 [help.github.com](https://help.github.com)을 방문하세요.

---

## Releases 만들기

GitHub에서 Releases는 소프트웨어를 보내고 제공할 수 있는 좋은 방법입니다.

### 새로운 Releases 만들기

1. 저장소로 이동하여 **Releases** 상단 항목을 클릭합니다.<br/><img src="/../../../../image/2014/03/github-releases-header-menu.png" alt="header-menu" style="width: 300px;"/><br/>

2. **Create a new release**를 클릭합니다. Release 생성 페이지로 이동합니다:<br/><img src="/../../../../image/2014/03/github-releases-draft-page.png" alt="draft-page" style="width: 600px;"/><br/>

3. Releases는 브랜치에 태그를 기반으로 합니다. [semantic versioning](http://semver.org/)에 맞는 태그 이름을 추천합니다. 당신은 또한 `master` 브랜치(몇 가지 베타 소프트웨어가 아니라면)에 대하여 Releases를 기록하고 싶어 합니다.

4. Releases에 멋진 제목과 설명을 넣습니다.

5. 당신이 원한다면, 컴파일된 프로그램 같은 바이너리 파일을 드래그하여 같이 Release 할 수 있습니다.<br/><img src="/../../../../image/2014/03/github-dragging_binaries.png" alt="dragging_binaries" style="width: 400px;"/><br/>

6. 안정적이지 않거나 불완전한 Release라면 **Prerelease box**를 체크하여 유저들에게 알릴 수 있습니다.

아직 Release를 만들 준비가 되지 않았다면 **Save draft**를 눌러 나중에 작업을 할 수 있습니다. 반면에 **Publish release**를 클릭하면 배포를 시작합니다!
---
layout: post
title: "[번역]GitHub / Commits / 왜 내 커밋이 잘못된 유저로 연결되나요?"
description: ""
categories: [Git]
tags: [git, github, translate, commit]
---
{% include JB/setup %}

이 문서는 [Why are my commits linked to the wrong user?](https://help.github.com/articles/why-are-my-commits-linked-to-the-wrong-user) 의 비공식 번역글이며 GitHub에서 보증, 유지 또는 감독하지 않습니다. 공식 도움글을 보시려면 [help.github.com](https://help.github.com)을 방문하세요.

---

## 왜 내 커밋이 잘못된 유저로 연결되나요?

GitHub은 커밋 헤더에 커밋이 연결된 사용자의 이메일을 사용합니다. 커밋이 다른 사용자로 책임을 지우거나 사용자와 전혀 연결이 되어 있지 않음을 찾는다면 설정을 확인해야 합니다. 

<div class="alert-info"><strong>팁</strong> : 커밋 책임은 저장소에 접근 권한을 주는 것이 아닙니다. 커밋을 보고 모르는 유저 탓을 한다면 걱정 안해도 됩니다. 솔직하게 저장소나 저장소에 접근하는 팀에 공동 제작자로 추가하기 전까지 유저는 저장소에 접근 할 수 없습니다.</div>

### 커밋과 일치하게 만들기

커밋에게 정확히 책임을 지우도록 GitHub에 하기 위해서는 git 이메일 설정이 맞고 이메일이 계정에 연결되었는지 확인해야 합니다.

#### Git 환경설정하기

git설정을 확인하기 위해 다음 명령을 실행하세요.

	$ git config user.email
	# you@there.com

이메일이 맞지 않다면 전역 설정을 변경할 수 있습니다.

	$ git config --global user.email "me@here.com"

<div class="alert-info"><strong>팁</strong> : 여러대의 컴퓨터에서 작업한다면 각각의 컴퓨터에 설정을 확인해야 합니다.</div>

#### GitHub 계정에 이메일 연결하기

이메일이 GitHub 계정에 연결되지 않는다면 추후 커밋에 올바르게 책임을 지도록 추가해야 합니다.

1. [계정 설정](https://github.com/settings)으로 이동하세요.<br/><img src="/../../../../image/2013/userbar-account-settings.png" alt="Account settings button" style="width: 150px;"/><br/><br/>

2. [이메일](https://github.com/settings/emails)을 클릭하세요.<br/><img src="/../../../../image/2013/settings-sidebar-emails.png" alt="Account settings button" style="width: 150px;"/><br/><br/>

3. "다른 이메일 주소 추가하기" 클릭하세요.<br/><img src="/../../../../image/2013/settings-email-add-another-email-address.png" alt="Email addition button" style="width: 150px;"/><br/><br/>

4. 이메일 주소를 입력하고 "추가" 클릭하세요.<br/><img src="/../../../../image/2013/settings-email-add-form.png" alt="Add email button" style="width: 150px;"/><br/><br/>

추가 보안을 위해 [GitHub에 이메일 인증](https://help.github.com/articles/setting-up-email-verification)을 할 수 있습니다.

### 과거는 역사이다.

잘못된 이메일을 사용하거나 이메일이 다른 계정에 이미 연결되었다면 이전 커밋은 정확하게 책임 지지 않을 것입니다. Git은 저장소 역사를 수정하고 정정할 수 있도록 하는 동안에 변경되는 커밋을 원격 저장소에 Push 하는 것을 적극적으로 만류합니다. 변경에 대한 자세한 내용은 [이 문서를 참고하세요](https://help.github.com/articles/changing-author-info).

이전 커밋은 올바른 이메일을 사용하면 계정에 이메일을 추가한 후 연결을 시작합니다. 하지만 이 상황이 발생하기 전에 서버 캐쉬에 오래된 데이터가 삭제되는 조금 시간이 걸릴 수도 있습니다.

앞으로 가서 설정이 일치한다면 새로운 커밋은 책임지고 계정과 연결이 됩니다.
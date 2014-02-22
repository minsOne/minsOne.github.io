---
layout: post
title: "[번역]GitHub / Collaborating / Pull 요청 합치기"
description: ""
categories: [translate, Collaborating]
tags: [git, GitHub]
---
{% include JB/setup %}

다음의 [Merging a pull request](https://help.github.com/articles/merging-a-pull-request) 번역하였습니다.

## Pull 요청 합치기

일단 Pull 요청이 만족스럽게 생각되면 대상 저장소에 Push 접근을 할 수 있는 누군가는 합칠 수 있습니다. 합칠 수 있는 다양한 벙법이 있습니다. 아래에 두가지 유명한 방법이 기술되어 있습니다.

### GitHub에서 바로 합치기

만약 합치는 것이 어떠한 충돌도 있지 않다면 하나의 Git 명령어를 치지 않고서도 온라인으로 Pull 요청을 합칠 수 있습니다.

1. Pull 요청 페이지를 열으세요.

2. **Merge pull request** 버튼을 클릭하세요.<br/><img src="/../../../../image/2013/pullrequest-mergebutton.png" alt="Merge pull request button" style="width: 500px;"/><br/><br/>

3. 커밋 메시지를 입력하세요.<br/><img src="/../../../../image/2013/pullrequest-commitmessage.png" alt="Commit message field" style="width: 500px;"/><br/><br/>

4. **Confirm Merge** 클릭하세요.<br/><img src="/../../../../image/2013/pullrequest-confirmmerge.png" alt="Confirm button" style="width: 500px;"/><br/><br/>


### 로컬에서 합치기

만약 Pull 요청을 온라인에서 합칠 수 없다거나 GitHub에 저장소를 합쳐서 보내기전에 로컬에서 이것을 테스트하길 원한다면, 로컬에서 합칠 수 있습니다. 이것은 저장소에 Push 접근을 할 수 없다해도 편리합니다.

#### Pull 

패치와 변경사항 적용은 가장 흔한 방법입니다. 이 방법은 커밋 히스토리를 수정하지 않고 유지할 것입니다.

1. 합치기 버튼의 왼쪽에 있는 `command line`을 클릭합니다.<br/><img src="/../../../../image/2013/pullrequest-manualinstructions.png" alt="Merge pull information message" style="width: 500px;"/><br/><br/>

2. Pull 요청에 표시되는 지시를 따릅니다.<br/>주의: 모든 Pull 요청과는 다를 수 있습니다.

만약 저장소에 쓰기권한이 없다면, 로컬에서 명령어를 실행할 수 있습니다.

1. 터미널에서 로컬 저장소를 엽니다.

2. 합치고 싶은 브랜치를 체크아웃 합니다.<br/>
```$ git checkout master```

3. 다른 유저의 저장소로부터 훌륭한 브랜치를 Pull 합니다.<br/>
```$ git pull https://github.com/otheruser/repo.git branchname```

4. 충돌을 해결하고 합친 것을 커밋합니다.

5. 변경사항들을 리뷰하고 만족스러울 만큼 확인합니다.

6. GitHub 저장소에 합친 것을 Push 합니다.<br/>
```$ git push origin master```<br/><br/>

#### 패치와 적용

Pull은 팀 또는 같은 소규모 그룹으로부터 반복되는 변경사항 적용하는 작업을 할 때 훌륭하게 작동합니다. 또 다른 방법으로는 일회성인 경우에서 git-am을 사용하여 조금 더 빠르게 합니다.

이 방법은 커밋 히스토리를 **유지하지 않습니다**. 로컬 테스팅 또는 공유하지 않는 저장소에 적용하기 위한 좋은 방법입니다. 만약 원격 저장소에 Push하고 있다면 Pull 방법은 바람직한 방법입니다.

모든 Pull 요청은 `git am` 명령어에 넣을 패치 파일이 있는 특정 URL을 가지고 있습니다.

1. 패치하고 싶은 Pull 요청 페이지를 방문합니다.

2. URL을 복사합니다.

3. 터미널에서 로컬 저장소를 엽니다.

4. 합치고 싶은 브랜치를 체크아웃 합니다.<br/>
```$ git checkout master```

5. 다운로드를 하고 패치를 적용합니다.<br/>
```$ curl http://github.com/otheruser/repo/pull/25.patch | git am```

### 관련 주제들
[Pull 요청 정리하기](http://minsone.github.io/lesson/2013/12/25/GitHub-Tidying-up-pull-requests/)

<!-- {% highlight bash%}git push origin master{% endhighlight %} -->
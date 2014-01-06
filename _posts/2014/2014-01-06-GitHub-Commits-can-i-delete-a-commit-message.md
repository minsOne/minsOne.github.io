---
layout: post
title: "[번역]GitHub / Commits / 커밋 메시지를 삭제할 수 있나요?"
description: ""
category: "translate"
tags: [git, GitHub, Commits, rebase, amend, push]
---
{% include JB/setup %}

다음의 [Can I delete a commit message?](https://help.github.com/articles/can-i-delete-a-commit-message) 번역하였습니다.

---

## 커밋 메시지를 삭제할 수 있나요?

예, 커밋 메시지를 변경하거나 브랜치에서 커밋을 완전히 삭제할 수 있습니다. 그러나 GitHub(또는 공유하고 있는 저장소)에 이미 Push를 한 경우 안전하게 업데이트하는 커밋을 막습니다.

### 최근 커밋 메시지 재작성하기

가장 최근 커밋 메시지를 `git commit --amend` 명령어(또는 `git gui`같은 GUI에 체크박스를 통해) 수정할 수 있습니다. 그러나 Git에서 커밋 메시지의 글은 커밋의 한 부분이고 메시지가 변하면 커밋 ID(즉, SHA1 체크섬은 커밋을 명명함)도 변합니다. 사실상 이전 커밋을 교체한 새로운 커밋을 생성합니다.

커밋이 로컬 저장소에만 있다면 안전하게 메시지를 수정할 수 있고 지금부터 브랜치 HEAD는 오래된 커밋과는 같지만 메시지만 다른 새로운 커밋이 됩니다. 이제 커밋을 Push할 수 있고 다른 사람들에게 공유할 수 있습니다.

그러나 GitHub(또는 공유하고 있는 저장소)에 오래된 커밋을 Push했다면, 수정된 커밋은 새로운 아이디를 가지며 다시 전송하기 위해 강제로 Push해야 합니다. 이미 저장소를 Clone 했고 오래된 커밋 버전을 가지고 있을 수 있는 팀 멤버와 작업하고 있다면 중대한 영향을 미칩니다. 변경한 커밋은 영구적이라고 생각하는 역사를 바꾸는 것입니다.

이 일이 발생한다면 [git rebase man page](http://git-scm.com/docs/git-rebase)에 다음 항목 [RECOVERING FROM UPSTREAM REBASE](http://git-scm.com/docs/git-rebase#_recovering_from_upstream_rebase)를 참고해 주세요.

### 오래되거나 여러개의 커밋 메시지를 새로 쓰기

최신이 아닌 커밋을 변경하길 원하면 여전히 대화형 rebase(즉, `git rebase -i`)를 사용하여 변경할 수 있습니다. 예를 들면 `git rebase -i HEAD~5`를 실행하면 현재 브랜치에 마지막 5개 커밋 목록을 볼 수 있고 각각 커밋은 `reword` 포함하는 기능(그리고 그 밖에 `squash`같은 강력하고 위험한 옵션) 위 목록에서 선택할 수 있습니다.

커밋 옆에 넣은 `reword` 메시지는 커밋을 수정하길 원하고 재작성할 기회가 주어집니다. 이전과 같이 커밋 메시지 문구 변경은 새로운 커밋 아이디(왜냐하면 데이터 SHA1 체크섬은 더이상 같지 않습니다.)로 끝납니다. 그러나 이 경우, 모든 커밋은 바꿔 쓴 커밋이 또한 새로운 아이디를 얻는데 이는 각각 커밋이 커밋 부모의 아이디를 포함하기 때문입니다.

강제로 Push해야할 필요성과 행동에 대한 영향을 다루는 것에 대한 모든 규칙은 이 경우에 적용 설명되었습니다.

강력한 명령 사용에 대한 더 상세하고 예제들을 위해 [git rebase man page](http://git-scm.com/docs/git-rebase)에 [INTERACTIVE MODE](http://git-scm.com/docs/git-rebase#_interactive_mode)를 보세요.

### GitHub에서 데이터 삭제하기

작성한 커밋이 보안 이슈가 있다면 단순히 커밋 메시지는 입력 실수를 넘어 강제 Push가 원격 저장소에 커밋을 지우지 않는다는 점을 알고 있어야 합니다. 단순히 새로운 커밋을 소개하고 브랜치 포인터를 커밋들을 가르키도록 움직입니다. 참조되지 않는 커밋은 새로운 Clone 명령에 포함되지 않지만 GitHub에서 여전히 캐쉬에 저장되어 있을 것입니다.


SHA1을 통해 직접 나쁜 커밋에 접근하는 걸 걱정한다면 캐쉬를 비우고 데이터를 깨끗히 하는 도움을 위해 [GitHub Support](https://github.com/contact)에 연락하세요.

### 그밖에 읽을 거리

- [Remove sensitive data](https://help.github.com/articles/remove-sensitive-data)
- [Git commit man page](http://git-scm.com/docs/git-commit)
- [Git rebase man page § RECOVERING FROM UPSTREAM REBASE](http://git-scm.com/docs/git-rebase#_recovering_from_upstream_rebase)
- [Git rebase man page § INTERACTIVE MODE](http://git-scm.com/docs/git-rebase#_interactive_mode)
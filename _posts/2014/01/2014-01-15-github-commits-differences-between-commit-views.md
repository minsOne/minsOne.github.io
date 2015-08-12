---
layout: post
title: "[번역]GitHub / Commits / 커밋 화면간의 차이"
description: ""
category: "Git"
tags: [git, github, commit, history, log]
---
{% include JB/setup %}

이 문서는 [Differences between commit views](https://help.github.com/articles/differences-between-commit-views)의 비공식 번역글이며 GitHub에서 보증, 유지 또는 감독하지 않습니다. 공식 도움글을 보시려면 [help.github.com](https://help.github.com)을 방문하세요.

---

## 커밋 화면간의 차이

본래 GitHub에 저장소의 커밋 히스토리를 보는 두가지 방법이 있습니다:

1. 저장소의 [커밋 페이지](https://github.com/mozilla/rust/commits/master)으로 직접 이동하기

1. 파일을 클릭하고 **히스토리**를 선택하여 [특정 파일에 커밋 히스토리](https://github.com/mozilla/rust/commits/master/README.md)를 얻습니다.

때로는 두개 커밋 화면은 <em>다른</em> 정보를 보여주고 있음을 알릴 수 있습니다. 단일 파일에서 히스토리는 저장소에 커밋 히스토리에서 찾은 커밋을 생략할 수 있습니다.

본질적으로 Git은 저장소의 히스토리를 보는 여러가지 방법이 있습니다. Git이 단일 파일의 히스토리를 보여줄 때, 파일을 변경하지 않은 커밋을 생략하여 히스토리를 간소화합니다. 파일을 건드릴지 결정하기 위해 모든 커밋을 보는 것이 아니라, Git은 최종 파일의 컨텐츠를 합칠 때 영향을 주지 않았다면 모든 브랜치를 생략합니다. 파일을 건드리는 브랜치에 커밋은 보여주지 않습니다.

파일의 커밋 히스토리에 GitHub은 명시적으로 두가지 간단한 전략을 따릅니다:

1. 최종 결과에 실제로 기여하지 않는 커밋을 제거하여 간단하게 히스토리를 만듭니다.(예를 들자면, 사이드 브랜치를 변경한 후 되돌리거나 지저분한 일부 변경 버전을 포함한다면 cherry-pick과 clean up을 합니다.)

1. 훨씬 더 효율적으로 계산하기 위해, 파일에 영향이 없는 히스토리의 모든 사이드 브랜치를 보는 것을 피할 수 있습니다.

물론 잘린 화면은 항상 다음 정보가 포함된 것은 아닙니다. 때로는 실패한 실험이나 지저분한 히스토리 또는 심지어 미심쩍은 병합에 잘못된 것을 찾아 알기를 원합니다. 위에 언급한바와 같이 Git은 히스토리를 보는 많은 방법을 가지고 있고 GitHub은 저장소의 커밋 페이지에 더 많은 정보를 화면에 제공합니다.

어떻게 Git이 커밋 히스토리를 생각하는지에 대한 많은 정보를 얻으려면 `git log` 도움 기사에 [히스토리 간소화](http://git-scm.com/docs/git-log#_history_simplification) 부분을 읽을 수 있습니다.

---


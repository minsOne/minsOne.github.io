---
layout: post
title: "[Xcode]dSYM 파일은 어디 있나요?"
description: ""
category: "Mac/iOS"
tags: [xcode, dsym, archives, xcarchive]
---
{% include JB/setup %}

Crashlytics에서 crash report를 보는데 Missing dSYM 창이 떴습니다.

dSYM 파일이 뭐길래 그러지 찾아보니까 dSYM 파일은 앱의 디버그 심볼을 저장하고 있다고 합니다. \[[링크][crashlytics]\]

Xcode의 메뉴에서 `Window - Organizer` 에서 아카이빙 된 파일들을 찾아 `Show in Finder`로 xcarchive파일을 확인할 수 있습니다.(제 컴퓨터에서는 열리지 않았습니다.)

또는 `Xcode - Preferences - Locations - Archives`에서 경로를 확인할 수 있습니다.

해당 경로에서 해당 날짜에 해당하는 xcarchive 파일을 확인하고, 패키지 내용보기를 통해 dSYM 파일을 얻을 수 있었습니다.

### 정리

dSYMs 파일은 `Window - Organizer` 에서 확인하거나 `Xcode - Preferences - Locations - Archives`에서 xcarchive 파일을 찾아 얻을 수 있습니다.

[crashlytics]: http://support.crashlytics.com/knowledgebase/articles/92512-what-s-a-dsym-file-and-why-do-you-need-it
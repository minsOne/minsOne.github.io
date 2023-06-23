---
layout: post
title: "[Swift 5.9+][Macros] Macros 개발시 디버깅 방법"
tags: [Swift, Macros]
---
{% include JB/setup %}

Swift Macros 개발시 디버깅은 테스트시에만 가능합니다.

먼저 Macros 코드 내에 BreakPoint를 설정합니다.

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2023/06/01.png" style="width: 600px; border: 1px solid #555;"/></p><br/>

다음으로, 테스트로 이동하여 테스트를 실행합니다.

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2023/06/02.png" style="width: 600px; border: 1px solid #555;"/></p><br/>

그러면 BreakPoint를 설정한 곳으로 이동하고, argument 정보를 출력해서 직접 확인해볼 수 있습니다.

<p style="text-align:left;"><img src="{{ site.prod_url }}/image/2023/06/03.png" style="width: 600px; border: 1px solid #555;"/></p><br/>
---
layout: post
title: "[Shell]/dev/null로 출력 버리기"
description: ""
category: "Shell"
tags: [shell, dev, null]
---
{% include JB/setup %}

`/dev/null` 파일은 항상 비어있으며, `/dev/null`에 전송된 데이터는 버려집니다. 따라서 특정 명령어를 실행 후, 출력이 필요없는 경우는 `/dev/null`에 출력을 지정하는 것이 좋습니다.

```
$ echo HelloWorld
HelloWorld

$ echo HelloWorld > /dev/null
# 출력되지 않음
```

하지만 실행 중, 에러가 발생하면 출력이 됩니다.

```
$ script.sh > /dev/null
sh: script.sh: command not found
```

출력 방향 지정시 다음 파일 설명자의 숫자에 따라 출력이 결정됩니다.

|    파일 설명자    |    설명   |
|:--------------:|:-------- |
| 0 | 표준 입력 |
| 1 | 표준 출력 |
| 2 | 표준 오류(진단) 출력 |

위의 파일 설명자를 이용해 표준 출력, 표준 오류 출력만을 또는 표준 출력과 표준 오류 출력 둘다 무시할 수 있도록 할 수 있습니다.

```
# 표준 출력만 무시하는 경우
$ echo HelloWorld 1> /dev/null

# 표준 오류 출력만 무시하는 경우
$ script.sh 2> /dev/null

# 표준 출력과 표준 오류 출력 둘다 무시하는 경우
$ echo HellWorld > /dev/null 2>&1
$ script.sh > /dev/null 2>&1
```

또한, 표준 출력과 표준 오류 출력방향을 각각 지정하여 다른 파일로 저장할 수 있습니다.

```
$ echo HellWorld 1> ok.txt
$ script.sh 2> fail.txt
$ echo HellWorld 1> ok.txt 2> fail.txt
$ echo HellWorld 1> /dev/null 2> fail.txt
```

## 참고
* [IBM - 표준 입력, 표준 출력 및 표준 오류 파일](https://www.ibm.com/support/knowledgecenter/ko/ssw_aix_71/com.ibm.aix.osdevice/standardinout.htm)
* [IBM - /dev/null 파일로 출력 버리기](https://www.ibm.com/support/knowledgecenter/ko/ssw_aix_71/com.ibm.aix.osdevice/discard_output_devnull.htm)
* [ZETAWIKI - /dev/null](https://zetawiki.com/wiki//dev/null)
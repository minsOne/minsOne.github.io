---
layout: post
title: "[Shell]터미널에서 Sublime Text, Sublime Merge 실행하기"
description: ""
category: "Shell"
tags: [shell, terminal, softlink, profile]
---
{% include JB/setup %}

처음에 sublime text를 설치한 후에 터미널에서 폴더 또는 파일을 열려고 할 때 여러가지 방법 중 profile과 symbolic link를 이용하여 실행하는 방법을 공유하고자 합니다.

## Sublime Text

### Symbolic Link

Sublime Text는 기본적으로 `/Applications/Sublime\ Text\ 2.app/Contents/SharedSupport/bin/subl`으로 터미널에서 실행할 수 있습니다. 그러면 symbolic link를 이용하여 subl명령어를 만들 수 있습니다.

```shell
ln -s /Applications/Sublime\ Text\ 2.app/Contents/SharedSupport/bin/subl /usr/local/bin/subl
```

/usr/local/bin 폴더에서 subl 파일이 Sublime Text 프로그램을 가르키고 있음을 확인할 수 있습니다.

```shell
lrwxr-xr-x   1 minsOne  admin   64  7 19 02:23 subl -> /Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl
```

subl 명령어로 Sublime Text를 실행할 수 있습니다.

```shell
$ subl .
# or
$ subl [FilePath]
```

### Profile

현재 사용하고 있는 쉘의 profile을 엽니다.

`vi ~/.bash_profile`

export PATH에 sublime text 경로를 추가합니다.

	export PATH=/Applications/Sublime\ Text\ 2.app/Contents/SharedSupport/bin:$PATH

subl 명령어로 sublime text를 실행할 수 있습니다.

---

## Sublime Merge

Sublime Merge는 `/Applications/Sublime Merge.app/Contents/SharedSupport/bin/smerge` 으로 실행할 수 있습니다.

Sublime Text와 같이 symbolic link를 이용하여 명령어를 만들 수 있습니다.

```shell
$ ln -sv "/Applications/Sublime Merge.app/Contents/SharedSupport/bin/smerge" /usr/local/bin/sm
```

/usr/local/bin 폴더에서 sm 파일이 Sublime Merge 프로그램을 가르키고 있음을 확인할 수 있습니다.

```shell
lrwxr-xr-x   1 minsOne  admin   64  7 19 02:23 sm -> /Applications/Sublime Merge.app/Contents/SharedSupport/bin/smerge
```

```shell
$ sm .
# or
$ sm [GitProjectDirectory]
```

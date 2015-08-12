---
layout: post
title: "[Go]Go 시작하기(초간단)"
description: ""
category: "Go"
tags: [go, mac]
---
{% include JB/setup %}

Mac 환경에서 brew가 설치되어 있다면 아주 간단하게 Go를 설치할 수 있습니다.

	$ brew install go

이제 hello, world를 출력해보록 hello.go 파일을 작성합니다.

	package main

	import "fmt"

	func main() {
		fmt.Printf("hello, world\n") 
	}

hello, world를 출력합니다.

	$ go run hello.go
	hello, world

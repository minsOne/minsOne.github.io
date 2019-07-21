---
layout: post
title: "[Swift5][RIBs] Uber의 RIBs 프로젝트에서 얻은 경험 - 1"
description: ""
category: "programming"
tags: [iOS, Swift, Uber, RIBs, Protocol, DIP, POP, Protocol Oriented Programming]
---
{% include JB/setup %}




<!--
	# Interactor

protocol LoggedOutListener: class
protocol LoggedOutPresentable: Presentable
protocol LoggedOutRouting: ViewableRouting

LoggedOutPresentable는 Interactor가 Presentable에 어떤 명령을 내릴지 정의하는 프로토콜
LoggedOutListener는 Interactor가 상위 Interactor에게 어떤 명령어를 내릴지 정의하는 프로토콜

# ViewController
protocol LoggedOutPresentableListener: class
Presentable에서 발생한 액션을 정의하는 프로토콜

#Builder
protocol LoggedOutDependency: Dependency
protocol LoggedOutBuildable: Buildable
	
-->
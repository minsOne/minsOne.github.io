---
layout: post
title: "[Node.js]강제로 특정 페이지 리다이렉션하기"
description: ""
category: "Node.js"
tags: [nodejs, redirect, location, 302, header]
---
{% include JB/setup %}

특정 페이지로 강제로 보내고자 할 때 응답 헤더의 Location 속성을 사용합니다.

	var http = require('http');

	http.createServer(function (req, res) {
		res.statusCode = 302;
		res.setHeader('Location', 'https://google.com');
		res.end();
	}).listen(51112, "127.0.0.1");

	console.log('Server running at http://127.0.0.1:1337/');

<br/><br/>
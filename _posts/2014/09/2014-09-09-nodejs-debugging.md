---
layout: post
title: "node.js debugging"
description: ""
category: "tool"
tags: [node, debug]
---
{% include JB/setup %}

### node-inspector

1.Chrome이 깔려 있는지 확인한다.(firefox, safari에서는 테스트 하지는 못하였다.아마도 웹킷을 지원하는 브라우저이면 가능하지 않을까 싶다.)

<br/>2.nodeJS가 0.3.0버전 이후인지 확인한다.

	$ node -v

<br/>3.node-inspector를 설치한다.

	$ npm isntall -g node-inspector

<br/>4.debugging할 js를 실행한다.

	$ node --debug server.js

만약 첫번째 줄에서 pause하고 싶다면 다음 명령어를 실행한다.

	$ node --debug-brk server.js

<br/>5.node-inspector를 실행하면 default port 8080으로 접속이 가능하다.(http://127.0.0.1:8080)

	$ node-inspector &

원하는 포트로 접속을 원하면 다음과 같이 실행하면 된다.

	$ node-inspector --web-port=30000

### nodemon

auto deploy해주는 모듈이다. 즉, 소스 수정 시 바로 적용되는 모듈이다.

1.설치 

	$ npm install nodemon -g

<br/>2.실행

	$ nodemon app.js

<br/><br/>ps. 2년전에 작성되었던 내용이기 때문에 기록으로 남김.
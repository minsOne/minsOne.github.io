프로젝트에 git flow를 도입하며..

얼마 전까지 iOS 프로젝트 하나를 맡아 작업하고 있었습니다. 유지 보수 및 프로젝트 구조의 리펙토링 등을 진행하였고, 배포 전략이라고 해도 master, develop를 만들어서 작업하였습니다. 어떻게 테스트하고, 배포하고 이런 부분들에 대해 신경을 조금만 썼습니다. 혼자 프로젝트를 맡아서 진행했으니까요. 

상황이 바뀌어서 한명이 프로젝트 하나 또는 두 개를 맡던 형태에서 다수가 여러 프로젝트를 관리하는 형태로 바뀌는 바람에 이렇게 할 수 없게 되버렸습니다. 그래서 첫 번째 작업으로 빌드 & 테스트 배포 & 앱스토어 업로드까지 하는 스크립트를 만들어 여러 프로젝트를 다루더라도 손쉽게 배포할 수 있도록 하였습니다.

이제 두 번째 작업으로 배포 전략을 세워야 할 때가 다가왔습니다. 형상 관리로 git을 사용하고 있었지만 브랜치 정책이 없어서 모든 커밋이 마스터 브랜치에 있었습니다. 특정 기능을 언제 개발했는지 찾기 위해서는 상당히 어려웠고, 릴리즈 될 때, 휴먼 에러가 발생하는 것을 최소한으로 막고자 git flow 정책을 취하였습니다.





http://danielkummer.github.io/git-flow-cheatsheet/index.ko_KR.html
http://dogfeet.github.io/articles/2011/a-successful-git-branching-model.html
http://lucamezzalira.com/2014/03/10/git-flow-vs-github-flow/
https://dogfeet.github.io/articles/2011/github-flow.html
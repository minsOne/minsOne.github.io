---
layout: post
title: "[iOS] Enterprise 규모 앱 환경 구성 - 1"
description: ""
category: "iOS/Mac"
tags: [iOS, XCode, Project]
---
{% include JB/setup %}

이전에 개발했을 때는 프로젝트가 크질 않아, 개발자 수도 적고, 프로젝트에 많은 라이브러리들이 포함되어 있었습니다. 또한, 윗 개발자분들한테 그렇게 배우기도 했었고요. 

현재 담당하고 있는 프로젝트는 기존에 혼자서 담당하거나 둘 또는 셋이서 담당하기엔 너무나 큰 프로젝트입니다. 프로젝트 개발을 처음 시작할 때는 이렇게 크다고는 생각 못해서 기존(?)에 하던 방식으로 개발을 하였습니다. 그러나 기존에 하던 방식으로는 컴파일 속도도 느리고, 한 곳을 고쳤을 때 사이드 이펙트가 어느정도로 날지 점점 감당하기 어려울 정도로 커지고 있습니다.

그렇다면 결국은 모듈화를 통해 결합도를 낮추고 응집도를 높일 수 밖에 없다는 결론으로 도달하게 되었습니다. 물론 개인적인 의견입니다. 

iOS에서 큰 서비스를 하는 곳이 많지 않고, 그런 곳들이 자료를 공개하질 않아 다른 분야도 있지만 Apple의 Cocoa Layer를 살펴보았습니다. [출처](https://warosu.org/g/thread/S51910725#p51915219)

<img src="/../../../../image/2018/12/cocoa_layered_architecture.jpg" alt="cocoa layered architecture" style="width: 900px;"/>

Kernel - Core OS - Core Service - Media - App Kit 으로 구성되어 있습니다.

위의 구조를 일부 차용하여 다음과 같이 구성하면 어떨까 싶습니다.<br/>

<p style="text-align:center;"><img src="/../../../../image/2018/12/enterprise_application_layer.png" alt="application layered architecture" style="width: 300px"/></p><br/>

* Module : 라이브러리를 가진 프로젝트로, 특정 역할(네트워크, 이미지 다운로드, 커스텀 UI 등)을 수행하며, 외부에는 정의된 인터페이스를 통해서만 호출 가능하도록 한다. 라이브러리 교체가 필요한 경우, 다른 라이브러리로 교체가 가능해야한다.

* Module Package : 여러 모듈들을 관리 및 모듈간의 결합으로 기능 확장을 하는 프로젝트

* Service : 특정 도메인, 상품 및 서비스를 관리하는 프로젝트

* Common Service : 인증, 보안 등 다른 서비스에서 공통으로 사용되는 서비스

* Main Service : 각 서비스들을 호출 및 연결을 수행

* Application : UIApplication(AppDelegate)에서 제공하는 기능을 받아서 처리

이렇게 Layer를 나눴을 때 다음과 같은 이점을 얻을 수 있습니다.

* 메인 프로젝트에서의 라이브러리 의존성이 없어짐
* 불필요한 프로토콜 적용이 없어짐 - 프로젝트 내에만 영향을 미침
* 위젯, 와치 등을 개발할 때 모듈을 가져다 사용하면 됨.
* Clean Build를 하는 경우는 느릴 순 있지만, Rebuild 하는 경우는 해당 수정 부분만 컴파일 되므로 훨씬 빨라짐.


하지만 Xcode는 모듈화를 손쉽게 해주는 기능이 없기 때문에, 한땀한땀 작업을 하거나 혹은 다른 도구에 도움을 받아야 합니다. 최근 프로젝트 설정 관련해서 가장 괜찮은 툴은 [XcodeGen](https://github.com/yonaskolb/XcodeGen)라고 알고 있습니다. 신규 프로젝트를 한다면 해당 도구의 도움을 받으면 좋을 것으로 생각되며, 기존 프로젝트에 적용하기에는 까다로울 수 있습니다. 그러므로 기존 프로젝트는 한땀한땀 소스를 옮기고 모듈화 하는 것이 좋지 않을까 생각됩니다.

다음 글에서는 기존 프로젝트에 소스 파일들을 모듈화 하는 것을 설명해볼까 합니다.
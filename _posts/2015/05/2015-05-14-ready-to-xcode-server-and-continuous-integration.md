---
layout: post
title: "Xcode 서버와 CI만들기(0)"
description: ""
category: "iOS/Mac"
tags: [ci, xcode, server, ios, mac, system, apple]
---
{% include JB/setup %}

사람이 반복적인 작업을 하지 않으려면 자동화를 하면 됩니다. 일일히 빌드하는 것도 귀찮고, 잘못된 코드를 올려서 빌드가 깨질수도 있는데, 판단할 수 있는 방법이 없고, 자동으로 배포하고 싶고,, 등등의 필요성을 느끼곤 합니다.

대개 서버에서는 이런 부분들이 잘 갖춰져 있지만, 클라이언트는 플랫폼에 종속되고, 시장 흐름에 따라 많이 흔들리기 때문에 이런 노하우가 쌓이기 힘듭니다. 하지만 귀찮은 짓을 한번만 잘 해놓으면 그 남는 잉여 시간을 게임을 하거나 공부를 하거나, 월급 루팡이 되거나 등등에 사용할 수 있습니다.

iOS 개발자로 전향을 하여 일을 하고 있기 때문에 귀찮아서 시작하고자 합니다.

시스템을 구축하는 진도에 따라 글을 작성할 예정입니다. 정확하게 언제 완결을 할지는 모르며, 가급적 완결이 난 후에 보시길 바랍니다.

참고할 자료는 다음과 같습니다.

* [Apple Document](https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/xcode_guide-continuous_integration/)
* [Continuous Integration With Xcode Server](http://useyourloaf.com/blog/2014/11/02/continuous-integration-with-xcode-server.html)
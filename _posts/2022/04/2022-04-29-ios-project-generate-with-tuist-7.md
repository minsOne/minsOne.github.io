---
layout: post
title: "[iOS][Xcode 13.2.1][Tuist 3.3] 프로젝트 생성/관리 도구 Tuist(7) - Preview를 사용할 수 없다면 DemoApp과 Inject의 Hot Reload를 이용해서 빠른 개발하기"
tags: [iOS, Hot Reload, Preview, App, Inject, Tuist]
published: false
---
{% include JB/setup %}

<!-- Tuist로 쉽게 프로젝트를 생성 및 의존성을 추가할 수 있습니다. 이 말은 역할에 맞는 라이브러리, 프레임워크로 세분화해서 만들 수 있다는 의미입니다.  -->

iOS 13부터 Preview 기능이 들어가면서, 이 기능을 어떻게 잘 써볼 수 있을지 많은 시도들이 있었습니다. 하지만 대규모 프로젝트로 진행될수록 Preview 활용도가 많이 떨어집니다. 

그 이유는 정확한 이유를 알 수 없는 에러, Preview를 위한 빌드, 빌드시간이 오래 걸리면 Preview 실패, Static Library에서는 사용 불가, Static Library를 사용할 때 간헐적인 실패 등이 발생합니다. 

UI 기능을 담당하는 모듈만 의존하는 DemoApp을 통해서 빠른 빌드 및 실행으로 작성한 UI를 확인할 수 있습니다. 

아래와 같이 의존 관계가 형성됩니다.

<div class="mermaid" style="display:flex;justify-content:center;"> 
graph TD;
    App-->Feature
    Feature-->예금
    Feature-->적금
    subgraph 예금상품
    예금-->예금UI
    예금DemoApp-->예금
    예금UIDemoApp-->예금UI
    end
    subgraph 적금상품
    적금-->적금UI
    적금DemoApp-->적금
    적금UIDemoApp-->적금UI
    end
    예금UI-->Resource
    적금UI-->Resource
</div>

UI는 사실 시행착오를 겪으면서 작업해야하는 기능입니다. 따라서 UIDemoApp을 만들고, 작업하는 편이 추후 유지보수를 생각했을 때 좋습니다. 

하지만, UI는 모듈로 해당 소스를 수정하고 다시 DemoApp을 빌드, 실행하여 수정한 코드가 잘 반영되었는지 확인하는데 있어서 컨텍스트 스위칭 비용이 생깁니다. 

여기에서 Preview 기능까지는 아니지만, DemoApp에서 Hot Reload를 할 수 있도록 해주는 툴인 InjectionIII - [MacApp](https://apps.apple.com/us/app/injectioniii/id1380446739?mt=12), [Github](https://github.com/johnno1962/InjectionIII)과 [Inject 라이브러리](https://github.com/krzysztofzablocki/Inject)를 이용하여 개발할 수 있습니다.


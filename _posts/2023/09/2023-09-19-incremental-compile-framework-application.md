---
layout: post
title: "[Xcode] 증분빌드 - Framework와 Application"
tags: []
published: false
---
{% include JB/setup %}

#### 실험 환경

* Xcode 15.1 Beta (15C5028h)

## 증분빌드

우리는 Xcode로 프로젝트를 생성하고 수많은 파일을 생성합니다. 또한, 특정 코드들이 같은 성격을 지니면 별도의 모듈로 분리하여 작업할 수 있습니다.

모듈로 분리할 때, 해당 모듈의 성격에 따라 라이브러리의 Mach-O를 Dynamic, Static으로 구분하여 정할 수 있습니다.

또한, 번들을 가져야하는 경우, 프레임워크로 만들어 작업할 수 있습니다.


## 증분 빌드 - Incremental Build

같은 성격을 지닌 코드들은 모듈로 분리하여 응집도 높이는 방식으로 진행합니다. 모듈은 성격에 따라 Mach-O를 Static, Dynamic으로 정하고, 번들을 가질 필요가 없다면, 라이브러리로 만들고, 가질 필요가 있으면 프레임워크로 만듭니다.

모듈은 빌드를 한 뒤에 재빌드할 일은 많지 않습니다. 특히나 Mach-O가 Dynamic인 프레임워크는 더욱 재빌드할 일이 없습니다. 다른 프레임워크나 라이브러리가 변경이 일어나도 인터페이스가 바뀌지 않는 이상 해당 프레임워크를 재빌드 하지 않습니다.

따라서 모듈화에 있어서 증분 빌드는 반드시 필요한 기능입니다.

---

다음과 같은 의존 관계가 형성되어 있다고 가정해봅시다.

<div class="mermaid" style="display:flex;justify-content:center;"> 
flowchart LR
    id1[Application]-->id2[AFramework]
    id2-->id3[BFramework]
    id3-->id4[CFramework]
    style id1 fill:#03bfff
    style id2 fill:#ffba0c
    style id3 fill:#ffba0c
    style id4 fill:#ffba0c
</div>

Application을 빌드하면 A, B, C 프레임워크가 빌드됩니다.

그리고 A 프레임워크의 소스를 수정한 뒤 빌드를 수행하면, B, C 프레임워크는 이미 빌드되었기 때문에, A 프레임워크만 빌드 수행합니다.

이제 모듈의 코드를 검증하기 위한 테스트 타겟을 추가한다면, 다음과 같은 의존 관계가 형성됩니다.

<div class="mermaid" style="display:flex;justify-content:center;"> 
flowchart LR
    id1[Application]-->id2[AFramework]
    id2-->id3[BFramework]
    id3-->id4[CFramework]
    id1-->id5[App_UnitTest]
    style id1 fill:#03bfff
    style id2 fill:#ffba0c
    style id3 fill:#ffba0c
    style id4 fill:#ffba0c
    style id5 fill:#ff5116
</div>



## 증분 빌드

우리는 특정 작업을 하는 코드를 응집도 높이는 방식으로 모듈을 만들어 진행할 수 있습니다. 쉽게 사용할 수 있는 방식이 프레임워크로 작업하는 것입니다.

프레임워크는 빌드한 후에 재빌드할 일은 많지 않습니다. 다른 프레임워크의 변경이 일어나더라도, 인터페이스가 바뀌지 않는 이상 해당 프레임워크를 재빌드 하지 않아도 됩니다. 

프레임워크는 보편적으로 Mach-O가 Dynamic으로 되어 있기 때문입니다.

그러나 프레임워크 스킴 빌드한 후, 애플리케이션 스킴으로 빌드한다면, 기존에 빌드했던 프레임워크 대신 재빌드를 합니다.

마찬가지로, 애플리케이션 스킴으로 빌드한 후, 프레임워크 스킴으로 빌드하면, 프레임워크가 재빌드가 일어납니다.

만약 해당 프레임워크에 포함된 파일이 많다면, 프레임워크를 빌드하는데 시간이 많이 걸린다는 의미이며, 그러면 우리의 개발 생산성은 줄어들고, 집중력이 흐트러집니다.

그러면 증분빌드가 일어나는지를 파악한다면, 재빌드가 발생할 때는 증분빌드가 수행되지 않을 것이고, 그것을 알려줄 수 있는 옵션이 있을 것입니다.

```
OTHER_SWIFT_FLAGS = -driver-show-incremental -driver-show-job-lifecycle
```

<!--
ENABLE_CODE_COVERAGE = NO
-driver-time-compilation
-->

## 참고자료

* [Apple - Swift Compiler Performance](https://github.com/apple/swift/blob/main/docs/CompilerPerformance.md)
* [Reducing Our Build Time By 50%](https://medium.com/gojekengineering/reducing-our-build-time-by-50-835b54c99588)
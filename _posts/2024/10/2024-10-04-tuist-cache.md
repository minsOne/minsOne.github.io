---
layout: post
title: "[Tuist] Cache"
tags: [Tuist]
published: false
---
{% include JB/setup %}

[Tuist](https://tuist.io/)는 Xcode 프로젝트를 생성하고 관리하는데 있어 아주 강력한 도구입니다. 특히, 특정 서비스를 개발하기 위해 일부 프로젝트들로만 구성하여 개발을 진행할 수 있습니다. 그래서 Tuist를 사용하는 팀은 모든 프로젝트를 인덱싱 및 빌드할 필요가 없기 때문에 상대적으로 빠른 개발이 가능합니다.

그러나, 우리가 개발하는 코드는 기존에 작성된 많은 코드 위에서 작성하곤 합니다. 사실 우리는 그 코드들에 비하면 아주 적은 양의 코드를 다루지만, 빌드시 코어 레이어에 있는 코드를 빌드한 뒤, 우리가 작성한 서비스 로직을 담은 코드를 빌드해야하므로, 빌드 시간이 오래 걸릴 수 밖에 없습니다. 

코어 레이어에 있는 코드는 사실 변하는 일이 많지 않습니다. 변할 일이 적은 코드를 매번 빌드한다는 것은 자원 낭비하는 것과 다르지 않습니다. 따라서 이런 코드는 적절히 정리하여 변경 사항이 있는 경우에만 빌드하고, 그 외에는 기존에 빌드된 결과물을 활용하는 것이 좋습니다.

## Tuist Cache

Tuist는 [Cache](https://docs.tuist.io/guides/develop/build/cache) 기능을 제공합니다. 캐싱 기능을 제공하기 위해서는 [Hash](https://docs.tuist.io/guides/develop/projects/hashing) 기능을 반드시 활용해야 합니다. 특정 모듈의 코드, 설정 등의 정보가 변경되었는지 확인하기 위해서는 Hash 기능이 존재해야, Hash 값을 기반으로 캐시된 빌드 결과물을 가져올 수 있기 때문입니다.

Tuist는 캐시 가능한 프레임워크의 해시 값을 출력해주는 기능이 있습니다. 

예제로 사용할 Tuist Project는 Tuist 저장소에 있는 [fixtures/ios_app_with_frameworks](https://github.com/tuist/tuist/tree/main/fixtures/ios_app_with_frameworks)를 사용합니다.

```shell
$ tuist cache --print-hashes
Loading and constructing the graph
It might take a while if the cache is empty
Framework1 - 1f6aa49b303be50f38845a996e98b3b2
Framework2-iOS - a4adee7f2d7ea8b34f4a0c040442a950
Framework2-macOS - 2ce66ca30f0097a0876f88f879537528
Framework3 - f3f2870d9d5bab1fb694d3db2969e292
Framework4 - f774c014e8f2728f7e8b111a5df2562a
Framework5 - 64b63969260c1920f86f67a8da600f67
Total time taken: 0.140s
```

다음으로, 캐시를 만들어봅시다. 

```shell
$ tuist cache
Loading and constructing the graph
It might take a while if the cache is empty
Hashing cacheable targets
Targets to be cached: Framework1, Framework2-iOS, Framework2-macOS, Framework3, Framework4, Framework5
Loading and constructing the graph
It might take a while if the cache is empty
Using cache binaries for the following targets:
...
Build Succeeded
Creating XCFrameworks
Creating XCFramework for Framework5
Creating XCFramework for Framework2-iOS
Creating XCFramework for Framework1
Creating XCFramework for Framework2-macOS
Creating XCFramework for Framework4
Creating XCFramework for Framework3
Storing binaries to speed up workflows
6 target(s) stored: Framework1, Framework2-iOS, Framework2-macOS, Framework3, Framework4, Framework5
All cacheable targets have been cached successfully as xcframeworks
```

만들어진 캐시 - XCFramework는 홈 디렉토리의 `.cache` 폴더에 보관되어 있습니다.

```shell
$ ls ~/.cache/tuist-cloud/BinaryCache
1f6aa49b303be50f38845a996e98b3b2 64b63969260c1920f86f67a8da600f67 f3f2870d9d5bab1fb694d3db2969e292
2ce66ca30f0097a0876f88f879537528 a4adee7f2d7ea8b34f4a0c040442a950 f774c014e8f2728f7e8b111a5df2562a
```

BinaryCache 폴더 내에 있는 폴더명은 앞에서 `tuist cache --print-hashes` 명령을 통해 얻은 해시값과 동일한 값을 가집니다. 폴더 이름이 해시인 폴더안에는 XCFramework가 있습니다.

```shell
$ ls ~/.cache/tuist/Binaries/1f6aa49b303be50f38845a996e98b3b2
Framework1.xcframework
$ ls ~/.cache/tuist/Binaries/2ce66ca30f0097a0876f88f879537528
Framework2-macOS.xcframework
$ ls ~/.cache/tuist/Binaries/64b63969260c1920f86f67a8da600f67
Framework5.xcframework
$ ls ~/.cache/tuist/Binaries/a4adee7f2d7ea8b34f4a0c040442a950
Framework2-iOS.xcframework
$ ls ~/.cache/tuist/Binaries/f3f2870d9d5bab1fb694d3db2969e292
Framework3.xcframework
$ ls ~/.cache/tuist/Binaries/f774c014e8f2728f7e8b111a5df2562a
Framework4.xcframework
```

만들어진 캐시를 이용하여 프로젝트를 생성해봅시다. [사용법](https://docs.tuist.io/guides/develop/build/cache#usage)

```shell
$ tuist generate App
```

<p style="text-align:center;">
<img src="{{ site.development_url }}/image/2024/10/01.png" style="width: 600px"/>
</p><br/>

App에서 의존하는 프레임워크인 Framework1, Framework2-iOS, Framework3, Framework4, Framework5를 캐시에 있는 XCFramework를 사용하는 것을 확인할 수 있습니다.

## 원격 저장소에 캐시 저장하기

WIP

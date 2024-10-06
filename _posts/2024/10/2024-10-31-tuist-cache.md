---
layout: post
title: "[Tuist 4.x+] Cache"
tags: [Tuist, MinIO, Cache]
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
<img src="{{ site.dev_url }}/image/2024/10/01.png" style="width: 600px"/>
</p><br/>

App에서 의존하는 프레임워크인 Framework1, Framework2-iOS, Framework3, Framework4, Framework5를 캐시에 있는 XCFramework를 사용하는 것을 확인할 수 있습니다.

## 원격 저장소에 캐시 저장하기

앞서 tuist cache 명령어로 만든 XCFramework는 로컬 캐시의 역할로 훌륭하지만, 다른 팀원과의 공유, 또는 CI/CD의 빠른 작업을 위해서는 원격 저장소에 캐시를 저장하는 것이 좋습니다.

우리는 캐시의 해시값을 확인하기 위해서 `tuist cache --print-hashes` 명령을 사용했습니다. 이 명령을 통해 얻은 해시값으로 원격 저장소에 저장하면 됩니다. 또한, 코드나 리소스 등의 변경으로 캐시는 일정 시간의 유효기간을 가집니다. 따라서 원격 저장소에서 일정 기간동안 캐시를 저장하고 더이상 사용하지 않으면 알아서 삭제되도록 하는 기능을 제공해줘야 합니다.

AWS의 S3나 다른 저장소를 사용할 수 있지만, 내부에서만 사용하는 저장소의 역할을 한다면 [MinIO](https://min.io/)도 사용하기 괜찮습니다.

MacOS에서 MinIO 설치하는 Homebrew로 쉽게 설치할 수 있습니다.

```shell
$ brew install minio/stable/minio
$ mkdir data
$ minio server ./data
INFO: Formatting 1st pool, 1 set(s), 1 drives per set.
INFO: WARNING: Host local has more than 0 drives of set. A host failure will result in data becoming unavailable.
MinIO Object Storage Server
Copyright: 2015-2024 MinIO, Inc.
License: GNU AGPLv3 - https://www.gnu.org/licenses/agpl-3.0.html
Version: RELEASE.2024-10-02T17-50-41Z (go1.22.8 darwin/arm64)

API: http://192.168.1.44:9000  http://127.0.0.1:9000
   RootUser: minioadmin
   RootPass: minioadmin

WebUI: http://192.168.1.44:52939 http://127.0.0.1:52939
   RootUser: minioadmin
   RootPass: minioadmin

CLI: https://min.io/docs/minio/linux/reference/minio-mc.html#quickstart
   $ mc alias set 'myminio' 'http://192.168.1.44:9000' 'minioadmin' 'minioadmin'

Docs: https://docs.min.io
WARN: Detected default credentials 'minioadmin:minioadmin', we recommend that you change these values with 'MINIO_ROOT_USER' and 'MINIO_ROOT_PASSWORD' environment variables

```

<!-- 이미지 -->

다음으로, MinIO를 쉽게 사용하기 위해 MinIO Client를 설치합니다. [Document](https://min.io/docs/minio/linux/reference/minio-mc.html#quickstart)

```shell
$ brew install minio/stable/mc
$ mc alias set 'myminio' 'http://192.168.1.44:9000' 'minioadmin' 'minioadmin'
```

다음으로, 캐시로 만들었던 XCFramework를 zip 파일로 만든 뒤, MinIO에 업로드합니다.

```shell
# upload.sh
# 해시 값 배열
hashes=("08d26b87177ac5b9317c59d8b5dd0db7" \
        "114b35b342bd5f046cbfc17e4271c403" \
        "42a2f5cc7dc61611276e545d8db85d7e" \
        "6028e3d23173f550cf1908baa5799144" \
        "f64b59d5995bd3bf1a85fbfa16a8f3cc")

# 반복문을 통해 각 해시 값에 대해 작업 수행
for hash in "${hashes[@]}"; do
    # 경로 설정
    dir_path="$HOME/.cache/tuist/Binaries/$hash"
    zip_file="$hash.zip"

    # 파일 압축
    (cd "$dir_path" && zip -r "$zip_file" *)

    # MinIO에 파일 업로드
    mc put "$dir_path/$zip_file" "myminio/tuist-cache"

    # 원본 디렉토리 삭제
    rm -rf "$dir_path"
done
```

MinIO에 업로드한 파일을 확인할 수 있습니다.

<p style="text-align:center;">
<img src="{{ site.dev_url }}/image/2024/10/03.png" style="width: 600px"/>
</p><br/>

다음으로 캐시를 복원하기 하기 위해, MinIO에 업로드한 파일을 다운받아서 압축을 풀어줍니다.

```shell
# download.sh
# 해시 값 배열
hashes=("08d26b87177ac5b9317c59d8b5dd0db7" \
        "114b35b342bd5f046cbfc17e4271c403" \
        "42a2f5cc7dc61611276e545d8db85d7e" \
        "6028e3d23173f550cf1908baa5799144" \
        "f64b59d5995bd3bf1a85fbfa16a8f3cc")

# 반복문을 통해 각 해시 값에 대해 작업 수행
for hash in "${hashes[@]}"; do
    # 경로 설정
    dir_path="$HOME/.cache/tuist/Binaries/$hash"
    zip_file="$hash.zip"
    
    # 파일 다운로드
    mc get "myminio/tuist-cache/$zip_file" "$dir_path/$zip_file"
    
    # 파일 압축 해제 및 zip 파일 삭제
    (cd "$dir_path" && unzip "$zip_file" && rm "$zip_file")
done
```

캐시를 복원했으니, `tuist generate` 명령어를 실행하면 캐시를 의존한 프로젝트를 만들어진다고 예상할 수 있습니다.

```shell
$ tuist generate App
...

The following warnings need attention:
 · Tuist Cache requires using the Tuist-provided server for fine-grained reading and persistence of cache binaries. See how you can use it by following the docs: https://docs.tuist.io/guides/quick-start/gather-insights.html
```

<p style="text-align:center;">
<img src="{{ site.dev_url }}/image/2024/10/04.png" style="width: 600px"/>
</p><br/>

하지만 캐시를 이용하지 않고 프로젝트를 만들었다는 것을 확인할 수 있습니다. 왜 그런걸까요?

tuist cache 명령를 실행했을 때, 상세 로그를 살펴보면 어떤 정보를 추가하는지 확인할 수 있습니다.

```shell
$ tuist cache --verbose

...
xcframework successfully written out to: /var/folders/ws/mcgh3rts36ngd_syj108d_j40000gn/T/TemporaryDirectory.UghI5Q/xcframeworks/Framework5.xcframework
Storing binaries to speed up workflows
/usr/bin/env xattr -w tuist.cloud.metadata PiiDvfJ39BBfOnE7FsSB1QvJGvz+0cJBkLFfdGrPtpF3K92vqzoQr020LGpP/V1I.U2VxdWVuY2UgKDIpOgogIEludGVnZXI6IDU2OTMxNzk5ODA3ODk1NTY0NTI3MzgzMDAxOTI2ODg2MzA4OTg4OTk2ODE4MzM2MDMxMDAxOTkwMjYzMTg2MjQxMjI5MjgxMjA4NDIzCiAgSW50ZWdlcjogMTA4NjMyMTkzODIyODkxMjkwNjA3ODY1NDYwMDg3MjcxOTIyODg4MTE4NjA2MTQ3MTAzNDU3OTAwNDMyOTk2OTkzMDAyMTk2NTc0NTIwCg== /Users/minsone/.cache/tuist/Binaries/f64b59d5995bd3bf1a85fbfa16a8f3cc

/usr/bin/env xattr -w tuist.cloud.metadata PiiDvfJ39BBfOnE7FsSB1QvJGvz+0cJBkLFfdGrPtpF3K92vqzoQr020LGpP/V1I.U2VxdWVuY2UgKDIpOgogIEludGVnZXI6IDU2OTMxNzk5ODA3ODk1NTY0NTI3MzgzMDAxOTI2ODg2MzA4OTg4OTk2ODE4MzM2MDMxMDAxOTkwMjYzMTg2MjQxMjI5MjgxMjA4NDIzCiAgSW50ZWdlcjogMTA4NjMyMTkzODIyODkxMjkwNjA3ODY1NDYwMDg3MjcxOTIyODg4MTE4NjA2MTQ3MTAzNDU3OTAwNDMyOTk2OTkzMDAyMTk2NTc0NTIwCg== /Users/minsone/.cache/tuist/Binaries/f64b59d5995bd3bf1a85fbfa16a8f3cc/Framework2-iOS.xcframework

/usr/bin/env xattr -w tuist.cloud.metadata PiiDvfJ39BBfOnE7FsSB1QvJGvz+0cJBkLFfdGrPtpF3K92vqzoQr020LGpP/V1I.U2VxdWVuY2UgKDIpOgogIEludGVnZXI6IDU2OTMxNzk5ODA3ODk1NTY0NTI3MzgzMDAxOTI2ODg2MzA4OTg4OTk2ODE4MzM2MDMxMDAxOTkwMjYzMTg2MjQxMjI5MjgxMjA4NDIzCiAgSW50ZWdlcjogMTA4NjMyMTkzODIyODkxMjkwNjA3ODY1NDYwMDg3MjcxOTIyODg4MTE4NjA2MTQ3MTAzNDU3OTAwNDMyOTk2OTkzMDAyMTk2NTc0NTIwCg== /Users/minsone/.cache/tuist/Binaries/42a2f5cc7dc61611276e545d8db85d7e

/usr/bin/env xattr -w tuist.cloud.metadata PiiDvfJ39BBfOnE7FsSB1QvJGvz+0cJBkLFfdGrPtpF3K92vqzoQr020LGpP/V1I.U2VxdWVuY2UgKDIpOgogIEludGVnZXI6IDU2OTMxNzk5ODA3ODk1NTY0NTI3MzgzMDAxOTI2ODg2MzA4OTg4OTk2ODE4MzM2MDMxMDAxOTkwMjYzMTg2MjQxMjI5MjgxMjA4NDIzCiAgSW50ZWdlcjogMTA4NjMyMTkzODIyODkxMjkwNjA3ODY1NDYwMDg3MjcxOTIyODg4MTE4NjA2MTQ3MTAzNDU3OTAwNDMyOTk2OTkzMDAyMTk2NTc0NTIwCg== /Users/minsone/.cache/tuist/Binaries/42a2f5cc7dc61611276e545d8db85d7e/Framework3.xcframework

/usr/bin/env xattr -w tuist.cloud.metadata PiiDvfJ39BBfOnE7FsSB1QvJGvz+0cJBkLFfdGrPtpF3K92vqzoQr020LGpP/V1I.U2VxdWVuY2UgKDIpOgogIEludGVnZXI6IDU2OTMxNzk5ODA3ODk1NTY0NTI3MzgzMDAxOTI2ODg2MzA4OTg4OTk2ODE4MzM2MDMxMDAxOTkwMjYzMTg2MjQxMjI5MjgxMjA4NDIzCiAgSW50ZWdlcjogMTA4NjMyMTkzODIyODkxMjkwNjA3ODY1NDYwMDg3MjcxOTIyODg4MTE4NjA2MTQ3MTAzNDU3OTAwNDMyOTk2OTkzMDAyMTk2NTc0NTIwCg== /Users/minsone/.cache/tuist/Binaries/08d26b87177ac5b9317c59d8b5dd0db7

/usr/bin/env xattr -w tuist.cloud.metadata PiiDvfJ39BBfOnE7FsSB1QvJGvz+0cJBkLFfdGrPtpF3K92vqzoQr020LGpP/V1I.U2VxdWVuY2UgKDIpOgogIEludGVnZXI6IDU2OTMxNzk5ODA3ODk1NTY0NTI3MzgzMDAxOTI2ODg2MzA4OTg4OTk2ODE4MzM2MDMxMDAxOTkwMjYzMTg2MjQxMjI5MjgxMjA4NDIzCiAgSW50ZWdlcjogMTA4NjMyMTkzODIyODkxMjkwNjA3ODY1NDYwMDg3MjcxOTIyODg4MTE4NjA2MTQ3MTAzNDU3OTAwNDMyOTk2OTkzMDAyMTk2NTc0NTIwCg== /Users/minsone/.cache/tuist/Binaries/08d26b87177ac5b9317c59d8b5dd0db7/Framework1.xcframework

/usr/bin/env xattr -w tuist.cloud.metadata PiiDvfJ39BBfOnE7FsSB1QvJGvz+0cJBkLFfdGrPtpF3K92vqzoQr020LGpP/V1I.U2VxdWVuY2UgKDIpOgogIEludGVnZXI6IDU2OTMxNzk5ODA3ODk1NTY0NTI3MzgzMDAxOTI2ODg2MzA4OTg4OTk2ODE4MzM2MDMxMDAxOTkwMjYzMTg2MjQxMjI5MjgxMjA4NDIzCiAgSW50ZWdlcjogMTA4NjMyMTkzODIyODkxMjkwNjA3ODY1NDYwMDg3MjcxOTIyODg4MTE4NjA2MTQ3MTAzNDU3OTAwNDMyOTk2OTkzMDAyMTk2NTc0NTIwCg== /Users/minsone/.cache/tuist/Binaries/114b35b342bd5f046cbfc17e4271c403

/usr/bin/env xattr -w tuist.cloud.metadata PiiDvfJ39BBfOnE7FsSB1QvJGvz+0cJBkLFfdGrPtpF3K92vqzoQr020LGpP/V1I.U2VxdWVuY2UgKDIpOgogIEludGVnZXI6IDU2OTMxNzk5ODA3ODk1NTY0NTI3MzgzMDAxOTI2ODg2MzA4OTg4OTk2ODE4MzM2MDMxMDAxOTkwMjYzMTg2MjQxMjI5MjgxMjA4NDIzCiAgSW50ZWdlcjogMTA4NjMyMTkzODIyODkxMjkwNjA3ODY1NDYwMDg3MjcxOTIyODg4MTE4NjA2MTQ3MTAzNDU3OTAwNDMyOTk2OTkzMDAyMTk2NTc0NTIwCg== /Users/minsone/.cache/tuist/Binaries/114b35b342bd5f046cbfc17e4271c403/Framework5.xcframework

/usr/bin/env xattr -w tuist.cloud.metadata PiiDvfJ39BBfOnE7FsSB1QvJGvz+0cJBkLFfdGrPtpF3K92vqzoQr020LGpP/V1I.U2VxdWVuY2UgKDIpOgogIEludGVnZXI6IDU2OTMxNzk5ODA3ODk1NTY0NTI3MzgzMDAxOTI2ODg2MzA4OTg4OTk2ODE4MzM2MDMxMDAxOTkwMjYzMTg2MjQxMjI5MjgxMjA4NDIzCiAgSW50ZWdlcjogMTA4NjMyMTkzODIyODkxMjkwNjA3ODY1NDYwMDg3MjcxOTIyODg4MTE4NjA2MTQ3MTAzNDU3OTAwNDMyOTk2OTkzMDAyMTk2NTc0NTIwCg== /Users/minsone/.cache/tuist/Binaries/6028e3d23173f550cf1908baa5799144

/usr/bin/env xattr -w tuist.cloud.metadata PiiDvfJ39BBfOnE7FsSB1QvJGvz+0cJBkLFfdGrPtpF3K92vqzoQr020LGpP/V1I.U2VxdWVuY2UgKDIpOgogIEludGVnZXI6IDU2OTMxNzk5ODA3ODk1NTY0NTI3MzgzMDAxOTI2ODg2MzA4OTg4OTk2ODE4MzM2MDMxMDAxOTkwMjYzMTg2MjQxMjI5MjgxMjA4NDIzCiAgSW50ZWdlcjogMTA4NjMyMTkzODIyODkxMjkwNjA3ODY1NDYwMDg3MjcxOTIyODg4MTE4NjA2MTQ3MTAzNDU3OTAwNDMyOTk2OTkzMDAyMTk2NTc0NTIwCg== /Users/minsone/.cache/tuist/Binaries/6028e3d23173f550cf1908baa5799144/Framework4.xcframework

5 target(s) stored: Framework1, Framework2-iOS, Framework3, Framework4, Framework5
All cacheable targets have been cached successfully as xcframeworks
```

상세 로그를 보면 해당 캐시 폴더 및 xcframework 폴더에 메타데이터가 저장되는 것을 확인할 수 있다. 이 메타데이터가 없으면 캐시로 인식하지 않습니다. 이전에 `tuist generate`시 출력됬던 경고에 의하면 Tuist Cloud에서만 사용하게 한다는 것을 알 수 있습니다. 하지만 자체 서버를 사용하는 경우라면, 이를 우회해야합니다.

메타 데이터는 `-p` 옵션을 이용하면 읽을 수 있습니다.

```shell
$ /usr/bin/env xattr -p tuist.cloud.metadata ~/.cache/tuist/Binaries/08d26b87177ac5b9317c59d8b5dd0db7/Framework1.xcframework
PiiDvfJ39BBfOnE7FsSB1QvJGvz+0cJBkLFfdGrPtpF3K92vqzoQr020LGpP/V1I.U2VxdWVuY2UgKDIpOgogIEludGVnZXI6IDU2OTMxNzk5ODA3ODk1NTY0NTI3MzgzMDAxOTI2ODg2MzA4OTg4OTk2ODE4MzM2MDMxMDAxOTkwMjYzMTg2MjQxMjI5MjgxMjA4NDIzCiAgSW50ZWdlcjogMTA4NjMyMTkzODIyODkxMjkwNjA3ODY1NDYwMDg3MjcxOTIyODg4MTE4NjA2MTQ3MTAzNDU3OTAwNDMyOTk2OTkzMDAyMTk2NTc0NTIwCg==
```

캐시를 사용하기 위해 캐시 폴더 및 xcframework 폴더에 메타데이터를 저장해야 합니다.

우리가 캐시를 MinIO에 올리기 위해서는 메타 데이터도 같이 저장해서 올렸다가, 내려받으면 저장된 메타 데이터를 동일하게 기록하는 단계가 필요합니다.

이전에 작성한 upload.sh 에서 메타 데이터를 metadata 파일로 저장하는 코드를 추가합니다.

```shell
# upload.sh
# 해시 값 배열
hashes=("08d26b87177ac5b9317c59d8b5dd0db7" \
        "114b35b342bd5f046cbfc17e4271c403" \
        "42a2f5cc7dc61611276e545d8db85d7e" \
        "6028e3d23173f550cf1908baa5799144" \
        "f64b59d5995bd3bf1a85fbfa16a8f3cc")

# 반복문을 통해 각 해시 값에 대해 작업 수행
for hash in "${hashes[@]}"; do
    # 경로 설정
    dir_path="$HOME/.cache/tuist/Binaries/$hash"
    zip_file="$hash.zip"
    metadata_file="$dir_path/metadata"

    # tuist.cloud.metadata를 파일에 출력
    /usr/bin/env xattr -p tuist.cloud.metadata "$dir_path" > "$metadata_file"

    # 파일 압축
    (cd "$dir_path" && zip -r "$zip_file" *)

    # MinIO에 파일 업로드
    mc put "$dir_path/$zip_file" "myminio/tuist-cache"

    # 원본 디렉토리 삭제
    rm -rf "$dir_path"
done
```

다음으로, download.sh에서는 MinIO에서 내려받은 zip 파일을 풀고, metadata 파일을 읽어 폴더와 xcframework 폴더에 메타데이터를 저장하는 코드를 추가합니다.

```shell
# download.sh
# 해시 값 배열
hashes=("08d26b87177ac5b9317c59d8b5dd0db7" \
        "114b35b342bd5f046cbfc17e4271c403" \
        "42a2f5cc7dc61611276e545d8db85d7e" \
        "6028e3d23173f550cf1908baa5799144" \
        "f64b59d5995bd3bf1a85fbfa16a8f3cc")

# 반복문을 통해 각 해시 값에 대해 작업 수행
for hash in "${hashes[@]}"; do
    # 경로 설정
    dir_path="$HOME/.cache/tuist/Binaries/$hash"
    zip_file="$hash.zip"
    metadata_file="$dir_path/metadata"
    
    # 파일 다운로드
    mc get "myminio/tuist-cache/$zip_file" "$dir_path/$zip_file"
    
    # 파일 압축 해제 및 zip 파일 삭제
    (cd "$dir_path" && unzip "$zip_file" && rm "$zip_file")

    # metadata 파일이 존재하면 tuist.cloud.metadata 속성 설정
    if [ -f "$metadata_file" ]; then
        metadata_content=$(cat "$metadata_file")
        
        # 디렉토리에 metadata 속성 추가
        /usr/bin/env xattr -w tuist.cloud.metadata "$metadata_content" "$dir_path"
        
        # 모든 .xcframework 파일에 metadata 속성 추가
        for xcframework in "$dir_path"/*.xcframework; do
            /usr/bin/env xattr -w tuist.cloud.metadata "$metadata_content" "$xcframework"
        done
        # metadata 파일 삭제
        rm $metadata_file
    fi
done
```

캐시를 복원했으니, `tuist generate` 명령어를 실행하면 캐시를 의존한 프로젝트를 복원할 수 있습니다.

```shell
$ tuist generate App
```

<p style="text-align:center;">
<img src="{{ site.dev_url }}/image/2024/10/02.png" style="width: 600px"/>
</p><br/>

## 정리

* MinIO를 이용해 자체 서버를 구축
* Tuist Cache의 메커니즘을 일부 우회하여 캐시를 사용할 수 있게 구성

## 참고자료

* [MinIO](https://github.com/minio/minio)
* [Tuist Cache](https://docs.tuist.io/en/guides/develop/build/cache)

<br/><br/>

## 전체 스크립트 코드

* upload.sh

```shell
# upload.sh
# 해시 값 배열
hashes=("08d26b87177ac5b9317c59d8b5dd0db7" \
        "114b35b342bd5f046cbfc17e4271c403" \
        "42a2f5cc7dc61611276e545d8db85d7e" \
        "6028e3d23173f550cf1908baa5799144" \
        "f64b59d5995bd3bf1a85fbfa16a8f3cc")

# 반복문을 통해 각 해시 값에 대해 작업 수행
for hash in "${hashes[@]}"; do
    # 경로 설정
    dir_path="$HOME/.cache/tuist/Binaries/$hash"
    zip_file="$hash.zip"
    metadata_file="$dir_path/metadata"

    # tuist.cloud.metadata를 파일에 출력
    /usr/bin/env xattr -p tuist.cloud.metadata "$dir_path" > "$metadata_file"

    # 파일 압축
    (cd "$dir_path" && zip -r "$zip_file" *)

    # MinIO에 파일 업로드
    mc put "$dir_path/$zip_file" "myminio/tuist-cache"

    # 원본 디렉토리 삭제
    rm -rf "$dir_path"
done
```

* download.sh

```shell
# 해시 값 배열
hashes=("08d26b87177ac5b9317c59d8b5dd0db7" \
        "114b35b342bd5f046cbfc17e4271c403" \
        "42a2f5cc7dc61611276e545d8db85d7e" \
        "6028e3d23173f550cf1908baa5799144" \
        "f64b59d5995bd3bf1a85fbfa16a8f3cc")

# 반복문을 통해 각 해시 값에 대해 작업 수행
for hash in "${hashes[@]}"; do
    # 경로 설정
    dir_path="$HOME/.cache/tuist/Binaries/$hash"
    zip_file="$hash.zip"
    metadata_file="$dir_path/metadata"
    
    # 파일 다운로드
    mc get "myminio/tuist-cache/$zip_file" "$dir_path/$zip_file"
    
    # 파일 압축 해제 및 zip 파일 삭제
    (cd "$dir_path" && unzip "$zip_file" && rm "$zip_file")

    # metadata 파일이 존재하면 tuist.cloud.metadata 속성 설정
    if [ -f "$metadata_file" ]; then
        metadata_content=$(cat "$metadata_file")
        
        # 디렉토리에 metadata 속성 추가
        /usr/bin/env xattr -w tuist.cloud.metadata "$metadata_content" "$dir_path"
        
        # 모든 .xcframework 파일에 metadata 속성 추가
        for xcframework in "$dir_path"/*.xcframework; do
            /usr/bin/env xattr -w tuist.cloud.metadata "$metadata_content" "$xcframework"
        done
        # metadata 파일 삭제
        rm $metadata_file
    fi
done
```


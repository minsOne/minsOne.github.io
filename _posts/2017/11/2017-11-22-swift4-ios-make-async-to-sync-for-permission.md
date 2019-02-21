---
layout: post
title: "[Swift4][iOS]권한 획득시 비동기를 동기로 처리하기(DispatchSemaphore)"
description: ""
category: "Programming"
tags: [PHPhotoLibrary, PHAuthorizationStatus, DispatchSemaphore, semaphore, async, sync, iOS]
---
{% include JB/setup %}

카메라 권한, 이미지 읽기, 쓰기 등의 권한을 얻으려면 비동기 방식을 사용합니다. 

```
PHPhotoLibrary.requestAuthorization({ (newStatus) in
    if (newStatus == PHAuthorizationStatus.authorized) {
    	// Doing
    } else {
    	// Doing
    }
})
```

따라서 클로저 내부에 다음 수행할 코드나 함수를 추가해야합니다. 만약에 동기 방식으로 처리할 수 있다면 어떨까요? 

동기 방식으로 처리하기 위해선 세마포어(Semaphore)를 사용합니다.

Swift에서는 [GCD 세마포어](https://developer.apple.com/documentation/dispatch/dispatchsemaphore)가 새로 디자인되어 다음과 같이 사용할 수 있습니다.

```
let semaphore = DispatchSemaphore(value: 0)
semaphore.wait()
semaphore.signal()
```


그러면 세마포어를 이용해서 Photo의 권한을 얻도록 코드를 작성합니다.

```
enum PHPhotoLibraryAuthorizationError: Error {
    case error(PHAuthorizationStatus)
}

extension PHPhotoLibrary {
    @discardableResult class func syncRequestAuthorization() throws -> PHAuthorizationStatus {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            return status
        case .denied, .restricted:
            throw PHPhotoLibraryAuthorizationError.error(status)
        case .notDetermined:
            break
        }
        
        let semaphore = DispatchSemaphore(value: 0)

        PHPhotoLibrary.requestAuthorization{ _ in
            semaphore.signal()
        }
        
        semaphore.wait()
        
        let newStatus = PHPhotoLibrary.authorizationStatus()

        switch newStatus {
        case .authorized:
            return newStatus
        case .denied, .restricted, .notDetermined:
            throw PHPhotoLibraryAuthorizationError.error(newStatus)
        }
    }
}
```

처음 권한 상태 확인 후, denied, restricted 경우라면 에러를 던지고, notDetermined이라면 권한을 요청합니다.

권한 요청시 세마포어를 이용하여 동기로 처리한 후, 다시 권한 상태를 확인하고 authorized를 제외한 나머지 경우는 에러를 던집니다.

이제 Photos를 이용하기 전에 syncRequestAuthorization를 호출하여 권한을 항상 확인할 수 있습니다.

```
do {
    try PHPhotoLibrary.syncRequestAuthorization()
} catch {
    // Error 처리
}

or

let result = try? PHPhotoLibrary.syncRequestAuthorization()
```


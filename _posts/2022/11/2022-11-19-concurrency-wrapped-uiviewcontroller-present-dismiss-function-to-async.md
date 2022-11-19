---
layout: post
title: "[Swift 5.7+][Concurrency] UIViewController의 present, dismiss 함수의 completion을 async 코드로 감싸 사용하기"
tags: [Swift, Concurrency, Task, UIViewController, present, dismiss, closure, async, await]
---
{% include JB/setup %}

UIViewController에서 present, dismiss 함수는 completion Block을 통해 완료 후 어떤 동작을 수행할지 주입할 수 있습니다.

하지만 Closure 코드를 작성함에 있어 코드의 복잡도는 증가합니다.

```swift
func routeNewViewController() {
  let vc = ViewController()
  present(vc, animated: true) { [weak self] in self?.something() }
}

func dismissViewController() {
  vc.dismiss(animated: true) { [weak self] in self?.something() }
}
```

---

Swift의 Concurrency에서 Closure 코드를 async로 만들어주는 `withCheckedContinuation(function:_:)` 함수를 이용해 래핑한 코드를 만들 수 있습니다.

```swift
import UIKit

protocol SuspendableViewControllerProtocol {
  /// UIViewController의 present 함수를 async 형태로 구현
  ///
  /// PresentedViewController의 ViewDidAppear 호출까지 await 후 진행
  ///
  /// ```
  /// Task { @MainActor [weak self] in
  ///   let newVC = NewViewController()
  ///   await self?.presentAsync(newVC, animated: true)
  ///   print("present completion")
  /// }
  ///
  /// // Output :
  /// PresentedViewController viewDidLoad
  /// PresentedViewController viewWillAppear
  /// PresentedViewController viewDidAppear
  /// present completion
  /// ```
  @MainActor
  func presentAsync(_ viewControllerToPresent: UIViewController, animated flag: Bool) async
  /// UIViewController의 dismiss 함수를 async 형태로 구현
  ///
  /// PresentedViewController의 viewDidDisappear 호출까지 await 후 진행
  ///
  /// ```
  /// Task { @MainActor [weak self] in
  ///   await self?.dismiss(animated: true)
  ///   print("dismiss completion")
  /// }
  ///
  /// // Output :
  /// PresentedViewController viewWillDisappear
  /// PresentedViewController viewDidDisappear
  /// dismiss completion
  /// ```
  @MainActor
  func dismissAsync(animated flag: Bool) async
}

extension SuspendableViewControllerProtocol where Self: UIViewController {
  @MainActor
  func presentAsync(_ viewControllerToPresent: UIViewController, animated flag: Bool) async {
    if Task.isCancelled { return }
    return await withCheckedContinuation { continuation in
      present(viewControllerToPresent, animated: flag, completion: {
        continuation.resume(returning: ())
      })
    }
  }
  
  @MainActor
  func dismissAsync(animated flag: Bool) async {
    if Task.isCancelled { return }
    return await withCheckedContinuation { continuation in
      dismiss(animated: flag, completion: {
        continuation.resume(returning: ())
      })
    }
  }
}

extension UIViewController: SuspendableViewControllerProtocol {}
```

그러면 우리는 위 presentAsync, dismissAsync 함수를 이용하여, Task 내에서 다음 수행할 코드를 작성할 수 있습니다.

## 예제

버튼을 눌러 BlueViewController를 띄우고, 닫는 일반적인 예제 코드입니다.

```swift
class ViewController: UIViewController, BlueViewControllerDelegate {
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    let blueBtn = UIButton()
    blueBtn.setTitle("Show BlueViewController", for: .normal)
    blueBtn.sizeToFit()
    blueBtn.frame.origin = .init(x: 100, y: 100)
    blueBtn.addTarget(self, action: #selector(showBlueViewController), for: .touchUpInside)
    blueBtn.setTitleColor(.systemBlue, for: .normal)
    
    view.addSubview(blueBtn)
  }

  @objc func showBlueViewController() {
    let vc = BlueViewController()
    vc.listener = self
    present(vc, animated: true) { print("presented BlueViewController") }
  }
  
  func dismissBlueViewController() {
    dismiss(animated: true) { print("dismissed BlueViewController") }
  }
}

protocol BlueViewControllerDelegate: AnyObject {
  func dismissBlueViewController()
}

class BlueViewController: UIViewController {
  weak var listener: BlueViewControllerDelegate?

  override func viewDidLoad() {
    print(Self.self, #function)
    super.viewDidLoad()
    view.backgroundColor = .systemBlue
    
    let dismissBtn = UIButton()
    dismissBtn.setTitle("Show BlueViewController", for: .normal)
    dismissBtn.sizeToFit()
    dismissBtn.frame.origin = .init(x: 100, y: 100)
    dismissBtn.addTarget(self, action: #selector(close), for: .touchUpInside)
    dismissBtn.backgroundColor = .systemBlue
    
    view.addSubview(dismissBtn)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    print(Self.self, #function)
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    print(Self.self, #function)
  }
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    print(Self.self, #function)
  }
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    print(Self.self, #function)
  }
  
  @objc func close() {
    listener?.dismissBlueViewController()
  }
}
```

<br/><video src="{{ site.production_url }}/image/2022/11/20221119_01.mp4" height="500" controls autoplay loop></video><br/>

위 코드에서 BlueViewController를 띄우고, 닫으면 다음과 같이 콘솔 로그가 출력됩니다.

```
BlueViewController viewDidLoad()
BlueViewController viewWillAppear(_:)
BlueViewController viewDidAppear(_:)
presented BlueViewController
BlueViewController viewWillDisappear(_:)
BlueViewController viewDidDisappear(_:)
dismissed BlueViewController
```

present의 completion Block은 viewDidAppear이 호출된 후 호출이 되고, dismiss의 completion Block은 viewDidDisappear이 호출된 후에 호출됨을 알 수 있습니다.

present와 dismiss 함수를 presentAsync, dismissAsync로 변경하여 코드를 작성해봅시다.

```swift
class ViewController: UIViewController, BlueViewControllerDelegate {
  private var task: Task<(), Never>?
  
  deinit { task?.cancel() }

  override func viewDidLoad() {
    ...
  }

  @objc func showBlueViewController() {
    task = Task { @MainActor [weak self] in
      let vc = BlueViewController()
      vc.listener = self
      await self?.presentAsync(vc, animated: true)
      print("presented BlueViewController")
    }
  }
  
  func dismissBlueViewController() {
    task = Task { @MainActor [weak self] in
      await self?.dismissAsync(animated: true)
      print("dismissed BlueViewController")
    }
  }
}
```

이전에 completion Block에 코드를 작성하던 것보다 간결하게 작성할 수 있었습니다.

또한, 변경한 코드로 호출했을 때 기존과 동일한 결과가 출력됨을 확인할 수 있습니다.

```
BlueViewController viewDidLoad()
BlueViewController viewWillAppear(_:)
BlueViewController viewDidAppear(_:)
presented BlueViewController
BlueViewController viewWillDisappear(_:)
BlueViewController viewDidDisappear(_:)
dismissed BlueViewController
```

## 참고자료

* [\[Swift 5.7+\]\[Concurrency\] Continuations - Closure를 async 코드로 감싸 사용하기]({{ site.production_url }}/swift-concurrency-continuation)
* [Mirrativ Tech Blog - Swift Concurrencyを利用した表示再開するUIViewControllerの実装](https://tech.mirrativ.stream/entry/2022/05/31/120125)
* iOSDC2022
  * [Swift Concurrency時代のiOSアプリの作り方](https://speakerdeck.com/koher/swift-concurrencyshi-dai-noiosapurinozuo-rifang)
  * [Swift Concurrency Next Step](https://speakerdeck.com/shiz/swift-concurrency-next-step)
  * [iOSDC2022 슬라이드 모음](https://qiita.com/yuukiw00w/items/4cb8d35bec1ac72440d4)
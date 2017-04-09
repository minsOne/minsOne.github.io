---
layout: post
title: "[RxSwift][Swift3] Closure, Delegate 대신 Observable을 사용해서 응답값을 쉽게 처리하기"
description: ""
category: "programming"
tags: [Swift, RxSwift, Closure, Delegate, Callback, Observable, PublishSubject]
---
{% include JB/setup %}

기존에 팝업 호출, 인증, 알럿 등을 사용할 때 Delegate 또는 Closure를 사용해서 처리합니다. 하지만 이러한 방식은 코드를 읽는데 흐름이 끊어집니다. 

예를 들어, 인증 Delegate 메소드를 찾으러 화면을 이동하거나, Closure 내부를 들어다 봐야 하기 때문입니다. 이는 팝업, 인증, 알럿이 비동기로 동작하기 때문입니다.

이러한 비동기 처리를 PublishSubject를 이용하여 깔끔하게 다룰 수 있습니다.

---

다음 상황을 해결해봅시다.

1. 버튼이 있는 화면 FirstVC을 만듭니다.
2. 버튼을 눌러 빨간색, 파란색 버튼이 있는 SecondVC를 띄웁니다.
3. 빨간색 버튼을 눌러 SecondVC를 닫은 후, FirstVC 배경색을 빨간색으로 바꿉니다.

기존에는 SecondViewController가 Callback 또는 delegate를 변수로 가져야 했습니다.

```
  class SecondViewController: UIViewController {
  var closure: ((UIColor) -> Void)? = nil

  func close(color: UIColor) {
    dismiss(animated: true) { [weak self] in
    self?.closure?(color)
    }
  }
  }
```

FirstVC는 Closure에 행동할지를 정의를 해야합니다. 하지만 SecondVC는 색상만 전달해하면 되는데, 역할이 애매모호합니다.

그러면 RxSwift를 이용하여 FirstVC가 SecondVC에서 선택한 색상을 받아 처리하는 방식으로 바꿔보도록 해봅시다.

```
  class FirstViewController: UIViewController {
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
      super.viewDidLoad()
      let btn = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
      view.addSubview(btn)
      btn.backgroundColor = UIColor.brown
    }
  }
```

먼저 SecondVC를 띄울 버튼을 만듭니다.

그리고 SecondVC를 만듭니다.

```
  class SecondViewController: UIViewController {
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
      super.viewDidLoad()
      view.backgroundColor = UIColor.gray
      
      let redButton = UIButton(frame: CGRect(x: 0, y: 100, width: 100, height: 100))
      redButton.backgroundColor = UIColor.red
      let blueButton = UIButton(frame: CGRect(x: 200, y: 100, width: 100, height: 100))
      blueButton.backgroundColor = UIColor.blue
      
      view.addSubview(redButton)
      view.addSubview(blueButton)
    }

    func complete(color: UIColor) {
      dismiss(animated: true) { [weak self] in
      }
    }
  }
```

SecondVC에 PublishSubject를 만들고, 외부에서 Observable을 구독하도록 추가합니다.

```
  class SecondViewController: UIViewController {
    private let selectedColorSubject = PublishSubject<UIColor>()
    var selectedColor: Observable<UIColor> {
      return selectedColorSubject.asObservable()
    }
  }
```

그리고 SecondVC는 색상 버튼을 선택 뒤, dismiss 완료 후, selectedColorSubject에 선택한 색상으로 이벤트를 발행합니다.

```
  class SecondViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    private let selectedColorSubject = PublishSubject<UIColor>()
    var selectedColor: Observable<UIColor> {
      return selectedColorSubject.asObservable()
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      view.backgroundColor = UIColor.gray
    
      let redButton = UIButton(frame: CGRect(x: 0, y: 100, width: 100, height: 100))
      redButton.backgroundColor = UIColor.red
      let blueButton = UIButton(frame: CGRect(x: 200, y: 100, width: 100, height: 100))
      blueButton.backgroundColor = UIColor.blue
    
      view.addSubview(redButton)
      view.addSubview(blueButton)
    
      let redObservable = redButton.rx.tap.map { UIColor.red }
      let blueObservable = blueButton.rx.tap.map { UIColor.blue }
    
      Observable.of(redObservable, blueObservable)
        .merge()
        .subscribe(onNext: { [weak self] in 
         self?.complete(color: $0) 
        })
        .addDisposableTo(disposeBag)
    }

    func complete(color: UIColor) {
      dismiss(animated: true) { [weak self] in
        self?.selectedColorSubject.onNext(color)
        self?.selectedColorSubject.onCompleted()
      }
    }
  }
```

selectedColorSubject에 onCompleted()를 호출해야하는데, PublishSubject가 disposed되어 메모리에 상주하지 않도록 합니다. 따라서 SecondVC가 dismiss되더라도 메모리 누수가 발생하지 않습니다.

FirstVC는 SecondVC의 selectedColor를 구독하고, 구독한 값으로 배경색을 바꿉니다.

```
  class FirstViewController: UIViewController {
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
      super.viewDidLoad()
      let btn = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
      view.addSubview(btn)
      btn.backgroundColor = UIColor.brown

      btn.rx.tap
        .flatMap(selectedColor)
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { [weak self] (color) in
          self?.view.backgroundColor = color
        })
        .addDisposableTo(disposeBag)
    }

    func selectedColor() -> Observable<UIColor> {
      let vc = SecondViewController()
      present(vc, animated: true)
      return vc.selectedColor
    }
  }
```

이제 SecondVC에서 선택한 색상이 FirstVC 배경색이 바뀌는 것을 확인할 수 있습니다.

<a data-flickr-embed="true"  href="https://www.flickr.com/photos/134677242@N06/33550828290/in/datetaken/" title="observable"><img src="https://c1.staticflickr.com/3/2906/33550828290_5dbc83dd68_o.jpg" width="374" height="682" alt="observable"></a><script async src="//embedr.flickr.com/assets/client-code.js" charset="utf-8"></script>


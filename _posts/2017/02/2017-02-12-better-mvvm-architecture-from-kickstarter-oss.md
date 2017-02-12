---
layout: post
title: "[RxSwift][Swift3]POP를 이용하여 더 나은 MVVM 구조 만들기"
description: ""
category: "programming"
tags: [RxSwift, swift, MVVM, Observable, protocol, ViewModel]
---
{% include JB/setup %}

## MVVM

MVVM 구조가 잘 작성되어 있는 예제가 많이 없다보니 어떻게 구조를 작성해야할 지 시작하기 어렵습니다. 그 와중에 킥스타터에서 자사 앱을 [오픈소스](https://github.com/kickstarter/ios-oss/tree/master/Kickstarter-iOS)로 공개했습니다. 여기에서 제가 주목한 점은 MVVM 아키텍처를 적용한 프로젝트였다는 점입니다. 

그전에 MVVM을 한번 살펴보도록 합시다.

<img src="https://i-msdn.sec.s-msft.com/dynimg/IC564167.png"/><br/>

-출처 : MSDN

Model은 ViewModel에 notification를 전달하고, ViewModel은 View에 notification를 전달합니다. View는 ViewModel에 명령을 전달하고, ViewModel은 Model을 업데이트 합니다.

ViewModel은 View에서 명령을 Input으로 받고, View에 전달할 notification를 output으로 내보낼 수 있습니다.

따라서 ViewModel은 input과 output을 가집니다. 이것을 코드로 나타내면 다음과 같이 작성할 수 있습니다.

```
  protocol ViewModelInput {}

  protocol ViewModelOutput {}

  protocol ViewModelType {
    var inputs: ViewModelInput { get }
    var outputs: ViewModelOutput { get }
  }

  class ViewModel: ViewModelInput, ViewModelOutput, ViewModelType {
    init() {}
    
    var inputs: ViewModelInput { return self }
    var outputs: ViewModelOutput { return self }
  }
```

View에서 ViewModel에 inputs과 outputs을 통해 접근해야 합니다.

ViewModel은 View에서 명령을 Input으로 받으므로, ViewModelInput 프로토콜에 View에서 보낼 명령을 정의합니다.

```
  protocol ViewModelInput {
    func request1()
    func request2()
    func request3()
  }
```

ViewModel 클래스는 ViewModelInput 프로토콜에 정의된 함수를 구현합니다.

```
  extension ViewModel {
    func request1() {
      ...
    }
    func request2() {
      ...
    }
    func request3() {
      ...
    }
  }
```

<br/><br/>이제 ViewModel에서 View에 notification를 전달할 output을 만들어 봅시다. 먼저 Model에서 ViewModel에 notification을 전달하므로, Model을 작성합니다.

```
  struct Model {
    let number = Variable(100)
  }
```

ViewModel은 Model의 number의 notification을 View에 보내도록 ViewModelOutput 프로토콜에 정의하고 ViewModel에 구현합니다.

```
  protocol ViewModelOutput {
    var number: Observable<Int> { get }
  }

  class ViewModel: ViewModelInput, ViewModelOutput, ViewModelType {
    let model: Model
    init() {
      model = Model()

      self.number = model.number.asObservable()
    }

    let number: Observable<Int>

    var inputs: ViewModelInput { return self }
    var outputs: ViewModelOutput { return self }
  }
```

<br/><br/>View는 ViewModelOutput 프로토콜에 정의된 number를 구독하여 화면에 반영합니다.

```
  class ViewController: UIViewController {

    var viewModel: ViewModel!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

    func bind() {
      viewModel.outputs.number
        .subscribe(onNext: { number in
            print(number)
          })
        .addDisposableTo(disposeBag)

      btn.rx.tap
        .subscribe(onNext: viewModel.inputs.request1)
        .addDisposableTo(DisposeBag)
    }
  }
```

## 정리

Model에서 발생한 notification은 ViewModel의 init에서 다루며, ViewModel의 output을 View가 구독합니다. 그리고 View에서 ViewModel의 input으로 명령으로 보내고, ViewModel은 명령을 받아 Model에 반영합니다.

POP를 이용하여 ViewModel의 input과 output 역할을 명확하게 해줍니다.

## 참고자료

* [kickstarter/ios-oss](https://github.com/kickstarter/ios-oss)
* [MSDN - The MVVM Pattern](https://msdn.microsoft.com/en-us/library/hh848246.aspx)

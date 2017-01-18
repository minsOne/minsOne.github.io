---
layout: post
title: "[Swift3][RxSwift]UITableViewCell에서 Rx 사용하기"
description: ""
category: "programming"
tags: [Swift, RxSwift, UITableViewCell]
---
{% include JB/setup %}

UITableViewCell에서도 간혹 Rx 방식으로 코드를 작성해야 하는 경우가 종종 있습니다. 하지만 UITableViewCell은 항상 재사용을 하기 때문에 어떻게 사용해야 할지 살짝 난감하기도 합니다.

따라서 재사용하는 특성을 이용하여 DisposeBag을 새로 만들어 기존의 스트림을 종료시키고 다시 만들면 됩니다.

```swift
class tableViewCell: UITableViewCell {
  var disposeBag = DisposeBag()

  override func prepareForReuse() {
    super.prepareForReuse()
		
    disposeBag = DisposeBag()	        
  }
}
```


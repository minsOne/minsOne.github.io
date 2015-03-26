---
layout: post
title: "GCD를 이용한 RaceCodition 만들기 in Swift"
description: ""
category: "Mac/iOS"
tags: [ios, swift, racecondition, didset, gcd]
---
{% include JB/setup %}

### GCD를 이용한 RaceCondition 발생시키기

예전에 코딩테스트를 보는데 다음과 같은 문제가 나와 풀었던 적이 있습니다. 해당 문제를 Swift 방식으로 쉽게 풀고자 합니다.

문제는 다음과 같습니다. localCountLabel이 3개 있고 globalCountLabel이 있습니다. 각각의 localCountLabel의 값이 증가할때마다 globalCountLabel 값도 증가하도록 합니다.

문제만 봐도 racecondition이라는 것을 알 수 있습니다.

우선 localCountLabel과 globalCountLabel을 선언합니다.

	var localCountLabel1: UILabel!
	var localCountLabel2: UILabel!
	var localCountLabel3: UILabel!
	var globalCountLabel: UILabel!

	var localCount1: Int = 0
	var localCount2: Int = 0
	var localCount3: Int = 0
	var globalCount: Int = 0

localCount는 label의 값이므로 값이 변경될 때 마다 label의 text를 변경하도록 [Property Observers](../swift-properties-summary/)를 이용합니다. UILabel은 화면에 표시되므로 GCD Main Queue를 이용하여 처리하도록 합니다.

	var localCount1: Int = Int(){
	  didSet {
	    dispatch_async(dispatch_get_main_queue(), { () -> Void in
	      self.localCountLabel1.text = String(self.localCount1)
	    })
	  }
	}
	var localCount2: Int = Int(){
	  didSet {
	    dispatch_async(dispatch_get_main_queue(), { () -> Void in
	      self.localCountLabel2.text = String(self.localCount2)
	    })
	  }
	}
	var localCount3: Int = Int(){
	  didSet {
	    dispatch_async(dispatch_get_main_queue(), { () -> Void in
	      self.localCountLabel3.text = String(self.localCount3)
	    })
	  }
	}
	var globalCount: Int = Int(){
	  didSet {
	    dispatch_async(dispatch_get_main_queue(), { () -> Void in
	      self.globalCountLabel.text = String(self.globalCount)
	    })
	  }
	}

이제 localCount와 globalCount값이 변경될 때 마다 각각의 label의 값이 변경됩니다.

다음으로 각각의 값을 증가시키는 함수를 만듭니다. 

	func plusCount(lCount: Int, gCount: Int) -> (Int, Int) {
	  return (lCount + 1, gCount + 1)
	}

각 localCount를 dispatch_async를 사용하여 값을 증가시키도록 합니다.

	let limit = 10000
    dispatch_async(dispatch_queue_create("kr.minsone.opensource.localCount1", nil), {
      while(self.globalCount < limit) {
        (self.localCount1, self.globalCount) = self.plusCount(self.localCount1, gCount: self.globalCount)
      }
    })
    dispatch_async(dispatch_queue_create("kr.minsone.opensource.localCount2", nil), {
      while(self.globalCount < limit) {
        (self.localCount2, self.globalCount) = self.plusCount(self.localCount2, gCount: self.globalCount)
      }
    })
    dispatch_async(dispatch_queue_create("kr.minsone.opensource.localCount3", nil), {
      while(self.globalCount < limit) {
        (self.localCount3, self.globalCount) = self.plusCount(self.localCount3, gCount: self.globalCount)
      }
    })

위의 코드를 통해 실행을 하게 되면 각각의 localCount값 합은 globalCount 값보다 큰 것을 확인할 수 있습니다.

위 코드를 실행할 수 있는 소스입니다. [링크](https://github.com/minsOne/raceConditionInSwift)

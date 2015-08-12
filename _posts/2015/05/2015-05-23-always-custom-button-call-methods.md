---
layout: post
title: "[Swift]커스텀 UIButton 클릭시 항상 특정 메소드 호출하기"
description: ""
category: "Mac/iOS"
tags: [ios, swift, uikit, initializers, convenience, addTarget, UIControlEvents]
---
{% include JB/setup %}

UIButton의 SubClass로 만들어 객체 생성시 자신에게 `addTarget`를 추가하여 기본적으로 로그 등의 기록을 남길 수 있습니다.

	import UIKit

	class SSPButton: UIButton {
	  convenience init() {
	    self.init(frame: CGRectZero);
	  }
	  
	  required init(coder aDecoder: NSCoder) {
	    super.init(coder: aDecoder)
	    self.setup()
	  }
	  
	  override init(frame: CGRect) {
	    super.init(frame: frame)
	    self.setup()
	  }
	  
	  deinit {
	    self.removeTarget(self, action:Selector("sendLog:"), forControlEvents: .TouchUpInside)
	  }
	}

	extension SSPButton {
	  func setup() {
	    self.addTarget(self, action: Selector("sendLog:"), forControlEvents: .TouchUpInside)
	  }
	  
	  @IBAction func sendLog(btn: SSPButton) {
	    println("Send Log")
	  }
	}

또한, UIControlEvents가 중복지정되더라도 갱신되지 않습니다. 따라서 생성 후 `addTarget`를 추가하여 지정한 메소드와 생성 시 지정한 메소드가 호출 됩니다. 그리고 호출되는 순서는 생성시 지정된 메소드가 먼저 호출되며, 생성 후에 지정된 메소드가 뒤에 호출됩니다.

	
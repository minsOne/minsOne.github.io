---
layout: post
title: "[Swift]지연 로딩으로 테이블뷰에 데이터를 반영하기"
description: ""
category: "Mac/iOS"
tags: [ios, swift, gcd, closure, nsnotification, tableview, lazy]
---
{% include JB/setup %}

원래는 blur 관련하여 검색을 하다 [Raywenderlich](http://www.raywenderlich.com/84043/ios-8-visual-effects-tutorial)의 [예제 소스](http://cdn3.raywenderlich.com/wp-content/uploads/2014/09/Grimm-Final.zip)에서 tableview에 GCD를 이용하여 row를 추가하는 방법을 보고 성능에 대해서 이러한 방식도 괜찮다고 생각되었습니다.

### 데이터 가져오기

우선 데이터를 저장할 클래스를 만듭니다.

	class Story {
	  var title: String
	  var content: String

	  init(title: String, content: String) {
	    self.title = title
	    self.content = content
	  }
	}

타입 메소드를 통해 Story 목록과 에러를 반환하는 함수를 만듭니다. 리스트 가져오는 부분은 global queue를 통해 처리하고 UI에 반영하는 부분은 main queue를 통해 처리하도록 합니다.

	class func loadStories(completion: ((Array<Story>?, NSErrorPointer) -> Void)!) {
		// 리스트 가져오는 로직
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {

			var error: NSErrorPointer = nil
			let path = NSBundle.mainBundle().bundlePath
			let manager = NSFileManager.defaultManager()

			var stories = [Story]()

			for file in contents {
				...
				...
				let story = Story(title: title, content: content)
				stories.append(story)
			}
			stories.sort{ $0.title < $1.title }
		}
		// 리스트를 화면에 반영하는 로직
		dispatch_async(dispatch_get_main_queue()) {
			if error != nil {
				completion(nil, error)
			} else {
				completion(stories, nil)
			}
		}
	}

### TableView에 반영하기

Story 목록을 가져와 테이블뷰에 반영하게 되면 ContentSizeCategory가 변경된 것을 NSNotification으로 처리하여 테이블뷰의 reloadData를 호출하도록 합니다.

viewController가 초기화 될 때 NSNotification을 등록하고 초기화 해제할 때 등록된 NSNotification을 제거합니다.
	
	required init(coder aDecoder: NSCoder)  {
		super.init(coder: aDecoder)
		registerForNotifications()
	}

	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}

	func preferredContentSizeCategoryDidChange(notification: NSNotification!) {	
		tableView.reloadData()
	}

	private func registerForNotifications() {
		let notificationCenter = NSNotificationCenter.defaultCenter()
    	notificationCenter.addObserver(self, selector: Selector("preferredContentSizeCategoryDidChange:"), name: UIContentSizeCategoryDidChangeNotification, object: nil)
	}

이제 테이블뷰에 rowHeight를 컨텐츠에 따라 셀의 크기를 가변적으로 하도록 UITableViewAutomaticDimension로 설정하고 Story 클래스의 loadStories 타입 메소드를 통해 테이블에 데이터를 채우도록 합니다.

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 78

		Story.loadStories() { loadedStories, error in
			if let stories = loadedStories {
		    	self.stories = stories
		    	var indexPaths = [NSIndexPath]()

		    	for (index, story) in stories {
		          indexPaths.append(NSIndexPath(forRow: index, inSection: 0))
		    	}

		    	self.tableView.beginUpdates()
		    	self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
		    	self.tableView.endUpdates()
			}
		}
	}

loadedStories, error는 타입 메소드인 loadStories에서 값을 받아오며, 위의 클로저는 loadedStories의 파라미터인 completion로 사용됩니다. 데이터를 받아와 화면을 갱신하는데 비동기로 동작하여 성능 이슈에 대해 자유로워 집니다.



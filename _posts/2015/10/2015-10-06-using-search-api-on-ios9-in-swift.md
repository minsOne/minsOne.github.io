---
layout: post
title: "[Swift][iOS]Search API를 사용해보자"
description: ""
category: "Mac/iOS"
tags: [CoreSpotlight, MobileCoreServices, CSSearchableItem, NSUserActivity, search, Spotlight, AppDelegate, swift, ios]
---
{% include JB/setup %}

Spotlight에 앱의 내용을 검색해달라는 기능 요청으로 Search API를 사용해보았습니다. 

### Search API 

#### 앱 내용 검색 등록

앱 내용을 검색할 수 있도록 아이템을 만들어야 합니다. 그러기 위해선 `CoreSpotlight`와 `MobileCoreServices` 프레임워크가 필요합니다.

	import CoreSpotlight
	import MobileCoreServices

다음으로 Spotlight에 노출될 정보 객체를 만듭니다. 제목, 키워드, 설명, 날짜, 썸네일 등을 설정할 수 있습니다.

	let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
	attributeSet.title = title
	attributeSet.keywords = title.componentsSeparatedByString(" ")

	let searchableItem = CSSearchableItem(uniqueIdentifier: title, domainIdentifier: nil, attributeSet: attributeSet)

여기에서 uniqueIdentifier 값은 Spotlight에서 검색하여 들어올때 넘겨주는 값입니다. 따라서, 넘겨줘야 할 정보가 많을 경우 해당 정보를 Dictionary로 만든 후 String으로 직렬화하여 uniqueIdentifier 값을 설정할 수 있습니다.

그리고 CoreSpotlight Index에 searchableItem을 추가합니다.
	
	var searchableItems: [CSSearchableItem] = []
	searchableItems.append(searchableItem)

	CSSearchableIndex.defaultSearchableIndex().indexSearchableItems(searchableItems, completionHandler: nil)

#### 앱 내용 검색 처리

이제 AppDelegate에서 Spotlight에서 검색한 후 들어올 때 처리하도록 합니다.

AppDelegate에서 다음 메소드에 먼저 전달됩니다.

	func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool

userActivity의 activityType이 CSSearchableItemActionType와 같은 경우 userActivity.userInfo에 CSSearchableItemActivityIdentifier 키로 uniqueIdentifier 값을 얻을 수 있습니다.

	func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
	    if userActivity.activityType != CSSearchableItemActionType { return true }
        guard let identifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String else { return true }
        // You can use content for this search reseult

        return true
    }

### 정리

생각외로 Search API를 사용하는데 어렵지 않습니다. 생각컨데 검색 내용을 등록할 때는 굳이 메인 쓰레드에서 사용할 필요가 없기 때문에, 저는 GCD에 우선순위를 `DISPATCH_QUEUE_PRIORITY_BACKGROUND`로 설정하여 검색을 등록하였습니다.

### 참고 자료

* [Tuts+ - iOS 9: Introducing Search APIs](http://code.tutsplus.com/tutorials/ios-9-introducing-search-apis--cms-24375)
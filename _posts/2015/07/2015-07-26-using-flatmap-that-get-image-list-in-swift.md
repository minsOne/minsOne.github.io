---
layout: post
title: "flatMap을 이용하여 유효한 이미지 리스트를 가져오기 in Swift"
description: ""
category: "programming"
tags: [swift, flatMap]
---
{% include JB/setup %}

icon-1,2,3,...100의 이미지를 가져올 때, 빈 이미지를 제외한 나머지 이미지 리스트를 가져오는 코드입니다.

	// Swift 2.0 이상 가능
	let iconArray = [Int](1...100).flatMap {
		UIImage(named: "icon-\($0)")
	}

위의 flatMap은 `func flatMap<T>(@noescape transform: (Self.Generator.Element) -> T?) -> [T]`를 사용하였습니다. 따라서 UIImage 옵셔널 값은 리스트에 추가되지 않고, 프로젝트에 있는 이미지들만을 가지고 옵니다.

만약 Swift 2.0 이상이 아닌 경우, 다음과 같이 코드를 작성할 수 있습니다.
	
	// Swift 1.0 가능
	let iconArray = [Int](1...100).map{ UIImage(named: "icon-\($0)") }.filter { $0 != nil }

	// Swift 1.2 이상 가능
	let iconArray = [Int](1...100).flatMap { s1 -> [UIImage] in
		if let image = UIImage(named: "icon-\(s1)") {
			return [image]
		}
		return []
	}

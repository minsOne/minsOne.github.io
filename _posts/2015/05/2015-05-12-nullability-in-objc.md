---
layout: post
title: "[Objective-C]Nullability"
description: ""
category: "Mac/iOS"
tags: [objc, swift, optional, unwrapping, nil, null, nullability, nullable, nonnull]
---
{% include JB/setup %}

### Nullability

Swift라는 언어가 나옴에 따라 Objective-C도 호환성을 가지기 위해 Nullability을 채택하였습니다. 

Xcode 6.3 이전 버전에서는 Swift와 Objective-C의 변수 선언시 다른 점은 optional과 non-optional(UIView vs UIView?)이라는 점입니다. 하지만 Objective-C는 단자 하나의 형태만 가집니다.(UIView *) 따라서 Swift에서 Objective-C의 변수가 값을 가지고 있는지 없는지를 알 수 없기 때문에, 무조건 UIView!라는 형태를 취하게 됩니다.

하지만 Xcode 6.3부터 Objective-C에 Nullability 특징을 가지게 됩니다. 따라서 Objective-C에서도 optional과 non-optioanl을 가질 수 있으며, 이는 Swift와 Objective-C 코드가 동일한 특징을 취하여 호환된다는 의미입니다.

Objective-C에서 optional은 `nullable`, non-optional은 `nonull`으로 사용합니다. nullable은 NULL, nil 값을 가질 수 있으며, nonull은 항상 값을 가져야 합니다.

첫번째로 nullable을 __nullable, nonull을 __nonnull으로 사용하는 코드입니다.

	@interface AAPLList : NSObject <NSCoding, NSCopying>

	- (AAPLListItem * __nullable)itemWithName:(NSString * __nonnull)name;

	@property (copy, __nullable) NSString *name;
	@property (copy, readonly) NSArray * __nonnull allItems;

	@end

	// ----------------
	self.list.name = nil // okay
	[self.list itemWithName:nil]; // warning!



두번째은 __를 사용하지 않고 좀 더 나은 방법인 nullable과 nonnull을 사용한 코드입니다.

	- (nullable AAPLListItem *)itemWithName:(nonnull NSString *)name;
	- (NSInteger)indexOfItem:(nonnull AAPLListItem *)item;

	@property (copy, nullable) NSString *name;
	@property (copy, readonly, nonnull) NSArray *allItems;

	// ----------------
	self.list.name = nil // okay
	[self.list itemWithName:nil]; // warning!


좀 더 복잡한 방법으로는 non-nullable 포인터가 nullable 객체 참조를 지정하기 위해 다음과 같이 사용합니다.

	__nullable id * __nonnull

또한, 특정 타입인 `NSError **`는 에러를 반환하는데 사용되는데 nullable 포인터가 nullable `NSError` 참조되도록 항상 추정됩니다.

### 참고 자료

* [Apple Blog][Apple_Blog]

[Apple_Blog]: https://developer.apple.com/swift/blog/?id=25
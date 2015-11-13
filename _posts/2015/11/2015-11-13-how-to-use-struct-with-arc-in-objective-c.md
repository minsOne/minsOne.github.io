---
layout: post
title: "[Objective-C]Struct에 Objective-C 객체 사용하기"
description: ""
category: "Mac/iOS"
tags: [swift, objc, tuple, struct, typedef, arc, __unsafe_unretained, assign, weak, release]
---
{% include JB/setup %}

### 들어가기 전

Swift에서 Tuple을 이용하여 여러 값을 한 번에 넘길 수 있습니다. 하지만 Objective-C는 ARC가 적용된 이후엔 struct 내부에 클래스 타입을 사용하지 못하도록 금지되어 있습니다. 

	typedef struct ImageNames {
	    NSString *normalImageName;
	    NSString *selectedImageName;
	} ImageNames;

위와 같이 작성하면, `ARC forbids Objective-C objects in struct`라는 에러가 발생합니다.

컴파일러도 에러를 뱉어내면서 사용하지 말라고 하지만, Swift에서 tuple을 쓰는 것이 매우 부러워서 사용할려고 합니다.

### Struct 작성하기

ARC로 인해 컴파일러가 위의 코드를 사용하지 못하게 하므로, `unsafe_unretained` 지시자를 추가합니다.

	typedef struct ImageNames {
	    __unsafe_unretained NSString *normalImageName;
	    __unsafe_unretained NSString *selectedImageName;
	} ImageNames;

__unsafe_unretained 지시자를 통해 컴파일러에 assign으로 사용하겠다고 말합니다.

<div class="alert warning"><strong>주의</strong> : assign은 weak과 다르게 release될 때 직접 nil 값을 넣어야 해제된 메모리에 접근하더라도 안전합니다.</div>

이제 우리는 다음과 같이 코드를 작성할 수 있습니다.

	- (ImageNames)getImageNames {
		ImageNames names;
		names.normalImageName = @"Normal Image";
		names.selectedImageName = @"Selected Image";

		return names;
	}

	ImageNames names = [self getImageNames];
	NSLog(@"%@, %@", names.normalImageName, names.selectedImageName);

	// Output
	Normal Image, Selected Image

작은 구조를 가진 데이터라면, 클래스로 만들어야 하나 생각도 듭니다. 또한, 포인터를 이용해서 처리할 수도 있지만, 여러 변수를 인자로 넘겨야 합니다.

Swift의 tuple 기능때문에 배가 아프긴 하지만, 근본적으로 다른 언어이므로 이 정도에서 만족해야 하지 않나 합니다.
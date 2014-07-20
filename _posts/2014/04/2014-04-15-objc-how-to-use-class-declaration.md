---
layout: post
title: "[Objc]@class vs import - 클래스 호출 시 사용 방법"
description: ""
category: "Mac/iOS"
tags: [objc, objectivec, import, class, annotation]
---
{% include JB/setup %}

오픈소스 라이브러리를 활용하다보면 @class라고 선언한 부분이 보입니다. 그냥 넘어갈 수도 있지만 나중에 유용하게 사용할 수 있기때문에 찾아보았습니다.

대개 특정 클래스를 사용하기 위해서는 다음과 같이 사용합니다.

	#import "Foo.h"
	@interface Bar : NSObject {
		Foo *fObj;
	}
	@end

\#import를 사용하여 헤더 파일을 로딩합니다. 그러나 추상 클래스인 경우는 선언을 하고 사용하지는 않는 경우가 많습니다.

소규모 프로젝트에서는 헤더 파일을 import하더라도 컴파일시 크게 문제되지 않지만 대규모 프로젝트에서는 사용하려고 하는 클래스에서만 헤더를 import합니다. 

단순히 선언만 하고 구상 클래스에서 헤더를 import를 하여 사용하려고 하는 경우에 @class를 사용합니다.

	@class Foo;
	@interface Bar : NSObject {
		Foo *fObj;
	}
	@end

@class를 사용하게 되면 포인터를 참조만 할 수 있으며 클래스의 메소드들은 사용하지 못합니다.

따라서 객체를 생성하거나 클래스 메소드를 사용하려고 하는 경우 #import를 통해 헤더를 호출하며, 단순히 참조를 하기 위해 사용한다면 @class를 사용하여 불필요한 헤더 파일 로딩을 하지 않습니다.
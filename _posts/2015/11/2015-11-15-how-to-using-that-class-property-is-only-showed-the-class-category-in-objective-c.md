---
layout: post
title: "[Objective-C]카테고리로 파일 분리시 속성을 외부에 노출시키지 않기"
description: ""
category: "Mac/iOS"
tags: [category, class, private, objc, objective-c, property]
---
{% include JB/setup %}

프로젝트 진행하다보면 개발자마다 스타일이 다르지만 종종 클래스 하나에 많은 메소드들이 선언되어 있고, 그러다 보면 한 클래스당 최소 500줄 이상, 심심찮게 천줄, 2천줄 가량 되기도 합니다.

일반적으로 화면을 보여주는 UIView에 관한 메소드들이 코드를 많이 차지합니다. 이들 메소드를 방치해놓고 있으면 어느순간 클래스의 라인이 엄청나게 늘어나는 것을 가끔씩 실감하곤 합니다.

사실 그렇게 되는건 리팩토링을 하지 않기도 하지만, 카테고리라는 기능을 잘 이용을 안해서 발생하기도 합니다. 그리고 한번쓰고 마는 메소드들은 카테고리로 다 빼놓고, 메인 로직만 가지고 분석하도록 코드를 분해해야합니다.

하지만 일부 속성들은 내부에서 사용하는데, 카테고리로 파일 분리시 사용하는 코드가 이들 속성을 사용하는 경우에 컴파일 에러가 발생합니다. 그렇다고 속성을 헤더 파일에 노출시켜 외부에서 사용하게 둘 수도 없고..

이 문제에 대한 해결책이 있습니다. 헤더 파일에 `@private`로 선언하고 속성을 추가하면 됩니다.

	@interface ChannelViewController : UIViewController {
	    @private
	    NSMutableArray *channelList;
	    NSMutableDictionary *channelKey;
	}

위와 같이 선언하면 카테고리로 파일 분리하더라도 해당 변수를 사용할 수 있습니다.

<div class="alert warning"><strong>주의</strong> : 카테고리를 사용하는 경우 카테고리 내부에 속성을 만들지 마세요.</div>
---
layout: post
title: "[Swift]Map 안에서 조건문 써야하나?"
description: ""
category: "programming"
tags: [swift, map, filter, condition, for, loop]
---
{% include JB/setup %}

어제 map을 사용하다가 특정 조건에 일치하는 경우와 일치하지 않는 경우 값을 다르게 해줘야 하는데 이를 코드로 작성하면 다음과 같습니다.

	self.weekLabels.map {
	  $0.alpha = ($0.tag == weekday ? 1.0 : 0.2)
	}

별 생각 없이 코드를 다시금 리팩토링하면서 map을 사용할 때 이렇게 해도 되나? 생각이 들었습니다. 그래서 두가지 방법으로 코드 작성 및 검색 해보았습니다.

### Map vs For Loop

처음 했던 생각으로 위의 코드와 for 문과 무슨 차이인가 싶어 for 문으로 코드를 작성해보았습니다.

	for label in self.weekLabels {
	  label.alpha = (label.tag == weekday ? 1.0 : 0.2)
	}

그냥 보면 앞의 map의 코드와 for 문을 보면 다르지 않다고 생각됩니다. 하지만 큰 차이점을 발견할 수 있습니다.

for 문의 label은 변수(var)가 아니라 상수(let)입니다. 위에서 사용한 label의 경우 참조 타입(Reference Type)이기 때문에 상수라도 내부 값을 변경할 수 있습니다. 하지만 값 타입(Value Type)이라면 값을 복사하여 사용하므로 위의 코드처럼 사용할 수 없습니다.

또한, map은 같은 타입의 객체를 반환하고 새로운 배열을 만들어 부작용 발생을 방지합니다. 하지만 for 문은 결과를 받을 변수를 미리 선언해야 합니다. 만일 코드를 잘못 작성할 경우 부작용이 발생할 수 있습니다.

<del>그러니까 다들 map을 씁시다</del>

### Map, Condition Vs Filter, Map

다음으로, filter를 이용해서 조건에 대해 분리하고 조건에 맞는 대상에 대해서만 값을 변경하도록 코드를 작성하였습니다.

	self.weekLabels.filter{ $0.tag == weekday }.map{ $0.alpha = 1.0 }
	self.weekLabels.filter{ $0.tag != weekday }.map{ $0.alpha = 0.2 }

코드의 수행 결과를 바로 파악할 수 있습니다.

하지만 이전 코드와 속도 부분을 비교할 경우 filter에서 2번, map에서 2번 돌아 총 4번 loop를 돌아 비효율적입니다.



### 어떻게 사용해야하는가?

map, filter 등은 함수형 언어에서 이미 기본 개념으로 들어가 있기 때문에, scala, haskell, f# 언어로 방향을 잡고 같은 생각을 하고 있는 사람들이 있는지 검색해 보았습니다.

`site:stackoverflow.com condition in map function`으로 검색을 하니 이미 많은 질문들이 올라와 있었고 특정 방법에 연연하지 않았습니다. 방법은 여러가지니까요.

결론은 다음과 같습니다.

1. map, condition은 배열의 모든 항목이 변경되지 않아도 되지만 모든 항목을 반환해야 함.
2. for 문은 배열의 모든 항목이 변경되지 않아도 되고 모든 항목을 반환 하지 않아도 됨.
3. filter, map은 해당 항목만 추려서 변경

상황에 맞게 적절한 것을 선택하는게 좋습니다.

<br/>

ps1. 생각한 모든 것들은 누군가 벌써 생각을 하고 기록에 남습니다.<br/>
ps2. 결국 처음 코드 그대로 썼습니다.<br/>
<del>ps3. 뻘짓은 적당히 하는 것이 건강에 좋습니다.</del><br/>
<del>ps4. 새벽에는 그냥 자야 합니다.</del><br/>
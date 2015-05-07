---
layout: post
title: "순수 함수(Pure Function)"
description: ""
category: "programming"
tags: [FP, pure function, swift, scala]
---
{% include JB/setup %}

### 순수 함수(Pure Function)

함수는 주어진 입력으로 계산하는 것 이외에 프로그램의 실행에 영향을 미치지 않아야 하며, 이를 부수 효과(side effect)가 없어야 한다고 합니다. 이러한 함수를 순수 함수라고 합니다.

예를 들어, count, length 함수는 임의의 문자열이나 배열에 대해서 항상 같은 길이를 반환하며, 그 외의 일은 일어나지 않습니다.

코드로 나타내보면 다음과 같이 작성할 수 있습니다.

	func plusNumber(num: Int) -> (Int -> Int) {
	  return { x in
	    return x + num
	  }
	}

	let addFive = plusNumber(5)
	addFive(1)	// 5
	addFive(10)	// 15

위의 코드에서 익명함수를 만들어 사용하게 되고 어떤 값이 들어오던지 5를 더하여 반환하게 되므로 부수 효과가 발생하지 않습니다.

순수 함수의 참조 투명성(referential transparency, RT)으로 입력 값이 같으면 결과 값도 같다면 표현식은 참조에 투명하다(referentially transparent)라고 합니다. 표현식 f(x)가 참조에 투명한 모든 x에 대해 참조가 투명하다면 함수 f는 순수하다(pure)라고 합니다.

따라서 코드의 블록을 이해하기 위해 일련의 상태 갱신을 따라갈 필요가 없고 국소 추론(local reasoning)만으로도 코드를 이해할 수 있습니다.

모듈적인 프로그램은 독립적으로 재사용할 수 있는 구성요소(component)로 구성됩니다. 

따라서 순수 함수는 입력과 결과가 분리되어 있으며, 어떻게 사용되는지에 대해서는 전혀 신경쓰지 않아도 되므로 재사용성이 높아집니다.

### 참고 자료

* 스칼라로 배우는 함수형 프로그래밍(Functional Programming in Scala)
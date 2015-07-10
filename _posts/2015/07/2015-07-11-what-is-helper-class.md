---
layout: post
title: "Helper Class란 뭘까?"
description: ""
category: "programming"
tags: [helper, class, helper class, utility, instance, object, static method, type method, class method, java, swift, objective-c]
---
{% include JB/setup %}

### Helper Class란 뭘까?

오픈소스 라이브러리를 뒤적뒤적 하다 보면 helper라는 클래스를 가진 녀석들이 가끔 출몰합니다. 그래서 helper class가 뭔가라고 기억 저편에서 꺼내어봤지만, 도저히 떠오르지 않았습니다. 

그래서 helper class라는 뜻을 추정하였습니다. helper class라는 의미를 보면 도와주는 클래스라는 의미로 파악됩니다. 또한, helper class가 있어도 되고, 없어도 되는 class라는 의미로도 생각됩니다.

위키피디아의 [Helper Class](https://en.wikipedia.org/wiki/Helper_class)를 보면, helper class는 일부 기능을 제공하여 도와주지만, 에플리케이션이나 클래스의 주목적으로는 사용될 수 없다고 합니다. 그리고 helper class의 인스턴스는 helper object로 불립니다.

정리하면 helper class는 보조적인 역할로 사용되며, 꼭 필요하지는 않다고 할 수 있습니다.

하지만 조금 달리 보면 utility class와 helper class는 비슷하다고 생각할 수도 있습니다. utility class도 보조적인 역할로 사용되는데 말이죠.

하지만 utility class는 모든 메소드가 정적 메소드입니다(Swift에선 Type method, Objective-C에서는 Class Method로 불림). 일반적으로 helper class는 모든 메소드가 정적 메소드이지 않으며, 여러 개의 helper class의 인스턴스가 있을 수 있습니다.

또한, helper class는 private로 선언하여 다른 곳에서의 접근을 막도록 하는 것이 좋습니다. 이는 특정 클래스를 도와주기 위해 helper class를 만든 것이지, 외부에서 접근하여 사용할 목적으로 만든 것이 아니기 때문입니다. 그리고 다른 helper class와 의존성이 생기지 않도록 해야 합니다.

### 정리

helper class는 특정 클래스의 작업을 도와주는 역할을 하는 클래스로 유용한 기능들을 제공하며, 다른 helper class와는 의존하지 않습니다.

하지만 helper class의 helper라는 의미에 더 치중하면 좋습니다. helper class, helper function도 되기 때문입니다. 즉, 어떤 일을 도와주고 기능을 제공해주는 존재로 포괄적으로 생각하는 것이 좋습니다.

### 참고 자료

* [CodeIgniter](http://codeigniter-kr.org/user_guide_2.1.0/general/helpers.html)
* [위키피디아](https://en.wikipedia.org/wiki/Helper_class)
* [HAXE](http://old.haxe.org/ref/oop?version=14253)
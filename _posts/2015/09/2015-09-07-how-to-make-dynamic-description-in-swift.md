---
layout: post
title: "[Swift]각각의 클래스로부터 동적 디스크립션 만들기"
description: ""
category: "Mac/iOS"
tags: [swift, objc, debugQuickLookObject, dynamicType, property, closure]
---
{% include JB/setup %}

### 동적 디스크립션 만들기

클래스를 만들고 사용하다 보면 디스크립션 또는 QuickLookObject를 만들려니 귀찮은 적이 있습니다. 그래도 한번 만들면 계속 써먹겠지 하다가 클래스가 많아지고, 속성이 하나둘씩 늘어나면 유지 보수하기가 점점 어려워집니다.

그래서 각각의 클래스들의 속성을 얻어 출력하면 어떨까라고 생각하였습니다.

동적 디스크립션 기능은 문자열, 숫자(NSNumber로 취급하여 Double 값은 Int로 취급됨)는 대응하였지만, 다른 타입(Size, Point, Color 등)에는 아직 대응하지 않았습니다. 구조체인 경우 객체가 NSValue 형태로 취급되므로, 다음에 작업해볼 예정입니다.

다음은 동적 디스크립션을 출력하는 코드입니다.

	class TTT: NSObject {
	  var s = "str"
	  var i = 1
	  var d = 2.0
	  var p = CGPointMake(0, 0)
	  var sz = CGSizeMake(0, 0)
	}

	extension TTT {
	  func debugQuickLookObject() -> AnyObject {
	    return MOQuickLook.dynamicDescription(self)
	  }
	}

	class MOQuickLook: NSObject {
	  class func dynamicDescription(aObject: AnyObject) -> String {
	    var aClass: AnyClass? = aObject.dynamicType
	    var propertiesCount : CUnsignedInt = 0
	    let propertiesInAClass = class_copyPropertyList(aClass, &propertiesCount)
	    let propertyValue = self.getPropertyValue(aObject)

	    return reduce(0..<Int(propertiesCount), "") { result, i in
	      var propertyKey = NSString(CString: property_getName(propertiesInAClass[i]), encoding: NSUTF8StringEncoding) as String?
	      return result + propertyValue(propertyKey)
	    }
	  }

	  private class func getPropertyValue(aObject: AnyObject) -> String? -> String {
	    return { propertyKey in
	      if let key = propertyKey,
	        aObj: AnyObject = aObject.valueForKey(key) {
	//        println(aObj.dynamicType)

	        switch aObj {
	        case let value as String:
	          return key + " : " + "\(value)" + "\n"
	        case let value as NSNumber:
	          return key + " : " + "\(value)" + "\n"
	        default:
	          return key + " : " + "Not yet" + "\n"
	        }
	      }
	      return ""
	    }
	  }
	}

	let a = TTT()
	/* 
	OutPut 
	s : str
	i : 1
	d : 2
	p : Not yet
	sz : Not yet
	*/
	println(a.debugQuickLookObject())

	/*
	OutPut
	s : str
	i : 1
	d : 2
	p : Not yet
	sz : Not yet
	*/
	println(MOQuickLook.dynamicDescription(a))

### 참고 자료

* [NSObject-NSCoding 프로젝트](https://github.com/greenisus/NSObject-NSCoding)
* [StackOverflow](http://stackoverflow.com/questions/24219179/how-do-i-serialise-nsdictionary-from-a-class-swift-implementation)
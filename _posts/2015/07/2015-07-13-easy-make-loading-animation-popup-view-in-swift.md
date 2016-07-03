---
layout: post
title: "[Swift]로딩 이미지 애니메이션 팝업 쉽게 만들기"
description: ""
category: "Mac/iOS"
tags: [swift, singleton, popup, window, uiapplication]
---
{% include JB/setup %}

### 쉽게 로딩 팝업 만들기

개발 요구사항 중에 이미지 애니메이션 팝업을 개발할 사항이 간혹 있습니다. 기존 오픈소스를 활용해도 되고, 아니면 간단하게 구현할 수 있습니다.

기본적으로 팝업은 항상 최상위에 위치해야 하므로 UIApplication의 keyWindow에 view를 붙여야 합니다. 그리고 UIView를 나중에 없앨 수 있도록 관리해야 하므로, Singleton를 만들어 view를 관리하도록 합니다.

첫번째로, 팝업을 관리할 Singleton 클래스를 만듭니다. 여기에서, Singleton 객체는 private로 외부에 노출하지 않습니다. 그리고 타입 메소드로 show와 hide만을 노출시켜 사용할 때 다른 객체를 관리하지 않고도 사용할 수 있도록 합니다.

	class LoadingHUD: NSObject {
		private static let sharedInstance = LoadingHUD()
		private var popupView: UIImageView
		class func hide() {
		}

		class func show() {
		}
	}

이제 show 함수를 합니다.

	class LoadingHUD: NSObject {
		class func show() {
			let popupView = UIImageView(frame: CGRectMake(0, 0, 300, 300))
	        popupView.backgroundColor = UIColor.blackColor()
	        popupView.animationImages = LoadingHUD.getAnimationImageArray()	// 애니메이션 이미지
	        popupView.animationDuration = 4.0
	        popupView.animationRepeatCount = 0	// 0일 경우 무한반복

			// popupView를 UIApplication의 window에 추가하고, popupView의 center를 window의 center와 동일하게 합니다.
			if let window = UIApplication.sharedApplication().keyWindow {
				window.addSubview(popupView)
				popupView.center = window.center
				popupView.startAnimating()
				sharedInstance.popupView?.removeFromSuperview()
				sharedInstance.popupView = popupView
			}
		}

		private class func getAnimationImageArray() -> [UIImage] {
			var animationArray: [UIImage] = []
			animationArray.append(UIImage(named: "animation1")!)
			animationArray.append(UIImage(named: "animation2")!)
			animationArray.append(UIImage(named: "animation3")!)
			animationArray.append(UIImage(named: "animation4")!)

			return animationArray
		}
	}

다음은 hide 함수를 구현합니다.

	class LoadingHUD: NSObject {
		class func show() {
			if let popupView = sharedInstance.popupView {
	            popupView.stopAnimating()
	            popupView.removeFromSuperview()
	        }
		}
	}

간단하게 애니메이션 팝업을 구현할 수 있으며, 위의 예제를 가지고 다른 팝업 형태로 구현할 수 있습니다.

다음은 [전체 소스](https://gist.github.com/minsOne/e5c37e9abef2fff594ab)입니다.
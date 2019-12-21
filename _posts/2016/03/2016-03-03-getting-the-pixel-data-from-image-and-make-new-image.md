---
layout: post
title: "[iOS][Swift]이미지로부터 픽셀 데이터 얻어 새로운 이미지 만들기"
description: ""
category: "Mac/iOS"
tags: [ios, swift, UIGraphics, bitmap]
---
{% include JB/setup %}

얼마전에 영상 재생시 보여줄 Artwork로 기존 이미지를 재활용하는 방안이 나와서 작업을 해보았는데 기존 이미지가 라운딩 처리되는 바람에 iOS의 Artwork로 보여줄 때 외각부분이 하얗게 나왔습니다. 그래서 이미지를 다시 만드니 어쩌니 하다 기존 이미지에서 색상을 추출해서 어색하지 않게 보이게 하면 어떠냐라고 의견이 나와 한번 작업을 해보았습니다.

### 색상 추출 및 배경색이 추가된 이미지 만들기

색상 값을 얻는 방법은 Apple의 [Getting the pixel data from a CGImage object](https://developer.apple.com/library/mac/qa/qa1509/_index.html)에서 참고하였으며, 다음 이미지에서 색상 값을 추출하였으며, playground에 끌어놓아 선언하였습니다.

<img src="/../../../../image/flickr/25173909930_358f916dbe.jpg" width="343" height="343" alt=""><br/>

	import UIKit

	let image = [#Image(imageLiteral: "2.png")#] // 이미지를 끌어놓아 사용합니다.
	let pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage))	// 이미지에서를 Data 형태로 만듭니다.
	let data = CFDataGetBytePtr(pixelData)	// 주소로 접근할 수 있도록 선언합니다.

	// 특정 위치에 색상 값을 뽑아내는 함수입니다.
	func getRGBA(pData: UnsafePointer<UInt8>, _ pixel: Int) -> UIColor {
		let red = pData[pixel]
		let green = pData[(pixel + 1)];
		let blue = pData[pixel + 2];
		let alpha = pData[pixel + 3];
		return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: CGFloat(alpha)/255.0)
	}

	// 색상 값을 찾습니다.
	func findColor(pData: UnsafePointer<UInt8>) -> UIColor {
		var resultColor = UIColor.blackColor()	// 색상이 없는 경우 대비해서 검은 색으로 설정
		let width = Int(image.size.width)	// 이미지의 width 값을 얻습니다.
		for i in 0...Int(image.size.height) where resultColor == UIColor.blackColor() {
			// (0,0)에서 색상값을 찾기 위해 대각선으로 이동하며, 각 pixel은 4byte이므로 4를 곱해서 좌표를 넘겨줍니다.
			let color = getRGBA(data, (width * i + i) * 4)
			if UIColor(red: 0, green: 0, blue: 0, alpha: 0) != color {
				resultColor = color
			}
		}
		return resultColor
	}

	// 뽑아낸 색상값을 배경색으로 하는 이미지를 만드는 함수입니다.
	func renderImage(image: UIImage, andBackgroundColor backgroundColor: UIColor) -> UIImage {
		UIGraphicsBeginImageContext(image.size)
		let context = UIGraphicsGetCurrentContext()
		let rect = CGRectMake(0, 0, image.size.width, image.size.height)	// 원본 이미지 크기와 동일하게 합니다.
		backgroundColor.setFill()	// 배경색으로 칠합니다.
		CGContextFillRect(context, rect)
		image.drawInRect(rect)	// 이미지를 그립니다.

		let maskedImage = UIGraphicsGetImageFromCurrentImageContext()	// 배경색이 추가된 이미지를 얻습니다.
		UIGraphicsEndImageContext()

		return maskedImage
	}

	renderImage(image, andBackgroundColor: findColor(data))


이제 우리는 투명 부분이었던 영역이 인근 색상으로 바뀐 이미지를 얻게 됩니다.

<img src="/../../../../image/flickr/25102854129_bf2b60919f.jpg" width="343" height="343" alt=""><br/>

### 참고 자료

* [Apple Technical Q&A](https://developer.apple.com/library/mac/qa/qa1509/_index.html)
* 스마트 스터디 핑크퐁 이미지
---
layout: post
title: "트위터 커버 효과 만들기 in Swift"
description: ""
category: "Mac/iOS"
tags: [swift, animation, scale, UIScrollView, transform]
---
{% include JB/setup %}

Twitter의 프로필을 화면에서 위로 스크롤을 하면 커버 이미지가 점점 확대되면서 블러처리가 됩니다. 

<br/><img src="/../../../../image/2015/twitterCover.png" alt="" style="width: 200px;"/><br/><br/>

이미지가 확대되는 효과를 구현해봅시다.

1.ViewController를 만들고 ScrollView를 만듭니다.

	import UIKit

	class ViewController: UIViewController, UIScrollViewDelegate {

	    var scrollView: UIScrollView!

	    override func viewDidLoad() {
            super.viewDidLoad()

            scrollView = UIScrollView(frame: view.bounds)
            scrollView.delegate = self
            scrollView.bounces = true
            scrollView.contentSize = CGSize(width: CGRectGetWidth(view.bounds),
                height: CGRectGetHeight(view.bounds) * 2)
	        view.addSubview(scrollView)
        }

        func scrollViewDidScroll(scrollView: UIScrollView) {}
	}

<br/>2.커버 이미지를 만들고 ScrollView에 붙입니다.
	
	var scrollView: UIScrollView!
	var imageView: UIImageView!

	override func viewDidLoad() {
	    super.viewDidLoad()
	    imageView = UIImageView(image: UIImage(named: "younha"))
	    imageView.frame = CGRect(origin: imageView.frame.origin, size: CGSize(width: view.frame.width, height: imageView.frame.height))
	    imageView.contentMode = .Center

	    scrollView = UIScrollView(frame: view.bounds)
	    scrollView.delegate = self
	    scrollView.bounces = true
	    scrollView.contentSize = CGSize(width: CGRectGetWidth(view.bounds),
	        height: CGRectGetHeight(view.bounds) * 2)
	    scrollView.addSubview(imageView)
	    view.addSubview(scrollView)
	}

<br/>3.scrollViewDidScroll 함수에서 ScrollView의 offset 값을 가지고 커버 이미지를 확대합니다.

	func scrollViewDidScroll(scrollView: UIScrollView) {
	    let yPosition = scrollView.contentOffset.y

	    // 위로 스크롤링을 하는 경우
	    if yPosition < 0 {
	    	// 이미지를 확대한다.
	        let scale = 1 + ((-yPosition) * 2 / imageView.frame.height)
	        imageView.transform = CGAffineTransformIdentity
	        imageView.transform = CGAffineTransformMakeScale(scale, scale)

	        // 이미지를 가장 위로 이동시킨다.
	        var imageViewFrame = imageView.frame
	        imageViewFrame.origin.y = yPosition
	        imageView.frame = imageViewFrame
	    }
	}

위로 스크롤링하여 스크롤 위치가 -1px씩 늘어나면 2px씩 확대되어야 합니다. 그리고 이미지를 이동한 스크롤 위치로 계속 이동시켜서 확대되더라도 빈 공간이 보이지 않도록 합니다.

다음은 위의 코드를 적용한 결과 화면입니다.

<video width="500" height="500" controls>
  <source src="/../../../../image/2015/twitterCoverAnimation.mp4" type="video/mp4">
</video>
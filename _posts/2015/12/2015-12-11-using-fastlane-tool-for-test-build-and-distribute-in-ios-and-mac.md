---
layout: post
title: "[iOS][Xcode]fastlane을 이용하여 쉽게 테스트, 빌드, 배포하기"
description: ""
category: "Mac/iOS"
tags: [ios, xcode, fastlane, scan, gym, snapshot, deliver, itunesconnect]
---
{% include JB/setup %}

뒤늦게 [fastlane](https://fastlane.tools)을 알게되었습니다. 아직 Xcode ci를 도입해야하는데 이런저런 사정이.. 귀차니즘과 함께하여 진행하질 못하였기에 이런저런 수작업으로 바이너리를 앱스토어에 올리고 있었습니다.

<br/><img src="/../../../../image/flickr/23656007995_4f54706ceb_z.jpg" width="533" height="187" alt="logo-desktop-large"><br/>

fastlane은 특정 기능들을 묶어 실행하는 길, 통로라고 할 수 있습니다.

쉽게 테스트를 실행하는 [scan](https://github.com/fastlane/scan), 자동으로 스크린샷을 찍어 확인할 수 있게 해주는 [snapshot](https://github.com/fastlane/snapshot), 쉽게 iOS 앱을 빌드해주는 [gym](https://github.com/fastlane/gym), 앱스토어에 앱과 메타데이터 등을 업로드해주는 [deliver](https://github.com/fastlane/deliver) 등등 있습니다.

fastlane은 lane으로 각 기능들을 묶어서 실행하거나 독립적으로 실행할 수 있습니다.

	lane :appstore do
	  increment_build_number
	  cocoapods
	  scan
	  snapshot
	  sigh
	  deliver
	  sh "./customScript.sh"

	  slack
	end

	$ fastlane appstore


제 경우는 xcode7으로 업데이트되면서 organzier에서 앱 목록을 불러오는 시간이 10분에서 15분이상 걸리기 때문에, 이러한 툴들이 필요했습니다. 그래서 이 중 gym, deliver를 사용하여 앱을 빌드하고, ipa를 deliver를 통해 앱스토어에 업로드하고 있습니다.

gym과 deliver 명령어는 다음과 같이 사용하고 있습니다.

	gym --verbose --scheme "Scheme 명" --clean
	deliver --ipa "업로드할 ipa명" --username "itunesconnect 계정 명" --app_identifier "앱 번들아이디" --submit_for_review false --force true --skip_metadata --skip_screenshots

<br/>이로서 저는 앱 빌드 및 ipa 생성 그리고 바이너리 업로드를 Xcode에서 벗어날 수 있었습니다. fastlane에 감사를 드립니다.

ps. 기존에 사용하던 스크립트가 있었지만 해당 툴로 좀 더 깔끔하게 정리되어 좋아졌습니다.

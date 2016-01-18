---
layout: post
title: "[Apple][iTMSTransporter]iTMSTransporter로 인앱 만들기"
description: ""
category: "Mac/iOS"
tags: [apple, iTMSTransporter, Transporter, InAppPurcase, itunesconnect, Application loader]
---
{% include JB/setup %}

이전 글에서 iTMSTransporter로 인앱을 다루어보았습니다. 이번에는 iTMSTransporter로 인앱을 생성해보도록 합시다.

먼저 인앱 정보를 내려받습니다.

	$ iTMSTransporter -m lookupMetadata -u username -p password -apple_id [appleid ex)10000200] -subitemtype InAppPurchase -destination destinationPath -v eXtreme

`[apple_id].itmsp`라는 폴더가 생성되는데, `metadata.xml` 파일을 열어보면 인앱 정보가 담겨있습니다.
	<in_app_purchases>
		...
		<in_app_purchase>
			<product_id>kr.ss.inapp2</product_id>
			<reference_name>inapp2</reference_name>
			<type>non-consumable</type>
			<products>
				<product>
					<cleared_for_sale>true</cleared_for_sale>
					<intervals>
						<interval>
							<start_date>2016-01-17</start_date>
							<wholesale_price_tier>1</wholesale_price_tier>
						</interval>
					</intervals>
				</product>
			</products>
			<locales>
				<locale name="ko">
					<title>inapp2</title>
					<description>oooooooinapp2</description>
				</locale>
			</locales>
			<read_only_info>
				<read_only_value key="iap-status">Waiting for Screenshot</read_only_value>
			</read_only_info>
		</in_app_purchase>
		...
	</in_app_purchases>

기존의 인앱 정보들을 지우고, 다음과 같은 형식으로 정보를 넣습니다.

	...
	<in_app_purchases>
		<in_app_purchase>
			<product_id>kr.ss.inapp99.test</product_id>
			<reference_name>test99</reference_name>
			<type>consumable</type>
			<products>
				<product>
					<cleared_for_sale>true</cleared_for_sale>
					<intervals>
						<interval>
							<start_date>2016-01-18</start_date>
							<wholesale_price_tier>1</wholesale_price_tier>
						</interval>
					</intervals>
				</product>
			</products>
			<locales>
				<locale name="ko">
					<title>test</title>
					<description>test1234567890</description>
				</locale>
			</locales>
			<review_screenshot>
				<size>70474</size>
				<file_name>reviewImage.png</file_name>
				<checksum type="md5">2bbccfc062320421330e5b6741977ed4</checksum>
			</review_screenshot>
			<review_notes>review_notes test12345</review_notes>
		</in_app_purchase>
	</in_app_purchases>
	...

기존의 인앱 정보와 다른 부분은 review_screenshot과 review_notes Element 유무입니다. 신규 인앱 리뷰를 위한 리뷰 스크린샷과 설명을 요구하는데, 이미지는 itmsp 폴더 내에 위치해야 하고, 이미지의 파일 크기, 파일 이름, md5를 설정해야 합니다. 또한, 리뷰 스크린샷은 다음 중 하나 이상의 해상도를 필요로 합니다.

312x390, 2732x2048, 2048x2732, 1334x750, 750x1334, 960x640, 960x600, 640x960, 640x920, 2208x1242, 1242x2208, 1136x640, 1136x600, 640x1136, 640x1096, 1024x768, 1024x748, 768x1024, 768x1004, 2048x1536, 2048x1496, 1536x2048, 1536x2008

만약, 여러 인앱을 추가해야한다면, in_app_purchase Element를 만들어서 추가합니다.

모든 준비가 다 되었다면, iTMSTransporter를 이용하여 itmsp를 업로드 합니다.

	$ iTMSTransporter -m upload -f [itmsp 파일 경로] -u username -p password -apple_id appleid -subitemtype InAppPurchase -v eXtreme -t DAV -success [성공 시 저장 경로] -failure [실패시 저장 경로]

itunesconnect에 들어가 확인하거나 Application Loader를 이용하여 인앱이 생성되었는지 확인할 수 있습니다.

---
layout: post
title: "[Apple][iTMSTransporter]iTMSTransporter로 인앱 다루기"
description: ""
category: "Mac/iOS"
tags: [apple, iTMSTransporter, Transporter, InAppPurcase, itunesconnect]
---
{% include JB/setup %}

서비스에 따라 다르지만 인앱 가격이 자주 바뀌는 서비스인 경우, 매번 itunesconnect에 들어가서 인앱 가격을 변경하거나 기간을 설정해줘야 합니다. 이벤트를 해야 하는 시점에 여러 앱의 인앱들을 바꿔야 한다면, 매우 끔찍할 것입니다. 속도가 느린 itunesconnect에서 일일이 변경을 하려면 말이죠.

하지만 애플은 일일이 하지 않아도 되도록 iTMSTransporter라는 툴을 만들어 놓았습니다. 메타데이터, App 파일 등을 조회하고, 진단하고, 업로드할 수 있습니다.

### 설치 방법

iTMSTransporter는 OS X, Window, Linux 등에서도 설치가 가능합니다.

[설치 방법 보러 가기](http://help.apple.com/itc/transporteruserguide/#/apdATD1E1148-D1E1A1303-D1E1148A1126)

### 인앱 다루기

#### 인앱 정보 가져오기

다음 명령을 통해서 인앱의 정보를 가져올 수 있습니다.

	$ iTMSTransporter -m lookupMetadata -u username -p password -apple_id [appleid ex)10000200] -subitemtype InAppPurchase -destination destinationPath -v eXtreme

`[apple_id].itmsp`라는 폴더가 생성된 것을 확인할 수 있으며, 이 폴더 아래에는 `metadata.xml` 파일이 있으며, 인앱 정보가 담겨 있습니다.

	<?xml version="1.0" encoding="UTF-8"?>
	<package xmlns="http://apple.com/itunes/importer" version="software5.4">
	    <metadata_token>metadata_token</metadata_token>
	    <provider>provider</provider>
	    <team_id>team_id</team_id>
	    <software>
	        <vendor_id>comecome</vendor_id>
	        <read_only_info>
	            <read_only_value key="apple-id">107571111</read_only_value>
	        </read_only_info>
	        <software_metadata app_platform="ios">
	            <versions>
	                <version string="1.0">
	                    <locales>
	                        <locale name="ko">
	                            <title>pushTest</title>
	                        </locale>
	                    </locales>
	                </version>
	            </versions>
	            <in_app_purchases>
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
					<in_app_purchase>
	                    <product_id>inapp1</product_id>
	                    <reference_name>kr.aaa.inapp1</reference_name>
	                    <type>consumable</type>
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
	                            <title>inapp1</title>
	                            <description>upload</description>
	                        </locale>
	                    </locales>
	                    <read_only_info>
	                        <read_only_value key="iap-status">Waiting for Screenshot</read_only_value>
	                    </read_only_info>
	                </in_app_purchase>
	            </in_app_purchases>
	        </software_metadata>
	    </software>
	</package>

`in_app_purchase` Element가 인앱 정보입니다. 우리는 이 정보를 수정하여 원하는 기간에 가격을 변경할 수 있습니다.

특정 인앱의 정보만 가져오길 원한다면 `subitemids` 옵션을 이용하면 됩니다.

	$ iTMSTransporter -m lookupMetadata -u username -p password -apple_id [appleid ex)10000200] -subitemtype InAppPurchase -subitemids [인앱 아이디 ex)kr.ss.inapp2,kr.aaa.inapp1] -destination destinationPath -v eXtreme

#### 인앱 가격 및 기간 변경하기

intervals에 기간을 추가해봅시다. 20일에 행사를 한다면 아래와 같이 값을 입력하면 됩니다.

	<intervals>
		<interval>
			<start_date>2016-01-17</start_date>
			<end_date>2016-01-20</end_date>
			<wholesale_price_tier>1</wholesale_price_tier>
		</interval>
		<interval>
			<start_date>2016-01-20</start_date>
			<end_date>2016-01-21</end_date>
			<wholesale_price_tier>2</wholesale_price_tier>
		</interval>
		<interval>
			<start_date>2016-01-21</start_date>
			<wholesale_price_tier>1</wholesale_price_tier>
		</interval>
	</intervals>

<div class="alert">주의 : 일정이 겹치지 않게 설정해야 합니다.</div>

위와 같이 변경하면, 다음 명령으로 메타 데이터를 업로드 합니다.

	$ iTMSTransporter -m upload -f [itmsp 파일 경로] -u username -p password -apple_id appleid -subitemtype InAppPurchase -v eXtreme -t DAV -success [성공 시 저장 경로] -failure [실패시 저장 경로]

업로드 한 뒤 itunesconnect에서 다음과 같이 확인할 수 있습니다.

<img src="https://farm2.staticflickr.com/1610/24324088142_589f5a5f66_c.jpg" width="800" height="297" alt=""><br/>

이제 itunesconnect에 들어가서 설정하지 않아도 빠르게 인앱을 변경할 수 있게 되었습니다.


### 참고 자료

* [Transporter 사용 설명서](http://help.apple.com/itc/transporteruserguide)

ps. 애플은 이미 다 만들어 놓았지만 스스로 찾아 써야한다는 결론.

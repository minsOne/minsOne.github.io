---
layout: post
title: "[iOS]Settings Bundle을 이용하여 라이센스를 설정 내에 표시하기"
description: ""
category: "Mac/iOS"
tags: [ios, opensource, license, settings, bundle, Acknowledgements]
---
{% include JB/setup %}

얼마전 tmax 발표를 보고 오픈소스 라이센스를 표시해놓아야 겠다는 생각이 많이 들었습니다. 앱 내에 UI를 만들고 넣어야 하나라는 생각이 들어서 설정에 추가하는 방식으로 선회를 하였습니다.

이렇게 말이죠.

<img src="https://farm2.staticflickr.com/1541/26575344152_e05c2c1876_c.jpg" width="240" height="214" alt="settings_bundle"><br/><br/>


위와 같이 설정에 정보를 추가하기 위해 프로젝트에 `Settings Bundle`를 추가하고, Root.plist 파일을 열고 다음 코드로 변경합니다.

<!--
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>PreferenceSpecifiers</key>
	<array>
		<dict>
			<key>Type</key>
			<string>PSGroupSpecifier</string>
			<key>Title</key>
			<string></string>
		</dict>
		<dict>
			<key>Type</key>
			<string>PSChildPaneSpecifier</string>
			<key>Title</key>
			<string>Acknowledgements</string>
			<key>File</key>
			<string>Acknowledgements</string>
		</dict>
	</array>
	<key>StringsTable</key>
	<string>Root</string>
</dict>
</plist>
-->

<script src="https://gist.github.com/minsOne/1faeb5c23f4068a5312fb74e2bbd1e65.js"></script>

<br/><br/>다음으로 라이센스를 표시하기 위한 화면을 만드는 `Acknowledgements.plist` 파일을 Settings Bundle에 추가합니다.

<!--
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>PreferenceSpecifiers</key>
	<array>
		<dict>
			<key>Type</key>
			<string>PSGroupSpecifier</string>
			<key>FooterText</key>
			<string>Description</string>
		</dict>
	</array>
	<key>StringsTable</key>
	<string>Acknowledgements</string>
</dict>
</plist>
-->

<script src="https://gist.github.com/minsOne/583130d820533af5b69e3a7360fa3516.js"></script>

<br/><br/>FooterText에 Description를 라이센스들로 대체하기 위해 en.lproj 파일 내에 Acknowledgements.strings 파일을 만듭니다. 그리고 아래와 같이 입력합니다.

<!--
"Description" =
"Copyright (c) 2009-2015 Matej Bukovinski\
\
Permission is hereby granted, free of charge, to any person obtaining a copy\
of this software and associated documentation files (the &quot;Software&quot;), to deal\
in the Software without restriction, including without limitation the rights\
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\
copies of the Software, and to permit persons to whom the Software is\
furnished to do so, subject to the following conditions:\
\
The above copyright notice and this permission notice shall be included in\
all copies or substantial portions of the Software.\
\
THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN\
THE SOFTWARE.\
";
-->

<script src="https://gist.github.com/minsOne/afd9ea5e3b8f48aad4bca5fc1baef9f6.js"></script>

<br/><br/>이제 앱을 디바이스에 설치한 후, 설정 앱을 재시작하고 설치된 앱으로 들어가면 처음 봤던 화면처럼 라이센스가 표시됩니다.

또한, 라이센스 화면을 생성해주는 [iOS-AcknowledgementGenerator](https://github.com/cvknage/iOS-AcknowledgementGenerator)를 이용하시면 좀 더 쉽고 깔끔하게 만드실 수 있습니다.

### 참고

* [Acknowledgements Settings.bundle Gist](https://gist.github.com/zetachang/4111314)
* [Apple Document](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/UserDefaults/Preferences/Preferences.html)

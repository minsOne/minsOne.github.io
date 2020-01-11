---
layout: post
title: "[iOS][Gem] XcodeProj Gem과 Graphviz를 이용하여 프로젝트의 Framework Dependency Diagram 그리기"
description: ""
category: "programming"
tags: [Ruby, Gem, XcodeProj, Graphviz, Framework]
---
{% include JB/setup %}

우리는 한 프로젝트가 어떤 프레임워크를 가져다 사용하고 있는지는 알지만 전체 프로젝트들이 어떻게 연결되어 있는지 알기가 힘듭니다. 프로젝트가 커지면 커질수록 어떻게 연결되어 있는지, 그리고 어떻게 프로젝트를 구성해야하는지 다이어그램를 그려야 하는데 그럴 수가 없습니다. 즉, 큰 그림을 볼 수 없습니다.

하지만 Xcode 프로젝트 분석을 도와주는 [Cocoapods의 **XcodeProj**](https://github.com/CocoaPods/Xcodeproj) Gem과 다이어그램을 그려주는 [**Graphviz**](https://www.graphviz.org/) 을 이용해서 스크립트를 만들려고 합니다.

다음 순서대로 진행하여 다이어그램을 만들 것입니다.

1. XcodeProj, Graphviz 설치하기
2. 모든 XcodeProject 찾기
3. Framework 프로젝트에서 사용하는 Framework 추출하기
4. Graphviz를 이용하여 그리기
5. App 프로젝트까지 포함한 다이어그램 그리기

여기에서 [DigitClockinSwift](https://github.com/minsOne/DigitClockInSwift)라는 제 프로젝트를 예제로 설명합니다.

## 1. XcodeProj, Graphviz 설치하기

XcodeProj는 다음과 같이 설치합니다.

```
$ [sudo] gem install xcodeproj
```

Graphviz는 다음과 같이 설치합니다.

```
$ brew install graphviz
```

## 2. 모든 XcodeProject 찾기

아직 ruby가 익숙하지 않은 관계로 Shell 스크립트로 `*.xcodeproj` 폴더를 모두 찾습니다.

```
$ find . -name "*.xcodeproj" -not -path "./Carthage/*"

# Output
./DigitClockinSwift.xcodeproj
./MainFeature/MainFeature.xcodeproj
./MainFeature/MainFeature/Dependencies/Settings/Settings.xcodeproj
./MainFeature/MainFeature/Dependencies/Clock/Clock.xcodeproj
./MainFeature/MainFeature/Dependencies/Clock/Dependencies/ClockTimer/ClockTimer.xcodeproj
./Resources/Resources.xcodeproj
./Library/Library.xcodeproj
./Analytics/Analytics.xcodeproj
```

Framework 간의 연결을 먼저 확인할 예정이므로 앱 프로젝트는 우선 제외합니다.(DigitClockinSwift.xcodeproj)


## 3. 프로젝트에서 사용하는 Framework 추출하기

이제 **XcodeProj** Gem을 이용하여 각 프레임워크들이 사용하는 프레임워크를 찾습니다.

```
# search_dependency_framework.rb
require 'xcodeproj'

framework_paths = ["./MainFeature/MainFeature.xcodeproj",
"./MainFeature/MainFeature/Dependencies/Settings/Settings.xcodeproj",
"./MainFeature/MainFeature/Dependencies/Clock/Clock.xcodeproj",
"./MainFeature/MainFeature/Dependencies/Clock/Dependencies/ClockTimer/ClockTimer.xcodeproj",
"./Resources/Resources.xcodeproj",
"./Library/Library.xcodeproj",
"./Analytics/Analytics.xcodeproj"]

puts "digraph G {"

framework_paths.each do |path|
	project = Xcodeproj::Project.open(path)
	if project.targets.first.frameworks_build_phases.files.empty? == true or
	 project.targets.first.product_type != "com.apple.product-type.framework"
		next
	end
	project.targets.first.frameworks_build_phases.files.each do |framework|
		framework.display_name.sub!("\.framework", "")
		puts "\"#{framework.display_name}\" -> \"#{project.targets.first.product_name}\""
	end
end
puts "}"
```

위 코드를 만들어 실행하면 다음과 같은 결과를 얻습니다.

```
digraph G {
"Resources" -> "Settings"
"RIBs" -> "Settings"
"Settings" -> "Clock"
"RIBs" -> "Clock"
"Library" -> "ClockTimer"
"Library" -> "Resources"
"GoogleUtilities" -> "Analytics"
"FirebaseCoreDiagnostics" -> "Analytics"
"libsqlite3.0.tbd" -> "Analytics"
"GoogleDataTransport" -> "Analytics"
"Firebase" -> "Analytics"
"FIRAnalyticsConnector" -> "Analytics"
"FirebaseAnalytics" -> "Analytics"
"FirebaseInstanceID" -> "Analytics"
"nanopb" -> "Analytics"
"FirebaseCore" -> "Analytics"
"GoogleAppMeasurement" -> "Analytics"
"GoogleDataTransportCCTSupport" -> "Analytics"
"StoreKit" -> "Analytics"
"Clock" -> "MainFeature"
"Settings" -> "MainFeature"
}
```

## 4. Graphviz를 이용하여 그리기

위에서 출력된 결과를 Graphviz를 이용해 다이어그램을 만듭니다.

```
$ ruby search_dependency_framework.rb >> input.dot && dot -Tpdf input.dot -o digraph.pdf
```

<p style="text-align:center;"><embed src="{{ site.production_url }}/image/2020/only_framework_dependency_digraph_for_DigitClockInSwift.pdf" type="application/pdf" height="500px" width="100%"></p><br/> 

## 5. App 프로젝트까지 포함한 다이어그램 그리기

이제 앱까지 연결한 다이어그램을 만들어 보겠습니다.

앱 프로젝트에서 사용하는 프레임워크를 추출해봅시다.

```
# search_app_framework_dependency.rb
require 'xcodeproj'

app_path = "./DigitClockinSwift.xcodeproj"

puts "digraph G {"
project = Xcodeproj::Project.open(app_path)

if project.targets.first.product_type == "com.apple.product-type.application"
	project.frameworks_group.children.each do |child|
		child.display_name.sub!("\.framework", "")
		puts "\"#{child.display_name}\" -> \"#{project.targets.first.product_name}\""
	end
end

puts "}"
```

위 코드를 만들어 실행하면 다음과 같은 결과를 얻습니다.

```
digraph G {
"RxRelay" -> "DigitClockinSwift"
"RIBs" -> "DigitClockinSwift"
"RxSwift" -> "DigitClockinSwift"
"MainFeature" -> "DigitClockinSwift"
"Clock" -> "DigitClockinSwift"
"Settings" -> "DigitClockinSwift"
"Library" -> "DigitClockinSwift"
"Resources" -> "DigitClockinSwift"
"Analytics" -> "DigitClockinSwift"
}
```

이제 프레임워크 프로젝트의 다이어그램과 앱 프로젝트의 다이어그램을 합쳐봅시다.

```
# dependency_framework_digraph.rb
require 'xcodeproj'

framework_paths = [
"./MainFeature/MainFeature.xcodeproj",
"./MainFeature/MainFeature/Dependencies/Settings/Settings.xcodeproj",
"./MainFeature/MainFeature/Dependencies/Clock/Clock.xcodeproj",
"./MainFeature/MainFeature/Dependencies/Clock/Dependencies/ClockTimer/ClockTimer.xcodeproj",
"./Resources/Resources.xcodeproj",
"./Library/Library.xcodeproj",
"./Analytics/Analytics.xcodeproj"
]

app_path = "./DigitClockinSwift.xcodeproj"

puts "digraph G {"

graphes = []

framework_paths.each do |path|
	project = Xcodeproj::Project.open(path)
	if project.targets.first.frameworks_build_phases.files.empty? == true or
	 project.targets.first.product_type != "com.apple.product-type.framework"
		next
	end
	project.targets.first.frameworks_build_phases.files.each do |framework|
		framework.display_name.sub!("\.framework", "")
		graphes.append("\t\"#{framework.display_name}\" -> \"#{project.targets.first.product_name}\"")
	end
end

project = Xcodeproj::Project.open(app_path)
if project.targets.first.product_type == "com.apple.product-type.application"
	project.frameworks_group.children.each do |child|
		child.display_name.sub!("\.framework", "")
		graphes.append("\t\"#{child.display_name}\" -> \"#{project.targets.first.product_name}\"")
	end
end

graphes.sort.each do |graph|
	puts graph
end

puts "}"
```

위 코드를 실행하면 다음과 같은 결과를 얻습니다.

```
digraph G {
	"Analytics" -> "DigitClockinSwift"
	"Clock" -> "DigitClockinSwift"
	"Clock" -> "MainFeature"
	"FIRAnalyticsConnector" -> "Analytics"
	"Firebase" -> "Analytics"
	"FirebaseAnalytics" -> "Analytics"
	"FirebaseCore" -> "Analytics"
	"FirebaseCoreDiagnostics" -> "Analytics"
	"FirebaseInstanceID" -> "Analytics"
	"GoogleAppMeasurement" -> "Analytics"
	"GoogleDataTransport" -> "Analytics"
	"GoogleDataTransportCCTSupport" -> "Analytics"
	"GoogleUtilities" -> "Analytics"
	"Library" -> "ClockTimer"
	"Library" -> "DigitClockinSwift"
	"Library" -> "Resources"
	"MainFeature" -> "DigitClockinSwift"
	"RIBs" -> "Clock"
	"RIBs" -> "DigitClockinSwift"
	"RIBs" -> "Settings"
	"Resources" -> "DigitClockinSwift"
	"Resources" -> "Settings"
	"RxRelay" -> "DigitClockinSwift"
	"RxSwift" -> "DigitClockinSwift"
	"Settings" -> "Clock"
	"Settings" -> "DigitClockinSwift"
	"Settings" -> "MainFeature"
	"StoreKit" -> "Analytics"
	"libsqlite3.0.tbd" -> "Analytics"
	"nanopb" -> "Analytics"
}
```

위에서 출력된 결과를 Graphviz를 이용해 다이어그램을 그립니다.

```
$ ruby dependency_framework_digraph.rb >> input.dot && dot -Tpdf input.dot -o digraph.pdf
```

<p style="text-align:center;"><embed src="{{ site.production_url }}/image/2020/framework_dependency_digraph_for_DigitClockInSwift.pdf" type="application/pdf" height="500px" width="100%"></p><br/> 

# 참고자료
* [WebGraphviz](http://www.webgraphviz.com/)
* [Graphviz](http://www.graphviz.org/)
* [Graphviz 소개](https://narusas.github.io/2019/01/25/Graphviz.html)
* Gem - [XcodeProj](https://github.com/CocoaPods/Xcodeproj)

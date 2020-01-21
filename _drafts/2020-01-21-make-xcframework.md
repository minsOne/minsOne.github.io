---
layout: post
title: "[Xcode] XCFramework 만들기"
description: ""
category: ""
tags: []
---
{% include JB/setup %}

WWDC 2019에서 [**Binary Frameworks in Swift**](https://developer.apple.com/videos/play/wwdc2019/416/) 라는 세션으로 XCFramework를 발표했습니다.

xcodebuild archive -scheme XCFrameworkTest -archivePath "./build/ios.xcarchive" -sdk iphoneos SKIP_INSTALL=NO
xcodebuild archive -scheme XCFrameworkTest -archivePath "./build/ios_sim.xcarchive" -sdk iphonesimulator SKIP_INSTALL=NO
xcodebuild archive -scheme XCFrameworkTest -archivePath "./build/mac.xcarchive" SKIP_INSTALL=NO

xcodebuild -create-xcframework \
    -framework "./build/ios.xcarchive/Products/Library/Frameworks/XCFrameworkTest.framework" \
    -framework "./build/ios_sim.xcarchive/Products/Library/Frameworks/XCFrameworkTest.framework" \
    -output "./build/XCFrameworkExample.xcframework"

///
xcodebuild -create-xcframework \
    -framework "./build/ios.xcarchive/Products/Library/Frameworks/XCFrameworkExample.framework" \
    -framework "./build/ios_sim.xcarchive/Products/Library/Frameworks/XCFrameworkExample.framework" \
    -framework "./build/macos.xcarchive/Products/Library/Frameworks/XCFrameworkExample.framework" \
    -output "./build/XCFrameworkExample.xcframework"


## 참고자료
https://habr.com/ru/company/true_engineering/blog/475816/
https://medium.com/trueengineering/xcode-and-xcframeworks-new-format-of-packing-frameworks-ca15db2381d3

https://appspector.com/blog/xcframeworks
https://stackoverflow.com/questions/47103464/archive-in-xcode-appears-under-other-items
https://instabug.com/blog/ios-binary-framework/
https://instabug.com/blog/swift-5-module-stability-workaround-for-binary-frameworks/

https://medium.com/@dcortes22/how-to-create-a-xcframework-2a166445a898
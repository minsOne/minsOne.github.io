---
layout: post
title: "[SwiftUI][iOS] Framework에 있는 Custom Font을 등록하여 사용하기"
description: ""
category: "iOS/Mac"
tags: [SwiftUI, iOS, Font, CTFontManagerRegisterFontsForURL, View, AppDelegate]
---
{% include JB/setup %}

특정 디자인을 사용하기 위해 Custom Font를 사용해야하는 경우가 있습니다. 보통은 Plist에 등록을 해서 사용하라고 하지만, 다운받은 Font 또는 다른 Framework에 있는 Plist에 등록할 수 없습니다.

iOS 4.1 부터 현재 프로세스를 사용하고 있는 동안 등록하여 사용할 수 있는 `CTFontManagerRegisterFontsForURL` 함수가 있습니다. 이 함수를 이용하여 Framework에 있는 Font를 읽어와 특정 View에서 사용할 수 있습니다.

```
// Font.Framework
private final class R {}

func registerFont() {
  guard let url = Bundle(for: R.self).url(forResource: "\(custom_font_file_name)", withExtension: "ttf"),
    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil) 
    else { print("failed to regist \(custom_font_file_name) font");return }
}
```

그러면 AppDelegate에서 해당 함수를 호출하여 Font를 등록 한 후에 각 화면들에서 해당 폰트를 사용할 수 있습니다.

```
import Font

class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    Font.registerFont()
    ...
  }
}

struct SomeView: View {
  var body: some View {
    Text("3333")
        .font(Font.custom("custom font name", size: 100))
  }
}
```

만약 해당 Font를 등록했지만 이름이 무엇인지 알기 어려울 때, 모든 Font를 검색하여 찾을 수도 있습니다.

```
class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
  	Font.registerFont()

    for family in UIFont.familyNames {
      print(family)
      for names in UIFont.fontNames(forFamilyName: family) {
        print"(=> \(names)")
      }
    }
}
```

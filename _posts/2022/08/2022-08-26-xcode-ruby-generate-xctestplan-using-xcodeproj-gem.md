---
layout: post
title: "[Xcode][Ruby] Xcodeproj Gem을 활용하여 Xcode Test Plans 생성 스크립트 만들기"
tags: [Xcode, Ruby, Gem, Cocoapods, Xcodeproj, xctestplan]
---
{% include JB/setup %}

들어가기 전에 여기에서 사용하는 프로젝트의 구조는 다음과 같습니다.

```
├── Application.xcworkspace
├── Projects
│   ├── Application
│   │   └── Application.xcodeproj
│   ├── ModuleA
│   │   └── ModuleA.xcodeproj
│   ├── ModuleB
│   │   └── ModuleB.xcodeproj
│   └── ModuleC
│       └── ModuleC.xcodeproj
└── TestPlan
    └── FullTest.xctestplan
```

------

Xcode 11에서 테스트를 모아서 관리하는 Xcode Test Plans 기능을 출시하였습니다. 참고 : [WWDC 2019 - Testing in Xcode](https://developer.apple.com/videos/play/wwdc2019/413/)

해당 기능을 통해 여러 프로젝트의 테스트 타겟을 통합하여 테스트 관리가 가능합니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2022/08/20220826_01.png" style="width: 800px"/>
</p><br/>

해당 xctestplan 파일의 소스를 살펴보면 다음과 같이 되어 있습니다.

```json
{
  "configurations" : [
    {
      "id" : "B26C50E8-C293-44A3-BE07-6818CDECD057",
      "name" : "Configuration 1",
      "options" : {

      }
    }
  ],
  "defaultOptions" : {
    "testTimeoutsEnabled" : true
  },
  "testTargets" : [
    {
      "parallelizable" : true,
      "target" : {
        "containerPath" : "container:Application.xcodeproj",
        "identifier" : "CBAB91A528B51F9400804137",
        "name" : "ApplicationTests"
      }
    },
    {
      "parallelizable" : true,
      "target" : {
        "containerPath" : "container:Application.xcodeproj",
        "identifier" : "CBAB91AF28B51F9400804137",
        "name" : "ApplicationUITests"
      }
    },
    {
      "parallelizable" : true,
      "target" : {
        "containerPath" : "container:..\/ModuleA\/ModuleA.xcodeproj",
        "identifier" : "CBAB91FD28B520AC00804137",
        "name" : "ModuleATests"
      }
    },
    {
      "parallelizable" : true,
      "target" : {
        "containerPath" : "container:..\/ModuleB\/ModuleB.xcodeproj",
        "identifier" : "CBAB91E928B520A400804137",
        "name" : "ModuleBTests"
      }
    },
    {
      "parallelizable" : true,
      "target" : {
        "containerPath" : "container:..\/ModuleC\/ModuleC.xcodeproj",
        "identifier" : "CBAB921928B520F400804137",
        "name" : "ModuleCTests"
      }
    }
  ],
  "version" : 1
}
```

`containerPath`의 상대경로는 어떤 프로젝트의 스킴에서 실행하느냐에 따라 경로가 결정됩니다. 

위의 정보에서는 `containerPath` 경로가 Application에서 시작하므로, xctestplan이 정상적으로 보여집니다.

만약에 ModuleA 프로젝트의 ModuleA 스킴에서 `FullTest.xctestplan`을 테스트 플랜으로 가지게 되면, `ApplicationTests`과 `ApplicationUITests` 테스트 타겟은 missing으로 출력이 됩니다.

<p style="text-align:center;">
<img src="{{ site.production_url }}/image/2022/08/20220826_02.png" style="width: 800px"/>
<img src="{{ site.production_url }}/image/2022/08/20220826_03.png" style="width: 800px"/>
</p><br/>

missing으로 표시되는 테스트는 수행되지 않습니다.

따라서 어떤 스킴에서 Test Plans을 수행할 것인지 결정해야 합니다. 여기에선 Application 프로젝트의 Application 스킴을 기반으로 작업할 것입니다.

다음으로, xctestplan의 `identifier`를 알아봅시다. `identifier`는 테스트 타겟의 UUID를 나타냅니다. 이 정보를 얻기 위해서는 `xcodeproj`의 `project.pbxproj` 파일을 열어서 테스트 타겟의 정보를 분석해야 합니다. 이 부분은 `CocoaPods/Xcodeproj` Gem [Github](https://github.com/CocoaPods/Xcodeproj)을 활용합니다.

다음과 같이 Ruby 파일을 작성합니다.

```ruby
# FileName : generate_xctestplan.rb
require 'xcodeproj'

cmd = "find Projects -type d -name '*.xcodeproj'"
value = `#{cmd}`
value.split(/\n+/).sort.each { |item|
  project_path = item
  project = Xcodeproj::Project.open(project_path)
  project.targets.each do |target|
    if target.product_type == "com.apple.product-type.bundle.unit-test"
      puts "#{project_path}, #{target.name}, #{target.uuid}"
    end
  end
}
```

위 파일을 실행하면 다음과 같이 출력됩니다.

```shell
$ ruby generate_xctestplan.rb
Projects/Application/Application.xcodeproj, ApplicationTests, CBAB91A528B51F9400804137
Projects/ModuleA/ModuleA.xcodeproj, ModuleATests, CBAB91FD28B520AC00804137
Projects/ModuleB/ModuleB.xcodeproj, ModuleBTests, CBAB91E928B520A400804137
Projects/ModuleC/ModuleC.xcodeproj, ModuleCTests, CBAB921928B520F400804137
```

프로젝트 경로, 테스트 타겟 이름과 UUID 정보를 추출하였습니다. 이 정보를 이용하여 xctestplan의 `testTargets` 항목을 생성하는 코드를 만들 수 있습니다.

```ruby
# FileName : generate_xctestplan.rb
require 'xcodeproj'

def makeTestTarget(target, path)
  output = "\n    {"
  output += "\n      \"parallelizable\" : true,"
  output += "\n      \"target\" : {"
  if path.include? "Application.xcodeproj"
    output += "\n        \"containerPath\" : \"container:Application.xcodeproj\","
  else
    output += "\n        \"containerPath\" : \"container:..\\/#{path.gsub("/", "\\/")}\","
  end
  output += "\n        \"identifier\" : \"#{target.uuid}\","
  output += "\n        \"name\" : \"#{target.name}\""
  output += "\n      }"
  output += "\n    },"

  return output
end

output = <<HEREDOC
{
  "configurations" : [
    {
      "id" : "36E28BCA-F3CC-4EBF-A90F-EE0B8DF0AA8A",
      "name" : "Configuration 1",
      "options" : {}
    }
  ],
  "defaultOptions" : {
    "testTimeoutsEnabled" : true
  },
  "testTargets" : [
HEREDOC

cmd = "find Projects -type d -name '*.xcodeproj'"
value = `#{cmd}`

value.split(/\n+/).sort.each { |item|
  project_path = item
  project = Xcodeproj::Project.open(project_path)
  project.targets.each do |target|
    if target.product_type.include? "com.apple.product-type.bundle.unit-test" 
      output += makeTestTarget(target, project_path)
    elsif target.product_type.include? "com.apple.product-type.bundle.ui-testing"
      output += makeTestTarget(target, project_path)
    end
  end
}

output += "\n  ],
  \"version\" : 1
}
"

puts output
```

이 파일을 실행하면 xctestplan의 JSON 형식을 따르는 데이터 형태로 출력됩니다.

```shell
$ ruby generate_xctestplan.rb
{
  "configurations" : [
    {
      "id" : "36E28BCA-F3CC-4EBF-A90F-EE0B8DF0AA8A",
      "name" : "Configuration 1",
      "options" : {}
    }
  ],
  "defaultOptions" : {
    "testTimeoutsEnabled" : true
  },
  "testTargets" : [

    {
      "parallelizable" : true,
      "target" : {
        "containerPath" : "container:Application.xcodeproj",
        "identifier" : "CBAB91A528B51F9400804137",
        "name" : "ApplicationTests"
      }
    },
    {
      "parallelizable" : true,
      "target" : {
        "containerPath" : "container:Application.xcodeproj",
        "identifier" : "CBAB91AF28B51F9400804137",
        "name" : "ApplicationUITests"
      }
    },
    {
      "parallelizable" : true,
      "target" : {
        "containerPath" : "container:..\/ModuleA\/ModuleA.xcodeproj",
        "identifier" : "CBAB91FD28B520AC00804137",
        "name" : "ModuleATests"
      }
    },
    {
      "parallelizable" : true,
      "target" : {
        "containerPath" : "container:..\/ModuleB\/ModuleB.xcodeproj",
        "identifier" : "CBAB91E928B520A400804137",
        "name" : "ModuleBTests"
      }
    },
    {
      "parallelizable" : true,
      "target" : {
        "containerPath" : "container:..\/ModuleC\/ModuleC.xcodeproj",
        "identifier" : "CBAB921928B520F400804137",
        "name" : "ModuleCTests"
      }
    },
  ],
  "version" : 1
}
```

이제 출력된 결과를 `TestPlan/FullTest.xctestplan` 파일에 덮어씌웁니다.

```
$ ruby generate_xctestplan.rb > TestPlan/FullTest.xctestplan
```

그리고 Xcode에서 FullTest.xctestplan 파일을 열어 정상적으로 노출되는지 확인합니다. 또한, xcodebuild test를 이용하여 생성한 FullTest.xctestplan으로 잘 동작하는지 확인합니다.

```
$ xcodebuild test -scheme Application -testPlan FullTest -destination 'platform=iOS Simulator,OS=16.0,name=iPhone 13'
```

## 정리

* [Xcodeproj](https://github.com/CocoaPods/Xcodeproj)를 활용하여 프로젝트 파일에서 정보를 추출하고, 그 정보를 이용하여 xctestplan 파일을 생성
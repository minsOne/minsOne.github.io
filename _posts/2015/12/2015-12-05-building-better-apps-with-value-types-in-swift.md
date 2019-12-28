---
layout: post
title: "[번역][Swift]값 타입(Value Types)으로 더 나은 앱 만들기"
description: ""
category: "programming"
tags: [apple, wwdc, protocol, value, reference, type, reference semantics, value semantics, copy, instance, struct, class, object, mutable, immutable, haskell]
---
{% include JB/setup %}

이 영상 번역 글은 [Building Better Apps with Value Types in Swift](https://developer.apple.com/videos/play/wwdc2015-414/)의 비공식 영상 번역글이며 Apple에서 보증, 유지 또는 감독하지 않습니다. 공식 영상을 보시려면 [Apple Developer](https://developer.apple.com)을 방문하세요.

---

번역에 오역이 있거나 누락된 부분이 있다면 [Pull Request](https://github.com/minsOne/minsOne.github.io/pulls) 또는 댓글로 남겨주시면 감사하겠습니다.

---

### 값 타입으로 더 나은 앱 만들기

<br/><img src="{{ site.production_url }}/image/flickr/23537867315_5ca500c6d8_z.jpg" width="640" height="402" alt="ValueType00"><br/>

안녕하세요. 저는 Doug Gregor입니다. 동료인 Bill Dudney 과, Swift에서 값 타입으로 더 나은 앱을 만드는 것을 이야기하려고 합니다. 

<br/><img src="{{ site.production_url }}/image/flickr/23455429071_f9f5356729_z.jpg" width="640" height="399" alt="ValueType01"><br/>

처음에, 참조 의미론 이야기로 시작하고, 그러고 나서 참조 의미론 형태 문제 일부를 해결책으로 불변성을 통해 탐구할 것입니다.

값 의미론과 값 타입으로 들어가서, 어떻게 동작하는지, 특히 Swift에서 어떻게 동작하는지, 그러고 나서 연습에서 값 타입 사용을 이야기하고, Swift 내에서 참조 타입과 값 타입을 혼용을 이야기할 것입니다. 시작합시다. 

<br/><img src="{{ site.production_url }}/image/flickr/23242118280_3f05806641_z.jpg" width="640" height="401" alt="ValueType02"><br/>

참조 의미론입니다. Swift 세상에서 참조 의미론에 들어가는 방법은 클래스를 정의하는 것입니다. 

<br/><img src="{{ site.production_url }}/image/flickr/22910786413_b407586179_z.jpg" width="640" height="401" alt="ValueType03"><br/>

매우 간단한 temperature 클래스가 있습니다. celsius에다 temperature 값을 저장합니다. 멋진 계산 속성인 fahrenheit를 가지길 원하고, 올바른 단위로 항상 얻을 수 있습니다.

간결하고 추상적인 temperature 버전입니다. 

<br/><img src="{{ site.production_url }}/image/flickr/23511786656_85484cd3af_z.jpg" width="640" height="399" alt="ValueType04"><br/>

몇 가지 간단한 코드에 사용해봅시다. home 인스턴스와 temperature 인스턴스를 만듭니다.

thermostat를 화씨 75도 설정합니다. 이제 정했고, 저녁 시간이 다가오고 있어서 연어를 굽고자 합니다.

그래서 oven을 화씨 425도 설정하고 구웠습니다. 

<br/><img src="{{ site.production_url }}/image/flickr/22909609334_f73039e484_z.jpg" width="640" height="401" alt="ValueType05"><br/>

저리 가세요. 여기가 왜 이렇게 뜨겁죠? 무슨 일인가요? 여러분은 무슨 일이 있었는지 압니다. 의도치 않은 공유 사례에 부닥쳤습니다.

<br/><img src="{{ site.production_url }}/image/flickr/22909609394_e55c87a5e8_z.jpg" width="640" height="401" alt="ValueType06"><br/>

객체 그래프 생각입니다. 집이 있습니다. 집에는 thermostat과 oven이 있습니다.

temp가 가리키는 temperature 객체를 가집니다. thermostat를 설정할 때, temp와 같은 객체로 연결되어 있습니다.

<br/><img src="{{ site.production_url }}/image/flickr/23511786836_71007d32d1_z.jpg" width="640" height="400" alt="ValueType07"><br/>

변경할 때까지는 좋아 보이며, 이제 의도치 않거나 예상치 못한 공유는 thermostat를 화씨 425도로 설정하게 합니다. 현시점에서 이미 끝났지만, thermostat를 oven에 묶어서 추가해봅시다. 우린 이미 잃었잖아요. 우리는 무엇을 잘못 했나요?

<br/><img src="{{ site.production_url }}/image/flickr/23429357292_516a9c820b_z.jpg" width="640" height="402" alt="ValueType08"><br/>

참조 의미론이 있는 세상에서 공유를 막기 위해 복사합니다. 

<br/><img src="{{ site.production_url }}/image/flickr/22910786683_e2e8715cf5_z.jpg" width="640" height="401" alt="ValueType09"><br/>

temperature를 화씨 75도 설정을 다시 합니다. thermostat의 temperature을 설정할 때 복사합니다. 새로운 객체를 얻습니다. 

그것은 thermostate의 temperature를 가리키는 것입니다. temp 변수의 temperature를 변경해도 영향 미치지 않습니다.

<br/><img src="{{ site.production_url }}/image/flickr/22910786833_07c12923c7_z.jpg" width="640" height="401" alt="ValueType10"><br/>

좋습니다. oven의 temperature를 설정하고, 또 다른 사본을 만듭니다.

이제는, 기술적으로, 마지막 사본은 필요 없습니다. 추가 사본을 만들기 위해 힙에 메모리 할당하는 시간을 비효율적으로 낭비합니다.

그러나 지난번에 사본을 태워 잃어버렸기 때문에, 안전하게 하고자 합니다. 어서요, 금요일 세션이잖아요, 쉬자고요! 

<br/><img src="{{ site.production_url }}/image/flickr/23429357502_347aacb54f_z.jpg" width="640" height="401" alt="ValueType11"><br/>

우리는 방어 복사로 이것을 참조하고, 여기서 우리는 필요한 것을 알고 있으므로 복사할 수 없지만, 만약에 지금 또는 언젠가 필요하면, 이 문제를 디버깅하는데 정말로 어렵습니다. 그래서 .copy로 언제든지 oven에서 temperature를 어딘가에 할당했다는 것을 너무 쉽게 잊습니다. 대신, oven에다 올바른 방법으로 구울 것입니다. 

<br/><img src="{{ site.production_url }}/image/flickr/23511787096_a7c059d20d_z.jpg" width="640" height="401" alt="ValueType12"><br/>

당연히 thermostat에다 정확하게 같은 것을 합니다. 이제 아주 많은 boilerplate가 있고, 이를 복사하고 붙여넣습니다. 그리고 조만간, 언어 특징에 관해 문을 두드리고 물어볼 것입니다.

<br/><img src="{{ site.production_url }}/image/flickr/23455429671_190720faff_z.jpg" width="640" height="399" alt="ValueType13"><br/>

그리고 Cocoa와 Objective-C에서 복사를 참조하는 곳에 관해 이야기합시다. Cocoa에서, 여러분은 NSCopying 프로토콜의 개념을 알고 있습니다. 그리고 복사를 의미하는 성문화(codifies), 그리고 많은 데이터 타입과 NSString, NSArray, NSURLRequest, 기타 등등을 알고 있습니다. 이것들은 복사하여 안전하므로 NSCopying에 적합합니다.

복사가 필요한 시스템에 있으며, 그리고 매우 매우 타당한 이유로 많은 방어 복사를 봅니다. 그래서 NSDictionary는 dictionary에 있는 key를 방어 복사(defensively copy)합니다. 왜 그럴까요? NSDictionary key를 얻어 삽입하고 나서 hash 값이 바뀌는 방법으로 변경된다면, 모든 NSDictionary의 내부 변수는 깨지고 버그는 우리에게 책임을 지웁니다. 우린 이런 것을 정말로 원치 않습니다.

우리가 진짜로 하는 것은 NSDictionary에서 방어 복사(defensive copy)입니다. 이 시스템에서는 정답이지만, 추가 복사하므로 운 나쁘게도 성능 하락이 있습니다. 물론 모든 방법을 Objective-C에 copy 속성과 언어 레벨로 끌어내리며 Objective-C는 모든 단일 할당에서 이들 문제를 막으려고 노력하기 위해 방어 복사를 수행하고, 모든 방어 복사는 이를 돕지만, 충분치 않습니다. 여전히 많은 버그가 있습니다.

<br/><img src="{{ site.production_url }}/image/flickr/23169907919_0ea76e75c1_z.jpg" width="640" height="401" alt="ValueType14"><br/>

그래서 이들 참조 의미론인 문제와 변화가 있습니다. 아마도 여기 그 문제는 참조 의미론이 아니지만, 변화 그 자신일 수 있습니다. 아마 우리는 불변 데이터 구조와 참조 의미론의 세상으로 이동해야 할지도 모릅니다.

<br/><img src="{{ site.production_url }}/image/flickr/23511787176_cb427e9624_z.jpg" width="640" height="399" alt="ValueType15"><br/>

함수형 프로그래밍 커뮤니티에 누군가와 이야기한다면, '우리는 수십 년간 이것을 해왔다'라고 말할 것입니다. 그리고 이것은 향상하게 시킵니다. 그래서 부작용이 없는 세상에서 의도치 않은 부작용은 있을 수 없으며, 불변 참조 의미론은 시스템에서 일관적인 방법으로 동작합니다. 

temperature 예제를 실행해서 의도하지 않은 결과는 없었습니다. 불변성은 몇 가지 단점이 있습니다. 이는 몇 가지 어색한 인터페이스로 이끌 수 있고, 일부는 단지 언어 작업 방법이고, 일부는 변경할 수 있는 세상에서 살고 있는데 익숙한 것이고, 그리고 우리는 상태와 변경 상태에 관해 생각하고, 순수한 불변 세상에서의 생각은 때론 우리를 조금 이상하게 할 수 있습니다.

또한, 머신 모델에 이르기까지 효율적인 매칭 문제가 있습니다. 언젠가는 여러분은 기계어를 파야 하고, 안정적인 register와 cache, memory 그리고 storage가 있는 CPU에서 실행합니다.

불변의 알고리즘에서 효율적인 수준(level efficiently)까지 대응하는 것이 항상 쉽지 않습니다. 몇 가지 이야기합시다.

<br/><img src="{{ site.production_url }}/image/flickr/22910787073_88f46d8f25_z.jpg" width="640" height="399" alt="ValueType16"><br/>

temperature 클래스를 불변하게 하여서 더 안전하게 만들려고 합니다. 그래서 저장 속성인 celsius를 var를 let으로 변경했고, 이제는 변경할 수 없습니다. 그러고 나서 fahrenheit 계산 속성은 setter를 없앱니다. 

아무리 애써봐도 temperature의 상태를 변경할 수 없습니다. 편의(convenience)를 위한 여러 initializer를 추가합니다. 

<br/><img src="{{ site.production_url }}/image/flickr/22910787023_30c4a055ec_z.jpg" width="640" height="399" alt="ValueType17"><br/>

어색함에 관해 이야기합시다.

어색한 불변 인터페이스입니다. 이전에 oven의 temperature를 화씨 10도 돌리길 원했다면, 이것은 간단한 기능입니다.

+= 10. 이게 전부입니다.

변경을 제거하려면 어떻게 해야 할까요? oven에 있는 temperature 객체를 가지고, 새로운 값을 가진 다른 temperature 객체를 만듭니다.

이것은 조금 더 어색합니다. 더 많은 코드가 있고, 힙에 다른 객체를 할당하는 시간을 낭비합니다. 그러나 사실은, 변경된 oven 자체를 할당했기 때문에 불변성 수용(embraced immutability)이 없습니다.

불변 참조 타입 개념을 받아들인다면, 새로운 집에다 새로운 오븐에 새로운 temperature를 만들어 넣을 것입니다. 그래서 좀 더 이론적 수학 문제를 해봅시다.

불변 참조 타입 개념을 여기 도처에다 수용한다면, 새로운 home에다 새로운 oven을 넣고 새로운 temperature를 만들어 넣을 것입니다. 어색합니다. 그래서 조금 더 이론을 가지고 몇 가지 수학을 해봅시다.

<br/><img src="{{ site.production_url }}/image/flickr/23511787316_0f7c8f5e62_z.jpg" width="640" height="399" alt="ValueType18"><br/>

에라토스테네스의 체는 소수를 계산하는 고대 알고리즘입니다. 이것은 변경을 사용하고 실제로 흙에 막대기로 그리기 적합한 그 자체를 빌려줍니다. 이것은 Swift로 변경 구현한 버전입니다. 우리는 이것을 설명하고 여러분은 이 뒤에 있는 아이디어를 얻습니다.

첫 번째 할 일로 배열을 만듭니다. 배열을 변경할 것이기 때문에 var로 통지합니다. 배열은 첫 번째 소수인 2부터라고 통지하고, 계산을 원하는 어떤 숫자까지 올라갑니다. 20을 계산할 것입니다. 이제 바깥 loop로 배열에서 다음 숫자를 뽑습니다. 이 숫자는 소수 P입니다. 내부 loop는 P 배수를 모두 지나가면서 0으로 설정하여 배열에서 지웁니다. 소수의 배수가 있다면 소수가 아니기 때문입니다. 바깥 loop로 돌아가서, 소수인 다음 수를 얻습니다.

배열에 이 숫자의 모든 배수를 지웁니다. 매우, 매우 간단한 알고리즘입니다. 흙에서 막대기로 생각해보세요.

숫자를 지웁니다. 모든 반복이 끝나면, 여기로 내려갑니다.

그리고 마지막으로 간단한 동작을 하는데, 배열에서 지우지 않은 모든 것이 결과 부분입니다.

<br/><img src="{{ site.production_url }}/image/flickr/23429357832_b752aebfd4_z.jpg" width="640" height="400" alt="ValueType19"><br/>

그래서 filter를 수행합니다. 전적으로 변경을 기반으로 한 간단한 알고리즘입니다. 변경 없는 세상에서 나타낼 수 없다는 의미가 아닙니다. 할 수 있습니다. 

<br/><img src="{{ site.production_url }}/image/flickr/22910787253_644b0f300c_z.jpg" width="640" height="403" alt="ValueType20"><br/>

이를 하기 위해, 우리는 Haskell을 사용할 것입니다. 순수한 함수형 언어이기 때문입니다. 나는 사람들이 좋아할 거라고 알고 있습니다.

Haskell 식입니다. 여러분이 Haskell을 읽을 수 있다면, 이 식은 아름답습니다. 함수형입니다. 변경하지 않습니다.

매우 유사한 구현으로 Swift는 함수형으로 할 수 있다고 밝혀졌기 때문에 또한, 지연(lazy)으로 만들고자 한다면, 독자가 연습을 해야 하지만 더 어렵지 않습니다. 어떻게 알고리즘이 작동하는지 방법을 설명할 것이고, 매우, 매우 유사하기 때문입니다. 

<br/><img src="{{ site.production_url }}/image/flickr/23429358082_be35a02d68_z.jpg" width="640" height="399" alt="ValueType21"><br/>

2에서 20까지의 숫자 배열로 시작합니다. 간단한 기본 경우에서, 숫자가 없다면, 소수도 없습니다. 첫 번째 조건문입니다. 이건 사소합니다.

반면에, 여러분이 하는 것은 항상 소수가 되는 첫 번째 숫자를 끄집어냅니다. 그리고 남아있는 숫자와 분리합니다.

Haskell은 패턴 매칭을 했고, 그리고 우리도 배열을 자를 수 있습니다. 그러고 나서 소수를 가지고 남은 배열에 모든 요소를 filter 동작에다 수행합니다. 소수의 배수가 아닌 숫자를 복사합니다.

이제 재귀하고 다시 수행합니다. 새로운 소수인 3으로 분리합니다. filter를 수행합니다.

모든 3의 배수 등등을 없앱니다. 여기에 일어난 것은 결국 왼쪽 대각선을 따라 실제 소수를 만들며, 결과적으로 모두 함께 연결됩니다. 이 아이디어는 유사합니다. 매우 매우 유사합니다.

그러나 다른 성능 특징을 가지기 때문에 같은 알고리즘은 아닙니다. 

<br/><img src="{{ site.production_url }}/image/flickr/23242119000_5c1141c6b9_z.jpg" width="640" height="401" alt="ValueType22"><br/>

Melissa O'Nelildp의 "Eratosthenes의 진짜 체"라는 뛰어난 논문에서 결과를 얻으며, 논문에서 Haskell 커뮤니티가 애용하는 채는 진짜 채가 아님을 보여줍니다. 진짜 채와 같이 수행하지 않기 때문입니다. Haskell에서 더 복잡하게 구현하여 성능 특성을 다시 얻을 수 있습니다.

논문을 읽고 확인해보세요. 정말 멋집니다. 여러분에게 이 예의 경험을 보여주고 싶습니다.

Haskell list에 포함된 상태(comprehension) 또는 동등한 Swift filter 아래 중 하나를 봅니다. 변경할 수 없는 버전에서, 이 기능은 배열의 모든 단일 원소를 지나가서 다음 단계에 남아있는지, P의 배수인지 아닌지를 확인하기 위해 나누기를 수행할 것입니다.

기존 변경 알고리즘에서, 소수의 배수만 지나갔었고, 더 큰 숫자를 얻음으로써 점점 희소하게 됩니다. 그래서 더 적은 요소를 방문하고, 그리고 또한, 다음 요소를 얻도록 추가해야만 합니다.

그래서 더 적게 요소 당 작업을 합니다. 이는 중요합니다. 그리고 변경하지 않는 버전은 많은 작업이 없는 변경 버전보다 효율적이지 않습니다. Cocoa로 돌아갑시다. 

<br/><img src="{{ site.production_url }}/image/flickr/23511787486_c6e8177aa8_z.jpg" width="640" height="401" alt="ValueType23"><br/>

Cocoa, Cocoa Touch framework에서 불변성 사용을 봤습니다. 많이 있습니다. NSDate, UIImage, NSNumber, 기타 등등 말이죠.

이들은 불변 타입이고, 그리고 이 불변 타입을 갖는 것은 안전성을 향상하게 시킵니다. 복사에 대해 걱정하지 않아도 되기 때문에 좋은 것입니다. 의도치 않은 부작용을 가진 공유에 걱정하지 않아도 됩니다.

그러나 여러분은 또한 불변 타입과 작업할 때 단점을 봅니다. Objective-C로 작은 작업을 만들었습니다. home 디렉토리와 일부 디렉토리에 도달하는 연속적인 경로 요소를 추가로 시작하는 NSURL을 만들고자 합니다. 참조 의미론 세상에서 변경 없이 하길 원했습니다. 그래서 NSURL을 만들었습니다. 매번 loop를 통해, 다음 경로 요소를 추가한 새로운 URL을 만들었습니다. 이는 훌륭한 알고리즘이 아닙니다. 정말로요. 다른 객체로 매번 URL을 만들고, 이전 URL은 날리고, 그러고 나서 NSURL은 매번 loop를 통해 모든 문자열을 복사합니다. 효율적인 알고리즘이 아닙니다.

<br/><img src="{{ site.production_url }}/image/flickr/23429358252_45fcab3aa1_z.jpg" width="640" height="403" alt="ValueType24"><br/>

여러분은 잘못하고 있습니다. NSArray에다 이들 요소를 모으고 나서 fileURLWithPathComponents를 사용해야 합니다.

좋습니다. 그러나 기억하세요. 우리는 여기서 불변을 받아들이고 있습니다. 배열을 만들 때, 특별한 객체인 home 디렉토리로 NSArray를 만듭니다. 매번 새로운 배열을 만들고 한 개 이상의 객체를 추가합니다.

아직도 2차(quadratic)입니다. 아직도 요소를 복사합니다. 문자열 데이터를 복사하지 않습니다.

좀 더 낫습니다. 아직도 요소를 복사합니다. 의미가 통하지 않기 때문에 Cocoa 세상에서 완전히 불변성을 받아들일 수 없는 이유입니다. 대신, 의미가 통하는 더 국소적인 곳에서는 변경을 사용합니다.

<br/><img src="{{ site.production_url }}/image/flickr/23537868355_cb35a02b37_z.jpg" width="640" height="399" alt="ValueType25"><br/>

모든 요소를 NSMutableArray에 모읍니다. 그러고 나서 불변 NSURL로 돌아가기 위해 fileURLWithPathComponents을 사용합니다.

불변성은 좋은 것입니다. 참조 의미론 세상에 더 쉽게 만드는 이유입니다. 그러나 완전히 불변성으로 갈 수 없거나 미쳐 시작합니다. 

<br/><img src="{{ site.production_url }}/image/flickr/23537868315_0e3d8ddb2f_z.jpg" width="640" height="399" alt="ValueType26"><br/>

그래서 값 의미론을 가져옵니다. 우리는 값 의미론으로 다르게 접근합니다.

우리는 변경을 좋아합니다. 가치 있는 것으로 생각합니다. 정확하게 마무리할 때 사용하기 쉽다고 생각합니다.

우리가 보는 바와 같이, 문제는 공유입니다. 그래서 Objective-C든지 Swift든지 간에 항상 어떻게 값 의미론 작업하는지 방법과 요구하는 것을 이미 알고 있습니다.

<br/><img src="{{ site.production_url }}/image/flickr/22909610534_744b8aec76_z.jpg" width="640" height="401" alt="ValueType27"><br/>

아이디어는 간단합니다: 두 개의 변수가 있고, 이들 변수에 값은 논리적으로 별개입니다. 그래서 정수 A가 있고, 정수 B에다 복사합니다.

물론 값은 같습니다. 이것은 사본입니다. B를 변경하러 이동합니다. 여러분에게 A를 바꿀 것이라고 말했다면, 여러분은 내가 미쳤다고 말할 것입니다.

이들 변수는 정수입니다. 이제까지 함께 작업했던 모든 언어에서 정수는 값 의미론입니다.

<br/><img src="{{ site.production_url }}/image/flickr/23169908719_64ce51c582_z.jpg" width="640" height="399" alt="ValueType28"><br/>

CGPoint 예제입니다. A에서 B로 복사하면, B가 변하며, A에는 아무런 영향이 없습니다.

여러분은 이것이 익숙합니다. CGPoint가 이 방법으로 행동하지 않았다면, 여러분은 정말 정말 놀랄 것입니다.

값 의미론의 아이디어는 매우 기본적인 타입인 숫자와 숫자를 포함하는 작은 구조체, 그리고 더 많이 풍부한 타입으로 작업하기 위한 외부로 확장한 것을 이미 알고 있고 이해한 것입니다. 

<br/><img src="{{ site.production_url }}/image/flickr/23455430281_382e9a63b8_z.jpg" width="640" height="401" alt="ValueType29"><br/>

Swift에서는 문자열은 값 타입입니다. A를 만들고, A에다 B를 복사하고, 어떤 방법으로 B를 변경하고, A에는 아무런 영향이 없습니다. 값 타입이기 때문입니다. A와 B는 다른 변수입니다.

그러므로 이들 변수는 논리적으로 구별됩니다. 

<br/><img src="{{ site.production_url }}/image/flickr/23242119380_4de0eb5e32_z.jpg" width="640" height="401" alt="ValueType30"><br/>

배열은 정확히 같은 방법으로 동작하지 않을까요? A를 만들고, B에다 복사하고, B를 변경합니다.

A에는 아무런 영향이 없습니다. 완전히 다른 값입니다. 

<br/><img src="{{ site.production_url }}/image/flickr/23537868625_5b615251bb_z.jpg" width="640" height="402" alt="ValueType31"><br/>

마지막으로, 딕셔너리입니다. 이것은 컬렉션입니다. 값 의미론인 것을 딕셔너리에 넣고, 값 의미론을 다시 얻습니다.

<br/><img src="{{ site.production_url }}/image/flickr/23537868615_1b1f1233fb_z.jpg" width="640" height="401" alt="ValueType32"><br/>

여기 이 훌륭한 것은 값 타입으로 아름답게 이루어집니다. 그래서 값 의미론 세상에서 매우 풍부한 모든 추상을 쉽게 만들 수 있습니다.

그래서 Swift에서 모든 기본 타입은 -- integer, double, string, character, 기타 등등 -- 모두 값 타입입니다. 기본 타입은 두 변수가 논리적으로 구분되는 기본 행동이 있습니다. Array, Set, Dictionary로 만들어지는 모든 컬렉션은 값 타입으로 주어지면 값 타입입니다. 그리고 tuple, struct, enum을 사용을 만드는 데 사용하는 언어 추상은 이것들에다 값 타입을 넣었을 때, 값 타입으로 얻습니다. 다시, 값 의미론 세상에서 모든 풍부한 추상을 만드는 것이 매우 매우 쉽습니다.

<br/><img src="{{ site.production_url }}/image/flickr/23455430541_028ee350f4_z.jpg" width="640" height="398" alt="ValueType33"><br/>

이제, 값 타입에 하나 더 중요한 부분이 있는데, 두 개의 값, 값 타입의 두 개의 변수가 같을 때의 개념입니다.

두 변수는 같은 값을 가집니다. 그리고 동일성(identity)은 상관 없다는 것이 중요합니다. 많은 사본을 가질 수 있기 때문입니다.

저장된 실제 값이 중요합니다. 값을 얻는 방법이 중요한 것이 아닙니다. 여러분에게 이것을 말하는 게 정말 정말 웃깁니다.

여기에 A가 있고, 5로 설정하고, B에다 2와 3을 더해서 설정합니다. 물론 A와 B는 같습니다.

여러분은 항상 이렇게 작업합니다. 이 방법으로 작업하지 않는다면 integer를 이해하지 않은 것입니다. 개념을 확장합니다.

<br/><img src="{{ site.production_url }}/image/flickr/23455430581_2377c60bed_z.jpg" width="640" height="399" alt="ValueType34"><br/>

물론 CGPoint와 같은 것이고, 이 방법이 아니라면 여러분은 이해할 수 없습니다.

<br/><img src="{{ site.production_url }}/image/flickr/23511787986_c9cf3e3b40_z.jpg" width="640" height="401" alt="ValueType35"><br/>

문자열은 정확하게 같은 방법으로 하지 않나요? 어떻게 "Hello, WWDC." 문자열을 얻는지 상관없습니다. 문자열은 값이고, 같음 연산자는 나타내는 데 필요합니다. 이것은 임의로 미치고 어리석게 만들 수 있습니다. 몇 가지 정렬 기능을 수행하려고 합니다.

<br/><img src="{{ site.production_url }}/image/flickr/23242120060_620ffcb0d4_z.jpg" width="640" height="400" alt="ValueType36"><br/>

결국, 두 개의 integer 배열이 있지만, integer 배열은 같은 값을 가집니다. 그러므로 두 배열은 같습니다.

<br/><img src="{{ site.production_url }}/image/flickr/23511788706_3a24fbc924_z.jpg" width="640" height="401" alt="ValueType37"><br/>

값 타입을 만들 때, Equatable protocol에 적합한지 매우 중요합니다. 모든 값 타입은 Equatable이어야 하기 때문입니다.

비교하기 위해 == 연산자가 있음을 의미하지만, 연산자는 현명한 방법으로 행동해야 합니다.

반사적이고(reflexive), 대칭적이고(symmetric), 과도적이(transitive) 될 필요가 있습니다. 이들 속성이 왜 중요한가요? 이들 속성이 있지않는 한 코드를 이해할 수 없기 때문입니다.

A에서 B로 복사한다면, A와 B가 같고 B와 A가 같다고 예상합니다.

왜 안 그렇겠어요? B를 C에다 복사하면, C, B와 A는 모두 같습니다.

동일성이 있다는 것이 중요한 게 아니라, 값이 있다는 것이 중요하므로 상관없습니다. 

운 좋게도, 매우 매우 쉽게 구현할 수 있습니다.

<br/><img src="{{ site.production_url }}/image/flickr/23169909799_57286d2b9b_z.jpg" width="640" height="399" alt="ValueType38"><br/>

CGPoint를 가지고 Equatable로 확장하고 = 연산자를 구현하고, 다른 값 타입 중 값 타입을 구성할 때, 일반적으로 값 타입 전부에 기본적인 == 연산자를 사용해야 합니다.

<br/><img src="{{ site.production_url }}/image/flickr/23169909999_c5fc906e15_z.jpg" width="640" height="401" alt="ValueType39"><br/>

temperature 타입으로 돌아갑시다. struct로 만들 수 있습니다.

변경할 수 있도록 Celsius를 var로 바꿀 것입니다. 이것은 이제 값 의미론입니다.

명백한 = 연산자를 Temperature에 줍니다. 이전 예제에다 = 연산자를 사용합니다.

<br/><img src="{{ site.production_url }}/image/flickr/23537869725_2a51d8aec0_z.jpg" width="640" height="399" alt="ValueType40"><br/>

home을 만들고, temperature를 만들고, temperature를 화씨 75도 설정합니다. 컴파일러는 여기에서 멈추게 합니다.

무슨 일이 있었어요? temp 속성을 변경하려고, temp는 let으로 설명됩니다.

이것은 상수입니다. 변경할 수 없습니다. 우리는 컴파일러를 진정시킬 것입니다.

<br/><img src="{{ site.production_url }}/image/flickr/22909611834_0b9aeaa0f5_z.jpg" width="640" height="400" alt="ValueType41"><br/>

var로 바꾸면, 값을 변경할 수 있습니다. 그리고 이 모든 작업은 완전히 괜찮습니다. 왜 괜찮냐구요? house는 oven에 있는 thermostat를 가리킵니다. thermostat와 oven 둘 다 각자의 temperature 값 인스턴스를 가집니다.

완전히 다른 것으로, 절대 공유되지 않습니다. 또한, struct로 inline되도록 일어났으며, 메모리 사용과 성능이 훨씬 더 나아졌습니다.

이것은 훌륭합니다. 값 의미론은 우리 삶을 더 쉽게 만듭니다. 예제에서, 모든 방법을 행하고 모든 것을 값 의미론으로 만듭시다. 

<br/><img src="{{ site.production_url }}/image/flickr/23429359802_6b8636e386_z.jpg" width="640" height="399" alt="ValueType42"><br/>

이제 house는 struct이고 thermostat struct와 oven struct를 가지며, 모든 세계는 값 의미론입니다.

코드 개선의 변화는 이제 home을 변경할 수 있습니다. home의 thermostat에서 temperature를 변경할 수 있기 때문이며, 이는 home과 thermostat에서 변경과 temperature에서 변경입니다. 이는 우리에게 정말 중요한 사항을 가져옵니다.

<br/><img src="{{ site.production_url }}/image/flickr/23169910019_450681a640_z.jpg" width="640" height="398" alt="ValueType43"><br/>

Swift의 불변 모델 작업 방식이기 때문에 Swift에선 값 의미론이 아름답게 동작합니다. Swift에서 let이 있을 때, 값 타입입니다.

프로세스 메모리가 오염이 일어나지 않는 이상 값은 바뀌지 않을 것을 의미합니다. 정말 강력한 문(statement)입니다.

let이라는 매우 간단한 이유임을 의미합니다. 그러나 우리는 여전히 변경을 허용합니다.

이 변수가 변경될 수 있다고 말하기 위해 var를 사용할 수 있습니다. 그리고 이는 알고리즘에 극단적으로 유용합니다. 변경은 매우 지역적임을 주의하세요.

이 변수를 바꿀 수 있지만, 변수에 말할 때까지, 어떤 곳에서 변경을 수행할 때까지, 프로그램에서 어딘가에도 아무런 영향을 미치지 못할 것이며, 저는 여러분에게 정말로 멋진 제어 변경을 줍니다. 다른 곳에 강력한 보장과 함께 말이죠. 

<br/><img src="{{ site.production_url }}/image/flickr/23169910009_a13601c297_z.jpg" width="640" height="401" alt="ValueType44"><br/>

여기 멋진 것 중 하나는 스레드 경계를 가로질러 지나가는 값 타입을 사용할 때(역자 주: 변수가 여러 스레드에서 사용됨을 의미), 이들 타입에서 race condition으로부터 해방합니다. 그래서 numbers를 만듭니다.

비동기적으로 무언가를 할 프로세스 일부에다 numbers를 넘겼습니다. numbers를 국지적으로 변경하고 나서 다시 변경합니다.

참조 의미론 배열로, 이것은 race condition입니다. 이것은 언젠가 여러분을 날려버릴 것입니다. 값 의미론으로, 매번 사본, 논리적인 사본을 얻습니다. 그러므로 race condition이 없습니다. 같은 배열과 부딪히지 않습니다.

성능 문제처럼 들립니다. number는 parameter를 통과할 때마다 매번 복사합니다. 

<br/><img src="{{ site.production_url }}/image/flickr/22910789183_1b87a00cbc_z.jpg" width="640" height="399" alt="ValueType45"><br/>

값 의미론의 중요한 부분 중 하나는 복사 비용이 쌉니다.

적은 비용으로, 상수 시간(constant time)이 싸다라는 것을 의미합니다. 기본 타입으로 만들어봅시다. 기본 타입이 있을 때, 정말로 low-level인 integer, double, float 등의 타입은 복사 비용은 쌉니다. 여러 바이트를 복사합니다.

보통 프로세서에서 일어납니다. 그러고 나서 double과 int 등으로 struct를 만들기 시작합니다.

CGPoint는 두 개의 CGFloat로 구성됩니다. struct, enum 또는 tuple은 field에 고정된 숫자가 있고, 상수 시간에 각각을 복사합니다. 모든 것은 상수 시간에 복사합니다.

고정 길이인 것에는 좋습니다. 확장 가능한 문자열, 배열, 딕셔너리 등은 어떤가요? Swift 세상에 복사-쓰기로 이들 타입을 다룹니다. 저렴하게 사본을 만듭니다. 복사-쓰기 사본 값을 수행하기 위한 참조-계산 연산자(reference-counting operation)의 고정된 숫자 일부입니다. 그러고 나서 변경하는 곳에서 var로 바꾸고 나서, 사본을 만들고 사본으로 작업합니다. 그래서 뒤에서는 공유하지만, 논리 공유는 아니며 논리적으로 여전히 다른 값입니다. 값 의미론으로부터 훌륭한 성능 특성을 받으며 정말로 좋은 프로그래밍 모델입니다.

<br/><img src="{{ site.production_url }}/image/flickr/22910789163_ce1856f42c_z.jpg" width="640" height="401" alt="ValueType46"><br/>

우리는 진짜로 값 의미론 프로그래밍 모델을 사랑합니다. 서로 다른 변수들은 항상 논리적으로 다릅니다. 여러분은 변경 개념을 알고 있고, 국지적으로 제어하길 원할 때, 효율적인 변경입니다. 그러나 let의 강력한 보장을 알고 있고, 이는 다른 곳에서 변경할 수 없음을 의미합니다.

그리고 복사는 비용이 싸며, 모든 작업에 함께합니다. 제 동료인 Bill Dudney에게 넘기도록 하겠습니다. 값 타입과 연습에 관해 이야기할 것입니다.

<br/><img src="{{ site.production_url }}/image/flickr/23242120890_bb6f603e81_z.jpg" width="640" height="398" alt="ValueType47"><br/>

안녕하세요. 여러분. Doug는 어떻게 값 타입으로 작업해야 하는지, 참조 의미론과 어떻게 비교해야 하는지를 알려줬습니다. 

<br/><img src="{{ site.production_url }}/image/flickr/23455431761_d18a5b42bc_z.jpg" width="640" height="399" alt="ValueType48"><br/>

값 타입을 사용하여 실제 예제를 만드는 것에 관해 이야기합시다. 두 개의 다른 값 타입의 간단한 Diagram을 예제로 함께 만들 것입니다. circle과 polygon을 말이죠. 

<br/><img src="{{ site.production_url }}/image/flickr/23537870125_710fb0bdb2_z.jpg" width="640" height="398" alt="ValueType49"><br/>

circle로 시작해봅시다. center이고 radius입니다.

두 개의 값 타입은 표준 라이브러리입니다. 물론, = 연산자, == 연산자, 그리고 단지 이들 타입을 비교만 하도록 구현하고자 합니다. 다시, 표준 라이브러리를 만든 이후, 라이브러리에서 나온 간단한 타입으로 구성한 이후 사용해야 합니다. 

<br/><img src="{{ site.production_url }}/image/flickr/22910789403_26a2d110f8_z.jpg" width="640" height="398" alt="ValueType50"><br/>

다음은 polygon입니다.

corner 배열이 있고, 각 corner는 다른 CGPoint이고, 값 타입입니다.

배열은 값 타입이고, 같음을 사용한 비교는 확실합니다. equal 연산자로 Equatable 연산자를 구현을 확인해야 합니다. 

<br/><img src="{{ site.production_url }}/image/flickr/22909612334_cf8fba42f1_z.jpg" width="640" height="398" alt="ValueType51"><br/>

이제 Diagram에 polygon과 circle 타입을 넣어 수행하고자 합니다.

배열은 값 타입이고, Equatable 연산자 구현을 확실하게 한 == 연산자를 사용하는 비교는 확실합니다. 

<br/><img src="{{ site.production_url }}/image/flickr/23242121290_828d87365e_z.jpg" width="640" height="398" alt="ValueType52"><br/>

이제 다이어그램에 polygon 과 circle 타입 둘 다 넣길 원합니다.

circle 배열을 간단하게 만듭니다. polygon 배열을 간단하게 만듭니다. 그래서 어느 타입의 배열이든 만들 수 있습니다. 

두 개의 타입을 포함하는 배열을 만드는 작업이 필요합니다. 

<br/><img src="{{ site.production_url }}/image/flickr/23511789496_6ee0bdeab6_z.jpg" width="640" height="399" alt="ValueType53"><br/>

Swift에서 할 수 있는 매커니즘은 protocol입니다. 그래서 Drawable이라는 protocol을 만듭니다.

subtype 둘 다 protocol로 구현하고 나서, Diagram에 있는 배열에 넣을 수 있습니다.

오늘 3시 30분에 훌륭한 많은 정보가 있는 프로토콜 지향 프로그래밍 Swift 토크를 다시 합니다.

만약 못 봤다면, 보러 가거나 비디오로 보길 제안합니다.

<br/><img src="{{ site.production_url }}/image/flickr/22910789673_1769573353_z.jpg" width="640" height="399" alt="ValueType54"><br/>

Drawable 프로토콜입니다. 수월하고 간단하고, Draw 메소드를 가집니다. 물론, 두 개 타입을 구현하고자 합니다.

polygon의 확장을 만들고, draw 메소드를 구현하고, 그리고 이는 Core Graphics를 호출하고 polygon을 그립니다.

<br/><img src="{{ site.production_url }}/image/flickr/23455432221_1548572f47_z.jpg" width="640" height="399" alt="ValueType55"><br/>

그리고 circle도 같습니다. 그래서 Core Graphics를 호출하고 circle 표시를 만듭니다.

<br/><img src="{{ site.production_url }}/image/flickr/23169910729_5d369d1176_z.jpg" width="640" height="400" alt="ValueType56"><br/>

Diagram으로 돌아갑니다. Items라는 drawable 배열이 있습니다. item에 메소드를 만들어 추가해야 합니다.

self를 변경하기 때문에 mutating으로 표시합니다. Draw 메소드를 구현하는데, 간단하게 items 리스트를 반복하고 각 item에서 Draw 메소드를 호출합니다. 

<br/><img src="{{ site.production_url }}/image/flickr/22910786253_d1727b73a6_z.jpg" width="640" height="397" alt="ValueType57"><br/>

도표로 살펴봅시다. Diagram을 만들고, doc이라는 Diagram을 만듭니다.

polygon을 만들고 배열에 추가합니다. 다른 하나인 circle을 만들고 배열에 추가합니다. 이제 배열은 두 개의 drawable을 가집니다.

<br/><img src="{{ site.production_url }}/image/flickr/23455429001_d4a6016665_z.jpg" width="640" height="406" alt="ValueType58"><br/>

다른 타입이라고 알립니다. doc과 같은 doc2라는 document를 만들었을 때, 논리적으로 새로운 인스턴스로 구분합니다.

첫 번째 인스턴스로부터 논리적으로 분리됩니다. 이제 doc을 변경할 수 있고, doc2를 변경해도 doc에는 아무런 영향을 미치지 않습니다.

circle을 polygon으로 바꿉니다. 배열은 값 의미론을 가지며 심지어 컬렉션은 다른 종류입니다.

배열 내부에 polygon과 circle을 값으로 가집니다. 

<br/><img src="{{ site.production_url }}/image/flickr/22910786123_cdfbbf9169_z.jpg" width="640" height="399" alt="ValueType59"><br/>

물론, 우리는 Diagram struct Equatable로 만들고자 합니다.

프로토콜을 구현합니다. 그리고 간단하게 구현되는 것을 볼 수 있을 것입니다.

그러나 이를 구현했다면 컴파일러는 "잠시만 기다려, 양쪽 두 값이 같은지에 대한 == 연산자가 없어."고 말합니다. 모든 작업 방법의 모든 상세를 말했었던 프로토콜 지향 프로그래밍 토크를 인용합니다.

이 토크에서 값 의미론에 초점을 맞출 것입니다. 

<br/><img src="{{ site.production_url }}/image/flickr/23537867065_22a31359a9_z.jpg" width="640" height="399" alt="ValueType60"><br/>

그래서 drawable은 Draw라는 메소드 하나를 가지며, 다이어그램에서 Draw라는 메소드가 있습니다.

Diagram을 Drawable로 바꿔봅시다. Diagram에 Drawable을 추가해야 합니다. Diagram은 오리처럼 꽥꽥댑니다.

<br/><img src="{{ site.production_url }}/image/flickr/23429356552_e3312133b4_z.jpg" width="640" height="398" alt="ValueType61"><br/>

흥미로운 점입니다. 새로운 Diagram을 만들 수 있고 기존 Diagram에 추가할 수 있습니다. 이는 다른 세 개의 타입이 있지만, 배열 내부에 모두 포함됩니다. Diagram의 새로운 인스턴스입니다. 그러나 배열에 하나 더 넣고 document를 추가할 수 있습니다. 참조 의미론이었다면, Draw 메소드를 살펴봅시다.

참조 의미론이었다면, 무한 재귀였을 겁니다. Diagram에서 Draw를 호출함으로, items 리스트로 찾습니다. 그리고 다시 Draw가 호출되고 무한 재귀가 될 것입니다. 그러나 값을 사용합니다.

Diagram에 doc을 대신 추가하고, 이는 값이기 때문에, 인스턴스가 완전히 나뉘고 구분됩니다.

그래서 무한 재귀가 없습니다. 그려진 두 polygon과 두 circle를 얻습니다. 

<br/><img src="{{ site.production_url }}/image/flickr/23537866935_c879cb2d38_z.jpg" width="640" height="399" alt="ValueType62"><br/>

값 타입으로 순수한 객체 트리를 만드는 것에 관해 이야기했고, 값 타입과 참조 타입을 섞는 방법을 이야기합시다. 

<br/><img src="{{ site.production_url }}/image/flickr/23242117620_319fc9424e_z.jpg" width="640" height="399" alt="ValueType63"><br/>

Objective-C에서는 매번 참조 타입 안쪽에 기본 데이터 타입을 넣는 데 사용됩니다. Objective-C에서 만드는 방법입니다.

<br/><img src="{{ site.production_url }}/image/flickr/23242117670_3190dd917f_z.jpg" width="640" height="400" alt="ValueType64"><br/>

그러나 이면은 좀 더 생각해볼 만한 여러 흥미로운 질문을 소개합니다. 값 타입을 만든다면, 값 타입이 값 의미론을 유지하는지, 심지어 참조 안쪽에 있는지 확인하길 원합니다. 확인하려고 한다면, 그 질문에 관해 생각해야 합니다. 다른 두 값이 참조가 있으므로 아마도 같은 것을 가르키고 있을 것이다는 사실을 어떻게 다뤄야 할까요? 이 질문을 풀어야 합니다. 

<br/><img src="{{ site.production_url }}/image/flickr/23169906789_ea3ec8cdd8_z.jpg" width="640" height="398" alt="ValueType65"><br/>

불변 클래스인 UIImage로 간단한 예제를 시작합니다.

Drawable으로 되는 image struct를 만들고, UIImage에 참조를 가집니다. 

<br/><img src="{{ site.production_url }}/image/flickr/23511785856_249372d2b9_z.jpg" width="640" height="396" alt="ValueType66"><br/>

샌 프란시스코의 아름다운 사진으로 인스턴스를 만듭니다. 

<br/><img src="{{ site.production_url }}/image/flickr/23511785996_213795bae4_z.jpg" width="640" height="398" alt="ValueType67"><br/>

그리고 image2를 만든다면, image와 image2는 둘 다 같은 객체를 가리킵니다.

여러분은 이것을 보고 Bill이 우리를 속였고, 이는 문제가 되며, temperature처럼 될 것으로 생각합니다.

그러나 UIImage는 불변이기 때문에 그렇지 않습니다. image가 변경된 것에 대해 image2는 걱정하지 않아도 됩니다. 

<br/><img src="{{ site.production_url }}/image/flickr/22909608514_60372eb10f_z.jpg" width="640" height="400" alt="ValueType68"><br/>

물론 언뜻 보기에 같음을 구현하는지 확인하려면, 여러분은 이를 보고 생각할 수 있습니다. === 연산자를 사용하여 참조 비교하고 이들 참조가 같은지를 볼 것입니다. 이 예제에서 괜찮게 동작하지만, 같은 기본 bitmap을 사용한 두 개의 UIImage를 만든다면 발생하는 것도 생각해야 합니다. 또한 동일시(equate)하고 동일(equal)하길 원하고, 그리고 이 경우에는 참조를 비교한 후에는, 비교하지 않을 것입니다.

그래서 두 이미지는 같지 않다고 잘못 말할 것입니다. 

<br/><img src="{{ site.production_url }}/image/flickr/23537866665_5520b9328e_z.jpg" width="640" height="399" alt="ValueType69"><br/>

대신 우리가 하고자 하는 것은 NSObject로부터 상속받은 UIImage에서 비교하는 Equal 메소드를 사용하길 원하고, 그래서 참조 타입은 같은 객체인지 아닌지 여부에 대한 정답을 얻었다고 확신합니다.

<br/><img src="{{ site.production_url }}/image/flickr/23455427931_8245a4947c_z.jpg" width="640" height="399" alt="ValueType70"><br/>

변하는 객체 사용에 관해 이야기합시다. 여기에 BezierPath가 있습니다. Drawable 구현합니다.

그러나 전체 구현은 변하는 참조 타입인 UIBezierPath로 구성됩니다. 읽기 경우에서, isEmpty를 수행할 때는 괜찮습니다. 어떤 변경도 하지 않아서, 어떠한 인스턴스도 망치지 않습니다.

<br/><img src="{{ site.production_url }}/image/flickr/23169906409_c7dce66fb9_z.jpg" width="640" height="398" alt="ValueType71"><br/>

그러나 아래 코드에는 AddLineToPoint 메소드가 있고, 그리고 두 BezierPath pointing이 있다면, 문제가 발생할 것입니다.

또한, 여길 보면, Mutating 키워드가 없습니다. AddLineToPoint가 있으므로 변경하는 표시이지만, 컴파일러는 우리에게 이를 소리치지 않습니다. 즉, path는 참조 타입이기 때문입니다. 다시 살펴볼 것입니다.

<br/><img src="{{ site.production_url }}/image/flickr/23242117120_af66445993_z.jpg" width="640" height="402" alt="ValueType72"><br/>

BezierPath 인스턴스가 두 개 있다면, 참조를 통해 같은 UIBezierPath 인스턴스를 둘 다 가리키고, 변경하고 나서, 다른 하나는 허를 찔립니다. 이는 나쁜 상황입니다. 값 의미론이 유지되지 않습니다.

<br/><img src="{{ site.production_url }}/image/flickr/22909608364_4f78f5e36d_z.jpg" width="640" height="396" alt="ValueType73"><br/>

이를 고쳐야 합니다. 복사-쓰기 사용하여 고치는 방법, 그리고 path를 작성하기 전에 사본이 만들었는지 확인하고 싶습니다. 

<br/><img src="{{ site.production_url }}/image/flickr/23455428101_9759090a66_z.jpg" width="640" height="398" alt="ValueType74"><br/>

이를 하기 위해서, 우리는 BezierPath의 새로운 방법 두 가지를 소개해야 합니다.

첫 번째, path 인스턴스를 private로 만들고 싶으며, 그리고 다음으로 읽기 전용 계산 속성 path(역자 주: get)를 구현하고 싶어 하고 private 인스턴스 변수를 반환합니다. 그리고 mutating으로 표시된 쓰기 전용 계산 속성 path(역자 주: set)를 만들길 원하고, 이는 상태를 변경합니다. 그래서 mutating으로 표시하고 기존 path의 새로운 사본으로 같게 path를 설정합니다.

<br/><img src="{{ site.production_url }}/image/flickr/23511785346_2c39912d40_z.jpg" width="640" height="398" alt="ValueType75"><br/>

이제 우리는 읽기 복사와 쓰기 복사를 얻는 방법 둘 다 있습니다. 그리고 이를 반영하여 구현을 바꿉니다. isEmpty 메소드에서 읽기 복사를 호출하고, 변경 메소드 아래에선 pathForWriting를 호출합니다. 그리고 컴파일러는 우리에게 "pathForWriting 속성은 mutating으로 표시되었고, 이 메소드는 mutating으로 표시되지 않았다." 라고 소리칩니다. 

<br/><img src="{{ site.production_url }}/image/flickr/22910785273_0b9080cd05_z.jpg" width="640" height="400" alt="ValueType76"><br/>

이는 훌륭합니다. 우리는 뭔가 잘못했을 때 컴파일러가 발견하여 도와줍니다. 

<br/><img src="{{ site.production_url }}/image/flickr/23511785166_dc2cdd46d5_z.jpg" width="640" height="397" alt="ValueType77"><br/>

다이어그램에서 path를 살펴 보면, path2라는 다른 path를 만듭니다. 물론, path2로부터 읽을 수 있습니다. 이슈는 없습니다. path2를 쓰기를 하러 갈 때, 다른 BezierPath 인스턴스를 만든 이후로, path2는 변경이 일어났음을 여전히 이해하지 못했습니다. 그래서 path2 뒤에 몇 가지 예상치 못한 변경을 소개하지 않습니다. 연습에서 어떻게 사용하는지 방법에 관해 이야기합시다. 

<br/><img src="{{ site.production_url }}/image/flickr/23537865715_6941cf2e9e_z.jpg" width="640" height="398" alt="ValueType78"><br/>

polygon 타입이 있고, polygon을 설명하는 BezierPath를 우리에게 돌려줄 메소드를 추가하여 확장합니다. BezierPath를 만들고 point를 통해 반복하고, point의 각각에 선을 추가합니다. 이제, 단점은 매번 호출로 AddLineToPoint 메소드가 복사하는 것을 기억합니다.

이는 수행하지 않을 것이고 뿐만 아니라 그럴 수도 있습니다. 

<br/><img src="{{ site.production_url }}/image/flickr/22910784243_3b1b28288b_z.jpg" width="640" height="399" alt="ValueType79"><br/>

대신, UIBezierPath 인스턴스를 만들어야 합니다. 그리고 변경 가능한 참조 타입이 있는 경우 그리고 BezierPath와 반환하는 것으로 값 타입 인스턴스를 만드는 것이 끝났을 때 변경해야 합니다. 여러 개 대신 사본 하나 또는 UIBezierPath 인스턴스만 만듭니다. 

<br/><img src="{{ site.production_url }}/image/flickr/22910784173_3c08e29f6d_z.jpg" width="640" height="398" alt="ValueType80"><br/>

Swift에는 유일하게 참조되었는지 아는 훌륭한 기능이 있고, 이 이점을 이용할 수 있습니다. BezierPath에서 봤던 것과 유사한 구조이고, 유일하게 참조된 속성이 있다는 사실을 사용할 수 있고 뭔가 유일하게 참조된 사실을 압니다. 그래서 우리는 참조 타입이 유일하게 참조되었다는 것을 안다면 사본 만드는 것을 피할 수 있습니다. 표준 라이브러리는 이 특징을 곳곳에 사용하고 이를 이용하여 뛰어난 성능 최적화를 많이 합니다. 

<br/><img src="{{ site.production_url }}/image/flickr/23511784506_e748cf8902_z.jpg" width="640" height="398" alt="ValueType81"><br/>

값 타입과 참조 타입을 섞습니다. 복사-쓰기 사용으로 변경할 수 있는 타입으로 참조 타입이 있다는 사실에도 불구하고 값 의미론 유지함을 확인하고 싶어 합니다. 

<br/><img src="{{ site.production_url }}/image/flickr/23537865155_20961123c6_z.jpg" width="640" height="398" alt="ValueType82"><br/>

값으로 모델 타입을 구현하고, undoStack을 구현할 수 있는 멋진 기능을 살펴보려고 합니다.

<br/><img src="{{ site.production_url }}/image/flickr/23537865085_0161df9d4e_z.jpg" width="640" height="399" alt="ValueType83"><br/>

그래서 Diagram을 만들고 Diagram 배열을 만듭니다. 그러고 나서 모든 변경으로, Diagram 배열에 doc를 추가할 것입니다. doc를 만들고 추가합니다.

polygon을 doc에 추가하고 doc를 undoStack에 추가합니다. circle을 만들고 doc에 추가하고 undoStack에 추가합니다. 이제 undoStack에 세 개의 다른 Diagram 인스턴스가 있습니다. 이들은 같은 것을 참조하지 않습니다. 이들은 세 개의 다른 값입니다.

<br/><img src="{{ site.production_url }}/image/flickr/22910783813_049f3d42ee_z.jpg" width="640" height="399" alt="ValueType84"><br/>

이것으로 정말로 멋진 기능을 구현할 수 있습니다. 앱에 이를 그리고, History 버튼이 있습니다. History 버튼을 탭하고 undoStack을 통해 이전 Diagram의 모든 상태 리스트를 얻습니다. 사용자에게 탭을 허용하고 이전으로 돌아가도록 할 수 있습니다.

undo에 속성이나 어떤 것을 추가한 배열을 유지하지 않아도 됩니다. 단지 이전 인스턴스로 돌아가서 그린 것입니다. 

<br/><img src="{{ site.production_url }}/image/flickr/23537864815_b2036a9831_z.jpg" width="640" height="399" alt="ValueType85"><br/>

이는 매우 강력한 기능으로, 사실 Photoshop은 모든 히스토리를 구현하기 위해 이 기능을 광범위하게 사용합니다. Photoshop에서 이미지를 열 때, 뒤에선 무슨 일이 일어날까요? Photoshop은 사진이 얼마나 큰지 상관치 않고, 작은 타일 묶음으로 나눕니다. 각각의 타일은 값이고, document는 값인 타일을 포함합니다. 

<br/><img src="{{ site.production_url }}/image/flickr/23455426231_5fef6a69b3_z.jpg" width="640" height="401" alt="ValueType86"><br/>

그러고 나서 만약 이 사람의 셔츠를 자주색에서 녹색처럼 바꾼다면, 셔츠가 포함된 타일인 다이어그램의 두 인스턴스에서 복사됩니다. 두 개의 다른 document가 있다고 하더라도, 오래된 상태와 새로운 상태, 이 사람의 셔츠 안에 포함된 타일인 결과로 새로운 데이터로만 소비해야 했습니다.

<br/><img src="{{ site.production_url }}/image/flickr/23429354362_f29b67ce83_z.jpg" width="640" height="398" alt="ValueType87"><br/>

요약해서, 값 타입에 관해 이야기했고, 여러분 애플리케이션에 가져갈 훌륭한 기능, 참조 타입을 비교하고 값 타입이 이들 일부 이슈를 수정하는지 방법을 보였습니다. 예제를 통해 이야기 했고, 값 타입을 사용하여 여러분 애플리케이션에 추가할 수 있는 몇 가지 멋진 기능을 봤습니다. 여러분 앱에서 이 것들을 어떻게 동작할지 기대합니다.

일부 관련된 세션은 비디오로 볼 수 있거나 오늘 3시 30분에 프로토콜-지향 토크가 있습니다.

더 많은 정보는, 항상 Stephan에게 메일을 보내거나 포럼에 가고, 문서는 또한 훌륭한 정보가 있습니다.

감사드리며 여러분이 WWDC에서 좋은 시간 보내시길 바랍니다.
---
layout: post
title: "[iOS]Key Value Coding, Key Value Observing"
description: ""
category: "iOS"
tags: [ios,KVC,KVO,key-value Coding, key-value Observing]
---
{% include JB/setup %}


## KVC(Key-value Coding)

### 정의

어플리케이션이 정보를 의미하는 문자열(또는 키)를 사용하여 간접적으로 객체의 속성값을 접근하는 매커니즘을 말합니다.
Key-value coding은 key-value observing, Cocoa bindings, Core Data와 함께 작업하는 기본적인 기술입니다.

### 특징

- 키가 되는 문자열은 런타임시 결정됩니다.
- 소스 코드가 간결해지면서 유지보수도 쉬워집니다.
- 클래스간 의존성이 낮아집니다.

### 사용 함수

#### 기본

일반적인 키에 대한 값을 얻을 때 사용합니다.
> - 값을 얻을 때 - `valueForKey:`
> - 값을 설정 할 때 - `setValue:forKey`

##### 예제

     NSLog(@"horsepower is %@", [engine valueForKey:@"horsepower"]);
     [engine setValue:[NSNumber numberWithInt:150] forKey:@"horsepower"];


#### 키-경로

키-경로를 통해 속성 값을 얻을 때 사용합니다.
> - 값을 얻을 때 - `valueForKeyPath:`
> - 값을 설정할 때 - `setValue:forKeyPath:`

##### 예제

     NSLog(@“%@“, [selectedPerson valueForKeyPath:@"spouse.scooter.modelName”] );

#### Array로 받기

키에 대한 값을 배열로 얻습니다.

##### 예제

     NSArray *pressures = [car valueForKeyPath: @"tires.pressure”];
     NSLog (@"pressures %@", pressures);


#### 원하는 키만 받기


원하는 키만 받을 때 사용합니다.


#### 예제


     NSArray *keys = [NSArray arrayWithObjects:@"make", @"model",@"modelYear", nil];
     NSDictionary *carValues = [cardictionaryWithValuesForKeys:keys];
     NSLog(@"Car values : %@", carValues);


### Key-value Coding 비교

#### Key-value Coding을 사용하지 않은 경우

    - (id)tableView:(NSTableView *)tableview
          objectValueForTableColumn:(id)column row:(NSInteger)row {
    
        ChildObject *child = [childrenArray objectAtIndex:row];
        if ([[column identifier] isEqualToString:@"name"]) {
            return [child name];
        }
        if ([[column identifier] isEqualToString:@"age"]) {
            return [child age];
        }
        if ([[column identifier] isEqualToString:@"favoriteColor"]) {
            return [child favoriteColor];
        }
        // And so on.
    }

#### Key-value Coding을 사용하는 경우

    - (id)tableView:(NSTableView *)tableview
          objectValueForTableColumn:(id)column row:(NSInteger)row {
    
        ChildObject *child = [childrenArray objectAtIndex:row];
        return [child valueForKey:[column identifier]];
    }
   
---

## KVO(Key-value Observing)

### 정의

모델 객체의 어떤 값이 변경되었을 경우 이를 UI에 반영하기 위해서 컨트롤러는 모델 객체에 Observing을 도입하여 델리게이트에 특정 메시지를 보내 처리할 수 있도록 하는 것입니다.

### 특징

- 일대일, 일대다 관계에 대해서도 Observing을 적용할 수 있습니다.
- 모델 데이터에 반영되는 구조를 가진 앱은 코코아 바인딩을 사용하면 코드 작성을 최소화 할 수 있습니다.

### 예제

#### Observer로 등록하기

    - (void)registerAsObserver {
        /*
         Register 'inspector' to receive change notifications for the "openingBalance" property of
         the 'account' object and specify that both the old and new values of "openingBalance"
         should be provided in the observe… method.
         */
        [account addObserver:inspector
                 forKeyPath:@"openingBalance"
                     options:(NSKeyValueObservingOptionNew |
                                NSKeyValueObservingOptionOld)
                        context:NULL];
    }
   
NSKeyValueObservingOptioinNew는 NSKeyValueChangeNewKey 키에 대한 새 값을 저장합니다.
NSKeyValueObservingOptionOld는 NSKeyValueChangeOldKey 키에 대한 이전 값을 저장합니다.

#### Observer로부터 통보 받기

    - (void)observeValueForKeyPath:(NSString *)keyPath
                          ofObject:(id)object
                            change:(NSDictionary *)change
                           context:(void *)context {
    
        if ([keyPath isEqual:@"openingBalance"]) {
            [openingBalanceInspectorField setObjectValue:
                [change objectForKey:NSKeyValueChangeNewKey]];
        }
        /*
         Be sure to call the superclass's implementation *if it implements it*.
         NSObject does not implement the method.
         */
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                               context:context];
    }

#### Observer에서 제거하기

    - (void)unregisterForChangeNotification {
        [observedObject removeObserver:inspector forKeyPath:@"openingBalance"];
    } 

### 참고
- [Key-Value Coding Programming Guide](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/KeyValueCoding.html)
- [Key-Value Observing Programming Guide](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueObserving/KeyValueObserving.html#//apple_ref/doc/uid/10000177i)
- [함수 예제 코드 참고](http://funnyrella.blogspot.kr/2013/10/27.html)
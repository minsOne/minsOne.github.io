---
layout: post
title: "NSDictionary를 이용한 조건문 제거하기"
description: ""
category: "Mac/iOS"
tags: [nadictionary, if, switch, blocks, mac, ios, objectivec, objc]
---
{% include JB/setup %}

## NSDictionary를 이용한 조건문 제거하기

if, switch문을 통해 변수의 값을 대입하는 코드들을 많이 작성했습니다. 그러나 이 조건문을 없애고 싶다는 생각도 많이 했습니다.

최근에 [Refactoring Tricks](http://www.merowing.info/2014/03/refactoring-tricks/#.UzjZsq1_unE)라는 글을 보면서 Key-Value를 통해서 값을 얻을 수 있다는 것을 뒤늦게 깨닫고 나서 위에 글에서 소개한 방식으로 코드를 작성을 많이 하고 있습니다.

### 데이터 가져오기

일반적으로 if / switch 조건문을 통해 변수에 지정된 값을 저장할 수 있습니다.
	
	NSString *str;
	if(index == 1){
		str = @"value1";
	} else if(index == 2){
		str = @"value2";
	} else if(index == 3){
		str = @"value3";
	} else if(index == 4){
		str = @"value4";
	} else if(index == 5){
		str = @"value5";
	}

<br/>if / switch 조건문을 제거하기 위해 다음 메소드에 Dictionary Mapping을 하여 데이터를 얻습니다.

	-(NSString *)getConditionStr:(NSInteger)index
	{
	    static NSDictionary *mapping = nil;
	    if (!mapping) {
	        mapping = @{
	                    @1: @"value1",
	                    @2: @"value2",
	                    @3: @"value3",
	                    @4: @"value4",
	                    @5: @"value5",
	                    };
	    }
	    return mapping[@(index)] ?:@"default";
	}

NSDictionary에 저장된 Key, Value를 통해 쉽게 코드를 읽을 수 있습니다.

### 조건에 따라 메소드 실행 후 데이터 가져오기

if / switch 조건문 안에서 메소드 실행 후 얻은 데이터를 변수에 저장할 때 보통 다음과 같이 합니다.

    NSString *str;
    Boolean result = TRUE;
	if(index == 1){
		str = [NSString stringWithFormat:@"%@", result ? @"True1" : @"False1"];
	} else if(index == 2){
		str = [NSString stringWithFormat:@"%@", result ? @"True2" : @"False2"];
	} else if(index == 3){
		str = [NSString stringWithFormat:@"%@", result ? @"True3" : @"False3"];
	} else if(index == 4){
		str = [NSString stringWithFormat:@"%@", result ? @"True4" : @"False4"];
	} else if(index == 5){
		str = [NSString stringWithFormat:@"%@", result ? @"True5" : @"False5"];
	}

<br/>그러면 NSDictionary에 block을 넣어 해당 키일 경우 block을 사용할 수 있도록 합시다.

	-(NSString *)getConditionStr:(NSInteger)index
	{
	    static NSDictionary *mapping = nil;
	    NSString *(^getTitle)(void);
	    
	    if (!mapping) {
	        mapping = @{
	                    @1: ^(void){
	                        return [NSString stringWithFormat:@"%@", index % 2 ? @"True1" : @"False1"];
	                    },
	                    @2: ^(void){
	                        return [NSString stringWithFormat:@"%@", index % 2 ? @"True2" : @"False2"];
	                    },
	                    @3: ^(void){
	                        return [NSString stringWithFormat:@"%@", index % 2 ? @"True3" : @"False3"];
	                    }
	                    };
	    }
	    getTitle = mapping[@(index)];
	    return getTitle();
	}

block도 객체이므로 NSDictionary에 저장이 가능하며 해당 block을 value로 가져오며 `(^getTitle)(void)`에 저장을 하고 마지막에 block을 호출합니다.

어떻게 보면 보기는 좋지 않을 수도 있지만 때에 따라서 사용하면 좋을 것 같습니다.
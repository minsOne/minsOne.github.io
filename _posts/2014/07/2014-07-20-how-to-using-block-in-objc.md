---
layout: post
title: "[Objective-C]Block 객체 사용하기"
description: ""
category: "Mac/iOS"
tags: [block, closure, first-class, reference, strong, weak, extention, typedef]
---
{% include JB/setup %}

블록 객체는 C언어의 확장이며 비표준입니다.([wikipedia 참조](http://en.wikipedia.org/wiki/Blocks_(C_language_extension))) 다른 언어에서 클로저(closure) 또는 익명함수, 람다함수, 일급 객체(first-class object)라고 합니다.

우선 Objective-C에서 다루므로 블록 객체라고 하겠습니다. 

### 블록 객체 정의

블록객체는 다음과 같은 조건을 만족합니다.([wikipedia 참조](http://en.wikipedia.org/wiki/First_class_object))

- 변수나 데이터 구조안에 담을 수 있다.
- 파라미터로 전달 할 수 있다.
- 반환값(return value)으로 사용할 수 있다.
- 할당에 사용된 이름과 관계없이 고유한 구별이 가능하다.

블록은 다음과 같이 설명할 수 있습니다.

<img src="{{ site.production_url }}/image/2014/07/block_explain_example.jpg" alt="block_explain_example"/><br/>

또한, 블럭 `객체`이므로 id형태로 저장이 가능하므로 array, dictionary에도 저장하여 사용 가능합니다.

	NSMutableArray *tmpArr = [[NSMutableArray alloc]init];
    [tmpArr addObject:^(int i){ NSLog(@"Result : %d", i);}];
    
    void (^c)(int) = ^(int i){ NSLog(@"Result : %d", i);};
    [tmpArr addObject:c];
    
    void (^b)(int) = tmpArr[0];
    void (^d)(int) = tmpArr[1];
    b(5);
    d(1);

함수에 객체로 넘기는 것도 가능합니다.

	- (void)main {
	    [self func:^int(int i) {
	    	return i + 5;  	
	    }];
	}

	- (void)func:(int (^)(int))myBlock
	{
	    int i = myBlock(5);
	    NSLog(@"Result : %d", i);
	}

### 블록 객체 타입 선언

블록 객체의 타입을 간결하게 사용하게 위해 typedef로 정의합니다.

	typedef void (^myBlockType)(int)

typedef로 정의된 block은 다음과 같이 사용할 수 있습니다.

	NSMutableArray *tmpArr = [[NSMutableArray alloc]init];
	[tmpArr addObject:^(int i){ NSLog(@"Result : %d", i);}];
	
	myBlockType c = ^(int i){ NSLog(@"Result : %d", i);};
	[tmpArr addObject:c];
	
	myBlockType b = tmpArr[0];
	myBlockType d = tmpArr[1];
	b(5);
	d(1);

함수에 블록 객체 넘길 때도 typedef를 쓰면 다음과 같이 사용할 수 있습니다.

	typedef int (^myBlockType2)(int);

	- (void)func:(myBlockType2)myBlock
	{
	    int i = myBlock(5);
	    NSLog(@"Result : %d", i);
	}
	
### Block 변수

블록 객체의 body내에서 코드를 작성할 때 인자로 넘어오는 값 말고 외부에 선언되어 있는 변수를 사용해야 할 경우가 있습니다. 일반적으로 외부 변수를 변경없이 사용하고자 하면 상관이 없지만 변수의 값이 변경되는 경우 컴파일러가 에러로 처리합니다. 여러 블록 객체 사이에 값을 공유할 수 있고 블록 함수 내부에서만 지역화를 할 수 있는 변수를 지정하도록 해야 하기 때문입니다.

__block을 명시하여 다음과 같이 사용합니다.

	__block int j = 5;
	void (^m)(void) = ^(void){
        j = j + 5;
        NSLog(@"j : %d", j);
    };
    m();
    NSLog(@"j : %d", j);

블럭 객체안에서 출력된 결과와 뒤에 출력한 로그의 결과 값이 같은 것을 확인 할 수 있습니다.

### 순환 참조 피하기

Block은 객체를 강함 참조로 객체를 가지고 있기 때문에 순환 참조가 발생할 수 있습니다.

다음의 경우에서 순환 참조가 발생합니다.

	@interface XYZBlockKeeper : NSObject
	@property (copy) void (^block)(void);
	@end

	@implementation XYZBlockKeeper
	- (void)configureBlock {
	    self.block = ^{
	        [self doSomething];    // capturing a strong reference to self
	                               // creates a strong reference cycle
	    };
	}
	...
	@end


순환 참조를 발생시키지 않으려면 강함 참조를 약한 참조를 가지는 객체를 생성하여 넘겨주면 순환 참조를 막을 수 있습니다.

	- (void)configureBlock {
	    XYZBlockKeeper * __weak weakSelf = self;
	    self.block = ^{
	        [weakSelf doSomething];   // capture the weak reference
	                                  // to avoid the reference cycle
	    }
	}

만약 self가 이전에 dealloc이 되더라도 블럭에서 호출하면 nil이므로 메모리 누수가 일어나지 않습니다.


### 정리

- 함수를 만들지 않고도 동적으로 코드를 동작 
- 객체로써 저장이 가능
- 강한 참조를 가지므로 순환 참조로 메모리 누수 되는 부분을 방지할 것
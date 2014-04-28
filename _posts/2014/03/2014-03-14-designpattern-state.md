---
layout: post
title: "디자인패턴 - 상태패턴"
description: ""
category: "programming"
tags: [designPattern, pattern, state, class, interface, context, method, if]
---
{% include JB/setup %}

## 들어가기

전략패턴은 객체를 바꾸어 쓸 수 있도록 하여 유연하게 대응하도록 하였습니다. 상태패턴은 내부 상태를 바꿈으로 써 객체에서 행동을 바꾸는 것으로 대응합니다.

## 초기 조건

뽑기 기계의 상태들을 대해 작업하려 합니다.

우선 동전 없음, 동전 있음, 알맹이 매진, 알맹이 판매라는 네 가지 상태가 있습니다.

현재 상태를 저장하기 위한 인스턴스 변수를 만들고 각 상태의 값을 정의합니다.

	const static NSInteger SOLD_OUT = 0;
	const static NSInteger NO_QUARTER = 1;
	const static NSInteger HAS_QUARTER = 2;
	const static NSInteger SOLD = 3;

	NSInteger state = SOLD_OUT;

이 시스템에서 일어날 수 있는 행동은 동전 투입, 동전 반환, 손잡이 돌림, 알맹이 내보냄이 있습니다. 각각의 행동들은 뽑기 기계의 인터페이스라고 할 수 있습니다.

동전 투입에 대한 메소드를 만들수 있습니다.

	 - (void)insertQuarter {
	 	if(state == HAS_QUARTER) {
	 		NSLog(@"동전은 한개만 넣어주세요.");
	 	} else if(state == SOLD_OUT) {
	 		NSLog(@"매진되었습니다. 다음 기회를 이용해주세요.");
	 	} else if(state == SOLD) {
	 		NSLog(@"잠깐만 기다려 주세요. 알맹이가 배출되고 있습니다.");
 		} else if(state == NO_QUARTER) {
 			state = HAS_QUARTER;
 			NSLog(@"동전이 투입되었습니다.");
	 	}
	 }	

조건문을 사용하여 모든 가능한 상태를 확인합니다. 그리고 상태에 따라서 적절한 작업을 처리합니다.

현재 상태는 인스턴스 변수에 저장을 하고 그 값을 써서 모든 행동 및 상태 전환을 처리하도록 하는 코드를 구현해봅니다.

	 // MOGumballMachine.h
 	 #import <Foundation/Foundation.h>
 	 @interface MOGumballMachine : NSObject
 	 -(id)init:(NSInteger)initCount;
 	 @end
 
 	 // MOGumballMachine.m
 	 #import "MOGumballMachine.h"
 
 	 const static NSInteger SOLD_OUT = 0;
 	 const static NSInteger NO_QUARTER = 1;
 	 const static NSInteger HAS_QUARTER = 2;
 	 const static NSInteger SOLD = 3;
 
 	 @interface MOGumballMachine() {
 	     NSInteger state;
 	     NSInteger count;
 	 }
 	 @end
 
 	 @implementation MOGumballMachine
 
 	 -(id)init:(NSInteger)initCount {
 	     self = [super init];
 	     if (self) {
 	         count = initCount;
 	         state = SOLD_OUT;
 	         if (count > 0) {
 	             state = NO_QUARTER;
 	         }
 	     }
 	     return self;
 	 }
 
 	 /**
 	  *  동전이 투입된 경우
 	  */
 	 - (void)insertQuarter{
 	     if(state == HAS_QUARTER) {
 	         NSLog(@"동전은 한개만 넣어주세요.");
 	     } else if(state == SOLD_OUT) {
 	         NSLog(@"매진되었습니다. 다음 기회를 이용해주세요.");
 	     } else if(state == SOLD) {
 	         NSLog(@"잠깐만 기다려 주세요. 알맹이가 배출되고 있습니다.");
 	     } else if(state == NO_QUARTER) {
 	         state = HAS_QUARTER;
 	         NSLog(@"동전이 투입되었습니다.");
 	     }
 	 }
 	 /**
 	  *  사용자가 동전을 반환 받으려고 하는 경우
 	  */
 	 - (void)ejectQuarter {
 	     if(state == HAS_QUARTER) {
 	         NSLog(@"동전이 반환됩니다.");
 	         state = NO_QUARTER;
 	     } else if(state == NO_QUARTER) {
 	         NSLog(@"동전을 넣어주세요.");
 	     } else if(state == SOLD) {
 	         NSLog(@"이미 알맹이를 뽑으셨습니다.");
 	     } else if(state == SOLD_OUT) {
 	         NSLog(@"동전을 넣지 않으셨습니다. 동전이 반환되지 않습니다.");
 	     }
 	 }
 
 	 /**
 	  *  손잡이를 돌리는 경우
 	  */
 	 - (void)turnCrank {
 	     if(state == SOLD) {
 	         NSLog(@"손잡이는 한번만 돌려주세요.");
 	     } else if(state == NO_QUARTER) {
 	         NSLog(@"동전을 넣어주세요.");
 	     } else if(state == SOLD_OUT) {
 	         NSLog(@"매진되었습니다.");
 	     } else if(state == HAS_QUARTER) {
 	         NSLog(@"손잡이를 돌리셨습니다.");
 	         state = SOLD;
 	         [self dispense];
 	     }
 	 }
 
 	 /**
 	  *  알맹이 꺼내기
 	  */
 	 - (void)dispense {
 	     if(state == SOLD) {
 	         NSLog(@"알맹이가 나가고 있습니다.");
 	         count = count - 1;
 	         if (count == 0) {
 	             NSLog(@"더 이상 알맹이가 없습니다.");
 	             state = SOLD_OUT;
 	         } else {
 	             state = NO_QUARTER;
 	         }
 	     } else if(state == NO_QUARTER) {
 	         NSLog(@"동전을 넣어주세요.");
 	     } else if(state == SOLD_OUT) {
 	         NSLog(@"매진입니다.");
 	     } else if(state == HAS_QUARTER) {
 	         NSLog(@"알맹이가 나갈 수 없습니다.");
 	     }
 
 	 }
 
	 @end


위에서 원하는 행동에 대하여 코드를 구현하였습니다. 그런데 이제 또 다른 요청들이 하나씩 들어오기 시작을 합니다.

아까 작성했던 코드를 어떻게 고쳐야 할지 고민이 시작되었습니다.


## 상태 패턴 적용하기

각 상태에서 일어나는 일을 캡슐화하여 별도의 클래스에 넣고 상태를 나타내는 상태 객체에 작업을 넘기도록 구성을 합니다.

다음과 같은 원칙으로 정리할 수 있습니다.

- 모든 행동에 대한 메소드가 들어가 있는 State 인터페이스를 정의
- 모든 상태에 대해서 상태 클래스 구현
- 조건문 코드를 전부 없애고 상태 클래스에 모든 작업을 위임

모든 상태 클래스에서 구현할 State 인터페이스를 생성합니다.

	 // MOState.h
	 #import <Foundation/Foundation.h>
	 #import "MOGumballMachine.h"

	 @interface MOState : NSObject
	 - (void)insertQuarter;
	 - (void)ejectQuarter;
	 - (void)turnCrank;
	 - (void)dispense;
	 @end

State 인터페이스를 상속받는 각각의 상태 클래스를 생성합니다.
	
	 // MOSoldState.h
	 #import "MOState.h"
	 @interface MOSoldState : MOState
	 - (void)insertQuarter;
	 - (void)ejectQuarter;
	 - (void)turnCrank;
	 - (void)dispense;
	 @end
 
 	 // MOSoldState.m
 	 #import "MSoldState.h"
 	 @implementation MOSoldState
 	 - (void)insertQuarter{}
 	 - (void)ejectQuarter{}
 	 - (void)turnCrank{}
 	 - (void)dispense{}
 	 @end
 
 	 // MOSoldOutState.h
 	 #import "MOState.h"
 	 @interface MOSoldOutState : MOState
 	 - (void)insertQuarter;
 	 - (void)ejectQuarter;
 	 - (void)turnCrank;
 	 - (void)dispense;
 	 @end
 
 	 // MOSoldOutState.m
 	 #import "MOSoldOutState.h"
 	 @implementation MOSoldOutState
 	 - (void)insertQuarter{}
 	 - (void)ejectQuarter{}
 	 - (void)turnCrank{}
 	 - (void)dispense{}
 	 @end
 
 	 // MONoQuarterState.h
 	 #import "MOState.h"
 	 @interface MONoQuarterState : MOState
 	 - (void)insertQuarter;
 	 - (void)ejectQuarter;
 	 - (void)turnCrank;
 	 - (void)dispense;
 	 @end
 
 	 // MONoQuarterState.m
 	 #import "MONoQuarterState.h"
 	 @implementation MONoQuarterState
 	 - (void)insertQuarter{}
 	 - (void)ejectQuarter{}
 	 - (void)turnCrank{}
 	 - (void)dispense{}
 	 @end
 
 	 // MOHasQuarterState.h
 	 #import "MOState.h"
 	 @interface MOHasQuarterState : MOState
 	 - (void)insertQuarter;
 	 - (void)ejectQuarter;
 	 - (void)turnCrank;
 	 - (void)dispense;
 	 @end
 
 	 // MOHasQuarterState.m
 	 #import "MOHasQuarterState.h"
 	 @implementation MOHasQuarterState
 	 - (void)insertQuarter{}
 	 - (void)ejectQuarter{}
 	 - (void)turnCrank{}
 	 - (void)dispense{}
 	 @end

각각의 상태들을 구현을 하고 이제 내부 구현을 시작합니다.

첫번째로 MONoQuarterState 상태 클래스를 살펴봅시다.

	 // MONoQuarterState.h
	 #import "MOState.h"
	 @interface MONoQuarterState : MOState
	 - (id)init:(MOGumballMachine *)gumballMachine;
	 - (void)insertQuarter;
	 - (void)ejectQuarter;
	 - (void)turnCrank;
	 - (void)dispense;
	 @end
	 
	 // MONoQuarterState.m
	 #import "MONoQuarterState.h"
	 
	 @interface MONoQuarterState ()
	 @property (nonatomic) MOGumballMachine *gumballMachine;
	 @end
	 
	 @implementation MONoQuarterState
	 - (id)init:(MOGumballMachine *)gumballMachine {
	     self = [super init];
	     if (self) {
	         self.gumballMachine = gumballMachine;
	     }
	     return self;
	 }
	 - (void)insertQuarter {
	     NSLog(@"동전을 넣으셨습니다.");
	     [self.gumballMachine setState:[self.gumballMachine getHasQuarterState]];
	 }
	 - (void)ejectQuarter {
	     NSLog(@"동전을 넣어주세요.");
	 }
	 - (void)turnCrank {
	     NSLog(@"동전을 넣어주세요.");
	 }
	 - (void)dispense {
	     NSLog(@"동전을 넣어주세요.");
	 }
	 
	 @end

MONoQuarterState 상태 클래스는 동전이 없는 상태를 나타내는 클래스입니다. 따라서 insertQuarter 메소드에서만 '동전을 넣으셨습니다.'라는 메시지를 출력하며 HasQuarterState로 상태를 전환를 하며 다른 메소드에서는 '동전을 넣어주세요.' 라는 메시지를 출력합니다.

그리고 상태와 관련된 인스턴스 변수를 정수형태에서 객체를 사용하는 방식으로 변경합니다.

	 // 변경 전
	 const static NSInteger SOLD_OUT = 0;
	 const static NSInteger NO_QUARTER = 1;
	 const static NSInteger HAS_QUARTER = 2;
	 const static NSInteger SOLD = 3;

	 NSInteger state = SOLD_OUT;
	 NSInteger count = 0;

	 // 변경 후
	 MOState *soldOutState;
	 MOState *noQuarterState;
	 MOState *hasQuarterState;
	 MOState *soldState;

	 MOState *state = soldOutState;
	 NSInteger count = 0;

</br/>이제 MOGumballMachine 클래스에 상태패턴을 적용하여 구현합니다.
 
 	 // MOGumballMachine.h
  	 #import <Foundation/Foundation.h>
 
  	 @class MOState;
  	 @interface MOGumballMachine : NSObject
 
  	 @property MOState* state;
  	 - (id)init:(NSInteger)count;
 	 - (void)insertQuarter;
 	 - (void)ejectQuarter;
 	 - (void)turnCrank;
 	 - (void)releaseBall;
 	 - (void)refill:(NSInteger)count;
 	 - (id)getState;
 	 - (id)getSoldOutState;
 	 - (id)getNoQuarterState;
 	 - (id)getHasQuarterState ;
 	 - (id)getSoldState;
  	 @end
 
  
  	 // MOGumballMachine.m
  	 #import "MOGumballMachine.h"
 	 #import "MOState.h"
 
  	 @interface MOGumballMachine()
 
  	 @property (nonatomic) MOState *soldOutState;
 	 @property (nonatomic) MOState *noQuarterState;
 	 @property (nonatomic) MOState *hasQuarterState;
 	 @property (nonatomic) MOState *soldState;
 
  	 @property (nonatomic) NSInteger count;
 
  	 @end
 
  	 @implementation MOGumballMachine
 
  	 -(id)init {
 	     self = [super init];
 	     if (self) {
 	         [self initialize];
 	         [self setState:self.soldOutState];
 	         self.count = 0;
 	     }
 	     return self;
 	 }
 
  	 -(id)init:(NSInteger)count {
 	     self = [super init];
 	     if (self) {
 	         [self initialize];
 	         self.count = count;
 	         [self setState:self.soldOutState];
 	         if (count > 0) {
 	             self.state = self.noQuarterState;
 	         }
 	     }
 	     return self;
 	 }
 
  	 - (void)initialize {
 	     self.soldOutState = [[MOState alloc]init];
 	     self.noQuarterState = [[MOState alloc]init];
 	     self.hasQuarterState = [[MOState alloc]init];
 	     self.soldState = [[MOState alloc]init];
 	 }
 
  	 /**
 	  *  동전이 투입된 경우
 	  */
 	 - (void)insertQuarter {
 	     [self.state insertQuarter];
 	 }
 	 /**
 	  *  사용자가 동전을 반환 받으려고 하는 경우
 	  */
 	 - (void)ejectQuarter {
 	     [self.state ejectQuarter];
 	 }
 
  	 /**
 	  *  손잡이를 돌리는 경우
 	  */
 	 - (void)turnCrank {
 	     [self.state turnCrank];
 	 }
 
  	 - (void)releaseBall {
 	     NSLog(@"A gumball comes rolling out the slot...");
 	     if(self.count != 0) {
 	         self.count -= 1;
 	     }
 	 }
 
  	 - (void)refill:(NSInteger)count {
 	     self.count = count;
 	 }
 
  	 - (id)getState {
 	     return self.state;
 	 }
 
  	 - (id)getSoldOutState {
 	     return self.soldOutState;
 	 }
 
  	 - (id)getNoQuarterState {
 	     return self.noQuarterState;
 	 }
 
  	 - (id)getHasQuarterState {
 	     return self.hasQuarterState;
 	 }
 
  	 - (id)getSoldState {
 	     return self.soldState;
 	 }
 
  	 @end
 
<br/> HasQuarterState와 SoldState 상태 클래스를 구현합니다.

	 
	 // MOHasQuarterState.h
	 #import "MOState.h"

	 @interface MOHasQuarterState : MOState
	 - (id)init:(MOGumballMachine *)gumballMachine;
	 - (void)insertQuarter;
	 - (void)ejectQuarter;
	 - (void)turnCrank;
	 - (void)dispense;
	 @end


	 // MOHasQuarterState.m
	 #import "MOHasQuarterState.h"

	 @interface MOHasQuarterState ()
	 @property (nonatomic) MOGumballMachine *gumballMachine;
	 @end

	 @implementation MOHasQuarterState
	 - (id)init:(MOGumballMachine *)gumballMachine
	 {
	     self = [super init];
	     if (self) {
	         self.gumballMachine = gumballMachine;
	     }
	     return self;
	 }
	 - (void)insertQuarter {
	     NSLog(@"동전은 한 개만 넣어주세요.");
	 }
	 - (void)ejectQuarter {
	     NSLog(@"동전이 반환됩니다.");
	     [self.gumballMachine setState:[self.gumballMachine getNoQuarterState]];
	 }
	 - (void)turnCrank {
	     NSLog(@"손잡이를 돌리셨습니다.");
	     [self.gumballMachine setState:[self.gumballMachine getSoldState]];
	 }
	 - (void)dispense {
	     NSLog(@"알맹이가 나갈 수 없습니다.");
	 }
	 @end


	 // MOSoldState.h
	 #import "MOState.h"

	 @interface MOSoldState : MOState
	 - (void)insertQuarter;
	 - (void)ejectQuarter;
	 - (void)turnCrank;
	 - (void)dispense;
	 @end


	 // MOSoldState.m
	 #import "MOSoldState.h"

	 @interface MOSoldState ()
	 @property (nonatomic) MOGumballMachine *gumballMachine;
	 @end

	 @implementation MOSoldState

	 - (id)init:(MOGumballMachine *)gumballMachine
	 {
	     self = [super init];
	     if (self) {
	         self.gumballMachine = gumballMachine;
	     }
	     return self;
	 }

	 - (void)insertQuarter {
	     NSLog(@"잠깐만 기다려 주세요. 알맹이가 나가고 있습니다.");
	 }
	 - (void)ejectQuarter {
	     NSLog(@"이미 알맹이를 뽑으셨습니다.");
	 }
	 - (void)turnCrank {
	     NSLog(@"손잡이는 한 번만 돌려주세요.");
	 }
	 - (void)dispense {
	     [self.gumballMachine releaseBall];
	     if ([self.gumballMachine getCount] > 0) {
	         [self.gumballMachine setState:[self.gumballMachine getNoQuarterState]];
	     } else {
	         NSLog(@"Oops, out of gumballs");
	         [self.gumballMachine setState:[self.gumballMachine getSoldOutState]];
	     }
	 }
	 @end

<br/> 마지막으로 열번에 한 번 알맹이를 주는 상태를 구현해 봅시다.
우선 MOGumballMachine에 winnerState를 추가합니다.

	 // MOGumballMachine.m
	 @property (nonatomic) MOState *winnerState;

	 // MOWinnerState.h
	 #import "MOState.h"

	 @interface MOWinnerState : MOState
	 - (id)init:(MOGumballMachine *)gumballMachine;
	 - (void)insertQuarter;
	 - (void)ejectQuarter;
	 - (void)turnCrank;
	 - (void)dispense;
	 @end


	 // MOWinnerState.m
	 #import "MOWinnerState.h"

	 @interface MOWinnerState ()
	 @property (nonatomic) MOGumballMachine *gumballMachine;
	 @end

	 @implementation MOWinnerState
	 - (id)init:(MOGumballMachine *)gumballMachine {
	     self = [super init];
	     if (self) {
	         self.gumballMachine = gumballMachine;
	     }
	     return self;
	 }
	 - (void)insertQuarter {
	     NSLog(@"잠깐만 기다려 주세요. 알맹이가 나가고 있습니다.");
	 }
	 - (void)ejectQuarter {
	     NSLog(@"이미 알맹이를 뽑으셨습니다.");
	 }
	 - (void)turnCrank {
	     NSLog(@"손잡이는 한 번만 돌려주세요.");
	 }
	 - (void)dispense {
	     NSLog(@"축하드립니다! 알맹이를 하나 더 받을 수 있습니다.");
	     [self.gumballMachine releaseBall];
	     if ([self.gumballMachine getCount] == 0) {
	         [self.gumballMachine setState:[self.gumballMachine getSoldOutState]];
	     } else {
	         [self.gumballMachine releaseBall];
	         if ([self.gumballMachine getCount] > 0) {
	             [self.gumballMachine setState:[self.gumballMachine getNoQuarterState]];
	         } else {
	             NSLog(@"더 이상 알맹이가 없습니다.");
	             [self.gumballMachine setState:[self.gumballMachine getSoldOutState]];
	         }
	     }
	 }
	 @end

	 // MOHasQuarterState.m
	 - (void)turnCrank {
	     NSLog(@"손잡이를 돌리셨습니다.");
	     int random = rand() % 10;
	     
	     if ((random == 0) && ([self.gumballMachine getCount] > 1) ){
	         [self.gumballMachine setState:[self.gumballMachine getWinnerState]];
	     } else {
	         [self.gumballMachine setState:[self.gumballMachine getSoldState]];
	     }
	 }

새로운 상태 클래스 MOWinnerState를 추가하였고 당첨여부를 결정하고 상태를 전환하는 코드를 추가를 하였습니다.

따라서 조건문 if문을 사용하지 않고서도 새로운 상태를 쉽게 추가하였습니다.



## 정리하기

위에서 상태 패턴을 통해 다음과 같은 이점을 얻었습니다.

- 각 행동을 클래스로 만들어 고립시켜 외부로부터 오염을 막습니다.
- 조건문 if를 제거하였습니다.
- 각 상태에 대해서 닫혀 있지만 MOGumballMachine는 새로운 상태 클래스를 추가할 수 있는 확장성을 얻었습니다.

따라서 특정 행동이 호출되면 그 행동은 저장을 하며 상태 클래스에서 메소드를 호출하게 되므로 각 상태에 맞는 행동을 하게 됩니다.

## 상태 패턴의 정의

상태패턴을 이용하면 객체의 내부 상태가 바뀜에 따라서 객체의 행동을 바꿀 수 있습니다. 즉, 상태를 별도의 클래스로 캡슐화한 다음 현재 상태를 나타내는 객체에게 행동을 위임하기 때문에, 내부 상태가 바뀜에 따라서 행동이 달라지게 됩니다. 

뽑기 기계가 NoQuarterState에 있을 때 동전을 집어 넣는 경우 HasQuarterState에 있을 때 동전을 집어 넣는 경우에 각각 다른 결과가 나옵니다. 구성을 통해 여러 상태 객체를 바꿔가면서 사용하기 때문에 이러한 결과를 얻을 수 있습니다.



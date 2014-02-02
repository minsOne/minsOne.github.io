---
layout: post
title: "[CoreData]MagicalRecord을 이용한 CoreData를 조금 더 쉽게 사용하기"
description: ""
categories: [iOS, Mac, CoreData]
tags: [iOS, Mac, CoreData, MagicalRecord]
---
{% include JB/setup %}

Core Data를 사용하는 데 있어 어떻게 사용하는지, 이렇게 사용하는게 맞는 것인지 헤깔리는 경우가 많습니다. 저같은 초보 개발자들은 iOS를 공부하는데 Core Data라는 기능은 있지만 사용하기 까다로운 부분이기도 합니다.

이런 부분을 MagicalRecord라는 라이브러리를 이용하여 SQL처럼 좀 더 쉽게 사용할 수 있습니다.

---

## 시작하기

[MagicalRecord](https://github.com/magicalpanda/MagicalRecord)에서 프로젝트를 다운받습니다.

프로젝트 안에 있는 MagicalRecord 폴더를 사용할 프로젝트에 import합니다.

프로젝트의 `Prefix.pch`파일에 `CoreData+MagicalRecord.h`을 추가하여 전역으로 사용할 수 있도록 합니다.

Core Data를 사용할 부분, awakeFromNib 또는 `application:didFinishLaunchingWithOptions:`에 Core Data를 사용하기 전에 데이터베이스 파일이 있는지 찾고 없으면 기본 저장 파일을 복사합니다.

	NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *storeURL = [NSPersistentStore MR_urlForStoreName:DBName];
    NSLog(@"URL : %@", storeURL);

	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:[storeURL path]]){
		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:[DBName stringByDeletingPathExtension] ofType:[DBName pathExtension]];
		if (defaultStorePath){
            	NSError *error;
			BOOL success = [fileManager copyItemAtPath:defaultStorePath toPath:[storeURL path] error:&error];
            	if (!success){
        	        	NSLog(@"Failed to install default recipe store");
            	} else {
	        	        NSLog(@"Success");
    	        }
		}
	}
MagicalRecord Class를 사용하여 설정을 합니다.
	
	 + (void) setupCoreDataStack;
	 + (void) setupAutoMigratingCoreDataStack;
	 + (void) setupCoreDataStackWithInMemoryStore;
	 + (void) setupCoreDataStackWithStoreNamed:(NSString *)storeName;
	 + (void) setupCoreDataStackWithAutoMigratingSqliteStoreNamed:(NSString *)storeName;

`setupCoreDataStack`은 기본적인 Core Data Stack을 설정할 때 사용합니다. Stack에는 NSPersistentStore, NSPersistentStoreCoordinate, NSManagedObjectModel, NSManagedObjectContext이 포함이 되며 SQLite 영구저장소가  /Library/Application Support//.sqlite에 생성됩니다.

`setupAutoMigratingCoreDataStack`은 데이터 마이그레이션이 필요할 때 사용합니다. setupCoreDataStack와 같은 역할을 하지만 추가적으로 자동으로 데이터 마이그레이션이 가능합니다.

`setupCoreDataStackWithInMemoryStore`는 unit test를 할 때 사용합니다. unit test는 반복적으로 앱을 껐다 켰다 하므로 영구저장소를 RAM에 생성시켜 바로 데이터를 파일에서 로딩할 필요 없이 사용할 수 있게 합니다.

`setupCoreDataStackWithStoreNamed`는 처음에 SQLite 영구 저장소를 생성할 때 만든 이름으로 불러서 사용합니다.

`setupCoreDataStackWithAutoMigratingSqliteStoreNamed`는 특정 이름으로 만들어진 SQLite 파일을 불러오고 자동으로 데이터 마이그레이션이 가능합니다.

[**Core Data의 데이터 마이그레이션 참고**](https://developer.apple.com/library/mac/documentation/cocoa/conceptual/CoreDataVersioning/Articles/Introduction.html)

그리고 어플리케이션을 종료하기 전에 `applicationWillTerminate:`에 MagicalRecord Class를 사용하여 MagicalRecord을 정리합니다.

	[MagicalRecord cleanUp];

---

## Core Data Logging 보기

`Scheme`에 `Arguments Passed On Launch`항목에 다음을 추가하면 Core Data를 사용할 때 쿼리를 확인할 수 있습니다.

	-com.apple.CoreData.SQLDebug

---

## Core Data SQLite 파일 삭제하기

SQLite 파일을 삭제하고 초기화 하는 경우가 있습니다. 이 경우에는 다음과 같이 사용하면 됩니다.

    NSString *dbStore = DBName;
    NSError *error = nil;
    NSURL *storeURL = [NSPersistentStore MR_urlForStoreName:dbStore];
    [MagicalRecord cleanUp];
    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];

---

## 가져오기

MagicalRecord에서는 데이터를 `NSArray` 타입으로 반환하며 해당 Entity 클래스로 구성된 객체로 되어 있습니다. 예를 들면 Bank라는 `Entity`에 대한 정보들 가져올 경우 다음과 같이 사용합니다.
	
	//일반적으로 사용하는 경우
	NSArray *bankInfos = [Bank MR_findAll];

	//"#define MR_SHORTHAND"를 pch 파일에 정의한 경우
	NSArray *bankInfos = [Bank findAll];	

	//특정 `property`에 대해 정렬할 경우
	NSArray *bankInfos = [Bank MR_findAllSortedBy:@"bankName" ascending:YES];

	//여러 `property`에 대해 정렬할 경우
	NSArray *bankInfos = [Bank MR_findAllSortedBy:@"bankName,bankId" ascending:YES];

아니면 하나의 정보만 가져오려고 하려면 다음과 같이 사용합니다.

	//검색된 가장 첫번째 결과
	Bank *bankInfo = [Bank MR_findFirst];

	//은행 이름이 woori라는 값을 가진 객체를 반환
	Bank *bankInfo = [Bank MR_findFirstByAttribute:@"bankName" withValue:@"woori"];

또한, 특정 Context안에서 다음과 같이 사용합니다.

	// MagicalRecord Block안에서 localContext으로 사용.
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		NSArray *bankInfos = [Bank MR_findAllInContext:localContext];
		} completion:^(BOOL success, NSError *error) {  
    }];

    //전역 Context로 사용
    NSManagedObjectContext *managedContext = ...;
    NSArray *bankInfos = [Bank MR_findAllInContext:managedContext];

SQL문에서 Where절을 통해 조건문을 만들어 원하는 조건에 해당하는 결과들을 가져올 수 있었습니다. 마찬가지로 Core Data에서는 `NSPredicate`를 통해 조건문을 만들 수 있습니다.

	NSPredicate *bankPredicate = [NSPredicate predicateWithFormat:@"bankId = %d", 20];
	NSArray *bankInfos = [Bank MR_findAllWithPredicate:bankPredicate];

또한, 특정 Context안에서 다음과 같이 사용합니다.

	// MagicalRecord Block안에서 localContext으로 사용.
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		NSArray *bankInfos = [Bank MR_findAllWithPredicate:bankPredicate inContext:localContext];
	} completion:^(BOOL success, NSError *error) {
    }];

	//전역 Context로 사용
	NSManagedObjectContext *managedContext = ...;
	NSArray *bankInfos = [Bank MR_findAllWithPredicate:bankPredicate inContext:managedContext];

SQL에 Count함수처럼 MagicalRecord에서 다음처럼 사용할 수 있습니다.

	//Bank 객체의 갯수 반환
	NSNumber *bankCount = [Bank MR_numberOfEntities];

	//조건문을 추가하여 사용
	NSNumber *count = [Person MR_numberOfEntitiesWithPredicate:bankPredicate];

또한, 특정 Context안에서 다음과 같이 사용합니다.

	// MagicalRecord Block안에서 localContext으로 사용.
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		NSNumber *bankCount = [Bank MR_numberOfEntitiesWithContext:localContext];
		NSNumber *count = [Person MR_numberOfEntitiesWithPredicate:bankPredicate];
	} completion:^(BOOL success, NSError *error) {
    }];

	//전역 Context로 사용
	NSManagedObjectContext *managedContext = ...;
	NSNumber *bankCount = [Bank MR_numberOfEntitiesWithContext:localContext];
	NSNumber *count = [Person MR_numberOfEntitiesWithPredicate:bankPredicate inContext:managedContext];


**NSManagedObjectContext**: Managed Object Context는 Core Data Application의 스케치북같은 것입니다. 객체를 생성하거나 Managed object를 가져오기도 하고 삭제할 수 있습니다. Context는 영구저장소를 표현하는 managed object입니다.

---

### Entity 만들기

`Entity`의 객체를 생성할 때 다음과 같이 사용합니다.

	Bank *bankInstance = [Bank MR_createEntity];

또한, 특정 Context안에서 다음과 같이 사용합니다.

	// MagicalRecord Block안에서 localContext으로 사용.
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		Bank *bankInstance = [Bank MR_createInContext:localContext];
	} completion:^(BOOL success, NSError *error) {
    }];
	
	//전역 Context로 사용
	NSManagedObjectContext *managedContext = ...;
	Bank *bankInstance = [Bank MR_createInContext:managedContext];

---

### Entity 삭제하기

위에서 Core Data에 저장된 데이터 객체를 가져온 후에 해당 객체를 삭제하려 할 때 다음과 같이 사용합니다.

	Bank *bankInfo = [Bank MR_findFirst];
	[bankInfo MR_deleteEntity];

또한, 특정 Context안에서 다음과 같이 사용합니다.

	// MagicalRecord Block안에서 localContext으로 사용.
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		Bank *bankInfo = [Bank MR_findFirstInContext:localContext];
		[bankInfo MR_deleteInContext:localContext];
	} completion:^(BOOL success, NSError *error) {
    }];

	//전역 Context로 사용
	NSManagedObjectContext *managedContext = ...;
	Bank *bankInfo = [Bank MR_findFirstInContext:managedContext];
	[bankInfo MR_deleteInContext:managedContext];

Core Data에 특정 `Entity` 객체들을 삭제하기 위해선 다음과 같이 사용합니다.

	[Bank MR_truncateAll];

---	

### Entity 갱신하기

Core Data에 저장된 데이터 객체를 가져온 후에 Property 값을 변경하면 Update가 됩니다.

	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		Bank *bankInfo = [Bank MR_findFirstInContext:localContext];
		bankInfo.bankName = @"나쁜은행";
	} completion:^(BOOL success, NSError *error) {
    }];

---
layout: post
title: "[Objc]NSOperation과 NSOperationQueue를 사용하는 방법 - 설명 및 예제"
description: ""
category: "iOS"
tags: [ios, KVO, NSOperation, NSOperationQueue, AFNetworking, AFHTTPRequestOperation, GCD, tableview, cell]
---
{% include JB/setup %}

백그라운드로 작업을 수행하는 방법은 NSThread, GCD, NSOperation 등이 있습니다. NSOperation은 NSOperationQueue로, GCD는 dispatch queue를 통해서 각각의 작업들을 관리를 할 수 있습니다.

그러나 둘의 차이는 GCD는 C API라는 점, NSOperationQueue는 Objective C API 라는 점입니다. 따라서 NSOperationQueue는 좀 더 무겁습니다. 그러나 NSOperationQueue를 사용할 경우 몇가지 장점이 있습니다.

### 작업 취소

NSOperationQueue는 NSOperation의 Cancel을 통해 작업을 취소할 수 있도록 제어가 가능합니다. 하지만 GCD는 기조가 실행하고 잊어버리기때문에 취소를 구현할 수 있지만 부수적인 코드가 많이 작성됩니다.

### KVO

NSOperation은 isCancelled, isFinished등 작업의 상태가 변경되었는지를 알 수 있으며 좀 더 세세한 작업을 할 수 있습니다.

### 작업의 재사용

NSOperation의 자식 클래스를 만들어서 원하는 형태로 작업이 가능하며 작업이 끝나더라도 재사용할 수 있습니다.

### 작업 우선순위

각 작업은 우선순위가 있으며 작업들간의 우선순위를 매깁니다. 우선순위가 높은 작업이 우선순위가 낮은 작업보다 먼저 수행이 됩니다. GCD도 우선순위를 가지지만 같은 작업에 대해서는 직접적인 방법은 없으며, 개별 블럭이 아닌 전체 큐에 대한 우선순위를 설정합니다.

### 작업 간의 의존성

작업이 수행한 후 다른 작업이 수행할 수 있도록 작업 계층을 만들 수 있습니다.

<br/><br/>
# NSOperation, NSOperationQueue를 이용한 동시 작업 수행

## 작업 생성

NSOperation을 상속을 받아 생성을 합니다.

	// MyLengthOperation.h
	#import <Foundation/Foundation.h>
	@interface MyLengthOperation : NSOperation
	@end

	// MyLengthOperation.m
	#import "MyLengthOperation.h"
	@implementation MyLengthOperation

	 - (void)main
	{
	    for (int i = 0; i < 1000; i++) {
	        if ( self.isCancelled ) {
	            break;
	        }
	        NSLog(@"%f", sqrt(i));
	    }
	}

	@end

<br/>NSOperation 상태 isCancelled, isReady, isFinished, isExecuting를 얻을 수 있으며 상태에 따라 로직을 분리하여 처리하기 쉽습니다.

NSOperation 객체를 생성 한 후 start, cancel 메소드를 수행하여 상태를 변경할 수 있습니다.

    MyLengthOperation *mylengthOperation = [[MyLengthOperation alloc]init];
    .
    .
    [mylengthOperation cancel];

<br/>일반적으로 NSOperation의 start 메소드는 override하지 않으며, 만약 한다면 isExecuting, isFinished, isConcurrent, isReady의 속성을 모두 관리를 해줘야 하므로 많이 복잡해 집니다.

작업간의 의존성을 부여하고자 한다면 addDependency 메소드를 통해서 작업이 끝난 후 수행할 특정 작업을 추가할 수 있습니다. 만약 제거할려면 removeDependency를 통해서 제거할 수 있습니다.

	MyLengthOperation *mylengthOperation = [[MyLengthOperation alloc]init];
	MyCalcOperation *calcOperation = [[MyCalcOperation alloc]init];

	[mylengthOperation addDependency:calcOperation];

<br/> 또한, dependency 말고도 setCompletionBlock 메소드로 block을 등록하면 작업이 완료된 후에 block을 수행하게 됩니다.

    MyLengthOperation *mylengthOperation = [[MyLengthOperation alloc]init];
    [mylengthOperation setCompletionBlock:^{
        NSLog(@"Complete");
    }];
    [mylengthOperation start];

## 작업 관리

NSOperation은 NSOperationQueue로 관리하며 손쉽게 사용할 수 있습니다.

	NSOperationQueue *queue = [[NSOperationQueue alloc]init];
	queue.name = @"Init Queue";

NSOperationQueue는 많은 쓰레드를 제어가능하며 또한, 동시에 수행 가능한 작업 수도 제어 가능합니다.

    [queue setMaxConcurrentOperationCount:3];

MaxConcurrentOperationCount를 통하여 수행 가능한 작업의 수를 지정합니다.

NSOperationQueue에 addOperation메소드를 통해 수행할 작업을 추가합니다.

    [queue addOperation:mylengthOperation];

현재 작업중인 내역을 가지고 오려면 operations 메소드를 통해서 NSArray 타입으로 얻을 수 있습니다.

    NSArray *operaionQueue = [queue operations];

이렇게 얻은 작업은 제어가 가능하게 됩니다.

NSOperationQueue를 pause나 suspend 상태로 가능하며 모든 작업들을 한번에 취소도 할 수 있습니다.

	[queue setSuspended:YES];   // Suspend
	[queue setSuspended:NO];    // Resume

	[queue cancelAllOperations];	// All Operation Cancel


굳이 NSOperation의 SubClass를 만들 필요 없이 Block으로 작업을 만들어 NSOperationQueue에 추가할 수 있습니다.

	[queue addOperationWithBlock:^{
	    int i = 0;
	    for (; i < 10; i++) {
	        NSLog(@"%d", i * i);
	    }
	}];

만약 UI에 해당하는 작업인 경우 mainThread에서 처리하도록 합니다.

    [[NSOperationQueue mainQueue] addOperation:mylengthOperation];

항상 명심해야 할 것은 UI에 관련된 부분은 mainThread에서, 데이터 처리 등의 작업은 Thread에서 처리하여 UI Block이 되는 것을 피하도록 합니다.

<br/>
---

## 컨텐츠 목록 다운로드 처리 작업

실제로 작업을 만들어 수행을 하도록 해봅시다.

우선 작업할 내용은 다음과 같습니다.

- 테이블뷰에서 컨텐츠 목록을 가져옵니다.
- 테이블뷰가 목록을 가지고 Row를 그릴 수 있도록 합니다.
- 각각의 Row마다 이미지를 다운받아 보이도록 합니다.
- 보여진 이미지는 filter를 거쳐 보이도록 합니다.

기본적인 테이블뷰를 만들어봅시다.

	// ListViewController.h
	#import <UIKit/UIKit.h>
	@interface ListViewController : UITableViewController
	@end

	// ListViewController.m
	#import "ListViewController.h"
	@implementation ListViewController
	 - (void)viewDidLoad
	{
	}

	 - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
	{
        return self.photos ? [self.photos count] : 0;
	}

	 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
	{
	    return 80.0f;
	}

	 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
	{
	    static NSString *kCellIdentifier = @"Cell Identifier";
	    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	    if (!cell) {
	        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
	        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	    }
	    return cell;
	}
	@end

<br/>
테이블에 보일 데이터 파일을 내려받고 다시 테이블 뷰를 reload를 하여 화면에 데이터가 보일 수 있도록 합니다.
네트워크 요청하는 부분은 `AFNetworking의 AFHTTPRequestOperation`으로 작업을 만들어 처리합니다.

	// ListViewController.h
	#import <UIKit/UIKit.h>
	#import "AFNetworking/AFNetworking.h"
	#define kDatasourceURLString @"https://sites.google.com/site/soheilsstudio/tutorials/nsoperationsampleproject/ClassicPhotosDictionary.plist"
	@interface ListViewController : UITableViewController

	@property (nonatomic, strong) NSMutableArray *photos; // main data source of controller

	@end

	// ListViewController.m
	#import "ListViewController.h"
	@implementation ListViewController

	// Lazy Instance to load data source.
	 - (NSDictionary *)photos {

 	    if (!_photos) {
		 	NSURL *datasourceURL = [NSURL URLWithString:kDatasourceURLString];
	        NSURLRequest *request = [NSURLRequest requestWithURL:datasourceURL];

	        AFHTTPRequestOperation *datasource_download_operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

	        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

	        [datasource_download_operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
	        	NSData *datasource_data = (NSData *)responseObject;
	        	CFPropertyListRef plist =  CFPropertyListCreateFromXMLData(kCFAllocatorDefault, (__bridge CFDataRef)datasource_data, kCFPropertyListImmutable, NULL);

	        	NSDictionary *datasource_dictionary = (__bridge NSDictionary *)plist;

	        	NSMutableArray *records = [NSMutableArray array];

	            for (NSString *key in datasource_dictionary) {
	                PhotoRecord *record = [[PhotoRecord alloc] init];
	                record.URL = [NSURL URLWithString:[datasource_dictionary objectForKey:key]];
	                record.name = key;
	                [records addObject:record];
	                record = nil;
	            }

	            self.photos = records;

	            [self.tableView reloadData];
	            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

	        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
	        	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
	                                                            message:error.localizedDescription
	                                                           delegate:nil
	                                                  cancelButtonTitle:@"OK"
	                                                  otherButtonTitles:nil];
	            [alert show];
	            alert = nil;
	            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	        }];

            [datasource_download_operation start];
		}

		return _photos;
	}


photo 프로퍼티가 존재하지 않을 경우 AFHTTPRequestOperation를 통해서 데이터를 받는 작업을 자세하게 풀어봅시다.

1.plist파일의 주소를 NSURLRequest로 만들어서 AFHTTPRequestOperation 작업으로 만듭니다.

<pre><code class="objectivec">NSURL *datasourceURL = [NSURL URLWithString:kDatasourceURLString];
NSURLRequest *request = [NSURLRequest requestWithURL:datasourceURL];
AFHTTPRequestOperation *datasource_download_operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
</code></pre>
<br/>

2.상태바에 네트워크 사용중이라고 NetworkActivityIndicator를 보여줍니다.

<pre><code class="objectivec">
[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
</code></pre><br/>

3.AFHTTPRequestOperation작업에서 setCompletionBlockWithSuccess, failure에서 동작할 block 코드를 작성합니다.

<pre><code class="objectivec">
datasource_download_operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
}];
</code></pre><br/>

4.정상적으로 데이터를 받은 경우의 block 코드를 설명합니다.

4-1.데이터는 responseObject에 있고 plist 데이터를 파싱하여 nsdictionary로 데이터를 만듭니다.

<pre><code class="objectivec">
NSData *datasource_data = (NSData *)responseObject;
CFPropertyListRef plist =  CFPropertyListCreateFromXMLData(kCFAllocatorDefault,
                                                           (__bridge CFDataRef)datasource_data,
                                                           kCFPropertyListImmutable,
                                                           NULL);
NSDictionary *datasource_dictionary = (__bridge NSDictionary *)plist;
</code></pre><br/>


4-2.NSDictionary의 값을 NSMutableArray로 만들어 photo 프로퍼티에 저장하고 테이블뷰를 reloadData 호출하여 갱신합니다.

<pre><code class="objectivec">NSMutableArray *records = [NSMutableArray array];

for (NSString *key in datasource_dictionary) {
    PhotoRecord *record = [[PhotoRecord alloc] init];
    record.URL = [NSURL URLWithString:[datasource_dictionary objectForKey:key]];
    record.name = key;
    [records addObject:record];
    record = nil;
}

self.photos = records;

[self.tableView reloadData];
[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
</code></pre><br/>

5.데이터를 받지 못한 경우의 block 코드를 설명합니다.

5-1.alert뷰를 띄우고 NetworkActivityIndicator를 내립니다.

<pre><code class="objectivec">UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                message:error.localizedDescription
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
[alert show];
alert = nil;
[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
</code></pre><br/>

6.위의 작업을 수행하도록 합니다.

<pre><code class="objectivec">[datasource_download_operation start];
</code></pre><br/>

위에서 컨텐츠 목록을 다운받아서 처리하는 작업을 설명하였습니다.
<br/>

## 이미지 다운로드 및 필터 처리 작업

이미지 다운로드 후 필터 처리하여 테이블 뷰에 보이도록 하는 과정을 설명합니다.

1.우선 다운로드 받을 URL, 이미지 이름, 다운로드 받은 이미지, 다운로드 여부, 필터 여부를 가진 데이터 모델을 먼저 만듭니다.

	//  PhotoRecord.h
	#import <UIKit/UIKit.h>
	@interface PhotoRecord : NSObject

	@property (nonatomic, strong) NSString *name;  // 이미지 이름
	@property (nonatomic, strong) UIImage *image; // 다운받은 이미지
	@property (nonatomic, strong) NSURL *URL; // 이미지 URL
	@property (nonatomic, readonly) BOOL hasImage; // 이미지가 다운로드 되었는지 여부
	@property (nonatomic, getter = isFiltered) BOOL filtered; // 이미지 필터가 되었는지 여부
	@property (nonatomic, getter = isFailed) BOOL failed; // 다운로드 실패 여부

	//  PhotoRecord.m
	#import "PhotoRecord.h"

	@implementation PhotoRecord

	 - (BOOL)hasImage {
	    return _image != nil;
	}

	 - (BOOL)isFailed {
	    return _failed;
	}

	 - (BOOL)isFiltered {
	    return _filtered;
	}

<br/>

2.이미지 다운로드 및 이미지를 필터 처리하는 작업 큐를 관리하는 모델을 만듭니다.

	//  PendingOperations.h
	#import <Foundation/Foundation.h>

	@interface PendingOperations : NSObject

	// 테이블뷰의 indexpath를 저장하여 해당 indexpath의 다운로드를 관리하는 변수
	@property (nonatomic, strong) NSMutableDictionary *downloadsInProgress;
	// 이미지 다운로드 작업을 관리하는 큐
	@property (nonatomic, strong) NSOperationQueue *downloadQueue;

	// 테이블뷰의 indexpath를 저장하여 해당 indexpath의 이미지 필터를 관리하는 변수
	@property (nonatomic, strong) NSMutableDictionary *filtrationsInProgress;
	// 이미지 필터 작업을 관리하는 큐
	@property (nonatomic, strong) NSOperationQueue *filtrationQueue;
	@end


	//  PendingOperations.m
	#import "PendingOperations.h"

	@implementation PendingOperations

	 - (NSMutableDictionary *)downloadsInProgress {
	    if (!_downloadsInProgress) {
	        _downloadsInProgress = [[NSMutableDictionary alloc] init];
	    }
	    return _downloadsInProgress;
	}

	 - (NSOperationQueue *)downloadQueue {
	    if (!_downloadQueue) {
	        _downloadQueue = [[NSOperationQueue alloc] init];
	        _downloadQueue.name = @"Download Queue";
	        _downloadQueue.maxConcurrentOperationCount = 1;
	    }
	    return _downloadQueue;
	}

	 - (NSMutableDictionary *)filtrationsInProgress {
	    if (!_filtrationsInProgress) {
	        _filtrationsInProgress = [[NSMutableDictionary alloc] init];
	    }
	    return _filtrationsInProgress;
	}

	 - (NSOperationQueue *)filtrationQueue {
	    if (!_filtrationQueue) {
	        _filtrationQueue = [[NSOperationQueue alloc] init];
	        _filtrationQueue.name = @"Image Filtration Queue";
	        _filtrationQueue.maxConcurrentOperationCount = 1;
	    }
	    return _filtrationQueue;
	}

	@end

<br/>
3.이제 이미지 다운로드 작업을 만들어봅시다.

앞에서 만들었던 photoRecord를 사용하여 다운로드 상태를 가지게 되며, delegate를 통해서 테이블뷰에 작업이 완료하였음을 알려줍니다.

	//  ImageDownloader.h
	#import <Foundation/Foundation.h>
	#import "PhotoRecord.h"
	@protocol ImageDownloaderDelegate;

	@interface ImageDownloader : NSOperation

	// 테이블뷰에 작업을 알려줄 델리게이트
	@property (nonatomic, assign) id <ImageDownloaderDelegate> delegate;

	// 테이블뷰의 indexpath
	@property (nonatomic, readonly, strong) NSIndexPath *indexPathInTableView;
	// 다운로드 작업 데이터를 가지고 있을 모델
	@property (nonatomic, readonly, strong) PhotoRecord *photoRecord;

	// 초기화 함수
	 - (id)initWithPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageDownloaderDelegate>) theDelegate;

	@end

	@protocol ImageDownloaderDelegate <NSObject>
	// 테이블 뷰에서 호출할 델리게이트 메소드
	 - (void)imageDownloaderDidFinish:(ImageDownloader *)downloader;
	@end

	//  ImageDownloader.m
	#import "ImageDownloader.h"

	@interface ImageDownloader ()
	@property (nonatomic, readwrite, strong) NSIndexPath *indexPathInTableView;
	@property (nonatomic, readwrite, strong) PhotoRecord *photoRecord;
	@end

	@implementation ImageDownloader
	#pragma mark -
	#pragma mark - Life Cycle
	 - (id)initWithPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageDownloaderDelegate>)theDelegate {

	    if (self = [super init]) {
	        self.delegate = theDelegate;
	        self.indexPathInTableView = indexPath;
	        self.photoRecord = record;
	    }
	    return self;
	}

	#pragma mark -
	#pragma mark - Downloading image
	 - (void)main {
		@autoreleasepool {

	        if (self.isCancelled)
	            return;

	        NSData *imageData = [[NSData alloc] initWithContentsOfURL:self.photoRecord.URL];

	        if (self.isCancelled) {
	            imageData = nil;
	            return;
	        }

	        if (imageData) {
	            UIImage *downloadedImage = [UIImage imageWithData:imageData];
	            self.photoRecord.image = downloadedImage;
	        }
	        else {
	            self.photoRecord.failed = YES;
	        }

	        imageData = nil;

	        if (self.isCancelled)
	            return;

	        dispatch_async(dispatch_get_main_queue(), ^{
	            [self.delegate imageDownloaderDidFinish:self];
	        });
	    }
	}

NSOperation은 언제라도 Cancel이 될 수 있기 때문에 로직 부분에 self.isCancelled를 체크하여 수행하는 것이 좋습니다. 그렇지 않으면 작업은 Cancel이 되었지만 계속 수행되기 때문입니다.

또한, ARC에서는 @autoreleasepool를 사용하여 ARC를 사용하지 않을 때의 NSAutoreleasePool을 대신합니다.

이미지가 다운 완료가 되면 imageDownloaderDidFinish 메소드로 호출하여 현재 작업을 넘겨줍니다. 이때 이미지를 화면에 보여주어야 하기 때문에 mainQueue를 이용합니다. 만일 GCD를 사용하지 않는다고 한다면 performSelectorOnMainThread를 사용하여 호출할 수 있습니다.

<br/>
4.이미지 다운 후 필터를 적용하는 작업을 만들어 봅시다.
앞에서 설명한 ImageDownloader와 구조가 많이 유사합니다. photoRecord를 사용하여 필터 적용 상태를 가지게 되며, delegate를 통해서 테이블뷰에 작업이 완료하였음을 알려줍니다.

	//  ImageFiltration.h
	#import <UIKit/UIKit.h>
	#import <CoreImage/CoreImage.h>
	#import "PhotoRecord.h"

	@protocol ImageFiltrationDelegate;

	@interface ImageFiltration : NSOperation

	// 테이블뷰에 작업을 알려줄 델리게이트
	@property (nonatomic, weak) id <ImageFiltrationDelegate> delegate;
	// 테이블뷰의 indexpath
	@property (nonatomic, readonly, strong) NSIndexPath *indexPathInTableView;
	// 다운로드 작업 데이터를 가지고 있을 모델
	@property (nonatomic, readonly, strong) PhotoRecord *photoRecord;

	 - (id)initWithPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageFiltrationDelegate>)theDelegate;

	@end

	@protocol ImageFiltrationDelegate <NSObject>
	  - (void)imageFiltrationDidFinish:(ImageFiltration *)filtration;
	@end


	//  ImageFiltration.m
	#import "ImageFiltration.h"

	@interface ImageFiltration ()
	@property (nonatomic, readwrite, strong) NSIndexPath *indexPathInTableView;
	@property (nonatomic, readwrite, strong) PhotoRecord *photoRecord;
	@end

	@implementation ImageFiltration
	#pragma mark -
	#pragma mark - Life cycle
	 - (id)initWithPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageFiltrationDelegate>)theDelegate {

		if (self = [super init]) {
	 		self.photoRecord = record;
	 		self.indexPathInTableView = indexPath;
	 		self.delegate = theDelegate;
		}
		return self;
	}

	#pragma mark -
	#pragma mark - Main operation
	 - (void)main {
	    @autoreleasepool {
	        if (self.isCancelled)
	            return;

	        if (!self.photoRecord.hasImage)
	            return;

	        UIImage *rawImage = self.photoRecord.image;
	        UIImage *processedImage = [self applySepiaFilterToImage:rawImage];

	        if (self.isCancelled)
	            return;

	        if (processedImage) {
	            self.photoRecord.image = processedImage;
	            self.photoRecord.filtered = YES;
	            dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate imageFiltrationDidFinish:self];
                });
	        }
	    }
	}

	#pragma mark -
	#pragma mark - Filtering image
	 - (UIImage *)applySepiaFilterToImage:(UIImage *)image {

	    // This is expensive + time consuming
	    CIImage *inputImage = [CIImage imageWithData:UIImagePNGRepresentation(image)];

	    if (self.isCancelled)
	        return nil;

	    UIImage *sepiaImage = nil;
	    CIContext *context = [CIContext contextWithOptions:nil];
	    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone" keysAndValues: kCIInputImageKey, inputImage, @"inputIntensity", [NSNumber numberWithFloat:0.8], nil];
	    CIImage *outputImage = [filter outputImage];

	    if (self.isCancelled)
	        return nil;

	    // Create a CGImageRef from the context
	    // This is an expensive + time consuming
	    CGImageRef outputImageRef = [context createCGImage:outputImage fromRect:[outputImage extent]];

	    if (self.isCancelled) {
	        CGImageRelease(outputImageRef);
	        return nil;
	    }

	    sepiaImage = [UIImage imageWithCGImage:outputImageRef];
	    CGImageRelease(outputImageRef);
	    return sepiaImage;
	}
	@end

이미지 필터를 처리한 후에 imageFiltrationDidFinish 호출하여 테이블뷰에 작업이 완료하였음을 알려줍니다.
<br/>

## 테이블 뷰에서의 작업 처리

1.이미지 다운로드, 이미지 필터 작업을 테이블뷰와 연결하여 동작하도록 구성해봅시다. 다음은 ListViewController.h입니다.

	//  ListViewController.h
	#import <UIKit/UIKit.h>
	#import "PhotoRecord.h"
	#import "PendingOperations.h"
	#import "ImageDownloader.h"
	#import "ImageFiltration.h"

	#import "AFNetworking/AFNetworking.h"

	#define kDatasourceURLString @"https://sites.google.com/site/soheilsstudio/tutorials/nsoperationsampleproject/ClassicPhotosDictionary.plist"

	@interface ListViewController : UITableViewController <ImageDownloaderDelegate, ImageFiltrationDelegate>

	@property (nonatomic, strong) NSMutableArray *photos;
	@property (nonatomic, strong) PendingOperations *pendingOperations;

	@end

ImageDownloaderDelegate, ImageFiltrationDelegate를 통해서 ImageDownloader, ImageFiltration NSOperation가 호출할 수 있도록 합니다.
<br/>

2.이제부터는 ListViewController.m에 추가할 내용에 대해서 설명합니다. PendingOperations가 추가하여 이미지 다운로드 큐와 이미지 필터 큐를 관리하며, lazy instantiation를 사용하도록 합니다.

	 - (PendingOperations *)pendingOperations {
	    if (!_pendingOperations) {
	        _pendingOperations = [[PendingOperations alloc] init];
	    }
	    return _pendingOperations;
	}
<br/>

3.테이블 뷰의 셀에 이미지와 라벨을 나타내도록 합시다. tableView:cellForRowAtIndexPath에서는 셀이 생성되지 않았다면 UIActivityIndicatorView를 나타내어 처리중임을 보이도록 하고, 이미지가 다운로드 되어 가지고 있다면 보여주고, 실패인 경우는 실패 이미지를, 다운로드 중이라면 기본 이미지를 보여주도록 합니다.
또한, 작업이 있는지 확인하여 작업이 없다면 수행하도록 합니다.

	 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	    static NSString *kCellIdentifier = @"Cell Identifier";
	    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];

	    if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            // 셀에 UIActivityIndicatorView를 만들어서 다운로드 받고 있다고 알려주도록 합니다.
            UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            cell.accessoryView = activityIndicatorView;
        }

        // 현재 row의 photo 객체를 가져옵니다.
        PhotoRecord *aRecord = [self.photos objectAtIndex:indexPath.row];

        // 만약 이미지가 다운로드 되었다면 이미지를 보여주도록 합니다.
        if (aRecord.hasImage) {
            [((UIActivityIndicatorView *)cell.accessoryView) stopAnimating];
            cell.imageView.image = aRecord.image;
            cell.textLabel.text = aRecord.name;

        }
        // 이미지 다운로드가 실패하였다면 실패 이미지를 보여줍니다.
        else if (aRecord.isFailed) {
            [((UIActivityIndicatorView *)cell.accessoryView) stopAnimating];
            cell.imageView.image = [UIImage imageNamed:@"Failed.png"];
            cell.textLabel.text = @"Failed to load";
        }
        // 이미지 다운 작업 중이라면 기본 이미지를 먼저 보여주고 작업을 할당합니다.
        else {
            [((UIActivityIndicatorView *)cell.accessoryView) startAnimating];
            cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
            cell.textLabel.text = @"";
            if (!tableView.dragging && !tableView.decelerating) {
                [self startOperationsForPhotoRecord:aRecord atIndexPath:indexPath];
            }
        }

        return cell;
	}

<br/>

4.startOperationsForPhotoRecord:atIndexPath에서 이미지가 없다면 이미지 다운로드 작업을, 필터가 되지 않았다면 필터 작업을 수행하도록 요청합니다.

	 - (void)startOperationsForPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath {
	    // 이미지가 없다면 다운로드 작업을 요청
	    if (!record.hasImage) {
	        [self startImageDownloadingForRecord:record atIndexPath:indexPath];
	    }
	    // 필터 작업이 되지 않았다면 필터 작업을 요청
	    if (!record.isFiltered) {
	        [self startImageFiltrationForRecord:record atIndexPath:indexPath];
	    }
	}
<br/>

5-1.pendingOperations의 downloadsInProgress에 key로 indexpath가 있는지 확인 한 후 없다면 다운로드 작업을 생성하여 pendingOperations의 downloadQueue에 추가합니다.

	 - (void)startImageDownloadingForRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath {
	    if (![self.pendingOperations.downloadsInProgress.allKeys containsObject:indexPath]) {
	        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithPhotoRecord:record atIndexPath:indexPath delegate:self];
	        [self.pendingOperations.downloadsInProgress setObject:imageDownloader forKey:indexPath];
	        [self.pendingOperations.downloadQueue addOperation:imageDownloader];
	    }
	}

5-2.pendingOperations의 filtrationsInProgress에 key로 indexpath가 있는지 확인 한 후 없다면 필터 작업을 생성하여 pendingOperations의 filtrationQueue에 추가합니다.

	 - (void)startImageFiltrationForRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath {
	    if (![self.pendingOperations.filtrationsInProgress.allKeys containsObject:indexPath]) {
	        ImageFiltration *imageFiltration = [[ImageFiltration alloc] initWithPhotoRecord:record atIndexPath:indexPath delegate:self];
	        ImageDownloader *dependency = [self.pendingOperations.downloadsInProgress objectForKey:indexPath];
	        if (dependency)
	            [imageFiltration addDependency:dependency];
	        [self.pendingOperations.filtrationsInProgress setObject:imageFiltration forKey:indexPath];
	        [self.pendingOperations.filtrationQueue addOperation:imageFiltration];
	    }
	}
<br/>

6.filtrationQueue, downloadQueue를 suspend, resume, cancel하는 메소드를 추가합니다.

	 - (void)suspendAllOperations {
	    [self.pendingOperations.downloadQueue setSuspended:YES];
	    [self.pendingOperations.filtrationQueue setSuspended:YES];
	}

	 - (void)resumeAllOperations {
	    [self.pendingOperations.downloadQueue setSuspended:NO];
	    [self.pendingOperations.filtrationQueue setSuspended:NO];
	}

	 - (void)cancelAllOperations {
	    [self.pendingOperations.downloadQueue cancelAllOperations];
	    [self.pendingOperations.filtrationQueue cancelAllOperations];
	}

<br/>

7-1.ImageDownloader Delegate 메소드인 imageDownloaderDidFinish를 추가하여 이미지가 다운로드 된 후에 테이블 뷰에 보일 수 있도록 합니다.

	 - (void)imageDownloaderDidFinish:(ImageDownloader *)downloader {
		// 이미지다운로드 작업에서 indexpath를 얻는다.
	    NSIndexPath *indexPath = downloader.indexPathInTableView;
	    // 이미지 상태의 모델을 얻는다.
	    PhotoRecord *theRecord = downloader.photoRecord;
	    // photo에 있는 데이터를 교체한다.
	    [self.photos replaceObjectAtIndex:indexPath.row withObject:theRecord];
	    // 테이블뷰에 얻은 indexpath를 통해 row를 갱신합니다.
	    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	    // indexpath로 저장되어 있던 다운로드 상태 정보를 삭제합니다.
	    [self.pendingOperations.downloadsInProgress removeObjectForKey:indexPath];
	}
<br/>

7-2.ImageFiltration Delegate 메소드인 imageFiltrationDidFinish를 추가하여 이미지 필터 작업을 한 후 테이블 뷰에 보이도록 합니다.

	 - (void)imageFiltrationDidFinish:(ImageFiltration *)filtration {
	    // 이미지 필터 작업에서 indexpath를 얻는다.
	    NSIndexPath *indexPath = filtration.indexPathInTableView;
	    // 이미지 상태의 모델을 얻는다.
	    PhotoRecord *theRecord = filtration.photoRecord;
	    // photo에 있는 데이터를 교체한다.
	    [self.photos replaceObjectAtIndex:indexPath.row withObject:theRecord];
	    // 테이블뷰에 얻은 indexpath를 통해 row를 갱신합니다.
	    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	    // indexpath로 저장되어 있던 필터 상태 정보를 삭제합니다.
	    [self.pendingOperations.filtrationsInProgress removeObjectForKey:indexPath];
	}

<br/>

8.테이블 뷰에서 유저가 스크롤 하다 보이는 화면에서 먼저 나와야 하므로 해당 보이는 Row를 찾아서 작업을 먼저 진행하도록 해야합니다.
우선 테이블뷰에서 보이는 Row를 먼저 얻습니다. 그리고 기존에 downloadsInProgress, filtrationsInProgress에 저장되어 있던 indexpath를 얻어서 작업을 취소 시키고 현재 보이는 Row의 indexpath를 얻어 startOperationsForPhotoRecord:atIndexPath를 호출하여 이미지 다운로드 작업 또는 이미지 필터 작업을 추가합니다.

	 - (void)loadImagesForOnscreenCells {

	    // 현재 보이는 Row를 NSSet으로 얻습니다.
	    NSSet *visibleRows = [NSSet setWithArray:[self.tableView indexPathsForVisibleRows]];

	    // 이미지 다운로드 작업 및 이미지 필터 작업이 저장되어 있는 indexpath를 얻습니다.
	    NSMutableSet *pendingOperations = [NSMutableSet setWithArray:[self.pendingOperations.downloadsInProgress allKeys]];
	    [pendingOperations addObjectsFromArray:[self.pendingOperations.filtrationsInProgress allKeys]];

	    NSMutableSet *toBeCancelled = [pendingOperations mutableCopy];
	    NSMutableSet *toBeStarted = [visibleRows mutableCopy];

	    // 새로 시작하는 indexpath목록에서 기존 indexpath 목록이 있으면 제외한다.(차집합)
	    [toBeStarted minusSet:pendingOperations];

	    // 취소하는 indexpath목록에서 현재 보이는 indexpath 목록이 있으면 제외한다.(차집합)
	    [toBeCancelled minusSet:visibleRows];

	    // pendingOperation에 걸려있는 모든 작업들을 취소합니다.
	    for (NSIndexPath *anIndexPath in toBeCancelled) {

	        ImageDownloader *pendingDownload = [self.pendingOperations.downloadsInProgress objectForKey:anIndexPath];
	        [pendingDownload cancel];
	        [self.pendingOperations.downloadsInProgress removeObjectForKey:anIndexPath];

	        ImageFiltration *pendingFiltration = [self.pendingOperations.filtrationsInProgress objectForKey:anIndexPath];
	        [pendingFiltration cancel];
	        [self.pendingOperations.filtrationsInProgress removeObjectForKey:anIndexPath];
	    }
	    toBeCancelled = nil;

	    // 보여지는 indexpath 목록으로부터 새로운 작압을 만들어 시작합니다.
	    for (NSIndexPath *anIndexPath in toBeStarted) {

	        PhotoRecord *recordToProcess = [self.photos objectAtIndex:anIndexPath.row];
	        [self startOperationsForPhotoRecord:recordToProcess atIndexPath:anIndexPath];
	    }
	    toBeStarted = nil;
	}

<br/>

9.테이블뷰에서 스크롤을 시작하면 모든 작업들을 일시 중지시키고 스크롤이 끝나면 재개하길 원할 수도 있습니다. 스크롤을 드래그 시작할 때 scrollViewWillBeginDragging 메소드, 드래그가 끝날 때 scrollViewDidEndDragging 메소드를 통하여 작업을 일시 중지시키고 재개합니다.

	 - (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	    [self suspendAllOperations];
	}

	 - (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	    if (!decelerate) {
	        [self loadImagesForOnscreenCells];
	        [self resumeAllOperations];
	    }
	}

	 - (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	    [self loadImagesForOnscreenCells];
	    [self resumeAllOperations];
	}


10.NSOperation과 NSOperationQueue를 통하여 이미지 다운로드 및 필터하는 작업을 관리하고 사용하는 방법을 알아보았습니다. 기본적으로 테이블뷰에 셀이 생성될 때 이미지가 미리 다운받아져있거나 내장되어있다면 좋겠지만 이렇게 동적으로 해야 하는 경우들이 상당히 많습니다. 따라서 위와 같이 적절하게 UI가 블럭되지 않게 잘 작성하는 것이 가장 중요한 방법입니다.
<br/>

---
## 참고

* [How To Use NSOperations and NSOperationQueues](http://www.raywenderlich.com/19788/how-to-use-nsoperations-and-nsoperationqueues)







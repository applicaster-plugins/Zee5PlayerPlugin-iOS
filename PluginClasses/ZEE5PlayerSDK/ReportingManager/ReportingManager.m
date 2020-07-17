//
//  ReportingManager.m
//  ZEE5PlayerSDK
//
//  Created by admin on 21/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import "ReportingManager.h"
#import <Zee5PlayerPlugin/ZEE5PlayerSDK.h>
#import "Zee5PlayerPlugin/Zee5PlayerPlugin-Swift.h"


@interface ReportingManager()

@property(strong, nonatomic) NSString *contentId;
@property(strong, nonatomic) NSString *QuardileValue;
@property(strong, nonatomic) NSString *currentDate;
@property (readwrite, nonatomic) BOOL isAlreadyExist;
@property (readwrite, nonatomic) BOOL isAlreadyExist2;
@property (readwrite, nonatomic) BOOL isDmpSync;   // For Lotame Analytics Check if value is true
@property (readwrite, nonatomic) BOOL isLotameEventSent;

@end

@implementation ReportingManager
static ReportingManager *sharedManager = nil;
+ (ReportingManager *)sharedInstance
{
    if (sharedManager)
    {
        return sharedManager;
    }
    
    static dispatch_once_t  t = 0;
    
    dispatch_once(&t, ^{
        sharedManager = [[ReportingManager alloc] init];
    });
    
    return sharedManager;
}


//MARK:- Start Reporting Watch History to Server with Time Interval of  60 second.

- (void)startReportingWatchHistory
{
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];  /// or @"yyyy-MM-dd hh:mm:ss a" if you prefer the time with AM/PM
    _currentDate = [dateFormatter stringFromDate:[NSDate date]];
    
    if ([self.contentId isEqualToString:[ZEE5PlayerManager sharedInstance].currentItem.content_id])
    {
        self.isAlreadyExist = true;
    }
    else
    {
         self.isAlreadyExist = false;
        _contentId = [ZEE5PlayerManager sharedInstance].currentItem.content_id;
        self.isLotameEventSent = false;
    }
    
    [self reportWatchHistory]; //// userApi.com use in this method (only used for register & subscribe user)
    [self reportWatchHistory2];  //// zee5.com Api use in this method (used for all usertypr including guest user also.)
    
}

- (void)reportWatchHistory
{
    if ([[ZEE5PlayerManager sharedInstance]getCurrentDuration] <= 0)
    {
        return;
    }
    if([ZEE5PlayerManager sharedInstance].currentItem == nil || ZEE5PlayerSDK.getUserTypeEnum == Guest)
    {
        return;
    }
    
    NSString *requestName = @"POST";
    
    if (_isAlreadyExist)
    {
        requestName = @"PUT";
    }

    NSDictionary *requestParams = @{
        @"id": [ZEE5PlayerManager sharedInstance].currentItem.content_id,
        @"asset_type": [ZEE5PlayerManager sharedInstance].currentItem.asset_type,
        @"duration": [NSString stringWithFormat:@"%.f",[[ZEE5PlayerManager sharedInstance] getCurrentDuration]],
    };
    

    NSString *userToken = [NSString stringWithFormat:@"%@", ZEE5UserDefaults.getUserToken];
    
     NSDictionary *requestheaders = @{@"Content-Type":@"application/json", @"Authorization": userToken,@"Accept":@"application/json"};
    
    [[NetworkManager sharedInstance] makeHttpRequest:requestName requestUrl:BaseUrls.watchHistory requestParam:requestParams requestHeaders:requestheaders shouldCancel:NO withCompletionHandler:^(id  _Nullable result)
    {
        
    }
    failureBlock:^(ZEE5SdkError * _Nullable error)
     {
        if (error.code == 400)
        {
            self.isAlreadyExist = true;
        }
        else
        {
            self.isAlreadyExist = false;
        }
    }];
   
}

//MARK:- Watch history Post Second Api (LOTAME Event Fire here)

- (void)reportWatchHistory2
{
    if ([[ZEE5PlayerManager sharedInstance]getCurrentDuration] <= 0)
    {
        return;
    }
    if([ZEE5PlayerManager sharedInstance].currentItem == nil)
    {
        return;
    }
    NSString *requestName = @"POST";
    
    if (_isAlreadyExist2)
    {
        requestName = @"PUT";
    }
    
    self.QuardileValue = [self QuartiletimeCalculate:[[ZEE5PlayerManager sharedInstance] getCurrentDuration]];
    
    NSString * Duration = [NSString stringWithFormat:@"%.f",[[ZEE5PlayerManager sharedInstance] getCurrentDuration]];
    
    NSString * DurationRange = [self Durationrange:[[ZEE5PlayerManager sharedInstance] getTotalDuration]];
    
    
    NSDictionary *requestParams = @{
        @"id": [ZEE5PlayerManager sharedInstance].currentItem.content_id,
        @"asset_type": [NSNumber numberWithInt:[[ZEE5PlayerManager sharedInstance].currentItem.asset_type intValue]]
        @"duration": Duration
    };
    

    NSString *userToken = [NSString stringWithFormat:@"%@", ZEE5UserDefaults.getUserToken];
    
    NSDictionary *requestheaders;
   if (ZEE5PlayerSDK.getUserTypeEnum == Guest)
    {
        requestheaders = @{@"Content-Type":@"application/json",@"X-Z5-Guest-Token": userToken,@"Accept":@"application/json"};
    }
    else
    {
        requestheaders = @{@"Content-Type":@"application/json", @"Authorization": userToken,@"Accept":@"application/json"};
    }

    [[NetworkManager sharedInstance] makeHttpRequest:requestName requestUrl:BaseUrls.watchHistory2 requestParam:requestParams requestHeaders:requestheaders shouldCancel:NO withCompletionHandler:^(id  _Nullable result)
    {
        if ([[result valueForKey:@"meta"]isKindOfClass:[NSDictionary class]])
        {
            self.isDmpSync = [[[result valueForKey:@"meta"]valueForKey:@"dmpSync"] boolValue];
            if (self.isDmpSync == true && self.isLotameEventSent == false)
            {
                self.isLotameEventSent = true;  /// Here Lotame Event has to fired.
                
            [[AnalyticEngine new]startLotameAnalyticsWith:DurationRange quartileValue:self.QuardileValue];

            }
        }
        
        
    }
    failureBlock:^(ZEE5SdkError * _Nullable error)
     {
        if (error.code == 400)
        {
            self.isAlreadyExist2 = true;
        }
        else
        {
            self.isAlreadyExist2 = false;
        }
    }];
   
}

//MARK:- Get Quartile Value To sent in LotameEvent

-(NSString *)QuartiletimeCalculate:(CGFloat)contentDuration
{
    CGFloat totalDuration = [[ZEE5PlayerManager sharedInstance]getTotalDuration];
    CGFloat Quartilevalue = (contentDuration/totalDuration)*100;
    
    NSString * quartileStr;
    if (Quartilevalue < 25.0 && Quartilevalue > 0){
        quartileStr =@"0%-25%";
    } else if (Quartilevalue < 50.0 && Quartilevalue > 25.0){
        quartileStr = @"25-50";
    }else if (Quartilevalue < 75.0 && Quartilevalue > 50.0){
         quartileStr = @"50-75";
    }else{
         quartileStr = @"75-100";
    }
    
    return quartileStr;
}

//MARK:- Get Duration Range Value To sent in LotameEvent

-(NSString *)Durationrange:(CGFloat)contentDuration
{

    CGFloat DurationinMinute = (contentDuration/60);
    
    NSString * DurationRange;
    if (DurationinMinute < 30.0 && DurationinMinute > 0){
        DurationRange =@"0-30mins";
    } else if (DurationinMinute < 60.0 && DurationinMinute > 30.0){
       DurationRange =@"30-60mins";
    }else if (DurationinMinute < 120.0 && DurationinMinute > 60.0){
         DurationRange =@"1-2hrs";
    }else{
          DurationRange =@"2hrs+";
    }
    
    return DurationRange;
}

//MARK:- Get Watch History Of Particular Content.

- (void)getWatchHistory
{
    self.isCountinueWatching =NO;
   
    if([ZEE5PlayerManager sharedInstance].currentItem == nil)
    {
        return;
    }
  
    NSDictionary *requestParams = @{};
    
    NSString *userToken = [NSString stringWithFormat:@"%@", ZEE5UserDefaults.getUserToken];

    NSDictionary *requestheaders;
    if (ZEE5PlayerSDK.getUserTypeEnum == Guest)
    {
        requestheaders = @{@"Content-Type":@"application/json",@"X-Z5-Guest-Token": userToken,@"Accept":@"application/json"};
    }
    else
    {
        requestheaders = @{@"Content-Type":@"application/json", @"Authorization": userToken,@"Accept":@"application/json"};
    }

    [[NetworkManager sharedInstance] makeHttpGetRequest:BaseUrls.watchHistory requestParam:requestParams requestHeaders:requestheaders withCompletionHandler:^(id  _Nullable result) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:result];
           
            if ([array count] > 0)
            {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.id contains[cd] %@",[ZEE5PlayerManager sharedInstance].currentItem.content_id];
                
                NSArray *filterArray = [array filteredArrayUsingPredicate:predicate];
            
                if ([filterArray count]>0)
                {
                    self.isCountinueWatching =YES;
                    NSInteger Duration =[[[filterArray objectAtIndex:0]objectForKey:@"duration"]integerValue];
                    [[ZEE5PlayerManager sharedInstance]setWatchHistory:Duration];
        
                }
            }
    } failureBlock:^(ZEE5SdkError * _Nullable error) {
    }];
    
}



- (void)gaEventManager:(NSDictionary *)dict
{
    if ([AppConfigManager sharedInstance].config.authKey == nil) {
        return;
    }
    NSDictionary *requestParams = @{
                                    @"v": @"1",
                                    @"tid": @"UA-106326967-24",
                                    @"cid": [Utility getAdvertisingIdentifier],
                                    @"aid":  [AppConfigManager sharedInstance].config.authKey,
                                    @"t": @"event"
                                    };
    NSMutableDictionary *dictParams = [[NSMutableDictionary alloc]init];
    [dictParams addEntriesFromDictionary:dict];
    [dictParams addEntriesFromDictionary:requestParams];

    
    [[NetworkManager sharedInstance] makeHttpGetRequest:BaseUrls.googleAnalytic requestParam:dictParams requestHeaders:@{} withCompletionHandler:^(id  _Nullable result) {

    } failureBlock:^(ZEE5SdkError * _Nullable error) {

    }];
    
    
}


@end

//
//  AddToWatchlist.m
//  ZEE5PlayerSDK
//
//  Created by Tejas Todkar on 27/12/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//


#import "AddToWatchlist.h"
#import <Zee5PlayerPlugin/ZEE5PlayerSDK.h>
#import <Zee5PlayerPlugin/Zee5PlayerPlugin-Swift.h>



@interface AddToWatchlist ()

@end


@implementation AddToWatchlist

static AddToWatchlist *SharedInstance = nil;

+ (AddToWatchlist *)Shared
{
    if (SharedInstance)
    {
        return SharedInstance;
    }
    
    static dispatch_once_t  t = 0;
    
    dispatch_once(&t, ^{
        SharedInstance = [[AddToWatchlist alloc] init];
    });
    
    return SharedInstance;
}
// *** Api calling For Add Content For Watchlist.******//


//-(void)getWatchListwithCompletion:(succeesHandlerwatchlist)Succees{
//    
//    if (ZEE5PlayerSDK.getUserTypeEnum == Guest)
//    {
//        Succees(FALSE);
//        return;
//    }
//    NSString *requestName = @"GET";
//    NSDictionary *requestParams =@{};
//
//    NSString *userToken = [NSString stringWithFormat:@"%@", ZEE5UserDefaults.getUserToken];
//    NSDictionary *requestheaders = @{@"Content-Type":@"application/json", @"authorization": userToken};
//
//    [[NetworkManager sharedInstance] makeHttpRequest:requestName requestUrl:BaseUrls.watchList requestParam:requestParams requestHeaders:requestheaders withCompletionHandler:^(id  _Nullable result)
//    {
//       NSMutableArray *array = [[NSMutableArray alloc] initWithArray:result];
//            if ([array count] > 0)
//        {
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.id contains[cd] %@",[ZEE5PlayerManager sharedInstance].currentItem.content_id];
//
//            NSArray *filterArray = [array filteredArrayUsingPredicate:predicate];
//            if ([filterArray count]>0)
//            {
//              Succees(TRUE);
//            }else{
//              Succees(FALSE);
//            }
//    }
//    }
//    failureBlock:^(ZEE5SdkError * _Nullable error)
//     {
//    }];
//
//}
-(void)AddToWatchlist:(CurrentItem *)currentItem
{
    if (ZEE5PlayerSDK.getUserTypeEnum == Guest)
    {
        [[ZEE5PlayerManager sharedInstance]pause];
        [[ZEE5PlayerManager sharedInstance]ShowToastMessage:@"You must be logged in to perform this action."];
        [[ZEE5PlayerManager sharedInstance]tapOnLoginButton];
        return;
        // Send Guest User to Login Screen Here
    }
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    // or @"yyyy-MM-dd hh:mm:ss a" if you prefer the time with AM/PM
    
    NSString *requestName = @"POST";
    
    NSString *currentDate = [dateFormatter stringFromDate:[NSDate date]];
    NSDictionary *requestParams = @{
        @"id": currentItem.content_id,
        @"asset_type": currentItem.asset_type,
        @"duration": [NSString stringWithFormat:@"%.f",[[ZEE5PlayerManager sharedInstance] getCurrentDuration]],
        @"date": currentDate
    };

    NSString *userToken = [NSString stringWithFormat:@"%@", ZEE5UserDefaults.getUserToken];
    NSDictionary *requestheaders = @{@"Content-Type":@"application/json", @"authorization": userToken};

    [[NetworkManager sharedInstance] makeHttpRequest:requestName requestUrl:BaseUrls.watchList requestParam:requestParams requestHeaders:requestheaders withCompletionHandler:^(id  _Nullable result)
    {
        if ([[[result valueForKey:@"code"]stringValue] isEqualToString:@"1"]) {
            [[AnalyticEngine shared]AddtoWatchlistAnlytics];
        }
    }
    failureBlock:^(ZEE5SdkError * _Nullable error)
     {
    }];
}

@end

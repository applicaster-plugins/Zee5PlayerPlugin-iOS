//
//  ContentClickApi.m
//  ZEE5PlayerSDK
//
//  Created by Tejas Todkar on 04/11/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

#import "ContentClickApi.h"
#import <Zee5PlayerPlugin/ZEE5PlayerSDK.h>

@interface ContentClickApi()
@property (nonatomic)NSString *Model_name;
@property (nonatomic)NSString *Model_ClickId;

@end
@implementation ContentClickApi


static ContentClickApi *sharedManager = nil;
+ (ContentClickApi *)sharedInstance
{
    if (sharedManager)
    {
        return sharedManager;
    }
    
    static dispatch_once_t  t = 0;
    
    dispatch_once(&t, ^{
        sharedManager = [[ContentClickApi alloc] init];
    });
    
    return sharedManager;
}

-(void)ContentConsumption
{
    NSString *State = ZEE5UserDefaults.getCountry;
    if ([ZEE5UserDefaults.getCountry isEqualToString:@"IN"] || [ZEE5UserDefaults.getCountry isEqualToString:@"In"])
    {
       State = [NSString stringWithFormat:@"%@-%@", ZEE5UserDefaults.getCountry, ZEE5UserDefaults.getState];
    }
    NSDictionary *requestParams = @{
                                    @"asset_id":[ZEE5PlayerManager sharedInstance].currentItem.content_id,
                                    @"translation":ZEE5UserDefaults.gettranslation,
                                    @"languages":@"en,hi",
                                    @"country":ZEE5UserDefaults.getCountry,
                                    @"version":ZEE5PlayerSDK.getPlayerSDKVersion,
                                    @"region":State
                                    };
    
    NSString *userToken = [NSString stringWithFormat:@"%@", ZEE5UserDefaults.getUserToken];
    NSString *GuestToken=@"";
    if (ZEE5PlayerSDK.getUserTypeEnum == Guest)
    {
        GuestToken = [NSString stringWithFormat:@"%@", ZEE5UserDefaults.getUserToken];
    }
    
    NSDictionary *requestheaders = @{@"Content-Type":@"application/json", @"Authorization": userToken,@"X-Access-Token":ZEE5UserDefaults.getPlateFormToken,@"X-Z5-AppPlatform":@"IOS Mobile",@"X-Z5-Appversion":ZEE5PlayerSDK.getPlayerSDKVersion,@"X-Z5-Guest-Token":GuestToken};
    [[NetworkManager sharedInstance]makeHttpGetRequest:[NSString stringWithFormat:@"%@reco",BaseUrls.Gwapi] requestParam:requestParams requestHeaders:requestheaders withCompletionHandler:^(id  _Nullable result)
    {
       
        self.Model_name =[[[result valueForKey:@"buckets"]valueForKey:@"modelName"]objectAtIndex:0];
        
        if ([[[result valueForKey:@"buckets"]valueForKey:@"items"]count] >0)
        {
            self.Model_ClickId =[[[[[result valueForKey:@"buckets"]valueForKey:@"items"]valueForKey:@"clickID"]objectAtIndex:0]objectAtIndex:0];
        }
        
        [self VideoClickApi];
    }
failureBlock:^(ZEE5SdkError * _Nullable error)
    {
    }];
    
}

-(void)VideoClickApi
{
    
    NSMutableDictionary *postData  = [[NSMutableDictionary alloc] init];
    [postData setValue:@"zee5" forKey:@"type"];
    [postData setValue:@"click" forKey:@"action"];
    [postData setValue:self.Model_name forKey:@"modelName"];
    [postData setValue:[ZEE5PlayerManager sharedInstance].currentItem.content_id forKey:@"itemID"];
    [postData setValue:self.Model_ClickId forKey:@"clickID"];
    [postData setValue:@"" forKey:@"origin"];
    [postData setValue:@"IN-MH" forKey:@"region"];
    
    
    NSString *userID = @"a027e306-1707-48af-991d-4597a91e0a92";       // Get userId of User
    
    if (ZEE5PlayerSDK.getUserTypeEnum == Guest)
    {
        userID = [NSString stringWithFormat:@"%@", ZEE5UserDefaults.getUserToken];
    }
    
    NSDictionary *headers = @{@"Content-Type":@"application/json",@"Authorization":userID,@"X-Z5-AppPlatform":@"IOS Mobile",@"X-Z5-Appversion":ZEE5PlayerSDK.getPlayerSDKVersion};
    
    
    [[NetworkManager sharedInstance]makeHttpRawPostRequest:@"POST" requestUrl:BaseUrls.VideoClickApi requestParam:postData requestHeaders:headers withCompletionHandler:^(id  _Nullable result)
     {
      
     }
     failureBlock:^(ZEE5SdkError * _Nullable error)
    {
    }
     ];
}



@end

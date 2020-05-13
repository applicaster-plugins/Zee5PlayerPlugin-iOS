//
//  userSettingDataModel.m
//  ZEE5PlayerSDK
//
//  Created by shriraj.salunkhe on 25/09/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

#import "userSettingDataModel.h"
#import <Zee5PlayerPlugin/ZEE5PlayerSDK.h>

NSString *const kValue = @"value";
NSString *const kParentalControl = @"parental_control";
NSString *const kAutoplay = @"auto_play";
NSString *const kStreamingQuality = @"streaming_quality";
NSString *const kDownloadQualitySetting = @"download_quality_setting";
NSString *const kStreamOverWifi = @"stream_over_wifi";
NSString *const kDownloadOverWifi = @"download_over_wifi";
NSString *const kDisplayLanguage = @"display_language";
NSString *const kContentLanguage = @"content_language";
NSString *const kRecentSearch = @"recent_search";
NSString *const kPopUps = @"popups";
NSString *const kpaytmconsent = @"paytmconsent";
NSString *const kDownloadQuality = @"download_quality";
NSString *const kFirstTimeLogin = @"first_time_login";



@implementation userSettingDataModel

+ (instancetype)initFromJSONDictionary:(NSDictionary *)dict
{
    
    return [[self alloc] initWithNSDictionary:dict];
}

- (instancetype)initWithNSDictionary:(NSDictionary *)dict
{
    
    self = [super init];
    
    if (self && [dict isKindOfClass:NSArray.class])
    {
        
            for (NSDictionary *userSetting in dict)
            {
          
                if ([[userSetting valueForKey:@"key"]isEqualToString:kParentalControl] && ![[userSetting valueForKey:kValue]isKindOfClass:[NSNull class]] )
                {
                    _parentalControl =[Utility getDictionaryFrom:[userSetting ValueForKeyWithNullChecking:kValue]];
                    self.ageRating = [_parentalControl ValueForKeyWithNullChecking:@"age_rating"];
                    self.userPin  = [_parentalControl ValueForKeyWithNullChecking:@"pin"];
                    
                }
                
                if ([[userSetting valueForKey:@"key"]isEqualToString:kAutoplay] && ![[userSetting valueForKey:kValue]isKindOfClass:[NSNull class]] )
                {
                    self.autoPlay = [userSetting ValueForKeyWithNullChecking:kValue];
                    
                }
                
                if ([[userSetting valueForKey:@"key"]isEqualToString:kStreamOverWifi] && ![[userSetting valueForKey:kValue]isKindOfClass:[NSNull class]] )
                {
                    self.streamOverWifi = [userSetting ValueForKeyWithNullChecking:kValue];
                    
                }
                if ([[userSetting valueForKey:@"key"]isEqualToString:kDownloadOverWifi] && ![[userSetting valueForKey:kValue]isKindOfClass:[NSNull class]] )
                {
                self.downloadOverWifi = [userSetting ValueForKeyWithNullChecking:kValue];
                                   
                }
        
                
            }
        
    }
        return self;
}




@end

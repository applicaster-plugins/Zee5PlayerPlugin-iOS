//
//  ZEE5UserDefaults.m
//  ZEE5PlayerSDK
//
//  Created by admin on 15/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import "ZEE5UserDefaults.h"

@implementation ZEE5UserDefaults


//MARK:- TT  ALL Data Set From ZEE5CoreSDK Plugin

+ (void)setUserToken:(NSString*)token
{
    [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"userToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)getUserToken
{
    NSString *userToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"userToken"];
    if (userToken)
    {
        return userToken;
    }
    return @"User token not available";
}

+ (void)setUserType:(NSString *)UserType
{
    [[NSUserDefaults standardUserDefaults] setValue:UserType forKey:@"userType"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)getUserType
{
    NSString *userType = [[NSUserDefaults standardUserDefaults] valueForKey:@"userType"];
    if (userType)
    {
        return userType;
    }else{
        userType = @"guest"; 
        return userType;
    }
}

+ (void)setPlateFormToken:(NSString*)token
{
    [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"plateFormToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (NSString *)getPlateFormToken
{
    NSString *platformToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"plateFormToken"];
    if (platformToken)
    {
        return platformToken;
    }
    return @"Plateform token not available";
}


+ (void)setUserSubscribedPack:(NSString *)Pack
{
    
    [[NSUserDefaults standardUserDefaults]setObject:Pack forKey:@"SubscribePack"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
+ (NSString *)getSubscribedPack
{
    id SubscribeDict =[[NSUserDefaults standardUserDefaults]valueForKey:@"SubscribePack"];
    if (SubscribeDict!=nil || [SubscribeDict isKindOfClass:[NSData class]])
    {
        return SubscribeDict;
    }
    return @"";
}
+ (void)setUserSettingData:(NSString *)UserSetting;
{
    
    [[NSUserDefaults standardUserDefaults]setObject:UserSetting forKey:@"UserSetting"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
+ (NSString *)getUserSetting
{
    id userSetting =[[NSUserDefaults standardUserDefaults]valueForKey:@"UserSetting"];
    if (userSetting!=nil || [userSetting isKindOfClass:[NSData class]])
    {
        return userSetting;
    }
    return @"";
}


+ (void)setCountry:(NSString*)Country andState:(NSString *)State
{
    [[NSUserDefaults standardUserDefaults]setValue:Country forKey:@"Country"];
    [[NSUserDefaults standardUserDefaults]setValue:State forKey:@"State"];
    
}
+ (NSString *)getCountry
{
    NSString * Country =[[NSUserDefaults standardUserDefaults]valueForKey:@"Country"];
    if (Country)
    {
        return Country;
    }
    return @"IN";
}
+ (NSString *)getState{
   
    NSString * State =[[NSUserDefaults standardUserDefaults]valueForKey:@"State"];
    if (State)
    {
        return State;
    }
    return @"NA";
}

+ (void)settranslationLanguage:(NSString *)language
{
    [[NSUserDefaults standardUserDefaults] setValue:language forKey:@"Translation"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (NSString *)gettranslation
{
    NSString *translation = [[NSUserDefaults standardUserDefaults] valueForKey:@"Translation"];
    if (translation)
    {
        return translation;
    }
    return @"en";
}

+ (void)setassetType:(NSString*)ContentType
{
    [[NSUserDefaults standardUserDefaults] setValue:ContentType forKey:@"AssetType"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (NSString *)getAssetType
{
    NSString *AssetType = [[NSUserDefaults standardUserDefaults] valueForKey:@"AssetType"];
       if (AssetType)
       {
           return AssetType;
       }
       return @"";
}

+ (void)setContentId:(NSString*)ContentID
{
    [[NSUserDefaults standardUserDefaults] setValue:ContentID forKey:@"CID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (NSString *)getContentID
{
    NSString *Contentid = [[NSUserDefaults standardUserDefaults] valueForKey:@"CID"];
       if (Contentid)
       {
           return Contentid;
       }
       return @"";
}




@end

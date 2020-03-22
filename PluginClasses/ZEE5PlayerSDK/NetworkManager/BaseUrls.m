//
//  BaseUrls.m
//  ZEE5PlayerSDK
//
//  Created by admin on 11/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import "BaseUrls.h"

@implementation BaseUrls

//+ (NSString*)userToken {
//    
//    switch (ZEE5PlayerSDK.getDevEnvironment) {
//        case development:
//            return @"https://stagingb2bapi.zee5.com/partner/api/get-token.php?";
//            break;
//        case production:
//            return @"https://stagingb2bapi.zee5.com/partner/api/get-token.php?";
//            break;
//    }
//}
+ (NSString*)userRegistration {
    
    switch (ZEE5PlayerSDK.getDevEnvironment) {
        case development:
            return @"https://b2bapi.zee5.com/partner/api/silentregisterlogin.php";
            break;
        case production:
            return @"https://b2bapi.zee5.com/partner/api/silentregisterlogin.php";
            break;
    }
}

+ (NSString*)userAuthorization
{
    switch (ZEE5PlayerSDK.getDevEnvironment) {
        case development:
            return @"https://staginguseraction.zee5.com/token/sdk_config.php";
            break;
        case production:
            return @"https://useraction.zee5.com/token/sdk_config.php";
            break;
    }
}

+ (NSString*)entitlementV4
{
    switch (ZEE5PlayerSDK.getDevEnvironment) {
        case development:
            return @"https://subscriptionapi.zee5.com/v4/entitlement";
            break;
        case production:
            return @"https://subscriptionapi.zee5.com/v4/entitlement";
            break;
    }
}

+ (NSString*)videoTokenApi
{
    switch (ZEE5PlayerSDK.getDevEnvironment) {
        case development:
            return @"https://gwapi.zee5.com/user/videoStreamingToken";
            break;
        case production:
            return @"https://gwapi.zee5.com/user/videoStreamingToken";
            break;
    }
}

+ (NSString*)drmLicenceUrl
{
    switch (ZEE5PlayerSDK.getDevEnvironment) {
        case development:
            return @"https://fp-keyos-aps1.licensekeyserver.com/getkey/";
            break;
        case production:
            return @"https://fp-keyos-aps1.licensekeyserver.com/getkey/";
            break;
    }
}
+ (NSString*)drmCertificateUrl
{
    switch (ZEE5PlayerSDK.getDevEnvironment) {
        case development:
            return @"https://fp-keyos-aps1.licensekeyserver.com/cert/b19d422d890644d5112d08469c2e5946.der";
            break;
        case production:
            return @"https://fp-keyos-aps1.licensekeyserver.com/cert/b19d422d890644d5112d08469c2e5946.der";
            break;
    }
}
+ (NSString*)plateFormToken
{
    switch (ZEE5PlayerSDK.getDevEnvironment) {
        case development:
            return @"https://useraction.zee5.com/token/platform_tokens.php";
            break;
        case production:
            return @"https://useraction.zee5.com/token/platform_tokens.php";
            break;
    }
}
+ (NSString*)liveContentDetails
{
    switch (ZEE5PlayerSDK.getDevEnvironment) {
        case development:
            return @"https://catalogapi.zee5.com/v1/channel";
            break;
        case production:
            return @"https://catalogapi.zee5.com/v1/channel";
            break;
    }
}
+ (NSString*)vodContentDetails
{
    switch (ZEE5PlayerSDK.getDevEnvironment) {
        case development:
            return @"https://gwapi.zee5.com/content/details";
            break;
        case production:
            return @"https://gwapi.zee5.com/content/details";
            break;
    }
}
+ (NSString*)vodSimilarContent
{
    switch (ZEE5PlayerSDK.getDevEnvironment) {
        case development:
            return @"https://gwapi.zee5.com/content/player";
            break;
        case production:
            return @"https://gwapi.zee5.com/content/player";
            break;
    }
}

+ (NSString*)watchHistory
{
    switch (ZEE5PlayerSDK.getDevEnvironment) {
        case development:
            return @"https://userapi.zee5.com/v1/watchhistory";
            break;
        case production:
            return @"https://userapi.zee5.com/v1/watchhistory";
            break;
    }
}

+ (NSString*)watchHistory2
{
    switch (ZEE5PlayerSDK.getDevEnvironment) {
        case development:
            return @"https://api.zee5.com/api/v1/watchhistory";
            break;
        case production:
            return @"https://api.zee5.com/api/v1/watchhistory";
            break;
    }
}
+ (NSString*)watchList
{
    switch (ZEE5PlayerSDK.getDevEnvironment) {
        case development:
            return @"https://userapi.zee5.com/v1/watchlist";
            break;
        case production:
            return @"https://userapi.zee5.com/v1/watchlist";
            break;
    }
}

+ (NSString*)adConfig
{
    switch (ZEE5PlayerSDK.getDevEnvironment) {
        case development:
        return @"https://stagingb2bapi.zee5.com/adtags/adds_v3.php?";
        break;
        case production:
        return @"https://b2bapi.zee5.com/adtags/adds_v3.php?";
        break;
    }
}
+ (NSString*)googleAnalytic
{
    switch (ZEE5PlayerSDK.getDevEnvironment) {
        case development:
        return @"https://www.google-analytics.com/collect";
        break;
        case production:
        return @"https://www.google-analytics.com/collect";
        break;
    }
}

+ (NSString*)getTokemNd
{
    switch (ZEE5PlayerSDK.getDevEnvironment) {
        case development:
            return @"https://useraction.zee5.com/tokennd/";
            break;
        case production:
            return @"https://useraction.zee5.com/tokennd/";
            break;
    }
}
+ (NSString*)getndToken
{
    switch (ZEE5PlayerSDK.getDevEnvironment) {
        case development:
            return @"https://apistaging.zee5.com/api/v2/ndtoken";
            break;
        case production:
            return @"https://api.zee5.com/api/v2/ndtoken";
            break;
    }
}

+ (NSString*)getSubscription
{
    switch (ZEE5PlayerSDK.getDevEnvironment) {
        case development:
            return @"https://subscriptionapi.zee5.com/v1/subscription";
            break;
        case production:
            return @"https://subscriptionapi.zee5.com/v1/subscription";
            break;
    }
}

+ (NSString*)getContentDetailsPlayer
{
    switch (ZEE5PlayerSDK.getDevEnvironment) {
        case development:
            return @"https://gwapi.zee5.com/content/player";
            break;
        case production:
            return @"https://gwapi.zee5.com/content/player";
            break;
    }
}

+ (NSString*)getContentDetails
{
    switch (ZEE5PlayerSDK.getDevEnvironment) {
        case development:
            return @"https://gwapi.zee5.com/content/details";
            break;
        case production:
            return @"https://gwapi.zee5.com/content/details";
            break;
    }

}

+ (NSString*)getNextContent
{
    switch (ZEE5PlayerSDK.getDevEnvironment) {
        case development:
            return @"https://gwapi.zee5.com/content/season/next_previous";
            break;
        case production:
            return @"https://gwapi.zee5.com/content/season/next_previous";
            break;
    }
    
}

+ (NSString*)TvShowContentDetail
{
    switch (ZEE5PlayerSDK.getDevEnvironment) {
        case development:
            return @"https://gwapi.zee5.com/content/tvshow";
            break;
        case production:
            return @"https://gwapi.zee5.com/content/tvshow";
            break;
    }
}

+ (NSString*)getUserSettings
{
    switch (ZEE5PlayerSDK.getDevEnvironment) {
        case development:
            return @"https://userapi.zee5.com/v1/settings";
            break;
        case production:
            return @"https://userapi.zee5.com/v1/settings";
            break;
    }
}

+ (NSString*)DeviceApi
{
    switch (ZEE5PlayerSDK.getDevEnvironment)
    {
        case development:
            return @"https://subscriptionapi.zee5.com/v1/device";
            break;
        case production:
            return @"https://subscriptionapi.zee5.com/v1/device";
            break;
    }
}

+ (NSString*)Gwapi
{
    switch (ZEE5PlayerSDK.getDevEnvironment)
    {
        case development:
            return @"https://gwapi.zee5.com/content/";
            break;
        case production:
            return @"https://gwapi.zee5.com/content/";
            break;
    }
}

+ (NSString*)VideoClickApi
{
    switch (ZEE5PlayerSDK.getDevEnvironment)
    {
        case development:
            return @"https://api.zee5.com/api/v1/click";
            break;
        case production:
            return @"https://api.zee5.com/api/v1/click";
            break;
    }
}

+ (NSString*)getCDNApi{
    
    switch (ZEE5PlayerSDK.getDevEnvironment)
   {
            case development:
               return @"https://vrl.m.conviva.com/";
               break;
    case production:
               return @"https://vrl.m.conviva.com/";
               break;
           
   }
}




@end

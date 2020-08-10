//
//  ZEE5PlayerSDK.m
//  ZEE5PlayerSDK
//
//  Created by admin on 04/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import "ZEE5PlayerSDK.h"
#import "Zee5PlayerPlugin/Zee5PlayerPlugin-Swift.h"
#import "comScoreAnalytics.h"
#import <Zee5PlayerPlugin/ZEE5PlayerSDK.h>
#import <Zee5CoreSDK/Zee5CoreSDK-umbrella.h>

static NSString *user_id = @"";
static DevelopmentEnvironment dev_environment = development;
static AdsEnvironment adsEnvironment = staging;
static ConsumptionType consumprionType = Movie;
static ConnectionType Connection = Mobile;

static comScoreAnalytics *comAnalytics;

///
static NSString *convivaCustomerKey = @"28bbf0a3decf6d1165032bfd835d6e1844c5d44d";
static NSString *convivaGatewayUrl = @"https://cws.conviva.com";

/* TouchStone gateway and url  */
static NSString *touchConvivaCustomerKey = @"28bbf0a3decf6d1165032bfd835d6e1844c5d44d";
static NSString *touchConvivaGatewayUrl = @"https://zee.testonly.conviva.com";



@implementation ZEE5PlayerSDK

+ (void)initializeWith:(NSString*)userId;
{
    id Dict;
    user_id = userId;
    [[AppConfigManager sharedInstance] setConfig:[ZEE5ConfigDataModel initFromJSONDictionary:Dict]];
    
    [self setupConvivaAnalytics];
    [self setupComScoreAnalytics];
    
}

// MARK:- ConvivaAnalytics Setup
+(void)setupConvivaAnalytics
{
    EventManager *eventManager = [[EventManager alloc] init];
    [eventManager setConvivaConfigurationWithCustomerKey: touchConvivaCustomerKey gatewayUrl: touchConvivaGatewayUrl];
}

// MARK:- ComScoreAnalytics Setup

+(void)setupComScoreAnalytics
{
    SCORPublisherConfiguration *myPublisherConfig = [SCORPublisherConfiguration publisherConfigurationWithBuilderBlock:^(SCORPublisherConfigurationBuilder *builder)
   {
    builder.publisherId = @"9254297";
   }];

    [[SCORAnalytics configuration] addClientWithConfiguration:myPublisherConfig];
   [SCORAnalytics start];
}

+ (NSString *)getUserId
{
    return user_id;
}


+ (void)setDevEnvirnoment:(DevelopmentEnvironment)Servertype{
    dev_environment = Servertype ;
}

+ (DevelopmentEnvironment)getDevEnvironment
{
    return dev_environment;
}

+ (void)setAdsEnvirnoment:(AdsEnvironment)Servertype {
    adsEnvironment = Servertype;
}
+ (AdsEnvironment)getAdsEnvironment {
    return adsEnvironment;
}

+(void)setConnection:(ConnectionType)Type{
    Connection = Type;
}
+(ConnectionType)Getconnectiontype{
    return Connection;
}


+ (Usertype)getUserTypeEnum {
    
    Usertype value = Guest;
    
    NSString
     *isLoggedInUserString = [[[ZAAppConnector sharedInstance] storageDelegate] localStorageValueFor:@"userLoginStatus" namespace:@"zee5localstorage"];
    BOOL isLoggedInUser = [ZEE5PlayerSDK getBoolValueFrom:isLoggedInUserString];
    if (isLoggedInUser == YES) {
        value = Registered;
    }
    
    BOOL isSubscribed = NO;
    NSString *subscriptions = [ZEE5UserDefaults getSubscribedPack];
    NSMutableArray *subscriptionsArray = [[NSMutableArray alloc] init];
    NSData *subscriptionsData = [subscriptions dataUsingEncoding:NSUTF8StringEncoding];
    id _Nullable resultData = [NSJSONSerialization JSONObjectWithData:subscriptionsData options:0 error:nil];
    
    for (NSDictionary *dict in resultData) {
        SubscriptionModel *model = [[SubscriptionModel alloc] initWithDictionary:dict];
        [subscriptionsArray addObject:model];
    }

    NSMutableArray *activePlans = [[NSMutableArray alloc] init];
    for (SubscriptionModel *model in subscriptionsArray) {
        if ([model.state isEqualToString:@"activated"]) {
            [activePlans addObject:model];
        }
    }
    
    for (SubscriptionModel *model in activePlans) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
        NSString *subscriptionEndDate = model.subscriptionEnd != nil ? model.subscriptionEnd : @"";
        NSDate *date = [formatter dateFromString:subscriptionEndDate];
        NSInteger interval = [date timeIntervalSinceDate:[NSDate new]];
        if (interval > 0) {
            isSubscribed = YES;
        }
    }
    
    if (isLoggedInUser == YES && isSubscribed == YES) {
        value = Premium;
    }
    return value;
}

+ (BOOL)getBoolValueFrom:(NSString *)value {
    NSArray *trueValues = @[@"true", @"yes", @"1"];
    return [trueValues containsObject:[value lowercaseString]];
}

+(ConsumptionType)getConsumpruionType{
    
    
     NSString *genres = [Utility getCommaSaperatedGenreList:[ZEE5PlayerManager sharedInstance].currentItem.geners];
    
    if ([[ZEE5PlayerManager sharedInstance].currentItem.asset_type isEqualToString:@"9"]) {
        consumprionType = Live;
    }else if ([[ZEE5PlayerManager sharedInstance].currentItem.asset_subtype isEqualToString:@"trailer"] || [[ZEE5PlayerManager sharedInstance].currentItem.asset_subtype isEqualToString:@"promo"]){
        consumprionType = Trailer;
    }else if ([[ZEE5PlayerManager sharedInstance].currentItem.asset_subtype isEqualToString:@"episode"] && [[ZEE5PlayerManager sharedInstance].currentItem.Showasset_subtype isEqualToString:@"tvshow"] ){
        consumprionType = Episode;
    }else if ([[ZEE5PlayerManager sharedInstance].currentItem.asset_subtype isEqualToString:@"movie"]){
        consumprionType = Movie;
    }else if ([[ZEE5PlayerManager sharedInstance].currentItem.asset_subtype isEqualToString:@"video"] && [genres containsString:@"Music" ]){
        consumprionType = Music;
    }else if ([[ZEE5PlayerManager sharedInstance].currentItem.asset_subtype isEqualToString:@"video"]){
        consumprionType = Video;
    }else if ([[ZEE5PlayerManager sharedInstance].currentItem.asset_subtype isEqualToString:@"episode"] && [[ZEE5PlayerManager sharedInstance].currentItem.Showasset_subtype isEqualToString:@"original"] ){
        consumprionType = Original;
    }
    else{
        consumprionType ;
    }
    return consumprionType;
}

+ (NSString *)getSDKVersion
{
    NSDictionary *infoDictionary = [[NSBundle bundleForClass:self] infoDictionary];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    return [NSString stringWithFormat:@"ZEE5 Player SDK Version %@ (%@)", majorVersion, minorVersion];
}

+ (NSString *)getPlayerSDKVersion {
    NSDictionary *infoDictionary = [[NSBundle bundleForClass:self] infoDictionary];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    return [NSString stringWithFormat:@"%@ (%@)", majorVersion, minorVersion];
}


@end

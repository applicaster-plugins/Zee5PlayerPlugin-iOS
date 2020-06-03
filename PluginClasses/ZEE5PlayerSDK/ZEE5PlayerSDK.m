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
static Usertype usertype = Guest;
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

+ (void)initializeWithContentID:(NSString*)content_id and:(NSString*)userId;
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
    NSLog(@"|||*** setupConvivaAnalytics ***|||");
    EventManager *eventManager = [[EventManager alloc] init];
    [eventManager setConvivaConfigurationWithCustomerKey: convivaCustomerKey gatewayUrl: convivaGatewayUrl];
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
   NSLog(@"Analytics Started");
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


+ (Usertype)getUserTypeEnum{
    NSString *Usertype = [ZEE5UserDefaults getUserType];
    if ([Usertype isEqualToString:@"guest"]){
        usertype = Guest;
    }else if ([Usertype isEqualToString:@"registered"]){
        usertype = Registered;
    }else if ([Usertype isEqualToString:@"premium"]){
        usertype = Premium;
    }else{
        usertype = Guest;
    }
    return usertype;
}

+(ConsumptionType)getConsumpruionType{
    
    
     NSString *genres = [Utility getCommaSaperatedGenreList:[ZEE5PlayerManager sharedInstance].currentItem.geners];
    
    if ([[ZEE5PlayerManager sharedInstance].currentItem.asset_type isEqualToString:@"9"]) {
        consumprionType = Live;
    }else if ([[ZEE5PlayerManager sharedInstance].currentItem.asset_subtype isEqualToString:@"trailer"] || [[ZEE5PlayerManager sharedInstance].currentItem.asset_subtype isEqualToString:@"promo"]){
        consumprionType = Trailer;
    }else if ([[ZEE5PlayerManager sharedInstance].currentItem.asset_subtype isEqualToString:@"episode"]){
        consumprionType = Episode;
    }else if ([[ZEE5PlayerManager sharedInstance].currentItem.asset_subtype isEqualToString:@"movie"]){
        consumprionType = Movie;
    }else if ([[ZEE5PlayerManager sharedInstance].currentItem.asset_subtype isEqualToString:@"video"] && [genres containsString:@"Music" ]){
        consumprionType = Music;
    }else if ([[ZEE5PlayerManager sharedInstance].currentItem.asset_subtype isEqualToString:@"video"]){
        consumprionType = Video;
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

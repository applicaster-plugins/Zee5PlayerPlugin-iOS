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

static comScoreAnalytics *comAnalytics;

///
static NSString *convivaCustomerKey = @"68b23e5e4a3770c20f04989fa8e89e0872e1c843";
static NSString *convivaGatewayUrl = @"https://zee-test.testonly.conviva.com/";


@implementation ZEE5PlayerSDK

+ (void)initializeWithContentID:(NSString*)content_id and:(NSString*)token;
{
    id Dict;
    
    [ZEE5UserDefaults setUserToken: token];
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
+ (DevelopmentEnvironment)getDevEnvironment
{
    return dev_environment;
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

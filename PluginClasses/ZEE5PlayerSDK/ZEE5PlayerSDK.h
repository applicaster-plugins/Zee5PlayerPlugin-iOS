//
//  ZEE5PlayerSDK.h
//  ZEE5PlayerSDK
//
//  Created by admin on 04/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import <UIKit/UIKit.h>


//! Project version number for ZEE5PlayerSDK.
FOUNDATION_EXPORT double ZEE5PlayerSDKVersionNumber;

//! Project version string for ZEE5PlayerSDK.
FOUNDATION_EXPORT const unsigned char ZEE5PlayerSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like

typedef enum devEnvironment
{
    development,
    production
} DevelopmentEnvironment;

typedef enum adsEnvironment
{
    prod,
    staging
} AdsEnvironment;

typedef enum playerType
{
    normalPlayer,
    mutedPlayer,
    unmutedPlayer
} PlayerType;

typedef enum buisnessType
{
    premium_downloadable,
    advertisement_downloadable,
    free_downloadable,
    premium,
    advertisement,
} ContentBuisnessType;

typedef enum userType
{
    Guest,
    Registered,
    Premium
} Usertype;

typedef enum InternetConnection
{
    Wifi,
    Mobile,
    WWAN,
    NoInternet
} ConnectionType;

typedef enum consumptiontype
{
    Movie,
    Episode,
    Shows,
    Trailer,
    Live,
    Music,
    Original,
    Video
} ConsumptionType;


///
typedef NS_ENUM(NSUInteger, ZEEConvivaPlayerState) {
    ConvivaPlayerStateSTOPPED = 1,
    ConvivaPlayerStatePLAYING = 3,
    ConvivaPlayerStateBUFFERING = 6,
    ConvivaPlayerStatePAUSED = 12,
    ConvivaPlayerStateNOT_MONITORED = 98,
    ConvivaPlayerStateUNKNOWN = 100,
};



#import <Zee5PlayerPlugin/ZEE5SdkError.h>
#import <Zee5PlayerPlugin/ZEE5AdModel.h>
#import <Zee5PlayerPlugin/CurrentItem.h>
#import <Zee5PlayerPlugin/Zee5MuteView.h>
#import <Zee5PlayerPlugin/ZEE5PlayerConfig.h>
#import <Zee5PlayerPlugin/VODContentDetailsDataModel.h>
#import <Zee5PlayerPlugin/ZEE5PlayerManager.h>
#import <Zee5PlayerPlugin/ZEE5PlayerDelegate.h>
#import <Zee5PlayerPlugin/ZEE5AudioTrack.h>
#import <Zee5PlayerPlugin/ZEE5Subtitle.h>
#import <Zee5PlayerPlugin/Zee5PlayerPlugin.h>
#import <Zee5PlayerPlugin/ZEE5LangaugeModel.h>
#import <Zee5PlayerPlugin/Genres.h>
#import <Zee5PlayerPlugin/RelatedVideos.h>
#import <Zee5PlayerPlugin/ZEE5UserDefaults.h>
#import <Zee5PlayerPlugin/Utility.h>
#import <Zee5PlayerPlugin/NetworkManager.h>
#import <Zee5PlayerPlugin/BaseUrls.h>
#import <Zee5PlayerPlugin/Zee5MenuView.h>
#import <Zee5PlayerPlugin/CurrentItem.h>
#import <Zee5PlayerPlugin/RelatedVideos.h>
#import <Zee5PlayerPlugin/SubscriptionModel.h>
#import <Zee5PlayerPlugin/NSDictionary+Extra.h>
#import <Zee5PlayerPlugin/AppConfigManager.h>
#import <Zee5PlayerPlugin/SimilarDataModel.h>
#import <Zee5PlayerPlugin/Zee5FanAdManager.h>
#import <Zee5PlayerPlugin/ReportingManager.h>
#import "Zee5Slider.h"
#import <Zee5PlayerPlugin/ZEE5PlayerSDK.h>


typedef void(^SuccessHandler)(id result);
typedef void(^FailureHandler)(ZEE5SdkError *error);

@interface ZEE5PlayerSDK : NSObject


+ (void)initializeWith:(NSString *)userId;
+ (NSString *)getUserId;
+ (void)setDevEnvirnoment:(DevelopmentEnvironment)Servertype;
+ (DevelopmentEnvironment)getDevEnvironment;
+ (void)setAdsEnvirnoment:(AdsEnvironment)Servertype;
+ (AdsEnvironment)getAdsEnvironment;
+ (Usertype)getUserTypeEnum;
+ (ConsumptionType)getConsumpruionType;
+ (NSString *)getSDKVersion;
+ (NSString *)getPlayerSDKVersion;

+(void)setConnection:(ConnectionType)Type;
+(ConnectionType)Getconnectiontype;
///  Analytics Setup For Comscore And Conviva
+(void)setupConvivaAnalytics;
+(void)setupComScoreAnalytics;


@end

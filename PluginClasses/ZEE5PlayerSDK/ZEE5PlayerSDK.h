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
} UserType;

///
typedef NS_ENUM(NSUInteger, ConvivaPlayerState) {
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
#import <Zee5PlayerPlugin/BeforeTvcontentView.h>
#import <Zee5PlayerPlugin/RelatedVideos.h>
#import <Zee5PlayerPlugin/InternationlguestUser.h>
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


+ (void)initializeWithContentID:(NSString*)content_id and:(NSString *)token;
+ (NSString *)getUserId;
+ (DevelopmentEnvironment)getDevEnvironment;
+ (UserType)getUserTypeEnum;
+ (NSString *)getSDKVersion;
+ (NSString *)getPlayerSDKVersion;


///  Analytics Setup For Comscore And Conviva
+(void)setupConvivaAnalytics;
+(void)setupComScoreAnalytics;


@end

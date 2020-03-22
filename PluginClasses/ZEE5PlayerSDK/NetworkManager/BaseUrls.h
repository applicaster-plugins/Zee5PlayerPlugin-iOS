//
//  BaseUrls.h
//  ZEE5PlayerSDK
//
//  Created by admin on 11/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZEE5PlayerSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseUrls : NSObject
+ (NSString*)userRegistration;
+ (NSString*)userAuthorization;
+ (NSString*)entitlementV4;
+ (NSString*)drmLicenceUrl;
+ (NSString*)drmCertificateUrl;
+ (NSString*)plateFormToken;
+ (NSString*)liveContentDetails;
+ (NSString*)watchHistory;
+ (NSString*)watchHistory2;
+ (NSString*)watchList;
+ (NSString*)vodContentDetails;
+ (NSString*)vodSimilarContent;
+ (NSString*)adConfig;
+ (NSString*)googleAnalytic;
+ (NSString*)getTokemNd;
+ (NSString*)getndToken;
+ (NSString*)getSubscription;
+ (NSString*)getContentDetailsPlayer;
+ (NSString*)getContentDetails;
+ (NSString*)getNextContent;
+ (NSString*)TvShowContentDetail;
+ (NSString*)getUserSettings;
+ (NSString*)DeviceApi;
+ (NSString*)Gwapi;
+ (NSString*)VideoClickApi;
+ (NSString*)videoTokenApi;
+ (NSString*)getCDNApi;
@end

NS_ASSUME_NONNULL_END

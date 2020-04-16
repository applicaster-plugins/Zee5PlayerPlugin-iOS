//
//  ZEE5UserDefaults.h
//  ZEE5PlayerSDK
//
//  Created by admin on 15/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN

@interface ZEE5UserDefaults : NSObject

+ (NSString *)getUserToken;
+ (void)setUserType:(NSString *)UserType;
+ (NSString *)getUserType;
+ (void)setPlateFormToken:(NSString*)token;
+ (NSString *)getPlateFormToken;
+ (void)setUserSubscribedPack:(NSString *)Pack;
+ (NSString *)getSubscribedPack;
+ (void)setCountry:(NSString*)Country andState:(NSString *)State;
+ (NSString *)getCountry;
+ (NSString *)getState;

+ (void)settranslationLanguage:(NSString*)language;
+ (NSString *)gettranslation;

+ (void)setassetType:(NSString*)ContentID;
+ (NSString *)getAssetType;

+ (void)setContentId:(NSString*)ContentID;
+ (NSString *)getContentID;

+ (void)setUserSettingData:(NSString *)UserSetting;
+ (NSString *)getUserSetting;


@end

NS_ASSUME_NONNULL_END

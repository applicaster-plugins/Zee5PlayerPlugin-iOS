//
//  userSettingDataModel.h
//  ZEE5PlayerSDK
//
//  Created by shriraj.salunkhe on 25/09/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface userSettingDataModel : NSObject

@property (nonatomic) NSDictionary *parentalControl ;
@property (nonatomic, strong) NSString * autoPlay;
@property (nonatomic, strong) NSString * streamingQuality;
@property (nonatomic, strong) NSString * downqualitySettings;
@property (nonatomic, strong) NSString * streamOverWifi;
@property (nonatomic, strong) NSString * downloadOverWifi;
@property (nonatomic, strong) NSString * displayLanguage;
@property (nonatomic, strong) NSString * contentLanguage;
@property (nonatomic, strong) NSString * firstTimeLogin;
@property (nonatomic, strong) NSString * ageRating;
@property (nonatomic, strong) NSString * userPin;




+ (instancetype)initFromJSONDictionary:(NSDictionary *)dict;


@end

NS_ASSUME_NONNULL_END

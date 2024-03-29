//
//  AppConfigManager.h
//  ZEE5PlayerSDK
//
//  Created by admin on 20/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZEE5ConfigDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppConfigManager : NSObject
@property (strong, nonatomic)ZEE5ConfigDataModel* config;
+ (AppConfigManager *)sharedInstance;

@end

NS_ASSUME_NONNULL_END

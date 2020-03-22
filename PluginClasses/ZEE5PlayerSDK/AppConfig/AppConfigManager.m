//
//  AppConfigManager.m
//  ZEE5PlayerSDK
//
//  Created by admin on 20/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import "AppConfigManager.h"

@implementation AppConfigManager

static AppConfigManager *sharedManager = nil;
+ (AppConfigManager *)sharedInstance
{
    if (sharedManager) {
        return sharedManager;
    }
    
    static dispatch_once_t  t = 0;
    
    dispatch_once(&t, ^{
        sharedManager = [[AppConfigManager alloc] init];
    });
    
    return sharedManager;
}

@end

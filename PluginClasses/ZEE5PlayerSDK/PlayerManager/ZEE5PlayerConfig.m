//
//  ZEE5PlayerConfig.m
//  ZEE5PlayerSDK
//
//  Created by admin on 04/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//PasswordP

#import "ZEE5PlayerConfig.h"

@implementation ZEE5PlayerConfig
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self doInitialConfiguration];
    }
    return self;
}
-(void)doInitialConfiguration
{
    self.autoPlay = YES;
    self.showCustomPlayerControls = YES;
    self.shouldStartPlayerInLandScape = NO;
    self.seekValue = 10;
    self.playerType = normalPlayer;
    self.showGoogleADs = YES;
    self.showFanADs = YES;
  
}


@end

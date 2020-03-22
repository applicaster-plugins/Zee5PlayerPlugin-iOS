//
//  ZEE5ConfigDataModel.m
//  ZEE5PlayerSDK
//
//  Created by admin on 23/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import "ZEE5ConfigDataModel.h"
#import <Zee5PlayerPlugin/ZEE5PlayerSDK.h>

@implementation ZEE5ConfigDataModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.authKey = @"jiolivetv_ios";
        self.registerPartnerURL = @"";
        self.vodContentDetailURL = @"";
        self.liveContentURL = @"";
        self.isConvivaEnabled = true;
        self.isGaEnabled = true;
        self.isSimilarVideos = true;

    }
    return self;
}

+ (instancetype)initFromJSONDictionary:(NSDictionary *)dict
{
    return [[self alloc]initWithNSValues];
}
////////Temp Arrangement//////

- (instancetype)initWithNSValues
{
    self =[super init];
    self.authKey = @"jiolivetv_ios";
    self.isSimilarVideos = true;
 
    return self;
}

@end

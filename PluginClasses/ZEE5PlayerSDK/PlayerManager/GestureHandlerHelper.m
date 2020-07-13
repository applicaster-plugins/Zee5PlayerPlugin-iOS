//
//  GestureHandlerHelper.m
//  ZEE5PlayerSDK
//
//  Created by admin on 06/12/20.
//  Copyright © 2020 ZEE5. All rights reserved.
//

#import "GestureHandlerHelper.h"

@interface GestureHandlerHelper ()

@property (nonatomic) BOOL isInPortraitMode;
@property (nonatomic) BOOL allowGestureHandler;

@end

@implementation GestureHandlerHelper

-(instancetype)init {
    if (self = [super init]) {
        _allowGestureHandler = YES;
    }
    return self;
}

- (void)didEnterLandscapeMode {
    self.isInPortraitMode = NO;
}

- (void)didEnterPortraitMode {
    self.isInPortraitMode = YES;
}

-(void)startAd {
    self.allowGestureHandler = NO;
}

-(void)endAd {
    self.allowGestureHandler = YES;
}

-(BOOL)isAllowed {
    return self.allowGestureHandler && self.isInPortraitMode;
}

@end

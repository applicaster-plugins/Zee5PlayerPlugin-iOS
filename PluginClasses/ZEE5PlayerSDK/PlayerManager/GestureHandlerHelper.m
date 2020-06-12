//
//  GestureHandlerHelper.m
//  ZEE5PlayerSDK
//
//  Created by admin on 06/12/20.
//  Copyright © 2020 ZEE5. All rights reserved.
//

#import "GestureHandlerHelper.h"

@interface GestureHandlerHelper ()
@property (nonatomic) BOOL allowOnPortraitModeOnly;
@end

@implementation GestureHandlerHelper

-(instancetype)initWithGestureHandler:(GestureHandler)handler {
    if (self = [super init]) {
        _allowGestureHandler = YES;
        _gestureHandler = handler;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
        _allowOnPortraitModeOnly = [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait ? YES : NO;
    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

-(void)startAd {
    self.allowGestureHandler = NO;
}

-(void)endAd {
    self.allowGestureHandler = YES;
}

-(void)execute {
    if (self.gestureHandler && self.allowGestureHandler && self.allowOnPortraitModeOnly) {
        self.gestureHandler();
    }
}

- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            switch(device.orientation)
            {
                case UIDeviceOrientationPortrait :
                    self.allowOnPortraitModeOnly = YES;
                    break;
                default:
                    self.allowOnPortraitModeOnly = NO;
                    break;
            };
        });
        
    });
}

@end

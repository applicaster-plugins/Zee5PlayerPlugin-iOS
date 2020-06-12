//
//  GestureHandlerHelper.h
//  ZEE5PlayerSDK
//
//  Created by admin on 06/12/20.
//  Copyright © 2020 ZEE5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZEE5PlayerManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface GestureHandlerHelper : NSObject
@property (nonatomic, copy) GestureHandler gestureHandler;
@property (nonatomic) BOOL allowGestureHandler;

-(instancetype)initWithGestureHandler:(GestureHandler)handler;

-(void)startAd;
-(void)endAd;
-(void)execute;
@end


NS_ASSUME_NONNULL_END

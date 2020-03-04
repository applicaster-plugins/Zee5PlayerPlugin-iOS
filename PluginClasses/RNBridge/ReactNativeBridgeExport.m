//
//  ZPReactNativeBridgeExport.m
//  ZappReactNativeAdapter
//
//  Created by Alex Zchut on 28/03/2017.
//  Copyright © 2017 Applicaster Ltd. All rights reserved.
//

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(ReactNativePlayerStatusModule, NSObject)

RCT_EXTERN_METHOD(getCurrentPlayable:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);

@end

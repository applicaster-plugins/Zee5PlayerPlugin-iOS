//
//  ZEE5SdkError.m
//  ZEE5PlayerSDK
//
//  Created by admin on 04/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import "ZEE5SdkError.h"

@implementation ZEE5SdkError
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (ZEE5SdkError*)initWithErrorCode:(NSInteger)code andZee5Code:(NSInteger)zeeerrorCode andMessage:(NSString*)message
{
    ZEE5SdkError *error = [[ZEE5SdkError alloc] init];
    error.code = code;
    error.message = message;
    error.zeeErrorCode = zeeerrorCode;
    return error;
}

@end

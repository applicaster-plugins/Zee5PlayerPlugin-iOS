//
//  ZEE5AdModel.m
//  ZEE5PlayerSDK
//
//  Created by Mani on 27/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import "ZEE5AdModel.h"
#import <Zee5PlayerPlugin/ZEE5PlayerSDK.h>



@implementation ZEE5AdModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tag = @"";
        self.tag_name = @"";
        self.time = @"";
    }
    return self;
}

+ (instancetype)initFromJSONDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithNSDictionary:dict];
}

- (instancetype)initWithNSDictionary:(NSDictionary *)dict{
    
    self = [super init];
    
    if (self && [dict isKindOfClass:NSDictionary.class])
    {
        self.tag = [dict ValueForKeyWithNullChecking:@"tag"];
        self.tag_name = [dict ValueForKeyWithNullChecking:@"tag_name"];
        self.time = [dict ValueForKeyWithNullChecking:@"time"];
    }
    
    return self;
}

@end

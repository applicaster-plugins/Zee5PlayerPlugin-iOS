//
//  ContentClickApi.h
//  ZEE5PlayerSDK
//
//  Created by Tejas Todkar on 04/11/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContentClickApi : NSObject

+ (ContentClickApi *)sharedInstance;

-(void)ContentConsumption;

@end

NS_ASSUME_NONNULL_END

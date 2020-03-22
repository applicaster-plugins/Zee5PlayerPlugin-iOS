//
//  FormRequestParamsAdapter.h
//  ZEE5PlayerSDK
//
//  Created by Mani on 06/06/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

#import <PlayKit/PlayKit-Swift.h>

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FormRequestParamsAdapter : NSObject <PKRequestParamsAdapter>
@property (nonatomic) NSDictionary* header;

@end

NS_ASSUME_NONNULL_END

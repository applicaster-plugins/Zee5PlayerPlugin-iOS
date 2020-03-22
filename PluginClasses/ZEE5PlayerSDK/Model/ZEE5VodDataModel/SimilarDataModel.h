//
//  SimilarDataModel.h
//  ZEE5PlayerSDK
//
//  Created by admin on 24/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZEE5CustomControl.h"

NS_ASSUME_NONNULL_BEGIN
@class RelatedVideos;

@interface SimilarDataModel : NSObject
+ (instancetype)initFromJSONDictionary:(NSDictionary *)dict;
@property ZEE5CustomControl *customControlView;

@property (nonatomic, copy) NSArray<RelatedVideos *> *relatedVideos;

@end

NS_ASSUME_NONNULL_END

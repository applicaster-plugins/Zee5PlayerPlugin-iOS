//
//  ZEE5ConfigDataModel.h
//  ZEE5PlayerSDK
//
//  Created by admin on 23/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZEE5ConfigDataModel : NSObject

@property (nonatomic, copy)   NSString *authKey;
@property (nonatomic, assign) BOOL isSimilarVideos;
@property (nonatomic, copy)   NSString *registerPartnerURL;
@property (nonatomic, copy)   NSString *vodContentDetailURL;
@property (nonatomic, copy)   NSString *liveContentURL;
@property (nonatomic, assign) BOOL isConvivaEnabled;
@property (nonatomic, assign) BOOL isGaEnabled;
@property (nonatomic, assign) BOOL isMetadataPush;

+ (instancetype)initFromJSONDictionary:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END

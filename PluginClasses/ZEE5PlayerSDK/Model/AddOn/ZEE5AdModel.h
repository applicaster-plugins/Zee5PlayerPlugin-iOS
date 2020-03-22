//
//  ZEE5AdModel.h
//  ZEE5PlayerSDK
//
//  Created by Mani on 27/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface ZEE5AdModel : NSObject
@property (nonatomic,strong) NSString *tag;
@property (nonatomic,strong) NSString *tag_name;
@property (nonatomic,strong) NSString *time;
@property (nonatomic) id adView;
@property (nonatomic) NSInteger tagValue;

+ (instancetype)initFromJSONDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END

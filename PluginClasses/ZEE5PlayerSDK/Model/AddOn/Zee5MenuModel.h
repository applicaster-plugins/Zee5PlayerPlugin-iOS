//
//  Zee5MenuModel.h
//  ZEE5PlayerSDK
//
//  Created by Mani on 18/06/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Zee5MenuModel : NSObject
@property (nonatomic) NSString *imageName;
@property (nonatomic) NSString *title;
@property (nonatomic) Boolean isSelected;
@property (nonatomic) NSInteger type;
@property (nonatomic) NSString *idValue;

@end

NS_ASSUME_NONNULL_END

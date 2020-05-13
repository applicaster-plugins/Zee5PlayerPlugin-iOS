//
//  AddToWatchlist.h
//  ZEE5PlayerSDK
//
//  Created by Tejas Todkar on 27/12/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN
@class CurrentItem;

@interface AddToWatchlist : NSObject

+ (AddToWatchlist *)Shared;
-(void)AddToWatchlist:(CurrentItem *)currentItem;
-(void)getWatchList:(NSString *)contentId;

@end

NS_ASSUME_NONNULL_END

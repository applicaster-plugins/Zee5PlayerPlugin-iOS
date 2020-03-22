//
//  ReportingManager.h
//  ZEE5PlayerSDK
//
//  Created by admin on 21/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class CurrentItem;

@interface ReportingManager : NSObject
+ (ReportingManager *)sharedInstance;
- (void)getWatchHistory;
- (void)startReportingWatchHistory;
- (void)reportWatchHistory;

- (void)gaEventManager:(NSDictionary *)dict;
@property (readwrite, nonatomic) BOOL isCountinueWatching;
@end

NS_ASSUME_NONNULL_END

//
//  Utility.h
//  ZEE5PlayerSDK
//
//  Created by admin on 11/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZEE5PlayerSDK.h"
#import "ZEE5PlayerConfig.h"
#import <Zee5PlayerPlugin/ZEE5PlayerConfig.h>


NS_ASSUME_NONNULL_BEGIN

@interface Utility : NSObject

+ (NSString *)makeUserId:(NSString*)user_id;
+ (NSString*)getAdvertisingIdentifier;
+ (NSString*)getCommaSaperatedGenreList:(NSArray<Genres*>*)genresArray;
+ (NSString *)convertEpochToTime:(NSTimeInterval)time;
+ (NSString *)convertEpochToDateTime:(NSTimeInterval)time;
+ (NSString *)convertEpochToDetailTime:(NSTimeInterval)time;
+ (NSString *)convertFullDateToDate:(NSString *)dateObj;
+ (NSString *)getCurrentDateInTimeStamp;
+ (NSString *)convertToString: (StreamType)type;
+ (NSString *)getLanguageStringFromId : (NSString *)strID;
+ (NSString *)getDuration:(NSInteger )currentDuraton total:(NSInteger)totalDuraton;
+ (NSMutableAttributedString *)addAttribuedFont :(NSTimeInterval)startTime :(NSTimeInterval)endTime;
+ (NSNumber *)secondsForTimeString:(NSString *)string;
+ (NSDictionary*)getDictionaryFrom:(NSString*)string;


////
+ (NSString *)convertDateFormat:(NSString *)dateObj toDateFormat:(NSString *)str;
+(NSString *)getCellularNetworkOperator;
+(NSString *)getNetworkConnectionType;
+(NSString *)stringFromTimeInterval:(NSTimeInterval)interval;
+(NSString *)getCountryName;

//////
+ (UIImage *)getGradientImageWithBounds:(CGRect)bounds;

+ (BOOL)isDate:(NSDate *)date inRangeFirstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate;



@end

NS_ASSUME_NONNULL_END

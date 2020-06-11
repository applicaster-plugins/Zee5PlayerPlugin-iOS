//
//  Utility.m
//  ZEE5PlayerSDK
//
//  Created by admin on 11/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import "Utility.h"
#import <AdSupport/ASIdentifierManager.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>


@interface Utility()
@property ZEE5PlayerConfig *config;

@end
@implementation Utility


+ (NSString *)makeUserId:(NSString*)user_id
{
    NSString *userId = user_id;
    
    if ([userId length] > 0) {
        
        if ([userId rangeOfString:@"@"].location == NSNotFound)
        {
            return [NSString stringWithFormat:@"%@@zee5jio.com", userId];

        }
        else
        {
            return userId;
        }
    }
    else
    {
        return [NSString stringWithFormat:@"%@@jio.com", [self getAdvertisingIdentifier]];
    }

    return user_id;
}

+ (NSString*)getAdvertisingIdentifier
{
    NSUUID *adId = [[ASIdentifierManager sharedManager] advertisingIdentifier];
    return [adId UUIDString];
}

+ (NSString*)getCommaSaperatedGenreList:(NSArray<Genres*>*)genresArray
{
    NSString *genreString = @"";
    for (Genres *genre in genresArray)
    {
        genreString = [NSString stringWithFormat:@"%@,",[genreString stringByAppendingString:genre.value]];
    }
    if ([genreString length] > 0) {
        genreString = [genreString substringToIndex:[genreString length] - 1];
    }
    return genreString;
}
+ (NSString *)convertFullDateToDate:(NSString *)dateObj
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];

    NSDate *date = [format dateFromString:dateObj];
    [format setDateFormat:@"dd MMM"];
    NSString* finalDateString = [format stringFromDate:date];

    return finalDateString;
}

+ (NSDictionary*)getDictionaryFrom:(NSString*)string
{
    NSData* jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    NSDictionary  *object = [NSJSONSerialization
                             JSONObjectWithData:jsonData
                             options:0
                             error:&error];
    return object;
}


+ (NSString *)convertEpochToTime:(NSTimeInterval)time
{
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"hh:mm a";
    
    NSString *strDate = [format stringFromDate:date];
    return strDate;
}

+ (NSString *)convertEpochToDateTime:(NSTimeInterval)time
{
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"EEEE, dd MMM, hh:mm a";
    
    NSString *strDate = [format stringFromDate:date];
    return strDate;
}

+ (NSString *)convertEpochToDetailTime:(NSTimeInterval)time
{
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"hh:mm:ss a";
    
    NSString *strDate = [format stringFromDate:date];
    return strDate;
}

+ (NSString *)getCurrentDateInTimeStamp
{
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSNumber *timeStampObj = [NSNumber numberWithDouble: timeStamp];
    return [NSString stringWithFormat:@"%ld",(long)[timeStampObj integerValue]];
}

+ (NSString *)convertToString: (StreamType)type
{
    switch (type) {
        case CONVIVA_STREAM_VOD:
            return @"vod";
            break;
        case CONVIVA_STREAM_LIVE:
            return @"live";
            break;
        case CONVIVA_STREAM_UNKNOWN:
            return @"";
            break;
        default:
            return @"dvr";
            
            break;
    }
}
+ (NSString *)getLanguageStringFromId : (NSString *)strID
{
    if ([strID isEqualToString:@"en"]) {
        return @"English";
    }
    else if ([strID isEqualToString:@"hi"]) {
        return @"Hindi";
    }
    else if ([strID isEqualToString:@"mr"]) {
        return @"Marathi";
    }
    else if ([strID isEqualToString:@"te"]) {
        return @"Telugu";
    }
    else if ([strID isEqualToString:@"kn"]) {
        return @"Kannada";
    }
    else if ([strID isEqualToString:@"ta"]) {
        return @"Tamil";
    }
    else if ([strID isEqualToString:@"ml"]) {
        return @"Malayalam";
    }
    else if ([strID isEqualToString:@"bn"]) {
        return @"Bengali";
    }
    else if ([strID isEqualToString:@"gu"]) {
        return @"Gujarati";
    }
    else if ([strID isEqualToString:@"pa"]) {
        return @"Punjabi";
    }
    else if ([strID isEqualToString:@"hr"]) {
        return @"Bhojpuri";
    }
    else if ([strID isEqualToString:@"or"]) {
        return @"Oriya";
    }
    return strID;
}

+ (BOOL)isDate:(NSDate *)date inRangeFirstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate
{
    return [date compare:firstDate] == NSOrderedDescending && [date compare:lastDate]  == NSOrderedAscending;
}

+ (NSString *)getDuration:(NSInteger )currentDuraton total:(NSInteger)totalDuraton
{
    int seconds = currentDuraton % 60;
    int minutes = (currentDuraton / 60) % 60;
    int hours = (int)(currentDuraton / 3600);
    
    //    int totalHours = totalDuraton / 3600;
    
    if(hours == 0)
    {
        return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }
    else
    {
        return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
        
    }
    
}

+ (NSString *)getDurationForAd:(NSInteger )currentDuraton total:(NSInteger)totalDuraton
{
    int seconds = currentDuraton % 60;
    int minutes = (currentDuraton / 60) % 60;
    int hours = (int)(currentDuraton / 3600);

return [NSString stringWithFormat:@"%02d:%02d:%02d.000",hours, minutes, seconds];
}

+ (NSNumber *)secondsForTimeString:(NSString *)string {
    
    NSArray *components = [string componentsSeparatedByString:@":"];
    NSInteger hours   = [[components objectAtIndex:0] integerValue];
    NSInteger minutes = [[components objectAtIndex:1] integerValue];
    NSInteger seconds = [[components objectAtIndex:2] integerValue];
    
    return [NSNumber numberWithInteger:(hours *3600) +(minutes *60) +seconds];
    }


+(NSMutableAttributedString *)addAttribuedFont :(NSTimeInterval)startTime :(NSTimeInterval)endTime
{
    NSDictionary *arialDict1 = [NSDictionary dictionaryWithObject: [UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    NSMutableAttributedString *aAttrString1 = [[NSMutableAttributedString alloc] initWithString:@"Playing '" attributes: arialDict1];
    
    NSDictionary *arialDict2 = [NSDictionary dictionaryWithObject: [UIColor colorWithRed:234.0/255.0 green:114.0/255.0 blue:67.0/255.0 alpha:1.0] forKey:NSForegroundColorAttributeName];
    NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:@"CATCHUP" attributes: arialDict2];
    
    NSMutableAttributedString *aAttrString3 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"' from %@ - %@",[Utility convertEpochToDateTime:startTime],[Utility convertEpochToTime:endTime]] attributes: arialDict1];
    
    [aAttrString1 appendAttributedString:aAttrString2];
    [aAttrString1 appendAttributedString:aAttrString3];
    return aAttrString1;
    
    
}

////

+ (NSString *)convertDateFormat:(NSString *)dateObj toDateFormat:(NSString *)str
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    
    NSDate *date = [format dateFromString: dateObj];
    [format setDateFormat: str];
    NSString* finalDateString = [format stringFromDate:date];
    
    return finalDateString;
}

////

+(NSString *)getCellularNetworkOperator
{
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    return [carrier carrierName];
}

+(NSString *)getNetworkConnectionType
{
    CTTelephonyNetworkInfo *telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
    NSString *technologyString = telephonyInfo.currentRadioAccessTechnology;
    
    NSString *str = @"WiFi";
    if ([technologyString isEqualToString: CTRadioAccessTechnologyLTE]) {
        str = @"LTE";
    } else if([technologyString isEqualToString: CTRadioAccessTechnologyWCDMA]) {
        str = @"3G";
    } else if([technologyString isEqualToString: CTRadioAccessTechnologyEdge]) {
        str = @"2G";
    }
    return str;
}

+(NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}
 
+(NSString *)getCountryName {
    NSString *name = [[NSLocale currentLocale] displayNameForKey: NSLocaleCountryCode value: NSLocale.currentLocale.countryCode];
    return name;
}

+ (UIImage *)getGradientImageWithBounds:(CGRect)bounds
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = bounds;
    gradientLayer.startPoint = CGPointMake(0.0, 0.5);
    gradientLayer.endPoint = CGPointMake(1.0, 0.5);
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:255.0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0] CGColor],(id)[[UIColor colorWithRed:161/255.0 green:0/255.0 blue:255/255.0 alpha:1.0] CGColor], nil];
    
    UIGraphicsBeginImageContext(gradientLayer.bounds.size);
    [gradientLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}





@end

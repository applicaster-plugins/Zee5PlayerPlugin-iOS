//
//  CurrentItem.h
//  ZEE5PlayerSDK
//
//  Created by admin on 06/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

//typedef enum {
//    vod,
//    live,
//    dvr
//} PlayerStreamType;

#import <Foundation/Foundation.h>
#import "Genres.h"
#import "RelatedVideos.h"
#import "ZEE5AdModel.h"
#import <ConvivaSDK/ConvivaSDK-iOS-umbrella.h>
NS_ASSUME_NONNULL_BEGIN

@interface CurrentItem : NSObject
@property(strong, nonnull) NSString *drm_key;
@property(strong, nonnull) NSString *hls_Url;
@property(strong, nonnull) NSString *hls_Full_Url;
@property (nonatomic, copy)   NSString *mpd_Url;
@property(strong, nonnull) NSString *imageUrl;
@property(strong, nonnull) NSString *TvShowImgurl;

@property(strong, nonnull) NSString *drm_token;
@property(strong, nonnull) NSString *business_type;
@property(strong, nonnull) NSArray *subTitles;
@property(strong, nonnull) NSArray *audioLanguages;
@property(strong, nonnull) NSArray *language;
@property(strong, nonnull) NSArray *charecters;
@property (nonatomic)StreamType streamType;
@property (strong, nonatomic) NSString* asset_type;
@property (strong, nonatomic) NSString* asset_subtype;
@property (nonatomic)   NSInteger episode_number;
@property (nonatomic, copy)   NSString *release_date;

@property (strong, nonatomic) NSArray<Genres*> *geners;
@property (strong, nonatomic) NSArray<RelatedVideos*> *related;
@property (strong, nonatomic) NSMutableArray<ZEE5AdModel*> *fanAds;
@property (strong, nonatomic) NSArray<ZEE5AdModel*> *googleAds;

@property(strong, nonnull) NSString *content_id;
@property(strong, nonnull) NSString *SeasonId;
@property(strong, nonnull) NSString *showId;
@property(strong, nonnull) NSString *channel_Name;
@property(strong, nonnull) NSString *showName;
@property (strong, nonatomic) NSString *ageRate;

@property(strong, nonnull) NSString *originalTitle;
@property(strong, nonnull) NSString *info;
@property(nonatomic) NSInteger duration;

@property (nonatomic, readwrite)  BOOL isDRM;
@property (nonatomic, readwrite)  BOOL WatchCredit;


@property (nonatomic, copy)NSString* skipintrotime;

@end

NS_ASSUME_NONNULL_END

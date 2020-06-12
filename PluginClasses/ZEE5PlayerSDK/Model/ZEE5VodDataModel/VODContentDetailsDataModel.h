//
//  VODContentDetailsDataModel.h
//  ZEE5PlayerSDK
//
//  Created by admin on 23/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Genres.h"
#import "RelatedVideos.h"



NS_ASSUME_NONNULL_BEGIN
@class RelatedVideos;
@class Genres;


@interface VODContentDetailsDataModel : NSObject
@property (nonatomic, copy)   NSString *identifier;
@property (nonatomic, copy)   NSString *trailerIdentifier;
@property (nonatomic, copy)   NSString *title;
@property (nonatomic, copy)   NSString *drmKeyID;
@property (nonatomic, copy)   NSArray *subtitleLanguages;
@property (nonatomic, copy)   NSArray *audioLanguages;
@property (nonatomic, copy)   NSArray *Languages;
@property (nonatomic, copy)   NSArray *charecters;
@property (nonatomic, copy)   NSString *assetType;
@property (nonatomic, copy)   NSString *assetSubtype;
@property (nonatomic)   NSInteger episodeNumber;
@property (nonatomic)   NSInteger duration;
@property (nonatomic, copy)   NSString *releaseDate;
@property (nonatomic, copy)   NSString *ageRating;
@property (nonatomic, copy)   NSString *buisnessType;



@property (nonatomic, copy)   NSString *descriptionContent;
@property (nonatomic, copy)   NSString *contentLength;

@property (nonatomic, copy)   NSString *hlsUrl;
@property (nonatomic, copy)   NSString *mpdUrl;
@property (nonatomic, copy)   NSString *web_Url;
@property (nonatomic, copy)   NSString *imageUrl;
@property (nonatomic, copy)NSString* introStarttime;
@property (nonatomic, copy)NSString* introEndTime;
@property (nonatomic, copy)NSString* watchCreditTime;

@property (nonatomic, readwrite)  BOOL isDRM;
@property (nonatomic,readwrite)BOOL ageRatingAdult;
@property (nonatomic,readwrite)BOOL isBeforeTv;


@property (nonatomic, copy) NSArray<Genres *> *geners;
@property (nonatomic, copy) NSArray<RelatedVideos *> *relatedVideos;
@property (nonatomic, copy)   NSString *contentDescription;


///TV Show Details///
@property (nonatomic, copy)   NSString *showOriginalTitle;
@property (nonatomic, copy)   NSString *tvShowBuisnessType;
@property (nonatomic, copy)   NSString *tvShowAssetSubtype;
@property (nonatomic, copy)   NSString *tvShowimgurl;
@property (nonatomic, copy)   NSString *tvShowId;

// Season Details If Available
@property (nonatomic, copy)   NSString *SeasonId;




+ (instancetype)initFromJSONDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END

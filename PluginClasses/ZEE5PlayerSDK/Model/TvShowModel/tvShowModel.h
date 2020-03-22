//
//  tvShowModel.h
//  Zee5PlayerPlugin
//
//  Created by Tejas Todkar on 02/03/20.
//

#import <Foundation/Foundation.h>
#import "EpisodesDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface tvShowModel : NSObject

@property (nonatomic, copy)   NSString *identifier;
@property (nonatomic, copy)   NSString *title;

@property (nonatomic, copy)   NSArray *seasons;
@property (nonatomic, copy)   NSArray *audioLanguages;
@property (nonatomic, copy)   NSArray *subtitleLanguages;
@property (nonatomic, copy)   NSString *assetType;
@property (nonatomic, copy)   NSString *assetSubtype;
@property (nonatomic)   NSInteger totalSeasons;
@property (nonatomic, copy)   NSString *releaseDate;
@property (nonatomic, copy)   NSString *ageRating;
@property (nonatomic, copy)   NSString *seasonBuisnessType;
@property (nonatomic, readwrite)  BOOL isDRM;
@property (nonatomic,readwrite)BOOL ageRatingAdult;
@property (nonatomic, copy)   NSString *descriptionContent;
@property (nonatomic, copy)   NSString *web_Url;

@property (nonatomic, copy) NSArray<EpisodesDataModel *> *Episodes;


//// ********latest Season From Season Array *********
@property (nonatomic, copy)   NSDictionary *LatestSeason;
@property (nonatomic, copy)   NSString *LatestSeasonAssetType;
@property (nonatomic, copy)   NSString *LatestSeasonAssetSubtype;
@property (nonatomic, copy)   NSString *LatestSeasonId;

//// ******** Trailers  From LatestSeason Array *********
@property (nonatomic, copy)   NSArray *Trailers;
//// ******** First Trailers  Object  From Trailers Array *********
@property (nonatomic, copy)   NSArray *FirstTrailers;
@property (nonatomic, copy)   NSString *TrailersContentid;


+ (instancetype)initFromJSONDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END

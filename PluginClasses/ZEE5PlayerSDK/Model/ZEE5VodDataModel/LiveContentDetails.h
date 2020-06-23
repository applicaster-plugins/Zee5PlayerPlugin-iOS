//
//  LiveContentDetails.h
//  Zee5PlayerPlugin
//
//  Created by Tejas Todkar on 11/12/19.
//

#import <Foundation/Foundation.h>
#import "Genres.h"
#import "RelatedVideos.h"


NS_ASSUME_NONNULL_BEGIN
@class RelatedVideos;
@class Genres;

@interface LiveContentDetails : NSObject

@property (nonatomic, copy)   NSString *identifier;
@property (nonatomic, copy)   NSString *assetType;
@property (nonatomic, copy)   NSString *title;
@property (nonatomic, copy)   NSString *showOriginalTitle;
@property (nonatomic, copy)   NSString *descriptionContent;
@property (nonatomic, copy)   NSString *StreamhlsUrl;
@property (nonatomic, copy)   NSString *StreamUrl;
@property (nonatomic, copy)   NSString *cacheUpHours;
@property (nonatomic, readwrite)  BOOL isDRM;
@property (nonatomic, copy)   NSString *drmKeyID;
@property (nonatomic, copy) NSArray<Genres *> *geners;
@property (nonatomic, copy)   NSArray *Tags;
@property (nonatomic, copy)   NSArray *languages;
@property (nonatomic, copy)   NSArray *subtitleLanguages;
@property (nonatomic, copy)   NSString *coverImage;
@property (nonatomic, copy)   NSDictionary *Licence;
@property (nonatomic, copy)   NSString *buisnessType;
@property (nonatomic, copy)   NSString *Image;

@property (nonatomic, copy) NSArray<RelatedVideos *> *relatedVideos;
+ (instancetype)initFromJSONDictionary:(NSDictionary *)dict;


@end

NS_ASSUME_NONNULL_END

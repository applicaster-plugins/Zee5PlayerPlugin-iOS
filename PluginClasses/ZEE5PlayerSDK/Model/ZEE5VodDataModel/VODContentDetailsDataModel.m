//
//  VODContentDetailsDataModel.m
//  ZEE5PlayerSDK
//
//  Created by admin on 23/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import "VODContentDetailsDataModel.h"
#import <Zee5PlayerPlugin/ZEE5PlayerSDK.h>



@implementation VODContentDetailsDataModel

+ (instancetype)initFromJSONDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithNSDictionary:dict];
}

- (instancetype)initWithNSDictionary:(NSDictionary *)dict{
    
    self = [super init];
    
    if (self && [dict isKindOfClass:NSDictionary.class]) {
        self.identifier = [dict ValueForKeyWithNullChecking:@"id"];
        self.title = [dict ValueForKeyWithNullChecking:@"title"];
        self.drmKeyID = [dict ValueForKeyWithNullChecking:@"drm_key_id"];
        self.subtitleLanguages = [dict ValueForKeyWithNullChecking:@"subtitle_languages"];
        self.audioLanguages = [dict ValueForKeyWithNullChecking:@"audio_languages"];
        self.assetType = [NSString stringWithFormat:@"%d", [[dict ValueForKeyWithNullChecking:@"asset_type"]intValue]];
        self.assetSubtype = [dict ValueForKeyWithNullChecking:@"asset_subtype"];
        self.releaseDate = [dict ValueForKeyWithNullChecking:@"release_date"];
        self.episodeNumber = [[dict ValueForKeyWithNullChecking:@"episode_number"] integerValue];
        self.duration = [[dict ValueForKeyWithNullChecking:@"duration"] integerValue];
        self.ageRating = [dict ValueForKeyWithNullChecking:@"age_rating"];
        self.imageUrl = [dict ValueForKeyWithNullChecking:@"image_url"];
        self.web_Url = [dict ValueForKeyWithNullChecking:@"web_url"];
        
        if ([self.ageRating isEqualToString:@"A"])
        {
           self.ageRatingAdult = true;
        }
        self.buisnessType = [dict ValueForKeyWithNullChecking:@"business_type"];
        
        
        
        self.introStarttime =[[dict valueForKey:@"skip_available"] valueForKey:@"intro_start_s"];
        self.introEndTime =[[dict valueForKey:@"skip_available"] valueForKey:@"intro_end_s"];
        self.watchCreditTime =@"NULL";
        if (dict [@"end_credits_marker"])
        {
            self.watchCreditTime = [dict ValueForKeyWithNullChecking:@"end_credits_marker"];
        }
       
        if ([[dict ValueForKeyWithNullChecking:@"hls"] isKindOfClass:NSArray.class]) {
            NSArray *urls = [dict ValueForKeyWithNullChecking:@"hls"];
            self.hlsUrl = [urls firstObject];
        }
        if ([[dict ValueForKeyWithNullChecking:@"video"] isKindOfClass:NSArray.class]) {
            NSArray *urls = [dict ValueForKeyWithNullChecking:@"video"];
            self.mpdUrl = [NSString stringWithFormat:@"%@",[urls firstObject]];
        }
        
        if ([[dict ValueForKeyWithNullChecking:@"is_drm"] isKindOfClass:NSNumber.class]) {
            self.isDRM = [[dict ValueForKeyWithNullChecking:@"is_drm"] boolValue];
        }

        NSMutableArray <Genres*>*genreArray = [[NSMutableArray alloc] init];
        
        if ([[dict ValueForKeyWithNullChecking:@"genre"] isKindOfClass:NSArray.class]) {
            
            for (NSDictionary *genreDict in [dict ValueForKeyWithNullChecking:@"genre"]) {
                
                Genres *genre = [[Genres alloc] init];
                genre.identifier = [genreDict ValueForKeyWithNullChecking:@"id"];
                genre.value = [genreDict ValueForKeyWithNullChecking:@"value"];
                
                [genreArray addObject:genre];
            }
            self.geners = genreArray;
        }
        
        NSMutableArray <RelatedVideos*>*relatedVideosArray = [[NSMutableArray alloc] init];

        if ([[dict ValueForKeyWithNullChecking:@"related"] isKindOfClass:NSArray.class]) {
            
            for (NSDictionary *relatedDict in [dict ValueForKeyWithNullChecking:@"related"])
            {
                RelatedVideos *related = [[RelatedVideos alloc] init];
                related.identifier = [relatedDict valueForKey:@"id"];
                related.imageURL = [relatedDict valueForKey:@"image_url"];
                related.title = [relatedDict valueForKey:@"title"];
                related.assetSubtype = [relatedDict valueForKey:@"asset_subtype"];
                if ([related.assetSubtype isEqualToString:@"trailer"])
                {
                    self.trailerIdentifier = related.identifier;
                    NSLog(@" Trailer id here %@", self.trailerIdentifier);
                }
                [relatedVideosArray addObject:related];
            }
            self.relatedVideos = relatedVideosArray;
        }
        
        self.contentDescription = [dict ValueForKeyWithNullChecking:@"description"];
        
        if ([[dict ValueForKeyWithNullChecking:@"tvshow_details"] isKindOfClass: NSDictionary.class]) {
            NSDictionary * showDetail = [dict ValueForKeyWithNullChecking:@"tvshow_details"];
            NSString *str = [showDetail ValueForKeyWithNullChecking: @"original_title"];
            self.tvShowBuisnessType = [showDetail ValueForKeyWithNullChecking:@"business_type"];
            
            /// ********* Before TV Logic On PopUp Close ***************//////////////
              if (!([self.tvShowBuisnessType isEqualToString:@"premium"] || [self.tvShowBuisnessType isEqualToString:@"premium_downloadable"]) && ([self.buisnessType isEqualToString:@"premium"] || [self.buisnessType isEqualToString:@"premium_downloadable"]))
                  {
                      self.isBeforeTv = true;
                  }
            
            self.showOriginalTitle = str;
            
            
            
        }
        
    }
    
    return self;
}

@end

//
//  tvShowModel.m
//  Zee5PlayerPlugin
//
//  Created by Tejas Todkar on 02/03/20.
//

#import "tvShowModel.h"
#import <Zee5PlayerPlugin/ZEE5PlayerSDK.h>

@implementation tvShowModel



+ (instancetype)initFromJSONDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithNSDictionary:dict];
}

- (instancetype)initWithNSDictionary:(NSDictionary *)dict{
    
    self = [super init];
    
    if (self && [dict isKindOfClass:NSDictionary.class]) {
        self.identifier = [dict ValueForKeyWithNullChecking:@"id"];
        self.title = [dict ValueForKeyWithNullChecking:@"title"];
        self.subtitleLanguages = [dict ValueForKeyWithNullChecking:@"subtitle_languages"];
        self.audioLanguages = [dict ValueForKeyWithNullChecking:@"audio_languages"];
        
        self.assetType = [NSString stringWithFormat:@"%d", [[dict ValueForKeyWithNullChecking:@"asset_type"]intValue]];
        self.assetSubtype = [dict ValueForKeyWithNullChecking:@"asset_subtype"];
        self.totalSeasons = [[dict ValueForKeyWithNullChecking:@"total_seasons"]intValue];
        
        self.releaseDate = [dict ValueForKeyWithNullChecking:@"release_date"];
        
        self.ageRating = [dict ValueForKeyWithNullChecking:@"age_rating"];
        self.web_Url = [dict ValueForKeyWithNullChecking:@"web_url"];
        self.seasonBuisnessType = [dict ValueForKeyWithNullChecking:@"business_type"];
        
        if ([[dict ValueForKeyWithNullChecking:@"is_drm"] isKindOfClass:NSNumber.class]) {
            self.isDRM = [[dict ValueForKeyWithNullChecking:@"is_drm"] boolValue];
        }
        self.descriptionContent = [dict ValueForKeyWithNullChecking:@"description"];
        
        
        self.seasons = [dict ValueForKeyWithNullChecking:@"seasons"];
        
        if ([self.seasons isKindOfClass:[NSArray class]] || self.seasons.count>0)
               {
                   self.LatestSeason = [self.seasons objectAtIndex:0];
                   self.LatestSeasonId = [self.LatestSeason valueForKey:@"id"];
                   self.LatestSeasonAssetType =[NSString stringWithFormat:@"%d",[[self.LatestSeason valueForKey:@"asset_type"]intValue]];
    
                  self.Trailers = [self.LatestSeason valueForKey:@"trailers"];
                   
                   if (self.Trailers.count>0) {
                       self.FirstTrailers = [self.Trailers objectAtIndex:0];
                       self.TrailersContentid = [self.FirstTrailers valueForKey:@"id"];
                   }
                
                   NSMutableArray <EpisodesDataModel*>*EpisodeArray = [[NSMutableArray alloc] init];

                   if ([[self.LatestSeason ValueForKeyWithNullChecking:@"episodes"] isKindOfClass:NSArray.class]) {
                       
                       for (NSDictionary *episodeDict in [self.LatestSeason ValueForKeyWithNullChecking:@"episodes"])
                       {
                           EpisodesDataModel *episode = [[EpisodesDataModel alloc] init];
                           episode.episodeId = [episodeDict valueForKey:@"id"];
                           episode.episodeAssetType = [[episodeDict valueForKey:@"asset_type"]intValue];
                           episode.episodeTitle = [episodeDict valueForKey:@"title"];
                           episode.episodeAssetSubtype = [episodeDict valueForKey:@"asset_subtype"];
                           episode.episodeBuisnesstype = [episodeDict valueForKey:@"business_type"];

                           [EpisodeArray addObject:episode];
                       }
                       self.Episodes = EpisodeArray;
                   }
        
    }
    }
    return self;
}

@end

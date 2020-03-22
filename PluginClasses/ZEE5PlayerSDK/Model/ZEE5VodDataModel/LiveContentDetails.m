//
//  LiveContentDetails.m
//  Zee5PlayerPlugin
//
//  Created by Tejas Todkar on 11/12/19.
//

#import "LiveContentDetails.h"
#import <Zee5PlayerPlugin/ZEE5PlayerSDK.h>

@implementation LiveContentDetails


+ (instancetype)initFromJSONDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithNSDictionary:dict];
}

- (instancetype)initWithNSDictionary:(NSDictionary *)dict{
    
    self = [super init];
    
    if (self && [dict isKindOfClass:NSDictionary.class]) {
        self.identifier = [dict ValueForKeyWithNullChecking:@"id"];
        self.assetType = [NSString stringWithFormat:@"%d", [[dict ValueForKeyWithNullChecking:@"asset_type"]intValue]];
        self.title = [dict ValueForKeyWithNullChecking:@"title"];
        self.showOriginalTitle = [dict ValueForKeyWithNullChecking:@"original_title"];
        self.descriptionContent = [dict ValueForKeyWithNullChecking:@"description"];
        self.StreamhlsUrl = [dict ValueForKeyWithNullChecking:@"stream_url_hls"];
        self.StreamUrl = [dict ValueForKeyWithNullChecking:@"stream_url"];
        self.cacheUpHours = [dict ValueForKeyWithNullChecking:@"catch_up_hours"];
        self.drmKeyID = [dict ValueForKeyWithNullChecking:@"drm_key_id"];
        self.subtitleLanguages = [dict ValueForKeyWithNullChecking:@"subtitle_languages"];
        self.languages = [dict ValueForKeyWithNullChecking:@"languages"];
        self.Tags = [dict ValueForKeyWithNullChecking:@"tags"];
        self.buisnessType = [dict ValueForKeyWithNullChecking:@"business_type"];
        self.coverImage = [dict ValueForKeyWithNullChecking:@"cover_image"];
        
        if ([[dict ValueForKeyWithNullChecking:@"licensing"] isKindOfClass:NSDictionary.class]) {
                   self.Licence = [dict ValueForKeyWithNullChecking:@"licensing"];
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
            
            for (NSDictionary *relatedDict in [dict ValueForKeyWithNullChecking:@"related"]) {
                RelatedVideos *related = [[RelatedVideos alloc] init];
                related.identifier = [relatedDict valueForKey:@"id"];
                related.imageURL = [relatedDict valueForKey:@"image_url"];
                related.title = [relatedDict valueForKey:@"title"];
                [relatedVideosArray addObject:related];
            }
            self.relatedVideos = relatedVideosArray;
        }
    }
    
    return self;
}

@end

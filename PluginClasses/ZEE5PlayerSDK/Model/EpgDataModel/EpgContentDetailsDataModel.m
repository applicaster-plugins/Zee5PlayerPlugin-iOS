//
//  LiveContentDetailsDataModel.m
//  ZEE5PlayerSDK
//
//  Created by admin on 23/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import "EpgContentDetailsDataModel.h"
#import <Zee5PlayerPlugin/ZEE5PlayerSDK.h>

@implementation EpgContentDetailsDataModel

+ (instancetype)initFromJSONDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithNSDictionary:dict];
}

- (instancetype)initWithNSDictionary:(NSDictionary *)dict{
    
    self = [super init];
    
    if (self && [dict isKindOfClass:NSDictionary.class]) {

        self.hlsFullURL = [dict ValueForKeyWithNullChecking:@"hls_full_url"];
        NSString *streamType = [dict ValueForKeyWithNullChecking:@"video_type"];
        
        if ([streamType isEqualToString:@"vod"])
        {
            self.videoType = CONVIVA_STREAM_VOD;
        }
         else if ([streamType isEqualToString:@"dvr"])
        {
            self.videoType = CONVIVA_STREAM_UNKNOWN;  // TT
        }
        
        if ([[dict valueForKey:@"payload"] isKindOfClass:NSDictionary.class]) {
            
            NSDictionary *payload = [dict valueForKey:@"payload"];

            self.identifier = [payload ValueForKeyWithNullChecking:@"id"];
            self.assetType = [NSString stringWithFormat:@"%d", [[payload ValueForKeyWithNullChecking:@"asset_type"]intValue]];
            self.assetSubtype = [payload ValueForKeyWithNullChecking:@"asset_subtype"];

            NSMutableArray <Genres*>*genreArray = [[NSMutableArray alloc] init];
            
            if ([[payload ValueForKeyWithNullChecking:@"genre"] isKindOfClass:NSArray.class]) {
                
                for (NSDictionary *genreDict in [payload ValueForKeyWithNullChecking:@"genre"]) {
                    
                    Genres *genre = [[Genres alloc] init];
                    genre.identifier = [genreDict ValueForKeyWithNullChecking:@"id"];
                    genre.value = [genreDict ValueForKeyWithNullChecking:@"value"];
                    
                    [genreArray addObject:genre];
                }
                self.geners = genreArray;
            }
            else{
                self.geners = @[];

            }
            
            NSMutableArray <RelatedVideos*>*relatedVideosArray = [[NSMutableArray alloc] init];
            if ([[payload ValueForKeyWithNullChecking:@"related"] isKindOfClass:NSArray.class]) {
                
                for (NSDictionary *relatedDict in [payload ValueForKeyWithNullChecking:@"related"]) {
                    RelatedVideos *related = [[RelatedVideos alloc] init];
                    related.identifier = [relatedDict valueForKey:@"id"];
                    related.imageURL = [relatedDict valueForKey:@"image_url"];
                    related.title = [relatedDict valueForKey:@"title"];
                    [relatedVideosArray addObject:related];
                }
                self.relatedVideos = relatedVideosArray;
            }
            else
            {
                self.relatedVideos = @[];
            }

            
            if (self.videoType !=CONVIVA_STREAM_UNKNOWN || self.videoType!= CONVIVA_STREAM_LIVE || self.videoType!=CONVIVA_STREAM_VOD) {
                
                NSDictionary *channelInfo = [payload ValueForKeyWithNullChecking:@"channel_info"];
                if ([channelInfo isKindOfClass:[NSDictionary class]]) {
                    
                    self.identifier = [channelInfo ValueForKeyWithNullChecking:@"id"];
                    self.channel_name = [channelInfo ValueForKeyWithNullChecking:@"original_title"];
                    self.show_name = [channelInfo ValueForKeyWithNullChecking:@"show_name"];

                }
            }
            else if (self.videoType == CONVIVA_STREAM_VOD)
            {
                if ([[dict valueForKey:@"payload"] isKindOfClass:NSDictionary.class]) {
                    
                    NSDictionary *payload = [dict valueForKey:@"payload"];
                    
                    self.assetSubtype = [payload ValueForKeyWithNullChecking:@"asset_subtype"];
                    self.identifier = [payload ValueForKeyWithNullChecking:@"id"];

                    if ([[payload ValueForKeyWithNullChecking:@"hls"] isKindOfClass:NSArray.class]) {
                        NSArray *urls = [payload ValueForKeyWithNullChecking:@"hls"];
                        self.hlsUrl = [urls firstObject];
                    }
                    
                    if ([[payload ValueForKeyWithNullChecking:@"is_drm"] isKindOfClass:NSNumber.class]) {
                        self.isDRM = [[payload ValueForKeyWithNullChecking:@"is_drm"] boolValue];
                    }
                    
                    self.drmKeyID = [payload ValueForKeyWithNullChecking:@"drm_key_id"];

                }


                
                NSDictionary *channelInfo = [payload ValueForKeyWithNullChecking:@"channel_info"];
                if ([channelInfo isKindOfClass:[NSDictionary class]]) {
                    
                    self.channel_name = [channelInfo ValueForKeyWithNullChecking:@"original_title"];
                    self.show_name = [channelInfo ValueForKeyWithNullChecking:@"show_name"];

                }
            }
        }
        


        
    }
    return self;
}

@end

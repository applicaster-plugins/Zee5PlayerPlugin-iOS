//
//  SimilarDataModel.m
//  ZEE5PlayerSDK
//
//  Created by admin on 24/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import "SimilarDataModel.h"
#import <Zee5PlayerPlugin/ZEE5PlayerSDK.h>


@implementation SimilarDataModel

+ (instancetype)initFromJSONDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithNSDictionary:dict];
}

- (instancetype)initWithNSDictionary:(NSDictionary *)dict{
    
    self = [super init];
    
    if (self && [dict isKindOfClass:NSDictionary.class]) {

        NSMutableArray <RelatedVideos*>*relatedVideosArray = [[NSMutableArray alloc] init];
        
        if ([[dict ValueForKeyWithNullChecking:@"items"] isKindOfClass:NSArray.class]) {
           
            for (NSDictionary *relatedDict in [dict ValueForKeyWithNullChecking:@"items"])
            {
                RelatedVideos *related = [[RelatedVideos alloc] init];
                related.identifier = [relatedDict valueForKey:@"id"];
                related.imageURL = [relatedDict valueForKey:@"image_url"];
                related.title = [relatedDict valueForKey:@"title"];
                related.assetType = [[relatedDict valueForKey:@"asset_type"]intValue];
                related.deepLink  = [relatedDict valueForKey:@"deeplink"];
                related.isAppSwitch = [[relatedDict valueForKey:@"is_app_switch"] boolValue];
                related.assetSubtype = [relatedDict valueForKey:@"asset_subtype"];
                [relatedVideosArray addObject:related];
            }
            self.relatedVideos = relatedVideosArray;
        }
    }
    
    return self;
}

@end

//
//  LiveContentDetailsDataModel.h
//  ZEE5PlayerSDK
//
//  Created by admin on 23/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ConvivaSDK/ConvivaSDK-iOS-umbrella.h>


NS_ASSUME_NONNULL_BEGIN
@class Genres;
@class RelatedVideos;

@interface EpgContentDetailsDataModel : NSObject

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy)   NSString *channel_name;
@property (nonatomic, copy)   NSString *show_name;
@property (nonatomic, copy) NSString *hlsFullURL;
@property (nonatomic, copy) NSString *assetType;
@property (nonatomic) StreamType videoType;
@property (nonatomic, copy)NSArray<Genres *> *geners;
@property (nonatomic, copy)   NSString *assetSubtype;
@property (nonatomic, copy) NSArray<RelatedVideos *> *relatedVideos;
@property (nonatomic, copy)   NSString *hlsUrl;
@property (nonatomic, readwrite)  BOOL isDRM;
@property (nonatomic, copy)   NSString *drmKeyID;
@property (nonatomic, copy)   NSArray *subtitleLanguages;



+ (instancetype)initFromJSONDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END

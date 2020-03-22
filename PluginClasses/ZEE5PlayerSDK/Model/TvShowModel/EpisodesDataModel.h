//
//  EpisodesDataModel.h
//  Zee5PlayerPlugin
//
//  Created by Tejas Todkar on 02/03/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EpisodesDataModel : NSObject

@property (nonatomic, copy)NSString* episodeId;
@property (nonatomic)NSInteger episodeAssetType;
@property (nonatomic, copy)NSString* episodeTitle;
@property (nonatomic, copy)NSString* episodeBuisnesstype;
@property (nonatomic, copy)NSString* episodeAssetSubtype;

@end

NS_ASSUME_NONNULL_END

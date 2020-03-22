//
//  Zee5CollectionCell.h
//  ZEE5PlayerSDK
//
//  Created by admin on 13/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN
@class RelatedVideos;

@interface Zee5CollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIView *counterView;

- (void)configureCellWith:(RelatedVideos *)model;

@end

NS_ASSUME_NONNULL_END

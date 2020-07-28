//
//  Zee5CollectionCell.m
//  ZEE5PlayerSDK
//
//  Created by admin on 13/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import "Zee5CollectionCell.h"
#import <Zee5PlayerPlugin/ZEE5PlayerSDK.h>

@implementation Zee5CollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)configureCellWith:(RelatedVideos *)model
{
    self.labelTitle.text = model.title;
    NSBundle *bundel = [NSBundle bundleForClass:self.class];
    self.imageView.image  = [UIImage imageNamed:@"placeholder" inBundle:bundel compatibleWithTraitCollection:nil];
    self.labelTitle.hidden = NO;
    if (ZEE5PlayerSDK.getConsumpruionType == Movie  || ZEE5PlayerSDK.getConsumpruionType == Live) {
        self.labelTitle.hidden = YES;
    }

    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: model.imageURL]];
        if ( data == nil )
            return;
        dispatch_async(dispatch_get_main_queue(), ^{
            // WARNING: is the cell still using the same data by this point??
            self.imageView.image = [UIImage imageWithData: data];
        });
    });

}

@end

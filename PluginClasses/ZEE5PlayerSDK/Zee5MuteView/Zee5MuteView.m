//
//  Zee5MuteView.m
//  ZEE5PlayerSDK
//
//  Created by Mani on 26/06/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

#import "Zee5MuteView.h"
#import "Zee5PlayerPlugin/ZEE5PlayerSDK.h"

@implementation Zee5MuteView

- (void)awakeFromNib
{
    [super awakeFromNib];

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.shadowLayer == nil) {
        self.shadowLayer = [CAGradientLayer layer];
    }
    else
    {
        [self.shadowLayer removeFromSuperlayer];
    }
    self.shadowLayer.frame = self.shadowView.bounds;
    self.shadowLayer.colors = [NSArray arrayWithObjects:(id)[UIColor blackColor].CGColor,(id)[UIColor colorWithWhite:1 alpha:0].CGColor, nil];
    self.shadowLayer.startPoint = CGPointMake(1.0f, 1.0f);
    self.shadowLayer.endPoint = CGPointMake(1.0f, 0.7f);
    [self.shadowView.layer insertSublayer:self.shadowLayer atIndex:0];

}

- (IBAction)btnMuteClicked:(UIButton *)sender {
}
- (IBAction)btnTapOnPlayer:(UIButton *)sender {
    [[ZEE5PlayerManager sharedInstance] navigateToDetail];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

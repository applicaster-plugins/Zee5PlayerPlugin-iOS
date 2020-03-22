//
//  upgradeSubscriView.m
//  ZEE5PlayerSDK
//
//  Created by Tejas Todkar on 17/10/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

#import "upgradeSubscriView.h"
#import <Zee5PlayerPlugin/ZEE5PlayerSDK.h>
#import "Zee5PlayerPlugin/Zee5PlayerPlugin-Swift.h"

@implementation upgradeSubscriView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self makeDragable];

    _proceedOutlet.layer.cornerRadius =23.0f;
    _proceedOutlet.layer.borderWidth =0.8;
    [_proceedOutlet.layer setMasksToBounds:YES];
    [_proceedOutlet setBackgroundImage:[Utility getGradientImageWithBounds:_proceedOutlet.bounds] forState:UIControlStateNormal];
    
}
- (void)layoutSubviews
{
  [super layoutSubviews];
    
    UIBezierPath *maskPath = [UIBezierPath
                              bezierPathWithRoundedRect:self.outerView.bounds
                              byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                              cornerRadii:CGSizeMake(25, 25)
                              ];

    CAShapeLayer *maskLayer = [CAShapeLayer layer];

    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.outerView.layer.mask = maskLayer;

}

- (IBAction)proceedAction:(id)sender
{
    
}
- (IBAction)termsOfUse:(id)sender
{
    
}
- (IBAction)privacyPolicyAction:(id)sender
{
    
}
- (IBAction)closeBtnAction:(id)sender{
    [[ZEE5PlayerManager sharedInstance]removeSubview];
}
- (IBAction)ApplyAction:(id)sender {
}


@end

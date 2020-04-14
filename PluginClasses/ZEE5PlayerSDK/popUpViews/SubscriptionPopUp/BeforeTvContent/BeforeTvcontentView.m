//
//  BeforeTvcontentView.m
//  ZEE5PlayerSDK
//
//  Created by Tejas Todkar on 24/10/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

#import "BeforeTvcontentView.h"
#import <Zee5PlayerPlugin/ZEE5PlayerSDK.h>
#import "Zee5PlayerPlugin/Zee5PlayerPlugin-Swift.h"

@implementation BeforeTvcontentView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self makeDragable];
    
    if (ZEE5PlayerSDK.getUserTypeEnum == Guest)
    {
        self.guestView.hidden =NO;
    }
    else
    {
         self.subscribeView.hidden =YES;
    }
    
    
    _subscribenowOutlet.layer.cornerRadius =23.0f;
    _subscribenowOutlet.layer.borderWidth =0.8;
    [_subscribenowOutlet.layer setMasksToBounds:YES];
    [_subscribenowOutlet setBackgroundImage:[Utility getGradientImageWithBounds:_subscribenowOutlet.bounds] forState:UIControlStateNormal];
    
    
    
      _loginOutlet.layer.cornerRadius =23.0f;
      _loginOutlet.layer.borderWidth =0.8;
      _loginOutlet.layer.borderColor = [[UIColor whiteColor]CGColor];
       [_loginOutlet.layer setMasksToBounds:YES];
}




- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIBezierPath *maskPath = [UIBezierPath
                              bezierPathWithRoundedRect:self.guestView.bounds
                              byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                              cornerRadii:CGSizeMake(25, 25)
                              ];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.guestView.layer.mask = maskLayer;
    self.subscribeView.layer.mask = maskLayer;

}



- (IBAction)subscribeNowAction:(id)sender
{
    [[ZEE5PlayerManager sharedInstance]tapOnSubscribeButton];
}
- (IBAction)loginAction:(id)sender
{
    [[ZEE5PlayerManager sharedInstance]tapOnLoginButton];
}
- (IBAction)watchFreeEpisodeAction:(id)sender
{
    
}

- (IBAction)closeBtnAction:(id)sender{
    [[ZEE5PlayerManager sharedInstance]removeSubview];
}
@end

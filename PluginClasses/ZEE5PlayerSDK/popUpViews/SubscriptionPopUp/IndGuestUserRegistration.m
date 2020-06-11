//
//  IndGuestUserRegistration.m
//  ZEE5PlayerSDK
//
//  Created by Tejas Todkar on 22/10/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

#import "IndGuestUserRegistration.h"
#import <Zee5PlayerPlugin/ZEE5PlayerSDK.h>
#import "Zee5PlayerPlugin/Zee5PlayerPlugin-Swift.h"


@implementation IndGuestUserRegistration


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self makeDragable];
    
    [self.subscribeBtnOutlet setTitle:@"Subscribe Now" forState:UIControlStateNormal];
    
    if (ZEE5PlayerSDK.getUserTypeEnum == Guest)
    {
        _subscribeView.hidden =YES;
        _outerView.hidden =NO;
    }
    else
    {
        _subscribeView.hidden =NO;
        _outerView.hidden =YES;
    }
    _subscribeBtnOutlet.layer.cornerRadius =23.0f;
    _subscribeBtnOutlet.layer.borderWidth =0.8;
    [_subscribeBtnOutlet.layer setMasksToBounds:YES];
    [_subscribeBtnOutlet setBackgroundImage:[Utility getGradientImageWithBounds:_subscribeBtnOutlet.bounds] forState:UIControlStateNormal];

    _loginBtnOutlet.layer.cornerRadius =23.0f;
    _loginBtnOutlet.layer.borderWidth =0.8;
    _loginBtnOutlet.layer.borderColor = [[UIColor whiteColor]CGColor];
    [_loginBtnOutlet.layer setMasksToBounds:YES];
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
    self.subscribeView.layer.mask = maskLayer;

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)loginAction:(id)sender
{
    [[ZEE5PlayerManager sharedInstance]tapOnLoginButton];
}
- (IBAction)subscribeAction:(id)sender
{
     [[ZEE5PlayerManager sharedInstance]tapOnSubscribeButton];
}

- (IBAction)closeBtnAction:(id)sender
{
    [[ZEE5PlayerManager sharedInstance]removeSubview];

}
@end

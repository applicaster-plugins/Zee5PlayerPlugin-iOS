//
//  devicePopView.m
//  ZEE5PlayerSDK
//
//  Created by shriraj.salunkhe on 09/10/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

#import "devicePopView.h"
#import <Zee5PlayerPlugin/ZEE5PlayerSDK.h>
#import "Zee5PlayerPlugin/Zee5PlayerPlugin-Swift.h"

@implementation devicePopView

- (void)awakeFromNib
{
    [super awakeFromNib];
     [self makeDragable];
    
    _smileBtnOutlet.layer.cornerRadius = _smileBtnOutlet.frame.size.height/2.0f;
    _smileBtnOutlet.layer.borderWidth = 0.5f;
    _smileBtnOutlet.layer.borderColor =[[UIColor clearColor]CGColor];
    [_smileBtnOutlet.layer setMasksToBounds:YES];
    

    _deleteOutlet.layer.cornerRadius =23.0f;
    _deleteOutlet.layer.borderWidth =0.8;
    [_deleteOutlet.layer setMasksToBounds:YES];
    [self.deleteOutlet setBackgroundImage:[Utility getGradientImageWithBounds:_deleteOutlet.bounds] forState:UIControlStateNormal];
     
     
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIBezierPath *maskPath = [UIBezierPath
                              bezierPathWithRoundedRect:self.OuterView.bounds
                              byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                              cornerRadii:CGSizeMake(25, 25)
                              ];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.OuterView.layer.mask = maskLayer;
    
}


- (IBAction)DeleteAction:(id)sender
{
    [[ZEE5PlayerManager sharedInstance]deleteAllDevice:@"DELETE"];
}

- (IBAction)cancelAction:(id)sender
{
    [[ZEE5PlayerManager sharedInstance]deleteAllDevice:@"Cancel"];
}

- (IBAction)closeBtnAction:(id)sender{
    [[ZEE5PlayerManager sharedInstance]removeSubview];
}
@end

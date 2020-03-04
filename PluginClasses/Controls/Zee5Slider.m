//
//  HybridPlayerControlsView.m
//  Zapp-App
//
//  Created by Miri on 27/12/2018.
//  Copyright © 2017 Applicaster LTD. All rights reserved.
//

@import ApplicasterSDK;

#import "Zee5Slider.h"

@interface Zee5Slider ()

@end

@implementation Zee5Slider

#pragma mark - UIView

- (void)awakeFromNib
{
    [super awakeFromNib];

}

#pragma mark - public

- (BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if(@available(iOS 12.0, *)){
        CGFloat width = self.frame.size.width;
        CGPoint tapPoint= [touch locationInView:self];
        float fPercent = tapPoint.x/width;
        int nNewValue = self.maximumValue * fPercent + 0.5;
        if(nNewValue!=self.value){
            self.value = nNewValue;
        }
    }
    return [super beginTrackingWithTouch:touch withEvent:event];
}

@end

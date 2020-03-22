//
//  Zee5Slider.h
//  ZEE5PlayerSDK
//
//  Created by admin on 12/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class ToolTipPopupView;
NS_ASSUME_NONNULL_BEGIN

@interface Zee5Slider :  UISlider
{
    ToolTipPopupView *toolTip;
    float stepValue;
}
@property(nonatomic) CGRect trackFrame;
@property(nonatomic) NSTimeInterval defaultValue;

@property(nonatomic) BOOL showTooltip;
@property(nonatomic) BOOL showTooltipContiously;
@property(nonatomic) BOOL fullScreen;

@property (nonatomic)  Boolean isDragging;
-(void)setMarkerAtPosition:(double)sliderValue;
-(void)removeAllAdTags;
- (void)animateToolTipFading:(BOOL)aFadeIn;
- (void)updateToolTipView;
@end

NS_ASSUME_NONNULL_END

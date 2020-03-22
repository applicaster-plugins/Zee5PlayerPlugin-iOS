//
//  Zee5Slider.m
//  ZEE5PlayerSDK
//
//  Created by admin on 12/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import "Zee5Slider.h"
#import "ZEE5PlayerManager.h"
#import <Zee5PlayerPlugin/ZEE5PlayerSDK.h>

#define ToolTipFont [UIFont boldSystemFontOfSize:12.0]
@class ToolTipPopupView;
//const CGSize kminValueImageSize = {15.0, 15.0};
//const CGSize kmaxValueImageSize = {20.0, 20.0};
//const CGFloat ksliderTrackHeight = 2;

@interface ToolTipPopupView : UIView
@property (nonatomic) float value;
@property (nonatomic, retain) UIFont *fontSize;
@property (nonatomic, retain) NSString *toolTipValue;
@end

@implementation ToolTipPopupView

@synthesize value=_value;
@synthesize fontSize =_fontSize;
@synthesize toolTipValue = _toolTipValue;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.fontSize = [UIFont boldSystemFontOfSize:18];
    }
    return self;
}

- (void)dealloc {
    self.toolTipValue = nil;
    self.fontSize = nil;
}

- (void)drawRect:(CGRect)rect {
    
    // Set the fill color and Create the path for the rectangle
    [[UIColor colorWithRed:233.0/255.0 green:51.0/255.0 blue:143.0/255.0 alpha:1.0] setFill];

//    [[UIColor colorWithRed:0.0f/256.0f green:0.0f/256.0f blue:0.0f/256.0f alpha:0.6] setFill];
    CGRect roundedRect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height * 0.8);
    UIBezierPath *roundedRectPath = [UIBezierPath bezierPathWithRoundedRect:roundedRect cornerRadius:5.0];
    
    // Create the arrow path
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    CGFloat midX = CGRectGetMidX(self.bounds);
    CGPoint midPoint = CGPointMake(midX, CGRectGetMaxY(self.bounds));
    [arrowPath moveToPoint:midPoint];
    [arrowPath addLineToPoint:CGPointMake((midX - 10.0), CGRectGetMaxY(roundedRect))];
    [arrowPath addLineToPoint:CGPointMake((midX + 10.0), CGRectGetMaxY(roundedRect))];
    [arrowPath closePath];
    
    // Attach the arrow path to the rectangle
    [roundedRectPath appendPath:arrowPath];
    
    CAShapeLayer *strokeLayer = [CAShapeLayer layer];
    strokeLayer.path = roundedRectPath.CGPath;
    strokeLayer.fillColor = [UIColor clearColor].CGColor;
    strokeLayer.strokeColor = [UIColor whiteColor].CGColor;
    strokeLayer.lineWidth = 0.5; // the stroke splits the width evenly inside and outside,
//    [self.layer addSublayer:strokeLayer];
    
    [roundedRectPath fill];
    
    // Draw the text if there is a value
    if (self.toolTipValue) {
        [[UIColor darkGrayColor] set];
        CGSize s = [_toolTipValue sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor darkGrayColor], NSForegroundColorAttributeName,ToolTipFont, NSFontAttributeName, nil]];
        CGFloat yOffset = (roundedRect.size.height - s.height) / 2;
        CGRect textRect = CGRectMake(roundedRect.origin.x, yOffset, roundedRect.size.width, s.height);
        NSMutableParagraphStyle *theStyle = [NSMutableParagraphStyle new];
        [theStyle setLineBreakMode:NSLineBreakByWordWrapping];
        [theStyle setAlignment:NSTextAlignmentCenter];
        [_toolTipValue drawInRect:textRect withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:ToolTipFont, NSFontAttributeName,theStyle, NSParagraphStyleAttributeName,[UIColor whiteColor],NSForegroundColorAttributeName, nil]];
    }
}

- (void)setValue:(float)aValue {
    _value = aValue;
    self.toolTipValue = [NSString stringWithFormat:@"%.1f", _value];
    [self setNeedsDisplay];
}

@end

@implementation Zee5Slider
{
    UIView* tickview;
}
@synthesize showTooltip;

-(void)setMarkerAtPosition:(double)sliderValue
{
//    if (self.subviews.count > 0) {
        CGRect trackRect = [self trackRectForBounds:self.frame];
        CGFloat xpos = sliderValue * trackRect.size.width;
        CGRect _thumbRect = [self thumbRectForBounds:self.bounds
                                       trackRect:[self trackRectForBounds:self.bounds]
                                           value:self.value];

        UIView *marker = [[UIView alloc] initWithFrame:CGRectMake(xpos,  (_thumbRect.size.height)/2 - 1 , 3.5, 1.5)];
    
    

//        marker.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:234.0/255.0 blue:0.0/255.0 alpha:1.0];
        marker.backgroundColor = [UIColor yellowColor];
        marker.tag = 10;
    [self insertSubview:marker atIndex:self.subviews.count - 2];
//    [self insertSubview:marker belowSubview:self];
//        [self insertSubview:marker aboveSubview:self];
//    }
}
-(void)removeAllAdTags
{
    if (self.subviews.count > 0) {
        for (UIView *vws in self.subviews) {
            if (vws.tag == 10) {
                [vws removeFromSuperview];
            }
        }
    }
}

-(void)setShowTooltip:(BOOL)show{
    if (show) {
        [self initToolTip];
    }else{
        [self removeToolTip];
    }
    self->showTooltip = show;
}



- (CGRect)knobRect {
    CGRect knobRect = [self thumbRectForBounds:self.bounds
                                     trackRect:[self trackRectForBounds:self.bounds]
                                         value:self.value];
    return knobRect;
}
#pragma mark - UIControl touch event tracking

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (showTooltip) {
        // Find the touch point on mousedown
        CGPoint touchPoint = [touch locationInView:self];
        // Check if the touch is within the knob's boundary to show the tooltip-view

        if(CGRectContainsPoint(self.knobRect, touchPoint)) {
            if(_showTooltipContiously)
            {
                if (_fullScreen)
                {
                    [self updateToolTipView];
                    [self animateToolTipFading:YES];

                }
            }
            else
            {
                [self updateToolTipView];
                [self animateToolTipFading:YES];

            }
        }
      
    }
    return [super beginTrackingWithTouch:touch withEvent:event];
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [NSObject cancelPreviousPerformRequestsWithTarget:[ZEE5PlayerManager sharedInstance]];

    if (self.showTooltip)
    {
        if(_showTooltipContiously)
        {
            if (_fullScreen)
            {
               
                [self updateToolTipView];
                [self animateToolTipFading:YES];
                
            }
        }
        else
        {
            
            [self updateToolTipView];
            [self animateToolTipFading:YES];
            
        }
        
    }
    return [super continueTrackingWithTouch:touch withEvent:event];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    [super cancelTrackingWithEvent:event];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (self.showTooltip && !self.showTooltipContiously)
    {
        // Fade out the tooltip view on mouse release event
        [self animateToolTipFading:NO];
        [super endTrackingWithTouch:touch withEvent:event];
    }
    else if(self.showTooltipContiously)
    {
        [self updateToolTipView];

    }
}

- (void)initToolTip {
    if (toolTip == nil) {
        toolTip = [[ToolTipPopupView alloc] initWithFrame:CGRectZero];
        toolTip.backgroundColor = [UIColor clearColor];
        toolTip.alpha = 0.0;
        [toolTip drawRect:CGRectZero];
    }
    [self addSubview:toolTip];
}

- (void)removeToolTip {
    [toolTip removeFromSuperview];
}
- (void)animateToolTipFading:(BOOL)aFadeIn {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    if (aFadeIn) {
        toolTip.alpha = 1.0;
        
    } else {
        [[ZEE5PlayerManager sharedInstance] perfomAction];

        toolTip.alpha = 0.0;
    }
    [UIView commitAnimations];
}

- (void)updateToolTipView {
    CGRect _thumbRect = [self thumbRectForBounds:self.bounds
                                       trackRect:[self trackRectForBounds:self.bounds]
                                           value:self.value];
    
    CGFloat height = 40;
    NSString *toolTipValue = @"";
    if(self.defaultValue > 0)
    {
        toolTipValue = [Utility convertEpochToDetailTime:self.defaultValue + self.value];
    }
    else
    {
        toolTipValue = [self getDuration:self.value];
    }
    CGFloat width = [self widthOfString:toolTipValue withFont:ToolTipFont] + 14;
    
    CGRect popupRect = CGRectMake(_thumbRect.origin.x - width/2 + 7, _thumbRect.origin.y - height, width, height);
    toolTip.frame = popupRect;
    toolTip.value = self.value;
    toolTip.clipsToBounds = YES;
    toolTip.toolTipValue = toolTipValue;
}
-(NSString *)getDuration:(NSInteger )totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = (int)(totalSeconds / 3600);
    if(hours == 0)
    {
        return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }
    else
    {
        return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
        
    }
    
}

- (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

@end





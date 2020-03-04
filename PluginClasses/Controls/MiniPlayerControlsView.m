//
//  MiniPlayerControlsView.m
//  Zapp-App
//
//  Created by Miri on 27/12/2018.
//  Copyright © 2017 Applicaster LTD. All rights reserved.
//

@import ZappPlugins;
@import ApplicasterSDK;

#import "MiniPlayerControlsView.h"

@implementation MiniPlayerControlsView

@synthesize playButton;
@synthesize pauseButton;
@synthesize stopButton;
@synthesize seekSlider;
@synthesize nativeShareButton;

#pragma mark - UIView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setStylesForControls];
}

#pragma mark - player controls

- (void)show:(BOOL)animated
{
    self.playerControlsContainer.alpha = 1.0;
}

- (void)hide:(BOOL)animated
{
    [self show:animated];
}

-(void)updateControlsForLiveState:(BOOL)isLive
{
    [super updateControlsForLiveState:isLive];
    self.seekSlider.hidden = isLive;
}

#pragma mark - private

- (void)customizeSeekSliderView:(UISlider *)slider
{
    [slider setMinimumTrackTintColor: [UIColor colorWithRed:255.0/256.0 green:255.0/256.0 blue:255.0/256.0 alpha:1]];
    [slider setMaximumTrackTintColor: [UIColor colorWithRed:62/256.0 green:62/256.0 blue:62/256.0 alpha:1]];
}

- (void)setStylesForControls
{
    [self.playButton setImage:[UIImage imageNamed:@"sticky_play_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];

    [self.playButton setImage:[UIImage imageNamed:@"sticky_play_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateHighlighted];

    [self.pauseButton setImage:[UIImage imageNamed:@"sticky_pause_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];

    [self.pauseButton setImage:[UIImage imageNamed:@"sticky_pause_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateHighlighted];

    [self.stopButton setImage:[UIImage imageNamed:@"sticky_close_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];

    [self.stopButton setImage:[UIImage imageNamed:@"sticky_close_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateHighlighted];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];

    // Make self unhittable
    if (hitView == self)
    {
        hitView = nil;
    }

    return hitView;
}

@end

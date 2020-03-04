//
//  FullScreenPlayerControlsView.m
//  Zapp-App
//
//  Created by Miri on 27/12/2018.
//  Copyright © 2017 Applicaster LTD. All rights reserved.
//

@import ZappPlugins;
@import ApplicasterSDK;

#import "FullScreenPlayerControlsView.h"
#import "Zee5PlayerViewController.h"

@interface FullScreenPlayerControlsView ()

@end

@implementation FullScreenPlayerControlsView

@synthesize shrinkButton;

#pragma mark - UIView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.lineImageView.backgroundColor = [UIColor whiteColor];
}

- (void)setData:(NSString *)title andPluginStyles:(NSDictionary *)pluginStyles {
    self.playableName.text = title;


}

#pragma mark - private

- (void)setStylesForControls
{
    [super setStylesForControls];

    [self.shrinkButton setImage:[UIImage imageNamed:@"exit_fullscreen_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];

    [self.shrinkButton setImage:[UIImage imageNamed:@"exit_fullscreen_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateHighlighted];

    [self.playButton setImage:[UIImage imageNamed:@"nagan_play_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];

    [self.playButton setImage:[UIImage imageNamed:@"nagan_play_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateHighlighted];

    [self.pauseButton setImage:[UIImage imageNamed:@"nagan_pause_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];

    [self.pauseButton setImage:[UIImage imageNamed:@"nagan_pause_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateHighlighted];
}

- (NSTimeInterval)initialPlayerControlsHideDelay
{
    return 5.0;
}

@end

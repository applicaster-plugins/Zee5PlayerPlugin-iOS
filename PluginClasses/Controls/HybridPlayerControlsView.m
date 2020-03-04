//
//  HybridPlayerControlsView.m
//  Zapp-App
//
//  Created by Miri on 27/12/2018.
//  Copyright © 2017 Applicaster LTD. All rights reserved.
//

@import ZappPlugins;
@import ApplicasterSDK;

#import "HybridPlayerControlsView.h"

@interface HybridPlayerControlsView ()
@property (nonatomic, assign) BOOL animatingControlsFade;
@property (nonatomic, assign) BOOL playerControlsContainerHidden;

@end

@implementation HybridPlayerControlsView

@synthesize playButton;
@synthesize pauseButton;
@synthesize seekSlider;
@synthesize expandButton;
@synthesize miniButton;
@synthesize nativeShareButton;
@synthesize sleepModeButton;
@synthesize skipBackwardButton, skipForwardButton;

#pragma mark - UIView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setStylesForControls];
    self.playerControlsContainerHidden = YES;
    self.expandButton.hidden = NO;
}

#pragma mark - public

#pragma mark - private

- (void)customizeSeekSliderView:(UISlider *)slider
{
    UIImage *thumbImage = [UIImage imageNamed:@"navBarCircle.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    if (thumbImage) {
        [slider setThumbImage:thumbImage forState:UIControlStateNormal];
        [slider setThumbImage:thumbImage forState:UIControlStateHighlighted];
    }
    [slider setMinimumTrackTintColor: [UIColor colorWithRed:255.0/256.0 green:255.0/256.0 blue:255.0/256.0 alpha:1]];
    [slider setMaximumTrackTintColor: [UIColor colorWithRed:62/256.0 green:62/256.0 blue:62/256.0 alpha:1]];

}

- (void)setStylesForControls
{
    [self.topGradientView setStartColor:[UIColor colorWithRed:1.0/256.0 green:2.0/256.0 blue:2.0/256.0 alpha:0.3]];
    [self.topGradientView setEndColor:[UIColor colorWithRed:1.0/256.0 green:2.0/256.0 blue:2.0/256.0 alpha:0.0]];
    [self.topGradientView setOrientation:APGradientViewVertical];
    self.topGradientView.shouldClickThrough = YES;

    [self.bottomGradientView setStartColor:[UIColor colorWithRed:1.0/256.0 green:2.0/256.0 blue:2.0/256.0 alpha:0.0]];
    [self.bottomGradientView setEndColor:[UIColor colorWithRed:1.0/256.0 green:2.0/256.0 blue:2.0/256.0 alpha:0.3]];
    [self.bottomGradientView setOrientation:APGradientViewVertical];
    self.bottomGradientView.shouldClickThrough = YES;

    [self.playButton setImage:[UIImage imageNamed:@"nagan_play_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];

    [self.playButton setImage:[UIImage imageNamed:@"nagan_play_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateHighlighted];

    [self.pauseButton setImage:[UIImage imageNamed:@"nagan_pause_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];

    [self.pauseButton setImage:[UIImage imageNamed:@"nagan_pause_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateHighlighted];

    [self.expandButton setImage:[UIImage imageNamed:@"fullscreen_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];

    [self.expandButton setImage:[UIImage imageNamed:@"fullscreen_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateHighlighted];

    [self.miniButton setImage:[UIImage imageNamed:@"minimize_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];

    [self.miniButton setImage:[UIImage imageNamed:@"minimize_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateHighlighted];

    [self.nativeShareButton setImage:[UIImage imageNamed:@"player_nativeShare_btn.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];

    [self.nativeShareButton setImage:[UIImage imageNamed:@"player_nativeShare_btn.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateHighlighted];

    [self.sleepModeButton setImage:[UIImage imageNamed:@"sleep_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];

    [self.sleepModeButton setImage:[UIImage imageNamed:@"sleep_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateHighlighted];

    [self.skipBackwardButton setImage:[UIImage imageNamed:@"backwardBtn" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];

    [self.skipBackwardButton setImage:[UIImage imageNamed:@"backwardBtn" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateHighlighted];

    [self.skipForwardButton setImage:[UIImage imageNamed:@"farwardBtn" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];

    [self.skipForwardButton setImage:[UIImage imageNamed:@"farwardBtn" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateHighlighted];

    if ([self respondsToSelector:@selector(chromecastButton)] == YES) {
        UIView *castButton = [[[ZAAppConnector sharedInstance] chromecastDelegate]
                              addButton:self.chromecastButton
                              topOffset:0
                              width:self.chromecastButton.bounds.size.width
                              buttonKey:@"kan_play_chromecast"
                              color:nil
                              useConstrains:YES];

        NSLog(@"castButton %@",castButton);
        if ([[[ZAAppConnector sharedInstance] chromecastDelegate] isReachableViaWiFi] == NO || castButton == nil || castButton.hidden == YES) {
            self.chromecastButton.hidden = YES;
        }
        else {
            self.chromecastButton.hidden = NO;
        }
    }
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

#pragma mark - player controls

- (void)show:(BOOL)animated
{
    if (self.animatingControlsFade == NO && animated) {
        self.animatingControlsFade = YES;
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.playerControlsContainer.alpha = 1.0;
                             self.playerControlsAlphaContainer.alpha = 1.0;
                         } completion:^(BOOL finished) {
                             self.playerControlsContainerHidden = NO;
                             self.animatingControlsFade = NO;
                         }];
    } else {
        self.playerControlsContainer.alpha = 1.0;
        self.playerControlsContainerHidden = NO;
        self.playerControlsAlphaContainer.alpha = 1.0;
    }
}

- (void)hide:(BOOL)animated
{
    if (self.animatingControlsFade == NO && animated) {
        self.animatingControlsFade = YES;
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.playerControlsContainer.alpha = 0.0;
                             self.playerControlsAlphaContainer.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             self.playerControlsContainerHidden = YES;
                             self.animatingControlsFade = NO;
                         }];
    } else {
        self.playerControlsContainer.alpha = 0.0;
        self.playerControlsContainerHidden = YES;
        self.playerControlsAlphaContainer.alpha = 0.0;
    }
}

- (BOOL)isVisible
{
    return !self.playerControlsContainerHidden;
}

- (void)setDuration:(NSTimeInterval)duration
{
    self.totalTimeLabel.text = [NSString timeCodeWithSeconds:duration];

}

- (void)setCurrentTime:(NSTimeInterval)currentTime
{
    self.currentTimeLabel.text = [NSString timeCodeWithSeconds:currentTime];
}

-(void)updateControlsForLiveState:(BOOL)isLive
{
    [super updateControlsForLiveState:isLive];
    if (self.isLive == YES) {
        self.currentTimeLabel.hidden = YES;
        self.totalTimeLabel.hidden = YES;
        self.seekSlider.hidden = YES;
        self.separatorView.hidden = YES;
    }
}

- (void)videoContentDidStartPlayingWithItem:(NSDictionary *)playingItemInfo {

}

- (NSTimeInterval)initialPlayerControlsHideDelay
{
    return 5.0;
}

-(void)updateSleepModeTimer:(NSString *)value {
    self.sleepModeTimerLabel.text = value;
}

- (IBAction)miniScreenTapped:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"APApplicasterPlayerMiniNotification"
                                                        object:nil];
}

- (IBAction)sleepModeTapped:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"APApplicasterPlayerStartSleepModeNotification"
                                                        object:nil];
}


- (IBAction)backWardButtonTapped:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayerBackwardNotification"
                                                        object:nil];
}

- (IBAction)forWardButtonTapped:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayerForwardNotification"
                                                        object:nil];
}

- (IBAction)shareButtonTapped:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayerShareNotification"
                                                        object:nil];
}

@end

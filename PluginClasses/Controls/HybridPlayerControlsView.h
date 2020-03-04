//
//  HybridPlayerControlsView.h
//  Zapp-App
//
//  Created by Miri on 27/12/2018.
//  Copyright © 2017 Applicaster LTD. All rights reserved.
//

@import ApplicasterSDK;
@import MediaPlayer;
#import <ApplicasterSDK/APPlayerControls.h>
#import <ApplicasterSDK/APPlayerControlsView.h>
#import <ApplicasterSDK/APUnhittableView.h>
#import <ApplicasterSDK/APGradientView.h>
#import "Zee5Slider.h"

@interface HybridPlayerControlsView : APPlayerControlsView <APPlayerControls>
@property (weak, nonatomic) IBOutlet APUnhittableView *playerControlsContainer;
@property (weak, nonatomic) IBOutlet APGradientView *topGradientView;
@property (weak, nonatomic) IBOutlet APGradientView *bottomGradientView;
@property (nonatomic,readonly, weak) IBOutlet UIButton *playButton;
@property (nonatomic,readonly, weak) IBOutlet UIButton *pauseButton;
@property (nonatomic, weak) IBOutlet Zee5Slider *seekSlider;
@property (nonatomic,readonly, weak) IBOutlet UIButton *expandButton;
@property (nonatomic,readonly, weak) IBOutlet UIButton *miniButton;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *chromecastButton;
@property (nonatomic,readonly, weak) IBOutlet UIButton *nativeShareButton;
@property (nonatomic,readonly, weak) IBOutlet UIButton *sleepModeButton;
@property (weak, nonatomic) IBOutlet UILabel *sleepModeTimerLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *totalTimeLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UIView *playerControlsAlphaContainer;

@property (nonatomic, weak) IBOutlet UIView *skipControlsContainerView;
@property (nonatomic, weak) IBOutlet UIButton *skipBackwardButton;
@property (nonatomic, weak) IBOutlet UILabel *backwardTimeLabel;
@property (nonatomic, weak) IBOutlet UIButton *skipForwardButton;
@property (nonatomic, weak) IBOutlet UILabel *forwardTimeLabel;

@property (nonatomic, assign) BOOL isLive;

- (void)setStylesForControls;
- (void)updateSleepModeTimer:(NSString *)value;

@end

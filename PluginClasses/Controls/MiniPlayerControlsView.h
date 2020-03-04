//
//  Zee5PlayerControlsView.h
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

@protocol miniPlayerControlsDelegate <NSObject>

- (void)miniPlayerClose;

@end

@interface MiniPlayerControlsView : APPlayerControlsView <APPlayerControls>
@property (weak, nonatomic) IBOutlet APUnhittableView *playerControlsContainer;
@property (nonatomic,readonly, weak) IBOutlet UIButton *playButton;
@property (nonatomic,readonly, weak) IBOutlet UIButton *pauseButton;
@property (nonatomic, readonly, weak) IBOutlet UIButton *stopButton;
@property (nonatomic,readonly, weak) IBOutlet APSlider *seekSlider;

@property (nonatomic, weak) id<miniPlayerControlsDelegate> delegate;

#pragma mark - Chromecast variables
@property (nonatomic, strong) UIViewController *chromecastMiniPlayerViewController;
@end

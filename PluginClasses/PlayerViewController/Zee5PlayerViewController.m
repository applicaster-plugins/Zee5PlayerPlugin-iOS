//
//  Zee5PlayerViewController.m
//  Zee5PlayerViewController
//
//  Created by Miri on 31/12/2018.
//

@import ZappPlugins;
#import "Zee5PlayerViewController.h"
#import "MiniPlayerControlsView.h"
#import "FullScreenPlayerControlsView.h"

static NSString *const kPlayerChromecastSessionDidEnd = @"ChromecastSessionDidEnd";
static NSString *const kPlayerChromecastSessionWillStart = @"ChromecastSessionWillStart";

static NSString *const kPlayerBackwardNotification = @"PlayerBackwardNotification";
static NSString *const kPlayerForwardNotification = @"PlayerForwardNotification";

@interface Zee5PlayerViewController ()
@property (nonatomic, strong) UIViewController *miniChromecastViewController;

//tracks if the player is in the proccess of switching between different views
@property (nonatomic,assign) BOOL isSwitchingBetweenDisplays;

@end

@implementation Zee5PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //Observe chromecast states
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(chromecastSessionWillStart:)
                                                 name:kPlayerChromecastSessionWillStart
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(chromecastSessionDidEnd:)
                                                 name:kPlayerChromecastSessionDidEnd
                                               object:nil];

    // Observe skip interval controls
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backwardNotification:)
                                                 name:kPlayerBackwardNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(forwardNotification:)
                                                 name:kPlayerForwardNotification
                                               object:nil];

    HybridPlayerControlsView *controls = (HybridPlayerControlsView *)self.controls;
    if ([controls isKindOfClass:[HybridPlayerControlsView class]] && controls.separatorView.isHidden == NO) {
        controls.separatorView.backgroundColor = UIColor.clearColor;
    }
}
- (void)dealloc {
    //Stop observing notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeMiniChromecastView];
}

- (void)setControls:(UIView<APPlayerControls> *)controls {
    [super setControls:controls];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"APApplicasterPlayerMiniNotification" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerMiniNotification:)
                                                 name:@"APApplicasterPlayerMiniNotification"
                                               object:nil];

    //Observe application state
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

}

- (void)changePlayerDisplayMode:(PlayerViewControllerDisplayMode)targetDisplayMode {
    self.isSwitchingBetweenDisplays = NO;
    if (targetDisplayMode == self.currentDisplayMode) {
        APLoggerDebug(@"Trying to switch to same display mode as currently presented");
        return;
    }
    self.currentState = self.playerController.player.playbackStateMachine.currentState;

    switch (targetDisplayMode) {
        case PlayerViewControllerDisplayModeInline:
            self.isSwitchingBetweenDisplays = YES;
            self.currentDisplayMode = targetDisplayMode;
            self.playerController.player.containerControlsView = nil;
            if (self.previousParentViewController != nil) {
                if (self.lastDisplayMode == PlayerViewControllerDisplayModeFullScreen) {
                    [self removeViewFromParentViewController];
                    [self playIfNeeded];
                    [self dismissSelfAnimated:NO completion:^{
                        [self hybridPlayerConfiguration];
                        self.isSwitchingBetweenDisplays = NO;
                    }];
                }
                else if (self.lastDisplayMode == PlayerViewControllerDisplayModeMini) {
                    [self removeViewFromParentViewController];
                    [self playIfNeeded];
                    [self removeMiniChromecastView];
                    [[[[ZAAppConnector sharedInstance] navigationDelegate] topmostModal] presentViewController:self.previousParentViewController animated:YES completion:^{
                        [self hybridPlayerConfiguration];
                        self.isSwitchingBetweenDisplays = NO;
                    }];
                }
            } else {
                [self setControls:[self hyBridPlayerControls]];
                self.isSwitchingBetweenDisplays = NO;
                return;
            }
            self.lastDisplayMode = PlayerViewControllerDisplayModeInline;
            break;
        case PlayerViewControllerDisplayModeFullScreen:
            self.isSwitchingBetweenDisplays = YES;
            if (self.currentPlayerDisplayMode == APPlayerViewControllerDisplayModeInline && self.parentViewController!= nil) {
                self.currentDisplayMode = targetDisplayMode;
                self.previousParentViewController = self.parentViewController;
                self.previousContainerView = self.view.superview;
                [self removeViewFromParentViewController];
                [self playIfNeeded];
                FullScreenPlayerControlsView *fullScreenPlayer = (FullScreenPlayerControlsView *)[self fullScreenPlayerControls];
                fullScreenPlayer.playableName.text = [self.playerController.currentItem playableName];
                [self setControls:fullScreenPlayer];
                [[[[ZAAppConnector sharedInstance] navigationDelegate] topmostModal] presentViewController:self animated:YES completion:^{
                    [self fullScreenPlayerConfiguration];
                    self.isSwitchingBetweenDisplays = NO;
                }];
                self.lastDisplayMode = PlayerViewControllerDisplayModeFullScreen;
            }
            break;
        case PlayerViewControllerDisplayModeMini:
            self.isSwitchingBetweenDisplays = YES;
            self.currentDisplayMode = targetDisplayMode;
            self.previousParentViewController = self.parentViewController;
            self.previousContainerView = self.view.superview;
            if (self.previousParentViewController != nil) {
                [self removeViewFromParentViewController];
                UIView *miniPlayerContainerView = [self.delegate miniPlayerContainerView];
                if (miniPlayerContainerView) {
                    self.playerController.player.containerControlsView = miniPlayerContainerView;
                    [[[ZAAppConnector sharedInstance] stickyViewDelegate] stickyViewDisplayWithView: miniPlayerContainerView];
                    [self miniPlayerConfiguration];
                    [self playIfNeeded];
                    [self.previousParentViewController dismissModalViewControllerFromParentAnimated:YES completionHandler:^{
                        self.isSwitchingBetweenDisplays = NO;
                    }];

                    //Add chromecast view
                    if([[ZAAppConnector sharedInstance] chromecastDelegate].isSynced) {
                        //Add chromecast view
                        UIViewController *chromecastMiniPlayerViewController = [[ZAAppConnector sharedInstance] chromecastDelegate].getMiniPlayerViewController;
                        [self attcheMiniChromecastView:chromecastMiniPlayerViewController
                                            inView:miniPlayerContainerView];
                    } else {
                        NSLog(@"test");
                    }
                }


            } else {
                APLoggerError(@"No previous parent view controller - can't move to mini");
                return;
            }
            self.lastDisplayMode = PlayerViewControllerDisplayModeMini;
            break;
        default:
            break;
    }
}

- (void)changeDisplayMode:(APPlayerViewControllerDisplayMode)targetDisplayMode
{
    switch (targetDisplayMode) {
        case APPlayerViewControllerDisplayModeUnknown:
            [self changePlayerDisplayMode:PlayerViewControllerDisplayModeUnknown];

            break;

        case APPlayerViewControllerDisplayModeFullScreen:
            [self changePlayerDisplayMode:PlayerViewControllerDisplayModeFullScreen];

            break;

        case APPlayerViewControllerDisplayModeInline:
            [self changePlayerDisplayMode:PlayerViewControllerDisplayModeInline];

            break;

        default:
            break;
    }
}

#pragma mark - Controls View

- (UIView<APPlayerControls> *)hyBridPlayerControls
{
    HybridPlayerControlsView *controls = [[NSBundle bundleForClass:self.class] loadNibNamed:@"HybridPlayerControlsView" owner:self options:nil].firstObject;
    controls.isLive = [self isLive];
    if(self.playerController.currentItem.isAudioOnly == YES) {
        controls.expandButton.hidden = YES;
        controls.totalTimeLabelTrailingConstraint.priority = 1000;
    }
    if(controls.isLive == YES) {
        controls.skipControlsContainerView.hidden = YES;
    }
    else {
        controls.skipControlsContainerView.hidden = NO;
        controls.backwardTimeLabel.text = self.skipInterval;
        controls.forwardTimeLabel.text = self.skipInterval;
    }
    return controls;
}

- (UIView<APPlayerControls> *)fullScreenPlayerControls
{
    FullScreenPlayerControlsView *controls = [[NSBundle bundleForClass:self.class] loadNibNamed:@"FullScreenPlayerControlsView" owner:self options:nil].firstObject;
    controls.isLive = [self isLive];
    if(controls.isLive == YES) {
        controls.skipControlsContainerView.hidden = YES;
    }
    else {
        controls.skipControlsContainerView.hidden = NO;
        controls.backwardTimeLabel.text = self.skipInterval;
        controls.forwardTimeLabel.text = self.skipInterval;
    }
    return controls;
}

- (UIView<APPlayerControls> *)miniPlayerControls
{
    return [[NSBundle bundleForClass:self.class] loadNibNamed:@"MiniPlayerControlsView" owner:self options:nil].firstObject;
}

#pragma mark - Sleep Mode

- (void)sleepModeConfiguration:(NSInteger)value {
    HybridPlayerControlsView *controls = (HybridPlayerControlsView *)self.controls;

    if ([controls respondsToSelector:@selector(sleepModeButton)]) {
        if (value == 0) {
            [controls.sleepModeButton setImage:[UIImage imageNamed:@"sleep_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];

            [controls.sleepModeButton setImage:[UIImage imageNamed:@"sleep_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateHighlighted];
            controls.sleepModeTimerLabel.text = @"";

        }
        else {
            [controls.sleepModeButton setImage:[UIImage imageNamed:@"sleep_full_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];

            [controls.sleepModeButton setImage:[UIImage imageNamed:@"sleep_full_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateHighlighted];
        }
    }
}

- (void)sleepModeCountDown:(NSNumber *)value {
    int intValue = [value intValue];

    HybridPlayerControlsView *controls = (HybridPlayerControlsView *)self.controls;

    int minutes = intValue / 60;
    int seconds = intValue % 60;
    if ([controls respondsToSelector:@selector(sleepModeTimerLabel)])
    {
        if ([controls respondsToSelector:@selector(sleepModeTimerLabel)]) {
            controls.sleepModeTimerLabel.text = [NSString stringWithFormat:@"%02d:%02d",minutes, seconds];

        }
        if ([controls respondsToSelector:@selector(sleepModeButton)]) {
            [controls.sleepModeButton setImage:[UIImage imageNamed:@"sleep_full_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];

            [controls.sleepModeButton setImage:[UIImage imageNamed:@"sleep_full_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateHighlighted];
        }

    }
}

#pragma mark - Controls Notifications

- (void)playerMiniNotification:(NSNotification *)notification {
    [self changePlayerDisplayMode:PlayerViewControllerDisplayModeMini];
}

- (void)backwardNotification:(NSNotification *)notification {
    [self performPlaybackSeekByCurrentTime:-[self.skipInterval doubleValue]];
}

- (void)forwardNotification:(NSNotification *)notification {
    [self performPlaybackSeekByCurrentTime:[self.skipInterval doubleValue]];
}

#pragma mark - Notifications

- (void)applicationWillEnterForeground:(NSNotification*)notification {
    [self.playerController.controls show:YES];
}

#pragma mark - private

- (void)hybridPlayerConfiguration {
    if (self.previousParentViewController) {
        [self.previousParentViewController addChildViewController:self
                                                           toView:self.previousContainerView];
        self.previousParentViewController = nil;
        self.previousContainerView = nil;
    }
    [self setControls:[self hyBridPlayerControls]];
    [self.controls show:YES];
    self.playerController.overlayHidden = YES;
    self.controls.shrinkButton.hidden = NO;
}

- (void)miniPlayerConfiguration {
    MiniPlayerControlsView *miniPlayer = (MiniPlayerControlsView *)[self miniPlayerControls];
    [self setControls:miniPlayer];
    [self.controls show:YES];
}

- (void)fullScreenPlayerConfiguration {
    self.playerController.player.containerControlsView = nil;
    self.playerController.overlayHidden = NO;
    self.controls.stopButton.hidden = YES;
    self.controls.shrinkButton.hidden = NO;
    self.playerController.player.muted = NO;
    if (self.disablePictureInPicture) {
        [self.controls.pictureInPictureButton removeFromSuperview];
    }
}

- (void)play {
    if ((self.currentState == nil) || [self.currentState isEqualToString: kPlaybackStatePlaying]) {
        [super play];
    }
}

- (void)pause {
    if (!self.isSwitchingBetweenDisplays) {
        [super pause];
    }

    // close Zee5 player if youtube player opened
    id<ZPPlayerProtocol> instance = [[ZPPlayerManager sharedInstance] lastActiveInstance];
    if ([NSStringFromClass([instance class]) isEqualToString:@"APPlugablePlayerYouTube"]) {
        [super stop];
    }

}

- (void)playIfNeeded {
    if ([[ZAAppConnector sharedInstance] chromecastDelegate].isSynced) {
        [self pause];
    } else if ([self.currentState isEqualToString: kPlaybackStatePlaying]) {
        [self play];
    } else {
        //Keep the same state
    }
}

- (BOOL)isLive {
    BOOL retVal = NO;

    if (self.playerController.currentItem.isLive == YES) {
        retVal = YES;
    }
    else if (self.playerController.currentItem.extensionsDictionary[@"live"]) {
        retVal = YES;
    }
    return retVal;
}

- (void)dismissSelfAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [self.presentingViewController dismissViewControllerAnimated:flag completion:^(void) {
        if (completion) {
            completion();
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kAPPlayerViewControllerDismissed object:self userInfo:nil];
    }];
}

-(void)performPlaybackSeekByCurrentTime:(NSTimeInterval)delta {
    NSTimeInterval currentPlayableTime = (self.playerController.player.currentPlaybackTime ? self.playerController.player.currentPlaybackTime : 0);
    self.playerController.player.currentPlaybackTime = currentPlayableTime + delta;
}

- (void)expandButtonTapped {
    [[UIDevice currentDevice] setValue:
     [NSNumber numberWithInteger: UIDeviceOrientationLandscapeRight]
                                forKey:@"orientation"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kControlsExpandButtonTapped" object:self userInfo:nil];

}

- (void)shrinkButtonTapped {
    [[UIDevice currentDevice] setValue:
     [NSNumber numberWithInteger: UIInterfaceOrientationPortrait]
                                forKey:@"orientation"];
}

#pragma mark - Chromecast Mini Logic
- (void)attcheMiniChromecastView:(UIViewController *)castPlayerViewContrller inView:(UIView *)miniPlayerView {
    if(!self.miniChromecastViewController) {
        UIViewController *parentViewController = miniPlayerView.parentViewController;
        [parentViewController addChildViewController:castPlayerViewContrller toView:miniPlayerView];
        [castPlayerViewContrller.view matchParent];
        [miniPlayerView bringSubviewToFront:castPlayerViewContrller.view];
        _miniChromecastViewController = castPlayerViewContrller;
    }
}

- (void)removeMiniChromecastView {
    if(self.miniChromecastViewController) {
        [self.miniChromecastViewController removeViewFromParentViewController];
        _miniChromecastViewController = nil;
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
   // Override this function of super - Don't remove it!
}

//This method called once the CastDelegate will be triggered
- (void)chromecastSessionDidEnd:(NSNotification*)notification {
    //play from the same location chromecast was ended
    [self removeMiniChromecastView];
    [self playIfNeeded];
}

//If we are on full screen go to Hybrid.
- (void)chromecastSessionWillStart:(NSNotification*)notification {
    [self shrinkButtonTapped];
    [self pause];
}

@end

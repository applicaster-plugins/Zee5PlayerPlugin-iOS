//
//  ArtiPlayer.h
//  ArtiMediaPlayer
//
//  Created by Avi Levin on 05/07/2018.
//
@import ApplicasterSDK;

#import <UIKit/UIKit.h>
#import "HybridPlayerControlsView.h"
#import "FullScreenPlayerControlsView.h"
#import "MiniPlayerControlsView.h"

@protocol pluggablePlayerDelegate <NSObject>

- (UIView *)miniPlayerContainerView;

@end

typedef NS_ENUM(NSInteger, PlayerViewControllerDisplayMode) {
    PlayerViewControllerDisplayModeUnknown = 0,
    PlayerViewControllerDisplayModeFullScreen,
    PlayerViewControllerDisplayModeInline,
    PlayerViewControllerDisplayModeMini,
};

@interface Zee5PlayerViewController : APPlayerViewController

@property (nonatomic, strong) NSString *currentState;
@property (nonatomic, strong) UIView *hybridPlayerContainerView;

@property (nonatomic, weak) id<pluggablePlayerDelegate> delegate;
@property (nonatomic, weak) UIViewController *previousParentViewController;
@property (nonatomic, weak) UIView *previousContainerView;

@property (nonatomic, strong) NSString *skipInterval;

// Current player display mode
@property (nonatomic, assign) PlayerViewControllerDisplayMode currentDisplayMode;

// Last player display mode
@property (nonatomic, assign) PlayerViewControllerDisplayMode lastDisplayMode;

/**
 Change player display mode
 */
- (void)changePlayerDisplayMode:(PlayerViewControllerDisplayMode)targetDisplayMode;

- (UIView<APPlayerControls> *)hyBridPlayerControls;

/**
 Sleep mode
 */
- (void)sleepModeConfiguration:(NSInteger)value;
- (void)sleepModeCountDown:(NSNumber *)value;

- (BOOL)isLive;

@property (nonatomic, strong) NSObject *currentZee5PlableModel;
@end

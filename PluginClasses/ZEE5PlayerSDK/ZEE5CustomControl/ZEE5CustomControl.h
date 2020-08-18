//
//  ZEE5CustomControl.h
//  ZEE5PlayerSDK
//
//  Created by admin on 11/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Zee5Slider.h"
#import "RelatedVideos.h"
#import "Zee5MenuView.h"


NS_ASSUME_NONNULL_BEGIN
@class TouchableButton;

@interface ZEE5CustomControl : UIView



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *con_height_topBar;

@property (weak, nonatomic) IBOutlet UILabel *watchNowTitle;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *con_top_collectionView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *Stackview_top;

@property (weak, nonatomic) IBOutlet UIButton *buttonReplay;

@property (weak, nonatomic) IBOutlet UIButton *buttonPlay;
@property (weak, nonatomic) IBOutlet UIButton *buttonFullScreen;
@property (weak, nonatomic) IBOutlet UILabel *labelCurrentTime;
@property (weak, nonatomic) IBOutlet UILabel *labelTotalDuration;
@property (weak, nonatomic) IBOutlet Zee5Slider *sliderDuration;

@property (weak, nonatomic) IBOutlet UIView *topView;

@property (weak, nonatomic) IBOutlet UIProgressView *bufferProgress;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UIView *viewVod;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *con_width_more;
@property (weak, nonatomic) IBOutlet UIButton *skipIntro;

@property (weak, nonatomic) IBOutlet UIView *unavailableContentView;
@property (weak, nonatomic) IBOutlet UILabel *unavailableContentLabel;

@property (nonatomic) NSArray <RelatedVideos*>*related;


//Live
@property (weak, nonatomic) IBOutlet UILabel *labelLiveCurrentTime;
@property (weak, nonatomic) IBOutlet UILabel *labelLiveDuration;
@property (weak, nonatomic) IBOutlet UIProgressView *bufferLiveProgress;
@property (weak, nonatomic) IBOutlet UIButton *buttonLive;
@property (weak, nonatomic) IBOutlet UIView *viewLive;
@property (weak, nonatomic) IBOutlet Zee5Slider *sliderLive;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *con_bottom_liveView;
@property (weak, nonatomic) IBOutlet UIButton *buttonLiveFull;
@property (weak, nonatomic) IBOutlet UIButton *btnSkipNext;
@property (weak, nonatomic) IBOutlet UIButton *btnSkipPrev;
@property (weak, nonatomic) IBOutlet UILabel *lableTitle;
@property (weak, nonatomic) IBOutlet UILabel *lableSubTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnMinimize;
@property (weak, nonatomic) IBOutlet UIView *viewTop;


@property (weak, nonatomic) IBOutlet UILabel *watchcreditsTimeLbl;

@property (strong, nonatomic) IBOutlet TouchableButton *forwardButton;
@property (strong, nonatomic) IBOutlet TouchableButton *rewindButton;
- (IBAction)watchCreditsAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *watchcreditsOutlet;

- (IBAction)downloadBtnAction:(id)sender;
-(void)forwardAndRewindActions;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtnOutlet;

@property (weak, nonatomic) IBOutlet UIView *trailerEndView;
- (IBAction)subscribeNow:(UIButton *)sender;
- (IBAction)loginNow:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIStackView *stackLoginView;
@property (weak, nonatomic) IBOutlet UIStackView *watchcretidStackview;
@property (weak, nonatomic) IBOutlet UIView *watchCreditBtnView;
@property (weak, nonatomic) IBOutlet UIView *watchcreditShowView;
@property (weak, nonatomic) IBOutlet UIImageView *nextEpisodeImg;
@property (weak, nonatomic) IBOutlet UILabel *nextEpisodename;
@property (weak, nonatomic) IBOutlet UILabel *showcreditTimelbl;
@property (weak, nonatomic) IBOutlet UIView *parentalDismissView;

@property (weak, nonatomic) IBOutlet UIButton *MenuBtn;
- (IBAction)parentalPlayBtn:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *playerControlView;
- (IBAction)upNextAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *adultView;
@property (weak, nonatomic) IBOutlet UIView *watchCreditVodView;
@end

NS_ASSUME_NONNULL_END

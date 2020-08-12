//
//  ZEE5PlayerManager.m
//  ZEE5PlayerSDK
//
//  Created by admin on 04/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import "ZEE5PlayerManager.h"
#import <AVFoundation/AVFoundation.h>
#import "EpgContentDetailsDataModel.h"
#import "VODContentDetailsDataModel.h"
#import <AdSupport/ASIdentifierManager.h>
#import "ZEE5CustomControl.h"
#import "Zee5MuteView.h"
#import "ParentalView.h"
#import "Zee5FanAdManager.h"
#import <Zee5PlayerPlugin/Zee5PlayerPlugin-Swift.h>
#import "DeviceManager.h"
#import "ZEE5AudioTrack.h"
#import "ZEE5Subtitle.h"
#import "Genres.h"
#import "ZEE5AdModel.h"
#import "SimilarDataModel.h"
#import <PlayKit/PlayKit-Swift.h>
#import <PlayKit_IMA/PlayKit_IMA-Swift.h>
#import "Zee5PlayerPlugin.h"
#import "SubscriptionModel.h"
#import "userSettingDataModel.h"
#import "devicePopView.h"
#import "comScoreAnalytics.h"
#import "LiveContentDetails.h"
#import "AddToWatchlist.h"
#import "tvShowModel.h"
#import "CdnHandler.h"
#import "SingletonClass.h"
#import "GestureHandlerHelper.h"

#define HIDECONTROLSVALUE 5.0
#define TOPBARHEIGHT 30

#define SUBTITLES @"Subtitle"
#define LANGUAGE @"Audio Track"
#define VIDEOQUALITY @"Quality"
#define AUTOPLAY @"Enable auto Play"
#define WATCHLIST @"Add to watch List"
#define PLAYBACKRATE @"Playback Rate"
#define POSTTIME @"post"
#define Conviva_Application_Name @"ZEE5-iOS App"
#define Conviva_Player_name @"ZEE5KalturaPlayer"

 /****************************************
     On Clck Of Share Button Use this url (For Live and VOD)
  *****************************************/
#define LiveShareUrl @"https://www.zee5.com/channels/details/"
#define VodShareUrl @"https://www.zee5.com/"

typedef NS_ENUM(NSUInteger, ZeeUserPlaybackAction) {
    ZeeUserPlaybackActionUnset = 0,
    ZeeUserPlaybackActionPlay,
    ZeeUserPlaybackActionTrailer,
    ZeeUserPlaybackActionIgnore,
};

@interface ZEE5PlayerManager()<UIGestureRecognizerDelegate>//// PlayerDelegate>
@property ZEE5CustomControl *customControlView;           //// Player Controls (play,pause Button)
@property Zee5MenuView *customMenu;                         //// MenuView Includes(Subtitle,Audio Selection)
@property Zee5MuteView *muteView;
@property ParentalView *parentalView;                 //// Parental Lock View(Insert 4 Digit Pin)
@property devicePopView *devicePopView;              //// Device Limit reached for Single user (View will Appear)

@property(nonatomic, strong) UIViewController *currentShareViewController;

@property VODContentDetailsDataModel *ModelValues;         // Stored data Model of Content Response
@property LiveContentDetails *LiveModelValues;             // Stored Data Model Of Live Content
@property tvShowModel *TvShowModel;             // Stored Data Model Of TvShow Content

@property(readwrite ,nonatomic) NSInteger PlayerStartTime;

@property ZEE5PlayerConfig *playerConfig;
@property comScoreAnalytics *comAnalytics;

@property(strong , nonatomic, nullable) PlayerView *kalturaPlayerView;
@property(strong , nonatomic, nullable) UIView *parentPlaybackView;
@property(strong , nonatomic) UIImageView *posterImageView;

@property(nonatomic) UIPanGestureRecognizer *panGesture;
@property(nonatomic) UITapGestureRecognizer *tapGesture;
@property(nonatomic) UIPinchGestureRecognizer *pinGesture;

@property(nonatomic) NSString *selectedString;         // Selected Value Of MenuView From Player.

@property (weak, nonatomic) NSArray *audioTracks;
@property (weak, nonatomic) NSArray *textTracks;
@property (weak, nonatomic) NSArray *selectedTracks;
@property (strong, nonatomic) NSArray *playBackRate;
@property (strong, nonatomic) NSMutableArray *PreviousContentArray;
@property (strong, nonatomic) NSMutableDictionary *oneTrustDict;
@property (strong, nonatomic) NSMutableArray *VideocountArray;
@property (strong,nonatomic) NSTimer *CreditTimer;
@property(nonatomic) NSString *CurrentAudioTrack;
@property(nonatomic) NSString *CurrenttextTrack;

@property(nonatomic) BOOL isLoaderShowing;
@property(nonatomic) BOOL isLive;
@property(nonatomic) BOOL videoCompleted;
@property(nonatomic) BOOL isAllreadyAdded;
@property(nonatomic) BOOL isWatchlistAdded;
@property(nonatomic) BOOL isParentalControlOffline;
@property(nonatomic) BOOL isHybridViewOpen;
@property(nonatomic) BOOL isNeedToSubscribe;
@property(nonatomic) BOOL isRsVodUser;

@property(nonatomic) CGFloat previousDuration;

@property(nonatomic) NSTimeInterval startTime;
@property(nonatomic) NSTimeInterval endTime;
@property(nonatomic) NSString  *showID;
@property(nonatomic) NSString  *videoToken;

@property(nonatomic) NSInteger startIntroTime;
@property(nonatomic) NSInteger endIntroTime;

@property(nonatomic) NSInteger watchCreditsTime;
@property(nonatomic) NSInteger watchHistorySecond;

@property(nonatomic) float currentScale;
@property(nonatomic) float endScale;

@property(nonatomic)int watchCtreditSeconds;

@property(nonatomic) NSString *ageRating;
@property(nonatomic) NSString *parentalPin;
@property(nonatomic) BOOL parentalControl;

@property(nonatomic) NSString *buisnessType;
@property(nonatomic) BOOL allowVideoContent;
@property (weak, nonatomic) NSArray *audioLanguageArr;

@property(nonatomic) Boolean seekStared;

@property (nonatomic, assign) BOOL isFullScreenMode;

@property(strong, nonatomic) GestureHandlerHelper *panDownGestureHandlerHelper;

@end


@implementation ZEE5PlayerManager

static ZEE5PlayerManager *sharedManager = nil;
static SingletonClass *singleton;
static ContentBuisnessType buisnessType;


+ (ZEE5PlayerManager *)sharedInstance
{
    if (sharedManager) {
        return sharedManager;
    }
    
    static dispatch_once_t  t = 0;
    
    dispatch_once(&t, ^{
        sharedManager = [[ZEE5PlayerManager alloc] init];
        singleton = [SingletonClass sharedManager];
        
        [[ChromeCastManager shared] initializeCastOptions];
        
        //            imaSettings.enableOmidExperimentally = YES;
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *error;
        [session setCategory:AVAudioSessionCategoryPlayback error:&error];
        [session setActive:YES error:&error];
        NSBundle *bundel = [NSBundle bundleForClass:self.class];
        [UIFont jbs_registerFontWithFilenameString:@"ZEE5_Player.ttf" bundle:bundel];
        [UIFont jbs_registerFontWithFilenameString:@"ZEE5_Alerts.ttf" bundle:bundel];
        
        [UIFont jbs_registerFontWithFilenameString:@"NotoSans-Bold.ttf" bundle:bundel];
        [UIFont jbs_registerFontWithFilenameString:@"NotoSans-Light.ttf" bundle:bundel];
        [UIFont jbs_registerFontWithFilenameString:@"NotoSans-Medium.ttf" bundle:bundel];
        [UIFont jbs_registerFontWithFilenameString:@"NotoSans-Regular.ttf" bundle:bundel];
        [UIFont jbs_registerFontWithFilenameString:@"NotoSans-SemiBold.ttf" bundle:bundel];
        
        [[PlayKitManager sharedInstance] registerPlugin:IMAPlugin.self];
                
        sharedManager.panDownGestureHandlerHelper = [[GestureHandlerHelper alloc] init];
    });
    
    return sharedManager;
}

//MARK:- VideoPlayMethod

- (void)playWithCurrentItem {
    if (self.currentItem == nil) {
        return;
    }
    
    if ([self.ModelValues.ageRating isEqualToString:@"A"] && ZEE5PlayerSDK.getUserTypeEnum == Guest  && ZEE5PlayerSDK.getConsumpruionType == Trailer == false) {
        [self showLockedContentControls];

        return;
    }
    
    if (_parentalControl) {
        [self hideLoaderOnPlayer];
        [self parentalControlshow];
        return;
    }
    
    if (!_allowVideoContent) {
        return;
    }
    
    if ([[ChromeCastManager shared] isCasting]) {
        [self castCurrentItem];
        return;
    }
    
    if (self.kalturaPlayerView != nil) {
        [self.kalturaPlayerView removeFromSuperview];
    }
    
    self.kalturaPlayerView = [[PlayerView alloc] init];
    [self.parentPlaybackView insertSubview:self.kalturaPlayerView belowSubview:self.customControlView];
    
    self.kalturaPlayerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.kalturaPlayerView matchParent];
    
    self.posterImageView.image = nil;
    
    if (_isStreamoverWifi == true && ZEE5PlayerSDK.Getconnectiontype == Mobile) {
        [self ShowToastMessage:@"WiFi is not connected! You have selected stream over WiFi only"];
        return;
    }
    
    BOOL isReplay = self.videoCompleted;
    self.videoCompleted = NO;
    
    [self getBase64StringwithCompletion:^(NSString *base64) {
        if (self.currentItem == nil) {
            return;
        }
        
        [[Zee5PlayerPlugin sharedInstance] initializePlayer:self.kalturaPlayerView andItem:self.currentItem andLicenceURI:BaseUrls.drmLicenceUrl andBase64Cerificate:base64];
        [self handleTracks];
        [self setupMetadataWithContent: self.currentItem];
        
        if (!isReplay && ZEE5PlayerSDK.getConsumpruionType != Live && ZEE5PlayerSDK.getConsumpruionType != Trailer) {
            [[ReportingManager sharedInstance] getWatchHistory];
        }
    }];
}

- (void)handleCastingStopped {
    [self playWithCurrentItem];
    [self updateControlsForCurrentItem];
}

- (void)castCurrentItem {
    [self hideLoaderOnPlayer];
    
    NSTimeInterval startTime = _customControlView.sliderDuration.value;
    [[ChromeCastManager shared] playSelectedItemRemotelyWithStartTime:startTime];
    
    [self resetControls];
    
    [self pause];
    [self.kalturaPlayerView removeFromSuperview];
    self.kalturaPlayerView = nil;
    
    NSString *imageUrlValue = self.currentItem.imageUrl;
    if (imageUrlValue == nil && self.LiveModelValues != nil) {
        imageUrlValue = self.LiveModelValues.coverImage;
    }
    
    if (imageUrlValue != nil && imageUrlValue.length > 0) {
        NSURL *posterImageUrl = [[NSURL alloc] initWithString:imageUrlValue];
        if (posterImageUrl != nil) {
            if (self.posterImageView == nil) {
                self.posterImageView = [[UIImageView alloc] init];
                
                [self.parentPlaybackView insertSubview:self.posterImageView atIndex:0];
                
                self.posterImageView.translatesAutoresizingMaskIntoConstraints = NO;
                [self.posterImageView matchParent];
            }
            
            NSString *currentContentId = [self.currentItem.content_id copy];
            [[[ZAAppConnector sharedInstance] imageDelegate] setImageWith:posterImageUrl placeholderImage:nil completion:^(UIImage *image, NSError *error) {
                if ([currentContentId isEqualToString:self.currentItem.content_id]) {
                    self.posterImageView.image = image;
                }
            }];
        }
    }
    else {
        self.posterImageView.image = nil;
    }
}

//MARK:- Notification

-(void)registerNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioInterruption:) name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LogoutDone) name:@"ZPLoginProviderLoggedOut" object:nil];
}

-(void)LogoutDone{
    //Here If any Method Called After Logout Then Use this Function
}

-(void)postContentIdShouldUpdateNotification:(NSString *)ContentId {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ContentIdUpdatedNotification" object:nil userInfo:@{@"contentId": ContentId}];
}

-(void)postReloadCurrentContentIdNotification {
    _isNeedToSubscribe = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadCurrentContentIdNotification" object:nil userInfo:nil];
}

-(void)onAudioInterruption:(NSNotification *)notification
{
    if ([[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] isEqualToNumber:[NSNumber numberWithInt:AVAudioSessionInterruptionTypeBegan]]) {
        _customControlView.buttonPlay.hidden = NO;
        [self hideUnHideTopView:NO];
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self pause];
    } else {
    }
}

//MARK:- Add Controls to Player(Control View)
-(void)addCustomControls
{
    if (self.customControlView != nil) {
        return;
    }
    
     _watchHistorySecond = 0;
    /************************************/
    /////  Array of Playeback Rate
    /***********************************/
    NSArray * Rate = [[NSArray alloc]initWithObjects:@"0.5X",@"1X",@"1.5X",@"2X",@"2.5X",@"3X", nil];
    
    self.playBackRate = Rate;
    self.selectedplaybackRate = self.selectedSubtitle =@"1X";
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    [_customControlView.sliderLive animateToolTipFading:NO];

    // temporal bypass to get the view, must refactor the xib structure
    NSArray *nib = [bundle loadNibNamed:@"ZEE5CustomControl" owner:self options:nil];
                  
    _customControlView = [nib objectAtIndex:0];
    _customControlView.accessibilityLabel = @"ZEE5CustomControl";

    UIButton *minimizeButton = [nib objectAtIndex:1];

    [self.parentPlaybackView addSubview:_customControlView];
    [_customControlView fillParent];
    
    [self.parentPlaybackView addSubview:minimizeButton];
    [minimizeButton anchorToTopLeftWithInset:0 size:CGSizeMake(60, 55)];
    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnPlayer)];
    _tapGesture.delegate = self;
    [_tapGesture setDelaysTouchesBegan : YES];
    _tapGesture.numberOfTapsRequired = 1;
    _tapGesture.cancelsTouchesInView = NO;

    [self.parentPlaybackView addGestureRecognizer:_tapGesture];
    
    _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
    [self.parentPlaybackView addGestureRecognizer:_panGesture];
    _panGesture.cancelsTouchesInView = NO;
    
    _pinGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinGesture:)];
    _pinGesture.delegate = self;
     [self.parentPlaybackView addGestureRecognizer:_pinGesture];

    self.parentPlaybackView.accessibilityLabel = @"ParentPlaybackView";
    
    [Zee5PlayerPlugin sharedInstance].player.view.multipleTouchEnabled   = NO;
    [Zee5PlayerPlugin sharedInstance].player.view.userInteractionEnabled = YES;
    
    [self MoatViewAdd];
    [[Zee5PlayerPlugin sharedInstance].player setRate:1.0];
    
    [self resetControls];
}

-(void)showLockedContentControls {
    [self hideLoaderOnPlayer];
    
    _customControlView.hidden = NO;
    _customControlView.parentalDismissView.hidden = YES;
    _customControlView.adultView.hidden = YES;
    _customControlView.trailerEndView.hidden = YES;

    if ([self.ModelValues.ageRating isEqualToString:@"A"] && ZEE5PlayerSDK.getUserTypeEnum == Guest  && ZEE5PlayerSDK.getConsumpruionType != Trailer) {
        [[Zee5PlayerPlugin sharedInstance]ConvivaErrorCode:1002 platformCode:@"009" severityCode:0 andErrorMsg:@"Age Rating Overlay"];
        _customControlView.adultView.hidden = NO;
        return;
    }
    if (_isContentAvailable == NO) {
        _customControlView.unavailableContentView.hidden = NO;
    }
    if (_isNeedToSubscribe && ZEE5PlayerSDK.getUserTypeEnum != premium) {
            [self hideUnHidetrailerEndView:NO];
             return;
         }
}

-(void)MoatViewAdd{
    if (_customControlView != nil && [singleton.ViewsArray containsObject:_customControlView]== false) {
        [singleton.ViewsArray addObject:_customControlView];
    }
    if (_customControlView.viewTop != nil && [singleton.ViewsArray containsObject:_customControlView.viewTop]== false) {
        [singleton.ViewsArray addObject:_customControlView.viewTop];
    }
    if (_customControlView.viewVod != nil && [singleton.ViewsArray containsObject:_customControlView.viewVod]== false ) {
        [singleton.ViewsArray addObject:_customControlView.viewVod];
    }
    if (_customControlView.collectionView != nil && [singleton.ViewsArray containsObject:_customControlView.collectionView]== false) {
        [singleton.ViewsArray addObject:_customControlView.collectionView];
    }
    if (_customControlView.viewLive != nil && [singleton.ViewsArray containsObject:_customControlView.viewLive]== false ) {
        [singleton.ViewsArray addObject:_customControlView.viewLive];
    }
    if (_customControlView.stackLoginView != nil && [singleton.ViewsArray containsObject:_customControlView.stackLoginView]== false) {
        [singleton.ViewsArray addObject:_customControlView.stackLoginView];
    }
    if (_customControlView.watchcretidStackview != nil && [singleton.ViewsArray containsObject:_customControlView.watchcretidStackview]== false ) {
        [singleton.ViewsArray addObject:_customControlView.watchcretidStackview];
    }
    if (_customControlView.adultView != nil && [singleton.ViewsArray containsObject:_customControlView.adultView]== false) {
        [singleton.ViewsArray addObject:_customControlView.adultView];
    }
    if (_customControlView.parentalDismissView != nil && [singleton.ViewsArray containsObject:_customControlView.parentalDismissView]== false) {
        [singleton.ViewsArray addObject:_customControlView.parentalDismissView];
    }
    if (_customControlView.playerControlView != nil && [singleton.ViewsArray containsObject:_customControlView.playerControlView]== false ) {
        [singleton.ViewsArray addObject:_customControlView.playerControlView];
    }
    if (_parentPlaybackView != nil && [singleton.ViewsArray containsObject:_parentPlaybackView]== false ) {
        [singleton.ViewsArray addObject:_parentPlaybackView];
    }
    if (_customControlView.btnMinimize != nil && [singleton.ViewsArray containsObject:_customControlView.btnMinimize]== false) {
        [singleton.ViewsArray addObject:_customControlView.btnMinimize];
    }
    if (_customControlView.watchNowTitle != nil && [singleton.ViewsArray containsObject:_customControlView.watchNowTitle]== false) {
        [singleton.ViewsArray addObject:_customControlView.watchNowTitle];
    }
}

-(void)hideUnHideTopView:(BOOL )isHidden
{
    if (_customControlView.watchNowTitle.isHidden == NO) {
        return;
    }
    
    _customControlView.btnMinimize.hidden = isHidden;
    
    if (self.currentItem == nil) {
        isHidden = YES;
    }
    else if ([[ChromeCastManager shared] isCasting]) {
        isHidden = YES;
    }
    
    _customControlView.viewTop.hidden = isHidden;
    _customControlView.topView.hidden = isHidden;
    _customControlView.playerControlView.hidden = self.isLoaderShowing || isHidden;
    if (!self.isLive)
    {
        _customControlView.viewVod.hidden = isHidden;
        _customControlView.collectionView.hidden = self.customControlView.buttonFullScreen.selected ? isHidden : YES;
    }
    else
    {
        _customControlView.viewLive.hidden = isHidden;
        _customControlView.collectionView.hidden = self.customControlView.buttonLiveFull.selected ? isHidden : YES;
    }
    if (isHidden) {
        _customControlView.con_top_collectionView.constant = 5;
    }

}

-(void)hideCustomControls
{
    [self hideUnHideTopView:YES];
}


-(void)hideUnHidetrailerEndView:(BOOL )isHidden
{
    _customControlView.trailerEndView.hidden = isHidden;
    _customControlView.stackLoginView.hidden = isHidden;

    if (ZEE5PlayerSDK.getUserTypeEnum != Guest) {
        _customControlView.stackLoginView.hidden = YES;
    }
    
}
#pragma mark: Player Events

-(void)playSimilarEvent:(NSString *)content_id
{
    [self SliderReset];
}

-(void)onPlaying
{
    if (_videoCompleted == YES) {
        [self pause];
        return;
    }
    self.customControlView.buttonPlay.selected = YES;
    _customControlView.sliderLive.userInteractionEnabled = NO;
    _videoCompleted = NO;
    [self.panDownGestureHandlerHelper endAd];
    [self updateControlsForCurrentItem];
    [self showAllControls];
    [self hideLoaderOnPlayer];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self perfomAction];

}

-(void)onDurationUpdate:(PKEvent *)event
{

    for (ZEE5AdModel *model in self.currentItem.fanAds)
    {
        if ([model.time isEqualToString:POSTTIME]) {
            NSInteger duration = [event.duration integerValue];
            if(duration != 0)
            {
                model.time = [NSString stringWithFormat:@"%ld",(long)duration];
            }
        }
    }

}

-(void)onTimeChange:(PKEvent *)event
{
    if (self.currentItem == nil) {
        return;
    }
    
    CGFloat floored = floor([event.currentTime doubleValue]);
    NSInteger totalSeconds = (NSInteger) floored;
    [[AnalyticEngine shared]VideoWatchPercentCalcWith:@"Forward"];
    
    if (self.isLive)
    {
        [_customControlView.labelLiveCurrentTime setHidden:YES];
        [_customControlView.labelLiveDuration setHidden:YES];
        
        if (!_customControlView.sliderLive.isTracking && !_seekStared)
        {
            _customControlView.sliderLive.value = totalSeconds;
            if(_customControlView.buttonLiveFull.selected)
            {
                [_customControlView.sliderLive updateToolTipView];
                [_customControlView.sliderLive animateToolTipFading:YES];
            }
            
        }
        _customControlView.sliderLive.maximumValue = [[Zee5PlayerPlugin sharedInstance] getDuration];
        
        if ((_customControlView.sliderLive.maximumValue - 10) <= totalSeconds)
        {
            [_customControlView.buttonLive setTitle:@"LIVE" forState:UIControlStateNormal];
        }
        else
        {
            [_customControlView.buttonLive setTitle:@"GO LIVE" forState:UIControlStateNormal];
        }
        
        _customControlView.sliderLive.value = _customControlView.sliderLive.maximumValue;
    }
    else
    {
        [_customControlView.labelLiveCurrentTime setHidden:NO];
        [_customControlView.labelLiveDuration setHidden:NO];
        
        if (!_customControlView.sliderDuration.isTracking && !_seekStared)
        {
            _customControlView.sliderDuration.value = totalSeconds;
        }
        _customControlView.labelCurrentTime.text = [Utility getDuration:totalSeconds total:[[Zee5PlayerPlugin sharedInstance] getDuration]];
        
      
        //MARK:- WatchHistory Logic
        if ((totalSeconds - _watchHistorySecond > 60 || _watchHistorySecond - totalSeconds > 60) && totalSeconds != 0)
        {
            _watchHistorySecond = totalSeconds;
            if (totalSeconds < _watchCreditsTime) {
                  [[ReportingManager sharedInstance]startReportingWatchHistory:_watchHistorySecond];
            }
        }
       /***********************************************/
        //MARK:- WatchCredit
       /*********************************************/
        if (totalSeconds >=_watchCreditsTime && (totalSeconds !=0 && _watchCreditsTime !=0 ) && _isLoaderShowing == NO){
            [[ReportingManager sharedInstance]deleteWatchHIstory];
            [self WatchcreditControls:totalSeconds];
        }
      
        //MARK:- SkipIntro Click Logic
        
        if (totalSeconds>=self.startIntroTime && totalSeconds<self.endIntroTime && _endIntroTime!=0)
        {
            _customControlView.skipIntro.hidden = NO;
        }
        else
        {
            _customControlView.skipIntro.hidden = YES;
        
        }
        
        NSString *duration = [Utility getDuration:[[Zee5PlayerPlugin sharedInstance] getDuration] total:[[Zee5PlayerPlugin sharedInstance] getDuration]];
        if (duration != nil && [duration length] > 0) {
            _customControlView.labelTotalDuration.text = duration;
        }
        else {
            _customControlView.labelTotalDuration.text = nil;
        }
        
        _customControlView.sliderDuration.maximumValue = [[Zee5PlayerPlugin sharedInstance] getDuration];
        
         //MARK:-  Continue Watching Logic
        if ([[ReportingManager sharedInstance]isCountinueWatching])
        {
            [self setSeekTime:_PlayerStartTime];
            _PlayerStartTime = 0;
            [[ReportingManager sharedInstance]setIsCountinueWatching:NO];
        }
    }
}


//MARK:- Watch Credit Logic

-(void)WatchcreditControls:(NSInteger)CreditTime
{
    if ([self.ModelValues.watchCreditTime isEqualToString:@"NULL"]==false && self.currentItem.WatchCredit == NO && _CreditTimer == nil )
        {
        
            if ((ZEE5PlayerSDK.getConsumpruionType == Episode || ZEE5PlayerSDK.getConsumpruionType == Original) && _customControlView.watchcretidStackview.hidden == true)
            {
                 self.CreditTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];   ///********* Timer Fired******
        
                _customControlView.watchcretidStackview.hidden = NO;
                _customControlView.watchcreditShowView.hidden = NO;
                _customControlView.watchCreditVodView.hidden =NO;
                _customControlView.collectionView.hidden =YES;
            }
            else
            {
                if ( _customControlView.watchcreditsTimeLbl.hidden==YES && self.customControlView.buttonFullScreen.selected == YES )
                {
                     self.CreditTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];///********* Timer Fired******
                    
                     [self handleUpwardsGesture:nil];
                    _customControlView.watchcreditsTimeLbl.hidden = NO;
                    _customControlView.watchcretidStackview.hidden = NO;
                    _customControlView.watchCreditBtnView.hidden = NO;
                    _customControlView.watchcreditShowView.hidden = YES;
                    _customControlView.watchCreditVodView.hidden =YES;
                }
            }
        }
    
    
}

-(void)timerFired
{
    if(_watchCtreditSeconds>0)
        {
            _watchCtreditSeconds -= 1;
            [_customControlView.watchcreditsTimeLbl setText:[NSString stringWithFormat:@"%@%02d",@"Starts In : ",_watchCtreditSeconds]];
            
           [_customControlView.showcreditTimelbl setText:[NSString stringWithFormat:@"%@%02d",@"Starts In : ",_watchCtreditSeconds]];
            
            if ((ZEE5PlayerSDK.getConsumpruionType != Episode || ZEE5PlayerSDK.getConsumpruionType != Original) && _customControlView.buttonFullScreen.selected){
                _customControlView.collectionView.hidden = false;
                return;
            }
            _customControlView.watchcretidStackview.hidden = false;
            
        }
         else
        {
            [self tapOnUpNext];
        }
}


             
-(void)onBuffring
{
    [self showloaderOnPlayer];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

}

-(void)onBuffringValueChange:(PKEvent *)event
{
    
    PKTimeRange *range = event.timeRanges.lastObject;
   // AnalyticEngine *engine =[[AnalyticEngine alloc]init];
    
    if (_isLive) {
        _customControlView.sliderLive.maximumValue = [[Zee5PlayerPlugin sharedInstance] getDuration];
        _customControlView.bufferLiveProgress.progress = range.duration/100;
        
    }
    else
    {
        _customControlView.bufferProgress.progress = range.duration/100;
        if([_customControlView.labelTotalDuration.text isEqualToString:@"00:00"])
        {
            NSTimeInterval duration = [[Zee5PlayerPlugin sharedInstance] getDuration];
            if (duration > 0) {
                _customControlView.sliderDuration.maximumValue = duration;
                _customControlView.labelTotalDuration.text = [Utility getDuration:[[Zee5PlayerPlugin sharedInstance] getDuration] total:[[Zee5PlayerPlugin sharedInstance] getDuration]];
               // [_customControlView.sliderDuration setMarkerAtPosition:100.0/_customControlView.sliderDuration.maximumValue];
              //  [_customControlView.sliderDuration setMarkerAtPosition:200.0/_customControlView.sliderDuration.maximumValue];
            }
        }
    }

}

- (void)onComplete
{
    _isTelco = NO;
    [self hideLoaderOnPlayer];
    
    if (ZEE5PlayerSDK.getConsumpruionType == Trailer && ZEE5PlayerSDK.getUserTypeEnum != Premium && !_customControlView.btnSkipNext.selected) {
        _videoCompleted = YES;
        [self HybridViewOpen];
        [self hideUnHidetrailerEndView:NO];
        return;
    }
    if (_isNeedToSubscribe && !_customControlView.btnSkipNext.selected) {
        _videoCompleted = YES;
        [self HybridViewOpen];
        [self hideUnHidetrailerEndView:NO];
        return;
    }
    if (!_isAutoplay && !_customControlView.btnSkipNext.selected) {
        _videoCompleted = YES;
        _customControlView.buttonPlay.hidden = YES;
        _customControlView.buttonReplay.hidden = NO;
        [self hideUnHideTopView:NO];
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self SliderReset];
    }
    else {
        if (_CreditTimer != nil) {
            return;
        }
        RelatedVideos *nextItem = nil;
        if (ZEE5PlayerSDK.getConsumpruionType == Episode || ZEE5PlayerSDK.getConsumpruionType == Original) {
            nextItem = self.currentItem.related[0];
        }
        else {
            for (RelatedVideos *relatedVideo in self.currentItem.related) {
                if (![_PreviousContentArray containsObject:relatedVideo.identifier]) {
                    nextItem = relatedVideo;
                    break;
                }
            }
        }
        if (nextItem != nil) {
            [[ZEE5PlayerManager sharedInstance] playSimilarEvent:nextItem.identifier];
            [self postContentIdShouldUpdateNotification:nextItem.identifier];
        }
    }
}

//MARK:- HandleHlsError(ndToken Method)

-(void)handleHLSError
{
    
    [self getTokenND:^(NSString *token)
    {
        NSArray *aryStrings = [self.currentItem.hls_Url componentsSeparatedByString:@".m3u8"];
        if ([aryStrings count] > 1)
        {
            NSString *newURL = [NSString stringWithFormat:@"%@.m3u8%@",aryStrings[0],token];
            newURL = [newURL stringByReplacingOccurrencesOfString:@"drm" withString:@"hls"];
            newURL = [newURL stringByReplacingOccurrencesOfString:@"zee5vod" withString:@"zee5vodnd"];
            self.currentItem.hls_Url = newURL;
            [self CreateConvivaSession];
            [self playWithCurrentItem];
        }

    }];
}

-(void)getTokenND:(void (^)(NSString *))completion
{
    [[NetworkManager sharedInstance]makeHttpGetRequest:BaseUrls.getndToken requestParam:@{} requestHeaders:@{} withCompletionHandler:^(id  _Nullable result) {
        if ([result isKindOfClass:[NSDictionary class]]) {
            
            completion(result[@"video_token"]);
        }
    } failureBlock:^(ZEE5SdkError * _Nullable error) {
        self.allowVideoContent = NO;
    }];
}
-(void)getBase64StringwithCompletion:(void (^)(NSString *))completion
{
    NSURL *url = [[NSURL alloc] initWithString:BaseUrls.drmCertificateUrl];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        NSString *base64 = [data base64EncodedStringWithOptions:0];
        completion(base64);
        [session finishTasksAndInvalidate];
        
    }];
    [postDataTask resume];

}

-(void)perfomAction
{
    [self performSelector:@selector(hideCustomControls) withObject:nil afterDelay:HIDECONTROLSVALUE];
}

#pragma mark: Gesture Events

-(void)tapOnPlayer
{
    
    [_customControlView.sliderDuration animateToolTipFading:NO];

    if (_customControlView.btnMinimize.hidden)
    {
        [self hideUnHideTopView:NO];
    }
    else
    {
        [self hideUnHideTopView:YES];
    }

    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (_customControlView.buttonPlay.selected) {
        if (!_customControlView.topView.hidden) {
            [self perfomAction];
        }
    }
}

-(void)removeMenuView
{
    if(_customMenu != nil)
    {
        if (_customMenu.superview != nil) {
            [_customMenu removeFromSuperview];

        }
        return;
    }

}
- (void)handlePinGesture:(UIPinchGestureRecognizer *)sender{
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:self.pinGesture.state;
            _currentScale = _pinGesture.scale;
            break;
        case UIGestureRecognizerStateEnded:self.pinGesture.state;
            _endScale = _pinGesture.scale;
            [self pinchZoomPlayerview:_currentScale End:_endScale];
            break;
        default:
            break;
    }
}
-(void)pinchZoomPlayerview:(float)currentScale End:(float)endScale{
    if (endScale > currentScale ) {
        if (_parentPlaybackView != nil && singleton.isAdStarted == false) {
            [Zee5PlayerPlugin .sharedInstance.player.view setContentMode:UIViewContentModeScaleAspectFill];
        }
        
    }else if (currentScale > endScale){
        if (_parentPlaybackView != nil && singleton.isAdStarted == false) {
                   [Zee5PlayerPlugin .sharedInstance.player.view setContentMode:UIViewContentModeScaleAspectFit];
               }
    }
    _currentScale = _endScale = 0.0;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)sender
{
    
    typedef NS_ENUM(NSUInteger, UIPanGestureRecognizerDirection) {
        UIPanGestureRecognizerDirectionUndefined,
        UIPanGestureRecognizerDirectionUp,
        UIPanGestureRecognizerDirectionDown,
        UIPanGestureRecognizerDirectionLeft,
        UIPanGestureRecognizerDirectionRight
    };
    
    static UIPanGestureRecognizerDirection direction = UIPanGestureRecognizerDirectionUndefined;
    
    switch (sender.state) {
            
        case UIGestureRecognizerStateBegan: {
            
            if (direction == UIPanGestureRecognizerDirectionUndefined) {
                
                CGPoint velocity = [sender velocityInView:[Zee5PlayerPlugin sharedInstance].player.view];
                
                BOOL isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);
                
                if (isVerticalGesture) {
                    if (velocity.y > 0) {
                        direction = UIPanGestureRecognizerDirectionDown;
                    } else {
                        direction = UIPanGestureRecognizerDirectionUp;
                    }
                }
                
                else {
                    if (velocity.x > 0) {
                        direction = UIPanGestureRecognizerDirectionRight;
                    } else {
                        direction = UIPanGestureRecognizerDirectionLeft;
                    }
                }
            }
            
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            switch (direction) {
                case UIPanGestureRecognizerDirectionUp: {
                    [self handleUpwardsGesture:sender];
                    break;
                }
                case UIPanGestureRecognizerDirectionDown: {
                    [self handleDownwardsGesture:sender];
                    break;
                }
                default: {
                    break;
                }
            }
        }
            
        case UIGestureRecognizerStateEnded: {
            if (direction == UIPanGestureRecognizerDirectionDown) {
                if ([self.panDownGestureHandlerHelper isAllowed]) {
                    [self tapOnMinimizeButton];
                }
                else {
                    [self handleDownwardsGesture:sender];
                }
            }
            direction = UIPanGestureRecognizerDirectionUndefined;
            break;
        }
            
        default:
            break;
    }
    
}

- (void)handleUpwardsGesture:(UIPanGestureRecognizer *)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    _customControlView.con_top_collectionView.constant = -130;
    [self hideUnHideControls:YES];
    [UIView animateWithDuration:0.3 animations:^{
        [self.customControlView layoutIfNeeded];
    }];
}

-(void)hideUnHideControls:(BOOL )isHidden
{
    if (_customControlView.buttonFullScreen.selected == NO || _customControlView.buttonLiveFull.selected == NO) {
        _customControlView.collectionView.hidden = YES;
        return;
    }
    
    _customControlView.btnMinimize.hidden = isHidden;

    if (self.currentItem == nil) {
        isHidden = YES;
    }
    
    _customControlView.collectionView.hidden = isHidden ? NO:YES;
    _customControlView.watchNowTitle.hidden = isHidden ? NO:YES;
    _customControlView.viewTop.hidden = isHidden;
    _customControlView.topView.hidden = isHidden;
    _customControlView.viewVod.hidden = isHidden;
    _customControlView.playerControlView.hidden = self.isLoaderShowing || isHidden;
}

- (void)handleDownwardsGesture:(UIPanGestureRecognizer *)sender
{
     [self hideUnHideControls:NO];
    if (_customControlView.buttonPlay.selected) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            [self perfomAction];
    }
    _customControlView.con_top_collectionView.constant = 5;
    [UIView animateWithDuration:0.3 animations:^{
        [self.customControlView layoutIfNeeded];
    }];
    
}

#pragma mark: Player Controls


-(void)play
{
    NSInteger rounded = roundf(_customControlView.sliderDuration.maximumValue);
    if (rounded == _customControlView.sliderDuration.value && rounded != 0)
    {
        [self onComplete];
    }
    else
    {
        self.customControlView.buttonPlay.selected = YES;
        [[Zee5PlayerPlugin sharedInstance].player play];
    }
}

-(void)Playbackcheck
{
    if (singleton.isAdPause == true) {
        [[Zee5PlayerPlugin sharedInstance].player play];
        return;
    }
}

-(void)pause
{
    [self hideLoaderOnPlayer];
    self.customControlView.buttonPlay.selected = NO;
    [[Zee5PlayerPlugin sharedInstance].player pause];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

}

-(void)DestroyPlayer{
    [[NetworkManager sharedInstance] cancelAllRequests];
    [self hideLoaderOnPlayer];
    [self.panDownGestureHandlerHelper endAd];

    [[Zee5PlayerPlugin sharedInstance].player destroy];
    [[ReportingManager sharedInstance]resetValues];
    _currentItem = nil;
    
     singleton.isAdStarted = NO;
     singleton.isAdPause = NO;
    _watchCreditsTime = 0 ;
    _textTracks = nil;
    _offlineTextTracks = nil;
    _audioTracks = nil;
    _offlineLanguageTracks = nil;
    self.selectedplaybackRate = self.selectedplaybackRateOffline = @"1X";
    self.LiveModelValues = nil;
    self.ModelValues = nil;
    self.posterImageView.image = nil;
    self.allowVideoContent = NO;
    
    [self.kalturaPlayerView removeFromSuperview];
    self.kalturaPlayerView = nil;
    
    [self resetControls];
}

-(void)replay
{
    [[NetworkManager sharedInstance] cancelAllRequests];

    [self resetControls];
    [self showloaderOnPlayer];
    
    [[AnalyticEngine shared] ReplayVideo];
    
    [self playWithCurrentItem];
}

- (void)stop
{
    [[AnalyticEngine shared]videoWatchDurationAnalytic];
    [[Zee5PlayerPlugin sharedInstance].player stop];
    self.isStop = YES;
    [[Zee5FanAdManager sharedInstance] stopFanAd];
}

-(void) skipIntro
{
    _customControlView.skipIntro.hidden =YES;
    [self setSeekTime:self.endIntroTime];
    [self showloaderOnPlayer];
    AnalyticEngine *engine = [[AnalyticEngine alloc]init];
    [engine skipIntroAnalyticsWith:_ModelValues.introStarttime SkipendTime:self.ModelValues.introEndTime];
    
}

-(void)WatchCredits
{
    [self handleDownwardsGesture:nil];
    self.currentItem.WatchCredit =YES;
    _customControlView.watchcretidStackview.hidden = true;
    [_CreditTimer invalidate];
    _CreditTimer = nil;
    
    AnalyticEngine *engine = [[AnalyticEngine alloc]init];
    [engine watchCreditsAnalyticsWith:self.ModelValues.watchCreditTime];
    
}


-(void)setSeekTime:(NSInteger)value
{
       [self showloaderOnPlayer];
    __weak __typeof(self) weakSelf = self;
    int rounded = roundf([[Zee5PlayerPlugin sharedInstance] getDuration]);
    if(value == 0)
    {
        value = 1;
    }
    else if(value == rounded)
    {
        value = value - 1;
    }
    _seekStared = YES;
    [[Zee5PlayerPlugin sharedInstance] setSeekTime:value];
    
    if (_CreditTimer != nil) {
          [_CreditTimer invalidate];
          _CreditTimer = nil;
          _customControlView.watchcretidStackview.hidden = YES;
          _customControlView.watchcreditsTimeLbl.hidden = YES;
           _watchCtreditSeconds = 10;
          [self handleDownwardsGesture:nil];
      }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.seekStared = false;
    });
}

-(void)setFullScreen:(BOOL)isFull {
    UIInterfaceOrientation value = isFull ? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationPortrait;
    [[UIDevice currentDevice] setValue:@(value) forKey:@"orientation"];
}

-(void)setMute:(BOOL)isMute
{
    [Zee5PlayerPlugin sharedInstance].player.volume = isMute ? 0.0 : 1.0;
}

-(void)setWatchHistory:(NSInteger)duration
{
    _PlayerStartTime = duration;    // Duration Get From WatchHistory Api Response.
    NSString *videoStartPoint = [Utility stringFromTimeInterval:_PlayerStartTime];
    NSString *VideoEndpoint = [Utility stringFromTimeInterval:_currentItem.duration];
    NSDictionary *dict = @{@"videoStartPoint" : videoStartPoint,@"videoEndPoint":VideoEndpoint};
    [[AnalyticEngine shared]VideoStartTimeWith:_PlayerStartTime];
    [self updateConvivaSessionWithMetadata: dict];
    
}

-(void)setLock:(BOOL)isLock
{
    [self hideUnHideTopView:isLock];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTaponLockButton:)]) {
        [self.delegate didTaponLockButton:isLock ? Locked : Unlocked];
    }
    
}

-(void)tapOnNextButton
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTaponNextButton)]) {
        [self.delegate didTaponNextButton];
        if (_currentItem.related.count>0)
        {
            _customControlView.btnSkipNext.selected = YES;
            if (_PreviousContentArray == nil) {
                            _PreviousContentArray = [[[NSMutableArray alloc]initWithObjects:_currentItem.content_id, nil]mutableCopy];
                        }
            [self onComplete];
        }
    }
}
-(void)tapOnPrevButton
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTaponPrevButton)]) {
        [self.delegate didTaponPrevButton];
        [self pause];
        _customControlView.btnSkipPrev.selected = YES;
        if (_PreviousContentArray.count>1) {
            for (int i = 0; i< _PreviousContentArray.count; i++) {
                NSString *cId = [_PreviousContentArray objectAtIndex:i];
                
                if ([_currentItem.content_id isEqualToString:cId] && i != 0)
                {
                    cId = [_PreviousContentArray objectAtIndex:i-1];

                    if (i == 1) {
                        _customControlView.btnSkipPrev.selected = false;
                    }
                    
                    [self postContentIdShouldUpdateNotification:cId];
                    break;
                }
            }
        }
        
    }
    
}
//MARK:- Handle Local Storage Array.
-(void)LocalStorageArray{
    
    _VideocountArray =[[NSMutableArray alloc]initWithCapacity:23];
    _VideocountArray = [[[NSUserDefaults standardUserDefaults]valueForKey:@"VideoCount"]mutableCopy];
    
    if (_VideocountArray.count <=20) {
        if (_VideocountArray == nil) {
            _VideocountArray = [[[NSMutableArray alloc]initWithObjects:@"Video", nil]mutableCopy];
        }else{
             [_VideocountArray addObject:@"Video"];
        }
             
        if (_VideocountArray.count == 1) {
            [[AnalyticEngine shared]VideoClick1Event];
        }else if (_VideocountArray.count == 3){
            [[AnalyticEngine shared]VideoClick3Event];
        }else if (_VideocountArray.count == 5){
             [[AnalyticEngine shared]VideoClick5Event];
        }else if (_VideocountArray.count == 7){
            [[AnalyticEngine shared]VideoClick7Event];
        }else if (_VideocountArray.count == 10){
             [[AnalyticEngine shared]VideoClick10Event];
        }else if (_VideocountArray.count == 15){
              [[AnalyticEngine shared]VideoClick15Event];
        }else if (_VideocountArray.count == 20){
              [[AnalyticEngine shared]VideoClick20Event];
        }
        [[NSUserDefaults standardUserDefaults]setObject:_VideocountArray forKey:@"VideoCount"];
    }
    if (ZEE5PlayerSDK.getConsumpruionType == Live == false && _customControlView.btnSkipNext.selected == TRUE) {

        _customControlView.btnSkipNext.selected = FALSE;
         _customControlView.btnSkipPrev.hidden = FALSE;
        _isAllreadyAdded = false;
    
        if (_PreviousContentArray.count>10) {
            [_PreviousContentArray removeObjectAtIndex:0];
        }
        
        if (_PreviousContentArray == nil) {
            _PreviousContentArray = [[[NSMutableArray alloc]initWithObjects:_currentItem.content_id, nil]mutableCopy];
        }else{
            for (NSString  *Contentid in _PreviousContentArray) {
                if ([Contentid isEqualToString:_currentItem.content_id]) {
                    _isAllreadyAdded = TRUE;
                    break;
                }
            }
        }
        if (_isAllreadyAdded == false && _PreviousContentArray != nil && _currentItem != nil){
            [_PreviousContentArray addObject:_currentItem.content_id];
        }
    }
    if (ZEE5PlayerSDK.getConsumpruionType == Episode || ZEE5PlayerSDK.getConsumpruionType == Original)
      {
          RelatedVideos *model = self.currentItem.related[0];
          _customControlView.nextEpisodename.text = model.title;
          
          [_customControlView.nextEpisodeImg setImage:[UIImage imageNamed:@"placeholder"]];
          
          dispatch_async(dispatch_get_global_queue(0,0), ^{
              NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: model.imageURL]];
              if ( data == nil )
                  return;
              dispatch_async(dispatch_get_main_queue(), ^{
                  [self.customControlView.nextEpisodeImg setImage:[UIImage imageWithData: data]];
              });
          });
      }
}
-(void)tapOnMinimizeButton
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTaponMinimizeButton)]) {
        [self.delegate didTaponMinimizeButton];
    }
}

-(void)tapOnUpNext
{
    [self SliderReset];
    [self.CreditTimer invalidate];
    _CreditTimer = nil;
    _customControlView.watchcreditsTimeLbl.hidden=YES;
     _customControlView.collectionView.hidden =YES;
    _customControlView.watchcretidStackview.hidden = YES;
    
    if (self.currentItem.WatchCredit==NO)
    {
         [self handleDownwardsGesture:nil];
         [self onComplete];
    }
    self.currentItem.WatchCredit = YES;
}
-(void)tapOnLiveButton
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTaponLiveButton:)])
    {
        [self.delegate didTaponLiveButton:self.showID];
    }
}

-(void)SliderReset {
    _customControlView.bufferProgress.progress = 0;
    _customControlView.sliderDuration.value = 0;
    _customControlView.labelCurrentTime.text = @"00:00";
    _customControlView.labelTotalDuration.text = nil;
}

-(void)tapOnGoLiveButton
{
    [self setSeekTime:_customControlView.sliderLive.maximumValue];
    [self play];
}

-(void)tapOnShareButton
{
    [self pause];   ///// Player Pause Here
    NSArray *objectsToShare;
    NSURL *zeeShareUrl;

    if (_isLive){
        
        if (_LiveModelValues.title && _LiveModelValues.identifier != nil ){
            NSString *Title = [_LiveModelValues.title stringByReplacingOccurrencesOfString:@" " withString:@"-"].lowercaseString;
            zeeShareUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@",LiveShareUrl,Title,_LiveModelValues.identifier]];
        }
    } else
    {
        zeeShareUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",VodShareUrl,_ModelValues.web_Url]];
    }
    
    objectsToShare = @[zeeShareUrl];

    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    activityVC.popoverPresentationController.sourceView = self.parentPlaybackView;
  
    [activityVC setCompletionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError)
     {
        self.currentShareViewController = nil;

        if (completed){
            [[AnalyticEngine shared]ShareAnlytics];
            [self play];
        }else{
            [self play];
        }
    }];

    UIViewController *VC = [[UIApplication sharedApplication]keyWindow].rootViewController.topmostModalViewController;
    [VC presentViewController:activityVC animated:YES completion: nil];
    
    self.currentShareViewController = activityVC;
}

-(void)navigateToDetail
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapOnPlayerToNavigateDetail)]) {
        [self.delegate didTapOnPlayerToNavigateDetail];
    }
}
- (void)refreshLabel
{
    __weak __typeof(self) weakSelf = self;
    
    //refresh the label.text on the main thread
    dispatch_async(dispatch_get_main_queue(),^{
        
        
        NSString *time = [Utility convertEpochToTime:[NSDate timeIntervalSinceReferenceDate]];
        
       // weakSelf.customControlView.labelLiveDuration.text = time;
        
    });
    // check every 60s
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf refreshLabel];
    });
}


-(CGFloat )getCurrentDuration
{
    if ([Zee5PlayerPlugin sharedInstance].player != nil)
    {
        return [[Zee5PlayerPlugin sharedInstance] getCurrentTime];
    }
    return 0.0;
    
}
-(CGFloat )getTotalDuration
{
    if ([Zee5PlayerPlugin sharedInstance].player != nil)
    {
        return [[Zee5PlayerPlugin sharedInstance] getDuration];
    }
    return 0.0;
}


-(NSUInteger )getBufferPercentage
{
    if ([Zee5PlayerPlugin sharedInstance].player != nil)
    {
        return [[Zee5PlayerPlugin sharedInstance] getCurrentTime];
    }
    return 0;
}

-(void)showAllControls
{
    _customControlView.buttonReplay.hidden = YES;
    
    [self hideUnHideTopView:NO];
}

-(void)showFullScreen
{
    self.isFullScreenMode = YES;
    
    if (_customControlView == nil) {
        return;
    }
    
    [_customControlView.sliderDuration animateToolTipFading:NO];
    _customControlView.watchNowTitle.hidden = YES;
    _customControlView.sliderLive.fullScreen = YES;
    [_customControlView.sliderLive updateToolTipView];
    if(_customControlView.sliderLive.userInteractionEnabled)
    {
        [_customControlView.sliderLive animateToolTipFading:YES];
    }
    
    self.customControlView.buttonFullScreen.selected = YES;
    self.customControlView.buttonLiveFull.selected = YES;
    
    if(!_videoCompleted && _isLive == false)
    {
        _customControlView.btnSkipNext.hidden = NO;
    }
    _customControlView.lableSubTitle.hidden = NO;
    
    self.customControlView.con_height_topBar.constant = TOPBARHEIGHT;
    self.customControlView.con_bottom_liveView.constant = 30;
    
    self.customControlView.collectionView.hidden = ![AppConfigManager sharedInstance].config.isSimilarVideos;
    _customControlView.con_top_collectionView.constant = 5;
    
    _customControlView.forwardButton.enabled = !_isLive;
    _customControlView.rewindButton.enabled = !_isLive;
    _customControlView.backtoPartnerView.hidden = YES;

    
    if (self.devicePopView != nil ||self.parentalView != nil)
    {
        self.devicePopView.hidden =YES;
        self.parentalView.hidden =YES;
    }
    
    [[AnalyticEngine shared] playerOrientationChangedTo: ZeeAnalyticsPlayerOrientationLandscape];
 
    NSDictionary *dict = @{@"viewingMode" : [AnalyticEngine playerOrientationNameFor: ZeeAnalyticsPlayerOrientationLandscape]};
    [self updateConvivaSessionWithMetadata: dict];
    
    [self.panDownGestureHandlerHelper didEnterLandscapeMode];
}

-(void)hideFullScreen
{
    self.isFullScreenMode = NO;
    if (_customControlView == nil) {
        return;
    }
    
    _customControlView.sliderLive.fullScreen = NO;
    _customControlView.watchNowTitle.hidden = YES;
    [_customControlView.sliderLive animateToolTipFading:NO];
    [_customControlView.sliderDuration animateToolTipFading:NO];
    
    self.customControlView.buttonFullScreen.selected = NO;
    self.customControlView.buttonLiveFull.selected = NO;
    _customControlView.skipIntro.hidden = YES;
    _customControlView.lableSubTitle.hidden = YES;
    
    self.customControlView.con_height_topBar.constant = 0;
    self.customControlView.con_bottom_liveView.constant = 10;
    
    _customControlView.con_top_collectionView.constant = 5;
    self.customControlView.collectionView.hidden = YES;
    _customControlView.watchcreditsTimeLbl.hidden = YES;

    _customControlView.forwardButton.enabled = !_isLive;
    _customControlView.rewindButton.enabled = !_isLive;
    
    if (_isTelco == true)
    {
        _customControlView.backtoPartnerView.hidden = false;
        _customControlView.partnerLblTxt.text = _TelcoMsg;
    }

    [[AnalyticEngine shared] playerOrientationChangedTo: ZeeAnalyticsPlayerOrientationPortrait];

    NSDictionary *dict = @{@"viewingMode" : [AnalyticEngine playerOrientationNameFor: ZeeAnalyticsPlayerOrientationPortrait]};
    [self updateConvivaSessionWithMetadata: dict];
    
    if (self.parentalView!=nil)
    {
        self.parentalView.hidden = NO;
    }

    if (self.devicePopView!=nil)
    {
        self.devicePopView.hidden =NO;
    }

    [self.panDownGestureHandlerHelper didEnterPortraitMode];
}

- (void)resetControls {
    _customControlView.btnMinimize.hidden = YES;
    
    _customControlView.buttonPlay.hidden = NO;
    _customControlView.buttonReplay.hidden = YES;
    
    _customControlView.viewTop.hidden = YES;
    _customControlView.topView.hidden = YES;
    _customControlView.playerControlView.hidden = YES;
    _customControlView.collectionView.hidden = YES;
    _customControlView.backtoPartnerView.hidden = YES;
    
    _customControlView.adultView.hidden = YES;
    _customControlView.parentalDismissView.hidden = YES;
    _customControlView.btnSkipPrev.hidden = YES;
    
    [_customControlView forwardAndRewindActions];
    
    _customControlView.viewLive.hidden = YES;
    _customControlView.viewVod.hidden = YES;
    _customControlView.skipIntro.hidden = YES;
    _customControlView.btnSkipNext.hidden = YES;
    _customControlView.MenuBtn.hidden = YES;
        
    [_customControlView.nextEpisodeImg setImage:[UIImage imageNamed:@"placeholder"]];

    _customControlView.lableTitle.text = nil;

    _customControlView.unavailableContentView.hidden = YES;
    
    [self hideUnHidetrailerEndView:YES];
    [self SliderReset];
    [self removeSubview];
}

- (void)updateControlsForCurrentItem {
    if (self.currentItem == nil) {
        return;
    }
    
    if (singleton.isAdStarted) {
        _customControlView.hidden = YES;
        return;
    }
    
    _customControlView.hidden = NO;
    
    _customControlView.viewLive.hidden = !self.isLive;
    _customControlView.viewVod.hidden = self.isLive;
    _customControlView.skipIntro.hidden = self.isLive;
    _customControlView.btnSkipNext.hidden = _isLive;
    _customControlView.MenuBtn.hidden = _isLive;
    _customControlView.related = self.currentItem.related;
    
    if (self.isLive) {
        _customControlView.lableTitle.text = [NSString stringWithFormat:@"%@ : %@",self.currentItem.channel_Name,self.currentItem.showName];
        _customControlView.sliderLive.userInteractionEnabled = NO;
        if (_endTime == 0) {
            [self refreshLabel];
        }
        else
        {
            // _customControlView.labelLiveDuration.text = [Utility convertEpochToTime:_endTime];
        }
    }
    else
    {
        if (_currentItem.channel_Name.length!=0)
        {
            _customControlView.lableTitle.text = [NSString stringWithFormat:@"%@ : %@",self.currentItem.channel_Name,self.currentItem.channel_Name];
        }
    }
    
    if (self.isFullScreenMode) {
        [self showFullScreen];
    }
    else {
        [self hideFullScreen];
    }
}

//MARK:- Player Loader

-(void)showloaderOnPlayer{
    self.isLoaderShowing = YES;
    self.customControlView.playerControlView.hidden = YES;

    if (self.delegate && [self.delegate respondsToSelector:@selector(showPlayerLoader)]) {
        [self.delegate showPlayerLoader];
    }
    
}

-(void)hideLoaderOnPlayer{
    
    self.isLoaderShowing = NO;

    if (self.delegate && [self.delegate respondsToSelector:@selector(hidePlayerLoader)]) {
        [self.delegate hidePlayerLoader];
    }
}

-(void)startAd {
    [self.panDownGestureHandlerHelper startAd];
     singleton.isAdPause = NO;
     singleton.isAdStarted = YES;
    [self updateControlsForCurrentItem];
}

-(void)endAd {
    singleton.isAdStarted = NO;
}

-(void)pauseAd {
    singleton.isAdPause = YES;
}

-(void)ShowToastMessage:(NSString *)Message{
    [[ZEE5PlayerDeeplinkManager sharedMethod]ShowtoastWithMessage:Message];
   
}

-(void)forward:(NSInteger)value
{
    NSLog(@" Seeked %ld",(long)value);
    NSInteger currentTime = [[Zee5PlayerPlugin sharedInstance] getCurrentTime];
    NSInteger seekValue = currentTime + value;
    if(seekValue > [[Zee5PlayerPlugin sharedInstance] getDuration])
    {
        seekValue = [[Zee5PlayerPlugin sharedInstance] getDuration];
    }
    [self setSeekTime:seekValue];
    [[AnalyticEngine shared]AutoSeekAnalyticsWith:@"Forward" Starttime:currentTime Endtime:seekValue];

}
-(void)rewind:(NSInteger)value
{
    NSInteger currentTime = [[Zee5PlayerPlugin sharedInstance] getCurrentTime];
    
    NSInteger seekValue = currentTime - value;
    if(seekValue < 0)
    {
        seekValue = 0;
    }
    [self setSeekTime:seekValue];
    [[AnalyticEngine shared]AutoSeekAnalyticsWith:@"Rewind" Starttime:currentTime Endtime:seekValue];
}

-(void)setAudioTrack:(NSString *)audioID Title:(NSString *)AudioTitle
{
    self.selectedLangauge = audioID;
    [[Zee5PlayerPlugin sharedInstance].player selectTrackWithTrackId:audioID];
    AnalyticEngine *engine = [[AnalyticEngine alloc]init];
    [engine audiolangChangeAnalyticsWith:self. CurrentAudioTrack newAudio:AudioTitle Mode:@"Online"];
}

-(void)setPlaybackRate:(NSString *)RateId Title:(NSString *)RateTitle
{
    self.selectedplaybackRate = RateTitle;
    float Value = [RateTitle floatValue];
    
    if (self.isOfflineContent == true) {
        [self.offlinePlayer setRate:Value];
           }
        else {
           [[Zee5PlayerPlugin sharedInstance].player setRate:Value];
           }
    
}

-(void)setSubTitle:(Zee5MenuModel *)model
{
    NSString *trackId = model.idValue;
    [[Zee5PlayerPlugin sharedInstance].player selectTrackWithTrackId:trackId];
    AnalyticEngine *engine = [[AnalyticEngine alloc]init];
    if ([self.CurrenttextTrack isEqualToString:@""]) {
        self.CurrenttextTrack = @"English";
    }
    [engine subtitlelangChangeAnalyticsWith:self.CurrenttextTrack newSubtitle:model.title Mode:@"Online"];
}



// Handle Available Tracks and Present Them

- (void)handleTracks {
    // don't forget to use weak self to prevent retain cycles when needed
    __weak __typeof(self) weakSelf = self;
    
    // add observer to tracksAvailable event
    [[Zee5PlayerPlugin sharedInstance].player addObserver:self events:@[PlayerEvent.tracksAvailable, PlayerEvent.textTrackChanged, PlayerEvent.audioTrackChanged] block:^(PKEvent * _Nonnull event) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
        if ([event isKindOfClass:PlayerEvent.tracksAvailable]) {
            
            // Extract Text Tracks
            if (event.tracks.textTracks)
            {
                strongSelf.textTracks = event.tracks.textTracks;
            }
            
            // Extract Audio Tracks
            if (event.tracks.audioTracks) {
                strongSelf.audioTracks = event.tracks.audioTracks;
                
                // Set Defualt array for Picker View
                strongSelf.selectedTracks = strongSelf.audioTracks;
            }
        }
        else if ([event isKindOfClass:PlayerEvent.textTrackChanged])
        {
            self.selectedSubtitle = event.selectedTrack.title;
            self.CurrenttextTrack = event.selectedTrack.title;
        }
        else if ([event isKindOfClass:PlayerEvent.audioTrackChanged])
        {
            self.CurrentAudioTrack = event.selectedTrack.title;
            [[AnalyticEngine shared]AudioLanguageWith:self.CurrentAudioTrack];
        }
    }];
}
-(void)GetAudioLanguage
{
    self.selectedString = LANGUAGE;

    [self prepareCustomMenu];

    NSMutableArray<Zee5MenuModel*> *models = [[NSMutableArray alloc] init];
    Zee5MenuModel *model2 = [[Zee5MenuModel alloc] init];
    model2.imageName = @"T";
    model2.title = LANGUAGE;
    model2.type = 1;
    model2.isSelected = false;
    [models addObject:model2];

    for (Track *track in self.audioTracks) {
        Zee5MenuModel *model = [[Zee5MenuModel alloc] init];
        if ([self.selectedLangauge isEqualToString:track.title])
        {
            model.imageName = @"t";
            model.isSelected = true;
        }
        else
        {
            model.imageName = @"";
            model.isSelected = false;
        }
        
        model.title = track.title;
        model.type = 2;
        model.idValue = track.id;
        [models addObject:model];
    }
    
    [_customMenu reloadDataWithObjects:models : true];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_customMenu];
    
}

-(void)showSubtitleActionSheet
{
    self.selectedString = SUBTITLES;
    [self prepareCustomMenu];

    NSMutableArray<Zee5MenuModel*> *models = [[NSMutableArray alloc] init];
    
    Zee5MenuModel *model1 = [[Zee5MenuModel alloc] init];
    model1.imageName = @"s";
    model1.title = SUBTITLES;
    model1.type = 1;
    model1.isSelected = false;
    [models addObject:model1];
    
    for (Track *track in self.textTracks)
    {
        Zee5MenuModel *model = [[Zee5MenuModel alloc] init];
        if ([self.selectedSubtitle isEqualToString:track.title]) {
            model.imageName = @"t";
            model.isSelected = true;
        }
        else
        {
            model.imageName = @"";
            model.isSelected = false;
        }

        model.title =  track.title;
        model.idValue = track.id;
        model.type = 2;
        [models addObject:model];
    }
    
    [_customMenu reloadDataWithObjects:models : true];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_customMenu];
}

-(void)GetPlayBackRate
{
    self.selectedString = PLAYBACKRATE;

    [self prepareCustomMenu];

    NSMutableArray<Zee5MenuModel*> *models = [[NSMutableArray alloc] init];
    Zee5MenuModel *model2 = [[Zee5MenuModel alloc] init];
    model2.imageName = @"s";
    model2.title = PLAYBACKRATE;
    model2.type = 1;
    model2.isSelected = false;
    [models addObject:model2];

    for (NSString *value in self.playBackRate) {
        Zee5MenuModel *model = [[Zee5MenuModel alloc] init];
        if ([self.selectedplaybackRate isEqualToString:value])
        {
            model.imageName = @"t";
            model.isSelected = true;
        }
        else
        {
            model.imageName = @"";
            model.isSelected = false;
        }
        
        model.title = value;
        model.type = 2;
        model.idValue = value;
        [models addObject:model];
    }
    
    [_customMenu reloadDataWithObjects:models : true];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_customMenu];
    
}

//MARK:-Prepare POP UP Views

-(void)prepareCustomMenu
{
    NSBundle *bundel = [NSBundle bundleForClass:self.class];

    if(_customMenu == nil)
    {
        _customMenu = [[bundel loadNibNamed:@"Zee5MenuView" owner:self options:nil] objectAtIndex:0];
    }
    else
    {
        [_customMenu removeFromSuperview];
    }
    
    CGRect widowFrame = [[[UIApplication sharedApplication] keyWindow] frame];
    _customMenu.frame = CGRectMake(0, 0, widowFrame.size.width, widowFrame.size.height);
    _customMenu.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}
-(void)DevicePopupShow
{
    [self hideLoaderOnPlayer];
    [self preparePopView];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_devicePopView];
    [[Zee5PlayerPlugin sharedInstance]ConvivaErrorCode:3602 platformCode:@"004" severityCode:1 andErrorMsg:@"Entitlement API Error -"];
}

-(void)preparePopView
{
    NSBundle *bundel = [NSBundle bundleForClass:self.class];
    
    if(_devicePopView == nil)
    {
        _devicePopView = [[bundel loadNibNamed:@"devicePopView" owner:self options:nil]objectAtIndex:0];
    }
    else
    {
        [_devicePopView removeFromSuperview];
         _devicePopView = nil;
    }
    
       CGRect windowFrame = [[[UIApplication sharedApplication] keyWindow] frame];
        _devicePopView.frame = windowFrame;
        _devicePopView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}
-(void)parentalControlshow
{
    [self prepareParentalView];
    [[Zee5PlayerPlugin sharedInstance]ConvivaErrorCode:1003 platformCode:@"012" severityCode:1 andErrorMsg:@"Parental Control Overlay"];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_parentalView];
    [[AnalyticEngine shared]PopUpLaunchWith:@"ParentalPopUp"];
}

-(void)prepareParentalView
{
    NSBundle *bundel = [NSBundle bundleForClass:self.class];
    
    if(_parentalView == nil)
    {
        _parentalView = [[bundel loadNibNamed:@"ParentalView" owner:self options:nil]objectAtIndex:0];
    }
    else
    {
        [_parentalView removeFromSuperview];
    }
    CGRect windowFrame = [[[UIApplication sharedApplication] keyWindow] frame];
    _parentalView.frame = windowFrame;
    _parentalView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    
}

-(void)parentalgesture:(BOOL)isKeypadShow
{
    if (isKeypadShow) {
        _parentalView.top_parentalView.constant = 100;
    }else{
         _parentalView.top_parentalView.constant = 0;
    }
    [UIView animateWithDuration:0.3 animations:^{
              [self.parentalView layoutIfNeeded];
          }];
    
}

-(void)checkParentalPin:(NSString *)Pin
{
    if(_parentalView != nil)
{
    [[AnalyticEngine shared]PopUpCTAPressedWith:@"Continue" POpUpCTAName:@"ParentalPopUp"];
    if ([Pin isEqualToString:self.parentalPin])
    {
       if (_parentalView.superview != nil)
            {
                [_parentalView removeFromSuperview];
                _parentalView = nil;
                if (_isParentalControlOffline == YES && self.parentalControl == NO) {
                _isParentalControlOffline = NO;
                    [self StartDownload];
                    return;
                }
                _parentalControl = NO;
                _allowVideoContent = YES;
                [self playWithCurrentItem];
                _customControlView.parentalDismissView.hidden = YES;
                
            }
            return;
        }else
        {
            [self ShowToastMessage:@"Incorrect PIN please try again"];
               [[Zee5PlayerPlugin sharedInstance]ConvivaErrorCode:1001 platformCode:@"008" severityCode:1 andErrorMsg:@"Parental Control Message -"];
        }
    }
    else
    {
   
    }
}
-(void)ParentalViewPlay{
    [self parentalControlshow];
   
}

//MARK:- Delete Device For User Login

-(void)deleteAllDevice:(NSString *)SenderAction
{
    if ([SenderAction isEqualToString:@"Cancel"])
    {
        switch (DeviceManager.getStateOfDevice)
        {
          case DeviceMaxout:
                [self DevicePopupShow];
                return;
                break;
          case DeviceAdded:
                [self postReloadCurrentContentIdNotification];
          default:
            break;
            };
        
        if(_devicePopView != nil)
        {
            if (_devicePopView.superview != nil)
            {
                [_devicePopView removeFromSuperview];
                 _devicePopView = nil;
                
            }
            return;
        }
        
    }
    else
    {
        [DeviceManager deleteDevice];
    }
}

-(void)moreOptions
{
    [self prepareCustomMenu];

    NSMutableArray<Zee5MenuModel*> *models = [[NSMutableArray alloc] init];
    if ([self.audioTracks count] > 1)
    {
        Zee5MenuModel *model1 = [[Zee5MenuModel alloc] init];
        model1.imageName = @"T";
        model1.title = LANGUAGE;
        model1.type = 1;
        model1.isSelected = false;
        [models addObject:model1];
    }
    
    if ([_currentItem.subTitles count] > 0)
    {
        Zee5MenuModel *model2 = [[Zee5MenuModel alloc] init];
        model2.imageName = @"s";
        model2.title = SUBTITLES;
        model2.type = 1;
        model2.isSelected = false;
        [models addObject:model2];
    }
    if ([_playBackRate count] > 0)
    {
        Zee5MenuModel *model3 = [[Zee5MenuModel alloc] init];
        model3.imageName = @"p";
        model3.title = PLAYBACKRATE;
        model3.type = 1;
        model3.isSelected = false;
        [models addObject:model3];
    }
    
    Zee5MenuModel *model4 = [[Zee5MenuModel alloc] init];
    model4.imageName = @"a";
    model4.title = WATCHLIST;
    model4.type = 1;
    model4.isSelected = false;
    [models addObject:model4];

    [_customMenu reloadDataWithObjects:models :false];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_customMenu];
}


-(void)selectedMenuItem:(id)model
{
    Zee5MenuModel *menuModel = (Zee5MenuModel *)model;
    if ([menuModel.title isEqualToString:LANGUAGE])
    {
        self.selectedString = menuModel.title;
        
        if (self.isOfflineContent == true) {
            [self showLangaugeSheetForOfflineContent];
        }
        else {
            [self showLangaugeActionSheet];
        }
    }
    else if ([menuModel.title isEqualToString: SUBTITLES])
    {
        self.selectedString = menuModel.title;
        
        if (self.isOfflineContent == true) {
            [self showSubtitleSheetForOfflineContent];
        }
        else {
            [self showSubtitleActionSheet];
        }
    }
    else if ([menuModel.title isEqualToString: PLAYBACKRATE])
    {
        self.selectedString = menuModel.title;
        
        if (self.isOfflineContent == true) {
            [self getPlayBackRateForOfflineContent];
        }
        else {
            [self GetPlayBackRate];
        }
    }
    else if ([menuModel.title isEqualToString:WATCHLIST])
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapOnAddToWatchList)])
        {
            [self.delegate didTapOnAddToWatchList];
        }
         [[AddToWatchlist Shared]AddToWatchlist:self.currentItem];  //// AddTWatchlist Api Call
          [self removeMenuView];
    }
    else if ([menuModel.title isEqualToString:AUTOPLAY] )
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapOnEnableAutoPlay)])
        {
            [self.delegate didTapOnEnableAutoPlay];
            
        }
    }
    else if([self.selectedString isEqualToString:LANGUAGE])
    {
        [self removeMenuView];
        
        if (self.isOfflineContent == true) {
            [self.offlinePlayer selectTrackWithTrackId: menuModel.idValue];
            self.selectedLangauge = menuModel.idValue;
        }
        else {
            [self setAudioTrack:menuModel.idValue Title:menuModel.title];
        }
        
        NSDictionary *dict = @{@"audioLanguage": menuModel.title};
        [self updateConvivaSessionWithMetadata: dict];
    }
    else if([self.selectedString isEqualToString:PLAYBACKRATE])
    {
        [self removeMenuView];
        self.selectedplaybackRate =menuModel.title;
        self.selectedplaybackRateOffline = menuModel.title;
        [self setPlaybackRate:menuModel.idValue Title:menuModel.title];
    }
    else if([self.selectedString isEqualToString:SUBTITLES] )
    {
        [self removeMenuView];
        self.selectedSubtitle = menuModel.title;
        
        if (self.isOfflineContent == true) {
            [self.offlinePlayer selectTrackWithTrackId: menuModel.idValue];
        }
        else {
            [self setSubTitle:menuModel];
        }
        
        NSString *str = [menuModel.title.lowercaseString containsString: @"off"] ? @"Off" : @"On";
        NSDictionary *dict = @{@"Subtitles": str};
        [self updateConvivaSessionWithMetadata: dict];
    }
    else
    {
        [self removeMenuView];
        
    }
}

-(void)HybridViewOpen {
    [self addHybridViewNotificationObservers];
    
    if (!_isHybridViewOpen) {
         _isHybridViewOpen = YES;
        
        [self hideLoaderOnPlayer];
        
        if ([Zee5PlayerPlugin sharedInstance].player.currentState != PlayerStateEnded) {
            [self pause];
        }
        
        [[ZEE5PlayerDeeplinkManager sharedMethod]NavigateHybridViewOpenWithCompletion:^(BOOL isSuccees) {
            if (isSuccees) {
                [self postReloadCurrentContentIdNotification];
            }
        }];
    }
}

- (void)addHybridViewNotificationObservers {
    [self removeHybridViewNotificationObservers];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSubscriptionFlowDismissNotification:) name:@"upgradePopupDissmiss" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSubscriptionFlowDismissNotification:) name:@"subscriptionFlowDismiss" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSubscriptionFlowDismissNotification:) name:@"sign_in_or_successfully" object:nil];
}

- (void)removeHybridViewNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"upgradePopupDissmiss" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"subscriptionFlowDismiss" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sign_in_or_successfully" object:nil];
}

-(void)handleSubscriptionFlowDismissNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"sign_in_or_successfully"] && self.isHybridViewOpen) {
        return;
    }
    
    self.isHybridViewOpen = NO;
    [self removeHybridViewNotificationObservers];

    BOOL hadAccess = !self.isNeedToSubscribe;
    BOOL hasAccess = [ZEE5PlayerSDK getUserTypeEnum] == Premium;
        
    if (!hadAccess && hasAccess && !_isRsVodUser) {
        [self resetControls];
        
        if (_ModelValues.isBeforeTv && self.TvShowModel.Episodes.count > 0) {
            NSString *beforeTvEpisodeId = self.TvShowModel.Episodes[1].episodeId;
            [self postContentIdShouldUpdateNotification:beforeTvEpisodeId];
        }
        else {
            [self postReloadCurrentContentIdNotification];
        }
    }
    else if ([Zee5PlayerPlugin sharedInstance].player.currentState != PlayerStateEnded && _customControlView.trailerEndView.hidden) {
         _isRsVodUser = NO;
        [self play];
    }
    else {
        [self hideUnHidetrailerEndView: NO];
    }
}

//MARK:- Remove All Present pop Views From Screen

-(void)removeSubview
{
    if (_devicePopView != nil){
        [_devicePopView removeFromSuperview];
        _devicePopView = nil;
    }else if (_parentalView != nil){
        if (self.isParentalControlOffline == TRUE && _parentalControl == false) {
            [_parentalView removeFromSuperview];
            _parentalView = nil;
            [self play];
            return;
        }

        [_parentalView removeFromSuperview];
        _parentalView = nil;
        _customControlView.parentalDismissView.hidden = YES;
        if (_parentalControl == YES) {
              _customControlView.parentalDismissView.hidden = NO;
          }
    }
}

//MARK:- Deeplink Manager Method.

-(void)tapOnSubscribeButton                  /// Navigate To Subscription Page
{
     [self stop];    ///*** Player Stop First Here***//
    
    if (_isLive==false){
        if (_ModelValues.isBeforeTv == true) {
             [[ZEE5PlayerDeeplinkManager sharedMethod]GetSubscrbtionWith:_ModelValues.assetType beforetv:true Param:@"Subscribe" completion:^(BOOL isSuccees) {
            if (isSuccees){
            [[ZEE5PlayerDeeplinkManager sharedMethod]fetchUserdata];
            [self postReloadCurrentContentIdNotification];
        }
    }];
            return;
        }
        [[ZEE5PlayerDeeplinkManager sharedMethod]GetSubscrbtionWith:_ModelValues.assetType beforetv:false Param:@"Subscribe" completion:^(BOOL isSuccees) {
                if (isSuccees) {
                [[ZEE5PlayerDeeplinkManager sharedMethod]fetchUserdata];
                [self postReloadCurrentContentIdNotification];
            }
                }];
        
    }else{
        [[ZEE5PlayerDeeplinkManager sharedMethod]GetSubscrbtionWith:_LiveModelValues.assetType beforetv:false Param:@"Subscribe" completion:^(BOOL isSuccees) {
            if (isSuccees) {
                [[ZEE5PlayerDeeplinkManager sharedMethod]fetchUserdata];
                [self postReloadCurrentContentIdNotification];
            }
        }];
    }

}
-(void)tapOnLoginButton                      /// Navigate To Login Screen
{
     [self stop];    ///*** Player Stop First Here***//
    [self removeSubview];
    [[ZEE5PlayerDeeplinkManager sharedMethod]NavigatetoLoginpageWithParam:@"Login" completion:^(BOOL isSuccees) {
        if (isSuccees) {
            [[ZEE5PlayerDeeplinkManager sharedMethod]fetchUserdata];
            [self postReloadCurrentContentIdNotification];
            //[self showLockedContentControls];
            
        }
    }];
    
}

-(void)airplayButtonClicked
{
//    [Zee5PlayerPlugin sharedInstance].player.
//    self.player.allowsExternalPlayback = true
//    self.player.usesExternalPlaybackWhileExternalScreenIsActive = true
//    let rect = CGRect(x: -100, y: 0, width: 0, height: 0)
//    let airplayVolume = MPVolumeView(frame: rect)
//    airplayVolume.showsVolumeSlider = false
//    self.view.addSubview(airplayVolume)
//    for view: UIView in airplayVolume.subviews {
//        if let button = view as? UIButton {
//            button.sendActions(for: .touchUpInside)
//            break
//        }
//    }
//    airplayVolume.removeFromSuperview()
}

-(void)showLangaugeActionSheet
{
    self.selectedString = LANGUAGE;

    [self prepareCustomMenu];

    NSMutableArray<Zee5MenuModel*> *models = [[NSMutableArray alloc] init];
    
    
    Zee5MenuModel *model2 = [[Zee5MenuModel alloc] init];
    model2.imageName = @"T";
    model2.title = LANGUAGE;
    model2.type = 1;
    model2.isSelected = false;
    [models addObject:model2];

    for (Track *track in self.audioTracks) {
        Zee5MenuModel *model = [[Zee5MenuModel alloc] init];
        if ([self.selectedLangauge isEqualToString:track.id]) {
            model.imageName = @"t";
            model.isSelected = true;
        }
        else {
            model.imageName = @"";
            model.isSelected = false;
        }
        model.title = track.title;
        model.type = 2;
        model.idValue = track.id;
        [models addObject:model];
    }
    
    [_customMenu reloadDataWithObjects:models : true];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_customMenu];
}

//MARK:- Content Details API

- (void)downloadVODContent:(NSString*)content_id country:(NSString*)country translation:(NSString*)laguage withCompletionHandler: (VODDataHandler)completionBlock {
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BaseUrls.vodContentDetails, content_id];
    
    NSDictionary *param =@{
        @"country":country,
        @"translation":laguage
    };
    
    NSDictionary *headers = @{
        @"Content-Type": @"application/json",
        @"X-Access-Token": ZEE5UserDefaults.getPlateFormToken
    };
    
    [[NetworkManager sharedInstance] makeHttpGetRequest:urlString requestParam:param requestHeaders:headers withCompletionHandler:^(id result) {
        VODContentDetailsDataModel *vodModel = [VODContentDetailsDataModel initFromJSONDictionary:result];
        
        if (vodModel.isDRM) {
            [[CdnHandler sharedInstance]getKCDNUrl:vodModel.identifier withCompletion:^(id  _Nullable result, NSString * _Nonnull CDN) {                
                [self getDRMToken:vodModel.identifier andDrmKey:vodModel.drmKeyID withCompletionHandler:^(id  _Nullable result) {
                    completionBlock(vodModel, [result valueForKey:@"drm"]);
                } failureBlock:^(ZEE5SdkError * _Nullable error) {
                    completionBlock(nil, nil);
                }];
            } andFailure:^(ZEE5SdkError * _Nullable error) {
            }];
        }
        else {
            completionBlock(nil, nil);
        }
    } failureBlock:^(ZEE5SdkError *error) {
//        if (error.zeeErrorCode == 101) {
//            [self setContentUnavailable];
//        }
        completionBlock(nil, nil);
    }];
}

- (void)setContentUnavailable {
    [self hideLoaderOnPlayer];
    
    self.isContentAvailable = NO;
    _customControlView.unavailableContentView.hidden = NO;
    
    [self hideUnHidetrailerEndView: YES];
}

- (void)playVODContentWithModel:(VODContentDetailsDataModel *)model {
    _watchCtreditSeconds = 10;
    _videoToken = @"";
    
    self.previousDuration = [[Zee5PlayerPlugin sharedInstance] getDuration];
    
    if (self.previousDuration != 0)
    {
        [self watchDuration:self.currentItem.content_id];
    }
    
    self.isLive = NO;
    _isContentAvailable = YES;
    _isStop = NO;
    _isHybridViewOpen = NO;
        
    [[AnalyticEngine shared] VideoStartTimeWith:0];
    [[AnalyticEngine shared] AudioLanguageWith:@""];
    [[AnalyticEngine shared]cleanupVideoSesssion];
    [self SliderReset];
    
    [ZEE5UserDefaults setContentId:model.identifier];
    
    [self registerNotifications];
    self.playerConfig = [[ZEE5PlayerConfig alloc] init];
    
    NSArray *array = [model.identifier componentsSeparatedByString:@"-"];
    NSString *contentType = array[1];
    
    [ZEE5UserDefaults setassetType:contentType];
    
    self.ModelValues = model;
    
    if ([self.ModelValues.watchCreditTime containsString:@"NULL"]== false) {
        self.watchCreditsTime = [[Utility secondsForTimeString:self.ModelValues.watchCreditTime]integerValue];
    }
    
    self.buisnessType = self.ModelValues.buisnessType;
    self.audioLanguageArr = self.ModelValues.audioLanguages;
    self.videoCompleted = false;
    
    [self getBusinessType];
    [self getskipandWatchcredit];
    [self getUserSettings];
    
    [self showloaderOnPlayer];
    
    if (self.ModelValues.isDRM) {
        [[CdnHandler sharedInstance] getKCDNUrl:self.ModelValues.identifier withCompletion:^(id  _Nullable result, NSString * _Nonnull CDN) {
            self.KcdnUrl = CDN;
            
            [self getDRMToken:self.ModelValues.identifier andDrmKey:self.ModelValues.drmKeyID withCompletionHandler:^(id  _Nullable result) {
                _videoToken = [result valueForKey:@"drm"];
                [self initilizePlayerWithVODContent:self.ModelValues andDRMToken:[result valueForKey:@"drm"]];
                
                // Update video end point
                NSTimeInterval vEndPoint = [[Zee5PlayerPlugin sharedInstance] getCurrentTime];
                NSString *videoEndPoint = [Utility stringFromTimeInterval: vEndPoint];
                
                NSDictionary *dict = @{@"videoEndPoint" : videoEndPoint};
                [self updateConvivaSessionWithMetadata: dict];
                [self stop];
                
            } failureBlock:^(ZEE5SdkError * _Nullable error) {
                [self notifiyError:error];
            }];
        } andFailure:^(ZEE5SdkError * _Nullable error) {
        }];
    }
    else {
        [self getVodToken:^(NSString *vodToken) {
            [self initilizePlayerWithVODContent:self.ModelValues andDRMToken:vodToken];
        }];
    }
}

- (void)playLiveContentWithModel:(LiveContentDetails *)model {
    _isStop = NO;
    _isHybridViewOpen = NO;
    _videoToken = @"";

    [[AnalyticEngine shared]VideoStartTimeWith:0];
    [[AnalyticEngine shared]AudioLanguageWith:@""];
    [[AnalyticEngine shared]cleanupVideoSesssion];
    [self SliderReset];
    
    [self registerNotifications];
    self.playerConfig = [[ZEE5PlayerConfig alloc] init];

    NSArray *array = [model.identifier componentsSeparatedByString:@"-"];
    NSString *contentType = array[1];
    
    [ZEE5UserDefaults setassetType:contentType];
    
    self.isLive = YES;
    
    self.LiveModelValues = model;
    self.buisnessType = self.LiveModelValues.buisnessType;
    self.audioLanguageArr = self.LiveModelValues.languages;
    self.showID = self.LiveModelValues.identifier;
    self.isStop = NO;
    self.videoCompleted = false;
    
    [self getBusinessType];
    
    [self getVideotoken:model.identifier andCountry:ZEE5UserDefaults.getCountry withCompletionhandler:^(id result) {
          self.videoToken = [result valueForKey:@"video_token"]; //// Fetch Video token here
        
        if (self.LiveModelValues.isDRM) {
            [self getDRMToken:self.LiveModelValues.identifier andDrmKey:self.LiveModelValues.drmKeyID withCompletionHandler:^(id  _Nullable result) {
                [self initilizePlayerWithLiveContent:self.LiveModelValues andDRMToken:[result valueForKey:@"drm"] VideoToken:self.videoToken];
            } failureBlock:^(ZEE5SdkError * _Nullable error) {
                [self notifiyError:error];
            }];
        }
        else {
            [self initilizePlayerWithLiveContent:self.LiveModelValues andDRMToken:@"" VideoToken:self.videoToken];
        }
    } faillureblock:^(ZEE5SdkError *error) {
        [self initilizePlayerWithLiveContent:self.LiveModelValues andDRMToken:@"" VideoToken:@""];
    }];
}

- (void)setPlaybackView:(UIView *)playbackView {
    self.parentPlaybackView = playbackView;
    [self addCustomControls];
}

-(void)getVodToken:(void (^)(NSString *))completion
{
    [[NetworkManager sharedInstance]makeHttpGetRequest:BaseUrls.getVodToken requestParam:@{} requestHeaders:@{} withCompletionHandler:^(id  _Nullable result) {
        if ([result isKindOfClass:[NSDictionary class]]) {
        
        completion(result[@"video_token"]);
        }
    } failureBlock:^(ZEE5SdkError * _Nullable error) {
        
    }];

}

-(void)setOneTrustValue:(NSDictionary *)oneDict {
    _oneTrustDict = [oneDict mutableCopy];
}
// MARK:- Download Ad Config

-(void)downLoadAddConfig:(SuccessHandler)success failureBlock:(FailureHandler)failure
{
    NSString * Bundleversion = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSDictionary *param = @{@"content_id":_currentItem.content_id ,@"platform_name":@"apple_app",@"user_type":[ZEE5UserDefaults getUserType],@"country":ZEE5UserDefaults.getCountry,@"state":ZEE5UserDefaults.getState,@"app_version":Bundleversion,@"audio_language":ZEE5UserDefaults.gettranslation};
    NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithDictionary:param];
   
    if (_oneTrustDict != nil) {
        
        [params addEntriesFromDictionary:_oneTrustDict];
        _oneTrustDict = nil;
    }
    
    [[NetworkManager sharedInstance] makeHttpGetRequest:BaseUrls.adConfig requestParam:params requestHeaders:@{} withCompletionHandler:^(id  _Nullable result)
    {
   
        NSMutableArray <ZEE5AdModel*>*fanAdModelArray = [[NSMutableArray alloc] init];
        NSMutableArray <ZEE5AdModel*>*googleAdModelArray = [[NSMutableArray alloc] init];
        
        NSArray *videoAds = [result ValueForKeyWithNullChecking:@"video_ads"];
        NSArray *coAds = [result ValueForKeyWithNullChecking:@"companion_ads"];
        if (coAds.count > 0) {
            self.companionAds = coAds;
            [[NSNotificationCenter defaultCenter]removeObserver:self name:@"CompanionAds" object:nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"CompanionAds" object:nil];
        }
       
        if([videoAds count] > 0 && self.isLive == false)
        {
            
            for (NSDictionary *insideDict in videoAds) {
                for (NSDictionary *adDict in [insideDict ValueForKeyWithNullChecking:@"intervals"]) {
                    ZEE5AdModel *adModel = [ZEE5AdModel initFromJSONDictionary:adDict];
                    if ([adModel.tag containsString:@"http"])
                    {
                        [googleAdModelArray addObject:adModel];
                        
                    }
                    else
                    {
                        [fanAdModelArray addObject:adModel];
                    }
                }
            }
            
        }
        
        
        self.currentItem.fanAds =  fanAdModelArray;
        self.currentItem.googleAds =  googleAdModelArray;
        
        if ([result isKindOfClass:[NSDictionary class]])
        {
            success(result);
        }
        
    } failureBlock:^(ZEE5SdkError * _Nullable error)
     {
        failure(error);
    }];
}

-(NSArray *)getComanionAds{
    return self.companionAds;
}

-(ContentBuisnessType)getBusinessType
{
    if ([_buisnessType isEqualToString:@"premium"])
    {
        buisnessType = premium;
    }else if ([_buisnessType isEqualToString:@"premium_downloadable"])
    {
        buisnessType = premium_downloadable;
    }else if ([_buisnessType isEqualToString:@"advertisement"])
    {
        buisnessType = advertisement;
    }else if ([_buisnessType isEqualToString:@"advertisement_downloadable"])
    {
        buisnessType = advertisement_downloadable;
    }else
    {
        buisnessType = free_downloadable;
    }
    return buisnessType;
}

//MARK:- Watch Credit, Skip intro, Fetch Data.

-(void)getskipandWatchcredit
{
    self.watchCreditsTime = _ModelValues.duration - self.watchCreditsTime;
    
    self.currentItem.WatchCredit =NO;
    
    self.startIntroTime = [[Utility secondsForTimeString:self.ModelValues.introStarttime]integerValue];
    self.endIntroTime =  [[Utility secondsForTimeString:self.ModelValues.introEndTime]integerValue];
}

// MARK:- Set Current Item Data(url,drmToken,Title)

- (void)initilizePlayerWithVODContent:(VODContentDetailsDataModel*)model andDRMToken:(NSString*)token
{
    self.currentItem = [[CurrentItem alloc] init];
    if (model.isDRM)
    {
        self.currentItem.hls_Url = [self.KcdnUrl stringByAppendingString:model.hlsUrl];
    }else{
        self.currentItem.hls_Url = [model.hlsUrl stringByAppendingString:token];
    }
    
    if (![self.currentItem.hls_Url containsString:@"https://"])
    {
        self.currentItem.hls_Url = [self.currentItem.hls_Url stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
    }
    
    if ([model.mpdUrl containsString:@"mpd"])
    {
        self.currentItem.mpd_Url = [self.KcdnUrl stringByAppendingString:model.mpdUrl] ;
    }

    self.currentItem.drm_token = token;
    self.currentItem.drm_key = model.drmKeyID;
    self.currentItem.subTitles = model.subtitleLanguages;
    self.currentItem.streamType = CONVIVA_STREAM_VOD;
    self.currentItem.content_id = model.identifier;
    self.currentItem.channel_Name = model.title;
    self.currentItem.asset_type = model.assetType;
    self.currentItem.asset_subtype = model.assetSubtype;
    self.currentItem.release_date = model.releaseDate;
    self.currentItem.episode_number = model.episodeNumber;
    self.currentItem.originalTitle = model.showOriginalTitle;
    self.currentItem.duration = model.duration;
    self.currentItem.imageUrl = model.imageUrl;
    self.currentItem.TvShowImgurl = model.tvShowimgurl;
    self.currentItem.info = model.contentDescription;
    self.currentItem.geners = model.geners;
    self.currentItem.isDRM = model.isDRM;
    self.currentItem.audioLanguages =model.audioLanguages;
    self.currentItem.charecters = model.charecters;
    self.currentItem.skipintrotime = model.introStarttime;
    self.currentItem.ageRate = model.ageRating;
    self.currentItem.business_type = model.buisnessType;
    self.currentItem.language = model.Languages;
    self.currentItem.SeasonId = model.SeasonId;
    self.currentItem.showId = model.tvShowId;
    self.currentItem.Showasset_subtype = model.tvShowAssetSubtype;
    self.currentItem.showchannelName = model.tvShowChannelname;
    self.currentItem.vttThumbnailsUrl = model.vttThumbnailsUrl;
    
    [self updateControlsForCurrentItem];
    [[AnalyticEngine shared]CurrentItemDataWith:self.currentItem];
    [self CreateConvivaSession];
    
    [self downLoadAddConfig:^(id result) {
        void (^playContent)(void) = ^() {
            [self perfromPlaybackActionForCurrentUserSubscription];
        };
        
        if (ZEE5PlayerSDK.getConsumpruionType == Episode || ZEE5PlayerSDK.getConsumpruionType == Original) {
            [self getNextEpisode:^{
                playContent();
            }];
        }
        else {
            [self getVodSimilarContent:^{
                playContent();
            }];
        }
    } failureBlock:^(ZEE5SdkError *error) {
        [self perfromPlaybackActionForCurrentUserSubscription];
    }];
}



-(void)CreateConvivaSession{
       [self createConvivaSeesionWithMetadata];
}
// MARK:- Set Current Item For Live Data(url,drmToken,Title)

- (void)initilizePlayerWithLiveContent:(LiveContentDetails*)Livemodel andDRMToken:(NSString*)token VideoToken:(NSString*)Vidtoken
{
    self.currentItem = [[CurrentItem alloc] init];
    self.currentItem.hls_Url = [Livemodel.StreamhlsUrl stringByAppendingString:Vidtoken];

    self.currentItem.originalTitle =Livemodel.showOriginalTitle;
    self.currentItem.drm_token = token;
    self.currentItem.drm_key = Livemodel.drmKeyID;
    self.currentItem.subTitles = Livemodel.subtitleLanguages;
    self.currentItem.streamType = CONVIVA_STREAM_LIVE;
    self.currentItem.content_id = Livemodel.identifier;
    self.currentItem.channel_Name = Livemodel.title;
    self.currentItem.showName =Livemodel.showOriginalTitle;
    self.currentItem.asset_type = Livemodel.assetType;
    self.currentItem.geners = Livemodel.geners;
    self.currentItem.isDRM = Livemodel.isDRM;
    self.currentItem.audioLanguages = Livemodel.languages;
    self.currentItem.business_type = Livemodel.buisnessType;
    self.currentItem.language = Livemodel.languages;
    self.currentItem.showchannelName = Livemodel.showOriginalTitle;
    self.currentItem.geners = Livemodel.geners;
    self.currentItem.imageUrl = [NSString stringWithFormat:@"https://akamaividz.zee5.com/resources/%@/list/270x152/%@",Livemodel.identifier,Livemodel.Image];
    
    [self updateControlsForCurrentItem];
    [[AnalyticEngine shared] CurrentItemDataWith:self.currentItem];
    [self CreateConvivaSession];

    [self downLoadAddConfig:^(id result) {
        [self perfromPlaybackActionForCurrentUserSubscription];

    } failureBlock:^(ZEE5SdkError *error) {
        [self perfromPlaybackActionForCurrentUserSubscription];
    }];
}


//MARK:- Meta data for Conviva Analytics.

- (void)createConvivaSeesionWithMetadata
{
    NSString *stremType = @"Unknown";
    NSString *isLive = @"false";
    NSString *userId = ZEE5PlayerSDK.getUserId ;
         if (ZEE5PlayerSDK.getUserTypeEnum == Guest) {
             userId = ZEE5UserDefaults.getUserToken;
         }
    
    if (!_isLive) {
        stremType = @"Vod";
        isLive = @"false";
    }else {
        stremType = @"Live";
        isLive = @"true";
    }
    
    NSDictionary *dict = [[NSDictionary alloc] init];
    dict = @{
             @"assetName": _isLive ? _LiveModelValues.title: _ModelValues.title,
             @"applicationName": Conviva_Application_Name,
             @"streamType": stremType,
             @"streamUrl": _isLive ? [self getLiveUrl]: [self getVodUrl],
             
             @"isLive": isLive,
             @"playerName": Conviva_Player_name,
             @"viewerId": userId,
             @"duration":_isLive ? @"0": [NSString stringWithFormat:@"%ld",_ModelValues.duration],
             };
 
    [[AnalyticEngine shared] setupConvivaSessionWith:dict];
}
-(NSString *)getVodUrl
{
    NSString * contentUrl;
    if (_ModelValues.isDRM){
        contentUrl = [self.KcdnUrl stringByAppendingString:_ModelValues.hlsUrl];
    }else{
        contentUrl = [_ModelValues.hlsUrl stringByAppendingString:_videoToken];
    }
    if (![ contentUrl containsString:@"https://"]){
        contentUrl = [contentUrl stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
    }
    return contentUrl;
}
-(NSString *)getLiveUrl{
     NSString * contentUrl;
     contentUrl = [_LiveModelValues.StreamhlsUrl stringByAppendingString:_videoToken];
     return contentUrl;
}

// MARK:- Meta Data For ComScore Analytics.

-(void)comScoreMetadata
{
    NSString *stremType = @"Unknown";
    NSString *isLive = @"false";
    
    NSString *userId = ZEE5PlayerSDK.getUserId ;
      if (ZEE5PlayerSDK.getUserTypeEnum == Guest) {
          userId = ZEE5UserDefaults.getUserToken;
      }
    
    if (self.currentItem.streamType == CONVIVA_STREAM_VOD) {
        stremType = @"Vod";
        isLive = @"false";
    }
    else if (self.currentItem.streamType == CONVIVA_STREAM_LIVE) {
        stremType = @"Live";
        isLive = @"true";
    }
    
    NSDictionary *dict = [[NSDictionary alloc] init];
    
    dict = @{
             @"assetName": self.currentItem.channel_Name ?: [NSNull null],
             @"applicationName": Conviva_Application_Name,
             @"streamType": stremType,
             @"streamUrl": self.currentItem.hls_Url ?: [NSNull null],
             
             @"isLive": isLive,
             @"playerName": Conviva_Player_name,
             @"viewerId": userId
             };
     [SCORAnalytics notifyViewEventWithLabels:dict];
}
-(void)setupMetadataWithContent:(CurrentItem *)item
{
    NSDictionary *dict;

    NSString *userId = ZEE5PlayerSDK.getUserId ;
    
    if (ZEE5PlayerSDK.getUserTypeEnum == Guest) {
        userId = ZEE5UserDefaults.getUserToken;
    }
    NSString *buildNumber = ZEE5PlayerSDK.getPlayerSDKVersion;
    NSString *genres = [Utility getCommaSaperatedGenreList: self.currentItem.geners];
    NSString *releaseDate = [Utility convertDateFormat: self.currentItem.release_date toDateFormat:@"MMM d, yyyy"];
    NSString *networkName = [Utility getCellularNetworkOperator];
    NSString *connectionType = [Utility getNetworkConnectionType];
    
    NSTimeInterval startPoint = [[Zee5PlayerPlugin sharedInstance] getCurrentTime];
    NSString *videoStartPoint = [Utility stringFromTimeInterval: startPoint];
    NSString *Affiliate = @"Zee Entertainment Enterprises Ltd";
    if (_isTelco) {
        if ([self.customControlView.partnerLblTxt.text containsString:@"vodafone"]) {
            Affiliate = @"Vodafone";
        }else if ([self.customControlView.partnerLblTxt.text containsString:@"airtel"]){
              Affiliate = @"Airtel";
        }else if ([self.customControlView.partnerLblTxt.text containsString:@"idea"]){
              Affiliate = @"Idea";
        }else{
              Affiliate = @"NA";
        }
    }
    NSString *AutoPlay = @"False";
    if (_isAutoplay) {
        AutoPlay = @"True";
    }
    
    NSString *BeforeTv = @"Y";
    if (_ModelValues.isBeforeTv || _isLive) {
        BeforeTv = @"N";
    }
    NSMutableArray *LanguageArr = [[NSMutableArray alloc]init];
    NSString *LanguageStr;
    for (NSString *language in item.language) {
       NSString *lan = [Utility getLanguageStringFromId:language];
        [LanguageArr addObject:lan];
    }
    if (LanguageArr .count >0) {
        LanguageStr = [LanguageArr componentsJoinedByString:@"'"];
    }
    
    NSString *NA = @"NA";
    
    dict = @{
             @"viewerId": userId,
             @"episodeName": item.channel_Name?: NA,
             @"category": item.asset_subtype?: NA,
             @"channel": item.channel_Name?: NA,
             
             @"contentID": item.content_id?: NA,
             @"ContentType": item.asset_subtype?: NA,
             @"genre": genres?: NA,
             @"pubDate": releaseDate?: NA,
             
             @"season": [NSNumber numberWithInteger:item.episode_number]?: NA,
             @"show": item.showName?: NA,
             @"playerVersion": buildNumber,
             
             @"carrier": networkName?: NA,
             @"connectionType": connectionType?: NA,
             
             @"accessType": [ZEE5UserDefaults getUserType]?:NA,
             @"viewerAge": NA,
             @"viewerGender": NA,
             
             @"autoplay": AutoPlay,  // "False"
             @"videoStartPoint": videoStartPoint,
             @"playbackQuality": @"Auto",
             @"originalLanguage": LanguageStr?:NA,
             
             @"isan": NA,
             @"rootID": item.content_id,
             @"site": @"zee5.com",
             @"tmsID": NA,
             @"adID": [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString],
             
             @"affiliate": Affiliate?:NA,
             @"streamingProtocol": @"HLS",
             @"platformName":@"IOS",
             @"catchUp":BeforeTv
             };
    
    [self updateConvivaSessionWithMetadata: dict];
    
}

-(void)updateConvivaSessionWithMetadata:(NSDictionary *)dict
{
    [[AnalyticEngine shared] updateMetadataWith:dict];

}

//MARK:- Similar Content For Playback

- (void)getVodSimilarContent:(void (^)(void))completion {
    NSString *contentId = self.currentItem.content_id;

    NSDictionary *param = @{
        @"user_type": ZEE5UserDefaults.getUserType,
        @"page":@"1",
        @"limit":@"25",
        @"translation":ZEE5UserDefaults.gettranslation,
        @"country":ZEE5UserDefaults.getCountry,
        @"languages":[self.currentItem.audioLanguages componentsJoinedByString:@","]
    };
    
    NSDictionary *headers = @{
        @"Content-Type": @"application/json",
        @"X-Access-Token": ZEE5UserDefaults.getPlateFormToken,
        @"Cache-Control":@"no-cache"
    };
    
    [[NetworkManager sharedInstance] makeHttpGetRequest:[NSString stringWithFormat:@"%@/%@", BaseUrls.vodSimilarContent, contentId] requestParam:param requestHeaders:headers withCompletionHandler:^(id  _Nullable result) {
        if (![self.currentItem.content_id isEqualToString:contentId]) {
            return;
        }
        
        SimilarDataModel *model = [SimilarDataModel initFromJSONDictionary:result];
        self.currentItem.related = model.relatedVideos;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kRefreshRelatedVideoList" object:nil];
        
        completion();
    } failureBlock:^(ZEE5SdkError * _Nullable error) {
        completion();
    }];
}

//MARK:- NextEpisode

- (void)getNextEpisode:(void (^)(void))completion {
    NSString *contentId = self.currentItem.content_id;

    NSDictionary *param = @{
        @"episode_id": contentId,
        @"page":@"1",
        @"limit":@"10",
        @"translation":ZEE5UserDefaults.gettranslation,
        @"country":ZEE5UserDefaults.getCountry,
        @"type":@"next"
    };
    
    NSDictionary *headers = @{
        @"Content-Type": @"application/json",
        @"X-Access-Token": ZEE5UserDefaults.getPlateFormToken,
        @"Cache-Control":@"no-cache"
    };
    
    [[NetworkManager sharedInstance] makeHttpGetRequest:[NSString stringWithFormat:@"%@/%@",BaseUrls.getNextContent,self.ModelValues.SeasonId] requestParam:param requestHeaders:headers withCompletionHandler:^(id  _Nullable result) {
        if (![self.currentItem.content_id isEqualToString:contentId]) {
            return;
        }
        
        SimilarDataModel *model = [SimilarDataModel initFromJSONDictionary:result];
        self.currentItem.related = model.relatedVideos;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kRefreshRelatedVideoList" object:nil];
        
        completion();
    } failureBlock:^(ZEE5SdkError * _Nullable error) {
        completion();
    }];
}

// MARK:- Get Subscription Data  and Logic For PopUps.

- (ZeeUserPlaybackAction)playbackActionForCurrentUser {
    ContentBuisnessType businessType = buisnessType;
    BOOL isPremiumItem = businessType == premium || businessType == premium_downloadable;
    
    if (ZEE5PlayerSDK.getUserTypeEnum == Premium || self.isLive || !isPremiumItem) {
        return ZeeUserPlaybackActionPlay;
    }
    
    NSString *subscriptionData = [ZEE5UserDefaults getSubscribedPack];
    if ([subscriptionData isKindOfClass:[NSNull class]] || subscriptionData.length == 0 || [subscriptionData isEqualToString:@"[]"]) {
        return ZeeUserPlaybackActionTrailer;
    }
    
    NSArray *jsonSubscriptions = [NSJSONSerialization JSONObjectWithData:[subscriptionData dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    for (NSDictionary *jsonSubscription in jsonSubscriptions) {
        SubscriptionModel *subscription = [[SubscriptionModel alloc] initWithDictionary:jsonSubscription];
        
        if (!subscription.isSubscriptionActive) {
            continue;
        }
        
        if (subscription.subscriptionPlan.channelAudioLanguages.count == 0) {
            self.isNeedToSubscribe = NO;
            return ZeeUserPlaybackActionPlay;
        }
        else {
            id matchingAudioLanguage = [subscription.subscriptionPlan.channelAudioLanguages firstObjectCommonWithArray:self.audioLanguageArr];
            if (matchingAudioLanguage != nil) {
                self.isNeedToSubscribe = NO;
                return ZeeUserPlaybackActionPlay;
            }
        }
    }
    
    return ZeeUserPlaybackActionIgnore;
}

- (void)perfromPlaybackActionForCurrentUserSubscription {
    switch ([self playbackActionForCurrentUser]) {
        case ZeeUserPlaybackActionPlay:
            self.allowVideoContent = YES;
            [self playWithCurrentItem];
            break;
            
        case ZeeUserPlaybackActionTrailer:
            self.allowVideoContent = YES;
            [self playTrailer];
            break;
            
        default:
            break;
    }
}

//MARK:- Play Trailer Method (Check Tv Show AssetType or Vod AssetType);

-(void)playTrailer
{
    _isNeedToSubscribe = YES;
    if (ZEE5PlayerSDK.getUserTypeEnum == Premium) {
        _isRsVodUser = YES;
    }
    if (!_isLive && self.ModelValues.trailerIdentifier != nil) {
        [self postContentIdShouldUpdateNotification: self.ModelValues.trailerIdentifier];
    }
    else if (self.TvShowModel.TrailersContentid != nil && (ZEE5PlayerSDK.getConsumpruionType == Episode || ZEE5PlayerSDK.getConsumpruionType == Original) && !_ModelValues.isBeforeTv) {
        [self postContentIdShouldUpdateNotification: self.TvShowModel.TrailersContentid];
    }
    else {
        [self CreateConvivaSession];
        if (_ModelValues.isBeforeTv) {
        [[Zee5PlayerPlugin sharedInstance]ConvivaErrorCode:3803 platformCode:@"006" severityCode:0 andErrorMsg:@"Before TV Popup"];
            [self HybridViewOpen];
        }
        if (_isLive) {
             [[Zee5PlayerPlugin sharedInstance]ConvivaErrorCode:3803 platformCode:@"007" severityCode:0 andErrorMsg:@"Premium Playback Failure"];
        }
        
        [self showLockedContentControls];
    }
}

//MARK:- Get User Setting

-(void)getUserSettings{
    

      NSString *result = [ZEE5UserDefaults getUserSetting];
    if ([result isKindOfClass:[NSNull class]] || result.length == 0) {
        return;
    }
      NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
      id _Nullable resultData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
      userSettingDataModel *settingModel = [userSettingDataModel initFromJSONDictionary:resultData];
    
      if (ZEE5PlayerSDK.getUserTypeEnum == Guest)
      {
          self.parentalControl = NO;
          self.isParentalControlOffline = NO;
          if ([settingModel.autoPlay isEqualToString:@"true"]) {
              _isAutoplay = true;
          }
          return;
      }
        self.ageRating =settingModel.ageRating;
        self.parentalPin = settingModel.userPin;
    _isAutoplay = false;
    _isStreamoverWifi = false;
    _isdownloadOverWifi = false;
    
    if ([settingModel.autoPlay isEqualToString:@"true"]) {
        _isAutoplay = true;
    }
    
    if ([settingModel.streamOverWifi isEqualToString:@"true"]) {
           _isStreamoverWifi = true;
       }
    if ([settingModel.downloadOverWifi isEqualToString:@"true"]) {
        _isdownloadOverWifi = true;
    }
        
    [self CheckParentalControl];
}
//MARK:- Check Parental control Logic

-(void)CheckParentalControl{
    if ( self.ageRating == nil || self.ageRating.length==0)
    {
        self.parentalControl = NO;
        self.isParentalControlOffline = NO;
        
    }
    else if ([self.ageRating isEqualToString:@"A"] ){
        if ([self.ModelValues.ageRating isEqualToString:@"A"])
        {
            self.parentalControl = YES;
           self.isParentalControlOffline = YES;
        }else{
            self.parentalControl = NO;
            self.isParentalControlOffline = NO;
        }
    }
    else if ([self.ageRating isEqualToString:@"UA"])
    {
        if ([self.ModelValues.ageRating isEqualToString:@"U"])
        {
             self.parentalControl = NO;
            self.isParentalControlOffline = NO;
        }
        else
        {
             self.parentalControl = YES;
            self.isParentalControlOffline = YES;
        }
    }
    else
    {
      self.parentalControl = YES;
      self.isParentalControlOffline = YES;
    }
}


// MARK:- Get Video Token For Live Only

-(void)getVideotoken:(NSString*)content_Id andCountry:(NSString*)Country  withCompletionhandler:(SuccessHandler)sucess faillureblock:(FailureHandler)failure
{
    
    NSString *idfaString = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
      NSString *userToken = [NSString stringWithFormat:@"%@", ZEE5UserDefaults.getUserToken];
      NSDictionary *headers = @{@"Content-Type":@"application/json",@"Authorization":userToken};
    
    
    NSDictionary *param =@{@"channel_id":content_Id,
                           @"country":Country,
                           @"device_id":idfaString
                              };
    
    [[NetworkManager sharedInstance]makeHttpGetRequest:BaseUrls.videoTokenApi requestParam:param requestHeaders:headers withCompletionHandler:^(id  _Nullable result)
     {
       
        if ([result isKindOfClass:[NSDictionary class]])
        {
            sucess(result);
        }
        
    } failureBlock:^(ZEE5SdkError * _Nullable error)
     {
        if (error.zeeErrorCode == 3608)
        {
            [self CreateConvivaSession];
            [DeviceManager addDevice];
        }else if (error.zeeErrorCode == 3602){
            [self CreateConvivaSession];
            [self DevicePopupShow];
        }
        if (error.zeeErrorCode == 3803 || error.zeeErrorCode == 3804) {
            [self playTrailer];
        }
    }];
}

//MARK:- Get DRM Token For Player

- (void)getDRMToken:(NSString*)content_id andDrmKey:(NSString*)drmKey  withCompletionHandler:(SuccessHandler)success failureBlock:(FailureHandler)failure
{
    
    NSString *idfaString = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    //check if there are "bearer " and "Bearer " substrings in the token string and remove it
    
    NSString *Token = [[[ZEE5UserDefaults getUserToken] stringByReplacingOccurrencesOfString:@"bearer " withString:@""] stringByReplacingOccurrencesOfString:@"Bearer " withString:@""];

    NSDictionary *parameterList = @{@"country":ZEE5UserDefaults.getCountry,
                                    @"persistent":@"false",
                                    @"key_id":drmKey,
                                    @"asset_id":content_id,
                                    @"token":Token,
                                    @"entitlement_provider":@"internal",
                                    @"device_id":idfaString,
                                    @"request_type":@"Drm",
                                    };
    NSDictionary *headers = @{@"Content-Type":@"application/json"};
    
    [[NetworkManager sharedInstance] makeHttpRequest:@"POST" requestUrl:BaseUrls.entitlementV4 requestParam:parameterList requestHeaders:headers  withCompletionHandler:^(id  _Nullable result)
    {
        if ([result isKindOfClass:[NSDictionary class]])
        {
            success(result);
        }
        
    } failureBlock:^(ZEE5SdkError * _Nullable error)
     {
        [self notifiyError:error];
        if (error.zeeErrorCode == 3608)
        {
            [self CreateConvivaSession];
            [DeviceManager addDevice];
        }
        else if (error.zeeErrorCode == 3602)
        {
            [self CreateConvivaSession];
            [self DevicePopupShow];
        }
        else if (error.zeeErrorCode == 3803 || error.zeeErrorCode == 3804)
        {
            [self playTrailer];
        }
        else
        {
            [self playTrailer];
        }
        failure(error);
    }];
}

- (void)notifiyError:(ZEE5SdkError*)error{
    
    if ([self.delegate respondsToSelector:@selector(didFinishWithError:)]) {
        [self.delegate didFinishWithError:error];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    UIView *v = touch.view;
    
    if (v == _customControlView.btnMinimize ||
        ([v isDescendantOfView:_customControlView] && [v isKindOfClass:[UIButton class]]) ||
        [touch.view isDescendantOfView:_customControlView.collectionView] ||
        [touch.view isDescendantOfView:_customControlView.sliderDuration] ||
        [touch.view isDescendantOfView:_customControlView.sliderLive] ||
        [touch.view isDescendantOfView:_customMenu.tblView]) {

        return NO;
    }
    
    return YES;
}

#pragma mark: GA Events

-(void)watchDuration:(NSString *)content_id
{
    
    NSDictionary *requestParams = @{
                                    @"cd48": content_id ? content_id : @"",
                                    @"cm5": [NSString stringWithFormat:@"%f",self.previousDuration],
                                    };
    
    [[ReportingManager sharedInstance] gaEventManager:requestParams];
    
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
    
    //
    self.isOfflineContent = false;
    self.selectedString = @"";
}


//MARK:-  Download Start Method
-(void)StartDownload
{
    if (ZEE5PlayerSDK.getUserTypeEnum == Guest) {
        
        [self pause];
        [[ZEE5PlayerDeeplinkManager sharedMethod]NavigatetoLoginpageWithParam:@"Download" completion:^(BOOL isSuccess) {
            if (isSuccess) {
                [[ZEE5PlayerDeeplinkManager sharedMethod]fetchUserdata];
                [self postReloadCurrentContentIdNotification];
            }
        }];
        return;
    }
    
    if (self.currentItem == nil ) {
        return;
    }
    
//    if (ZEE5PlayerSDK.getConsumpruionType == Trailer && ZEE5PlayerSDK.getUserTypeEnum == Premium == false) {
//        [self pause];
//        [self HybridViewOpen];
//        return;
//    }
    if (_isNeedToSubscribe && ZEE5PlayerSDK.getConsumpruionType != Trailer ) {
         [self pause];
         [self HybridViewOpen];
          return;
    }
    
    if (_isdownloadOverWifi == true && ZEE5PlayerSDK.Getconnectiontype == Mobile) {
        [self ShowToastMessage:@"WiFi is not connected! You have selected download over WiFi only"];
        return;
    }
    
    if (self.isParentalControlOffline ==YES)
    {
         [self pause];
      [self parentalControlshow];
        self.parentalControl = NO;
      return;
    }
    
   [[AnalyticEngine shared]DownloadCTAClicked];
   [[DownloadHelper shared] startDownloadItemWith:self.currentItem];
}

//MARK:- Telco User checked;

-(void)Telcouser:(BOOL)istelco param:(NSString *)Message{
    _isTelco = istelco;
    _TelcoMsg = [NSString stringWithFormat:@"< %@",Message];
}

// MARK:- Offline content Methods

-(void)moreOptionForOfflineContentAudio:(NSArray<Track*>*)audio text:(NSArray<Track*>*)texts withPlayer:(id<Player>)player
{
    [self prepareCustomMenu];
    
    /************************************/
     /////  Array of Playeback Rate For Offline
     /***********************************/
     NSArray * Rate = [[NSArray alloc]initWithObjects:@"0.5X",@"1X",@"1.5X",@"2X",@"2.5X",@"3X", nil];
     
     self.playBackRate = Rate;
    
    NSMutableArray<Zee5MenuModel*> *models = [[NSMutableArray alloc] init];
    
    self.isOfflineContent = true;
    self.offlinePlayer = player;
    
    if (audio.count > 0) {
        self.offlineLanguageTracks = audio;
        
        Zee5MenuModel *model1 = [[Zee5MenuModel alloc] init];
        model1.imageName = @"T";
        model1.title = LANGUAGE;
        model1.type = 1;
        model1.isSelected = false;
        [models addObject:model1];
    }
    
    if (texts.count > 0) {
        self.offlineTextTracks = texts;
        
        Zee5MenuModel *model2 = [[Zee5MenuModel alloc] init];
        model2.imageName = @"s";
        model2.title = SUBTITLES;
        model2.type = 1;
        model2.isSelected = false;
        [models addObject:model2];
    }
    if (_playBackRate.count > 0) {
        
        Zee5MenuModel *model3 = [[Zee5MenuModel alloc] init];
        model3.imageName = @"p";
        model3.title = PLAYBACKRATE;
        model3.type = 1;
        model3.isSelected = false;
        [models addObject:model3];
    }

    [_customMenu reloadDataWithObjects:models :false];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_customMenu];
}

-(void)showSubtitleSheetForOfflineContent
{
    self.selectedString = SUBTITLES;
    [self prepareCustomMenu];
    
    NSMutableArray<Zee5MenuModel*> *models = [[NSMutableArray alloc] init];
    
    Zee5MenuModel *model1 = [[Zee5MenuModel alloc] init];
    model1.imageName = @"s";
    model1.title = SUBTITLES;
    model1.type = 1;
    model1.isSelected = false;
    [models addObject:model1];
    
    
    for (Track *track in self.offlineTextTracks) {
        Zee5MenuModel *model = [[Zee5MenuModel alloc] init];
        if ([self.selectedSubtitle isEqualToString:[Utility getLanguageStringFromId:track.title]]) {
            model.imageName = @"t";
            model.isSelected = true;
        }
        else {
            model.imageName = @"";
            model.isSelected = false;
        }
        
        model.title = track.title;
        model.type = 2;
        model.idValue = track.id;
        [models addObject:model];
    }
    
    [_customMenu reloadDataWithObjects:models : true];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_customMenu];
}

-(void)showLangaugeSheetForOfflineContent
{
    self.selectedString = LANGUAGE;
    
    [self prepareCustomMenu];
    
    NSMutableArray<Zee5MenuModel*> *models = [[NSMutableArray alloc] init];
    
    Zee5MenuModel *model2 = [[Zee5MenuModel alloc] init];
    model2.imageName = @"T";
    model2.title = LANGUAGE;
    model2.type = 1;
    model2.isSelected = false;
    [models addObject:model2];
    
    for (Track *track in self.offlineLanguageTracks) {
        Zee5MenuModel *model = [[Zee5MenuModel alloc] init];
        if ([self.selectedLangauge isEqualToString:track.title]) {
            model.imageName = @"t";
            model.isSelected = true;
        }
        else {
            model.imageName = @"";
            model.isSelected = false;
        }
        
        model.title = track.title;
        model.type = 2;
        model.idValue = track.id;
        [models addObject:model];
    }
    
    [_customMenu reloadDataWithObjects:models : true];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_customMenu];
}

-(void)getPlayBackRateForOfflineContent{
  
        self.selectedString = PLAYBACKRATE;

        [self prepareCustomMenu];

        NSMutableArray<Zee5MenuModel*> *models = [[NSMutableArray alloc] init];
        Zee5MenuModel *model2 = [[Zee5MenuModel alloc] init];
        model2.imageName = @"p";
        model2.title = PLAYBACKRATE;
        model2.type = 1;
        model2.isSelected = false;
        [models addObject:model2];

        for (NSString *value in self.playBackRate) {
            Zee5MenuModel *model = [[Zee5MenuModel alloc] init];
            if ([self.selectedplaybackRateOffline isEqualToString:value])
            {
                model.imageName = @"t";
                model.isSelected = true;
            }
            else
            {
                model.imageName = @"";
                model.isSelected = false;
            }
            
            model.title = value;
            model.type = 2;
            model.idValue = value;
            [models addObject:model];
        }
        
        [_customMenu reloadDataWithObjects:models : true];
        [[[UIApplication sharedApplication] keyWindow] addSubview:_customMenu];

}

@end

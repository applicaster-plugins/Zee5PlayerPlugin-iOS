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
#import "upgradeSubscriView.h"
#import "comScoreAnalytics.h"
#import "IndGuestUserRegistration.h"
#import "InternationlguestUser.h"
#import "BeforeTvcontentView.h"
#import "ContentClickApi.h"
#import "LiveContentDetails.h"
#import "AddToWatchlist.h"
#import "tvShowModel.h"
#import "CdnHandler.h"
#import "SingletonClass.h"

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



@interface ZEE5PlayerManager()<UIGestureRecognizerDelegate>//// PlayerDelegate>
@property ZEE5CustomControl *customControlView;           //// Player Controls (play,pause Button)
@property DownloadQualityMenu *QualityView;
@property Zee5MenuView *customMenu;                         //// MenuView Includes(Subtitle,Audio Selection)
@property Zee5MuteView *muteView;
@property ParentalView *parentalView;                 //// Parental Lock View(Insert 4 Digit Pin)
@property devicePopView *devicePopView;              //// Device Limit reached for Single user (View will Appear)
@property upgradeSubscriView *subscribeView;
@property IndGuestUserRegistration *GuestuserPopView;
@property InternationlguestUser *IntenationalGuestuserView;
@property BeforeTvcontentView *TvContentView;

@property(nonatomic, strong) UIViewController *currentShareViewController;

@property VODContentDetailsDataModel *ModelValues;         // Stored data Model of Content Response
@property LiveContentDetails *LiveModelValues;             // Stored Data Model Of Live Content
@property tvShowModel *TvShowModel;             // Stored Data Model Of TvShow Content

@property(readwrite ,nonatomic) NSInteger PlayerStartTime;

@property ZEE5PlayerConfig *playerConfig;
@property comScoreAnalytics *comAnalytics;

@property(strong , nonatomic) UIView *viewPlayer;

@property(nonatomic) UIPanGestureRecognizer *panGesture;
@property(nonatomic) UITapGestureRecognizer *tapGesture;

@property(nonatomic) NSString *selectedString;         // Selected Value Of MenuView From Player.

@property (weak, nonatomic) NSArray *audioTracks;
@property (weak, nonatomic) NSArray *textTracks;
@property (weak, nonatomic) NSArray *selectedTracks;
@property (strong, nonatomic) NSArray *playBackRate;
@property (strong, nonatomic) NSMutableArray *PreviousContentArray;
@property (strong, nonatomic) NSMutableArray *VideocountArray;
@property (strong,nonatomic) NSTimer *CreditTimer;
@property(nonatomic) NSString *CurrentAudioTrack;
@property(nonatomic) NSString *CurrenttextTrack;


@property(nonatomic) BOOL isLive;
@property(nonatomic) BOOL videoCompleted;
@property(nonatomic) BOOL isAllreadyAdded;
@property(nonatomic) BOOL isWatchlistAdded;
@property(nonatomic) BOOL isParentalControlOffline;
@property(nonatomic) BOOL ishybridViewOpen;
@property(nonatomic) BOOL isNeedToSubscribe;


@property(nonatomic) CGFloat previousDuration;

@property(nonatomic) NSTimeInterval startTime;
@property(nonatomic) NSTimeInterval endTime;
@property(nonatomic) NSString  *showID;

@property(nonatomic) NSInteger startIntroTime;
@property(nonatomic) NSInteger endIntroTime;

@property(nonatomic) NSInteger watchCreditsTime;
@property(nonatomic) NSInteger watchHistorySecond;

@property(nonatomic) NSInteger hybridscreenTime;

@property(nonatomic)int watchCtreditSeconds;

@property(nonatomic) NSString *ageRating;
@property(nonatomic) NSString *parentalPin;
@property(nonatomic) BOOL parentalControl;

@property(nonatomic) NSString *buisnessType;
@property(nonatomic) BOOL allowVideoContent;
@property (weak, nonatomic) NSArray *audioLanguageArr;



@property(nonatomic) Boolean seekStared;


@end


@implementation ZEE5PlayerManager

static ZEE5PlayerManager *sharedManager = nil;
static ChromeCastManager *castManager;
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
        castManager = [[ChromeCastManager alloc] init];
        singleton = [SingletonClass sharedManager];
        [castManager initializeCastOptions];
        
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
        
    });
    
    return sharedManager;
}

//MARK:- VideoPlayMethod

- (void)playWithCurrentItem {

    
    if (!_allowVideoContent)
    {
        return;
    }
    else
    {
        
    if (_isStreamoverWifi == true && ZEE5PlayerSDK.Getconnectiontype == Mobile){
        [self ShowToastMessage:@"WiFi is not connected! You have selected stream over WiFi only"];
            return;
        }
      
    [self getBase64StringwithCompletion:^(NSString *base64) {

        
        
        if (self.playerConfig.showCustomPlayerControls)
              {
                  [self addCustomControls];
                  self.customControlView.buttonPlay.selected = true;
              }
              else
              {
                  [self addMuteViewToPlayer];
              }
        [[Zee5PlayerPlugin sharedInstance] initializePlayer:self.playbackView andItem:self.currentItem andLicenceURI:BaseUrls.drmLicenceUrl andBase64Cerificate:base64];
        
        self.panGesture = [[UIPanGestureRecognizer alloc]init];
        [self handleOrientations];
        [self handleTracks];
        
        [[AnalyticEngine new]ConsumptionAnalyticEvents];
//        //[[AddToWatchlist Shared]getWatchListwithCompletion:^(BOOL * _Nonnull isAddedWatclist) {
//            self.isWatchlistAdded = isAddedWatclist;
//        }];
        
        if (ZEE5PlayerSDK.getConsumpruionType == Live == false && ZEE5PlayerSDK.getConsumpruionType == Trailer == false)
        {
             [[ReportingManager sharedInstance] getWatchHistory];
        }
       
    }];
  }
}
- (void)playWithCurrentItemWithURL : (NSString *)urlString playbacksession_id:(NSString *)playbacksession_id{
    
    
    [[Zee5PlayerPlugin sharedInstance] initializePlayer:self.playbackView andURL:urlString andToken:@"" playbacksession_id:playbacksession_id];
   
    self.panGesture = [[UIPanGestureRecognizer alloc]init];
    
    if (self.playerConfig.showCustomPlayerControls)
    {
        [self addCustomControls];
        self.customControlView.buttonPlay.selected = true;
    }
    else
    {
        [self addMuteViewToPlayer];
    }
    
    [self handleOrientations];
    [self handleTracks];

}

//MARK:- Notification
-(void)registerNotifications
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterForGround)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioInterruption) name:AVAudioSessionInterruptionNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(LogoutDone) name:@"ZPLoginProviderLoggedOut" object:nil];
    
}
-(void)LogoutDone{
    
    [_PreviousContentArray removeAllObjects];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"Array"];
}
-(void)ContentidNotification:(NSString *)ContentId{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ContentIdUpdatedNotification" object:ContentId userInfo:nil];
}

-(void)RefreshViewNotification{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"ReloadConsumption" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadConsumption" object:nil userInfo:nil];
}

-(void)onAudioInterruption
{
    _customControlView.buttonPlay.hidden = NO;
    [self hideUnHideTopView:NO];

    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self pause];
}

-(void)didEnterForGround
{
    if ( ([[UIDevice currentDevice] orientation] ==  UIDeviceOrientationLandscapeLeft) || ([[UIDevice currentDevice] orientation] ==  UIDeviceOrientationLandscapeRight) )
    {
        [self showFullScreen];
    }
    else
    {
        [self hideFullScreen];
    }
}

- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            switch(device.orientation)
            {
                case UIDeviceOrientationLandscapeLeft :
                    [self showFullScreen];
                    
                    break;
                case  UIDeviceOrientationLandscapeRight:
                    [self showFullScreen];
                  
                    break;
                    
                case UIDeviceOrientationPortrait :
                    [self hideFullScreen];
                   
                    break;
                case UIDeviceOrientationPortraitUpsideDown:
                    [self hideFullScreen];
                 
                    break;
                default:
                    break;
            };
        });
        
    });
}

//MARK:- Add Controls to Player(Control View)
-(void)addCustomControls
{
     _watchHistorySecond = 0;
    /************************************/
    /////  Array of Playeback Rate
    /***********************************/
    NSArray * Rate = [[NSArray alloc]initWithObjects:@"0.5X",@"1X",@"1.5X",@"2X",@"2.5X",@"3X", nil];
    
    self.playBackRate = Rate;
       
    NSBundle *bundel = [NSBundle bundleForClass:self.class];
    
    if(_customControlView != nil )
    {
        [_customControlView.sliderLive animateToolTipFading:NO];
    }
    if(_customControlView == nil)
    {
        _customControlView = [[bundel loadNibNamed:@"ZEE5CustomControl" owner:self options:nil] objectAtIndex:0];
    }
    _customControlView.frame = CGRectMake(0, 0, self.viewPlayer.frame.size.width, self.viewPlayer.frame.size.height);
    _customControlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _customControlView.playerControlView.hidden = YES;
    _customControlView.viewLive.hidden = !self.isLive;
    _customControlView.viewVod.hidden = self.isLive;
    _customControlView.skipIntro.hidden = self.isLive;
    _customControlView.btnSkipPrev.hidden = true;
    _customControlView.btnSkipNext.hidden = _isLive;
    _customControlView.related = self.currentItem.related;
    [self hideUnHidetrailerEndView:true];
    _customControlView.adultView.hidden = YES;
    
    if (_ishybridViewOpen == true) {
        [self.playbackView addSubview:_customControlView];
       [self hideUnHidetrailerEndView:false];
        return;
    }
    
    
    if (_currentItem.related.count == 1)
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
    
    
    [self.playbackView addSubview:_customControlView];
    

    _tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOnPlayer)];
    _tapGesture.delegate = self;
    [_tapGesture setDelaysTouchesBegan : YES];
    _tapGesture.numberOfTapsRequired = 1;

    [_customControlView addGestureRecognizer:_tapGesture];
    
    _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
    [_customControlView addGestureRecognizer:_panGesture];
    
    [Zee5PlayerPlugin sharedInstance].player.view.multipleTouchEnabled   = NO;
    [Zee5PlayerPlugin sharedInstance].player.view.userInteractionEnabled = YES;
    
    _customControlView.collectionView.hidden = YES;
    _customControlView.backtoPartnerView.hidden = YES;
    
    [_customControlView forwardAndRewindActions];
  
    [self showAllControls];
    [self showloaderOnPlayer];
    
    if ([self.ModelValues.ageRating isEqualToString:@"A"] && ZEE5PlayerSDK.getUserTypeEnum == Guest  && ZEE5PlayerSDK.getConsumpruionType == Trailer == false)
    {
              _customControlView.adultView.hidden = NO;
              [self stop];
          [self hideLoaderOnPlayer];
    }
    
    
    [self MoatViewAdd];
    [self LocalStorageArray];
    [[Zee5PlayerPlugin sharedInstance].player setRate:1.0];
}

-(void)MoatViewAdd{
    if (_customControlView != nil ) {
        [singleton.ViewsArray addObject:_customControlView];
    }
    if (_customControlView.viewTop != nil ) {
        [singleton.ViewsArray addObject:_customControlView.viewTop];
    }
    if (_customControlView.viewVod != nil ) {
        [singleton.ViewsArray addObject:_customControlView.viewVod];
    }
    if (_customControlView.collectionView != nil ) {
        [singleton.ViewsArray addObject:_customControlView.collectionView];
    }
    if (_customControlView.viewLive != nil ) {
        [singleton.ViewsArray addObject:_customControlView.viewLive];
    }
    if (_customControlView.stackLoginView != nil ) {
          [singleton.ViewsArray addObject:_customControlView.stackLoginView];
      }
    if (_customControlView.watchcretidStackview != nil ) {
             [singleton.ViewsArray addObject:_customControlView.watchcretidStackview];
         }
    if (_customControlView.adultView != nil ) {
                [singleton.ViewsArray addObject:_customControlView.adultView];
        }
    if (_customControlView.playerControlView != nil ) {
            [singleton.ViewsArray addObject:_customControlView.playerControlView];
    }
}

-(void)addMuteViewToPlayer
{
    NSBundle *bundel = [NSBundle bundleForClass:self.class];
    if(_muteView == nil)
    {
        _muteView = [[bundel loadNibNamed:@"Zee5MuteView" owner:self options:nil] objectAtIndex:0];
    }
    _muteView.frame = CGRectMake(0, 0, [Zee5PlayerPlugin sharedInstance].player.view.frame.size.width, [Zee5PlayerPlugin sharedInstance].player.view.frame.size.height);
    _muteView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if ([self.currentItem.asset_subtype isEqualToString:@"episode"])
    {
        _muteView.lblTitle.text = self.currentItem.channel_Name;
        NSString *date = [Utility convertFullDateToDate:self.currentItem.release_date];
        _muteView.lblEpisode.text = [NSString stringWithFormat:@"E%ld | %@", (long)self.currentItem.episode_number, date];
    }
    else
    {
        _muteView.lblTitle.text = self.currentItem.channel_Name;
        _muteView.lblEpisode.text = @"";
    }
    [Zee5PlayerPlugin sharedInstance].player.volume = 0.0;
    [[Zee5PlayerPlugin sharedInstance].player.view addSubview:_muteView];
}


-(void)hideUnHideTopView:(BOOL )isHidden
{
    _customControlView.viewTop.hidden = isHidden;
    _customControlView.topView.hidden = isHidden;
    _customControlView.playerControlView.hidden = isHidden;
    _customControlView.btnMinimize.hidden = isHidden;
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

}

-(void)hideCustomControls
{
    [self hideUnHideTopView:YES];
    self.panGesture.enabled = false;
}


-(void)hideUnHidetrailerEndView:(BOOL )isHidden
{
    _customControlView.trailerEndView.hidden = isHidden;
    _customControlView.stackLoginView.hidden = isHidden;
    if (ZEE5PlayerSDK.getUserTypeEnum == Guest== false) {
        _customControlView.stackLoginView.hidden = true;
    }
    
}
#pragma mark: Player Events

-(void)playSimilarEvent:(NSString *)content_id
{
    [self setSeekTime:0];
}

-(void)onPlaying
{
    self.customControlView.buttonPlay.selected = YES;
    _customControlView.sliderLive.userInteractionEnabled = NO;
    _videoCompleted = NO;

    [self showAllControls];
    [self hideLoaderOnPlayer];
    _customControlView.buttonPlay.hidden = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (!_customControlView.topView.hidden) {
        [self perfomAction];
    }
    
    if (_parentalControl == YES) {
        [self pause];
        [self parentalControlshow];
    }

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
    CGFloat floored = floor([event.currentTime doubleValue]);
    NSInteger totalSeconds = (NSInteger) floored;
    
  
    [[AnalyticEngine new]VideoWatchPercentCalcWith:@"Forward"];
    
 
    [[Zee5FanAdManager sharedInstance] loadfanAds:totalSeconds];
    if (self.isLive)
    {
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
    }
    else
    {
        if (!_customControlView.sliderDuration.isTracking && !_seekStared)
        {
            _customControlView.sliderDuration.value = totalSeconds;
        }
        _customControlView.labelCurrentTime.text = [Utility getDuration:totalSeconds total:[[Zee5PlayerPlugin sharedInstance] getDuration]];
        
      
        //MARK:- WatchHistory Logic
        if (totalSeconds - _watchHistorySecond >60 || _watchHistorySecond - totalSeconds > 60)
        {
            _watchHistorySecond = totalSeconds;
            [[ReportingManager sharedInstance]startReportingWatchHistory];
        }
       /***********************************************/
             // Watchcredit
       /*********************************************/
        if (totalSeconds>=_watchCreditsTime){
            
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
        _customControlView.labelTotalDuration.text = [Utility getDuration:[[Zee5PlayerPlugin sharedInstance] getDuration] total:[[Zee5PlayerPlugin sharedInstance] getDuration]];
        
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
        
            if (_currentItem.related.count == 1 && _customControlView.watchcretidStackview.hidden == true)
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
                    _customControlView.watchCreditBtnView.hidden = YES;
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
            _watchCtreditSeconds-=1;
            [_customControlView.watchcreditsTimeLbl setText:[NSString stringWithFormat:@"%@%02d",@"Starts In : ",_watchCtreditSeconds]];
            
           [_customControlView.showcreditTimelbl setText:[NSString stringWithFormat:@"%@%02d",@"Starts In : ",_watchCtreditSeconds]];
            
            if (_currentItem.related.count > 1){
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
    [self showAllControls];
    [self showloaderOnPlayer];
    _customControlView.buttonPlay.hidden = YES;
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
            _customControlView.sliderDuration.maximumValue = [[Zee5PlayerPlugin sharedInstance] getDuration];
            _customControlView.labelTotalDuration.text = [Utility getDuration:[[Zee5PlayerPlugin sharedInstance] getDuration] total:[[Zee5PlayerPlugin sharedInstance] getDuration]];
            [_customControlView.sliderDuration setMarkerAtPosition:100.0/_customControlView.sliderDuration.maximumValue];
            [_customControlView.sliderDuration setMarkerAtPosition:200.0/_customControlView.sliderDuration.maximumValue];
        }
    }

}

- (void)onComplete
{
    _isTelco = false;
    [self hideLoaderOnPlayer];
    if (ZEE5PlayerSDK.getConsumpruionType == Trailer && _isNeedToSubscribe == true)
    {
        _videoCompleted = YES;
        [self pause];
         [self HybridViewOpen];
        [self hideUnHidetrailerEndView:false];
        return;
    }
    if (_isAutoplay == false && _customControlView.btnSkipNext.selected == false)
    {
        _videoCompleted = YES;
        _customControlView.buttonPlay.hidden = YES;
        _customControlView.buttonReplay.hidden = NO;
        [self hideUnHideTopView:NO];
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self setSeekTime:0];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishPlaying)]) {
            [self.delegate didFinishPlaying];
        }
    }
    else
    {
        [self pause];
        _customControlView.btnSkipNext.selected = false;
        if (_CreditTimer != nil) {
            return;
        }
        RelatedVideos *Model;
        for (RelatedVideos *Object in self.currentItem.related) {
             if ([_PreviousContentArray containsObject:Object.identifier])
            {
            }
             else{
                 Model = Object;
                 break;
             }
        }
        if (self.currentItem.related.count == 1) {
            Model = self.currentItem.related[0];
        }
       
        [[ZEE5PlayerManager sharedInstance] playSimilarEvent:Model.identifier];
        [[ZEE5PlayerManager sharedInstance]playVODContent:Model.identifier country:ZEE5UserDefaults.getCountry translation:ZEE5UserDefaults.gettranslation withCompletionHandler:^(VODContentDetailsDataModel * _Nullable result, NSString * _Nullable customData) {
            
        }];
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
        // [sharedManager playWithCurrentItem];
    } failureBlock:^(ZEE5SdkError * _Nullable error) {
        
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

-(void)handleOrientations
{
    if (_playerConfig.shouldStartPlayerInLandScape)
    {
        [self showFullScreen];
    }
    else
    {
        [self didEnterForGround];
    }
}

-(void)perfomAction
{
    [self performSelector:@selector(hideCustomControls) withObject:nil afterDelay:HIDECONTROLSVALUE];
}

#pragma mark: Gesture Events

-(void)tapOnPlayer
{
    
    [_customControlView.sliderDuration animateToolTipFading:NO];
    if (_customControlView.topView.hidden)
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
    self.panGesture.enabled = (self.customControlView.buttonLiveFull.selected && !_customControlView.topView.hidden && [AppConfigManager sharedInstance].config.isSimilarVideos);
    _customControlView.con_top_collectionView.constant = 10;
    
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
    [UIView animateWithDuration:0.3 animations:^{
        [self.customControlView layoutIfNeeded];
    }];
}

- (void)handleDownwardsGesture:(UIPanGestureRecognizer *)sender
{
    if (_customControlView.buttonPlay.selected) {
        if (!_customControlView.topView.hidden) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            [self perfomAction];
        }
    }
    _customControlView.con_top_collectionView.constant = 10;
    [UIView animateWithDuration:0.3 animations:^{
        [self.customControlView layoutIfNeeded];
    }];
    
}

#pragma mark: Player Controls


-(void)play
{
    if (_parentalControl == YES) {
        [self parentalControlshow];
        [self pause];
        return;
    }
    NSInteger rounded = roundf(_customControlView.sliderDuration.maximumValue);
    if (rounded == _customControlView.sliderDuration.value && rounded != 0)
    {
        [self onComplete];
    }
    else
    {
        self.customControlView.buttonPlay.selected = YES;
        [[Zee5PlayerPlugin sharedInstance].player play];
        [[ReportingManager sharedInstance] startReportingWatchHistory];
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
    [[Zee5PlayerPlugin sharedInstance].player destroy];
    _currentItem = nil;
    [self.playbackView removeFromSuperview];
}

-(void)replay
{
    [self showAllControls];
    _customControlView.buttonPlay.hidden = NO;
    _customControlView.sliderDuration.value = 0.0;
    _customControlView.bufferProgress.progress = 0.0;
    _customControlView.labelCurrentTime.text = @"00:00";
     [[AnalyticEngine new]ReplayVideo];
    [self hideLoaderOnPlayer];
    
    [self play];
    
}

- (void)stop
{
    [[Zee5PlayerPlugin sharedInstance].player pause];
    [[Zee5PlayerPlugin sharedInstance].player stop];
    [[AnalyticEngine new] cleanupVideoSesssion];
   
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
    __weak __typeof(self) weakSelf = self;
    [self showloaderOnPlayer];
    
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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.seekStared = false;
    });
   
    //    self.customControlView.buttonPlay.selected = YES;
}



-(void)setFullScreen:(BOOL)isFull
{
    if(isFull)
    {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
    }
    else
    {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    }
}
-(void)setMute:(BOOL)isMute
{
    [Zee5PlayerPlugin sharedInstance].player.volume = isMute ? 0.0 : 1.0;
    
}
-(void)setWatchHistory:(NSInteger)duration
{
    _PlayerStartTime = duration;    // Duration Get From WatchHistory Api Response.
    
    NSString *videoStartPoint = [Utility stringFromTimeInterval:duration];
    NSString *VideoEndpoint = [Utility stringFromTimeInterval:[[Zee5PlayerPlugin sharedInstance]getDuration]];
    NSDictionary *dict = @{@"videoStartPoint" : videoStartPoint,@"videoEndPoint":VideoEndpoint};
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
            [self onComplete];
        }
    }
}
-(void)tapOnPrevButton
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTaponPrevButton)]) {
        [self.delegate didTaponPrevButton];
        [self pause];
        if (_PreviousContentArray.count>1) {
            for (int i = 0; i< _PreviousContentArray.count; i++) {
                NSString *cId = [_PreviousContentArray objectAtIndex:i];
                if ([_currentItem.content_id isEqualToString:cId] && i != 0)
                {
                    cId = [_PreviousContentArray objectAtIndex:i-1];
                   
                    [[ZEE5PlayerManager sharedInstance]playVODContent:cId country:ZEE5UserDefaults.getCountry translation:ZEE5UserDefaults.gettranslation withCompletionHandler:^(VODContentDetailsDataModel * _Nullable result, NSString * _Nullable customData) {
                                   
                               }];
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
    if (ZEE5PlayerSDK.getConsumpruionType == Live == false) {
        _PreviousContentArray = [[NSMutableArray alloc]initWithCapacity:13];
        
        _isAllreadyAdded = false;
        _PreviousContentArray = [[[NSUserDefaults standardUserDefaults]valueForKey:@"Array"]mutableCopy];
    
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
       
        [[NSUserDefaults standardUserDefaults]setObject:_PreviousContentArray forKey:@"Array"];
       }
    
      if (_PreviousContentArray.count>2 && ! _isLive) {
          _customControlView.btnSkipPrev.hidden = false;
      }
}
-(void)tapOnMinimizeButton
{
    [[ReportingManager sharedInstance] startReportingWatchHistory];
    if (self.customControlView.buttonFullScreen.selected == YES) {
        [self hideFullScreen];
    }else{
         [self stop];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTaponMinimizeButton)]) {
        [self.delegate didTaponMinimizeButton];
        [[AnalyticEngine new]VideoExitAnalytics];
    }
}

-(void)tapOnUpNext
{
    [self setSeekTime:0];
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

-(void)tapOnGoLiveButton
{
    [self setSeekTime:_customControlView.sliderLive.maximumValue];
    [self play];
}

-(void)tapOnShareButton
{
    NSArray *objectsToShare;
    NSURL *zeeShareUrl;

    if (_isLive){
        
        if (_LiveModelValues.title && _LiveModelValues.identifier != nil ){
            NSString *Title = [_LiveModelValues.title stringByReplacingOccurrencesOfString:@"" withString:@"-"].lowercaseString;
            zeeShareUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@",LiveShareUrl,Title,_LiveModelValues.identifier]];
        }
    } else
    {
        zeeShareUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",VodShareUrl,_ModelValues.web_Url]];
                       
    }
    
    objectsToShare = @[zeeShareUrl];
    [self pause];   ///// Player Pause Here
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    activityVC.popoverPresentationController.sourceView = self.viewPlayer;
  
    [activityVC setCompletionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError)
     {
        self.currentShareViewController = nil;

        if (completed){
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
    BOOL fullScreen = !self.customControlView.buttonLiveFull.selected;
    _customControlView.buttonReplay.hidden = YES;
    _customControlView.playerControlView.hidden = NO;
    
}

-(void)showFullScreen
{
    [_customControlView.sliderDuration animateToolTipFading:NO];
    _customControlView.sliderLive.fullScreen = YES;
    [_customControlView.sliderLive updateToolTipView];
    if(_customControlView.sliderLive.userInteractionEnabled)
    {
        [_customControlView.sliderLive animateToolTipFading:YES];
    }
    
    self.customControlView.buttonFullScreen.selected = YES;
    self.customControlView.buttonLiveFull.selected = YES;
    
    if(!_videoCompleted)
    {
        _customControlView.btnSkipNext.hidden = NO;
        _customControlView.btnSkipPrev.hidden = NO;
    }
    _customControlView.lableSubTitle.hidden = NO;
    
    self.customControlView.con_height_topBar.constant = TOPBARHEIGHT;
    self.customControlView.con_bottom_liveView.constant = 30;
    
    self.panGesture.enabled = (self.customControlView.buttonLiveFull.selected && !_customControlView.topView.hidden && [AppConfigManager sharedInstance].config.isSimilarVideos);
    self.customControlView.collectionView.hidden = ![AppConfigManager sharedInstance].config.isSimilarVideos;
    _customControlView.con_top_collectionView.constant = 10;
   
    _customControlView.Stackview_top.constant = 0;
    
    CGRect frame = [UIScreen mainScreen].bounds;
    _customControlView.forwardButton.frame = CGRectMake(frame.size.width - 200, 0, 200, frame.size.height);
    
    _customControlView.rewindButton.frame = CGRectMake(0, 0, 200, frame.size.height);
    
    
    _customControlView.backtoPartnerView.hidden = YES;

    
    if (self.subscribeView !=nil || self.devicePopView!=nil ||self.parentalView!=nil)
    {
        self.subscribeView.hidden =YES;
        self.devicePopView.hidden =YES;
        self.parentalView.hidden =YES;
    }
    NSDictionary *dict = @{@"viewingMode" : @"Landscape"};
    [self updateConvivaSessionWithMetadata: dict];
    UIView *View = [[UIApplication sharedApplication].keyWindow.subviews lastObject];
}

-(void)hideFullScreen
{
    _customControlView.sliderLive.fullScreen = NO;
    [_customControlView.sliderLive animateToolTipFading:NO];
    [_customControlView.sliderDuration animateToolTipFading:NO];
    
    self.customControlView.buttonFullScreen.selected = NO;
    self.customControlView.buttonLiveFull.selected = NO;
   // _customControlView.btnSkipNext.hidden = YES;
   // _customControlView.btnSkipPrev.hidden = YES;
    _customControlView.skipIntro.hidden = YES;
    _customControlView.lableSubTitle.hidden = YES;
    
    self.customControlView.con_height_topBar.constant = 0;
    self.customControlView.con_bottom_liveView.constant = 10;
    
    self.panGesture.enabled = (self.customControlView.buttonLiveFull.selected && !_customControlView.topView.hidden && [AppConfigManager sharedInstance].config.isSimilarVideos);
    self.customControlView.collectionView.hidden = YES;
    _customControlView.con_top_collectionView.constant = 10;

    _customControlView.forwardButton.frame = CGRectMake(_customControlView.frame.size.width - 150, 0, 150, self.playbackView.frame.size.height);
    _customControlView.rewindButton.frame = CGRectMake(0, 0, 150, self.playbackView.frame.size.height);
    
    
    if (_isTelco == true)
    {
        _customControlView.backtoPartnerView.hidden = false;
    }

    
    ////
    NSDictionary *dict = @{@"viewingMode" : @"Portrait"};
    [self updateConvivaSessionWithMetadata: dict];
    
    if (self.parentalView!=nil)
    {
        self.parentalView.hidden = NO;
    }
    if (self.subscribeView != nil || self.devicePopView!=nil)
      {
          self.subscribeView.hidden =NO;
          self.devicePopView.hidden =NO;
      }
    if ([[UIApplication sharedApplication].keyWindow.subviews containsObject:_QualityView])
    {
    }
}

//MARK:- Player Loader

-(void)showloaderOnPlayer{
    if (self.delegate && [self.delegate respondsToSelector:@selector(showPlayerLoader)]) {
           [self.delegate showPlayerLoader];
       }
}

-(void)hideLoaderOnPlayer{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(hidePlayerLoader)]) {
        [self.delegate hidePlayerLoader];
    }
}
-(void)ShowToastMessage:(NSString *)Message{
    [[ZEE5PlayerDeeplinkManager new]ShowtoastWithMessage:Message];
   
}

-(void)forward:(NSInteger)value
{
    NSInteger currentTime = [[Zee5PlayerPlugin sharedInstance] getCurrentTime];
    NSInteger seekValue = currentTime + value;
    if(seekValue > [[Zee5PlayerPlugin sharedInstance] getDuration])
    {
        seekValue = [[Zee5PlayerPlugin sharedInstance] getDuration];
    }
    [self setSeekTime:seekValue];
    AnalyticEngine *engine = [[AnalyticEngine alloc]init];
    [engine AutoSeekAnalyticsWith:@"forward" time:value];
    
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
    AnalyticEngine *engine = [[AnalyticEngine alloc]init];
    [engine AutoSeekAnalyticsWith:@"rewind" time:value];
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

-(void)setSubTitle:(NSString *)subTitleID Title:(NSString *)SubtitleTitle
{
    [[Zee5PlayerPlugin sharedInstance].player selectTrackWithTrackId:subTitleID];
    AnalyticEngine *engine = [[AnalyticEngine alloc]init];
    [engine subtitlelangChangeAnalyticsWith:self.CurrenttextTrack newSubtitle:SubtitleTitle Mode:@"Online"];
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
        if ([self.selectedLangauge isEqualToString:track.id])
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
        if ([self.selectedSubtitle isEqualToString:[Utility getLanguageStringFromId:track.title]]){;    //[Utility getLanguageStringFromId:str]])
            model.imageName = @"t";
            model.isSelected = true;
        }
        else
        {
            model.imageName = @"";
            model.isSelected = false;
        }

        model.title =track.title;
        model.type = 2;
        model.idValue = track.id;
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
    [self preparePopView];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_devicePopView];
    
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
    [[[UIApplication sharedApplication] keyWindow] addSubview:_parentalView];
    
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
                _parentalControl =NO;
                _allowVideoContent =YES;
                [self play];
                
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

//MARK:- Delete Device For User Login

-(void)deleteAllDevice:(NSString *)SenderAction
{
    if ([SenderAction isEqualToString:@"Cancel"])
    {
        switch (DeviceManager.getStateOfDevice)
        {
          case DeviceMaxout:
                [self DevicePopupShow];
                break;
          case DeviceAdded:
                if (_isLive)
                {
                    [self playLiveContent:_LiveModelValues.identifier country:ZEE5UserDefaults.getCountry translation:ZEE5UserDefaults.gettranslation];
                }
                else
                {
                   [self playVODContent:_ModelValues.identifier country:ZEE5UserDefaults.getCountry translation:ZEE5UserDefaults.gettranslation  withCompletionHandler:^(VODContentDetailsDataModel * _Nullable result, NSString * _Nullable customData) {
                        
                   }];
                }
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
    
//    Zee5MenuModel *model4 = [[Zee5MenuModel alloc] init];
//    model4.imageName = @"2";
//    model4.title = AUTOPLAY;
//    model4.type = 1;
//    model4.isSelected = false;
//    [models addObject:model4];
    
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
            [self setSubTitle:menuModel.idValue Title:menuModel.title];
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

-(void)InternationalGuestUser
{
    NSBundle *bundel = [NSBundle bundleForClass:self.class];
    
    if(_IntenationalGuestuserView == nil)
    {
        _IntenationalGuestuserView = [[bundel loadNibNamed:@"InternationlguestUser" owner:self options:nil]objectAtIndex:0];
    }
    else
    {
        [_IntenationalGuestuserView removeFromSuperview];
        _IntenationalGuestuserView = nil;
    }
    
         CGRect windowFrame = [[[UIApplication sharedApplication] keyWindow] frame];
        _IntenationalGuestuserView.frame = windowFrame;
        _IntenationalGuestuserView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
        [[[UIApplication sharedApplication] keyWindow] addSubview:_IntenationalGuestuserView];
  
}

-(void)HybridViewOpen{
    [self HybridviewnotificationObserver];
    if (_ishybridViewOpen == false) {
         _ishybridViewOpen = true;
        if ([Zee5PlayerPlugin sharedInstance].player.currentState != PlayerStateEnded) {
            [self pause];
        }
           [[ZEE5PlayerDeeplinkManager sharedMethod]HybridpackviewWithCompletion:^(BOOL isSuccess) {
              if (isSuccess) {
                  [[ZEE5PlayerDeeplinkManager new]fetchUserdata];
                 [self RefreshViewNotification];
             }
         }];
        
    }
 
}
-(void)HybridviewnotificationObserver{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"upgradePopupDissmiss" object:nil];
      [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DismissHybridView) name:@"upgradePopupDissmiss" object:nil];
}

-(void)DismissHybridView{
    
     _ishybridViewOpen = false;
    if ([Zee5PlayerPlugin sharedInstance].player.currentState != PlayerStateEnded) {
        [self play];
        return;
    }
    if (_ModelValues.isBeforeTv == true && self.TvShowModel.Episodes.count > 0) {
           NSString *ContentId = self.TvShowModel.Episodes[1].episodeId;
           
           [self playVODContent:ContentId country:ZEE5UserDefaults.getCountry translation:ZEE5UserDefaults.gettranslation withCompletionHandler:^(VODContentDetailsDataModel * _Nullable result, NSString * _Nullable customData) {
                          }];
       }
    
}

-(void)INDGuestUser
{
    NSBundle *bundel = [NSBundle bundleForClass:self.class];
    
    [self hideLoaderOnPlayer];
    if(_GuestuserPopView == nil)
    {
        _GuestuserPopView = [[bundel loadNibNamed:@"IndGuestUserRegistration" owner:self options:nil]objectAtIndex:0];
    }
    else
    {
        
        [_GuestuserPopView removeFromSuperview];
        _GuestuserPopView = nil;
    }
       CGRect widowFrame = [[[UIApplication sharedApplication] keyWindow] frame];
        _GuestuserPopView.frame = widowFrame;
        _GuestuserPopView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

     [[[UIApplication sharedApplication] keyWindow] addSubview:_GuestuserPopView];

}
-(void)PrepareBeforeTvcontentView
{
    NSBundle *bundel = [NSBundle bundleForClass:self.class];
    
    if( _TvContentView== nil)
    {
        _TvContentView = [[bundel loadNibNamed:@"BeforeTvcontentView" owner:self options:nil]objectAtIndex:0];
    }
    else
    {
        [_TvContentView removeFromSuperview];
    }
    
        CGRect windowFrame = [[[UIApplication sharedApplication] keyWindow] frame];
        _TvContentView.frame = windowFrame;
        _TvContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
     [[[UIApplication sharedApplication] keyWindow] addSubview:_TvContentView];
  
}
-(void)UpgradeSubscribePopView
{
    [self prepareSubscribeView];
       [[[UIApplication sharedApplication] keyWindow] addSubview:_subscribeView];
}

-(void)prepareSubscribeView
{
    NSBundle *bundel = [NSBundle bundleForClass:self.class];
    
    if(_subscribeView == nil)
    {
        _subscribeView = [[bundel loadNibNamed:@"upgradeSubscriView" owner:self options:nil]objectAtIndex:0];
    }
    else
    {
        [_subscribeView removeFromSuperview];
    }
    
       CGRect widowFrame = [[[UIApplication sharedApplication] keyWindow] frame];
        _subscribeView.frame = CGRectMake(0,widowFrame.size.height - _subscribeView.frame.size.height, widowFrame.size.width, _subscribeView.frame.size.height);
        _subscribeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  
}

-(void)upgradeSubscribePack:(NSString *)SubscribePack
{
    if (SubscribePack.length !=0)
       {
           if(_subscribeView != nil)
           {
               if (_subscribeView.superview != nil)
               {
                   [_subscribeView removeFromSuperview];
                   _allowVideoContent = YES;
                   [self playWithCurrentItem];
               }
               return;
           }
       }
}
//MARK:- Remove All Present pop Views From Screen

-(void)removeSubview
{
    if(_subscribeView != nil){
        [_subscribeView removeFromSuperview];
        _subscribeView = nil;
    }else if (_TvContentView != nil){
        [_TvContentView removeFromSuperview];
         _TvContentView = nil;
    }else if (_GuestuserPopView != nil){
        [self hybridPopCloseCallback];
    }else if (_IntenationalGuestuserView != nil){
        [_IntenationalGuestuserView removeFromSuperview];
        _IntenationalGuestuserView = nil;
    }else if (_devicePopView != nil){
        [_devicePopView removeFromSuperview];
        _devicePopView = nil;
    }else if (_parentalView != nil){
        [_parentalView removeFromSuperview];
        _parentalView = nil;
    }
    
}

//MARK:- Hybrid Cinsumption Screen Close Callback

-(void)hybridPopCloseCallback
{
    [_GuestuserPopView removeFromSuperview];
      _GuestuserPopView = nil;
    
    
    if (_ModelValues.isBeforeTv == true && self.TvShowModel.Episodes.count > 0) {
        NSString *ContentId = self.TvShowModel.Episodes[1].episodeId;
        
        [self playVODContent:ContentId country:ZEE5UserDefaults.getCountry translation:ZEE5UserDefaults.gettranslation withCompletionHandler:^(VODContentDetailsDataModel * _Nullable result, NSString * _Nullable customData) {
                       }];
    }
  
//   else if (PlayerStateEnded && self.currentItem.related.count>0 )
//    {
//
//        RelatedVideos *model = self.currentItem.related[0];
//               [[ZEE5PlayerManager sharedInstance] playSimilarEvent:model.identifier];
//
//        [[ZEE5PlayerManager sharedInstance]playVODContent:model.identifier country:ZEE5UserDefaults.getCountry translation:ZEE5UserDefaults.gettranslation withCompletionHandler:^(VODContentDetailsDataModel * _Nullable result, NSString * _Nullable customData) {
//
//               }];
 //   }
}


//MARK:- Deeplink Manager Method.

-(void)tapOnSubscribeButton                  /// Navigate To Subscription Page
{
     [self stop];    ///*** Player Stop First Here***//
    [_GuestuserPopView removeFromSuperview];
    _GuestuserPopView = nil;
    [self hideUnHidetrailerEndView:true];
    
    if (_isLive==false){
        if (_ModelValues.isBeforeTv == true) {
             [[ZEE5PlayerDeeplinkManager sharedMethod]GetSubscrbtionWith:_ModelValues.assetType beforetv:true Param:@"Subscribe" completion:^(BOOL isSuccees) {
            if (isSuccees){
            [[ZEE5PlayerDeeplinkManager new]fetchUserdata];
            [self RefreshViewNotification];
        }
    }];
            return;
        }
        [[ZEE5PlayerDeeplinkManager sharedMethod]GetSubscrbtionWith:_ModelValues.assetType beforetv:false Param:@"Subscribe" completion:^(BOOL isSuccees) {
                if (isSuccees) {
                [[ZEE5PlayerDeeplinkManager new]fetchUserdata];
                [self RefreshViewNotification];
            }
                }];
        
    }else{
        [[ZEE5PlayerDeeplinkManager sharedMethod]GetSubscrbtionWith:_LiveModelValues.assetType beforetv:false Param:@"Subscribe" completion:^(BOOL isSuccees) {
            if (isSuccees) {
                [[ZEE5PlayerDeeplinkManager new]fetchUserdata];
                [self RefreshViewNotification];
            }
        }];
    }

}
-(void)tapOnLoginButton                      /// Navigate To Login Screen
{
     [self stop];    ///*** Player Stop First Here***//
     [self removeSubview];
    [self hideUnHidetrailerEndView:true];
    [[ZEE5PlayerDeeplinkManager new]NavigatetoLoginpageWithParam:@"Login" completion:^(BOOL isSuccees) {
        if (isSuccees) {
            [[ZEE5PlayerDeeplinkManager new]fetchUserdata];
            [self RefreshViewNotification];
            
        }
    }];
    
}

//MARK:- Navigate To Download Screen

-(void)GoToDownloadsSection
{
    [self setFullScreen: NO];
    [[Zee5PlayerPlugin sharedInstance].player pause];
    [[ZEE5PlayerDeeplinkManager new]NavigatetoDownloads];
    
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

//MARK:- Play LiveContent Method.

- (void)playLiveContent:(NSString*)content_id country:(NSString*)country translation:(NSString*)laguage {
    self.isLive = YES;
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BaseUrls.liveContentDetails, content_id];
    NSDictionary *param =@{@"country":country, @"translation":laguage};
    
    NSDictionary *headers = @{@"Content-Type":@"application/json",@"X-Access-Token": ZEE5UserDefaults.getPlateFormToken};
    
    [[NetworkManager sharedInstance] makeHttpGetRequest:urlString requestParam:param requestHeaders:headers withCompletionHandler:^(id result) {
        self.LiveModelValues = [LiveContentDetails initFromJSONDictionary:result];
        self.buisnessType = self.LiveModelValues.buisnessType;
        self.audioLanguageArr = self.LiveModelValues.languages;
        self.showID = self.LiveModelValues.identifier;
        self.isStop = NO;
        
        [self getVideotoken:content_id andCountry:country withCompletionhandler:^(id result) {
            NSString * VideoToken = [result valueForKey:@"video_token"];  //// Fetch Video token here
            
            if (self.LiveModelValues.isDRM) {
                [self getDRMToken:self.LiveModelValues.identifier andDrmKey:self.LiveModelValues.drmKeyID withCompletionHandler:^(id  _Nullable result) {
                    [self initilizePlayerWithLiveContent:self.LiveModelValues andDRMToken:[result valueForKey:@"drm"] VideoToken:VideoToken];
                    if (self.currentItem == nil) {
                        return ;
                    }
                    
                    [self stop];
                    
                } failureBlock:^(ZEE5SdkError * _Nullable error) {
                    [self notifiyError:error];
                }];
            }
            else {
                [self initilizePlayerWithLiveContent:self.LiveModelValues andDRMToken:@"" VideoToken:VideoToken];
                
                if (self.currentItem == nil) {
                    return ;
                }
            }
            
        } faillureblock:^(ZEE5SdkError *error) {
            [self initilizePlayerWithLiveContent:self.LiveModelValues andDRMToken:@"" VideoToken:@""];
            
            if (self.currentItem == nil) {
                return ;
            }
        }];
    } failureBlock:^(ZEE5SdkError *error) {
        [self notifiyError:error];
    }];
}

//MARK:-  Applicaster Call Method. (ContentId.Country,Language)

- (void)playVODContent:(NSString*)content_id country:(NSString*)country translation:(NSString*)laguage playerConfig:(ZEE5PlayerConfig*)playerConfig playbackView:(nonnull UIView *)playbackView withCompletionHandler: (VODDataHandler)completionBlock
{

   // content_id = @"0-1-200439_782008633";//0-1-261984
    
    _isStop = false;
    _isNeedToSubscribe = false;
    _ishybridViewOpen = false;
    self.viewPlayer = playbackView;
    self.playbackView = [[PlayerView alloc] initWithFrame:CGRectMake(0, 0, playbackView.frame.size.width, playbackView.frame.size.height)];
    
    [self setSeekTime:0];
    
    self.playbackView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self.viewPlayer addSubview:self.playbackView];
     
    [ZEE5UserDefaults settranslationLanguage:laguage];
    [ZEE5UserDefaults setContentId:content_id];
    //Clean up video Session
    [[AnalyticEngine new] cleanupVideoSesssion];
    
    
    [self registerNotifications];
    self.playerConfig = playerConfig;
 
    
    NSArray *array = [content_id componentsSeparatedByString:@"-"];
    NSString *contentType = array[1];
    
    [ZEE5UserDefaults setassetType:contentType];
    
    if ([contentType isEqualToString:@"6"])
    {
        [self fetchTvShow:content_id country:country translation:laguage];
    }
    else if ([contentType isEqualToString:@"9"])
    {
        [self playLiveContent:content_id country:country translation:laguage];
    }
    else
    {
        [self playVODContent:content_id country:country translation:laguage withCompletionHandler:^(VODContentDetailsDataModel * _Nullable result, NSString * _Nullable customData) {
            completionBlock(result, customData);
        }];
    }
    
}


//MARK:- Content Details API

- (void)playVODContent:(NSString*)content_id country:(NSString*)country translation:(NSString*)laguage withCompletionHandler: (VODDataHandler)completionBlock
{
    
       _watchCtreditSeconds = 10;
    [self setSeekTime:0];
    
    self.previousDuration = [[Zee5PlayerPlugin sharedInstance] getDuration];
    
    if (self.previousDuration != 0)
    {
        [self watchDuration:self.currentItem.content_id];
    }
    
    self.isLive = NO;
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BaseUrls.vodContentDetails, content_id];
    NSDictionary *param =@{@"country":country, @"translation":laguage};
    
    NSDictionary *headers = @{@"Content-Type":@"application/json",@"X-Access-Token": ZEE5UserDefaults.getPlateFormToken};
    
    
    [[NetworkManager sharedInstance] makeHttpGetRequest:urlString requestParam:param requestHeaders:headers withCompletionHandler:^(id result)
    {
        self.ModelValues = [VODContentDetailsDataModel initFromJSONDictionary:result];
        
        if ([self.ModelValues.watchCreditTime containsString:@"NULL"]== false)
        {
             self.watchCreditsTime = [[Utility secondsForTimeString:self.ModelValues.watchCreditTime]integerValue];
         
        }
    
        self.buisnessType = self.ModelValues.buisnessType;
        self.audioLanguageArr = self.ModelValues.audioLanguages;
        
       ///*Fetch Require Details     *////
        
        [self getBusinessType];
        [self getskipandWatchcredit];
        [self getUserSettings];
    
        if (self.ModelValues.isDRM)
        {
            [[CdnHandler sharedInstance]getKCDNUrl:self.ModelValues.identifier withCompletion:^(id  _Nullable result, NSString * _Nonnull CDN) {
                
                self.KcdnUrl = CDN;
                
                [self getDRMToken:self.ModelValues.identifier andDrmKey:self.ModelValues.drmKeyID withCompletionHandler:^(id  _Nullable result)
                 {
                    [self initilizePlayerWithVODContent:self.ModelValues andDRMToken:[result valueForKey:@"drm"]];
                    if (self.currentItem == nil) {
                        return ;
                    }
                    
                    // Update video end point
                    NSTimeInterval vEndPoint = [[Zee5PlayerPlugin sharedInstance] getCurrentTime];
                    NSString *videoEndPoint = [Utility stringFromTimeInterval: vEndPoint];
                   
                    NSDictionary *dict = @{@"videoEndPoint" : videoEndPoint};
                    [self updateConvivaSessionWithMetadata: dict];
                    
                    [self stop];
                
                    [self createConvivaSeesionWithMetadata];
                    
                } failureBlock:^(ZEE5SdkError * _Nullable error)
                 {
                    [self notifiyError:error];
                   
                }];
                
            } andFailure:^(ZEE5SdkError * _Nullable error) {
                
            }];
        }else
        {
           [self getVodToken:^(NSString *vodToken) {
                [self initilizePlayerWithVODContent:self.ModelValues andDRMToken:vodToken];
               if (self.currentItem == nil) {
                return ;
                }
           }];
        }
    } failureBlock:^(ZEE5SdkError *error)
     {
        [self notifiyError:error];
         [[Zee5PlayerPlugin sharedInstance]ConvivaErrorCode:error.zeeErrorCode platformCode:@"001" severityCode:0 andErrorMsg:@"Content Detail API Failure -"];
    }];
    
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

//MARK:- FetchTvShow Content API.

- (void)fetchTvShow:(NSString*)content_id country:(NSString*)country translation:(NSString*)laguage;
{
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BaseUrls.TvShowContentDetail, content_id];
    NSDictionary *param =@{@"country":country, @"translation":laguage};
    NSDictionary *headers = @{@"Content-Type":@"application/json",@"X-Access-Token": ZEE5UserDefaults.getPlateFormToken};
    
    
    [[NetworkManager sharedInstance] makeHttpGetRequest:urlString requestParam:param requestHeaders:headers withCompletionHandler:^(id result)
    {

        self.TvShowModel = [tvShowModel initFromJSONDictionary:result];
        NSString *ContentID = self.TvShowModel.Episodes[0].episodeId;
            if (![ContentID isKindOfClass:[NSNull class]] || ![ContentID isEqualToString:@"(NULL)"])
            {
                [self playVODContent:ContentID country:country translation:laguage withCompletionHandler:^(VODContentDetailsDataModel * _Nullable result, NSString * _Nullable customData) {
                    //completionBlock(result, customData);
                }];
            }
        }
        failureBlock:^(ZEE5SdkError *error)
     {
        [self notifiyError:error];
    }];
    
}
- (void)playAESContent:(NSString*) content_id country:(NSString*)country translation:(NSString*) laguage platform_name:(NSString*)platform_name playbacksession_id:(NSString*)playbacksession_id playerConfig:(ZEE5PlayerConfig*)playerConfig playbackView:(nonnull UIView *)playbackView
{
    
    _isStop = false;
    self.viewPlayer = playbackView;
    self.playbackView = [[PlayerView alloc] initWithFrame:CGRectMake(0, 0, playbackView.frame.size.width, playbackView.frame.size.height)];
    
    self.playbackView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.viewPlayer addSubview:self.playbackView];
    
    [self registerNotifications];
    self.playerConfig = playerConfig;
    
    self.isLive = NO;
    [self playAESContent:content_id country:country translation:laguage platform_name:platform_name playbacksession_id:playbacksession_id];
}


-(void)contentIdChanged:(NSString *)content_id withCompletionHandler:(CIdHandler)success{
    
    if ([_currentItem.content_id isKindOfClass:[NSNull class]] == false)
    {
        if ([_currentItem.content_id isEqualToString:content_id]==false) {
            success(YES,_currentItem.content_id);
        }
    }
}

// MARK:- Download Ad Config

-(void)downLoadAddConfig:(SuccessHandler)success failureBlock:(FailureHandler)failure
{
    if (_playerConfig.shouldStartPlayerInLandScape)
    {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
    }
    NSString * Bundleversion = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSDictionary *params = @{@"content_id":_currentItem.content_id ,@"platform_name":@"apple_app",@"user_type":[ZEE5UserDefaults getUserType],@"country":ZEE5UserDefaults.getCountry,@"state":ZEE5UserDefaults.getState,@"app_version":Bundleversion,@"audio_language":ZEE5UserDefaults.gettranslation};
    
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
        
//        [[Zee5FanAdManager sharedInstance] createFanAds];
        
    } failureBlock:^(ZEE5SdkError * _Nullable error)
     {
        failure(error);
        [sharedManager playWithCurrentItem];
        
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

//MARK:-   Play AES Content (using Playback Session ID)

- (void)playAESContent:(NSString*)content_id country:(NSString*)country translation:(NSString*)laguage  platform_name:(NSString*)platform_name playbacksession_id:(NSString*)playbacksession_id
{
    self.previousDuration = [[Zee5PlayerPlugin sharedInstance] getDuration];
    
    if (self.previousDuration != 0)
    {
        [self watchDuration:self.currentItem.content_id];
    }
    self.isLive = NO;
    
    NSDictionary *param =@{@"content_id":content_id,@"country":country, @"translation":laguage,@"platform_name":platform_name,@"playbacksession_id":playbacksession_id};
    

   
    NSDictionary *headers = @{@"Content-Type":@"application/json",@"X-Access-Token":ZEE5UserDefaults.getPlateFormToken,@"x-playback-session-id" : playbacksession_id};
    
    [[NetworkManager sharedInstance] makeHttpGetRequest:BaseUrls.getndToken requestParam:param requestHeaders:headers withCompletionHandler:^(id result)
     {
        
         [self playWithCurrentItemWithURL:[result valueForKey:@"video_token"] playbacksession_id:playbacksession_id];
        
    }
     
    failureBlock:^(ZEE5SdkError *error) {
        
    
        [self notifiyError:error];
    }];
    
}

-(void)getTokenAndCustomDataFromContent:(NSString*)content_id country:(NSString*)country translation:(NSString*)laguage withCompletionHandler:(DRMSuccessHandler)success andFailure:(DRMFailureHandler)failed
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BaseUrls.vodContentDetails, content_id];
    NSDictionary *param =@{@"country":country, @"translation":laguage};
    NSDictionary *headers = @{@"Content-Type":@"application/json",@"X-Access-Token":ZEE5UserDefaults.getPlateFormToken};
    [[NetworkManager sharedInstance] makeHttpGetRequest:urlString requestParam:param requestHeaders:headers withCompletionHandler:^(id result) {
        
        VODContentDetailsDataModel *model = [VODContentDetailsDataModel initFromJSONDictionary:result];

        if (model.isDRM)
        {
            [self getDRMToken:model.identifier andDrmKey:model.drmKeyID withCompletionHandler:^(id  _Nullable result)
             {
                success(BaseUrls.drmLicenceUrl,[result valueForKey:@"drm"]);
                
            } failureBlock:^(ZEE5SdkError * _Nullable error) {
                failed(error.message);
            }];
        }
        else
        {
            failed(@"Error Message");

        }

    } failureBlock:^(ZEE5SdkError *error) {
        [self notifiyError:error];
    }];

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
    
    if (![self.currentItem.hls_Url containsString:@"https"])
    {
        self.currentItem.hls_Url = [self.currentItem.hls_Url stringByReplacingOccurrencesOfString:@"http" withString:@"https"];
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

    if ([ZEE5UserDefaults.getContentID isEqualToString:_currentItem.content_id] == false) {
      [self ContentidNotification:_currentItem.content_id];
    }
    
    if (_playerConfig.playerType == normalPlayer)
    {
        [self downLoadAddConfig:^(id result) {

            if (ZEE5PlayerSDK.getConsumpruionType == Episode){
                [self getNextEpisode];
            }else
            {
              [self getVodSimilarContent];
            }
            if (ZEE5PlayerSDK.getConsumpruionType == Trailer)
               {
                   self.allowVideoContent = YES;
                   [self playWithCurrentItem];
               }else{
                     [self getSubscrptionList];
               }
            
        } failureBlock:^(ZEE5SdkError *error) {
           [self getSubscrptionList];
        }];
    }
    else
    {
        self.playerConfig.showCustomPlayerControls = false;
        [self playWithCurrentItem];
    }
    
    [[AnalyticEngine new]CurrentItemDataWith:self.currentItem];
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
    
    if (![ZEE5UserDefaults.getContentID isEqualToString:_currentItem.content_id]) {
        [self ContentidNotification:_currentItem.content_id];
    }
    
    if (_playerConfig.playerType == normalPlayer)
    {
        [self downLoadAddConfig:^(id result) {
            [self getVodSimilarContent];
            [self getSubscrptionList];
            
        } failureBlock:^(ZEE5SdkError *error) {
            [self getSubscrptionList];
        }];
    }
    else {
        self.playerConfig.showCustomPlayerControls = false;
        [self playWithCurrentItem];
    }
    
    [[AnalyticEngine new] CurrentItemDataWith:self.currentItem];
    
    [self getSubscrptionList];
}


//MARK:- Meta data for Conviva Analytics.

- (void)createConvivaSeesionWithMetadata
{
    NSString *stremType = @"Unknown";
    NSString *isLive = @"false";
    
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
             @"viewerId": ZEE5PlayerSDK.getUserId
             };
 
    [[AnalyticEngine new] setupConvivaSessionWith:dict];
    
   
    [self comScoreMetadata];
    [self setupMetadataWithContent: self.currentItem];
}

// MARK:- Meta Data For ComScore Analytics.

-(void)comScoreMetadata
{
    NSString *stremType = @"Unknown";
    NSString *isLive = @"false";
    
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
             @"viewerId": ZEE5PlayerSDK.getUserId
             };
     [SCORAnalytics notifyViewEventWithLabels:dict];
}
-(void)setupMetadataWithContent:(CurrentItem *)item
{

    
    NSDictionary *dict;
    
    NSString *userId = ZEE5PlayerSDK.getUserId;
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
    if (_ModelValues.isBeforeTv) {
        AutoPlay = @"N";
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
             @"originalLanguage": [item.language componentsJoinedByString:@","]?:NA,
             
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
    [[AnalyticEngine new] updateMetadataWith:dict];

}

- (void)initilizePlayerWithEPGContent:(EpgContentDetailsDataModel*)model andDRMToken:(NSString*)token
{
    self.currentItem = [[CurrentItem alloc] init];
    if (model.isDRM)
    {
        self.currentItem.hls_Url = [self.KcdnUrl stringByAppendingString:model.hlsUrl];
    }
    else
    {
        self.currentItem.hls_Url = model.hlsUrl;
    }
    self.currentItem.drm_token = token;
    self.currentItem.drm_key = model.drmKeyID;
    self.currentItem.subTitles = model.subtitleLanguages;
    self.currentItem.streamType = CONVIVA_STREAM_VOD;
    self.currentItem.content_id = model.identifier;
    self.currentItem.channel_Name = model.channel_name;
    self.currentItem.asset_type = model.assetType;
    self.currentItem.asset_subtype = model.assetSubtype;
    self.currentItem.geners = model.geners;
    self.currentItem.isDRM = model.isDRM;
    self.currentItem.hls_Full_Url = model.hlsFullURL;
    self.currentItem.showName = model.show_name;
//    [sharedManager playWithCurrentItem];
    if (_playerConfig.playerType == normalPlayer)
    {
      //  [self downLoadAddConfig];
    }
    else
    {
        self.playerConfig.showCustomPlayerControls = false;
        [self playWithCurrentItem];
    }
}


//MARK:- Similar Content For Playback

- (void)getVodSimilarContent
{
    NSDictionary *param =@{@"user_type": ZEE5UserDefaults.getUserType,
                           @"page":@"1",
                           @"limit":@"25",
                           @"translation":ZEE5UserDefaults.gettranslation,
                           @"country":ZEE5UserDefaults.getCountry,
                           @"languages":self.currentItem.audioLanguages
                           };
    NSDictionary *headers = @{@"Content-Type":@"application/json",@"X-Access-Token":ZEE5UserDefaults.getPlateFormToken,@"Cache-Control":@"no-cache"};
    
    [[NetworkManager sharedInstance] makeHttpGetRequest:[NSString stringWithFormat:@"%@/%@",BaseUrls. vodSimilarContent,_currentItem.content_id] requestParam:param requestHeaders:headers withCompletionHandler:^(id  _Nullable result)
     {
         
        SimilarDataModel *model = [SimilarDataModel initFromJSONDictionary:result];
        self.currentItem.related = model.relatedVideos;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kRefreshRelatedVideoList" object:nil];
        
    } failureBlock:^(ZEE5SdkError * _Nullable error) {
        
    }];
    
}

//MARK:- NextEpisode

- (void)getNextEpisode
{
    NSDictionary *param =@{@"episode_id": _currentItem.content_id,
                           @"page":@"1",
                           @"limit":@"1",
                           @"translation":ZEE5UserDefaults.gettranslation,
                           @"country":ZEE5UserDefaults.getCountry,
                           @"type":@"next"
                           };
    NSDictionary *headers = @{@"Content-Type":@"application/json",@"X-Access-Token":ZEE5UserDefaults.getPlateFormToken,@"Cache-Control":@"no-cache"};
    
    [[NetworkManager sharedInstance] makeHttpGetRequest:[NSString stringWithFormat:@"%@/%@",BaseUrls.getNextContent,self.ModelValues.SeasonId] requestParam:param requestHeaders:headers withCompletionHandler:^(id  _Nullable result)
     {
         
        SimilarDataModel *model = [SimilarDataModel initFromJSONDictionary:result];
        self.currentItem.related = model.relatedVideos;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kRefreshRelatedVideoList" object:nil];
        
        
    } failureBlock:^(ZEE5SdkError * _Nullable error) {
        
    }];
}

// MARK:- Get Subscription Data  and Logic For PopUps.

- (void)getSubscrptionList
{

    NSString *result = [ZEE5UserDefaults getSubscribedPack];
    if ([result isKindOfClass:[NSNull class]]|| result.length == 0 || [result isEqualToString:@"[]"])
    {
        self.allowVideoContent =YES;
        if (ZEE5PlayerSDK.getUserTypeEnum == Premium == false && (buisnessType == premium || buisnessType == premium_downloadable) && _isLive == false) {
            [self playTrailer];
            return;
        }
        [self playWithCurrentItem];
        return;
    }
    
   NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
    id _Nullable resultData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

        for(NSDictionary *dict in resultData)
            {
                 SubscriptionModel *model = [[SubscriptionModel alloc] initWithDictionary:dict];
          
                    if (model.subscriptionPlan.channelAudioLanguages.count!=0 && (buisnessType == premium_downloadable || buisnessType == premium) )
                    {
                        id commonObject = [model.subscriptionPlan.channelAudioLanguages firstObjectCommonWithArray:self.audioLanguageArr];
                        
                        if (model.isSubscriptionActive  && commonObject!=nil)
                        {
                            self.allowVideoContent =YES;
                            break;
                    
                        }else
                        {
                           
                        }
                    }else
                    {
                        if (model.isSubscriptionActive && (buisnessType == premium_downloadable || buisnessType == premium))
                        {
                                self.allowVideoContent =YES;
                                break;
                        }
                         else if (buisnessType == premium_downloadable || buisnessType == premium)
                        {
                          // [self playTrailer];   // Trailer Play Here.
                        }
                        else
                        {
                          self.allowVideoContent =YES;
                        }
                    }
                }
        [self playWithCurrentItem]; ////  Main call For Play item
}

//MARK:- Play Trailer Method (Check Tv Show AssetType or Vod AssetType);

-(void)playTrailer
{
    _isNeedToSubscribe = true;
    if (_isLive == false && self.ModelValues.trailerIdentifier!=nil)
    {
        self.allowVideoContent = YES;
          [self playVODContent:self.ModelValues.trailerIdentifier country:ZEE5UserDefaults.getCountry translation:ZEE5UserDefaults.gettranslation withCompletionHandler:^(VODContentDetailsDataModel * _Nullable result, NSString * _Nullable customData) {
              
          }];
        return;
    }
    else if (self.TvShowModel.TrailersContentid != nil && ZEE5PlayerSDK.getConsumpruionType == Episode && _ModelValues.isBeforeTv == false)
    {
        self.allowVideoContent = YES;
          [self playVODContent:self.TvShowModel.TrailersContentid country:ZEE5UserDefaults.getCountry translation:ZEE5UserDefaults.gettranslation withCompletionHandler:^(VODContentDetailsDataModel * _Nullable result, NSString * _Nullable customData) {
              
          }];
        return;
    }
    if (_ModelValues.isBeforeTv == true) {
        [[Zee5PlayerPlugin sharedInstance]ConvivaErrorCode:1000 platformCode:@"006" severityCode:0 andErrorMsg:@"Before TV Popup -"];
    }
    [self HybridViewOpen];
    [self addCustomControls];
    
    
}

//MARK:- Get User Setting

-(void)getUserSettings{
    

   NSString *result = [ZEE5UserDefaults getUserSetting];
      if ([result isKindOfClass:[NSNull class]] || result.length ==0 || ZEE5PlayerSDK.getUserTypeEnum == Guest)
      {
          self.parentalControl = NO;
          self.isParentalControlOffline = NO;
          return;
      }
    
    NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
   id _Nullable resultData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
        userSettingDataModel *settingModel = [userSettingDataModel initFromJSONDictionary:resultData];
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
-(void)CheckParentalControl{
    if ([self.ageRating isEqualToString:@"A"] || self.ageRating == nil || self.ageRating.length==0)
    {
        self.parentalControl = NO;
        self.isParentalControlOffline = NO;
        
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
                   [self DevicePopupShow];
               }
        if (error.zeeErrorCode == 3803) {
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
        
        [[Zee5PlayerPlugin sharedInstance]ConvivaErrorCode:error.zeeErrorCode platformCode:@"004" severityCode:1 andErrorMsg:@"Entitlement API Error -"];
        
        if (error.zeeErrorCode == 3608)
        {
            [DeviceManager addDevice];
        }
        else if (error.zeeErrorCode == 3602)
        {
            [self DevicePopupShow];
        }
        else if (error.zeeErrorCode == 3803 || error.zeeErrorCode == 3804)
        {
            // Show suibscriptionorLogin popup here.
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
    if ([touch.view isDescendantOfView:_customControlView.collectionView] || [touch.view isDescendantOfView:_customControlView.sliderDuration] || [touch.view isDescendantOfView:_customControlView.sliderLive] || [touch.view isDescendantOfView:_customMenu.tblView] ) {
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
        [[ZEE5PlayerDeeplinkManager new]NavigatetoLoginpageWithParam:@"Download" completion:^(BOOL isSuccess) {
            if (isSuccess) {
                [[ZEE5PlayerDeeplinkManager new]fetchUserdata];
                [self RefreshViewNotification];
               
               // [self StartDownload];
            }
        }];
        return;
    }
    
    if (self.currentItem == nil ) {
        return;
    }
    
    if (ZEE5PlayerSDK.getConsumpruionType == Trailer && ZEE5PlayerSDK.getUserTypeEnum == Premium == false) {
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
    
   [[AnalyticEngine new]DownloadCTAClicked];
   [[DownloadHelper shared] startDownloadItemWith:self.currentItem];
}

-(void)getContentDetailForCastingItem:(NSString*)content_id country:(NSString*)country translation:(NSString*)language :(void (^)(VODContentDetailsDataModel* model, NSString* drmToken))success
    {
        NSString *urlString = [NSString stringWithFormat:@"%@/%@", BaseUrls.vodContentDetails, content_id];
        NSDictionary *param =@{@"country":country, @"translation":language};
        NSDictionary *headers = @{@"Content-Type":@"application/json",@"X-Access-Token":ZEE5UserDefaults.getPlateFormToken};
        [[NetworkManager sharedInstance] makeHttpGetRequest:urlString requestParam:param requestHeaders:headers withCompletionHandler:^(id result) {
            VODContentDetailsDataModel *model = [VODContentDetailsDataModel initFromJSONDictionary:result];
            
            if (model.isDRM) {
                [self getDRMToken:model.identifier andDrmKey:model.drmKeyID withCompletionHandler:^(id  _Nullable result) {
                    NSString *drmToken = [result valueForKey:@"drm"];
                
                    success(model,drmToken);
                }
                     failureBlock:^(ZEE5SdkError * _Nullable error) {
                         [self notifiyError:error];
                        
                }];
            }
        }
        failureBlock:^(ZEE5SdkError *error) {
            [self notifiyError:error];
        }];
    }
//MARK:- Telco User checked;

-(void)Telcouser:(BOOL)istelco param:(NSString *)Message{
    _isTelco = istelco;
    _customControlView.partnerLblTxt.text = [NSString stringWithFormat: @"< %@",Message];
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
    
//    Zee5MenuModel *model2 = [[Zee5MenuModel alloc] init];
//    if ([self.selectedSubtitle.lowercaseString isEqualToString:@"Off".lowercaseString]) {
//        model2.imageName = @"t";
//        model2.isSelected = true;
//    }
//    else {
//        model2.imageName = @"";
//        model2.isSelected = false;
//    }
//
//    model2.title = @"Off";
//    model2.type = 2;
//    [models addObject:model2];
    
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


@end

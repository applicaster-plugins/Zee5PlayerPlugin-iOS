//
//  Zee5PlayerPlugin.m
//  ZEE5PlayerSDK
//
//  Created by Mani on 29/05/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

#import "Zee5PlayerPlugin.h"
#import <PlayKit/PlayKit-Swift.h>
#import <PlayKit_IMA/PlayKit_IMA-Swift.h>
#import "FormPostFairPlayLicenseProvider.h"
#import "FormRequestParamsAdapter.h"
#import "Zee5PlayerPlugin/Zee5PlayerPlugin-Swift.h"
#import <Zee5PlayerPlugin/ZEE5PlayerSDK.h>
#import <ConvivaSDK/ConvivaSDK-iOS-umbrella.h>
#import "SingletonClass.h"
#import "Utility.h"


#define Conviva_Application_Name @"ZEE5-iOS App"
#define Conviva_Player_Name @"ZEE5-KalturaPlayer"


@interface Zee5PlayerPlugin() // <PlayerDelegate>

@property CurrentItem *currentItem;
@property (strong, nonatomic) FormPostFairPlayLicenseProvider *fairplayProvider;
@property (strong, nonatomic) FormRequestParamsAdapter *requestAdapter;
@property (strong, nonatomic) NSString *adStremUrl;
@property (strong, nonatomic) NSString *Direction;  ///   Use In analytics when Seekbar chnaged
@property (nonatomic) int PlayerStartTime;          ///   Use In analytics when Seekbar chnaged
@property (nonatomic) int PlayerEndTime;            ///   Use In analytics when Seekbar chnaged
@property (nonatomic) int adCount;
@property(nonatomic) BOOL SubtitleError;



@end


@implementation Zee5PlayerPlugin


static Zee5PlayerPlugin *sharedManager = nil;

+ (Zee5PlayerPlugin *)sharedInstance
{
    if (sharedManager)
    {
        return sharedManager;
    }
    static dispatch_once_t  t = 0;
    
    dispatch_once(&t, ^{
        sharedManager = [[Zee5PlayerPlugin alloc] init];
    });
    
    return sharedManager;
}

// MARK:- Initialize Player method Using CurrentItem

-(void)initializePlayer : (PlayerView *)playbackView andItem :(CurrentItem *)currentItem andLicenceURI:(NSString *)licence  andBase64Cerificate:(NSString *)cerificate
{
    if (currentItem == nil) {
        return;
    }
    
    self.fairplayProvider = [[FormPostFairPlayLicenseProvider alloc] init];
    self.currentItem = currentItem;
    _adCount = 0;

    if (self.player)
    {
        [self.player stop];
    }

    NSString *contentStringURL = self.currentItem.hls_Url;
    
    if (contentStringURL == nil || [contentStringURL length] == 0) {
        return;
    }
    
    PluginConfig *pluginConfig = [self createPluginConfig];
    self.player = [[PlayKitManager sharedInstance] loadPlayerWithPluginConfig:pluginConfig];
    
    [self registerPlayerEvents];
    
    self.player.view = playbackView;

    NSString *entryId = self.currentItem.content_id;

#if TARGET_IPHONE_SIMULATOR
    NSURL *contentURL = [[NSURL alloc] initWithString:@"https://www.csiamerica.com/sites/default/files/CSiBridge_-_07_Staged_Analysis.mp4"];
    
    PKMediaSource *source = [[PKMediaSource alloc] init:entryId contentUrl:contentURL mimeType:nil drmData:nil mediaFormat:MediaFormatMp4];
    PKMediaEntry *mediaEntry = [[PKMediaEntry alloc] init:entryId sources:@[source] duration:-1];
#else
    NSURL *contentURL = [[NSURL alloc] initWithString:contentStringURL];
    
    self.fairplayProvider.customData = self.currentItem.drm_token;
    self.player.settings.fairPlayLicenseProvider = self.fairplayProvider;

    FairPlayDRMParams *fairplayParams = [[FairPlayDRMParams alloc] initWithLicenseUri:licence base64EncodedCertificate:cerificate];
    
    MediaFormat mediaFormat = MediaFormatHls;
    
    if (!currentItem.isDRM) {
        if ([contentStringURL containsString:@".mp3"]) {
            mediaFormat = MediaFormatMp3;
        }
        else if ([contentStringURL containsString:@".mp4"]) {
            mediaFormat = MediaFormatMp4;
        }
        else if ([contentStringURL containsString:@".wvm"]) {
            mediaFormat = MediaFormatWvm;
        }
    }
    
    PKMediaSource *source = [[PKMediaSource alloc] init:entryId contentUrl:contentURL mimeType:nil drmData:@[fairplayParams] mediaFormat:mediaFormat];
    
    PKMediaEntry *mediaEntry = [[PKMediaEntry alloc] init:entryId sources:@[source] duration:-1];
#endif

    
    // Can set external subtitles only when the duration is known
    if (_SubtitleError == true) {
           mediaEntry.externalSubtitles = nil;
    }
    else if (currentItem.duration > 0 && ![currentItem.vttThumbnailsUrl containsString:@"mp4"] ) {
        mediaEntry.externalSubtitles = [self externalSubtitlesFrom:currentItem.subTitles vttThumbnailsUrl:currentItem.vttThumbnailsUrl duration:currentItem.duration];
    }
    // create media config
    MediaConfig *mediaConfig = [[MediaConfig alloc] initWithMediaEntry:mediaEntry startTime:0];
    _SubtitleError = false;
    if (ZEE5PlayerSDK.getDevEnvironment == development ) {
        self.requestAdapter = [[FormRequestParamsAdapter alloc] init];
        self.player.settings.contentRequestAdapter = self.requestAdapter;
        self.requestAdapter.header = @{@"z5globe": @"true"};
    }
    [self.player prepare:mediaConfig];
    [self.player play];

}

//MARK:- Create Plugin Config For Advertisement

- (PluginConfig *)createPluginConfig
{
    NSMutableDictionary *pluginConfigDict = [NSMutableDictionary new];
    IMAConfig *imaConfig = [IMAConfig new];
    NSString *vmapString = [self vmapTagBuilder];
    if (vmapString.length == 0 || vmapString == nil ||[vmapString isKindOfClass:[NSNull class]] || [[SingletonClass sharedManager]hlsErrorCount] == 1) {

        imaConfig.adTagUrl = @"";
        imaConfig.adsResponse = @"";
    }else
    {
        NSArray *VideoMimetypes = [[NSArray alloc]initWithObjects:@"application/x-mpegURL",@"application/dash+xml",@"video/mp4", nil];
           PlayKitManager.logLevel = PKLogLevelWarning;
           imaConfig.adsResponse = vmapString;
           imaConfig.requestTimeoutInterval = 10;
           imaConfig.videoMimeTypes = VideoMimetypes;
           imaConfig.alwaysStartWithPreroll = true;
         //  imaConfig.enableDebugMode = true;
           imaConfig.videoControlsOverlays = [[SingletonClass sharedManager]ViewsArray];
    }
    pluginConfigDict[IMAPlugin.pluginName] = imaConfig;
    return [[PluginConfig alloc] initWithConfig:pluginConfigDict];
}



- (void)listSubviewsOfView:(UIView *)view {
    NSArray *subviews = [view subviews];

    if ([subviews count] == 0) return; // COUNT CHECK LINE

    for (UIView *subview in subviews) {
        [self listSubviewsOfView:subview];
    }
}


// MARK:- Initialize Player method Using Url

-(void)initializePlayer : (PlayerView *)playbackView andURL :(NSString *)urlString andToken:(NSString *)token playbacksession_id:(NSString *)playbacksession_id
{
    self.requestAdapter = [[FormRequestParamsAdapter alloc] init];

    if (self.player)
    {
        [self.player stop];
    }
    PluginConfig *pluginConfig = [self createPluginConfig];

    self.player = [[PlayKitManager sharedInstance] loadPlayerWithPluginConfig:pluginConfig];
    self.player.settings.contentRequestAdapter = self.requestAdapter;

    [self registerPlayerEvents];
    
    self.player.view = playbackView;
    
    
    NSString *contentStringURL = urlString;
    if(![contentStringURL containsString:@"hdnea="] && ![token isEqualToString:@""])
    {
        contentStringURL = [NSString stringWithFormat:@"%@%@",contentStringURL,token];
    }
    
    
#if TARGET_IPHONE_SIMULATOR
    NSURL *contentURL = [[NSURL alloc] initWithString:@"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"];
#else
    NSURL *contentURL = [[NSURL alloc] initWithString:contentStringURL];
#endif
    
    NSString *entryId = self.currentItem.content_id;
    
    PKMediaSource *source = [[PKMediaSource alloc] init:entryId contentUrl:contentURL mimeType:nil drmData:nil mediaFormat:MediaFormatMp4];
    
    PKMediaEntry *mediaEntry = [[PKMediaEntry alloc] init:entryId sources:@[source] duration:-1];
    
    // create media config
    MediaConfig *mediaConfig = [[MediaConfig alloc] initWithMediaEntry:mediaEntry startTime:0];

    
    self.requestAdapter.header = @{@"x-playback-session-id": playbacksession_id};
    
    [self.player prepare:mediaConfig];
    [self.player play];
}

//MARK: Capture player Ad events

- (void)createConvivaAdSeesionWithAdEvent: (PKEvent*) event
{
    
    NSString *stremType = @"Unknown";
    if (self.currentItem.streamType == CONVIVA_STREAM_VOD) {
        stremType = @"Vod";
    }
    else if (self.currentItem.streamType == CONVIVA_STREAM_LIVE) {
        stremType = @"Live";
    }

    NSDictionary *dict = [[NSDictionary alloc] init];
    NSString *AdDuration = @"0";
    
    if (event.adInfo.duration > 0) {
        AdDuration = [NSString stringWithFormat:@"%f",event.adInfo.duration];
    }
    
    dict = @{
             @"assetName": event.adInfo.title,
             @"applicationName": Conviva_Application_Name,
             @"streamType": stremType,
             @"duration": AdDuration,
             @"streamUrl":@"NA" ,
             @"adPosition":[NSString stringWithFormat:@"%ld",(long)event.adInfo.adPosition],
             @"adId": event.adInfo.adId,
             @"advertiserName":event.adInfo.advertiserName
             };
    
    /// Ad custom tags
    NSString *isLive = @"false";
    if (self.currentItem.isDRM) {
        isLive = @"true";
    }
    
    NSString *position = @"Pre-roll";
    NSString *startEvent = @"progress";
    
    if (event.adInfo.positionType == AdPositionTypePreRoll) {
        position = @"Pre-roll";
        startEvent = @"progress";
    }
    else if (event.adInfo.positionType == AdPositionTypeMidRoll) {
        position = @"Mid-roll";
        startEvent = @"firstQuartile";
    }
    else if (event.adInfo.positionType == AdPositionTypePostRoll) {
        position = @"Post-roll";
        startEvent = @"thirdQuartile";
    }
    
    NSString *country = [Utility getCountryName];   //  // "India = 21665149170", "ExIndia = 21800039520"
    NSString *countryAdCode = [country.lowercaseString containsString: @"india"] ? @"21665149170" : @"21800039520";
    
    NSString *userId = ZEE5PlayerSDK.getUserId ;
         if (ZEE5PlayerSDK.getUserTypeEnum == Guest) {
             userId = ZEE5UserDefaults.getUserToken;
         }
    
    NSDictionary *tags = [[NSDictionary alloc] init];
    tags = @{
             @"streamUrl": @"NA",
             
             @"isLive": isLive,
             @"playerName": Conviva_Player_Name,
             @"viewerId": userId,
             
             @"c3.ad.technology": @"Client Side",   // "Server Side" or "Client Side"
             @"c3.ad.id": event.adInfo.adId,
             @"c3.ad.system": @"NA",  // "Freewheel", "Innovid", "Extreme IO","NA"
             
             @"c3.ad.position": position,
             @"c3.ad.isSlate": @"false",
             @"c3.ad.mediaFileApiFramework": @"VPAID",   // "VPAID", "NA"
             
             @"c3.ad.adStitcher": @"NA",  // "Uplynk", "Google DAI", "Google Anvato", "YoSpace","NA"
             @"c3.ad.unitName": @"NA",
             @"c3.ad.sequence": @"NA",
             
             @"c3.ad.creativeId": event.adInfo.creativeId,
             @"c3.ad.creativeName": @"NA",
             @"c3.ad.breakId": @"NA",
             
             @"c3.ad.category": @"NA",
             @"c3.ad.classification": @"National Ad",  // "National Ad", "Local Ad", "Regional Ad","NA"
             @"c3.ad.advertiser": @"McDonald's Corp",  // "McDonald's Corp", "NA"
             
             @"c3.ad.advertiserCategory": @"Food and Drinks",  // "CPG - Beauty:Health - Cough, Cold, Pain Relief, Allergy","NA"
             @"c3.ad.advertiserId": @"NA",
             @"c3.ad.campaignName": @"NA",
             
             @"c3.ad.dayPart": @"Primetime", // "Primetime", "Daytime", "Latenight", "Vintage", "Classics", "News", "Originals"
             @"c3.ad.adManagerName": @"PlayKit_IMA",
             @"c3.ad.adManagerVersion": @"v1.7.0",
             
             @"c3.ad.sessionStartEvent": startEvent,   // "firstQuartile", "midpoint", "thirdQuartile", "complete", "progress", "start"
             @"c3.indiaexindia": countryAdCode    // "India = 21665149170", "ExIndia = 21800039520"
             };

    AnalyticEngine *engine = [[AnalyticEngine alloc] init];
    if (AdEvent.adsRequested)
    {
        [engine setupConvivaAdSessionWith:dict customTags:tags];
        [engine SetupMixpanelAnalyticsWith:dict tags:tags];
        [engine AdViewAnalytics];
        _adCount++;
        [engine AdViewNumberWithAdNo:_adCount];
        [[ZEE5PlayerManager sharedInstance]hideLoaderOnPlayer];
    }
}

//MARK:- PlayerAD Events

-(void)registerPlayerForAdEvents
{
    __weak typeof(self) weakSelf = self;
     AnalyticEngine *engine = [[AnalyticEngine alloc] init];
    
    [self.player addObserver: self event: AdEvent.adStarted block:^(PKEvent * _Nonnull event)
     {
        [weakSelf createConvivaAdSeesionWithAdEvent: event];
        [weakSelf ConvivaErrorCode:event.error.code platformCode:@"010" severityCode:1 andErrorMsg:@"Ad Started"];
        [[ZEE5PlayerManager sharedInstance]hideLoaderOnPlayer];
        [[ZEE5PlayerManager sharedInstance] startAd:event];
    }];
    
    [self.player addObserver: self event: AdEvent.adComplete block:^(PKEvent * _Nonnull event) {
        [engine AdCompleteAnalytics];
        [engine AdWatchDurationAnalytics];
        [[ZEE5PlayerManager sharedInstance] endAd];
    }];
    
    [self.player addObserver: self event: AdEvent.adSkipped block:^(PKEvent * _Nonnull event) {
        [[ZEE5PlayerManager sharedInstance] endAd];
    }];
    
    [self.player addObserver: self event: AdEvent.adStartedBuffering block:^(PKEvent * _Nonnull event) {
    }];
    
    //// Extra Ad events
    
    [self.player addObserver: self event: AdEvent.adBreakReady block:^(PKEvent * _Nonnull event) {
    }];
    
    [self.player addObserver: self event: AdEvent.allAdsCompleted block:^(PKEvent * _Nonnull event) {
        if ([[SingletonClass sharedManager]isAdIntegrate] == YES) {
            [[ZEE5PlayerManager sharedInstance] onComplete];
            [engine updatePlayerStateWithState: ConvivaPlayerStateSTOPPED];
            [engine cleanupVideoSesssion];
        }
    }];
    
    [self.player addObserver: self event: AdEvent.adComplete block:^(PKEvent * _Nonnull event) {
       
    }];
    [self.player addObserver: self event: AdEvent.adClicked block:^(PKEvent * _Nonnull event) {
        [engine AdClickedAnalytics];
    }];
    
    [self.player addObserver: self event: AdEvent.adFirstQuartile block:^(PKEvent * _Nonnull event) {
    }];
    
    [self.player addObserver: self event: AdEvent.adLoaded block:^(PKEvent * _Nonnull event) {
    }];
    
    [self.player addObserver: self event: AdEvent.adLog block:^(PKEvent * _Nonnull event) {
    }];
    
    [self.player addObserver: self event: AdEvent.adMidpoint block:^(PKEvent * _Nonnull event) {
    }];
    
    [self.player addObserver: self event: AdEvent.adPaused block:^(PKEvent * _Nonnull event) {
        [[ZEE5PlayerManager sharedInstance]pauseAd];
    }];
    
    [self.player addObserver: self event: AdEvent.adResumed block:^(PKEvent * _Nonnull event) {
    }];
    
    [self.player addObserver: self event: AdEvent.adSkipped block:^(PKEvent * _Nonnull event) {
        [engine AdSkipedAnlytics];
    }];
    
    [self.player addObserver: self event: AdEvent.adStarted block:^(PKEvent * _Nonnull event) {
    }];
    
    [self.player addObserver: self event: AdEvent.adTapped block:^(PKEvent * _Nonnull event) {
    }];
    
    [self.player addObserver: self event: AdEvent.adThirdQuartile block:^(PKEvent * _Nonnull event) {
    }];
    
    [self.player addObserver: self event: AdEvent.adCuePointsUpdate block:^(PKEvent * _Nonnull event) {
    }];
    
    [self.player addObserver: self event: AdEvent.adStartedBuffering block:^(PKEvent * _Nonnull event) {
    }];
    
    [self.player addObserver: self event: AdEvent.adPlaybackReady block:^(PKEvent * _Nonnull event) {
    }];
    
    [self.player addObserver: self event: AdEvent.requestTimedOut block:^(PKEvent * _Nonnull event) {
    }];
    
    [self.player addObserver: self event: AdEvent.adsRequested block:^(PKEvent * _Nonnull event) {
    }];
    [self.player addObserver: self event: AdEvent.adDidRequestContentResume block:^(PKEvent * _Nonnull event) {
        [engine EndAdbreak];
    }];
    [self.player addObserver: self event: AdEvent.adDidRequestContentPause block:^(PKEvent * _Nonnull event) {
    
    }];
    
    [self.player addObserver: self event: AdEvent.error block:^(PKEvent * _Nonnull event) {
        [weakSelf ConvivaErrorCode:event.error.code platformCode:@"003" severityCode:1 andErrorMsg:@"Ad Playback Error"];
    }];
}

-(void)registerPlayerEvents
{
    [self handlePlayerError];
    [self registerPlayerMetaData];
    [self registerPlayEvent];
    [self registerDurationChangedEvent];
    [self registerPlayerEventStateChangedEvent];
    [self registerBufferEvent];
    [self registerEndEvent];
    [self registerErrorEvent];
    
    if (![_currentItem.asset_type isEqualToString:@"9"])
    {
        [self handlePlayerSeekEvents];
    }
    [self currentBitrateHandler];
    
    // Ad Events
    [self registerPlayerForAdEvents];
    
}

//MARK:- Handle basic event Of Player (Play, Pause, CanPlay ..  Failed)


-(void)ConvivaErrorCode:(NSInteger)Code platformCode:(NSString *)Platform severityCode:(NSInteger)Severity andErrorMsg:(NSString *)ErrorMsg{
    NSString *ErrorMSG = [NSString stringWithFormat:@"%@ - %ld",ErrorMsg,Code];
    if (Code == 0) {ErrorMSG = [NSString stringWithFormat:@"%@",ErrorMsg];}
    NSString *ErrorCode = [NSString stringWithFormat:@"CE_IOS_%@",Platform];
    NSDictionary *dict = @{@"errorCode":ErrorCode,@"errorMessage":ErrorMSG};
    NSString *Message = [NSString stringWithFormat:@"%@",dict];
    NSDictionary *infodict = @{@"infoMessage" : Message};
    [[AnalyticEngine shared]updateMetadataWith:infodict];
    if ([Platform isEqualToString:@"010"]) {
        return;
    }
    [[AnalyticEngine shared]setupConvivvaErrorMsgWith:Message COSeverity:Severity];
}

- (void)handlePlayerError {
    
    __weak typeof(self) weakSelf = self;
    
    [self.player addObserver:self
                       event:PlayerEvent.error
                       block:^(PKEvent * _Nonnull event) {
        // 7002 when i pass certificate Nil value
        // 7000 when Url takes wrong Url
        #if DEBUG
        NSLog(@"**** error discriPtion **** %@",event.error.localizedDescription);
          #endif
        if (event.error.code >= 7000)
        {
             weakSelf.SubtitleError = true;
            [[ZEE5PlayerManager sharedInstance]handleHLSError:event.error.code];
        }
        [[AnalyticEngine new]PlayBackErrorWith:event.error.localizedFailureReason];
    }];
    
    [self.player addObserver:self
                      events:@[PlayerEvent.errorLog]
                       block:^(PKEvent * _Nonnull event){
    }];
}

-(void)registerPlayerMetaData{
    
    [self.player addObserver:self
                       event:PlayerEvent.loadedMetadata
                       block:^(PKEvent * _Nonnull event) {
                        
        [[AnalyticEngine shared]ConsumptionAnalyticEvents];
        [[ZEE5PlayerManager sharedInstance]LocalStorageArray];

                       }];
}
- (void)registerPlayEvent {
    
    AnalyticEngine *engine = [[AnalyticEngine alloc] init];
    
    [self.player addObserver:self
                       event:PlayerEvent.playing
                       block:^(PKEvent * _Nonnull event) {
        [[AnalyticEngine shared]VideoPlayAnalytics];
        [[ZEE5PlayerManager sharedInstance] onPlaying];
        [engine updatePlayerStateWithState:ConvivaPlayerStatePLAYING];
    }];
    
    [self.player addObserver:self
                      events:@[PlayerEvent.pause]
                       block:^(PKEvent * _Nonnull event){
    }];
    
    [self.player addObserver:self
                      events:@[PlayerEvent.play]
                       block:^(PKEvent * _Nonnull event){
        [engine updatePlayerStateWithState:ConvivaPlayerStatePLAYING];
    }];
    
    [self.player addObserver:self
                      events:@[PlayerEvent.stopped]
                       block:^(PKEvent * _Nonnull event){
        if ( [[SingletonClass sharedManager]hlsErrorCount] == 1) {
            return;
        }
        [engine updatePlayerStateWithState:ConvivaPlayerStateSTOPPED];
        [engine cleanupVideoSesssion];
    }];
}

// Handle Duration Changes
- (void)registerDurationChangedEvent {
    
    [self.player addObserver:self
                      events:@[PlayerEvent.durationChanged]
                       block:^(PKEvent * _Nonnull event) {
        if (event.currentTime != NULL)
        {
            [[ZEE5PlayerManager sharedInstance] onDurationUpdate:event];
        }
    }];
    
    [self.player addObserver:self
                      events:@[PlayerEvent.playheadUpdate]
                       block:^(PKEvent * _Nonnull event) {
        if (event.currentTime !=NULL) {
            [[ZEE5PlayerManager sharedInstance] onTimeChange:event];
        }
    }];
}



// Handle State Changes
- (void)registerPlayerEventStateChangedEvent {
    [self.player addObserver:self
                      events:@[PlayerEvent.stateChanged]
                       block:^(PKEvent * _Nonnull event) {
        PlayerState oldState = event.oldState;
        PlayerState newState = event.newState;
        
        
        if (newState == PlayerStateBuffering) {
            [[AnalyticEngine shared]updatePlayerStateWithState:ConvivaPlayerStateBUFFERING];
        }
        if (newState == PlayerStateReady) {
            [[ZEE5PlayerManager sharedInstance]hideLoaderOnPlayer];
        }
    }];
}

// Get Current Bitrate
- (void)currentBitrateHandler {
    [self.player addObserver: self event: PlayerEvent.videoTrackChanged block:^(PKEvent * _Nonnull event) {
        
        NSInteger videoBitrate = [event.bitrate integerValue] / 1000;
        [[AnalyticEngine shared]updateVideoBitrateWith:videoBitrate];
    }];
}

// Handle Seek Changes
- (void)handlePlayerSeekEvents {
    
    AnalyticEngine *engine = [[AnalyticEngine alloc] init];
    __weak typeof(self) weakSelf = self;
    
    [self.player addObserver:self
                      events:@[PlayerEvent.seeking]
                       block:^(PKEvent * _Nonnull event) {
        
        NSTimeInterval playerTime = [weakSelf getCurrentTime];
        weakSelf.PlayerStartTime = playerTime;
        [engine setSeekStartTimeWithDuration: weakSelf.PlayerStartTime];
    }];
    
    [self.player addObserver:self
                      events:@[PlayerEvent.seeked]
                       block:^(PKEvent * _Nonnull event) {
        
        NSTimeInterval playerTime = [weakSelf getCurrentTime];
        weakSelf.PlayerEndTime = playerTime;
        
        if(weakSelf.PlayerEndTime < weakSelf.PlayerStartTime){
            weakSelf.Direction = @"Reverse";}else{
                weakSelf.Direction = @"Forward";
            }
        [engine setSeekEndTimeWithDuration: weakSelf.PlayerEndTime];
        [engine VideoWatchPercentCalcWith:weakSelf.Direction];
        [engine seekValueChangeAnalyticsWith:weakSelf.Direction Starttime:weakSelf.PlayerStartTime EndTime:weakSelf.PlayerEndTime];
    }];
}

-(void)registerBufferEvent {
    
    AnalyticEngine *engine = [[AnalyticEngine alloc] init];
    
    [self.player addObserver:self
                      events:@[PlayerEvent.playbackStalled]
                       block:^(PKEvent * _Nonnull event) {
        [[ZEE5PlayerManager sharedInstance] onBuffring];
        [engine updatePlayerStateWithState: ConvivaPlayerStateBUFFERING];
        [engine playerbufferStartAnalytics];
    }];
    
    [self.player addObserver:self
                      events:@[PlayerEvent.loadedTimeRanges]
                       block:^(PKEvent * _Nonnull event) {
        [[ZEE5PlayerManager sharedInstance] onBuffringValueChange:event];
    }];
}

-(void)registerEndEvent {
    
    AnalyticEngine *engine = [[AnalyticEngine alloc] init];
    [self.player addObserver:self
                      events:@[PlayerEvent.ended]
                       block:^(PKEvent * _Nonnull event) {
        [[ReportingManager sharedInstance]deleteWatchHIstory];
        [engine  videoWatchDurationAnalytic];
        if (ZEE5PlayerSDK.getUserTypeEnum == Premium || [[SingletonClass sharedManager]isAdIntegrate] == NO) {
            [[ZEE5PlayerManager sharedInstance] onComplete];
            [engine updatePlayerStateWithState: ConvivaPlayerStateSTOPPED];
            [engine cleanupVideoSesssion];
        }
    }];
}
// Handle Player Errors
- (void)registerErrorEvent {
    
    [self.player addObserver:self events:@[PlayerEvent.error] block:^(PKEvent * _Nonnull event) {
        NSError *error = event.error;
        if (error && (error.code == PKErrorCode.AssetNotPlayable || error.code == PKErrorCode.FailedToLoadAssetFromKeys)) {
            
        }
    }];
}



-(NSTimeInterval )getDuration
{
    return self.player.duration;
}
-(NSTimeInterval )getCurrentTime
{
    return self.player.currentTime;
}
-(void)setSeekTime:(NSInteger)value
{
    [self.player seekTo:value];
}
- (BOOL)playerShouldPlayAd:(id<Player>)player
{
    return YES;
}

-(NSString *)getCurrentAuditrack
{
    return self.player.currentAudioTrack;
}
-(NSString *)getCurrenttextTrack
{
    return self.player.currentTextTrack;
}


//MARK:- VMAP Builder (Advertisement)

-(NSString *)vmapTagBuilder
{
    NSString *totalString = @"";
    NSString *part1 = @"<vmap:VMAP xmlns:vmap=\"http://www.iab.net/videosuite/vmap\" version=\"1.0\">\n";
    NSString *part3 = @"\n</vmap:VMAP>";
    NSString *part2 = @"";
    NSString *range =@"";
    if (self.currentItem.googleAds.count >0) {
        for (ZEE5AdModel *model in self.currentItem.googleAds) {
            if ([model.time.lowercaseString isEqualToString:@"pre"] && [model.tag_name containsString:@"bumper"]) {
                part2 = [NSString stringWithFormat:@"%@%@%@%@%@%@",part2,@"<vmap:AdBreak timeOffset=\"start\" breakType=\"linear\" breakId=\"preroll\">\n<vmap:AdSource id=\"",model.tag_name,@"\" allowMultipleAds=\"false\" followRedirects=\"true\">\n<vmap:AdTagURI templateType=\"vast3\">\n<![CDATA[\n",model.tag,@"]]>\n</vmap:AdTagURI>\n</vmap:AdSource>\n<vmap:Extensions>\n<vmap:Extension type=\"bumper\" suppress_bumper=\"true\"/>\n</vmap:Extensions>\n</vmap:AdBreak>"];
            }
            else if ([model.time.lowercaseString isEqualToString:@"pre"]){
                part2 = [NSString stringWithFormat:@"%@%@%@%@%@%@",part2,@"<vmap:AdBreak timeOffset=\"start\" breakType=\"linear\" breakId=\"preroll\">\n<vmap:AdSource id=\"",model.tag_name,@"\" allowMultipleAds=\"false\" followRedirects=\"true\">\n<vmap:AdTagURI templateType=\"vast3\">\n<![CDATA[\n",model.tag,@"]]>\n</vmap:AdTagURI>\n</vmap:AdSource>\n</vmap:AdBreak>"];
            }
            else if ([model.time.lowercaseString isEqualToString:@"post"]) {
                part2 = [NSString stringWithFormat:@"%@%@%@%@%@%@",part2,@"<vmap:AdBreak timeOffset=\"end\" breakType=\"linear\" breakId=\"postroll\">\n<vmap:AdSource id=\"",model.tag_name,@"\" allowMultipleAds=\"false\" followRedirects=\"true\">\n<vmap:AdTagURI templateType=\"vast3\">\n<![CDATA[\n",model.tag,@"]]>\n</vmap:AdTagURI>\n</vmap:AdSource>\n</vmap:AdBreak>"];
            }
            else
            {
                range = [model.tag_name substringWithRange:NSMakeRange(0, 9)];
                NSString *ModelTime = [Utility getDurationForAd:[(model.time)intValue] total:0];
                part2 = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@",part2,@"<vmap:AdBreak timeOffset=\"",ModelTime,@"\" breakType=\"linear\" breakId=\"",range,@"\">\n<vmap:AdSource id=\"",model.tag_name,@"\" allowMultipleAds=\"false\" followRedirects=\"true\">\n<vmap:AdTagURI templateType=\"vast3\">\n<![CDATA[\n",model.tag,@"]]>\n</vmap:AdTagURI>\n</vmap:AdSource>\n</vmap:AdBreak>"];
                
            }
        }
        
        totalString = [NSString stringWithFormat:@"%@%@%@",part1,part2,part3];
    #if DEBUG
        NSLog(@"**** VAST String **** %@",totalString);
    #endif
    }else
    {
        totalString = @"";
    }
    return totalString;
}

// MARK: Subtitles

- (nullable NSArray<PKExternalSubtitle *> *)externalSubtitlesFrom:(NSArray *)subtitles vttThumbnailsUrl:(NSString *)vttThumbnailsUrl duration:(NSTimeInterval)duration {
    NSMutableArray<PKExternalSubtitle *> *result = [[NSMutableArray alloc] init];
        
    if (![vttThumbnailsUrl containsString:@"/thumbnails/index.vtt"]) {
        return nil;
    }
    
    NSString *baseUrl = [vttThumbnailsUrl stringByReplacingOccurrencesOfString:@"/thumbnails/index.vtt" withString:@""];

    for (NSString *subtitle in subtitles) {
        NSString *vttUrl = [NSString stringWithFormat:@"%@/manifest-%@.vtt", baseUrl, subtitle];
        
        PKExternalSubtitle *externalSubtitle = [[PKExternalSubtitle alloc] initWithId:[subtitle stringByAppendingString:@"_vtt"]
                                                                                 name:[Utility getLanguageStringFromId:subtitle]
                                                                             language:subtitle
                                                                         vttURLString:vttUrl
                                                                             duration:duration
                                                                            isDefault:false
                                                                           autoSelect:false
                                                                               forced:false
                                                                      characteristics:@""];
        
        [result addObject:externalSubtitle];
        break;
    }
    return result;
}

@end

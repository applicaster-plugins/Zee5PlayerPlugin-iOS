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


#define Conviva_Application_Name @"ZEE5"


@interface Zee5PlayerPlugin() // <PlayerDelegate>

@property CurrentItem *currentItem;
@property (strong, nonatomic) FormPostFairPlayLicenseProvider *fairplayProvider;
@property (strong, nonatomic) FormRequestParamsAdapter *requestAdapter;
@property (strong, nonatomic) NSString *adStremUrl;
@property (strong, nonatomic) NSString *Direction;  ///   Use In analytics when Seekbar chnaged
@property (nonatomic) int PlayerStartTime;          ///   Use In analytics when Seekbar chnaged
@property (nonatomic) int PlayerEndTime;            ///   Use In analytics when Seekbar chnaged

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
    self.fairplayProvider = [[FormPostFairPlayLicenseProvider alloc] init];
    self.currentItem = currentItem;

    if (self.player)
    {
        [self.player stop];
    }

    NSString *contentStringURL = self.currentItem.hls_Url;
//    if (self.currentItem.isDRM || [currentItem.asset_type isEqualToString:@"0"] || [currentItem.asset_type isEqualToString:@"9"] )
//    {
//        contentStringURL = self.currentItem.hls_Url;
//    }
//    else
//    {
//        contentStringURL = self.currentItem.hls_Full_Url;
//    }
    
       PluginConfig *pluginConfig = [self createPluginConfig];
       self.player = [[PlayKitManager sharedInstance] loadPlayerWithPluginConfig:pluginConfig];
       self.player.settings.fairPlayLicenseProvider = self.fairplayProvider;

       [self registerPlayerEvents];

       self.player.view = playbackView;

    NSURL *contentURL = [[NSURL alloc] initWithString:contentStringURL];
    NSString *entryId = self.currentItem.content_id;

    FairPlayDRMParams* fairplayParams = [[FairPlayDRMParams alloc] initWithLicenseUri:licence base64EncodedCertificate:cerificate];

    PKMediaSource* source = [[PKMediaSource alloc] init:entryId contentUrl:contentURL mimeType:nil drmData:@[fairplayParams] mediaFormat:MediaFormatHls];

    PKMediaEntry *mediaEntry = [[PKMediaEntry alloc] init:entryId sources:@[source] duration:-1];

    // create media config
    MediaConfig *mediaConfig = [[MediaConfig alloc] initWithMediaEntry:mediaEntry startTime:0];

    self.fairplayProvider.customData = self.currentItem.drm_token;
    [self.player prepare:mediaConfig];
    [self.player play];

}

//MARK:- Create Plugin Config For Advertisement

- (PluginConfig *)createPluginConfig
{
    NSMutableDictionary *pluginConfigDict = [NSMutableDictionary new];
    IMAConfig *imaConfig = [IMAConfig new];
    NSString *vmapString = [self vmapTagBuilder];
    NSLog(@"|** VMapTagBuilder **::** %@",vmapString);

    imaConfig.adsResponse = vmapString;
    pluginConfigDict[IMAPlugin.pluginName] = imaConfig;
    return [[PluginConfig alloc] initWithConfig:pluginConfigDict];
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
    
    NSURL *contentURL = [[NSURL alloc] initWithString:contentStringURL];
    
    NSString *entryId = self.currentItem.content_id;
    
    PKMediaSource* source = [[PKMediaSource alloc] init:entryId contentUrl:contentURL mimeType:nil drmData:nil mediaFormat:MediaFormatMp4];
    
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
    NSLog(@"|*** create ConvivaAdSeesion");
    
    NSString *stremType = @"Unknown";
    if (self.currentItem.streamType == CONVIVA_STREAM_VOD) {
        stremType = @"Vod";
    }
    else if (self.currentItem.streamType == CONVIVA_STREAM_LIVE) {
        stremType = @"Live";
    }
    NSLog(@"%@",stremType);
    NSDictionary *dict = [[NSDictionary alloc] init];
    
    NSLog(@"|*** AdObject EventTitle: %@ *** streamUrl: %@ *** Adtotaltime: %d", event.adInfo.title, event.adTagUrl, [event.adMediaTime intValue]);
    
    dict = @{
             @"assetName": event.adInfo.title,
             @"applicationName": Conviva_Application_Name,
             @"streamType": @"Vod",
             @"duration": @"NA",
             @"streamUrl": @"NA" ,
             @"adPosition":[NSString stringWithFormat:@"%ld",(long)event.adInfo.adPosition],
             @"adId": event.adInfo.adId,
             @"advertiserName":event.adInfo.advertiserName
             };

    NSLog(@"|*** create DONE");
     NSLog(@"|*** Create Ad analytics object:: %@ ***|", dict);
    
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
    
    NSDictionary *tags = [[NSDictionary alloc] init];
    tags = @{
             @"streamUrl": @"NA",
             
             @"isLive": isLive,
             @"playerName": Conviva_Application_Name,
             @"viewerId": ZEE5PlayerSDK.getUserId,
             
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
        NSLog(@"|** AD Requested **|");
        [engine setupConvivaAdSessionWith: dict customTags: tags];
        [engine SetupMixpanelAnalyticsWith:dict tags:tags]; 
    }
   else if (AdEvent.adStarted)
    {
        NSLog(@"|** AD Started **|");
        [engine setupConvivaAdSessionWith: dict customTags: tags];
        [engine AdViewAnalyticsWith:dict tags:tags];
      
    }
    else if (AdEvent.adSkipped)
    {
         NSLog(@"|** AD Skiped **|");
        [engine AdSkipedAnlyticsWith:dict tags:tags];
    }
    else if (AdEvent.adComplete)
    {
        NSLog(@"|** AD Complete **|");
        //[engine AdCompleteAnalyticsWith:dict tags:tags];
      
    }
    else if (AdEvent.adClicked)
    {
        NSLog(@"|** AD Clicked **|");
        [engine AdClickedAnalyticsWith:dict tags:tags];
    }
    else{
        NSLog(@"|** No Add **|");
    }
 
}

//MARK:- PlayerAD Events

-(void)registerPlayerForAdEvents
{
    __weak typeof(self) weakSelf = self;
     AnalyticEngine *engine = [[AnalyticEngine alloc] init];
    
    [self.player addObserver: self event: AdEvent.adStarted block:^(PKEvent * _Nonnull event)
    {
        NSLog(@"|**** AD Started ****|");
        
        // Setup Ad events
        [engine detachVideoPlayer];
        [weakSelf createConvivaAdSeesionWithAdEvent: event];
        [engine updateAdPlayerStateWithState:CONVIVA_PLAYING];
        [[ZEE5PlayerManager sharedInstance]hideLoaderOnPlayer];
    
        
    }];
    
    [self.player addObserver: self event: AdEvent.adComplete block:^(PKEvent * _Nonnull event) {
        NSLog(@"|**** AD Completed ****|");
    
        [engine updateAdPlayerStateWithState: CONVIVA_STOPPED];
        
        [engine attachVideoPlayer];
        [engine cleanupAdSession];
        [[ZEE5PlayerManager sharedInstance]showloaderOnPlayer];
    
    }];
    
    [self.player addObserver: self event: AdEvent.adSkipped block:^(PKEvent * _Nonnull event) {
        NSLog(@"|**** AD Skipped ****|");
    
        [engine updateAdPlayerStateWithState:CONVIVA_STOPPED];
        //MARK:- Temporary Comment Due to crash after Skipped.
       // [weakSelf createConvivaAdSeesionWithAdEvent: event];
        
        [engine attachVideoPlayer];
        [engine cleanupAdSession];
    }];
    
    [self.player addObserver: self event: AdEvent.adStartedBuffering block:^(PKEvent * _Nonnull event) {
        NSLog(@"|**** AD Start Buffering ****|");
        [engine updateAdPlayerStateWithState: CONVIVA_BUFFERING];
        [[ZEE5PlayerManager sharedInstance]showloaderOnPlayer];
    }];
    
    
    //// Extra Ad events
    
    [self.player addObserver: self event: AdEvent.adBreakReady block:^(PKEvent * _Nonnull event) {
        NSLog(@"\n\n******\n\n");
        NSLog(@"|**** GOT AD Event :: AdEvent .adBreakReady ****|");
        NSLog(@"\n\n******\n\n");
    }];
    
    [self.player addObserver: self event: AdEvent.allAdsCompleted block:^(PKEvent * _Nonnull event) {
        NSLog(@"\n\n******\n\n");
        NSLog(@"|**** GOT AD Event :: AdEvent .allAdsCompleted ****|");
        NSLog(@"\n\n******\n\n");
    }];
    
    [self.player addObserver: self event: AdEvent.adComplete block:^(PKEvent * _Nonnull event) {
        NSLog(@"\n\n******\n\n");
        NSLog(@"|**** GOT AD Event :: AdEvent .adComplete ****|");
        NSLog(@"\n\n******\n\n");
    }];
    
    [self.player addObserver: self event: AdEvent.adClicked block:^(PKEvent * _Nonnull event) {
        NSLog(@"\n\n******\n\n");
        NSLog(@"|**** GOT AD Event :: AdEvent .adClicked ****|");
        NSLog(@"\n\n******\n\n");
        
        [weakSelf createConvivaAdSeesionWithAdEvent: event];  // TT
    }];
    
    [self.player addObserver: self event: AdEvent.adFirstQuartile block:^(PKEvent * _Nonnull event) {
        NSLog(@"\n\n******\n\n");
        NSLog(@"|**** GOT AD Event :: AdEvent .adFirstQuartile ****|");
        NSLog(@"\n\n******\n\n");
    }];
    
    [self.player addObserver: self event: AdEvent.adLoaded block:^(PKEvent * _Nonnull event) {
        NSLog(@"\n\n******\n\n");
        NSLog(@"|**** GOT AD Event :: AdEvent .adLoaded ****|");
        NSLog(@"\n\n******\n\n");
    }];
    
    [self.player addObserver: self event: AdEvent.adLog block:^(PKEvent * _Nonnull event) {
        NSLog(@"\n\n******\n\n");
        NSLog(@"|**** GOT AD Event :: AdEvent .adLog ****|");
        NSLog(@"\n\n******\n\n");
    }];
    
    [self.player addObserver: self event: AdEvent.adMidpoint block:^(PKEvent * _Nonnull event) {
        NSLog(@"\n\n******\n\n");
        NSLog(@"|**** GOT AD Event :: AdEvent .adMidpoint ****|");
        NSLog(@"\n\n******\n\n");
    }];
    
    [self.player addObserver: self event: AdEvent.adPaused block:^(PKEvent * _Nonnull event) {
        NSLog(@"\n\n******\n\n");
        NSLog(@"|**** GOT AD Event :: AdEvent .adPaused ****|");
        NSLog(@"\n\n******\n\n");
    }];
    
    [self.player addObserver: self event: AdEvent.adResumed block:^(PKEvent * _Nonnull event) {
        NSLog(@"\n\n******\n\n");
        NSLog(@"|**** GOT AD Event :: AdEvent .adResumed ****|");
        NSLog(@"\n\n******\n\n");
    }];
    
    [self.player addObserver: self event: AdEvent.adSkipped block:^(PKEvent * _Nonnull event) {
        NSLog(@"\n\n******\n\n");
        NSLog(@"|**** GOT AD Event :: AdEvent .adSkipped ****|");
        NSLog(@"\n\n******\n\n");
    }];
    
    [self.player addObserver: self event: AdEvent.adStarted block:^(PKEvent * _Nonnull event) {
        NSLog(@"\n\n******\n\n");
        NSLog(@"|**** GOT AD Event :: AdEvent .adStarted ****|");
        NSLog(@"\n\n******\n\n");
    }];
    
    [self.player addObserver: self event: AdEvent.adTapped block:^(PKEvent * _Nonnull event) {
        NSLog(@"\n\n******\n\n");
        NSLog(@"|**** GOT AD Event :: AdEvent .adTapped ****|");
        NSLog(@"\n\n******\n\n");
    }];
    
    [self.player addObserver: self event: AdEvent.adThirdQuartile block:^(PKEvent * _Nonnull event) {
        NSLog(@"\n\n******\n\n");
        NSLog(@"|**** GOT AD Event :: AdEvent .adThirdQuartile ****|");
        NSLog(@"\n\n******\n\n");
    }];
    
//    [self.player addObserver: self event: AdEvent.adDidProgressToTime block:^(PKEvent * _Nonnull event) {
//        NSLog(@"\n\n******\n\n");
//        NSLog(@"|**** GOT AD Event :: AdEvent .adDidProgressToTime ****|");
//        NSLog(@"\n\n******\n\n");
//    }];
    
    [self.player addObserver: self event: AdEvent.adCuePointsUpdate block:^(PKEvent * _Nonnull event) {
        NSLog(@"\n\n******\n\n");
        NSLog(@"|**** GOT AD Event :: AdEvent .adCuePointsUpdate ****|");
        NSLog(@"\n\n******\n\n");
    }];
    
    [self.player addObserver: self event: AdEvent.adStartedBuffering block:^(PKEvent * _Nonnull event) {
        NSLog(@"\n\n******\n\n");
        NSLog(@"|**** GOT AD Event :: AdEvent .adStartedBuffering ****|");
        NSLog(@"\n\n******\n\n");
    }];
    
    [self.player addObserver: self event: AdEvent.adPlaybackReady block:^(PKEvent * _Nonnull event) {
        NSLog(@"\n\n******\n\n");
        NSLog(@"|**** GOT AD Event :: AdEvent .adPlaybackReady ****|");
        [[ZEE5PlayerManager sharedInstance]hideLoaderOnPlayer];
        NSLog(@"\n\n******\n\n");
    }];
    
    [self.player addObserver: self event: AdEvent.requestTimedOut block:^(PKEvent * _Nonnull event) {
        NSLog(@"\n\n******\n\n");
        NSLog(@"|**** GOT AD Event :: AdEvent .requestTimedOut ****|");
        NSLog(@"\n\n******\n\n");
    }];
    
    [self.player addObserver: self event: AdEvent.adsRequested block:^(PKEvent * _Nonnull event) {
        NSLog(@"\n\n******\n\n");
        NSLog(@"|**** GOT AD Event :: AdEvent .adsRequested :: %@ :: %@ :: %@ :: %ld ****|", event.adTagUrl, event.adMediaTime, event.adTotalTime, (long)event.adInfo.podIndex);
    
        
        NSLog(@"\n\n******\n\n");
    }];
    
    [self.player addObserver: self event: AdEvent.error block:^(PKEvent * _Nonnull event) {
        NSLog(@"\n\n******\n\n");
        NSLog(@"|**** GOT AD Event :: AdEvent .error :: %@ ****|", event.adError.localizedDescription);
        NSLog(@"\n\n******\n\n");
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
    
    //
    
    if (![_currentItem.asset_type isEqualToString:@"9"])
    {
        [self handlePlayerSeekEvents];
    }
    [self currentBitrateHandler];
    
    // Ad Events
    [self registerPlayerForAdEvents];

}

//MARK:- Handle basic event Of Player (Play, Pause, CanPlay ..  Failed)

- (void)handlePlayerError {
    
    [self.player addObserver:self
                       event:PlayerEvent.error
                       block:^(PKEvent * _Nonnull event) {
               NSLog(@"|*** Error Code From Kaltura*** %ld",(long)event.error.code);
               NSLog(@"|*** Error Code From Kaltura*** %@",event.error.localizedDescription);
        
        // 7002 when i pass certificate Nil value
        // 7000 when Url takes wrong Url
        if (event.error.code >= 7000)
        {
            [[ZEE5PlayerManager sharedInstance]handleHLSError];
        }
        [[AnalyticEngine new]PlayBackErrorWith:event.error.localizedFailureReason];
        
                 
                       }];
    
    [self.player addObserver:self
                      events:@[PlayerEvent.errorLog]
                       block:^(PKEvent * _Nonnull event){
        
              NSLog(@"|**** Error Code From Kaltura %ld",(long)event.error.code);
              NSLog(@"|**** ErrorLog From Kaltura %@",PlayerEvent.errorLog);
        
                /// Cheack Code here Why Its Getting Failed
                         
        
                       }];
}

-(void)registerPlayerMetaData{
    
    
    
    [self.player addObserver:self
                       event:PlayerEvent.loadedMetadata
                       block:^(PKEvent * _Nonnull event) {
                        
                           NSLog(@"|**** Playing Start ****|");
        [[AnalyticEngine new]VideoPlayAnalytics];

                       }];
}
- (void)registerPlayEvent {
    
    AnalyticEngine *engine = [[AnalyticEngine alloc] init];
    
    [self.player addObserver:self
                       event:PlayerEvent.playing
                       block:^(PKEvent * _Nonnull event) {
                           [[ZEE5PlayerManager sharedInstance] onPlaying];
                           
                           NSLog(@"|**** Playing Event ****|");
                           [engine updatePlayerStateWithState:CONVIVA_PLAYING];
                       }];
    
    [self.player addObserver:self
                      events:@[PlayerEvent.pause]
                       block:^(PKEvent * _Nonnull event){
                           [[ZEE5PlayerManager sharedInstance] pause];
                           
                           NSLog(@"|**** Pause Event ****|");
                           [engine updatePlayerStateWithState: CONVIVA_PAUSED];
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
                           
                           NSLog(@"State Chnaged Event:: oldState: %ld | newState: %ld", (long)oldState, (long)newState);
                           
                           if (newState == PlayerStateBuffering) {
                               
                               NSLog(@"|*** Get buffering events ***|");
                               
                               AnalyticEngine *engine = [[AnalyticEngine alloc] init];
                               [engine updatePlayerStateWithState: CONVIVA_BUFFERING];
                           }
                       }];
}

// Get Current Bitrate
- (void)currentBitrateHandler {
    [self.player addObserver: self event: PlayerEvent.videoTrackChanged block:^(PKEvent * _Nonnull event) {
        
        NSInteger videoBitrate = [event.bitrate integerValue] / 1000;
        NSLog(@"|*** Current Bitrate: %@ and vide: %ld ***|", event.bitrate, (long)videoBitrate);
        
        AnalyticEngine *engine = [[AnalyticEngine alloc] init];
        [engine updateVideoBitrateWith: videoBitrate];
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
        
                           NSLog(@"|*** SEEKED SeekEvents: Int- %d", weakSelf.PlayerStartTime);
                           
       [engine setSeekStartTimeWithDuration: weakSelf.PlayerStartTime];
                       }];
    
    [self.player addObserver:self
                      events:@[PlayerEvent.seeked]
                       block:^(PKEvent * _Nonnull event) {
                           
                           NSTimeInterval playerTime = [weakSelf getCurrentTime];
                           weakSelf.PlayerEndTime = playerTime;
                           NSLog(@"|*** SEEKED SeekEvents: Int- %d",weakSelf.PlayerEndTime);
                          
                       if(weakSelf.PlayerEndTime < weakSelf.PlayerStartTime){
                               weakSelf.Direction = @"Reverse";}else{
                                  weakSelf.Direction = @"Forward";
                               }
        [engine setSeekEndTimeWithDuration: weakSelf.PlayerEndTime];
        [engine VideoWatchPercentCalc];
        [engine seekValueChangeAnalyticsWith:weakSelf.Direction Starttime:weakSelf.PlayerStartTime EndTime:weakSelf.PlayerEndTime];
                       }];
}

-(void)registerBufferEvent {
    
    AnalyticEngine *engine = [[AnalyticEngine alloc] init];
    
    [self.player addObserver:self
                      events:@[PlayerEvent.playbackStalled]
                       block:^(PKEvent * _Nonnull event) {
                           [[ZEE5PlayerManager sharedInstance] onBuffring];
                           NSLog(@"|**** Buffer Event ****|");
                           [engine updatePlayerStateWithState: CONVIVA_BUFFERING];
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
                           [[ZEE5PlayerManager sharedInstance] onComplete];
                           NSLog(@"|*** Complete Video- End event ***|");
        [engine  videoWatchDurationAnalytic];
                           [engine updatePlayerStateWithState: CONVIVA_STOPPED];
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
    NSString *part3 = @"</vmap:VMAP>";
    NSString *part2 = @"";

    for (ZEE5AdModel *model in self.currentItem.googleAds) {
        
        NSInteger index = [self.currentItem.googleAds indexOfObject:model];
        if ([model.time.lowercaseString isEqualToString:@"pre"]) {
            part2 = [NSString stringWithFormat:@"%@%@%@%@",part2,@"<vmap:AdBreak timeOffset=\"start\" breakType=\"linear\" breakId=\"preroll\">\n<vmap:AdSource id=\"preroll-ad-1\" allowMultipleAds=\"false\" followRedirects=\"true\">\n<vmap:AdTagURI templateType=\"vast3\">\n<![CDATA[\n",model.tag,@"]]>\n</vmap:AdTagURI>\n</vmap:AdSource>\n</vmap:AdBreak>"];
        }
        else if ([model.time.lowercaseString isEqualToString:@"post"]) {
            part2 = [NSString stringWithFormat:@"%@%@%@%@",part2,@"<vmap:AdBreak timeOffset=\"end\" breakType=\"linear\" breakId=\"postroll\">\n<vmap:AdSource id=\"postroll-ad-1\" allowMultipleAds=\"false\" followRedirects=\"true\">\n<vmap:AdTagURI templateType=\"vast3\">\n<![CDATA[\n",model.tag,@"]]>\n</vmap:AdTagURI>\n</vmap:AdSource>\n</vmap:AdBreak>"];
        }
        else
        {
            part2 = [NSString stringWithFormat:@"%@%@%@%@%ld%@%@%@%@%@",part2,@"<vmap:AdBreak timeOffset=\"",model.time,@"\" breakType=\"linear\" breakId=\"midroll-",(long)index,@"\">\n<vmap:AdSource id=\"",model.tag_name,@"\" allowMultipleAds=\"false\" followRedirects=\"true\">\n<vmap:AdTagURI templateType=\"vast3\">\n<![CDATA[\n",model.tag,@"]]>\n</vmap:AdTagURI>\n</vmap:AdSource>\n</vmap:AdBreak>"];

        }
    }
    
    totalString = [NSString stringWithFormat:@"%@%@%@",part1,part2,part3];

    return totalString;
}

@end

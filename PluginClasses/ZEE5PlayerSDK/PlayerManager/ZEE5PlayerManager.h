//
//  ZEE5PlayerManager.h
//  ZEE5PlayerSDK
//
//  Created by admin on 04/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZEE5PlayerConfig.h"
#import "ZEE5PlayerDelegate.h"
#import "CurrentItem.h"
#import <PlayKit/PlayKit-Swift.h>
#import <ComScore/ComScore.h>
#import "VODContentDetailsDataModel.h"
#import "tvShowModel.h"



typedef void(^DRMSuccessHandler)(NSString* _Nullable licenceURL, NSString* _Nullable customData);
typedef void(^DRMFailureHandler)(NSString* _Nullable error);

typedef void(^VODDataHandler)(VODContentDetailsDataModel * _Nullable result, NSString * _Nullable customData);
typedef void(^TokenSuccessHandler)(id _Nullable result);
typedef void(^TokenFailureHandler)(ZEE5SdkError * _Nullable error);
typedef void(^CIdHandler)(BOOL isSame, NSString * _Nullable customData);
typedef void(^GestureHandler)(void);


NS_ASSUME_NONNULL_BEGIN
@class CurrentItem;
@class ZEE5PlayerConfig;
@class DownloadRootController;
@class KalturaPlayerController;
@class LiveContentDetails;

@interface ZEE5PlayerManager : NSObject
@property CurrentItem *currentItem;
@property (weak, nonatomic) id <ZEE5PlayerDelegate> delegate;
@property(nonatomic) BOOL isStop;
@property(nonatomic) BOOL isTelco;     //// Come From Partner App.
@property(nonatomic) NSString *TelcoMsg;
@property(nonatomic) BOOL isAutoplay;
@property(nonatomic) BOOL isStreamoverWifi;
@property(nonatomic) BOOL isdownloadOverWifi;
@property(nonatomic) BOOL isContentAvailable;
@property(nonatomic) BOOL isHybridViewOpen;
@property(nonatomic) NSString *selectedSubtitle;
@property(nonatomic) NSString *selectedLangauge;
@property(nonatomic) NSString *selectedplaybackRate;
@property (weak, nonatomic) NSArray *companionAds;

@property(nonatomic, strong, readonly) UIViewController *_Nullable currentShareViewController;


@property(nonatomic) NSString *KcdnUrl;   /////////************ CDN URL String*************//////
@property(nonatomic) NSString *c3Ri;   /////////************ Value From cdn Api*************//////



+ (ZEE5PlayerManager *)sharedInstance;

- (void)downloadVODContent:(NSString*)content_id country:(NSString*)country translation:(NSString*)laguage withCompletionHandler: (VODDataHandler)completionBlock;
- (void)playVODContentWithModel:(VODContentDetailsDataModel *)model;
- (void)playLiveContentWithModel:(LiveContentDetails *)model;
- (void)getShowModel:(tvShowModel *)model;
- (void)postContentIdShouldUpdateNotification:(NSString *)contentId;
- (void)postReloadCurrentContentIdNotification;

/*!
 * @discussion This method used to stop the video
 */
-(void)stop;

/*!
 * @discussion This method used to play the video
 */
-(void)play;

/*!
 * @discussion This method used to pause the video
 */
-(void)pause;

/*!
 * @discussion This method used to Remove Playback View
 */
-(void)DestroyPlayer;

// To get custom data and license url for the content
- (void)getDRMToken:(NSString*)content_id andDrmKey:(NSString*)drmKey  withCompletionHandler:(TokenSuccessHandler)success failureBlock:(TokenFailureHandler)failure;

-(void)replay;
-(void)setMute:(BOOL)isMute;
-(void)setLock:(BOOL)isLock;

-(void)setFullScreen:(BOOL)isFull;
-(void)showFullScreen;
-(void)hideFullScreen;
-(void)LocalStorageArray;

-(void)forward:(NSInteger)value;
-(void)rewind:(NSInteger)value;
-(void)setSeekTime:(NSInteger)value;
-(void)hideCustomControls;
-(void)perfomAction;
-(void)setAudioTrack:(NSString *)audioID Title:(NSString *)AudioTitle;
-(void)setSubTitle:(NSString *)subTitleID Title:(NSString *)SubtitleTitle;
-(void)moreOptions;
-(void)GetAudioLanguage;
-(void)skipIntro;
-(void)WatchCredits;
-(void)tapOnLiveButton;
-(void)tapOnGoLiveButton;
-(void)tapOnShareButton;
-(void)tapOnPrevButton;
-(void)tapOnNextButton;
-(void)tapOnUpNext;
-(void)navigateToDetail;
-(void)tapOnMinimizeButton;
-(void)airplayButtonClicked;
-(void)StartDownload;
-(void)showloaderOnPlayer;
-(void)hideLoaderOnPlayer;
-(void)ShowToastMessage:(NSString *)Message;
-(void)startAd:(PKEvent *)event;
-(void)endAd;
-(void)pauseAd;
-(void)SliderReset;
-(void)Playbackcheck;
-(void)setPlaybackView:(UIView *)playbackView;
-(void)setOneTrustValue:(nullable NSDictionary *)oneDict;

-(void)getBase64StringwithCompletion:(void (^)(NSString *))completion;
-(void)Telcouser:(BOOL)istelco param:(NSString *)Message;

-(CGFloat )getCurrentDuration;
-(CGFloat )getTotalDuration;
-(NSUInteger )getBufferPercentage;
-(NSArray *)getComanionAds;
-(void)playSimilarEvent:(NSString *)content_id;
-(void)onPlaying;
-(void)onDurationUpdate:(PKEvent *)event;
-(void)onTimeChange:(PKEvent *)event;
-(void)onBuffring;
-(void)onBuffringValueChange:(PKEvent *)event;
-(void)setWatchHistory:(NSInteger)duration;

-(void)removeSubview;
-(void)HybridViewOpen;

-(void)hideUnHideTopView:(BOOL )isHidden;
-(void)setContentUnavailable;

-(void)selectedMenuItem:(id)model;
-(void)tapOnPlayer;
-(void)onComplete;
-(void)handleHLSError:(NSInteger)errorCode;

-(void)checkParentalPin:(NSString *)Pin;
-(void)ParentalViewPlay;
-(void)parentalgesture:(BOOL)isKeypadShow;
-(void)deleteAllDevice:(NSString *)SenderAction;
-(ContentBuisnessType)getBusinessType;


-(void)tapOnSubscribeButton;
-(void)tapOnLoginButton;

- (void)handleCastingStopped;
- (void)castCurrentItem;

-(void)showLangaugeActionSheet;
-(void)showSubtitleActionSheet;

// For Offline -
-(void)moreOptionForOfflineContentAudio:(NSArray<Track*>*)audio text:(NSArray<Track*>*)texts withPlayer:(id<Player>)player;

@property(nonatomic) BOOL isOfflineContent;
@property NSArray<Track*>* offlineTextTracks;
@property NSArray<Track*>* offlineLanguageTracks;
@property(nonatomic) NSString *selectedplaybackRateOffline;
@property (strong, nonatomic) id<Player> offlinePlayer;

@end

NS_ASSUME_NONNULL_END

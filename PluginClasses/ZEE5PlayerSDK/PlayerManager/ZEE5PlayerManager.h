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



typedef void(^DRMSuccessHandler)(NSString* _Nullable licenceURL, NSString* _Nullable customData);
typedef void(^DRMFailureHandler)(NSString* _Nullable error);

typedef void(^VODDataHandler)(VODContentDetailsDataModel * _Nullable result, NSString * _Nullable customData);
typedef void(^TokenSuccessHandler)(id _Nullable result);
typedef void(^TokenFailureHandler)(ZEE5SdkError * _Nullable error);
typedef void(^CIdHandler)(BOOL isSame, NSString * _Nullable customData);


NS_ASSUME_NONNULL_BEGIN
@class CurrentItem;
@class ZEE5PlayerConfig;
@class DownloadRootController;
@class KalturaPlayerController;


@interface ZEE5PlayerManager : NSObject
@property CurrentItem *currentItem;
@property (weak, nonatomic) id <ZEE5PlayerDelegate> delegate;
@property(strong , nonatomic) PlayerView *playbackView;
@property(nonatomic) BOOL isStop;
@property(nonatomic) BOOL isTelco;     //// Come From Partner App.
@property(nonatomic) BOOL isAutoplay;
@property(nonatomic) BOOL isStreamoverWifi;
@property(nonatomic) BOOL isdownloadOverWifi;
@property(nonatomic) NSString *selectedSubtitle;
@property(nonatomic) NSString *selectedLangauge;
@property(nonatomic) NSString *selectedplaybackRate;
@property (weak, nonatomic) NSArray *companionAds;

@property(nonatomic, strong, readonly) UIViewController *_Nullable currentShareViewController;


@property(nonatomic) NSString *KcdnUrl;   /////////************ CDN URL String*************//////



+ (ZEE5PlayerManager *)sharedInstance;

/*!
 * @discussion This method used to play live catch up and live dvr
 * @param channel_id Need to pass channel id
 * @param show_id Need to pass show id.
 * @param startTime Need to pass start time of catch up.
 * @param end_time Need to pass end time of catch up.
 * @param episode_no Need to pass episode number.
 * @param season_nun Need to pass season number.
 * @param category Need to pass category.
 * @param laguage Need to pass transaltion langauge id.
 * @param playerConfig Need to pass playerConfig file.
 * @param playbackView Need to pass the view where you want to play the video.
 */

- (void)playLiveContent:(NSString *)channel_id showId:(NSString *)show_id startTime:(NSTimeInterval)startTime endtime:(NSTimeInterval)end_time episodNumber:(NSString *)episode_no seasonNumber:(NSString *)season_nun category:(NSString *)category translation:(NSString *)laguage playerConfig:(ZEE5PlayerConfig *)playerConfig playbackView:(PlayerView *)playbackView;

/*!
 * @discussion This method used to play vod content with content id
 * @param content_id Need to pass content id of the video
 * @param country Need to pass user country id.
 * @param laguage Need to pass transaltion langauge id.
 * @param playerConfig Need to pass playerConfig file.
 * @param playbackView Need to pass the view where you want to play the video.
 */

//- (void)playVODContent:(NSString*)content_id country:(NSString*)country translation:(NSString*)laguage playerConfig:(ZEE5PlayerConfig*)playerConfig playbackView:(UIView*)playbackView;

- (void)playVODContent:(NSString*)content_id country:(NSString*)country translation:(NSString*)laguage playerConfig:(ZEE5PlayerConfig*)playerConfig playbackView:(nonnull UIView *)playbackView withCompletionHandler: (VODDataHandler)completionBlock;

/*!
 * @discussion This method used to play vod content with json
 * @param playerConfig Need to pass playerConfig file.
 * @param playbackView Need to pass the view where you want to play the video.
 */

- (void)playVODWithJson:(NSDictionary *)dict playerConfig:(ZEE5PlayerConfig*)playerConfig playbackView:(nonnull PlayerView *)playbackView;

/*!
 * @discussion This method used to play vod content with url
 * @param playerConfig Need to pass playerConfig file.
 * @param playbackView Need to pass the view where you want to play the video.
 */

- (void)playVODWithURL:(NSString*)urlString playerConfig:(ZEE5PlayerConfig*)playerConfig playbackView:(nonnull PlayerView *)playbackView;

- (void)playVODContent:(NSString*)content_id country:(NSString*)country translation:(NSString*)laguage withCompletionHandler: (VODDataHandler)completionBlock;


-(void)contentIdChanged:(NSString *)content_id withCompletionHandler:(CIdHandler)success;
/*!
 * @discussion This method used to play hls content with content id
 * @param content_id Need to pass content id of the video
 * @param country Need to pass user country id.
 * @param laguage Need to pass transaltion langauge id.
 * @param platform_name Need to pass name of platform.
 * @param playbacksession_id Need to pass plassback session id for analytics.
 * @param playerConfig Need to pass playerConfig file.
 * @param playbackView Need to pass the view where you want to play the video.
 */
- (void)playAESContent:(NSString*) content_id country:(NSString*)country translation:(NSString*) laguage platform_name:(NSString*)platform_name playbacksession_id:(NSString*)playbacksession_id playerConfig:(ZEE5PlayerConfig*)playerConfig playbackView:(nonnull UIView *)playbackView;

/*!
 * @discussion This method use to get the custom data and licence url with content id
 * @param content_id Need to pass content id of the video
 * @param country Need to pass user country id.
 * @param laguage Need to pass transaltion langauge id.
 */

-(void)getTokenAndCustomDataFromContent:(NSString*)content_id country:(NSString*)country translation:(NSString*)laguage withCompletionHandler:(DRMSuccessHandler)success andFailure:(DRMFailureHandler)failed;

/*!
 * @discussion This method use to get the video content details with content id
 * @param content_id Need to pass content id of the video
 * @param country Need to pass user country id.
 */
-(void)getContentDetailForCastingItem:(NSString*)content_id country:(NSString*)country translation:(NSString*)language : (void (^)(VODContentDetailsDataModel *model, NSString *result))success ;

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
-(void)RefreshViewNotification;
-(void)HybridViewOpen;

-(void)hideUnHideTopView:(BOOL )isHidden;

-(void)selectedMenuItem:(id)model;
-(void)tapOnPlayer;
-(void)onComplete;
-(void)handleHLSError;

-(void)checkParentalPin:(NSString *)Pin;
-(void)parentalgesture:(BOOL)isKeypadShow;
-(void)deleteAllDevice:(NSString *)SenderAction;
-(void)upgradeSubscribePack:(NSString *)SubscribePack;
-(ContentBuisnessType)getBusinessType;


-(void)tapOnSubscribeButton;
-(void)tapOnLoginButton;

- (void)playWithCurrentItem ;

-(void)showLangaugeActionSheet;
-(void)showSubtitleActionSheet;

// For Offline -
-(void)moreOptionForOfflineContentAudio:(NSArray<Track*>*)audio text:(NSArray<Track*>*)texts withPlayer:(id<Player>)player;

@property(nonatomic) BOOL isOfflineContent;
@property NSArray<Track*>* offlineTextTracks;
@property NSArray<Track*>* offlineLanguageTracks;
@property (strong, nonatomic) id<Player> offlinePlayer;

@end

NS_ASSUME_NONNULL_END

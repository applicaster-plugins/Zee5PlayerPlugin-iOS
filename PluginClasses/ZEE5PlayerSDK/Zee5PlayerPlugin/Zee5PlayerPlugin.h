//
//  Zee5PlayerPlugin.h
//  ZEE5PlayerSDK
//
//  Created by Mani on 29/05/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PlayKit/PlayKit-Swift.h>
#import "ZEE5AdModel.h"

NS_ASSUME_NONNULL_BEGIN
@class CurrentItem;

@interface Zee5PlayerPlugin : NSObject
+ (Zee5PlayerPlugin *)sharedInstance;
@property (strong, nonatomic) id<Player> player;

/*!
 @discussion This method used to initialise PlayerView using PlayerCurrentitem Object
 @param currentItem Need to pass currentItem Object
 @param licence  need to pass licenceUrl
 @param cerificate need to pass base64 certificate
**/
-(void)initializePlayer : (PlayerView *)playbackView andItem :(CurrentItem *)currentItem andLicenceURI:(NSString *)licence  andBase64Cerificate:(NSString *)cerificate;
/*!
 @discussion This method used to initialise PlayerView. with plaback Session id.
 @param urlString Need to pass URL of video
 @param token  need to pass Token of user.
 @param playbacksession_id need to pass playbacksessionid
**/
-(void)initializePlayer : (PlayerView *)playbackView andURL :(NSString *)urlString andToken:(NSString *)token playbacksession_id:(NSString *)playbacksession_id;

/*!
  @discussion This method used to get Duration of Content.
*/
-(NSTimeInterval )getDuration;

/*!
  @discussion This method used to get currentTime of Player
*/
-(NSTimeInterval )getCurrentTime;
/*!
  @discussion This method used to set Seektime of Seekbar in player.
*/
-(void)setSeekTime:(NSInteger)value;


/*!
  @discussion This method used to getCurrentAuditracks
*/
-(NSString *)getCurrentAuditrack;


/*!
  @discussion This method used to getCurrenttextTrack
*/
-(NSString *)getCurrenttextTrack;

/*!
 @discussion This method used toReport ConvivaErrorSession
 @param Code PlaybackfailErrorCode
 @param Platform  PlatformCode
 @param ErrorMsg ConvivaErrorMsg
**/
-(void)ConvivaErrorCode:(NSInteger)Code platformCode:(NSString *)Platform severityCode:(NSInteger)Severity andErrorMsg:(NSString *)ErrorMsg;

@end

NS_ASSUME_NONNULL_END

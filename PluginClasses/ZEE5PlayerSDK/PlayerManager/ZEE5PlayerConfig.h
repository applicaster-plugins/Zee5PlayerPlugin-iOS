//
//  ZEE5PlayerConfig.h
//  ZEE5PlayerSDK
//
//  Created by admin on 04/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Zee5PlayerPlugin/ZEE5PlayerSDK.h>



NS_ASSUME_NONNULL_BEGIN



@interface ZEE5PlayerConfig : NSObject
/*!
 * @brief Need to pass whether to play the video automatically or not.
 * Default - NO
 */
@property(nonatomic) BOOL autoPlay;

/*!
 * @brief Need to pass whether to show custom controls or not.
 * Default - NO
 */
@property(nonatomic) BOOL showCustomPlayerControls;

/*!
 * @brief Need to pass whether to play video in landscape or not.
 * Default - NO
 */
@property(nonatomic) BOOL shouldStartPlayerInLandScape;

/*!
 * @brief Need to pass whether to play video in normal mode or muted.
 * Default - normalPlayer
 */
@property(nonatomic) PlayerType playerType;

/*!
 * @brief Need to pass seek value.
 * Default - 10 Sec
 */
@property(nonatomic) NSInteger seekValue;

/*!
 * @brief  Need to pass whether to show GoogleAds
 * Default - Yes
*/
@property(nonatomic) BOOL showGoogleADs;

/*!
 * @brief Need to pass whether to show FanADs
 * Default - Yes
*/
@property(nonatomic) BOOL showFanADs;


/*!
 * @brief Need to pass bydefault value KcDNUrl
 * Default - Akamai
*/






@end

NS_ASSUME_NONNULL_END

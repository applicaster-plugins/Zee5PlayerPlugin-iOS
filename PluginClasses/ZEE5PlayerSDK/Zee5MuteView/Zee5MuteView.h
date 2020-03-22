//
//  Zee5MuteView.h
//  ZEE5PlayerSDK
//
//  Created by Mani on 26/06/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Zee5MuteView : UIView
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblEpisode;
@property (weak, nonatomic) IBOutlet UIButton *btnMute;
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (nonatomic) CAGradientLayer *shadowLayer;


@end

NS_ASSUME_NONNULL_END

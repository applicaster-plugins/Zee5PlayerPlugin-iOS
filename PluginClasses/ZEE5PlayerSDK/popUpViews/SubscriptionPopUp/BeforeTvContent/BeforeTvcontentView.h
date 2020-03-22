//
//  BeforeTvcontentView.h
//  ZEE5PlayerSDK
//
//  Created by Tejas Todkar on 24/10/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BeforeTvcontentView : UIView
@property (weak, nonatomic) IBOutlet UIView *guestView;
@property (weak, nonatomic) IBOutlet UIView *subscribeView;
- (IBAction)subscribeNowAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *subscribenowOutlet;
- (IBAction)loginAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *loginOutlet;
@property (weak, nonatomic) IBOutlet UIButton *watchfreeepisodeOutlet;
- (IBAction)watchFreeEpisodeAction:(id)sender;
- (IBAction)closeBtnAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *closeBtnOutlet;

@end

NS_ASSUME_NONNULL_END

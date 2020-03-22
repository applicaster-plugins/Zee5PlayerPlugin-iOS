//
//  InternationlguestUser.h
//  ZEE5PlayerSDK
//
//  Created by Tejas Todkar on 24/10/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface InternationlguestUser : UIView
@property (weak, nonatomic) IBOutlet UILabel *textlabel;
- (IBAction)loginAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *loginOutlet;

@property (weak, nonatomic) IBOutlet UIView *outerView;
@property (weak, nonatomic) IBOutlet UIButton *subscribenowOutlet;
- (IBAction)subscribeNowAction:(id)sender;
- (IBAction)startfreetrialAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *startfreetrialBtnOutlet;
@property (weak, nonatomic) IBOutlet UIView *subscribeView;
- (IBAction)closeBtnAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *closeBtnOutlet;
@end

NS_ASSUME_NONNULL_END

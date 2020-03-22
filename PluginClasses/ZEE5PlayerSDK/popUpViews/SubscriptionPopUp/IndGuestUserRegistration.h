//
//  IndGuestUserRegistration.h
//  ZEE5PlayerSDK
//
//  Created by Tejas Todkar on 22/10/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IndGuestUserRegistration : UIView
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UIButton *loginBtnOutlet;
- (IBAction)loginAction:(id)sender;
- (IBAction)subscribeAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *subscribeBtnOutlet;
@property (weak, nonatomic) IBOutlet UIView *outerView;
@property (weak, nonatomic) IBOutlet UIView *subscribeView;
- (IBAction)closeBtnAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *closeViewBtnOutlet;

@end

NS_ASSUME_NONNULL_END

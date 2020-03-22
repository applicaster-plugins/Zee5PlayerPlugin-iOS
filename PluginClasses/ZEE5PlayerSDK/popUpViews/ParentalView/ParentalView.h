//
//  ParentalView.h
//  ZEE5PlayerSDK
//
//  Created by shriraj.salunkhe on 26/09/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

#import <UIKit/UIKit.h> 

NS_ASSUME_NONNULL_BEGIN


@interface ParentalView : UIView

- (IBAction)NextAction:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *top_parentalView;
@property (weak, nonatomic) IBOutlet UITextField *textPin;
@property (weak, nonatomic) IBOutlet UITextField *textPin2;

@property (weak, nonatomic) IBOutlet UITextField *textPin3;

@property (weak, nonatomic) IBOutlet UITextField *textPin4;

- (IBAction)showHideAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *showhideOutlet;

@property (weak, nonatomic) IBOutlet UIView *OuterView;

- (IBAction)ForgotPinoutlet:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *confirmOutlet;

- (IBAction)closeBtnAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *closeBtnOutlet;

@end

NS_ASSUME_NONNULL_END

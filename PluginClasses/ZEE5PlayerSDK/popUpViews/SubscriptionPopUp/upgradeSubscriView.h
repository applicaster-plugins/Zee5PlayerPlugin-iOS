//
//  upgradeSubscriView.h
//  ZEE5PlayerSDK
//
//  Created by Tejas Todkar on 17/10/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface upgradeSubscriView : UIView

@property (weak, nonatomic) IBOutlet UIButton *proceedOutlet;
-(IBAction)proceedAction:(id)sender;
- (IBAction)termsOfUse:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *outerView;

@property (weak, nonatomic) IBOutlet UITextField *promoCodeTextField;
@property (weak, nonatomic) IBOutlet UITableView *SubscribepacktableView;
- (IBAction)ApplyAction:(id)sender;

@end

NS_ASSUME_NONNULL_END

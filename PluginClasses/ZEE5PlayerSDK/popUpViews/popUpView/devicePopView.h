//
//  devicePopView.h
//  ZEE5PlayerSDK
//
//  Created by shriraj.salunkhe on 09/10/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface devicePopView : UIView

- (IBAction)DeleteAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *OuterView;
@property (weak, nonatomic) IBOutlet UIButton *deleteOutlet;
@property (weak, nonatomic) IBOutlet UIButton *smileBtnOutlet;


@property (weak, nonatomic) IBOutlet UIButton *cancelOutlet;
- (IBAction)cancelAction:(id)sender;

- (IBAction)closeBtnAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *closeBtnOutlet;
@end

NS_ASSUME_NONNULL_END

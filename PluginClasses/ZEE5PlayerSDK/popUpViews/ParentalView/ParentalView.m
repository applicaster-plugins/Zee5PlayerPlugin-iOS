//
//  ParentalView.m
//  ZEE5PlayerSDK
//
//  Created by shriraj.salunkhe on 26/09/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

#import "ParentalView.h"
#import <Zee5PlayerPlugin/ZEE5PlayerSDK.h>
#import "Zee5PlayerPlugin/Zee5PlayerPlugin-Swift.h"


@interface ParentalView ()<UITextFieldDelegate>

@end

@implementation ParentalView

- (void)awakeFromNib
{
    
    [super awakeFromNib];
    [self.textPin becomeFirstResponder];
    [self makeDragable];
    
    _textPin.layer.cornerRadius =4.0f;
    [_textPin.layer setMasksToBounds:YES];
    
    _textPin2.layer.cornerRadius =4.0f;
    [_textPin2.layer setMasksToBounds:YES];
    
    _textPin3.layer.cornerRadius =4.0f;
    [_textPin3.layer setMasksToBounds:YES];
    
    _textPin4.layer.cornerRadius =4.0f;
    [_textPin4.layer setMasksToBounds:YES];
    
    _confirmOutlet.enabled =NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide) name:UIKeyboardDidHideNotification object:nil];
    
    [self buttonApearance];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIBezierPath *maskPath = [UIBezierPath
                              bezierPathWithRoundedRect:self.OuterView.bounds
                              byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                              cornerRadii:CGSizeMake(25, 25)
                              ];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.OuterView.layer.mask = maskLayer;
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

    [super touchesBegan:touches withEvent:event];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
  
        [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if ((textField.text.length <1) && (string.length > 0))
    {
        NSInteger nextTag = textField.tag + 1;
        // Try to find next responder
        UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
        if (! nextResponder)
            _confirmOutlet.enabled =YES;
        [self buttonApearance];
            [textField resignFirstResponder];
        

        if (nextResponder)
            // Found next responder, so set it.
            [nextResponder becomeFirstResponder];
        
        textField.text = string;

        return NO;
    }
    else if ((textField.text.length >= 1) && (string.length == 0))
    {
        NSInteger previousTag = textField.tag - 1;
        // Try to find next responder
        UIResponder* nextResponder = [textField.superview viewWithTag:previousTag];
        if (previousTag == 0)
           [textField resignFirstResponder];

        if (nextResponder)
            // Found next responder, so set it.
            [nextResponder becomeFirstResponder];
        _confirmOutlet.enabled =NO;
        [self buttonApearance];
        
        
        textField.text = @"";
        
         return NO;

    }
    return YES;
}


-(void)keyboardDidShow{
    [[ZEE5PlayerManager sharedInstance]parentalgesture:true];
}

-(void)keyboardDidHide
{
    [[ZEE5PlayerManager sharedInstance]parentalgesture:false];
}

-(void)buttonApearance
{
    _confirmOutlet.layer.cornerRadius =18.0f;
    _confirmOutlet.layer.borderWidth =0.8;
    [_confirmOutlet.layer setMasksToBounds:YES];
    
    if (self.confirmOutlet.enabled ==YES)
    {
        _confirmOutlet.alpha =1.0f;
        _confirmOutlet.layer.borderColor =[[UIColor clearColor]CGColor];
        
    [self.confirmOutlet setBackgroundImage:[Utility getGradientImageWithBounds:_confirmOutlet.bounds] forState:UIControlStateNormal];
        
    }
    else
    {
        
        [_confirmOutlet setBackgroundImage:nil forState:UIControlStateNormal];
        [_confirmOutlet setBackgroundColor:[UIColor blackColor]];
         _confirmOutlet.alpha =0.40f;
         _confirmOutlet.layer.borderColor =[[UIColor whiteColor]CGColor];
       
    }
   
    
}
- (IBAction)CancelAction:(id)sender {
}

- (IBAction)showHideAction:(id)sender
{
    if ([_showhideOutlet.currentTitle isEqualToString:@"Show Pin"])
    {
        [_showhideOutlet setTitle:@"Hide Pin" forState:UIControlStateNormal];
        _textPin.secureTextEntry = NO;
        _textPin2.secureTextEntry =NO;
        _textPin3.secureTextEntry =NO;
        _textPin4.secureTextEntry =NO;
        
    }
    else
    {
        [_showhideOutlet setTitle:@"Show Pin" forState:UIControlStateNormal];
        _textPin.secureTextEntry = YES;
         _textPin2.secureTextEntry = YES;
        _textPin3.secureTextEntry = YES;
        _textPin4.secureTextEntry = YES;
    }
}

- (IBAction)NextAction:(id)sender
{
    if ([_textPin.text isEqualToString:@""] || [_textPin2.text isEqualToString:@""] || [_textPin3.text isEqualToString:@""] || [_textPin4.text isEqualToString:@""])
    {
        NSLog(@"Please Enter Pin");
        [[ZEE5PlayerManager sharedInstance]ShowToastMessage:@"Please Enter Pin"];

    }
    else
    {
        NSString * PIN =[NSString stringWithFormat:@"%@%@%@%@",_textPin.text,_textPin2.text,_textPin3.text,_textPin4.text];
        [[ZEE5PlayerManager sharedInstance]checkParentalPin:PIN];
        [self AddNotification:PIN];
            
        _textPin.text=@"";
        _textPin2.text=@"";
        _textPin3.text=@"";
        _textPin4.text=@"";
    }
    
  
}
-(void)AddNotification:(NSString *)Pin{
   [[NSNotificationCenter defaultCenter] postNotificationName:@"ParentalPin" object:Pin userInfo:nil];
}
- (IBAction)textPin3:(id)sender {
}

// MARK:- Navigate Do Parental View(DeepLinking)

- (IBAction)ForgotPinoutlet:(id)sender
{
    [[ZEE5PlayerManager sharedInstance]removeSubview];
    [[ZEE5PlayerDeeplinkManager new]NavigatetoParentalViewPage];
}

- (IBAction)closeBtnAction:(id)sender{
   
    //[[ZEE5PlayerManager sharedInstance]removeSubview];
}
@end

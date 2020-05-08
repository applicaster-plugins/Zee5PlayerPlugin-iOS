//
//  ZEE5CustomControl.m
//  ZEE5PlayerSDK
//
//  Created by admin on 11/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import "ZEE5CustomControl.h"
#import "ZEE5PlayerManager.h"
#import "ZEE5PlayerConfig.h"
#import "Zee5CollectionCell.h"
#import <Zee5PlayerPlugin/ZEE5PlayerSDK.h>
#import "Zee5PlayerPlugin/Zee5PlayerPlugin-Swift.h"
@implementation ZEE5CustomControl

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)awakeFromNib
{
    [super awakeFromNib];
    NSBundle *bundel = [NSBundle bundleForClass:self.class];
    UIImage *image = [UIImage imageNamed:@"Thumb" inBundle:bundel compatibleWithTraitCollection:nil];

    _sliderDuration.showTooltip = YES;
    [_sliderDuration setThumbImage:image forState:UIControlStateNormal];
    [_sliderDuration setThumbImage:image forState:UIControlStateHighlighted];
    
    _sliderLive.showTooltip = NO; 
    _sliderLive.showTooltipContiously = NO;
    [_sliderLive setThumbImage:image forState:UIControlStateNormal];
    [_sliderLive setThumbImage:image forState:UIControlStateHighlighted];
    
    [_sliderDuration addTarget:self action:@selector(sliderValueChanged:withEvent:) forControlEvents:UIControlEventTouchUpInside];
  
    [_sliderDuration addTarget:self action:@selector(sliderValueChanged:withEvent:) forControlEvents:UIControlEventValueChanged];

    
    [_collectionView registerNib:[UINib nibWithNibName:@"Zee5CollectionCell" bundle:bundel] forCellWithReuseIdentifier:@"cell"];
    
    _buttonLive.layer.cornerRadius = _buttonLive.frame.size.height/2;
    _buttonLive.clipsToBounds = YES;
    
    _skipIntro.layer.cornerRadius = _buttonLive.frame.size.height/2;
    _skipIntro.clipsToBounds = YES;
    _watchcretidStackview.hidden=YES;
    _watchcreditsTimeLbl.hidden=YES;
    
    _watchcreditShowView.layer.borderColor = [[UIColor whiteColor]CGColor];
    _watchcreditShowView.layer.borderWidth = 1.0f;
    _watchcreditShowView.layer.cornerRadius = 4.0f;
    [_watchcreditShowView.layer setMasksToBounds:YES];
    _adultView.hidden = YES;
    

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshRelatedList) name:@"kRefreshRelatedVideoList" object:nil];
    
    
}

- (IBAction)watchCreditsAction:(id)sender
{
    [[ZEE5PlayerManager sharedInstance]WatchCredits];
    _watchcreditsOutlet.hidden =YES;
    _watchcreditsTimeLbl.hidden =YES;
}

- (IBAction)downloadBtnAction:(id)sender
{
    [[ZEE5PlayerManager sharedInstance]StartDownload];
}

-(void)forwardAndRewindActions
{
    NSInteger value = 10;
//    NSInteger value = [self.labelForward.text integerValue];
    __weak typeof(self) weakSelf = self;

    [self.forwardButton removeFromSuperview];
    
    self.forwardButton = [[TouchableButton alloc] initWithTitle:@"Forward" imageName:@"3" seekBtn:@"Forward"];
    [self insertSubview:self.forwardButton atIndex:1];
//    [self sendSubviewToBack:self.forwardButton];
    
    
    self.forwardButton.singleTouch = ^(BOOL  touch)
    {
        [weakSelf.forwardButton resetViews];
        [[ZEE5PlayerManager sharedInstance] tapOnPlayer];

    };
    self.forwardButton.pressed = ^(BOOL pressed) {
        
        [[ZEE5PlayerManager sharedInstance] hideCustomControls];
        [[ZEE5PlayerManager sharedInstance] forward:value];
    };
    
    [self.rewindButton removeFromSuperview];
    
    self.rewindButton = [[TouchableButton alloc] initWithTitle:@"Rewind" imageName:@"N" seekBtn:@"Rewind"];
    
    [self insertSubview:self.rewindButton atIndex:1];
//    [self sendSubviewToBack:self.rewindButton];
    
    
    self.rewindButton.singleTouch = ^(BOOL  touch) {
        [weakSelf.rewindButton resetViews];
        [[ZEE5PlayerManager sharedInstance] tapOnPlayer];
    };
    self.rewindButton.pressed = ^(BOOL pressed) {
        
        [[ZEE5PlayerManager sharedInstance] hideCustomControls];
        [[ZEE5PlayerManager sharedInstance] rewind:value];
    };
}

- (void)refreshRelatedList
{
    self.related = [ZEE5PlayerManager sharedInstance].currentItem.related;
    [self.collectionView reloadData];
}

- (IBAction)buttonPlayClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    AnalyticEngine *engine =[[AnalyticEngine alloc]init];
    
    if(sender.selected)
    {
        [[ZEE5PlayerManager sharedInstance] play];
        [engine playerResumeAnalytics];
        
       
    }
    else
    {
        [[ZEE5PlayerManager sharedInstance] pause];
        [engine playerPauseAnalytics];
  

    }
    
}
- (IBAction)btnMoreClicked:(UIButton *)sender
{
    [[ZEE5PlayerManager sharedInstance] moreOptions];
    [[AnalyticEngine new]playerCTAWith:@"MoreCTA"];

}
- (IBAction)skipIntroBtnClick:(id)sender
{
    [[ZEE5PlayerManager sharedInstance] skipIntro];
}

- (IBAction)buttonFullScreenClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    [[ZEE5PlayerManager sharedInstance] setFullScreen:sender.selected];
}

- (IBAction)buttonLockClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    [[ZEE5PlayerManager sharedInstance] setLock:sender.selected];

}
- (IBAction)buttonMuteClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    [[ZEE5PlayerManager sharedInstance] setMute:sender.selected];

}
- (IBAction)buttonSkipNextClicked:(UIButton *)sender
{
    [[ZEE5PlayerManager sharedInstance] tapOnNextButton];

}
- (IBAction)buttonSkipPrevClicked:(UIButton *)sender {
    [[ZEE5PlayerManager sharedInstance] tapOnPrevButton];

}
- (IBAction)buttonMinimizeClicked:(UIButton *)sender {

    [[ZEE5PlayerManager sharedInstance]tapOnMinimizeButton];
}
- (IBAction)buttonReplayClicked:(UIButton *)sender {
    [[ZEE5PlayerManager sharedInstance] replay];

}

- (IBAction)buttonLiveClicked:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"LIVE"])
    {
        [[ZEE5PlayerManager sharedInstance] tapOnLiveButton];
    }
    else
    {
        [[ZEE5PlayerManager sharedInstance] tapOnGoLiveButton];
    }
    
}

- (IBAction)btnShareClicked:(UIButton *)sender {
     NSLog(@"|** BtnShareClicked");
    [[ZEE5PlayerManager sharedInstance]tapOnShareButton];
}


- (IBAction)btnWatchListClicked:(UIButton *)sender {
    NSLog(@"|** btnWatchListClicked 11");
}

- (IBAction)btnCastClicked:(UIButton *)sender
{
    
}
- (IBAction)btnWatchPromoClicked:(id)sender {
}
- (IBAction)btnAudioLangaugeClicked:(UIButton *)sender
{
    [[ZEE5PlayerManager sharedInstance] GetAudioLanguage];
}
- (IBAction)btnSubtitlsClicked:(UIButton *)sender
{
    [[ZEE5PlayerManager sharedInstance] showSubtitleActionSheet];

}
- (IBAction)btnAirPlayClicked:(UIButton *)sender {
    [[ZEE5PlayerManager sharedInstance] airplayButtonClicked];

}

- (void)sliderValueChanged:(Zee5Slider *)sender  withEvent:(UIEvent*)event
{
    [[ZEE5PlayerManager sharedInstance] setSeekTime:sender.value];

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return [self.related count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Zee5CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    RelatedVideos *model = self.related[indexPath.row];
    [cell configureCellWith:model];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.con_top_collectionView.constant = 10;
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [[ZEE5PlayerManager sharedInstance] pause];
        RelatedVideos *model = self.related[indexPath.row];
        
        NSLog(@"|*** Releated Video: didSelect ***|");
        
        [[ZEE5PlayerManager sharedInstance] playSimilarEvent:model.identifier];
        
        [[ZEE5PlayerManager sharedInstance] playVODContent:model.identifier country:ZEE5UserDefaults.getCountry translation:ZEE5UserDefaults.gettranslation withCompletionHandler:^(VODContentDetailsDataModel * _Nullable result, NSString * _Nullable customData) {
                           //completionBlock(result, customData);
                       }];
    }];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kRefreshRelatedVideoList" object:nil];
}


- (IBAction)subscribeNow:(UIButton *)sender {
    [[ZEE5PlayerManager sharedInstance]tapOnSubscribeButton];
}

- (IBAction)loginNow:(UIButton *)sender {
    [[ZEE5PlayerManager sharedInstance]tapOnLoginButton];
}

- (IBAction)bactoPartnetAppAction:(id)sender {
    [[ZEE5PlayerManager sharedInstance]pause];
    //[ZEE5PlayerDeeplinkManager];
}

- (IBAction)upNextAction:(id)sender {
    [[ZEE5PlayerManager sharedInstance]tapOnUpNext];
}
@end

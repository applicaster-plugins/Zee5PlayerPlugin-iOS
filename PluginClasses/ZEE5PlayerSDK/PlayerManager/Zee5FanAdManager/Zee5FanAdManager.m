//
//  Zee5FanAdManager.m
//  ZEE5PlayerSDK
//
//  Created by Mani on 11/07/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

#import "Zee5FanAdManager.h"
//import <FBAudienceNetwork/FBAudienceNetwork.h>
//#import <FBAudienceNetwork/FBAdSettings.h>
#import <Zee5PlayerPlugin/ZEE5PlayerSDK.h>

@interface Zee5FanAdManager()<FBInstreamAdViewDelegate>
{
    
}
//@property (nonatomic, strong) FBInstreamAdView *fanAD;
//@property(nonatomic) NSInteger previousAdTime;
//@property(nonatomic) BOOL preAdPlayed;
//@property(nonatomic) BOOL addFailedToLoad;

@end

@implementation Zee5FanAdManager



static Zee5FanAdManager *sharedManager = nil;
+ (Zee5FanAdManager *)sharedInstance
{
    if (sharedManager) {
        return sharedManager;
    }
    
    static dispatch_once_t  t = 0;
    
    dispatch_once(&t, ^{
        sharedManager = [[Zee5FanAdManager alloc] init];
    });
    
    return sharedManager;
}

#pragma mark: Facebook Ads

-(void)createFanAds
{
//    [self loadFanAds];
//    for (ZEE5AdModel *model in [ZEE5PlayerManager sharedInstance].currentItem.fanAds) {
//        if ([model.time isEqualToString:@"0"]) {
//            [self loadfanAds:0];
//            return;
//        }
//    }
//    [[ZEE5PlayerManager sharedInstance] playWithCurrentItem];
    
}

-(void)loadFanAds
{
//    [FBAdSettings addTestDevice:[FBAdSettings testDeviceHash]];
//    for (ZEE5AdModel *model in [ZEE5PlayerManager sharedInstance].currentItem.fanAds) {
//        FBInstreamAdView *fanAD = [[FBInstreamAdView alloc] initWithPlacementID:model.tag];
//        fanAD.delegate = self;
//        fanAD.tag = [[ZEE5PlayerManager sharedInstance].currentItem.fanAds indexOfObject:model];
//        [fanAD loadAd];
//        model.adView = fanAD;
//        model.tagValue = fanAD.tag;
//    }
}

-(void)loadfanAds:(NSInteger)value
{
//    _previousAdTime = value;
//    if (value == 0) {
//        self.preAdPlayed = YES;
//    }
//    else
//    {
//        self.preAdPlayed = NO;
//    }
//    for (ZEE5AdModel *model in [ZEE5PlayerManager sharedInstance].currentItem.fanAds)
//    {
//        NSInteger currentValue = [model.time integerValue];
//        if (currentValue == value) {
//            self.fanAD = (FBInstreamAdView *)model.adView;
//            [self showInstreamVideoAd];
//            break;
//        }
//    }
}

- (void)showInstreamVideoAd
{
//
//    if (self.fanAD && self.fanAD.isAdValid) {
//        [[ZEE5PlayerManager sharedInstance] pause];
//        self.addFailedToLoad = NO;
//
//        // The ad can now be added to the layout and shown
//        self.fanAD.frame = [ZEE5PlayerManager sharedInstance].playbackView.bounds;
//        self.fanAD.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        [[ZEE5PlayerManager sharedInstance].playbackView addSubview:self.fanAD];
//        UIViewController *rootViewController = (UIViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
//
//        [self.fanAD showAdFromRootViewController:rootViewController];
//
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(tagValue == %d)", self.fanAD.tag];
//        NSArray *getAray = [[ZEE5PlayerManager sharedInstance].currentItem.fanAds filteredArrayUsingPredicate:predicate];
//        //ZEE5AdModel *model = getAray.firstObject;
//
//    }
//    else
//    {
//        self.addFailedToLoad = YES;
//    }
}

//- (void)adViewDidLoad:(FBInstreamAdView *)adView
//{
//    if (self.addFailedToLoad)
//    {
//        [self showInstreamVideoAd];
//    }
//    NSLog(@"Ad is loaded and ready to be displayed");
//}
//- (void)adViewDidClick:(FBInstreamAdView *)adView
//{
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(tagValue == %d)", self.fanAD.tag];
//    NSArray *getAray = [[ZEE5PlayerManager sharedInstance].currentItem.fanAds filteredArrayUsingPredicate:predicate];
//   // ZEE5AdModel *model = getAray.firstObject;
//}
//- (void)adViewDidEnd:(FBInstreamAdView *)adView
//{
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(tagValue == %d)", self.fanAD.tag];
//    NSArray *getAray = [[ZEE5PlayerManager sharedInstance].currentItem.fanAds filteredArrayUsingPredicate:predicate];
//    //ZEE5AdModel *model = getAray.firstObject;
//
//    [self removeFanAdFromSuperview];
//
//    // The app should now proceed to content
//}
//
//- (void)adView:(FBInstreamAdView *)adView didFailWithError:(NSError *)error
//{
//    NSLog(@"Ad failed: %@", error.localizedDescription);
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(tagValue == %d)", self.fanAD.tag];
//    NSArray *getAray = [[ZEE5PlayerManager sharedInstance].currentItem.fanAds filteredArrayUsingPredicate:predicate];
//    //ZEE5AdModel *model = getAray.firstObject;
//    [self removeFanAdFromSuperview];
//
//    // The app should now proceed to content
//}
//
//-(void)removeFanAdFromSuperview
//{
//
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(tagValue == %d)", self.fanAD.tag];
//
//    NSArray *getAray = [[ZEE5PlayerManager sharedInstance].currentItem.fanAds filteredArrayUsingPredicate:predicate];
//    if([getAray count] > 0)
//    {
//        [[ZEE5PlayerManager sharedInstance].currentItem.fanAds removeObject:[getAray firstObject]];
//    }
//
//    [self.fanAD removeFromSuperview];
//    self.fanAD = nil;
//    if (![ZEE5PlayerManager sharedInstance].isStop) {
//        for (ZEE5AdModel *model in [ZEE5PlayerManager sharedInstance].currentItem.fanAds)
//        {
//            if ([model.time isEqualToString:[NSString stringWithFormat:@"%ld",(long)_previousAdTime]]) {
//                [self loadfanAds:_previousAdTime];
//                return;
//            }
//        }
//        if (_preAdPlayed) {
//            [[ZEE5PlayerManager sharedInstance] playWithCurrentItem];
//        }
//        [[ZEE5PlayerManager sharedInstance] hideUnHideTopView:NO];
//
//        [[ZEE5PlayerManager sharedInstance] play];
//    }
//
//
//    NSLog(@"Ad ended");
//}
//
//-(void)stopFanAd
//{
//    if (_fanAD != nil) {
//        [self adViewDidEnd:_fanAD];
//    }
//
//}


@end

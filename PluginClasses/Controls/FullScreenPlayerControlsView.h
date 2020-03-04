//
//  FullScreenPlayerControlsView.h
//  Zapp-App
//
//  Created by Miri on 27/12/2018.
//  Copyright © 2017 Applicaster LTD. All rights reserved.
//

@import ApplicasterSDK;
@import MediaPlayer;
#import <ApplicasterSDK/APPlayerControls.h>
#import <ApplicasterSDK/APPlayerControlsView.h>
#import <ApplicasterSDK/APUnhittableView.h>
#import <ApplicasterSDK/APGradientView.h>
#import "HybridPlayerControlsView.h"

@interface FullScreenPlayerControlsView : HybridPlayerControlsView <APPlayerControls>

@property (nonatomic, readonly, weak) IBOutlet UIButton *shrinkButton;
@property (weak, nonatomic) IBOutlet UILabel *playableName;
@property (weak, nonatomic) IBOutlet UIImageView *lineImageView;

- (void)setData:(NSString *)title andPluginStyles:(NSDictionary *)pluginStyles;

@end

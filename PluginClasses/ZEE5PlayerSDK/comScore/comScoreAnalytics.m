//
//  comScoreAnalytics.m
//  ZEE5PlayerSDK
//
//  Created by Tejas Todkar on 22/10/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

#import "comScoreAnalytics.h"

@implementation comScoreAnalytics

static comScoreAnalytics *comScoreobject = nil;

+ (id) comScoresharedInstance
{
    if (! comScoreobject)
    {
        comScoreobject = [[comScoreAnalytics alloc] init];
    }
    return comScoreobject;
}

- (id)init
{
    if (! comScoreobject) {

        comScoreobject = [super init];
        SCORPublisherConfiguration *myPublisherConfig = [SCORPublisherConfiguration publisherConfigurationWithBuilderBlock:^(SCORPublisherConfigurationBuilder *builder)
        {
            builder.publisherId = @"9254297";
        }];
        
        [[SCORAnalytics configuration] addClientWithConfiguration:myPublisherConfig];
        [SCORAnalytics start];
        
        NSLog(@"%s", __PRETTY_FUNCTION__);
    }
    return comScoreobject;
}


@end

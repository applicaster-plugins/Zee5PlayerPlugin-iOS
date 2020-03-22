//
//  FormRequestParamsAdapter.m
//  ZEE5PlayerSDK
//
//  Created by Mani on 06/06/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

#import "FormRequestParamsAdapter.h"
#import <PlayKit/PlayKit-Swift.h>

@interface FormRequestParamsAdapter()
@end


@implementation FormRequestParamsAdapter

-(PKRequestParams *)adaptWithRequestParams:(PKRequestParams *)requestParams
{
    PKRequestParams *params = [[PKRequestParams alloc] initWithUrl:requestParams.url headers:self.header];
    return params;
}

- (void)updateRequestAdapterWith:(id<Player> _Nonnull)player {
    
}


@end

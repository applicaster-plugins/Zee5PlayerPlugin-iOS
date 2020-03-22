//
//  ViewController.m
//  BasicSample
//
//  Created by Gal Orlanczyk on 15/03/2017.
//  Copyright © 2017 Kaltura. All rights reserved.
//

#import <PlayKit/PlayKit-Swift.h>
#import "FormPostFairPlayLicenseProvider.h"


@interface FormPostFairPlayLicenseProvider()
@end


@implementation FormPostFairPlayLicenseProvider

- (void)getLicenseWithSpc:(NSData * _Nonnull)spc assetId:(NSString * _Nonnull)assetId requestParams:(PKRequestParams * _Nonnull)requestParams callback:(void (^ _Nonnull)(NSData * _Nullable, NSTimeInterval, NSError * _Nullable))callback
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestParams.url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    request.HTTPBody = [[NSString stringWithFormat:@"assetid=%@&spc=%@", assetId, [spc base64EncodedStringWithOptions:0]] dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    
    [requestParams.headers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop)
    {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:self.customData forHTTPHeaderField:@"customData"];
    
    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Handle HTTP error
        if (error)
        {
            callback(nil, 0, error);
            return;
        }
        
        // ASSUMING the response data is base64-encoded CKC.
        NSData *ckc = [[NSData alloc] initWithBase64EncodedData:data options:0];
        if (!ckc)
        {
            callback(nil, 0, [NSError errorWithDomain:@"FormPostFairPlayLicenseProvider" code:1 userInfo:nil]);
            return;
        }
        
        callback(ckc, /* offline duration */ 0, nil);
        
    }] resume];
}

@end

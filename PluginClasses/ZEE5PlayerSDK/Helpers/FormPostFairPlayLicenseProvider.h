//
//  FormPostFairPlayLicenseProvider.h
//  ZEE5PlayerSDK
//
//  Created by Mani on 03/06/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//
#import <PlayKit/PlayKit-Swift.h>

#ifndef FormPostFairPlayLicenseProvider_h
#define FormPostFairPlayLicenseProvider_h

@interface FormPostFairPlayLicenseProvider: NSObject <FairPlayLicenseProvider>
@property (nonatomic) NSString* customData;
@end
#endif /* FormPostFairPlayLicenseProvider_h */

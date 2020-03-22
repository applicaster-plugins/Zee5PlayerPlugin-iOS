//
//  CdnHandler.h
//  Zee5PlayerPlugin
//
//  Created by Tejas Todkar on 16/03/20.
//

#import <Foundation/Foundation.h>
#import "ZEE5PlayerSDK.h"


NS_ASSUME_NONNULL_BEGIN

typedef void(^CDNhandlerSuccess)(id _Nullable result , NSString *CDN);
typedef void(^CDNhandlerfailure)(ZEE5SdkError * _Nullable error);

@interface CdnHandler : NSObject
+ (CdnHandler *)sharedInstance;

@property(nonatomic,copy) NSString *kCDNUrl;
@property(nonatomic,copy) NSDictionary *CDN;

-(void)getKCDNUrl:(NSString *)ContentID withCompletion:(CDNhandlerSuccess)Success andFailure:(CDNhandlerfailure)failure;

/////CDN///////
-(NSString*) CdnToCdnURl:(NSString*)URL;


@end

NS_ASSUME_NONNULL_END

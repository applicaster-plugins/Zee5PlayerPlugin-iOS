//
//  CdnHandler.m
//  Zee5PlayerPlugin
//
//  Created by Tejas Todkar on 16/03/20.
//

#import "CdnHandler.h"

@implementation CdnHandler

static CdnHandler *sharedManager = nil;
+ (CdnHandler *)sharedInstance
{
    if (sharedManager)
    {
        return sharedManager;
    }
    
    static dispatch_once_t  t = 0;
    
    dispatch_once(&t, ^{
        sharedManager = [[CdnHandler alloc] init];
        sharedManager.CDN = @{@"TATA":@"https://mediatata.zee5.com",
                              @"AKAMAI":@"https://zee5vod.akamaized.net",
                              @"AMAZON":@"https://mediacloudfront.zee5.com"};
     
        // *******Default Used when Api Response Failed****//////
        
        sharedManager.kCDNUrl = @"https://zee5vod.akamaized.net";
        
    });
    return sharedManager;
}

-(void)getKCDNUrl:(NSString *)ContentID withCompletion:(CDNhandlerSuccess)Success andFailure:(CDNhandlerfailure)failure
{
    
    NSDictionary *param =@{@"c3.vr":@"2", @"c3.ck":@"28bbf0a3decf6d1165032bfd835d6e1844c5d44d",@"c3.rt":@"p",@"c3.vp":@"s",@"c3.im":@"d",@"c3.um":@"d",@"c3.r1":@"akamai",@"c3.r2":@"cloudfront",@"c3.r3":@"tata",@"c3.at":@"ON_DEMAND",@"c3.ext.VI":@"956528b0-efcd-41dd-bda4-adb1a907534f",@"c3.ext.DEVICE":@"Web",@"c3.ext.PROVIDER":@"shaka",@"c3.ext.contentID":ContentID
       };
       
       NSDictionary *headers = @{};
       
       [[NetworkManager sharedInstance] makeHttpGetRequest:BaseUrls.getCDNApi requestParam:param requestHeaders:headers withCompletionHandler:^(id result)
       {
           NSArray *CDNList = [result ValueForKeyWithNullChecking:@"resource_list"];
           NSString *CDN = [[CDNList valueForKey:@"cdn"]objectAtIndex:0];
           self.kCDNUrl = [self CdnToCdnURl:CDN];
           Success(result,self.kCDNUrl);
        
       }failureBlock:^(ZEE5SdkError *error)
        {
           failure(error);
       }];
}


-(NSString*) CdnToCdnURl:(NSString*)URL
{
    NSDictionary *Dict = self.CDN;
    return [Dict valueForKey:URL];
}



@end

//
//  DeviceManager.m
//  ZEE5PlayerSDK
//
//  Created by shriraj.salunkhe on 07/10/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

#import "DeviceManager.h"
#import <AdSupport/ASIdentifierManager.h>


@implementation DeviceManager
static DevicemanageState DeviceState;


+(void)addDevice
{
    UIDevice *device = [UIDevice currentDevice];
    NSString *Devicename = device.name;
    NSString  *currentDeviceId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
      

    NSMutableDictionary *postData  = [[NSMutableDictionary alloc] init];
    [postData setValue:Devicename forKey:@"name"];
    [postData setValue:currentDeviceId forKey:@"identifier"];
 
    NSString *userToken = [NSString stringWithFormat:@"%@", ZEE5UserDefaults.getUserToken];
    
    NSDictionary *headers = @{@"Content-Type":@"application/json",@"Authorization":userToken};
    
   
    [[NetworkManager sharedInstance]makeHttpRawPostRequest:@"POST" requestUrl:BaseUrls.DeviceApi requestParam:postData requestHeaders:headers withCompletionHandler:^(id  _Nullable result)
    {
     
        NSInteger stateCode;
        stateCode = [[result valueForKey:@"code"]integerValue];
  
        
        if (stateCode == 3600)
        {
            DeviceState =DeviceAllreadyadded ;
        }
        else if (stateCode == 3602)
        {
            DeviceState = DeviceMaxout;
           [[ZEE5PlayerManager sharedInstance]deleteAllDevice:@"Cancel"];
        }
        else if (stateCode ==0)
        {
            DeviceState = DeviceAdded;
            [[ZEE5PlayerManager sharedInstance]deleteAllDevice:@"Cancel"];
          
        }
    }
failureBlock:^(ZEE5SdkError * _Nullable error)
{
    }
     ];
}

+(void)deleteDevice;
{
    NSString *userToken = [NSString stringWithFormat:@"%@", ZEE5UserDefaults.getUserToken];
    
    NSDictionary *headers = @{@"Content-Type":@"application/json",@"Authorization":userToken};
    
    
    [[NetworkManager sharedInstance]makeHttpRawRequest:@"DELETE" requestUrl:BaseUrls.DeviceApi  requestHeaders:headers withCompletionHandler:^(id  _Nullable result)
     {
         NSInteger stateCode;
         
         stateCode = [[result valueForKey:@"code"]integerValue];
         NSString *message = [result valueForKey:@"message"];
         
         if (stateCode == 3600)
         {
             DeviceState = DeviceAllreadyadded;
         }
         else if (stateCode == 3607)
         {
             DeviceState = DevicecantDelete;
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                 message:message delegate:self cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil, nil];
             [alert show];
//             [alert release];
             
        
         }
         else if (stateCode ==0)
         {
             [self addDevice];
             DeviceState = DeviceAdded;
         }
     }
      failureBlock:^(ZEE5SdkError * _Nullable error)
    {
    }
     ];
    
}

+(DevicemanageState)getStateOfDevice
{
    return DeviceState;
}



@end



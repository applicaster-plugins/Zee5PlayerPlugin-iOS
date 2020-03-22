//
//  DeviceManager.h
//  ZEE5PlayerSDK
//
//  Created by shriraj.salunkhe on 07/10/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZEE5PlayerSDK.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^DeviceCompletion)(id _Nullable result);
typedef void(^DeviceFailure)(ZEE5SdkError * _Nullable error);

typedef enum state
{
    DeviceAllreadyadded,
    DeviceAdded,
    DeviceDeleted,
    DeviceMaxout,
    DevicecantDelete
} DevicemanageState;

@interface DeviceManager : NSObject


+(void)addDevice;
+(void)deleteDevice;
+(DevicemanageState)getStateOfDevice;

@end

NS_ASSUME_NONNULL_END

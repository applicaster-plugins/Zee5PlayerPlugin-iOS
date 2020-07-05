//
//  NetworkManager.h
//  ZEE5PlayerSDK
//
//  Created by admin on 04/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Zee5PlayerPlugin/ZEE5PlayerSDK.h>

typedef void(^SuccessHandler)(id _Nullable result);
typedef void(^FailureHandler)(ZEE5SdkError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface NetworkManager : NSObject
+ (NetworkManager *)sharedInstance;
- (void)cancelAllRequests;

- (void)authenticateWithServer:(NSString *)app_id userId:(NSString *)user_id andSDK_key:(NSString *)key withCompletionHandler:(SuccessHandler)success failureBlock:(FailureHandler)failure;

- (void)makeHttpGetRequest:(NSString *)urlString requestParam:(NSDictionary*)param requestHeaders:(NSDictionary*)headers withCompletionHandler:(SuccessHandler)success failureBlock:(FailureHandler)failure;

- (void)makeHttpRequest:(NSString *)requestname requestUrl:(NSString*)urlString requestParam:(NSDictionary*)param requestHeaders:(NSDictionary*)headers withCompletionHandler:(SuccessHandler)success failureBlock:(FailureHandler)failure;

- (void)makeHttpRawPostRequest:(NSString *)requestname requestUrl:(NSString*)urlString requestParam:(NSDictionary *)param requestHeaders:(NSDictionary*)headers withCompletionHandler:(SuccessHandler)success failureBlock:(FailureHandler)failure;

- (void)makeHttpRawRequest:(NSString *)requestname requestUrl:(NSString*)urlString requestHeaders:(NSDictionary*)headers withCompletionHandler:(SuccessHandler)success failureBlock:(FailureHandler)failure;


@end

NS_ASSUME_NONNULL_END

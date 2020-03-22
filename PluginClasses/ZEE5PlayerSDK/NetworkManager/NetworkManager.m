//
//  NetworkManager.m
//  ZEE5PlayerSDK
//
//  Created by admin on 04/12/18.
//  Copyright © 2018 ZEE5. All rights reserved.
//

#import "NetworkManager.h"
#import "ZEE5PlayerSDK.h"

@interface NetworkManager()<NSURLSessionDelegate>
@property (strong, nonatomic) NSURLSession *session;
@end

@implementation NetworkManager

static NetworkManager *sharedManager = nil;

+ (NetworkManager *)sharedInstance
{
    if (sharedManager) {
        return sharedManager;
    }
    
    static dispatch_once_t  t = 0;
    
    dispatch_once(&t, ^{
        sharedManager = [[NetworkManager alloc] init];
    });
    
    return sharedManager;
}

- (id)init
{
    if (self = [super init]) {
        
        self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    
    return self;
}

- (void)authenticateWithServer:(NSString *)app_id userId:(NSString *)user_id andSDK_key:(NSString *)key withCompletionHandler:(SuccessHandler)success failureBlock:(FailureHandler)failure
{

}

- (void)makeHttpGetRequest:(NSString *)urlString requestParam:(NSDictionary*)param requestHeaders:(NSDictionary*)headers withCompletionHandler:(SuccessHandler)success failureBlock:(FailureHandler)failure
{
    
    NSArray *allKeys = [param allKeys];
    
    NSMutableString *full_Url_String = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@?", urlString]];
    
    for(NSString *key in allKeys)
    {
        [full_Url_String appendString:[NSString stringWithFormat:@"%@=%@&", key, [param valueForKey:key]]];
    }
    
    if ([full_Url_String length] > 0)
    {
        full_Url_String = [[full_Url_String substringToIndex:[full_Url_String length] - 1] mutableCopy];
    }
    NSLog(@"%@", full_Url_String);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *escapedPath = [full_Url_String stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [request setURL:[NSURL URLWithString:escapedPath]];

    [request setHTTPMethod:@"GET"];
    
    for (NSString *key in headers.keyEnumerator)
    {
        [request setValue:[headers valueForKey:key] forHTTPHeaderField:key];
    }

    
    NSURLSessionDataTask *postDataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        [sharedManager checkForValidityForData:data withURLResponse:response andError:error withCompletionHandler:^(id result)
         {
            success(result);
        } failureBlock:^(id error) {
            failure(error);
            
        }];
    }];
    [postDataTask resume];
    

}

- (void)makeHttpRequest:(NSString *)requestname requestUrl:(NSString*)urlString requestParam:(NSDictionary*)param requestHeaders:(NSDictionary*)headers withCompletionHandler:(SuccessHandler)success failureBlock:(FailureHandler)failure;
{
    
    NSError *error = nil;
   
    
    NSData *dataFromDict  = [NSJSONSerialization dataWithJSONObject:param
           options:NSJSONWritingPrettyPrinted
             error:&error];


    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[dataFromDict length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *escapedPath = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    [request setURL:[NSURL URLWithString:escapedPath]];
    [request setHTTPMethod:requestname];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    for (NSString *key in headers.keyEnumerator)
    {
        [request setValue:[headers valueForKey:key] forHTTPHeaderField:key];
    }
    [request setHTTPBody:dataFromDict];
    
    NSURLSessionDataTask *postDataTask = [_session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
      
        [sharedManager checkForValidityForData:data withURLResponse:response andError:error withCompletionHandler:^(id result)
        {
            success(result);
        } failureBlock:^(id error) {
            failure(error);
            
        }];
    }];
    [postDataTask resume];



}


-(void)makeHttpRawPostRequest:(NSString *)requestname requestUrl:(NSString *)urlString requestParam:(NSDictionary *)param requestHeaders:(NSDictionary *)headers withCompletionHandler:(SuccessHandler)success failureBlock:(FailureHandler)failure
{
    
    NSError *error =nil;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
   
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:param
                                                           options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[jsonData length]];
    [request setHTTPBody:jsonData];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:requestname];
   
    for (NSString *key in headers.keyEnumerator)
    {
        [request setValue:[headers valueForKey:key] forHTTPHeaderField:key];
    }
    
    
    NSURLSessionDataTask *postDataTask = [_session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
        {
        id jsonObj;
        
             if (data)
             {
                 jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                
                 success(jsonObj);
             }
      
    }];
    [postDataTask resume];

}


-(void)makeHttpRawRequest:(NSString *)requestname requestUrl:(NSString *)urlString requestHeaders:(NSDictionary *)headers withCompletionHandler:(SuccessHandler)success failureBlock:(FailureHandler)failure
{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:requestname];
    
    for (NSString *key in headers.keyEnumerator)
    {
        [request setValue:[headers valueForKey:key] forHTTPHeaderField:key];
    }
    
    
    NSURLSessionDataTask *postDataTask = [_session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        id jsonObj;
                                              
            if (data)
            {
              jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
              success(jsonObj);
            }
                                              
    }];
    [postDataTask resume];
    
}



- (void)checkForValidityForData:(NSData *)data withURLResponse:(NSURLResponse *)response andError:(NSError *)error withCompletionHandler:(SuccessHandler)success failureBlock:(FailureHandler)failure
{
    
    ZEE5SdkError *generalError =[ZEE5SdkError initWithErrorCode:[(NSHTTPURLResponse *)response statusCode] andZee5Code:0 andMessage:@"Unknown error"];
    
    
    id jsonObj;
    
    if (data)
    {
    
        jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    }
    
    if (error) {
        
        generalError = [ZEE5SdkError initWithErrorCode:[error code] andZee5Code:0 andMessage:[error localizedDescription]];
        failure(generalError);
    }
    else
    {
        
        NSLog(@"%ld", (long)[(NSHTTPURLResponse *)response statusCode]);
        switch ([(NSHTTPURLResponse *)response statusCode]) {
            case 200:
            {
                if (data) {
                    success(jsonObj);
                }
                else
                {
                    failure(nil);
                }
            }
                break;
            case 403:
            {
                if ([jsonObj isKindOfClass:[NSDictionary class]] && [[jsonObj valueForKey:@"message"] isKindOfClass:[NSString class]]) {
                    generalError = [ZEE5SdkError initWithErrorCode:403 andZee5Code:[[jsonObj valueForKey:@"code"]intValue] andMessage:[jsonObj valueForKey:@"message"]];
                }
                failure(generalError);
            }
                break;
            case 404:
            {
                
                if ([jsonObj isKindOfClass:[NSDictionary class]] && [[jsonObj valueForKey:@"message"] isKindOfClass:[NSString class]])
                {
                    generalError = [ZEE5SdkError initWithErrorCode:404 andZee5Code:[[jsonObj valueForKey:@"code"]intValue] andMessage:[jsonObj valueForKey:@"message"]];
                }
                failure(generalError);
            }
                break;
            case 400:
            {
                if ([jsonObj isKindOfClass:[NSDictionary class]] && [[jsonObj valueForKey:@"message"] isKindOfClass:[NSString class]]) {
                    generalError = [ZEE5SdkError initWithErrorCode:400 andZee5Code:[[jsonObj valueForKey:@"code"]intValue] andMessage:[jsonObj valueForKey:@"message"]];
                }
                failure(generalError);
            }
                break;
            case 401:
            {
                
                if ([jsonObj isKindOfClass:[NSDictionary class]] && [[jsonObj valueForKey:@"message"] isKindOfClass:[NSString class]]) {
                    generalError = [ZEE5SdkError initWithErrorCode:401 andZee5Code:[[jsonObj valueForKey:@"code"]intValue] andMessage:[jsonObj valueForKey:@"message"]];
                }
                if ([jsonObj isKindOfClass:[NSDictionary class]] && [[jsonObj valueForKey:@"error_msg"] isKindOfClass:[NSString class]]) {
                    generalError = [ZEE5SdkError initWithErrorCode:404 andZee5Code:0 andMessage:[jsonObj valueForKey:@"error_msg"]];
                }
                failure(generalError);
            }
                break;
            default:
            {
                failure(generalError);
            }
                break;
        }
    }
}


@end

//
//  SingletonClass.m
//  Zee5PlayerPlugin
//
//  Created by Tejas Todkar on 03/06/20.
//

#import "SingletonClass.h"



#import <Zee5PlayerPlugin/Zee5PlayerPlugin-Swift.h>

@implementation SingletonClass
@synthesize ViewsArray,isAdPause,isAdStarted,isAdIntegrate,isofflinePlayer,isMidrolldone,offlinePlayerDuration,offlinePlayerCurrentTime,hlsErrorCount;

+ (id)sharedManager {

    static SingletonClass *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc] init];
    });
    return singleton;
}
- (id)init {
  if (self = [super init]) {
      ViewsArray = [[NSMutableArray alloc]init];
      isAdPause = NO;
      isAdStarted = NO;
      isAdIntegrate = NO;
      isMidrolldone = NO;
      isofflinePlayer = NO;
      offlinePlayerCurrentTime = 0;
      offlinePlayerDuration = 0;
      hlsErrorCount = 0;
  }
  return self;
}

- (void)dealloc {
  // Should never be called, but just here for clarity really.
}


@end

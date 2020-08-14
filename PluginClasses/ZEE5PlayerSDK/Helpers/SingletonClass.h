//
//  SingletonClass.h
//  Zee5PlayerPlugin
//
//  Created by Tejas Todkar on 03/06/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface SingletonClass : NSObject{
    
}

@property (strong, nonatomic) NSMutableArray<UIView *> *ViewsArray;
@property(nonatomic) BOOL isAdPause;
@property(nonatomic) BOOL isAdStarted;
@property(nonatomic) BOOL isAdIntegrate;
@property(nonatomic) BOOL isMidrolldone;

+ (id)sharedManager;


@end

NS_ASSUME_NONNULL_END

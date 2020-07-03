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

@property (strong, nonatomic) NSMutableArray *ViewsArray;
@property(nonatomic) BOOL isAdPause;
@property(nonatomic) BOOL isAdStarted;

+ (id)sharedManager;


@end

NS_ASSUME_NONNULL_END

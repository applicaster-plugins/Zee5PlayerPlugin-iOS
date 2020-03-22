#import <UIKit/UIKit.h>

@interface SubscriptionAdditional : NSObject

@property (nonatomic, strong) NSString * paymentinfo;
@property (nonatomic, strong) NSString * paymentMode;
@property (nonatomic, strong) NSString * couponCode;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

-(NSDictionary *)toDictionary;
@end

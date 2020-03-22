#import <UIKit/UIKit.h>

@interface SubscriptionPaymentProvider : NSObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * productReference;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

-(NSDictionary *)toDictionary;
@end
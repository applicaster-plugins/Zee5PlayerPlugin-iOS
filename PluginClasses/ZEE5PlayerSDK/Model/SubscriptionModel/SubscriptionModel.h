#import <UIKit/UIKit.h>
#import "SubscriptionAdditional.h"
#import "SubscriptionPlan.h"

@interface SubscriptionModel : NSObject

@property (nonatomic, strong) SubscriptionAdditional * additional;
@property (nonatomic, assign) NSInteger allowedBillingCycles;
@property (nonatomic, strong) NSString * createDate;
@property (nonatomic, strong) NSObject * freeTrial;
@property (nonatomic, strong) NSString * idField;
@property (nonatomic, strong) NSString * identifier;
@property (nonatomic, strong) NSString * paymentProvider;
@property (nonatomic, assign) BOOL recurringEnabled;
@property (nonatomic, assign) BOOL isSubscriptionActive;
@property (nonatomic, strong) NSString * state;
@property (nonatomic, strong) NSString * subscriptionEnd;
@property (nonatomic, strong) SubscriptionPlan * subscriptionPlan;
@property (nonatomic, strong) NSString * subscriptionStart;
@property (nonatomic, assign) NSInteger usedBillingCycles;
@property (nonatomic, strong) NSString * userId;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

-(NSDictionary *)toDictionary;
@end
